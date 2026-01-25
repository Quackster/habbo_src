/**
 * Club Handler Class - Server message handlers for Habbo Club
 *
 * Ported from: hh_club/Cast External ParentScript 4 - Club Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { ClubStatus, ClubMessages, ClubCommands } from './types';
import { ClubComponent } from './ClubComponent';

export class ClubHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle OK message - request club info
   */
  handleOk(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    conn.send('SCR_GET_USER_INFO', { string: 'club_habbo' });
  }

  /**
   * Handle SCR_SINFO - club status info
   */
  handleScrSinfo(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const productName = conn.GetStrFrom(msg);
    const daysLeft = conn.GetIntFrom(msg);
    const elapsedPeriods = conn.GetIntFrom(msg);
    const prepaidPeriods = conn.GetIntFrom(msg);
    const responseFlag = conn.GetIntFrom(msg);

    const status: ClubStatus = {
      productName,
      daysLeft,
      elapsedPeriods,
      prepaidPeriods,
    };

    const component = this.getComponent() as ClubComponent | null;
    if (component) {
      component.setStatus(status, responseFlag);
    }
  }

  /**
   * Handle SCR_GIFT - club gift notification
   */
  handleGift(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const giftCount = conn.GetIntFrom(msg);

    const component = this.getComponent() as ClubComponent | null;
    if (component) {
      component.showGifts(giftCount);
    }
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [ClubMessages.OK]: 'handleOk',
      [ClubMessages.SCR_SINFO]: 'handleScrSinfo',
      [ClubMessages.SCR_GIFT]: 'handleGift',
    };

    const commands: Record<string, number> = {
      SCR_GET_USER_INFO: ClubCommands.SCR_GET_USER_INFO,
      SCR_BUY: ClubCommands.SCR_BUY,
      SCR_GIFT_APPROVAL: ClubCommands.SCR_GIFT_APPROVAL,
    };

    if (register) {
      registerListener(connId, this.id, messages);
      registerCommands(connId, commands);
    } else {
      unregisterListener(connId, this.id, messages);
      unregisterCommands(connId, this.id, commands);
    }
  }
}
