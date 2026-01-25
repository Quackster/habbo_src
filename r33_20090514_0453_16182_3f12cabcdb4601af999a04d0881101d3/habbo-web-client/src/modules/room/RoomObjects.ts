/**
 * Room Object Classes
 *
 * Ported from:
 * - hh_furni_classes/Cast External ParentScript 3 - Active Object Class.ls
 * - hh_furni_classes/Cast External ParentScript 4 - Passive Object Class.ls
 * - hh_furni_classes/Cast External ParentScript 5 - Item Object Class.ls
 * - hh_human/Cast External ParentScript 2 - Human Class EX.ls
 *
 * Base classes for all objects that can exist in a room.
 */

import { messageBus } from '../../core/MessageBus';
import { spriteManager, SpriteInfo } from '../../ui/SpriteManager';
import { RoomGeometry } from './RoomGeometry';
import {
  Direction,
  RoomLocation,
  ScreenCoordinate,
  ObjectInfo,
  ActiveObjectDef,
  PassiveObjectDef,
  ItemObjectDef,
  UserObjectDef,
  ActionDef,
  SlideObjectData,
} from './types';

/**
 * Base class for all room objects
 */
export abstract class BaseRoomObject {
  protected id: string = '';
  protected objectClass: string = '';
  protected locX: number = 0;
  protected locY: number = 0;
  protected locH: number = 0;
  protected direction: Direction[] = [0];
  protected sprites: SpriteInfo[] = [];
  protected visible: boolean = true;
  protected geometry: RoomGeometry | null = null;

  constructor() {}

  abstract define(data: unknown): boolean;
  abstract getInfo(): ObjectInfo;

  getId(): string {
    return this.id;
  }

  setId(id: string): void {
    this.id = id;
  }

  getClass(): string {
    return this.objectClass;
  }

  getLocation(): RoomLocation {
    return { x: this.locX, y: this.locY, h: this.locH };
  }

  getSprites(): SpriteInfo[] {
    return this.sprites;
  }

  setGeometry(geometry: RoomGeometry): void {
    this.geometry = geometry;
  }

  show(): void {
    this.visible = true;
    for (const sprite of this.sprites) {
      sprite.visible = true;
    }
  }

  hide(): void {
    this.visible = false;
    for (const sprite of this.sprites) {
      sprite.visible = false;
    }
  }

  isVisible(): boolean {
    return this.visible;
  }

  deconstruct(): void {
    for (const sprite of this.sprites) {
      spriteManager.release(sprite.id);
    }
    this.sprites = [];
  }
}

/**
 * Active Object - Floor furniture
 */
export class ActiveObject extends BaseRoomObject {
  private custom: string = '';
  private name: string = '';
  private dimensions: [number, number] = [1, 1];
  private altitude: number = 0;
  private partColors: string[] = [];
  private animFrame: number = 0;
  private xFactor: number = 64;
  private correctLocZ: boolean = false;
  private smallMember: string = '';
  private expireTimestamp: number = -1;

  // Sliding state
  private startLoc: RoomLocation | null = null;
  private destLoc: RoomLocation | null = null;
  private slideStartTime: number = 0;
  private slideEndTime: number = 0;
  private slideTimePerTile: number = 500;

  define(data: ActiveObjectDef): boolean {
    this.id = data.id;
    this.objectClass = data.class;
    this.direction = data.direction;
    this.dimensions = data.dimensions ?? [1, 1];
    this.altitude = data.altitude;
    this.locX = data.x;
    this.locY = data.y;
    this.locH = this.altitude;
    this.expireTimestamp = data.expire ?? -1;

    this.solveColors(data.colors);

    if (!this.solveMembers()) {
      return false;
    }

    if (!this.prepare(data.props)) {
      return false;
    }

    this.updateLocation();
    return true;
  }

  getInfo(): ObjectInfo {
    return {
      class: this.objectClass,
      name: this.name,
      custom: this.custom,
      smallMember: this.smallMember,
      expire: this.expireTimestamp,
    };
  }

  getCustom(): string {
    return this.custom;
  }

  select(): boolean {
    return false;
  }

  moveTo(x: number, y: number, h: number): void {
    this.locX = x;
    this.locY = y;
    this.locH = h + this.altitude;
    this.updateLocation();
  }

  moveBy(dx: number, dy: number, dh: number): void {
    this.locX += dx;
    this.locY += dy;
    this.locH += dh;
    this.updateLocation();
  }

