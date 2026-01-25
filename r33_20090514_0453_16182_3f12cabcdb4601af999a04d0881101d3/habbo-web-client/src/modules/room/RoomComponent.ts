/**
 * Room Component Class
 *
 * Ported from: hh_room/Cast External ParentScript 4 - Room Component Class.ls
 *
 * Manages all objects within a room including users, furniture (active objects),
 * wall decorations (passive objects), and wall items (item objects).
 * Handles object creation, updates, and removal.
 */

import { messageBus } from '../../core/MessageBus';
import { objectManager } from '../../core/ObjectManager';
import { getVariable } from '../../core/VariableContainer';
import { RoomGeometry } from './RoomGeometry';
import {
  ActiveObject,
  PassiveObject,
  ItemObject,
  UserObject,
  BaseRoomObject,
} from './RoomObjects';
import {
  RoomType,
  RoomData,
  UserObjectDef,
  ActiveObjectDef,
  PassiveObjectDef,
  ItemObjectDef,
  StatusUpdate,
  ActionDef,
  SlideObjectData,
  ChatMessage,
  TradeState,
} from './types';

export class RoomComponent {
  private id: string = 'room_component';
  private roomId: string = '';
  private roomType: RoomType = 'public';
  private roomData: RoomData | null = null;

  // Object lists
  private userObjects: Map<string, UserObject> = new Map();
  private activeObjects: Map<string, ActiveObject> = new Map();
  private passiveObjects: Map<string, PassiveObject> = new Map();
  private itemObjects: Map<string, ItemObject> = new Map();

  // Sliding objects for animation
  private slideObjects: Map<string, SlideObjectData> = new Map();

  // Room state
  private isOwner: boolean = false;
  private hasRights: boolean = false;
  private controllerLevel: number = 0;

  // Trade state
  private tradeState: TradeState = {
    active: false,
    ownItems: [],
    partnerItems: [],
    ownAccepted: false,
    partnerAccepted: false,
  };

  // Class container for dynamic object classes
  private classContainer: Map<string, string> = new Map();

  // Geometry reference (set by RoomInterface)
  private geometry: RoomGeometry | null = null;

  // Shadow manager
  private shadowManagerId: string | null = null;

  constructor() {
    this.classContainer.set('bodypart', 'Bodypart Class EX');
    this.classContainer.set('activeobject', 'Active Object Class');
    this.classContainer.set('passiveobject', 'Passive Object Class');
    this.classContainer.set('itemobject', 'Item Object Class');
    this.classContainer.set('userobject', 'Human Class EX');
  }

  getId(): string {
    return this.id;
  }

  getRoomId(): string {
    return this.roomId;
  }

  getRoomType(): RoomType {
    return this.roomType;
  }

  setGeometry(geometry: RoomGeometry): void {
    this.geometry = geometry;
  }

  getClassContainer(): Map<string, string> {
    return this.classContainer;
  }

  getShadowManager(): string | null {
    return this.shadowManagerId;
  }

  /**
   * Initialize the room component for a new room
   */
  enterRoom(roomData: RoomData): boolean {
    this.leaveRoom(); // Clean up any existing room

    this.roomId = roomData.id;
    this.roomType = roomData.type;
    this.roomData = roomData;
    this.isOwner = false;
    this.hasRights = false;
    this.controllerLevel = 0;

    console.log(`RoomComponent: Entering room ${this.roomId} (${this.roomType})`);

    messageBus.emit('room:entered', { roomId: this.roomId, roomType: this.roomType });

    return true;
  }

  /**
   * Leave the current room and clean up
   */
  leaveRoom(): void {
    if (!this.roomId) return;

    // Remove all objects
    for (const [id, obj] of this.userObjects) {
      obj.deconstruct();
    }
    this.userObjects.clear();

    for (const [id, obj] of this.activeObjects) {
      obj.deconstruct();
    }
    this.activeObjects.clear();

    for (const [id, obj] of this.passiveObjects) {
      obj.deconstruct();
    }
    this.passiveObjects.clear();

    for (const [id, obj] of this.itemObjects) {
      obj.deconstruct();
    }
    this.itemObjects.clear();

    this.slideObjects.clear();

    // Reset trade state
    this.tradeState = {
      active: false,
      ownItems: [],
      partnerItems: [],
      ownAccepted: false,
      partnerAccepted: false,
    };

    messageBus.emit('room:left', { roomId: this.roomId });

    this.roomId = '';
    this.roomData = null;
  }

