/**
 * Window Manager Class
 *
 * Ported from: fuse_client/Cast External ParentScript 39 - Window Manager Class.ls
 *
 * Manages all windows in the UI system including z-ordering, activation,
 * modal windows, and event routing.
 */

import { WindowInstance } from './WindowInstance';
import { Rect, EventData } from './types';
import { objectManager } from '../core/ObjectManager';
import { getVariable } from '../core/VariableContainer';

class WindowManager {
  private lockLocZ: boolean = false;
  private defLocX: number = 100;
  private defLocY: number = 100;
  private defaultLocZ: number = 0;
  private availableLocZ: number = 0;
  private itemList: string[] = [];
  private hideList: string[] = [];
  private posCache: Map<string, [number, number]> = new Map();
  private boundary: Rect = { x: -20, y: -20, width: 840, height: 640 };
  private modalId: string = 'modal';
  private activeItem: string = '';
  private lastEventData: EventData = {
    title: '',
    sprite: '',
    event: 'mouseDown',
    time: 0,
  };

  constructor() {
    this.defLocX = getVariable('window.default.locx', 100) as number;
    this.defLocY = getVariable('window.default.locy', 100) as number;
    this.defaultLocZ = getVariable('window.default.locz', 0) as number;
    this.availableLocZ = this.defaultLocZ;

    // Get boundary from config
    const boundaryLimit = getVariable('window.boundary.limit', [-20, -20, 20, 20]) as number[];
    const stageWidth = 800;
    const stageHeight = 600;
    this.boundary = {
      x: boundaryLimit[0],
      y: boundaryLimit[1],
      width: stageWidth + boundaryLimit[2] - boundaryLimit[0],
      height: stageHeight + boundaryLimit[3] - boundaryLimit[1],
    };
  }

  /**
   * Create a new window
   */
  async create(
    id: string,
    layout?: string,
    locX?: number,
    locY?: number,
    special?: 'modal' | 'modalcorner'
  ): Promise<boolean> {
    // Handle modal windows
    if (special === 'modal') {
      return this.modal(id, layout);
    }
    if (special === 'modalcorner') {
      return this.modal(id, layout, 'corner');
    }

    if (!layout) {
      layout = 'empty.window';
    }

    // If window exists, get its position and remove it
    if (this.exists(id)) {
      const existing = this.get(id);
      if (existing) {
        if (locX === undefined) {
          locX = existing.getProperty('locX') as number;
        }
        if (locY === undefined) {
          locY = existing.getProperty('locY') as number;
        }
      }
      this.remove(id);
    }

    // Determine position
    let x: number, y: number;
    if (locX !== undefined && locY !== undefined) {
      x = locX;
      y = locY;
    } else if (this.posCache.has(id)) {
      [x, y] = this.posCache.get(id)!;
    } else {
      x = this.defLocX;
      y = this.defLocY;
    }

    // Create window object
    const window = new WindowInstance();
    window.setId(id);

    // Register with object manager
    objectManager.register(id, window);

    // Define window properties
    const props = {
      locX: x,
      locY: y,
      locZ: this.availableLocZ,
      boundary: this.boundary,
      elements: {},
      manager: this,
    };

    if (!window.define(props)) {
      objectManager.remove(id);
      return false;
    }

    // Merge layout
    if (!await window.merge(layout)) {
      objectManager.remove(id);
      return false;
    }

    this.itemList.push(id);
    this.availableLocZ += window.getProperty('sprCount') as number;
    this.activate();

    return true;
  }

  /**
   * Remove a window
   */
  remove(id: string): boolean {
    if (!id) return false;

    const window = this.get(id);
    if (!window) return false;

    // Cache position
    this.posCache.set(id, [
      window.getProperty('locX') as number,
      window.getProperty('locY') as number,
    ]);

    // Clean up
    window.deconstruct();
    objectManager.remove(id);

    // Remove from item list
    const idx = this.itemList.indexOf(id);
    if (idx !== -1) {
      this.itemList.splice(idx, 1);
    }

    // Handle active item
    let nextActive: string | undefined;
    if (this.activeItem === id) {
      nextActive = undefined;
    } else {
      nextActive = this.activeItem;
    }

    // Check for remaining modals
    if (this.exists(this.modalId)) {
      let hasModals = false;
      for (let i = this.itemList.length - 1; i >= 0; i--) {
        const wnd = this.get(this.itemList[i]);
        if (wnd?.getProperty('modal')) {
          hasModals = true;
          nextActive = this.itemList[i];
          break;
        }
      }
      if (!hasModals) {
        this.remove(this.modalId);
      }
    }

    this.activate(nextActive);
    return true;
  }

