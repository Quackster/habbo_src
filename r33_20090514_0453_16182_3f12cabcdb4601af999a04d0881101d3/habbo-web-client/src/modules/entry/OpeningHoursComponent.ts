/**
 * Opening Hours Component Class - Business logic for hotel availability
 *
 * Ported from: hh_entry/Cast External ParentScript 12 - Opening Hours Component Class.ls
 *              hh_entry_init/Cast External ParentScript 12 - Opening Hours Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { HotelClosingStatus, OpeningHoursState } from './types';
import { OpeningHoursInterface } from './OpeningHoursInterface';

export class OpeningHoursComponent extends BaseObject {
  private state: OpeningHoursState = {
    hotelClosingStatus: HotelClosingStatus.Open,
    hotelClosedDisconnectStatus: false,
  };

  construct(): void {
    super.construct();

    registerMessage('getHotelClosingStatus', this.id, 'getHotelClosingStatus');
    registerMessage('getHotelClosedDisconnectStatus', this.id, 'getHotelClosedDisconnectStatus');
    registerMessage('getAvailabilityTime', this.id, 'sendGetAvailabilityTime');
  }

  deconstruct(): void {
    unregisterMessage('getHotelClosingStatus', this.id);
    unregisterMessage('getHotelClosedDisconnectStatus', this.id);
    unregisterMessage('getAvailabilityTime', this.id);
    super.deconstruct();
  }

  /**
   * Get hotel closing status
   */
  getHotelClosingStatus(resultList?: Record<string, unknown>): number {
    const value = this.state.hotelClosingStatus === HotelClosingStatus.Closing ? 1 : 0;

    if (resultList) {
      resultList.retval = value;
      if (value && resultList.showDialog) {
        const iface = this.getInterface() as OpeningHoursInterface | null;
        if (iface) {
          iface.showHotelClosingNotice();
        }
      }
    }

    return value;
  }

  /**
   * Get hotel availability status
   */
  getHotelAvailabilityStatus(resultList?: Record<string, unknown>): number {
    const value = this.state.hotelClosingStatus === HotelClosingStatus.Closed ? 0 : 1;

    if (resultList) {
      resultList.retval = value;
    }

    return value;
  }

  /**
   * Get hotel closed disconnect status
   */
  getHotelClosedDisconnectStatus(resultList?: Record<string, unknown>): number {
    const value = this.state.hotelClosedDisconnectStatus ? 1 : 0;

    if (resultList) {
      resultList.retval = value;
    }

    return value;
  }

  /**
   * Set hotel closing status
   */
  setHotelClosingStatus(status: HotelClosingStatus): void {
    this.state.hotelClosingStatus = status;
  }

  /**
   * Set hotel as closed with disconnect notice
   */
  setHotelClosedDisconnect(openHour: number, openMinute: number): void {
    this.state.hotelClosingStatus = HotelClosingStatus.Closed;
    this.state.hotelClosedDisconnectStatus = true;
    this.state.openHour = openHour;
    this.state.openMinute = openMinute;

    const iface = this.getInterface() as OpeningHoursInterface | null;
    if (iface) {
      iface.showHotelClosedDisconnectNotice(openHour, openMinute);
    }
  }

  /**
   * Send request for availability time
   */
  sendGetAvailabilityTime(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('GET_AVAILABILITY_TIME');
    }
  }

  /**
   * Get current state
   */
  getState(): OpeningHoursState {
    return { ...this.state };
  }

  /**
   * Check if hotel is open
   */
  isHotelOpen(): boolean {
    return this.state.hotelClosingStatus === HotelClosingStatus.Open;
  }

  /**
   * Check if hotel is closing
   */
  isHotelClosing(): boolean {
    return this.state.hotelClosingStatus === HotelClosingStatus.Closing;
  }

  /**
   * Check if hotel is closed
   */
  isHotelClosed(): boolean {
    return this.state.hotelClosingStatus === HotelClosingStatus.Closed;
  }
}