  rotate(change: number = 2): void {
    const newDir = ((this.direction[0] + change) % 8) as Direction;
    this.direction[0] = newDir < 0 ? (8 + newDir) as Direction : newDir;
    this.solveMembers();
    this.updateLocation();
  }

  setSlideTo(
    fromLoc: RoomLocation,
    toLoc: RoomLocation,
    timeNow?: number,
    hasCharacter?: boolean
  ): void {
    const now = timeNow ?? Date.now();
    this.slideStartTime = now;
    this.locX = fromLoc.x;
    this.locY = fromLoc.y;
    this.locH = fromLoc.h;

    const distances = [
      Math.abs(fromLoc.x - toLoc.x),
      Math.abs(fromLoc.y - toLoc.y),
      Math.abs(fromLoc.h - toLoc.h),
    ];
    const moveTime = Math.max(...distances) * this.slideTimePerTile;

    this.slideEndTime = this.slideStartTime + moveTime;
    this.startLoc = { ...fromLoc };
    this.destLoc = { ...toLoc };
    this.updateLocation();
  }

  animateSlide(timeNow?: number): boolean {
    if (!this.startLoc || !this.destLoc) return true;

    const now = timeNow ?? Date.now();
    if (this.slideEndTime < now) {
      this.locX = this.destLoc.x;
      this.locY = this.destLoc.y;
      this.locH = this.destLoc.h;
      this.startLoc = null;
      this.destLoc = null;
      this.updateLocation();
      return true;
    }

    const timeUsed = now - this.slideStartTime;
    const percentSlid = timeUsed / (this.slideEndTime - this.slideStartTime);

    this.locX = (this.destLoc.x - this.startLoc.x) * percentSlid + this.startLoc.x;
    this.locY = (this.destLoc.y - this.startLoc.y) * percentSlid + this.startLoc.y;
    this.locH = (this.destLoc.h - this.startLoc.h) * percentSlid + this.startLoc.h;
    this.updateLocation();
    return false;
  }

  ghostObject(): void {
    for (const sprite of this.sprites) {
      sprite.alpha = 0.35;
    }
  }

  removeGhostEffect(): void {
    for (const sprite of this.sprites) {
      sprite.visible = true;
      sprite.alpha = 1.0;
    }
  }

  getScreenLocation(): { x: number; y: number } {
    if (this.sprites.length < 1) {
      return { x: 0, y: 0 };
    }
    const sprite = this.sprites[0];
    return {
      x: sprite.locX + sprite.width / 2,
      y: sprite.locY + sprite.height / 2,
    };
  }

  protected prepare(props?: string): boolean {
    return true;
  }

  protected solveColors(partColors?: string): void {
    if (!partColors) {
      partColors = '0,0,0';
    }
    this.partColors = partColors.split(',');
    while (this.partColors.length < 4) {
      this.partColors.push('#ffffff');
    }
  }

  protected solveMembers(): boolean {
    // Release existing sprites
    for (const sprite of this.sprites) {
      spriteManager.release(sprite.id);
    }
    this.sprites = [];

    // Create sprite for the object
    const sprite = spriteManager.reserve(this.id);
    if (!sprite) {
      console.warn(`ActiveObject: Could not reserve sprite for ${this.objectClass}`);
      return false;
    }

    this.sprites.push(sprite);
    this.smallMember = `${this.objectClass}_small`;

    return true;
  }

  protected updateLocation(): void {
    if (!this.geometry) return;

    const screenLoc = this.geometry.getScreenCoordinate(this.locX, this.locY, this.locH);

    for (let i = 0; i < this.sprites.length; i++) {
      const sprite = this.sprites[i];
      sprite.locX = screenLoc.x;
      sprite.locY = screenLoc.y;

      if (this.correctLocZ) {
        sprite.locZ = screenLoc.z + (this.locH * 1000) - 1;
      } else {
        sprite.locZ = screenLoc.z - 1;
      }
    }
  }
}

/**
 * Passive Object - Static room decorations (walls, etc.)
 */
export class PassiveObject extends BaseRoomObject {
  private dimensions: [number, number] = [1, 1];

  define(data: PassiveObjectDef): boolean {
    this.id = data.id;
    this.objectClass = data.class;
    this.direction = data.direction;
    this.dimensions = data.dimensions ?? [1, 1];
    this.locX = data.x;
    this.locY = data.y;
    this.locH = data.h ?? 0;

    if (!this.solveMembers()) {
      return false;
    }

    this.updateLocation();
    return true;
  }

  getInfo(): ObjectInfo {
    return {
      class: this.objectClass,
    };
  }

