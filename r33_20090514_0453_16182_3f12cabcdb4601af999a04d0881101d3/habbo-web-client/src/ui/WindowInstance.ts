/**
 * Window Instance Class
 *
 * Ported from: fuse_client/Cast External ParentScript 55 - Window Instance Class.ls
 *
 * Represents a single window in the UI system. Manages sprites, elements,
 * drag/scale behavior, and event routing.
 */

import { WindowProps, WindowLayout, ElementProps, Rect, WindowEvent, SpriteData } from './types';
import { BaseElement, UniqueElement, WrapperElement } from './elements';
import { layoutParser } from './LayoutParser';
import { spriteManager, reserveSprite, releaseSprite } from './SpriteManager';
import { resourceManager } from '../managers/ResourceManager';
import { objectManager } from '../core/ObjectManager';

interface GroupData {
  members: HTMLCanvasElement[];
  sprites: SpriteData[];
  items: BaseElement[];
  rect: Rect;
  border: [number, number, number, number];
}

interface ProcedureEntry {
  method: string;
  target: string;
}

export class WindowInstance {
  private id: string = '';
  private title: string = '';
  private clientId: string = '';
  private procedures: Map<WindowEvent, ProcedureEntry> = new Map();
  private lock: boolean = false;
  private locX: number = 0;
  private locY: number = 0;
  private locZ: number = 0;
  private width: number = 0;
  private height: number = 0;
  private modal: boolean = false;
  private active: boolean = false;
  private visible: boolean = true;
  private dragFlag: boolean = false;
  private dragOffset: [number, number] = [0, 0];
  private boundary: Rect = { x: 0, y: 0, width: 800, height: 600 };
  private scaleFlag: boolean = false;
  private scaleOffset: [number, number] = [0, 0];
  private elemList: Map<string, BaseElement> = new Map();
  private memberList: Map<string, HTMLCanvasElement> = new Map();
  private groupData: GroupData[] = [];
  private spriteList: Map<string, SpriteData> = new Map();
  private specialIdList: string[] = ['drag', 'close', 'scale'];
  private clientRect: [number, number, number, number] = [0, 0, 0, 0];
  private elemClsList: Record<string, unknown> = {};
  private windowManager: unknown = null;

  constructor() {
    this.initProcedures();
  }

  /**
   * Get the window ID
   */
  getId(): string {
    return this.id;
  }

  /**
   * Set the window ID
   */
  setId(id: string): void {
    this.id = id;
    this.title = id;
  }

  /**
   * Define the window with properties
   */
  define(props: WindowProps): boolean {
    this.locX = props.locX;
    this.locY = props.locY;
    this.locZ = props.locZ;
    this.boundary = props.boundary;
    this.elemClsList = props.elements ?? {};
    this.windowManager = props.manager;
    return true;
  }

  /**
   * Merge a layout into this window
   */
  async merge(layoutName: string): Promise<boolean> {
    this.setDeactive();

    if (!await this.buildVisual(layoutName)) {
      return false;
    }

    // Add special IDs for this group
    const groupNum = this.groupData.length;
    this.specialIdList.push(`drag${groupNum}`);
    this.specialIdList.push(`close${groupNum}`);

    // Activate through window manager
    if (this.windowManager && typeof (this.windowManager as Record<string, unknown>).Activate === 'function') {
      (this.windowManager as { Activate: (id: string) => void }).Activate(this.id);
    }

    return true;
  }

  /**
   * Unmerge the last merged layout
   */
  unmerge(): boolean {
    if (this.groupData.length === 0) {
      console.error('WindowInstance: Cannot unmerge window without content');
      return false;
    }

    const group = this.groupData.pop()!;

    // Deconstruct items
    for (const item of group.items) {
      item.deconstruct();
      // Remove from elemList
      for (const [key, value] of this.elemList.entries()) {
        if (value === item) {
          this.elemList.delete(key);
          break;
        }
      }
    }

    // Update client rect
    this.clientRect = [
      this.clientRect[0] - group.border[0],
      this.clientRect[1] - group.border[1],
      this.clientRect[2] - group.border[2],
      this.clientRect[3] - group.border[3],
    ];

    // Release sprites
    for (const sprite of group.sprites) {
      for (const [key, value] of this.spriteList.entries()) {
        if (value === sprite) {
          this.spriteList.delete(key);
          break;
        }
      }
      // Release from sprite manager
      // spriteManager.release...
    }

    // Remove members
    for (const member of group.members) {
      for (const [key, value] of this.memberList.entries()) {
        if (value === member) {
          this.memberList.delete(key);
          break;
        }
      }
    }

    // Remove special IDs
    const groupNum = this.groupData.length;
    this.specialIdList = this.specialIdList.filter(
      id => id !== `drag${groupNum}` && id !== `close${groupNum}`
    );

    return true;
  }

