/**
 * Poll Interface Class - UI for polls/surveys
 *
 * Ported from: hh_poll/Cast External ParentScript 3 - Poll Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { executeMessage } from '../../core/MessageBus';
import { EventEmitter } from '../../core/events';

export class PollInterface extends BaseObject {
  private events: EventEmitter = new EventEmitter();

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Show poll offer dialog
   */
  showOffer(description: string): void {
    this.events.emit('showOffer', { description });
  }

  /**
   * Show question dialog
   */
  showQuestion(): void {
    this.events.emit('showQuestion');
  }

  /**
   * Hide question dialog
   */
  hideQuestion(): void {
    this.events.emit('hideQuestion');
  }

  /**
   * Hide all windows
   */
  hideWindows(): void {
    this.events.emit('hideWindows');
  }

  /**
   * Show alert message
   */
  showAlert(message: string): void {
    executeMessage('alert', { Msg: message });
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }
}
