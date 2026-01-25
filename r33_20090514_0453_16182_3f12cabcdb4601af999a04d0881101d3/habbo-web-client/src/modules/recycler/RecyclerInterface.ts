/**
 * Recycler Interface Class - UI for recycling items
 *
 * Ported from: hh_recycler/Cast External ParentScript 3 - Recycler Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';
import { RecyclerState } from './types';
import { RecyclerComponent } from './RecyclerComponent';

export class RecyclerInterface extends BaseObject {
  private hostWindowObject: unknown = null;
  private events: EventEmitter = new EventEmitter();

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
    this.hostWindowObject = obj;
  }

  /**
   * Update view based on state
   */
  updateView(state: RecyclerState): void {
    this.events.emit('updateView', { state });
  }

  /**
   * Update recycle button state
   */
  updateRecycleButton(): void {
    const component = this.getComponent() as RecyclerComponent | null;
    if (!component) return;

    const poolFull = component.isPoolFull();
    this.events.emit('updateRecycleButton', { enabled: poolFull });
  }

  /**
   * Update slots display
   */
  updateSlots(): void {
    const component = this.getComponent() as RecyclerComponent | null;
    if (!component) return;

    const pool = component.getGiveFurniPool();
    this.events.emit('updateSlots', { items: pool });
    this.updateRecycleButton();
  }

  /**
   * Show recycler window
   */
  showWindow(): void {
    this.events.emit('showWindow');
  }

  /**
   * Hide recycler window
   */
  hideWindow(): void {
    this.events.emit('hideWindow');
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }
}