  // ==================== User Objects ====================

  /**
   * Create a user object in the room
   */
  createUserObject(data: UserObjectDef): UserObject | null {
    if (this.userObjects.has(data.id)) {
      console.warn(`RoomComponent: User ${data.id} already exists`);
      return this.userObjects.get(data.id)!;
    }

    const user = new UserObject();
    if (this.geometry) {
      user.setGeometry(this.geometry);
    }

    if (!user.define(data)) {
      console.error(`RoomComponent: Failed to create user ${data.id}`);
      return null;
    }

    this.userObjects.set(data.id, user);
    objectManager.register(`user_${data.id}`, user);

    messageBus.emit('room:userAdded', { userId: data.id, userName: data.name });

    return user;
  }

  /**
   * Remove a user from the room
   */
  removeUserObject(id: string): boolean {
    const user = this.userObjects.get(id);
    if (!user) return false;

    user.deconstruct();
    this.userObjects.delete(id);
    objectManager.remove(`user_${id}`);

    messageBus.emit('room:userRemoved', { userId: id });

    return true;
  }

  /**
   * Get a user object by ID
   */
  getUserObject(id: string): UserObject | null {
    return this.userObjects.get(id) ?? null;
  }

  /**
   * Get all user objects
   */
  getUserObjects(): UserObject[] {
    return Array.from(this.userObjects.values());
  }

  /**
   * Update user status
   */
  updateUserStatus(update: StatusUpdate): void {
    const user = this.userObjects.get(update.id);
    if (!user) return;

    const actionIndex: string[] = [];
    const actionDefs: ActionDef[] = [];

    for (const action of update.actions) {
      actionIndex.push(action.name);
      actionDefs.push(action);
    }

    user.resetValues(
      update.x,
      update.y,
      update.h,
      update.headDirection,
      update.bodyDirection,
      actionIndex
    );

    // Process actions
    for (const action of actionDefs) {
      this.processUserAction(user, action);
    }

    user.refresh(update.x, update.y, update.h);
  }

  /**
   * Process a user action
   */
  private processUserAction(user: UserObject, action: ActionDef): void {
    const actionName = action.name;
    const params = action.params;

    switch (actionName) {
      case 'mv': {
        const [x, y, h] = params.split(',').map(Number);
        user.actionMv(x, y, h);
        break;
      }
      case 'sit': {
        const height = parseFloat(params);
        user.actionSit(height);
        break;
      }
      case 'lay': {
        const height = parseFloat(params);
        user.actionLay(height);
        break;
      }
      case 'dance': {
        const style = parseInt(params, 10);
        user.actionDance(style);
        break;
      }
      case 'wave':
        user.actionWave();
        break;
      case 'talk':
        user.actionTalk();
        break;
      case 'carryd':
      case 'carryf':
      case 'cri':
        user.actionCarry(params);
        break;
      case 'fx': {
        const effectId = parseInt(params, 10);
        user.actionFx(effectId);
        break;
      }
      case 'trd':
        user.actionTrade();
        break;
      default:
        // Unknown action
        break;
    }
  }

  // ==================== Active Objects (Floor Furniture) ====================

  /**
   * Create an active object (floor furniture)
   */
  createActiveObject(data: ActiveObjectDef): ActiveObject | null {
    if (this.activeObjects.has(data.id)) {
      console.warn(`RoomComponent: Active object ${data.id} already exists`);
      return this.activeObjects.get(data.id)!;
    }

    const obj = new ActiveObject();
    if (this.geometry) {
      obj.setGeometry(this.geometry);
    }

    if (!obj.define(data)) {
      console.error(`RoomComponent: Failed to create active object ${data.id}`);
      return null;
    }

    this.activeObjects.set(data.id, obj);
    objectManager.register(`active_${data.id}`, obj);

    messageBus.emit('room:activeObjectAdded', { objectId: data.id, objectClass: data.class });

    return obj;
  }

  /**
   * Remove an active object
   */
  removeActiveObject(id: string): boolean {
    const obj = this.activeObjects.get(id);
    if (!obj) return false;

    obj.deconstruct();
    this.activeObjects.delete(id);
    this.slideObjects.delete(id);
    objectManager.remove(`active_${id}`);

    messageBus.emit('room:activeObjectRemoved', { objectId: id });

    return true;
  }

  /**
   * Get an active object by ID
   */
  getActiveObject(id: string): ActiveObject | null {
    return this.activeObjects.get(id) ?? null;
  }