  /**
   * Build visual from layout
   */
  private async buildVisual(layoutName: string): Promise<boolean> {
    const layout = await layoutParser.parse(layoutName) as WindowLayout;
    if (!layout || !layout.elements) {
      console.error(`WindowInstance: Invalid layout ${layoutName}`);
      return false;
    }

    const groupNum = this.groupData.length;
    const newElemList = new Map<string, BaseElement>();
    const newMemberList = new Map<string, HTMLCanvasElement>();
    const newSpriteList = new Map<string, SpriteData>();
    const groupData: GroupData = {
      members: [],
      sprites: [],
      items: [],
      rect: layout.rect,
      border: layout.border,
    };

    // Process each element group
    for (const [elemId, elemItems] of layout.elements) {
      let id = elemId;
      if (this.elemList.has(id)) {
        id = `${id}${groupNum}`;
      }

      // Create canvas buffer for this element group
      const buffer = document.createElement('canvas');
      const bufferCtx = buffer.getContext('2d')!;

      // Reserve sprite
      const spriteNum = reserveSprite(this.id);
      if (spriteNum < 0) {
        console.error('WindowInstance: Out of sprites');
        // Cleanup already created sprites
        for (const sprite of newSpriteList.values()) {
          // Release sprite
        }
        return false;
      }

      const sprite = spriteManager.getSprite(spriteNum)!;
      spriteManager.setEventBroker(spriteNum, id);

      // Calculate element bounding rect
      let elemRect = { x: 2000, y: 2000, width: 0, height: 0 };
      let maxX = -2000, maxY = -2000;

      for (const item of elemItems) {
        if (item.flipH) item.locH -= item.width;
        if (item.flipV) item.locV -= item.height;

        if (item.locH < elemRect.x) elemRect.x = item.locH;
        if (item.locV < elemRect.y) elemRect.y = item.locV;
        if (item.locH + item.width > maxX) maxX = item.locH + item.width;
        if (item.locV + item.height > maxY) maxY = item.locV + item.height;
      }

      elemRect.width = maxX - elemRect.x;
      elemRect.height = maxY - elemRect.y;

      // Size the buffer
      buffer.width = elemRect.width || 1;
      buffer.height = elemRect.height || 1;

      newMemberList.set(id, buffer);
      newSpriteList.set(id, sprite);
      groupData.members.push(buffer);
      groupData.sprites.push(sprite);

      // Update sprite
      sprite.canvas = buffer;
      sprite.ctx = bufferCtx;
      sprite.width = buffer.width;
      sprite.height = buffer.height;
      sprite.blend = elemItems[0].blend ?? 100;
      sprite.ink = elemItems[0].ink ?? 0;

      // Create element
      let wrapper: BaseElement;

      if (elemItems.length === 1) {
        // Single element - use UniqueElement
        const item = elemItems[0];
        item.id = id;
        (item as unknown as Record<string, unknown>).mother = this.id;
        (item as unknown as Record<string, unknown>).buffer = buffer;
        (item as unknown as Record<string, unknown>).sprite = sprite;

        wrapper = new UniqueElement();
        wrapper.define(item);
      } else {
        // Multiple elements - use WrapperElement
        const wrapperProps = {
          id,
          type: 'wrapper' as const,
          locH: elemRect.x,
          locV: elemRect.y,
          width: elemRect.width,
          height: elemRect.height,
        };
        (wrapperProps as unknown as Record<string, unknown>).buffer = buffer;
        (wrapperProps as unknown as Record<string, unknown>).sprite = sprite;
        (wrapperProps as unknown as Record<string, unknown>).locX = elemRect.x;
        (wrapperProps as unknown as Record<string, unknown>).locY = elemRect.y;

        wrapper = new WrapperElement();
        wrapper.define(wrapperProps);

        // Add child elements
        for (const item of elemItems) {
          item.locH -= elemRect.x;
          item.locV -= elemRect.y;
          item.id = id;
          (item as unknown as Record<string, unknown>).mother = this.id;
          (item as unknown as Record<string, unknown>).buffer = buffer;
          (item as unknown as Record<string, unknown>).sprite = sprite;

          const child = new UniqueElement();
          child.define(item);
          (wrapper as WrapperElement).add(child);
        }
      }

      newElemList.set(id, wrapper);
      groupData.items.push(wrapper);

      // Position sprite
      sprite.x = elemRect.x + this.clientRect[0];
      sprite.y = elemRect.y + this.clientRect[1];
      sprite.z = this.locZ + this.spriteList.size;
    }

    // Update window dimensions
    if (groupNum === 0) {
      this.locX += layout.rect.x;
      this.locY += layout.rect.y;
      this.width = layout.rect.width;
      this.height = layout.rect.height;
    } else {
      const newW = this.clientRect[0] + this.clientRect[2] + layout.rect.width;
      const newH = this.clientRect[1] + this.clientRect[3] + layout.rect.height;
      if (newW !== this.width || newH !== this.height) {
        this.resizeTo(newW, newH);
      }
    }

    // Update client rect
    this.clientRect = [
      this.clientRect[0] + layout.border[0],
      this.clientRect[1] + layout.border[1],
      this.clientRect[2] + layout.border[2],
      this.clientRect[3] + layout.border[3],
    ];

    // Position sprites relative to window
    for (const [id, sprite] of newSpriteList) {
      const loc = [sprite.x - layout.rect.x, sprite.y - layout.rect.y];
      sprite.x = this.locX + loc[0];
      sprite.y = this.locY + loc[1];
      sprite.z = this.locZ + this.spriteList.size;

      this.memberList.set(id, newMemberList.get(id)!);
      this.spriteList.set(id, sprite);
    }

    // Add elements to main list
    for (const [id, elem] of newElemList) {
      this.elemList.set(id, elem);
    }

    this.groupData.push(groupData);

    // Prepare and render
    for (const item of groupData.items) {
      item.prepare();
      item.render();
    }

    return true;
  }

