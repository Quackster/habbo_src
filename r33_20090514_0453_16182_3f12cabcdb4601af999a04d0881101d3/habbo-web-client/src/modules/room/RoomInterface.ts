/**
 * Room Interface Class
 *
 * Ported from: hh_room/Cast External ParentScript 3 - Room Interface Class.ls
 *
 * Manages the visual interface for a room including:
 * - Room visualizer/renderer
 * - Room geometry
 * - Tile highlighter
 * - Object selection
 * - Event handling for room objects
 */

import { messageBus } from '../../core/MessageBus';
import { objectManager } from '../../core/ObjectManager';
import { getVariable } from '../../core/VariableContainer';
import {
  getVisualizerManager,
  createVisualizer,
  removeVisualizer,
  VisualizerInstance,
} from '../../ui/VisualizerManager';
import { RoomGeometry } from './RoomGeometry';
import { getRoomComponent, RoomComponent } from './RoomComponent';
import {
  RoomType,
  Direction,
  RoomLocation,
  RoomEventData,
  RoomObjectType,
  GeometryConfig,
} from './types';

// Hiliter class for tile highlighting
export class RoomHiliter {
  private geometry: RoomGeometry | null = null;
  private spriteId: string = '';
  private lastLoc: { x: number; y: number } = { x: 0, y: 0 };
  private lastCoord: RoomLocation | null = null;
  private visible: boolean = true;

  constructor() {}

  define(geometry: RoomGeometry, spriteId: string): boolean {
    this.geometry = geometry;
    this.spriteId = spriteId;
    return true;
  }

  update(mouseX: number, mouseY: number): RoomLocation | null {
    if (!this.geometry) return null;

    if (mouseX === this.lastLoc.x && mouseY === this.lastLoc.y) {
      return this.lastCoord;
    }

    this.lastLoc = { x: mouseX, y: mouseY };
    const coord = this.geometry.getFloorCoordinate(mouseX, mouseY);
    this.lastCoord = coord;

    if (!coord) {
      // Hide hiliter when not over valid tile
      this.setPosition(-10000, -10000);
    } else {
      const screenCoord = this.geometry.getScreenCoordinate(coord.x, coord.y, coord.h);
      this.setPosition(screenCoord.x, screenCoord.y);
    }

    return coord;
  }

  private setPosition(x: number, y: number): void {
    // Update sprite position through sprite manager
    messageBus.emit('hiliter:moved', { x, y, spriteId: this.spriteId });
  }

  show(): void {
    this.visible = true;
  }

  hide(): void {
    this.visible = false;
    this.setPosition(-10000, -10000);
  }

  deconstruct(): void {
    this.geometry = null;
  }
}

// Object mover class for drag-and-drop furniture placement
export class ObjectMover {
  private geometry: RoomGeometry | null = null;
  private component: RoomComponent | null = null;
  private activeObjectId: string | null = null;
  private itemObjectId: string | null = null;
  private isMoving: boolean = false;
  private startLoc: RoomLocation | null = null;

  define(geometry: RoomGeometry, component: RoomComponent): void {
    this.geometry = geometry;
    this.component = component;
  }

  startMoveActiveObject(objectId: string): boolean {
    if (!this.component) return false;

    const obj = this.component.getActiveObject(objectId);
    if (!obj) return false;

    this.activeObjectId = objectId;
    this.startLoc = obj.getLocation();
    this.isMoving = true;

    obj.ghostObject();

    messageBus.emit('objectMover:started', { objectId, type: 'active' });
    return true;
  }

  startMoveItemObject(objectId: string): boolean {
    if (!this.component) return false;

    const obj = this.component.getItemObject(objectId);
    if (!obj) return false;

    this.itemObjectId = objectId;
    this.isMoving = true;

    messageBus.emit('objectMover:started', { objectId, type: 'item' });
    return true;
  }

  updatePosition(mouseX: number, mouseY: number): void {
    if (!this.isMoving || !this.geometry || !this.component) return;

    if (this.activeObjectId) {
      const coord = this.geometry.getFloorCoordinate(mouseX, mouseY);
      if (coord) {
        const obj = this.component.getActiveObject(this.activeObjectId);
        if (obj) {
          obj.moveTo(coord.x, coord.y, coord.h);
        }
      }
    }
  }