  protected solveMembers(): boolean {
    const sprite = spriteManager.reserve(this.id);
    if (!sprite) {
      return false;
    }
    this.sprites.push(sprite);
    return true;
  }

  protected updateLocation(): void {
    if (!this.geometry) return;

    const screenLoc = this.geometry.getScreenCoordinate(this.locX, this.locY, this.locH);

    for (const sprite of this.sprites) {
      sprite.locX = screenLoc.x;
      sprite.locY = screenLoc.y;
      sprite.locZ = screenLoc.z;
    }
  }
}

/**
 * Item Object - Wall items (posters, post-its, photos)
 */
export class ItemObject extends BaseRoomObject {
  private name: string = '';
  private custom: string = '';
  private type: string = '';
  private wallX: number = 0;
  private wallY: number = 0;
  private localX: number = 0;
  private localY: number = 0;
  private formatVer: 'old' | 'new' = 'new';
  private itemDirection: 'leftwall' | 'rightwall' = 'leftwall';
  private xFactor: number = 64;
  private expireTimestamp: number = -1;

  define(data: ItemObjectDef): boolean {
    this.id = data.id;
    this.objectClass = data.class;
    this.locX = data.x;
    this.locY = data.y;
    this.locH = data.h ?? 0;
    this.localX = data.localX;
    this.localY = data.localY;
    this.wallX = data.wallX;
    this.wallY = data.wallY;
    this.formatVer = data.formatVersion;
    this.itemDirection = data.direction;
    this.type = data.type ?? '';
    this.expireTimestamp = data.expire ?? -1;

    // Set name based on class
    switch (this.objectClass) {
      case 'poster':
        this.name = `poster_${this.type}_name`;
        this.custom = `poster_${this.type}_desc`;
        break;
      case 'post.it':
      case 'post.it.vd':
        this.name = 'Post-it Note';
        break;
      case 'photo':
        this.name = 'Photo';
        break;
    }

    if (!this.solveMembers()) {
      return false;
    }

    this.updateLocation();
    return true;
  }

  getInfo(): ObjectInfo {
    return {
      name: this.name,
      class: this.objectClass,
      custom: this.custom,
      smallMember: `${this.objectClass}_small`,
      expire: this.expireTimestamp,
    };
  }

  getWallLocation(): [number, number] {
    return [this.wallX, this.wallY];
  }

  getCustom(): string {
    return this.custom;
  }

  select(): boolean {
    return true;
  }

  setDirection(direction: 'leftwall' | 'rightwall'): void {
    this.itemDirection = direction;
  }

  setState(value: string): void {
    this.updateColor(value);
  }

  protected solveMembers(): boolean {
    const sprite = spriteManager.reserve(this.id);
    if (!sprite) {
      return false;
    }
    this.sprites.push(sprite);
    return true;
  }

  protected updateColor(hexStr: string): void {
    if (this.sprites.length < 1) return;

    const sprite = this.sprites[0];
    if (this.objectClass === 'post.it') {
      sprite.bgColor = hexStr || '#FFFF33';
    } else if (this.objectClass === 'post.it.vd') {
      sprite.bgColor = '#FFFFFF';
    }
  }

  protected updateLocation(): void {
    if (!this.geometry) return;

    if (this.formatVer === 'old') {
      const screenLoc = this.geometry.getScreenCoordinate(
        this.locX,
        this.locY,
        this.locH * 18.0 / 32.0
      );
      for (const sprite of this.sprites) {
        sprite.locX = screenLoc.x;
        sprite.locY = screenLoc.y;
        sprite.locZ = screenLoc.z + 20000;
      }
    } else {
      // New format uses wall-relative positioning
      // This would be calculated based on wall positions
      for (const sprite of this.sprites) {
        sprite.locX = this.localX;
        sprite.locY = this.localY;
      }
    }
  }
}

/**
 * User Object - Avatars/humans in the room
 */
export class UserObject extends BaseRoomObject {
  private name: string = '';
  private custom: string = ''; // motto
  private sex: 'M' | 'F' = 'M';
  private figure: string = '';
  private webId?: number;
  private badges: Record<string, string> = {};
  private groupId?: string;
  private groupStatus?: string;
  private xp: number = 0;

  // State
  private headDirection: Direction = 0;
  private screenLoc: ScreenCoordinate = { x: 0, y: 0, z: 0 };
  private restingHeight: number = 0;

  // Animation state
  private mainAction: string = 'std';
  private moving: boolean = false;
  private talking: boolean = false;
  private carrying: string | number = 0;
  private sleeping: boolean = false;
  private dancing: number = 0;
  private waving: boolean = false;
  private trading: boolean = false;
  private animating: boolean = false;
  private fx: number = 0;