  /**
   * Close this window
   */
  close(): boolean {
    if (this.windowManager && typeof (this.windowManager as Record<string, unknown>).Remove === 'function') {
      return (this.windowManager as { Remove: (id: string) => boolean }).Remove(this.id);
    }
    return false;
  }

  /**
   * Lock the window (prevent z-order changes)
   */
  setLock(value: boolean = true): boolean {
    this.lock = value;
    return true;
  }

  /**
   * Hide the window
   */
  hide(): boolean {
    if (this.visible) {
      this.visible = false;
      this.moveX(10000); // Move off-screen
      return true;
    }
    return false;
  }

  /**
   * Show the window
   */
  show(): boolean {
    if (!this.visible) {
      this.visible = true;
      this.moveX(-10000); // Move back on-screen
      return true;
    }
    return false;
  }

  /**
   * Move to absolute position
   */
  moveTo(x: number, y: number): void {
    this.moveBy(x - this.locX, y - this.locY);
  }

  /**
   * Move by offset (with boundary checking)
   */
  moveBy(offX: number, offY: number): void {
    // Boundary checks
    if (this.locX + offX < this.boundary.x) {
      offX = this.boundary.x - this.locX;
    }
    if (this.locY + offY < this.boundary.y) {
      offY = this.boundary.y - this.locY;
    }
    if (this.locX + this.width + offX > this.boundary.x + this.boundary.width) {
      offX = this.boundary.x + this.boundary.width - this.locX - this.width;
    }
    if (this.locY + this.height + offY > this.boundary.y + this.boundary.height) {
      offY = this.boundary.y + this.boundary.height - this.locY - this.height;
    }

    this.locX += offX;
    this.locY += offY;
    this.moveXY(offX, offY);
  }

  /**
   * Move sprites in X direction
   */
  private moveX(offX: number): void {
    for (const sprite of this.spriteList.values()) {
      sprite.x += offX;
    }
  }

  /**
   * Move sprites in Y direction
   */
  private moveY(offY: number): void {
    for (const sprite of this.spriteList.values()) {
      sprite.y += offY;
    }
  }

  /**
   * Move sprites in both directions
   */
  private moveXY(offX: number, offY: number): void {
    for (const sprite of this.spriteList.values()) {
      sprite.x += offX;
      sprite.y += offY;
    }
  }

  /**
   * Move to Z position
   */
  moveZ(z: number): void {
    let i = 0;
    for (const sprite of this.spriteList.values()) {
      sprite.z = z + i;
      i++;
    }
    this.locZ = z;
  }

