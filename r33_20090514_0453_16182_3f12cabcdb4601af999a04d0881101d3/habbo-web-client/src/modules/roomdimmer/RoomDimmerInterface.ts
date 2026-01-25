/**
 * Room Dimmer Interface Class - UI for room dimmer
 *
 * Ported from: hh_roomdimmer/Cast External ParentScript 4 - Roomdimmer Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';

export class RoomDimmerInterface extends BaseObject {
  private events: EventEmitter = new EventEmitter();

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Show control panel
   */
  showControlPanel(): void {
    this.events.emit('showControlPanel');
  }

  /**
   * Hide control panel
   */
  hide(): void {
    this.events.emit('hide');
  }

  /**
   * Update interface
   */
  updateInterface(): void {
    this.events.emit('updateInterface');
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }
}
