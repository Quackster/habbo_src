/**
 * Opening Hours Handler Class - Server message handlers for hotel availability
 *
 * Ported from: hh_entry/Cast External ParentScript 13 - Opening Hours Handler Class.ls
 *              hh_entry_init/Cast External ParentScript 13 - Opening Hours Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { executeMessage } from '../../core/MessageBus';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { HotelClosingStatus, OpeningHoursMessages, OpeningHoursCommands } from './types';
import { OpeningHoursComponent } from './OpeningHoursComponent';
import { OpeningHoursInterface } from './OpeningHoursInterface';

export class OpeningHoursHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    // Incoming message handlers
    const messages: Record<number, string> = {
      [OpeningHoursMessages.AVAILABILITY_STATUS]: 'handleAvailabilityStatus',
      [OpeningHoursMessages.INFO_HOTEL_CLOSING]: 'handleInfoHotelClosing',
      [OpeningHoursMessages.INFO_HOTEL_CLOSED]: 'handleInfoHotelClosed',
      [OpeningHoursMessages.AVAILABILITY_TIME]: 'handleAvailabilityTime',
      [OpeningHoursMessages.LOGIN_FAILED_HOTEL_CLOSED]: 'handleLoginFailedHotelClosed',
    };

    // Outgoing command IDs
    const commands: Record<string, number> = {
      GET_AVAILABILITY_TIME: OpeningHoursCommands.GET_AVAILABILITY_TIME,
    };

    if (register) {
      registerListener(connId, this.id, messages);
      registerCommands(connId, commands);
    } else {
      unregisterListener(connId, this.id, messages);
      unregisterCommands(connId, this.id, commands);
    }
  }

  /**
   * Handle availability status message
   * Message ID: 290
   */
  handleAvailabilityStatus(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;

    const isOpen = conn.GetIntFrom(msg) !== 0;
    const isShutDown = conn.GetIntFrom(msg) !== 0;

    let closingState = HotelClosingStatus.Open;
    if (!isOpen) {
      closingState = isShutDown ? HotelClosingStatus.Closing : HotelClosingStatus.Closed;
    }

    const component = this.getComponent() as OpeningHoursComponent | null;
    if (component) {
      component.setHotelClosingStatus(closingState);
    }
  }

  /**
   * Handle info hotel closing message (countdown notification)
   * Message ID: 291
   */
  handleInfoHotelClosing(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    const minutesUntil = conn.GetIntFrom(msg);

    const iface = this.getInterface() as OpeningHoursInterface | null;
    if (iface) {
      iface.showHotelClosingAlert(minutesUntil);
    }
  }

  /**
   * Handle info hotel closed message
   * Message ID: 292
   */
  handleInfoHotelClosed(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;

    const openHour = conn.GetIntFrom(msg);
    const openMinute = conn.GetIntFrom(msg);
    const disconnect = conn.GetIntFrom(msg) !== 0;

    if (disconnect) {
      const component = this.getComponent() as OpeningHoursComponent | null;
      if (component) {
        component.setHotelClosedDisconnect(openHour, openMinute);
      }
    } else {
      const iface = this.getInterface() as OpeningHoursInterface | null;
      if (iface) {
        iface.showHotelClosedNotice(openHour, openMinute);
      }
    }
  }

  /**
   * Handle availability time message
   * Message ID: 293
   */
  handleAvailabilityTime(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;

    const isOpen = conn.GetIntFrom(msg) !== 0;
    const timeUntil = conn.GetIntFrom(msg);

    executeMessage('hotelAvailabilityTime', isOpen, timeUntil);
  }

  /**
   * Handle login failed due to hotel closed message
   * Message ID: 294
   */
  handleLoginFailedHotelClosed(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;

    const openHour = conn.GetIntFrom(msg);
    const openMinute = conn.GetIntFrom(msg);

    const component = this.getComponent() as OpeningHoursComponent | null;
    if (component) {
      component.setHotelClosedDisconnect(openHour, openMinute);
    }
  }
}