  /**
   * Center the window on screen
   */
  center(): void {
    const stageWidth = this.boundary.width;
    const stageHeight = this.boundary.height;
    const x = (stageWidth - this.width) / 2;
    const y = (stageHeight - this.height) / 2;
    this.moveTo(x, y);
  }

  /**
   * Resize by offset
   */
  resizeBy(offX: number, offY: number): void {
    if (offX !== 0 || offY !== 0) {
      this.width += offX;
      this.height += offY;
      for (const elem of this.elemList.values()) {
        elem.resizeBy(offX, offY);
      }
    }
  }

  /**
   * Resize to absolute size
   */
  resizeTo(x: number, y: number): void {
    const offW = x - this.width;
    const offH = y - this.height;
    this.resizeBy(offW, offH);
  }

  /**
   * Set as active window
   */
  setActive(): boolean {
    if (!this.active) {
      this.active = true;
      return true;
    }
    return false;
  }

  /**
   * Set as inactive window
   */
  setDeactive(): boolean {
    if (this.lock) return false;
    if (this.active) {
      this.active = false;
      return true;
    }
    return false;
  }

  /**
   * Get client rect
   */
  getClientRect(): Rect {
    return {
      x: this.locX,
      y: this.locY,
      width: this.width,
      height: this.height,
    };
  }

  /**
   * Get an element by ID
   */
  getElement(id: string): BaseElement | null {
    return this.elemList.get(id) ?? null;
  }

  /**
   * Check if element exists
   */
  elementExists(id: string): boolean {
    return this.elemList.has(id);
  }

  /**
   * Register a client object
   */
  registerClient(clientId: string): boolean {
    this.clientId = clientId;
    return true;
  }

  /**
   * Remove client
   */
  removeClient(): boolean {
    this.clientId = '';
    return true;
  }

  /**
   * Register an event procedure
   */
  registerProcedure(method: string, targetId: string, event?: WindowEvent): boolean {
    if (event) {
      this.procedures.set(event, { method, target: targetId });
    } else {
      // Register for all events
      for (const evt of this.getSupportedEvents()) {
        this.procedures.set(evt, { method, target: targetId });
      }
    }
    return true;
  }

  /**
   * Remove event procedure
   */
  removeProcedure(event?: WindowEvent): boolean {
    if (event) {
      this.procedures.delete(event);
    } else {
      this.initProcedures();
    }
    return true;
  }

  /**
   * Get a property
   */
  getProperty(prop: string): unknown {
    switch (prop) {
      case 'locX': return this.locX;
      case 'locY': return this.locY;
      case 'locZ': return this.locZ;
      case 'boundary': return this.boundary;
      case 'width': return this.width;
      case 'height': return this.height;
      case 'visible': return this.visible;
      case 'title': return this.title;
      case 'id': return this.id;
      case 'modal': return this.modal;
      case 'spriteList': return this.spriteList;
      case 'elementList': return this.elemList;
      case 'Active': return this.active;
      case 'lock': return this.lock;
      case 'sprCount': return this.spriteList.size;
      default: return null;
    }
  }

