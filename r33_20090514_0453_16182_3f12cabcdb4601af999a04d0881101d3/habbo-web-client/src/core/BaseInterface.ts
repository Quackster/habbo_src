/**
 * BaseInterface - Base class for all Interface objects
 *
 * Ported from Lingo interface patterns. Provides standard methods for
 * window management, element access, and event handling that match
 * the original Lingo API.
 *
 * In Lingo, interfaces typically:
 * - Create/manage windows via getWindow(), createWindow(), removeWindow()
 * - Access elements via elementExists(), getElement(), setText()
 * - Register for events via registerProcedure(), registerClient()
 * - Use timeouts via createTimeout(), removeTimeout()
 */

import { BaseObject } from './BaseObject';
import {
  createWindow,
  removeWindow,
  getWindow,
  windowExists,
  activateWindow,
  deactivateWindow,
  registerClient,
  registerProcedure,
  getWindowManager,
} from '../ui/WindowManager';
import { WindowInstance } from '../ui/WindowInstance';
import { BaseElement } from '../ui/elements';
import { timeoutManager } from './TimeoutManager';

/**
 * Window event types for procedure registration
 */
export type WindowEventType =
  | 'mouseEnter'
  | 'mouseLeave'
  | 'mouseWithin'
  | 'mouseDown'
  | 'mouseUp'
  | 'mouseUpOutside'
  | 'keyDown'
  | 'keyUp';

/**
 * Base class for all Interface objects in the ICH pattern
 */
export abstract class BaseInterface extends BaseObject {
  /** Map of managed window IDs */
  protected windowIds: Set<string> = new Set();

  /** Map of active timeouts by name */
  protected timeoutIds: Map<string, string> = new Map();

  /**
   * Construct the interface
   */
  construct(): void {
    super.construct();
    this.windowIds = new Set();
    this.timeoutIds = new Map();
  }

  /**
   * Deconstruct the interface - clean up all windows and timeouts
   */
  deconstruct(): void {
    // Remove all managed windows
    for (const windowId of this.windowIds) {
      this.removeWindow(windowId);
    }
    this.windowIds.clear();

    // Remove all timeouts
    for (const timeoutId of this.timeoutIds.values()) {
      this.removeTimeout(timeoutId);
    }
    this.timeoutIds.clear();

    super.deconstruct();
  }

  // ============================================================
  // Window Management - matches Lingo API
  // ============================================================

  /**
   * Create a window
   *
   * Lingo: createWindow(windowId, layoutFile, locX, locY)
   */
  protected async createWindow(
    windowId: string,
    layout?: string,
    locX?: number,
    locY?: number
  ): Promise<boolean> {
    const result = await createWindow(windowId, layout, locX, locY);
    if (result) {
      this.windowIds.add(windowId);
      // Register this interface as the client for the window
      this.registerClientForWindow(windowId);
    }
    return result;
  }

  /**
   * Create a modal window
   *
   * Lingo: createWindow(windowId, layoutFile, VOID, VOID, #modal)
   */
  protected async createModalWindow(
    windowId: string,
    layout?: string
  ): Promise<boolean> {
    const result = await createWindow(windowId, layout, undefined, undefined, 'modal');
    if (result) {
      this.windowIds.add(windowId);
      this.registerClientForWindow(windowId);
    }
    return result;
  }

  /**
   * Remove a window
   *
   * Lingo: removeWindow(windowId)
   */
  protected removeWindow(windowId: string): boolean {
    const result = removeWindow(windowId);
    this.windowIds.delete(windowId);
    return result;
  }

  /**
   * Get a window instance
   *
   * Lingo: getWindow(windowId)
   */
  protected getWindow(windowId: string): WindowInstance | null {
    return getWindow(windowId);
  }

  /**
   * Check if window exists
   *
   * Lingo: windowExists(windowId)
   */
  protected windowExists(windowId: string): boolean {
    return windowExists(windowId);
  }

  /**
   * Activate (bring to front) a window
   *
   * Lingo: activateWindow(windowId)
   */
  protected activateWindow(windowId: string): boolean {
    return activateWindow(windowId);
  }

  /**
   * Deactivate a window
   *
   * Lingo: deactivateWindow(windowId)
   */
  protected deactivateWindow(windowId: string): boolean {
    return deactivateWindow(windowId);
  }

