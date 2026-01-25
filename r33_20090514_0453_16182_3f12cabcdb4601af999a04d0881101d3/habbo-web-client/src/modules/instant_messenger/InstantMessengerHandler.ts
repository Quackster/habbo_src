/**
 * Instant Messenger Handler Class - Server message handlers
 *
 * Ported from: hh_instant_messenger/Cast External ParentScript 5 - Instant Messenger Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { executeMessage } from '../../core/MessageBus';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { IMMessages, IMCommands } from './types';
import { InstantMessengerComponent } from './InstantMessengerComponent';

export class InstantMessengerHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle incoming IM message
   */
  handleIMMessage(msg: HabboMessage): boolean {
    const conn = msg.connection as HabboConnection;
    if (!conn) return false;

    const senderId = String(conn.GetIntFrom(msg));
    const text = conn.GetStrFrom(msg);

    const component = this.getComponent() as InstantMessengerComponent | null;
    if (component) {
      component.receiveMessage(senderId, text);
    }

    return true;
  }

  /**
   * Handle incoming invitation
   */
  handleIMInvitation(msg: HabboMessage): boolean {
    const conn = msg.connection as HabboConnection;
    if (!conn) return false;

    const senderId = String(conn.GetIntFrom(msg));
    const text = conn.GetStrFrom(msg);

    const component = this.getComponent() as InstantMessengerComponent | null;
    if (component) {
      component.receiveInvitation(senderId, text);
    }

    return true;
  }

  /**
   * Handle IM error
   */
  handleIMError(msg: HabboMessage): boolean {
    const conn = msg.connection as HabboConnection;
    if (!conn) return false;

    const errorCode = conn.GetIntFrom(msg);
    const chatId = String(conn.GetIntFrom(msg));

    const component = this.getComponent() as InstantMessengerComponent | null;
    if (component) {
      component.receiveError(chatId, errorCode);
    }

    return true;
  }

  /**
   * Handle invitation error
   */
  handleInvitationError(msg: HabboMessage): boolean {
    const conn = msg.connection as HabboConnection;
    if (!conn) return false;

    const errorCode = conn.GetIntFrom(msg);

    executeMessage('alert', 'Invitation could not be sent');

    return true;
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [IMMessages.IM_MESSAGE]: 'handleIMMessage',
      [IMMessages.IM_INVITATION]: 'handleIMInvitation',
      [IMMessages.IM_ERROR]: 'handleIMError',
      [IMMessages.INVITATION_ERROR]: 'handleInvitationError',
    };

    const commands: Record<string, number> = {
      MESSENGER_SENDMSG: IMCommands.MESSENGER_SENDMSG,
      FRIEND_INVITE: IMCommands.FRIEND_INVITE,
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