  confirmMove(): { objectId: string; type: string; location: RoomLocation } | null {
    if (!this.isMoving || !this.component) return null;

    let result: { objectId: string; type: string; location: RoomLocation } | null = null;

    if (this.activeObjectId) {
      const obj = this.component.getActiveObject(this.activeObjectId);
      if (obj) {
        obj.removeGhostEffect();
        result = {
          objectId: this.activeObjectId,
          type: 'active',
          location: obj.getLocation(),
        };
      }
    } else if (this.itemObjectId) {
      const obj = this.component.getItemObject(this.itemObjectId);
      if (obj) {
        result = {
          objectId: this.itemObjectId,
          type: 'item',
          location: obj.getLocation(),
        };
      }
    }

    this.cancelMove();
    return result;
  }

  cancelMove(): void {
    if (this.activeObjectId && this.component && this.startLoc) {
      const obj = this.component.getActiveObject(this.activeObjectId);
      if (obj) {
        obj.moveTo(this.startLoc.x, this.startLoc.y, this.startLoc.h);
        obj.removeGhostEffect();
      }
    }

    this.activeObjectId = null;
    this.itemObjectId = null;
    this.startLoc = null;
    this.isMoving = false;

    messageBus.emit('objectMover:cancelled', {});
  }

  isObjectMoving(): boolean {
    return this.isMoving;
  }

  deconstruct(): void {
    this.cancelMove();
    this.geometry = null;
    this.component = null;
  }
}

/**
 * Main Room Interface Class
 */
export class RoomInterface {
  private id: string = 'room_interface';
  private roomId: string = '';

  // Sub-components
  private geometry: RoomGeometry;
  private hiliter: RoomHiliter;
  private objectMover: ObjectMover;
  private component: RoomComponent;

  // Room visualizer
  private visualizerId: string = '';
  private visualizerLayout: string = '';

  // Container/GUI IDs
  private containerId: string | null = null;
  private guiId: string | null = null;

  // Selection state
  private selectedObjectId: string | null = null;
  private selectedObjectType: RoomObjectType | null = null;

  // Door position (entry point)
  private doorPosition: RoomLocation = { x: 0, y: 0, h: 0 };

  // Event handlers
  private eventHandlers: Map<string, Function[]> = new Map();

  constructor() {
    this.geometry = new RoomGeometry();
    this.hiliter = new RoomHiliter();
    this.objectMover = new ObjectMover();
    this.component = getRoomComponent();

    // Set up event listeners
    this.setupEventListeners();
  }

  getId(): string {
    return this.id;
  }

  getGeometry(): RoomGeometry {
    return this.geometry;
  }

  getHiliter(): RoomHiliter {
    return this.hiliter;
  }

  getObjectMover(): ObjectMover {
    return this.objectMover;
  }

  getRoomVisualizer(): VisualizerInstance | null {
    return getVisualizerManager().get(this.visualizerId);
  }

  /**
   * Initialize the room interface
   */
  async define(
    layout: string,
    geometryConfig: GeometryConfig,
    doorX: number = 0,
    doorY: number = 0
  ): Promise<boolean> {
    this.visualizerLayout = layout;

    // Configure geometry
    this.geometry.define(geometryConfig);

    // Set door position
    this.doorPosition = { x: doorX, y: doorY, h: 0 };

    // Pass geometry to component
    this.component.setGeometry(this.geometry);

    // Set up hiliter
    this.hiliter.define(this.geometry, 'room_hiliter');

    // Set up object mover
    this.objectMover.define(this.geometry, this.component);

    // Create room visualizer
    this.visualizerId = `room_vis_${Date.now()}`;
    const created = await createVisualizer(this.visualizerId, layout, 0, 0);

    if (!created) {
      console.error('RoomInterface: Failed to create room visualizer');
      return false;
    }

    console.log(`RoomInterface: Room interface initialized with layout ${layout}`);

    return true;
  }