  /**
   * Activate a window (bring to front)
   */
  activate(id?: string): boolean {
    if (this.lockLocZ) return false;
    if (this.itemList.length === 0) return false;

    // Check if current active is modal
    if (this.exists(this.activeItem)) {
      const activeWnd = this.get(this.activeItem);
      if (activeWnd?.getProperty('modal')) {
        id = this.activeItem;
        // Ensure modal overlay is on top
        if (this.exists(this.modalId)) {
          const modalIdx = this.itemList.indexOf(this.modalId);
          if (modalIdx !== -1) {
            this.itemList.splice(modalIdx, 1);
            this.itemList.push(this.modalId);
          }
        }
      }
    }

    // Find window to activate
    if (id !== undefined) {
      if (!this.exists(id)) return false;
      const wnd = this.get(id);
      if (wnd?.getProperty('lock')) {
        id = undefined;
      }
    }

    if (id === undefined) {
      // Find first non-locked window from back
      for (let i = this.itemList.length - 1; i >= 0; i--) {
        const wnd = this.get(this.itemList[i]);
        if (!wnd?.getProperty('lock') || wnd.getProperty('modal')) {
          id = this.itemList[i];
          break;
        }
      }
    }

    if (!id) return false;

    // Move to end of list
    const idx = this.itemList.indexOf(id);
    if (idx !== -1) {
      this.itemList.splice(idx, 1);
      this.itemList.push(id);
    }

    // Reassign z-order
    this.availableLocZ = this.defaultLocZ;
    for (const currId of this.itemList) {
      const wnd = this.get(currId);
      if (!wnd) continue;

      if (!wnd.getProperty('lock')) {
        wnd.setDeactive();
      }

      const spriteList = wnd.getProperty('spriteList') as Map<string, unknown>;
      if (!wnd.getProperty('lock') || currId === id) {
        wnd.moveZ(this.availableLocZ);
        this.availableLocZ += spriteList.size;
      }
    }

    this.activeItem = id;
    return this.get(id)!.setActive();
  }

  /**
   * Deactivate a window
   */
  deactivate(id: string): boolean {
    if (!this.exists(id)) return false;

    const wnd = this.get(id);
    if (wnd?.getProperty('modal')) return false;

    // Move to beginning of list
    const idx = this.itemList.indexOf(id);
    if (idx !== -1) {
      this.itemList.splice(idx, 1);
      this.itemList.unshift(id);
    }

    this.activate();
    return true;
  }

  /**
   * Reorder windows
   */
  reorder(newOrder: string[]): boolean {
    if (newOrder.join(',') === this.itemList.join(',')) {
      return true;
    }

    this.itemList = newOrder;
    this.availableLocZ = this.defaultLocZ;

    for (const id of this.itemList) {
      const wnd = this.get(id);
      if (!wnd) continue;

      const spriteList = wnd.getProperty('spriteList') as Map<string, unknown>;
      wnd.moveZ(this.availableLocZ);
      this.availableLocZ += spriteList.size;
    }

    return true;
  }

  /**
   * Lock z-ordering (prevent activation changes)
   */
  lock(): boolean {
    this.lockLocZ = true;
    return true;
  }

  /**
   * Unlock z-ordering
   */
  unlock(): boolean {
    this.lockLocZ = false;
    return true;
  }

  /**
   * Create a modal window
   */
  async modal(
    id: string,
    layout?: string,
    position: 'center' | 'corner' = 'center'
  ): Promise<boolean> {
    if (!await this.create(id, layout)) {
      return false;
    }

    const wnd = this.get(id);
    if (!wnd) return false;

    if (position === 'center') {
      wnd.center();
    } else {
      wnd.moveTo(0, 0);
    }

    wnd.setLock(true);
    wnd.setProperty('modal', true);

    // Create modal overlay if needed
    if (!this.exists(this.modalId)) {
      if (await this.create(this.modalId, 'modal.window')) {
        const modalWnd = this.get(this.modalId);
        if (modalWnd) {
          modalWnd.moveTo(0, 0);
          modalWnd.resizeTo(this.boundary.width, this.boundary.height);
          modalWnd.setLock(true);
          const modalElem = modalWnd.getElement('modal');
          if (modalElem) {
            modalElem.setProperty('blend', 40);
          }
        }
      } else {
        console.error('WindowManager: Failed to create modal window layer');
      }
    }

    this.activeItem = id;
    this.activate(id);

    return true;
  }

