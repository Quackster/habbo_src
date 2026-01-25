/**
 * Recycler Interface Class - UI for recycling items
 *
 * Ported from: hh_recycler/Cast External ParentScript 3 - Recycler Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { RecyclerState } from './types';
import { RecyclerComponent } from './RecyclerComponent';

export class RecyclerInterface extends BaseInterface {
  private pWindowId: string = 'recycler_window';
  private pHostWindowObject: unknown = null;

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Set host window object
   */
  setHostWindowObject(obj: unknown): void {
    this.pHostWindowObject = obj;
  }

  /**
   * Update view based on state
   *
   * Lingo: updateView(state)
   */
  updateView(state: RecyclerState): void {
    if (!this.windowExists(this.pWindowId)) return;

    // Show/hide elements based on state
    switch (state) {
      case 'disabled':
        if (this.elementExists(this.pWindowId, 'disabled_message')) {
          this.showElement(this.pWindowId, 'disabled_message');
        }
        if (this.elementExists(this.pWindowId, 'slots_container')) {
          this.hideElement(this.pWindowId, 'slots_container');
        }
        break;
      case 'ready':
        if (this.elementExists(this.pWindowId, 'disabled_message')) {
          this.hideElement(this.pWindowId, 'disabled_message');
        }
        if (this.elementExists(this.pWindowId, 'slots_container')) {
          this.showElement(this.pWindowId, 'slots_container');
        }
        if (this.elementExists(this.pWindowId, 'timeout_message')) {
          this.hideElement(this.pWindowId, 'timeout_message');
        }
        break;
      case 'timeout':
        if (this.elementExists(this.pWindowId, 'timeout_message')) {
          this.showElement(this.pWindowId, 'timeout_message');
        }
        break;
    }
  }

  /**
   * Update recycle button state
   *
   * Lingo: updateRecycleButton()
   */
  updateRecycleButton(): void {
    if (!this.windowExists(this.pWindowId)) return;

    const component = this.getComponent() as RecyclerComponent | null;
    if (!component) return;

    const poolFull = component.isPoolFull();
    if (this.elementExists(this.pWindowId, 'button_recycle')) {
      this.setElementProperty(this.pWindowId, 'button_recycle', 'enabled', poolFull);
    }
  }

  /**
   * Update slots display
   *
   * Lingo: updateSlots()
   */
  updateSlots(): void {
    if (!this.windowExists(this.pWindowId)) return;

    const component = this.getComponent() as RecyclerComponent | null;
    if (!component) return;

    const pool = component.getGiveFurniPool();

    // Update each slot
    for (let i = 0; i < 5; i++) {
      const slotId = `slot_${i}`;
      if (this.elementExists(this.pWindowId, slotId)) {
        const item = pool[i];
        if (item) {
          // Show item in slot
          this.setElementProperty(this.pWindowId, slotId, 'item', item);
          this.showElement(this.pWindowId, slotId);
        } else {
          // Clear slot
          this.setElementProperty(this.pWindowId, slotId, 'item', null);
        }
      }
    }

    this.updateRecycleButton();
  }

  /**
   * Show recycler window
   *
   * Lingo: showWindow() - embedded in host window
   */
  showWindow(): void {
    // Recycler is typically embedded in furniture window
    // This would show/activate the recycler view
    if (this.windowExists(this.pWindowId)) {
      this.showElement(this.pWindowId, 'recycler_view');
    }
  }

  /**
   * Hide recycler window
   *
   * Lingo: hideWindow()
   */
  hideWindow(): void {
    if (this.windowExists(this.pWindowId)) {
      this.hideElement(this.pWindowId, 'recycler_view');
    }
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }
}