  /**
   * Get all active objects
   */
  getActiveObjects(): ActiveObject[] {
    return Array.from(this.activeObjects.values());
  }

  /**
   * Move an active object
   */
  moveActiveObject(id: string, x: number, y: number, h: number, direction?: number): void {
    const obj = this.activeObjects.get(id);
    if (!obj) return;

    obj.moveTo(x, y, h);
    if (direction !== undefined) {
      obj.rotate(direction - obj.getLocation().x); // Approximate direction change
    }
  }

  /**
   * Update active object state/data
   */
  updateActiveObjectData(id: string, data: string): void {
    const obj = this.activeObjects.get(id);
    if (!obj) return;

    // Object-specific data update would go here
    messageBus.emit('room:activeObjectUpdated', { objectId: id, data });
  }

  // ==================== Passive Objects (Wall Decorations) ====================

  /**
   * Create a passive object
   */
  createPassiveObject(data: PassiveObjectDef): PassiveObject | null {
    if (this.passiveObjects.has(data.id)) {
      return this.passiveObjects.get(data.id)!;
    }

    const obj = new PassiveObject();
    if (this.geometry) {
      obj.setGeometry(this.geometry);
    }

    if (!obj.define(data)) {
      return null;
    }

    this.passiveObjects.set(data.id, obj);
    return obj;
  }

  /**
   * Remove a passive object
   */
  removePassiveObject(id: string): boolean {
    const obj = this.passiveObjects.get(id);
    if (!obj) return false;

    obj.deconstruct();
    this.passiveObjects.delete(id);
    return true;
  }

  /**
   * Get passive object(s)
   */
  getPassiveObject(idOrList: string | 'list'): PassiveObject | PassiveObject[] | null {
    if (idOrList === 'list') {
      return Array.from(this.passiveObjects.values());
    }
    return this.passiveObjects.get(idOrList) ?? null;
  }

  // ==================== Item Objects (Wall Items) ====================

  /**
   * Create an item object (wall item)
   */
  createItemObject(data: ItemObjectDef): ItemObject | null {
    if (this.itemObjects.has(data.id)) {
      console.warn(`RoomComponent: Item ${data.id} already exists`);
      return this.itemObjects.get(data.id)!;
    }

    const obj = new ItemObject();
    if (this.geometry) {
      obj.setGeometry(this.geometry);
    }

    if (!obj.define(data)) {
      console.error(`RoomComponent: Failed to create item ${data.id}`);
      return null;
    }

    this.itemObjects.set(data.id, obj);
    objectManager.register(`item_${data.id}`, obj);

    messageBus.emit('room:itemObjectAdded', { objectId: data.id, objectClass: data.class });

    return obj;
  }

  /**
   * Remove an item object
   */
  removeItemObject(id: string): boolean {
    const obj = this.itemObjects.get(id);
    if (!obj) return false;

    obj.deconstruct();
    this.itemObjects.delete(id);
    objectManager.remove(`item_${id}`);

    messageBus.emit('room:itemObjectRemoved', { objectId: id });

    return true;
  }

  /**
   * Get an item object by ID
   */
  getItemObject(id: string): ItemObject | null {
    return this.itemObjects.get(id) ?? null;
  }

  /**
   * Get all item objects
   */
  getItemObjects(): ItemObject[] {
    return Array.from(this.itemObjects.values());
  }

  /**
   * Update item object state
   */
  updateItemObjectState(id: string, state: string): void {
    const obj = this.itemObjects.get(id);
    if (!obj) return;

    obj.setState(state);
  }

  // ==================== Sliding Objects ====================

  /**
   * Add a sliding object for animation
   */
  addSlideObject(data: SlideObjectData): void {
    this.slideObjects.set(data.objectId, data);
  }

  /**
   * Remove a sliding object
   */
  removeSlideObject(objectId: string): void {
    this.slideObjects.delete(objectId);
  }

  /**
   * Update all sliding objects (called each frame)
   */
  updateSlideObjects(): void {
    const now = Date.now();
    const toRemove: string[] = [];

    for (const [id, data] of this.slideObjects) {
      // Check if it's a user or active object
      const user = this.userObjects.get(id);
      const activeObj = this.activeObjects.get(id);

      if (user) {
        // User sliding handled by user.update()
      } else if (activeObj) {
        const done = activeObj.animateSlide(now);
        if (done) {
          toRemove.push(id);
        }
      }
    }

    for (const id of toRemove) {
      this.slideObjects.delete(id);
    }
  }

