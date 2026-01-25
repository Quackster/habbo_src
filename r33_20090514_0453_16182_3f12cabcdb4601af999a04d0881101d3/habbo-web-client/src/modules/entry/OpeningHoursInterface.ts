/**
 * Opening Hours Interface Class - UI for hotel closing/closed dialogs
 *
 * Ported from: hh_entry/Cast External ParentScript 11 - Opening Hours Interface Class.ls
 *              hh_entry_init/Cast External ParentScript 11 - Opening Hours Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';

export class OpeningHoursInterface extends BaseObject {
  private hotelClosingId: string = 'Opening Hours';
  private loginFailedId: string = 'opening_hours_login_failed';
  private events: EventEmitter = new EventEmitter();

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.hideAll();
    super.deconstruct();
  }

  /**
   * Hide all opening hours dialogs
   */
  hideAll(): boolean {
    this.hideHotelClosingAlert();
    this.hideHotelClosingNotice();
    this.hideHotelClosedNotice();
    this.hideHotelClosedDisconnectNotice();
    return true;
  }

  /**
   * Show hotel closing alert (countdown before shutdown)
   */
  showHotelClosingAlert(minutesUntil?: number): void {
    let text = 'The hotel will close for maintenance';
    if (minutesUntil !== undefined) {
      text += ` in ${minutesUntil} minutes`;
    }
    text += '. Please save your progress.';

    this.events.emit('showHotelClosingAlert', {
      id: this.hotelClosingId,
      title: 'Hotel Closing',
      text,
      minutesUntil,
    });
  }

  /**
   * Show hotel closing notice (maintenance mode)
   */
  showHotelClosingNotice(): void {
    this.events.emit('showHotelClosingNotice', {
      id: this.hotelClosingId,
      title: 'Hotel Closed',
      text: 'The hotel is currently closed for maintenance. Please try again later.',
    });
  }

  /**
   * Show hotel closed notice with opening time
   */
  showHotelClosedNotice(openHour: number, openMinute: number): void {
    const hourStr = openHour.toString().padStart(2, '0');
    const minuteStr = openMinute.toString().padStart(2, '0');

    this.events.emit('showHotelClosedNotice', {
      id: this.hotelClosingId,
      title: 'Hotel Closed',
      text: `The hotel is currently closed. It will reopen at ${hourStr}:${minuteStr}.`,
      openHour,
      openMinute,
    });
  }

  /**
   * Show hotel closed disconnect notice (logged out due to closing)
   */
  showHotelClosedDisconnectNotice(openHour: number, openMinute: number): void {
    const hourStr = openHour.toString().padStart(2, '0');
    const minuteStr = openMinute.toString().padStart(2, '0');

    this.events.emit('showHotelClosedDisconnectNotice', {
      id: this.loginFailedId,
      title: 'Connection Failure',
      text: `The hotel has closed. It will reopen at ${hourStr}:${minuteStr}.`,
      openHour,
      openMinute,
    });
  }

  /**
   * Hide hotel closing alert
   */
  hideHotelClosingAlert(): boolean {
    this.events.emit('hideHotelClosingAlert', { id: this.hotelClosingId });
    return true;
  }

  /**
   * Hide hotel closing notice
   */
  hideHotelClosingNotice(): boolean {
    this.events.emit('hideHotelClosingNotice', { id: this.hotelClosingId });
    return true;
  }

  /**
   * Hide hotel closed disconnect notice
   */
  hideHotelClosedDisconnectNotice(): boolean {
    this.events.emit('hideHotelClosedDisconnectNotice', { id: this.loginFailedId });
    return true;
  }

  /**
   * Hide hotel closed notice
   */
  hideHotelClosedNotice(): boolean {
    this.events.emit('hideHotelClosedNotice', { id: this.hotelClosingId });
    return true;
  }

  /**
   * Handle dialog events
   */
  handleDialogEvent(event: string, elementId: string, dialogId: string): void {
    if (event === 'mouseUp') {
      switch (elementId) {
        case 'close':
        case 'openhrs_ok':
          if (dialogId === this.hotelClosingId) {
            this.hideHotelClosingAlert();
          } else if (dialogId === this.loginFailedId) {
            this.hideHotelClosedDisconnectNotice();
          }
          break;
      }
    }
  }

  /**
   * Get events emitter for UI binding
   */
  getEvents(): EventEmitter {
    return this.events;
  }
}