  /**
   * Load height map data
   */
  loadHeightMap(data: string, useFloorMap: boolean = false): boolean {
    return this.geometry.loadHeightMap(data, useFloorMap);
  }

  /**
   * Clean up the room interface
   */
  deconstruct(): void {
    this.hiliter.deconstruct();
    this.objectMover.deconstruct();

    if (this.visualizerId) {
      removeVisualizer(this.visualizerId);
      this.visualizerId = '';
    }

    this.selectedObjectId = null;
    this.selectedObjectType = null;

    messageBus.emit('room:interfaceDestroyed', { roomId: this.roomId });
  }

  /**
   * Set up event listeners
   */
  private setupEventListeners(): void {
    // Mouse move for hiliter
    messageBus.on('input:mouseMove', (data: { x: number; y: number }) => {
      this.hiliter.update(data.x, data.y);

      if (this.objectMover.isObjectMoving()) {
        this.objectMover.updatePosition(data.x, data.y);
      }
    });

    // Mouse click for object selection
    messageBus.on('input:mouseDown', (data: { x: number; y: number; button: number }) => {
      if (data.button === 0) { // Left click
        this.handleClick(data.x, data.y);
      }
    });

    // Mouse up for object placement
    messageBus.on('input:mouseUp', (data: { x: number; y: number; button: number }) => {
      if (this.objectMover.isObjectMoving()) {
        const result = this.objectMover.confirmMove();
        if (result) {
          messageBus.emit('room:objectMoved', result);
        }
      }
    });
  }

  /**
   * Handle click on room
   */
  private handleClick(x: number, y: number): void {
    // Check for object clicks first
    // This would typically use sprite hit testing

    // If no object clicked, check floor click
    const coord = this.geometry.getFloorCoordinate(x, y);
    if (coord && this.geometry.isValidCoordinate(coord.x, coord.y)) {
      messageBus.emit('room:floorClicked', { x: coord.x, y: coord.y, h: coord.h });
    }
  }

  // ==================== Event Procedures ====================

  /**
   * Handle room floor click event
   */
  eventProcRoom(event: string, x: number, y: number): void {
    const coord = this.geometry.getFloorCoordinate(x, y);
    if (!coord) return;

    if (!this.geometry.isValidCoordinate(coord.x, coord.y)) {
      return;
    }

    if (event === 'mouseDown') {
      messageBus.emit('room:tileClicked', {
        x: coord.x,
        y: coord.y,
        h: coord.h,
      });
    }
  }

  /**
   * Handle user object click event
   */
  eventProcUserObj(event: string, objectId: string): void {
    const user = this.component.getUserObject(objectId);
    if (!user) return;

    if (event === 'mouseDown') {
      this.selectObject(objectId, 'user');

      messageBus.emit('room:userClicked', {
        userId: objectId,
        userName: user.getName(),
        info: user.getInfo(),
      });
    }
  }

  /**
   * Handle user object rollover
   */
  eventProcUserRollOver(event: string, objectId: string): void {
    if (event === 'mouseEnter') {
      messageBus.emit('room:userRollOver', { userId: objectId, enter: true });
    } else if (event === 'mouseLeave') {
      messageBus.emit('room:userRollOver', { userId: objectId, enter: false });
    }
  }

  /**
   * Handle active object click event
   */
  eventProcActiveObj(event: string, objectId: string): void {
    const obj = this.component.getActiveObject(objectId);
    if (!obj) return;

    if (event === 'mouseDown') {
      this.selectObject(objectId, 'active');

      messageBus.emit('room:activeObjectClicked', {
        objectId,
        info: obj.getInfo(),
      });
    }
  }

  /**
   * Handle active object rollover
   */
  eventProcActiveRollOver(event: string, objectId: string): void {
    if (event === 'mouseEnter') {
      messageBus.emit('room:activeObjectRollOver', { objectId, enter: true });
    } else if (event === 'mouseLeave') {
      messageBus.emit('room:activeObjectRollOver', { objectId, enter: false });
    }
  }