  /**
   * Move a window to position
   *
   * Lingo: tWndObj.moveTo(x, y)
   */
  protected moveWindow(windowId: string, x: number, y: number): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      wnd.moveTo(x, y);
      return true;
    }
    return false;
  }

  /**
   * Center a window on screen
   *
   * Lingo: tWndObj.center()
   */
  protected centerWindow(windowId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      wnd.center();
      return true;
    }
    return false;
  }

  /**
   * Hide a window
   *
   * Lingo: tWndObj.hide()
   */
  protected hideWindow(windowId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.hide();
    }
    return false;
  }

  /**
   * Show a window
   *
   * Lingo: tWndObj.show()
   */
  protected showWindow(windowId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.show();
    }
    return false;
  }

  /**
   * Merge a layout into an existing window
   *
   * Lingo: tWndObj.merge(layoutFile)
   */
  protected async mergeWindow(windowId: string, layout: string): Promise<boolean> {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.merge(layout);
    }
    return false;
  }

  /**
   * Unmerge the last merged layout from a window
   *
   * Lingo: tWndObj.unmerge()
   */
  protected unmergeWindow(windowId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.unmerge();
    }
    return false;
  }

  /**
   * Lock window z-ordering globally
   *
   * Lingo: lockWindowLayering()
   */
  protected lockWindowLayering(): boolean {
    return getWindowManager().lock();
  }

  /**
   * Unlock window z-ordering globally
   *
   * Lingo: unlockWindowLayering()
   */
  protected unlockWindowLayering(): boolean {
    return getWindowManager().unlock();
  }

  // ============================================================
  // Element Access - matches Lingo API
  // ============================================================

  /**
   * Check if element exists in window
   *
   * Lingo: tWndObj.elementExists(elementId)
   */
  protected elementExists(windowId: string, elementId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.elementExists(elementId);
    }
    return false;
  }

  /**
   * Get an element from a window
   *
   * Lingo: tWndObj.getElement(elementId)
   */
  protected getElement(windowId: string, elementId: string): BaseElement | null {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.getElement(elementId);
    }
    return null;
  }

  /**
   * Set text on an element
   *
   * Lingo: tElem.setText(text)
   */
  protected setText(windowId: string, elementId: string, text: string): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem && typeof (elem as any).setText === 'function') {
      (elem as any).setText(text);
      return true;
    }
    // Fallback to property
    if (elem) {
      return elem.setProperty('text', text);
    }
    return false;
  }

  /**
   * Get text from an element
   *
   * Lingo: tElem.getText()
   */
  protected getText(windowId: string, elementId: string): string {
    const elem = this.getElement(windowId, elementId);
    if (elem && typeof (elem as any).getText === 'function') {
      return (elem as any).getText();
    }
    // Fallback to property
    if (elem) {
      return (elem.getProperty('text') as string) ?? '';
    }
    return '';
  }

  /**
   * Set element property
   *
   * Lingo: tElem.setProperty(#prop, value)
   */
  protected setElementProperty(
    windowId: string,
    elementId: string,
    property: string,
    value: unknown
  ): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem) {
      return elem.setProperty(property, value);
    }
    return false;
  }

  /**
   * Get element property
   *
   * Lingo: tElem.getProperty(#prop)
   */
  protected getElementProperty(
    windowId: string,
    elementId: string,
    property: string
  ): unknown {
    const elem = this.getElement(windowId, elementId);
    if (elem) {
      return elem.getProperty(property);
    }
    return null;
  }

  /**
   * Show an element
   *
   * Lingo: tElem.show()
   */
  protected showElement(windowId: string, elementId: string): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem) {
      return elem.show();
    }
    return false;
  }

  /**
   * Hide an element
   *
   * Lingo: tElem.hide()
   */
  protected hideElement(windowId: string, elementId: string): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem) {
      return elem.hide();
    }
    return false;
  }

  /**
   * Move an element
   *
   * Lingo: tElem.moveTo(x, y)
   */
  protected moveElement(
    windowId: string,
    elementId: string,
    x: number,
    y: number
  ): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem) {
      elem.moveTo(x, y);
      return true;
    }
    return false;
  }

  /**
   * Resize an element
   *
   * Lingo: tElem.resizeTo(w, h)
   */
  protected resizeElement(
    windowId: string,
    elementId: string,
    width: number,
    height: number
  ): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem) {
      elem.resizeTo(width, height);
      return true;
    }
    return false;
  }

  /**
   * Feed an image to an element
   *
   * Lingo: tElem.feedImage(imageData)
   */
  protected feedImage(
    windowId: string,
    elementId: string,
    image: HTMLCanvasElement | HTMLImageElement | ImageData
  ): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem && typeof (elem as any).feedImage === 'function') {
      (elem as any).feedImage(image);
      return true;
    }
    return false;
  }

  /**
   * Clear image from an element
   *
   * Lingo: tElem.clearImage()
   */
  protected clearImage(windowId: string, elementId: string): boolean {
    const elem = this.getElement(windowId, elementId);
    if (elem && typeof (elem as any).clearImage === 'function') {
      (elem as any).clearImage();
      return true;
    }
    return false;
  }

  // ============================================================
  // Event Registration - matches Lingo API
  // ============================================================

  /**
   * Register this interface as a client for window events
   *
   * Lingo: tWndObj.registerClient(me.getID())
   */
  protected registerClientForWindow(windowId: string): boolean {
    return registerClient(windowId, this.id);
  }

  /**
   * Register event procedure handler
   *
   * Lingo: tWndObj.registerProcedure(#eventHandler, me.getID(), #mouseUp)
   */
  protected registerWindowProcedure(
    windowId: string,
    handlerMethod: string,
    event?: WindowEventType
  ): boolean {
    return registerProcedure(windowId, handlerMethod, this.id, event);
  }

  /**
   * Remove event procedure handler
   *
   * Lingo: tWndObj.removeProcedure(#mouseUp)
   */
  protected removeWindowProcedure(windowId: string, event?: WindowEventType): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.removeProcedure(event);
    }
    return false;
  }

  // ============================================================
  // Timeout Management - matches Lingo API
  // ============================================================

  /**
   * Create a named timeout
   *
   * Lingo: createTimeout(timeoutName, duration, #handler, me.getID(), [...])
   */
  protected createTimeout(
    name: string,
    durationMs: number,
    handlerMethod: string,
    args?: unknown[]
  ): boolean {
    // Remove existing timeout with same name
    this.removeTimeout(name);

    const timeoutId = `${this.id}_timeout_${name}_${Date.now()}`;

    timeoutManager.create(
      timeoutId,
      durationMs,
      () => {
        this.timeoutIds.delete(name);
        const handler = (this as Record<string, unknown>)[handlerMethod];
        if (typeof handler === 'function') {
          if (args) {
            handler.call(this, ...args);
          } else {
            handler.call(this);
          }
        }
      },
      false
    );

    this.timeoutIds.set(name, timeoutId);
    return true;
  }

  /**
   * Remove a named timeout
   *
   * Lingo: removeTimeout(timeoutName)
   */
  protected removeTimeout(name: string): boolean {
    const timeoutId = this.timeoutIds.get(name);
    if (timeoutId) {
      timeoutManager.remove(timeoutId);
      this.timeoutIds.delete(name);
      return true;
    }
    return false;
  }

  /**
   * Check if timeout exists
   *
   * Lingo: timeoutExists(timeoutName)
   */
  protected timeoutExists(name: string): boolean {
    const timeoutId = this.timeoutIds.get(name);
    if (timeoutId) {
      return timeoutManager.exists(timeoutId);
    }
    return false;
  }

  // ============================================================
  // Window Property Helpers
  // ============================================================

  /**
   * Set window property
   */
  protected setWindowProperty(windowId: string, property: string, value: unknown): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.setProperty(property, value);
    }
    return false;
  }

  /**
   * Get window property
   */
  protected getWindowProperty(windowId: string, property: string): unknown {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.getProperty(property);
    }
    return null;
  }

  /**
   * Lock a window (prevent z-order changes)
   */
  protected lockWindow(windowId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.setLock(true);
    }
    return false;
  }

  /**
   * Unlock a window
   */
  protected unlockWindowInstance(windowId: string): boolean {
    const wnd = this.getWindow(windowId);
    if (wnd) {
      return wnd.setLock(false);
    }
    return false;
  }

  // ============================================================
  // Event Handler - Override in subclasses
  // ============================================================

  /**
   * Default event handler for window events
   * Override in subclasses to handle specific events
   *
   * Lingo: eventProcName(event, spriteId, param, windowId)
   */
  eventProc(
    event: string,
    spriteId: string,
    param: unknown,
    windowId: string
  ): void {
    // Override in subclasses
  }
}