  // Movement
  private moveStart: number = 0;
  private moveTime: number = 500;
  private startScreenLoc: ScreenCoordinate = { x: 0, y: 0, z: 0 };
  private destScreenLoc: ScreenCoordinate = { x: 0, y: 0, z: 0 };

  // Rendering
  private canvas: HTMLCanvasElement | null = null;
  private ctx: CanvasRenderingContext2D | null = null;
  private canvasSize = { width: 64, height: 102 };
  private changes: boolean = true;
  private correctLocZ: boolean = false;

  constructor() {
    super();
    this.canvas = document.createElement('canvas');
    this.canvas.width = this.canvasSize.width;
    this.canvas.height = this.canvasSize.height;
    this.ctx = this.canvas.getContext('2d');
  }

  define(data: UserObjectDef): boolean {
    this.id = data.id;
    this.webId = data.webId;
    this.name = data.name;
    this.custom = data.custom;
    this.sex = data.sex;
    this.figure = data.figure;
    this.direction = data.direction;
    this.headDirection = data.direction[0];
    this.locX = data.x;
    this.locY = data.y;
    this.locH = data.h;
    this.badges = data.badge ?? {};
    this.groupId = data.groupId;
    this.groupStatus = data.groupStatus;
    this.xp = data.xp ?? 0;

    // Reserve sprites
    const mainSprite = spriteManager.reserve(this.id);
    if (!mainSprite) {
      console.warn(`UserObject: Could not reserve sprite for ${this.name}`);
      return false;
    }
    this.sprites.push(mainSprite);

    // Shadow sprite
    const shadowSprite = spriteManager.reserve(`${this.id}_shadow`);
    if (shadowSprite) {
      this.sprites.push(shadowSprite);
    }

    this.updateScreenLocation();
    return true;
  }

  getInfo(): ObjectInfo {
    let customText = this.custom;
    if (this.trading) {
      customText = (this.custom ? this.custom + '\n\n' : '') + 'Trading';
    } else if (this.carrying) {
      customText = (this.custom ? this.custom + '\n\n' : '') + `Carrying: ${this.carrying}`;
    }

    return {
      name: this.name,
      class: 'user',
      custom: customText,
      ctrl: 'furniture',
      badges: this.badges,
      groupId: this.groupId,
      xp: this.xp,
      fx: this.fx,
    };
  }

  getName(): string {
    return this.name;
  }

  getCustom(): string {
    return this.custom;
  }

  getWebId(): number | undefined {
    return this.webId;
  }

  getDirection(): Direction {
    return this.direction[0];
  }

  getHeadDirection(): Direction {
    return this.headDirection;
  }

  select(): boolean {
    return true;
  }

  getScreenLocation(): ScreenCoordinate {
    return this.screenLoc;
  }

  getTileCenter(): { x: number; y: number } {
    const xFactor = this.geometry?.xFactor ?? 64;
    return {
      x: this.screenLoc.x + xFactor / 2,
      y: this.screenLoc.y,
    };
  }

