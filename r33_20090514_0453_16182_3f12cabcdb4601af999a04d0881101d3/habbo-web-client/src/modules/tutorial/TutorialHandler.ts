/**
 * Tutorial Handler Class (NUH Handler) - Server message handlers
 *
 * Ported from: hh_tutorial/Cast External ParentScript 5 - NUH Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import {
  registerListener,
  registerCommands,
  unregisterListener,
  unregisterCommands,
} from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { TutorialMessages, TutorialCommands, HelpStatusData } from './types';
import { TutorialComponent } from './TutorialComponent';

/**
 * Tutorial handler - processes server messages
 */
export class TutorialHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle help items message
   */
  handleHelpItems(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const idCount = conn.GetIntFrom(msg);
    const data: HelpStatusData = {};

    for (let i = 0; i < idCount; i++) {
      const keyId = conn.GetIntFrom(msg);
      const component = this.getComponent() as TutorialComponent | null;
      const key = component?.getHelpItemName(keyId);

      if (key) {
        data[key] = 1;
      }
    }

    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.setHelpStatusData(data);
    }
  }

  /**
   * Handle tutors available message
   */
  handleTutorsAvailable(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const areAvailable = conn.GetIntFrom(msg);
    if (!areAvailable) {
      return;
    }

    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.showInviteWindow();
    }
  }

  /**
   * Handle inviting completed message
   */
  handleInvitingCompleted(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const acceptCount = conn.GetIntFrom(msg);

    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.invitingCompleted(acceptCount);
    }
  }

  /**
   * Handle invitation exists message
   */
  handleInvitationExists(msg: HabboMessage): void {
    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.invitationExists();
    }
  }

  /**
   * Handle invitation sent message
   */
  handleInvitationSent(): void {
    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.invitingStarted();
    }
  }

  /**
   * Handle guide found message
   */
  handleGuideFound(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const accountId = conn.GetIntFrom(msg);

    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.guideFound(accountId);
    }
  }

  /**
   * Handle inviter left room message
   */
  handleInviterLeftRoom(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const roomId = conn.GetIntFrom(msg);

    const component = this.getComponent() as TutorialComponent | null;
    if (component) {
      component.inviterLeftRoom(roomId);
    }
  }

  /**
   * Register/unregister message listeners
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [TutorialMessages.HELP_ITEMS]: 'handleHelpItems',
      [TutorialMessages.TUTORS_AVAILABLE]: 'handleTutorsAvailable',
      [TutorialMessages.INVITING_COMPLETED]: 'handleInvitingCompleted',
      [TutorialMessages.INVITATION_EXISTS]: 'handleInvitationExists',
      [TutorialMessages.INVITATION_SENT]: 'handleInvitationSent',
      [TutorialMessages.GUIDE_FOUND]: 'handleGuideFound',
      [TutorialMessages.INVITER_LEFT_ROOM]: 'handleInviterLeftRoom',
    };

    const commands: Record<string, number> = {
      MSG_REMOVE_ACCOUNT_HELP_TEXT: TutorialCommands.REMOVE_ACCOUNT_HELP_TEXT,
      MSG_GET_TUTORS_AVAILABLE: TutorialCommands.GET_TUTORS_AVAILABLE,
      MSG_INVITE_TUTORS: TutorialCommands.INVITE_TUTORS,
      MSG_CANCEL_TUTOR_INVITATIONS: TutorialCommands.CANCEL_TUTOR_INVITATIONS,
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