  // ==================== Room Rights ====================

  /**
   * Set owner status
   */
  setOwner(isOwner: boolean): void {
    this.isOwner = isOwner;
    if (isOwner) {
      this.hasRights = true;
    }
    messageBus.emit('room:ownerStatusChanged', { isOwner });
  }

  /**
   * Set controller level (0=none, 1=guest, 2=rights, 3=owner)
   */
  setControllerLevel(level: number): void {
    this.controllerLevel = level;
    this.hasRights = level >= 2;
    messageBus.emit('room:controllerLevelChanged', { level });
  }

  /**
   * Check if user has rights in this room
   */
  hasRoomRights(): boolean {
    return this.hasRights;
  }

  /**
   * Check if user is owner of this room
   */
  isRoomOwner(): boolean {
    return this.isOwner;
  }

  // ==================== Trading ====================

  /**
   * Open trade with another user
   */
  openTrade(partnerId: string): void {
    this.tradeState = {
      active: true,
      partnerId,
      ownItems: [],
      partnerItems: [],
      ownAccepted: false,
      partnerAccepted: false,
    };
    messageBus.emit('trade:opened', { partnerId });
  }

  /**
   * Close trade
   */
  closeTrade(): void {
    this.tradeState = {
      active: false,
      ownItems: [],
      partnerItems: [],
      ownAccepted: false,
      partnerAccepted: false,
    };
    messageBus.emit('trade:closed', {});
  }

  /**
   * Update trade items
   */
  updateTradeItems(ownItems: string[], partnerItems: string[]): void {
    this.tradeState.ownItems = ownItems;
    this.tradeState.partnerItems = partnerItems;
    messageBus.emit('trade:itemsUpdated', { ownItems, partnerItems });
  }

  /**
   * Set trade acceptance status
   */
  setTradeAcceptance(ownAccepted: boolean, partnerAccepted: boolean): void {
    this.tradeState.ownAccepted = ownAccepted;
    this.tradeState.partnerAccepted = partnerAccepted;
    messageBus.emit('trade:acceptanceUpdated', { ownAccepted, partnerAccepted });
  }

  /**
   * Get trade state
   */
  getTradeState(): TradeState {
    return { ...this.tradeState };
  }

  // ==================== Chat ====================

  /**
   * Handle incoming chat message
   */
  handleChat(message: ChatMessage): void {
    const user = this.userObjects.get(message.userId);
    if (user) {
      user.actionTalk();

      // Auto-stop talking after message duration
      const duration = Math.min(message.message.length * 100, 5000);
      setTimeout(() => {
        if (this.userObjects.has(message.userId)) {
          user.stopActionTalk();
        }
      }, duration);
    }

    messageBus.emit('room:chat', message);
  }

  // ==================== Height Map ====================

  /**
   * Validate and update the height map with object positions
   */
  validateHeightMap(): void {
    if (!this.geometry) return;

    const placeMap = this.geometry.getObjectPlaceMap();

    // Mark tiles occupied by active objects
    for (const obj of this.activeObjects.values()) {
      const loc = obj.getLocation();
      const x = Math.floor(loc.x);
      const y = Math.floor(loc.y);

      if (y >= 0 && y < placeMap.length && x >= 0 && x < placeMap[y].length) {
        // Object occupies this tile
        // Note: Full implementation would check object dimensions
      }
    }
  }

  // ==================== Update Loop ====================

  /**
   * Update all room objects (called each frame)
   */
  update(): void {
    // Update sliding objects
    this.updateSlideObjects();

    // Update user animations
    for (const user of this.userObjects.values()) {
      user.update();
    }
  }

  /**
   * Render all room objects
   */
  render(): void {
    for (const user of this.userObjects.values()) {
      user.render();
    }
  }

  /**
   * Release sprites from active objects when running low
   */
  releaseSpritesFromActiveObjects(): void {
    // In emergency situations, release sprites from objects not on screen
    console.warn('RoomComponent: Releasing sprites from off-screen objects');
  }
}

// Singleton instance
let roomComponentInstance: RoomComponent | null = null;

export function getRoomComponent(): RoomComponent {
  if (!roomComponentInstance) {
    roomComponentInstance = new RoomComponent();
  }
  return roomComponentInstance;
}

export function resetRoomComponent(): void {
  if (roomComponentInstance) {
    roomComponentInstance.leaveRoom();
  }
  roomComponentInstance = null;
}