  getProperty(prop: string): unknown {
    switch (prop) {
      case 'carrying': return this.carrying;
      case 'direction': return this.direction[0];
      case 'dancing': return this.dancing;
      case 'fx': return this.fx;
      case 'loc': return this.getLocation();
      case 'mainAction': return this.mainAction;
      case 'moving': return this.moving;
      case 'badges': return this.badges;
      case 'groupId': return this.groupId;
      case 'groupStatus': return this.groupStatus;
      case 'locZ': return this.sprites[0]?.locZ ?? 0;
      default: return null;
    }
  }

  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'groupId':
        this.groupId = value as string;
        return true;
      case 'groupStatus':
        this.groupStatus = value as string;
        return true;
      default:
        return false;
    }
  }

  /**
   * Reset values for a new position/state
   */
  resetValues(
    x: number,
    y: number,
    h: number,
    headDir: Direction,
    bodyDir: Direction,
    actions: string[] = []
  ): void {
    this.moving = false;
    this.trading = actions.includes('trd');
    this.animating = this.dancing > 0 || this.fx > 0;

    this.locX = x;
    this.locY = y;
    this.locH = h;
    this.restingHeight = 0;
    this.direction[0] = bodyDir;
    this.headDirection = headDir;

    this.resetAction();
    this.updateScreenLocation();
  }

  /**
   * Refresh the user's appearance and position
   */
  refresh(x: number, y: number, h: number): void {
    if (this.fx > 0 || this.dancing > 0 || this.mainAction === 'lay') {
      this.headDirection = this.direction[0];
    }
    this.changes = true;
  }

  /**
   * Update for animation frame
   */
  update(): void {
    if (this.moving) {
      const factor = Math.min(1.0, (Date.now() - this.moveStart) / this.moveTime);
      this.screenLoc = {
        x: (this.destScreenLoc.x - this.startScreenLoc.x) * factor + this.startScreenLoc.x,
        y: (this.destScreenLoc.y - this.startScreenLoc.y) * factor + this.startScreenLoc.y,
        z: (this.destScreenLoc.z - this.startScreenLoc.z) * factor + this.startScreenLoc.z,
      };
      this.changes = true;
    }
  }

  /**
   * Render the user to canvas
   */
  render(): void {
    if (!this.changes || !this.ctx || !this.canvas) return;
    this.changes = false;

    // Update sprite positions
    if (this.sprites[0]) {
      const sprite = this.sprites[0];
      sprite.locX = this.screenLoc.x;
      sprite.locY = this.screenLoc.y;

      let offsetZ = 2;
      if (this.correctLocZ) {
        offsetZ = ((this.locH + this.restingHeight) * 1000) + 2;
      }
      sprite.locZ = this.screenLoc.z + offsetZ;
    }

    // Shadow sprite
    if (this.sprites[1]) {
      const shadow = this.sprites[1];
      shadow.locX = this.screenLoc.x;
      shadow.locY = this.screenLoc.y;
      shadow.locZ = (this.sprites[0]?.locZ ?? 0) - 3;
      shadow.alpha = 0.16;
    }
  }

  // Action handlers
  actionStd(): void {
    this.mainAction = 'std';
    this.changes = true;
  }

  actionMv(destX: number, destY: number, destH: number): void {
    if (!this.geometry) return;

    this.mainAction = 'wlk';
    this.moving = true;

    this.moveStart = Date.now();
    this.startScreenLoc = { ...this.screenLoc };
    this.destScreenLoc = this.geometry.getScreenCoordinate(destX, destY, destH);
  }

  actionSit(height: number, isInQueue: boolean = false): void {
    if (this.dancing) {
      this.stopActionDance();
    }
    this.mainAction = 'sit';
    this.restingHeight = height - 1.0;
    this.updateScreenLocation();
    this.changes = true;
  }

  actionLay(height: number): void {
    if (this.dancing) {
      this.stopActionDance();
    }
    if (this.carrying) {
      this.stopActionCarry();
    }
    this.mainAction = 'lay';
    this.carrying = 0;
    this.restingHeight = Math.abs(height) - 1.0;
    this.updateScreenLocation();
    this.changes = true;
  }

  actionTalk(): void {
    this.talking = true;
    this.changes = true;
  }

  stopActionTalk(): void {
    this.talking = false;
    this.changes = true;
  }

  actionWave(): void {
    this.waving = true;
    this.changes = true;
    // Auto-stop after 2 seconds
    setTimeout(() => this.stopActionWave(), 2000);
  }

  stopActionWave(): void {
    this.waving = false;
    this.changes = true;
  }

  actionDance(style: number): void {
    if (this.mainAction === 'lay' || this.mainAction === 'sit') {
      return;
    }

    this.dancing = style;
    if (style !== 0) {
      this.stopActionCarry();
      this.stopActionWave();
      this.animating = true;
    } else {
      this.animating = false;
      this.resetAction();
    }
    this.changes = true;
  }

  stopActionDance(): void {
    this.actionDance(0);
  }

  actionCarry(item: string | number): void {
    this.carrying = item;
    this.changes = true;
  }

  stopActionCarry(): void {
    this.carrying = 0;
    this.changes = true;
  }

  actionFx(effectId: number): void {
    this.fx = effectId;
    this.animating = effectId > 0;
    this.changes = true;
    messageBus.emit('user:effectChanged', { userId: this.id, effectId });
  }

  actionTrade(): void {
    this.trading = true;
    this.changes = true;
  }

  stopActionTrade(): void {
    this.trading = false;
    this.changes = true;
  }

  private resetAction(): void {
    this.mainAction = 'std';
    this.changes = true;
  }

  private updateScreenLocation(): void {
    if (!this.geometry) return;

    this.screenLoc = this.geometry.getScreenCoordinate(
      this.locX,
      this.locY,
      this.locH + this.restingHeight
    );
  }

  deconstruct(): void {
    super.deconstruct();
    this.canvas = null;
    this.ctx = null;
  }
}