  /**
   * Get a window by ID
   */
  get(id: string): WindowInstance | null {
    return objectManager.get<WindowInstance>(id);
  }

  /**
   * Check if window exists
   */
  exists(id: string): boolean {
    return this.itemList.includes(id) && objectManager.exists(id);
  }

  /**
   * Get all window IDs
   */
  getIdList(): string[] {
    return [...this.itemList];
  }

  /**
   * Hide all windows
   */
  hideAll(): boolean {
    for (const id of this.itemList) {
      const wnd = this.get(id);
      if (wnd?.getProperty('visible')) {
        wnd.hide();
        this.hideList.push(id);
      }
    }
    return true;
  }

  /**
   * Show all previously hidden windows
   */
  showAll(): boolean {
    for (const id of this.hideList) {
      const wnd = this.get(id);
      wnd?.show();
    }
    this.hideList = [];
    return true;
  }

  /**
   * Register a window event for tracking
   */
  registerWindowEvent(title: string, spriteId: string, event: string): void {
    if (['mouseUp', 'mouseDown', 'keyUp', 'keyDown'].includes(event)) {
      this.lastEventData = {
        title,
        sprite: spriteId,
        event: event as EventData['event'],
        time: Date.now(),
      };
    }
  }

  /**
   * Get last event info
   */
  getLastEvent(): string {
    return `${this.lastEventData.title}-${this.lastEventData.sprite}-${this.lastEventData.event}`;
  }

  /**
   * Get last event time
   */
  getLastEventTime(): number {
    return this.lastEventData.time;
  }

  /**
   * Get property
   */
  getProperty(prop: string): unknown {
    switch (prop) {
      case 'defaultLocZ': return this.defaultLocZ;
      case 'boundary': return this.boundary;
      case 'count': return this.itemList.length;
      default: return null;
    }
  }

  /**
   * Set property
   */
  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'defaultLocZ':
        this.defaultLocZ = value as number;
        this.activate();
        return true;
      case 'boundary':
        this.boundary = value as Rect;
        return true;
      default:
        return false;
    }
  }

  /**
   * Print debug info
   */
  print(): void {
    console.log('WindowManager State:');
    console.log('  Active:', this.activeItem);
    console.log('  Windows:', this.itemList);
    console.log('  LocZ:', this.availableLocZ);
  }
}

// Singleton instance
let windowManagerInstance: WindowManager | null = null;

export function getWindowManager(): WindowManager {
  if (!windowManagerInstance) {
    windowManagerInstance = new WindowManager();
  }
  return windowManagerInstance;
}

// API functions (matching original Lingo API)
export async function createWindow(
  id: string,
  layout?: string,
  locX?: number,
  locY?: number,
  special?: 'modal' | 'modalcorner'
): Promise<boolean> {
  return getWindowManager().create(id, layout, locX, locY, special);
}

export function removeWindow(id: string): boolean {
  return getWindowManager().remove(id);
}

export function getWindow(id: string): WindowInstance | null {
  return getWindowManager().get(id);
}

export function windowExists(id: string): boolean {
  return getWindowManager().exists(id);
}

export function activateWindow(id: string): boolean {
  return getWindowManager().activate(id);
}

export function deactivateWindow(id: string): boolean {
  return getWindowManager().deactivate(id);
}

export async function mergeWindow(id: string, layout: string): Promise<boolean> {
  const wnd = getWindow(id);
  if (wnd) {
    return wnd.merge(layout);
  }
  return false;
}

export function registerClient(id: string, clientId: string): boolean {
  const wnd = getWindow(id);
  if (wnd) {
    return wnd.registerClient(clientId);
  }
  return false;
}

export function registerProcedure(
  id: string,
  handler: string,
  clientId: string,
  event?: string
): boolean {
  const wnd = getWindow(id);
  if (wnd) {
    return wnd.registerProcedure(handler, clientId, event as any);
  }
  return false;
}

export function showWindows(): boolean {
  return getWindowManager().showAll();
}

export function hideWindows(): boolean {
  return getWindowManager().hideAll();
}

export function lockWindowLayering(): boolean {
  return getWindowManager().lock();
}

export function unlockWindowLayering(): boolean {
  return getWindowManager().unlock();
}

export function getWindowIdList(): string[] {
  return getWindowManager().getIdList();
}