  /**
   * Handle item object click event
   */
  eventProcItemObj(event: string, objectId: string): void {
    const obj = this.component.getItemObject(objectId);
    if (!obj) return;

    if (event === 'mouseDown') {
      this.selectObject(objectId, 'item');

      messageBus.emit('room:itemObjectClicked', {
        objectId,
        info: obj.getInfo(),
      });
    }
  }

  /**
   * Handle item object rollover
   */
  eventProcItemRollOver(event: string, objectId: string): void {
    if (event === 'mouseEnter') {
      messageBus.emit('room:itemObjectRollOver', { objectId, enter: true });
    } else if (event === 'mouseLeave') {
      messageBus.emit('room:itemObjectRollOver', { objectId, enter: false });
    }
  }

  // ==================== Selection ====================

  /**
   * Select an object
   */
  selectObject(objectId: string, type: RoomObjectType): void {
    this.selectedObjectId = objectId;
    this.selectedObjectType = type;

    messageBus.emit('room:objectSelected', { objectId, type });
  }

  /**
   * Deselect current object
   */
  deselectObject(): void {
    if (this.selectedObjectId) {
      messageBus.emit('room:objectDeselected', {
        objectId: this.selectedObjectId,
        type: this.selectedObjectType,
      });
    }

    this.selectedObjectId = null;
    this.selectedObjectType = null;
  }

  /**
   * Get selected object info
   */
  getSelectedObject(): { id: string; type: RoomObjectType } | null {
    if (!this.selectedObjectId || !this.selectedObjectType) {
      return null;
    }
    return { id: this.selectedObjectId, type: this.selectedObjectType };
  }

  // ==================== Container/GUI ====================

  /**
   * Set container ID
   */
  setContainer(containerId: string): void {
    this.containerId = containerId;
  }

  /**
   * Get container ID
   */
  getContainer(): string | null {
    return this.containerId;
  }

  /**
   * Set GUI ID
   */
  setGui(guiId: string): void {
    this.guiId = guiId;
  }

  /**
   * Get GUI ID
   */
  getGui(): string | null {
    return this.guiId;
  }

  // ==================== Door Position ====================

  /**
   * Get door position
   */
  getDoorPosition(): RoomLocation {
    return { ...this.doorPosition };
  }

  /**
   * Set door position
   */
  setDoorPosition(x: number, y: number, h: number = 0): void {
    this.doorPosition = { x, y, h };
  }

  // ==================== Coordinate Helpers ====================

  /**
   * Convert screen to room coordinates
   */
  screenToRoom(screenX: number, screenY: number): RoomLocation | null {
    return this.geometry.getWorldCoordinate(screenX, screenY);
  }

  /**
   * Convert room to screen coordinates
   */
  roomToScreen(x: number, y: number, h: number = 0): { x: number; y: number; z: number } {
    return this.geometry.getScreenCoordinate(x, y, h);
  }

  /**
   * Check if a tile is walkable
   */
  isTileWalkable(x: number, y: number): boolean {
    return this.geometry.isValidCoordinate(x, y) && !this.geometry.isBlocked(x, y);
  }

  // ==================== Update/Render ====================

  /**
   * Update the room interface (called each frame)
   */
  update(): void {
    // Update component
    this.component.update();
  }

  /**
   * Render the room (called each frame)
   */
  render(ctx: CanvasRenderingContext2D): void {
    // Render visualizer
    const visualizer = this.getRoomVisualizer();
    if (visualizer) {
      visualizer.render();
      ctx.drawImage(visualizer.canvas, visualizer.locX, visualizer.locY);
    }

    // Render component objects
    this.component.render();
  }
}

// Singleton instance
let roomInterfaceInstance: RoomInterface | null = null;

export function getRoomInterface(): RoomInterface {
  if (!roomInterfaceInstance) {
    roomInterfaceInstance = new RoomInterface();
  }
  return roomInterfaceInstance;
}

export function resetRoomInterface(): void {
  if (roomInterfaceInstance) {
    roomInterfaceInstance.deconstruct();
  }
  roomInterfaceInstance = null;
}