  /**
   * Set a property
   */
  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'locX':
        this.moveTo(value as number, this.locY);
        break;
      case 'locY':
        this.moveTo(this.locX, value as number);
        break;
      case 'locZ':
        this.moveZ(value as number);
        break;
      case 'boundary':
        this.boundary = value as Rect;
        break;
      case 'title':
        this.title = value as string;
        break;
      case 'modal':
        this.modal = value as boolean;
        break;
      case 'visible':
        if (value) this.show();
        else this.hide();
        break;
      default:
        return false;
    }
    return true;
  }

  /**
   * Set blend for all sprites
   */
  setBlend(blend: number): boolean {
    for (const sprite of this.spriteList.values()) {
      sprite.blend = blend;
    }
    return true;
  }

  /**
   * Get supported events
   */
  private getSupportedEvents(): WindowEvent[] {
    return [
      'mouseEnter', 'mouseLeave', 'mouseWithin',
      'mouseDown', 'mouseUp', 'mouseUpOutside',
      'keyDown', 'keyUp'
    ];
  }

  /**
   * Initialize procedures map
   */
  private initProcedures(): void {
    this.procedures.clear();
    for (const evt of this.getSupportedEvents()) {
      this.procedures.set(evt, { method: 'null', target: this.id });
    }
  }

  // Event handlers
  mouseEnter(_: unknown, spriteId: string): unknown {
    return this.redirectEvent('mouseEnter', spriteId);
  }

  mouseLeave(_: unknown, spriteId: string): unknown {
    return this.redirectEvent('mouseLeave', spriteId);
  }

  mouseWithin(_: unknown, spriteId: string): unknown {
    return this.redirectEvent('mouseWithin', spriteId);
  }

  mouseDown(_: unknown, spriteId: string): unknown {
    if (!this.active && !this.lock) {
      if (this.windowManager && typeof (this.windowManager as Record<string, unknown>).Activate === 'function') {
        (this.windowManager as { Activate: (id: string) => void }).Activate(this.id);
      }
    }

    if (this.specialIdList.includes(spriteId)) {
      if (spriteId.includes('drag')) {
        this.startDrag();
      } else if (spriteId.includes('scale')) {
        this.startScale();
      }
    }

    return this.redirectEvent('mouseDown', spriteId);
  }

  mouseUp(_: unknown, spriteId: string): unknown {
    if (this.specialIdList.includes(spriteId)) {
      if (spriteId.includes('drag')) {
        this.stopDrag();
      } else if (spriteId.includes('scale')) {
        this.stopScale();
      } else if (spriteId.includes('close')) {
        if (!this.clientId) {
          return this.close();
        }
      }
    }

    return this.redirectEvent('mouseUp', spriteId);
  }

  mouseUpOutside(_: unknown, spriteId: string): unknown {
    if (spriteId.includes('drag')) {
      this.stopDrag();
    }
    if (spriteId.includes('scale')) {
      this.stopScale();
    }
    return this.redirectEvent('mouseUpOutside', spriteId);
  }

  keyDown(_: unknown, spriteId: string): unknown {
    return this.redirectEvent('keyDown', spriteId);
  }

  keyUp(_: unknown, spriteId: string): unknown {
    return this.redirectEvent('keyUp', spriteId);
  }

  /**
   * Redirect event to registered handler
   */
  private redirectEvent(event: WindowEvent, spriteId: string): unknown {
    const proc = this.procedures.get(event);
    if (!proc || proc.method === 'null') return null;

    const element = this.elemList.get(spriteId);
    let param: unknown = null;

    if (element) {
      // Call element's event handler
      const handler = element[event as keyof BaseElement];
      if (typeof handler === 'function') {
        param = handler.call(element, spriteId);
      }
    }

    if (param === 0) return null;

    // Call registered procedure
    const target = objectManager.get(proc.target);
    if (target && typeof (target as Record<string, unknown>)[proc.method] === 'function') {
      return (target as Record<string, (...args: unknown[]) => unknown>)[proc.method](
        event, spriteId, param, this.id
      );
    }

    return null;
  }

  /**
   * Start dragging
   */
  private startDrag(): void {
    if (!this.dragFlag) {
      // Would need mouse position from event system
      this.dragFlag = true;
    }
  }

  /**
   * Stop dragging
   */
  private stopDrag(): void {
    if (this.dragFlag) {
      this.dragFlag = false;
    }
  }

  /**
   * Start scaling
   */
  private startScale(): void {
    if (!this.scaleFlag) {
      this.scaleFlag = true;
    }
  }

  /**
   * Stop scaling
   */
  private stopScale(): void {
    if (this.scaleFlag) {
      this.scaleFlag = false;
    }
  }

  /**
   * Update drag position (called from main loop)
   */
  updateDrag(mouseX: number, mouseY: number): void {
    if (this.dragFlag) {
      this.moveTo(mouseX - this.dragOffset[0], mouseY - this.dragOffset[1]);
    }
  }

  /**
   * Update scale (called from main loop)
   */
  updateScale(mouseX: number, mouseY: number): void {
    if (this.scaleFlag) {
      const offX = mouseX - this.scaleOffset[0];
      const offY = mouseY - this.scaleOffset[1];
      this.scaleOffset = [mouseX, mouseY];

      if (this.width + offX < 64) {
        // Don't resize below minimum
        return;
      }
      if (this.height + offY < 64) {
        return;
      }

      this.resizeBy(offX, offY);
    }
  }

  /**
   * Deconstruct the window
   */
  deconstruct(): void {
    // Release all sprites
    for (const [id, sprite] of this.spriteList) {
      // Release sprite from manager
    }

    // Deconstruct all elements
    for (const elem of this.elemList.values()) {
      elem.deconstruct();
    }

    this.elemList.clear();
    this.spriteList.clear();
    this.memberList.clear();
    this.groupData = [];
    this.windowManager = null;
  }
}
