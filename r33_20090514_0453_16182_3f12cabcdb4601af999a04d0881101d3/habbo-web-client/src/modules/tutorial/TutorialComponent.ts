/**
 * Tutorial Component Class (NUH Component) - New User Help logic
 *
 * Ported from: hh_tutorial/Cast External ParentScript 4 - NUH Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { getVariable } from '../../core/VariableContainer';
import { getConnection } from '../../managers/ConnectionManager';
import {
  registerMessage,
  unregisterMessage,
  executeMessage,
} from '../../core/MessageBus';
import { HelpStatusData, TutorialCommands } from './types';
import { TutorialInterface } from './TutorialInterface';

/**
 * Tutorial component - manages new user help state
 */
export class TutorialComponent extends BaseObject {
  private helpStatusData: HelpStatusData = {};
  private postponedHelps: string[] = [];
  private openHelps: string[] = [];
  private invitationRoomID: number = 0;
  private inviting: boolean = false;
  private guidesFoundCount: number = 0;
  private guideList: number[] = [];
  private autoSelectGuide: boolean = true;
  private askingForSkip: boolean = false;
  private tutorialStructName: string = 'NUH.ids';

  // Timeouts storage
  private helpTimeouts: Map<string, ReturnType<typeof setTimeout>> = new Map();

  construct(): void {
    super.construct();

    this.helpStatusData = {};
    this.postponedHelps = [];
    this.openHelps = [];
    this.guideList = [];
    this.tutorialStructName = 'NUH.ids';
    this.invitationRoomID = 0;
    this.inviting = false;
    this.autoSelectGuide = true;
    this.askingForSkip = false;

    // Register messages
    registerMessage('roomReady', this.id, 'initHelpOnRoomEntry');
    registerMessage('leaveRoom', this.id, 'removeHelp');
    registerMessage('changeRoom', this.id, 'removeHelp');
    registerMessage('enterRoom', this.id, 'removeHelp');
    registerMessage('roomInterfaceHidden', this.id, 'removeHelp');
    registerMessage('NUH_close', this.id, 'setHelpItemClosed');
  }

  deconstruct(): void {
    // Unregister messages
    unregisterMessage('roomReady', this.id);
    unregisterMessage('leaveRoom', this.id);
    unregisterMessage('changeRoom', this.id);
    unregisterMessage('enterRoom', this.id);
    unregisterMessage('roomInterfaceHidden', this.id);
    unregisterMessage('NUH_close', this.id);

    // Clear all timeouts
    for (const timeout of this.helpTimeouts.values()) {
      clearTimeout(timeout);
    }
    this.helpTimeouts.clear();

    super.deconstruct();
  }

  /**
   * Get help item key ID from name
   */
  getHelpItemKeyId(helpItemName: string): number | null {
    // Would look up from NUH.ids configuration
    // For now return null as it needs external config
    return null;
  }

  /**
   * Get help item name from key ID
   */
  getHelpItemName(keyId: number): string | null {
    // Would look up from NUH.ids configuration
    return null;
  }

  /**
   * Set help item as closed
   */
  setHelpItemClosed(helpItemName: string): void {
    if (!this.openHelps.includes(helpItemName)) {
      return;
    }

    if (this.helpStatusData[helpItemName] !== 1) {
      return;
    }

    this.helpStatusData[helpItemName] = 0;

    // Send to server
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    const key = this.getHelpItemKeyId(helpItemName);

    if (conn && key !== null && key !== 0) {
      conn.send('MSG_REMOVE_ACCOUNT_HELP_TEXT', { integer: key });
    }

    this.removeOpenHelp(helpItemName);

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.removeHelpBubble(helpItemName);
    }

    // Show postponed helps
    if (this.postponedHelps.length > 0) {
      let delay = 1000;
      for (const helpId of this.postponedHelps) {
        const timeoutId = `NUH_help_${helpId}_postponed`;
        const timeout = setTimeout(() => {
          this.tryToShowHelp(helpId);
        }, delay);
        this.helpTimeouts.set(timeoutId, timeout);
        delay += 100;
      }
      this.postponedHelps = [];
    }
  }

  /**
   * Remove from open helps list
   */
  private removeOpenHelp(helpId: string): void {
    const index = this.openHelps.indexOf(helpId);
    if (index > -1) {
      this.openHelps.splice(index, 1);
    }
  }

  /**
   * Set help status data from server
   */
  setHelpStatusData(data: HelpStatusData): void {
    this.helpStatusData = data;
  }

  /**
   * Close invitation dialog
   */
  closeInvitation(result: 'yes' | 'no' | 'never'): void {
    switch (result) {
      case 'yes':
        this.sendInvitations();
        break;
      case 'no':
        // Do nothing
        break;
      case 'never':
        this.setHelpItemClosed('invite');
        break;
    }

    this.removeOpenHelp('invite');

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.hideInvitationWindow();
    }
  }

  /**
   * Check if chat help is on
   */
  isChatHelpOn(): boolean {
    return this.helpStatusData['chat'] === 1;
  }

  /**
   * Initialize help on room entry
   */
  initHelpOnRoomEntry(): void {
    // Check if user is room owner
    // If so, show new user help items
    this.showNewUserHelpItems();
  }

  /**
   * Remove all help items
   */
  removeHelp(): void {
    // Clear all timeouts
    for (const [key, timeout] of this.helpTimeouts.entries()) {
      clearTimeout(timeout);
    }
    this.helpTimeouts.clear();

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.removeAll();
    }

    this.postponedHelps = [];
    this.openHelps = [];
  }

  /**
   * Show new user help items
   */
  showNewUserHelpItems(): void {
    for (const [itemName, itemOn] of Object.entries(this.helpStatusData)) {
      if (itemOn) {
        // Get timeout from configuration
        const timeout = 0; // Would be from config

        if (timeout === 0) {
          this.openHelps.push(itemName);
          continue;
        }

        const timeoutId = `NUH_help_${itemName}`;
        const timeoutHandle = setTimeout(() => {
          this.tryToShowHelp(itemName);
        }, timeout);
        this.helpTimeouts.set(timeoutId, timeoutHandle);
      }
    }
  }

  /**
   * Try to show help item
   */
  tryToShowHelp(helpId: string): void {
    // Check if we should postpone
    if (this.askingForSkip || this.inviting || this.openHelps.includes('own_user')) {
      this.postponeHelp(helpId);
      return;
    }

    const iface = this.getInterface() as TutorialInterface | null;
    if (!iface) return;

    switch (helpId) {
      case 'asktoshowhelp':
        iface.showSkipOrNotWindow(helpId);
        this.askingForSkip = true;
        this.openHelps.push(helpId);
        break;

      case 'own_user':
        iface.showOwnUserHelp(helpId);
        this.openHelps.push(helpId);
        break;

      case 'hand':
        // Only show if room owner
        iface.showGenericHelp(helpId);
        this.openHelps.push(helpId);
        break;

      case 'invite':
        // Only show if room owner
        this.checkHelpers();
        break;

      default:
        iface.showGenericHelp(helpId);
        this.openHelps.push(helpId);
    }

    // Show highlighter for single help item
    const infofeedHelps = this.openHelps.filter(
      (h) => h !== 'own_user' && h !== 'asktoshowhelp' && h !== 'chat'
    );

    if (infofeedHelps.length === 1) {
      iface.hideHighlighters();
      iface.showHighlighter(helpId);

      const key = this.getHelpItemKeyId(helpId);
      if (key !== null && key !== 0) {
        const connId = getVariable('connection.info.id', 'Info') as string;
        const conn = getConnection(connId);
        if (conn) {
          conn.send('MSG_REMOVE_ACCOUNT_HELP_TEXT', { integer: key });
        }
      }

      if (helpId === 'achievements') {
        this.handleAchievementsSelection();
      }
    }
  }

  /**
   * Postpone help item
   */
  private postponeHelp(helpId: string): void {
    if (!this.postponedHelps.includes(helpId)) {
      this.postponedHelps.push(helpId);
    }
  }

  /**
   * Check if tutors are available
   */
  checkHelpers(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('MSG_GET_TUTORS_AVAILABLE');
    }
  }

  /**
   * Show invite window
   */
  showInviteWindow(): void {
    this.openHelps.push('invite');

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.showInviteWindow();
    }
  }

  /**
   * Handle inviter left room
   */
  inviterLeftRoom(roomId: number): void {
    this.inviting = false;
    this.invitationRoomID = roomId;

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.showInvitationStatusWindow('room_left');
    }
  }

  /**
   * Go to invitation room
   */
  goToInvitationRoom(): void {
    if (this.invitationRoomID > 0) {
      executeMessage('roomForward', this.invitationRoomID, 'private');
    }
  }

  /**
   * Send tutor invitations
   */
  sendInvitations(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('MSG_INVITE_TUTORS');
    }
  }

  /**
   * Cancel tutor invitations
   */
  cancelInvitations(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('MSG_CANCEL_TUTOR_INVITATIONS');
    }
    this.inviting = false;
  }

  /**
   * Inviting started
   */
  invitingStarted(): void {
    this.inviting = true;
    this.guidesFoundCount = 0;

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.showInvitationStatusWindow('search');
    }
  }

  /**
   * Inviting completed
   */
  invitingCompleted(acceptCount: number): void {
    this.inviting = false;

    const state = acceptCount === 0 ? 'failure' : 'success';

    const iface = this.getInterface() as TutorialInterface | null;
    if (iface) {
      iface.showInvitationStatusWindow(state);
    }
  }

  /**
   * Invitation already exists
   */
  invitationExists(): void {
    executeMessage('alert', 'invitation_exists');
  }

  /**
   * Get guide count
   */
  getGuideCount(): number {
    return this.guidesFoundCount;
  }

  /**
   * Guide found
   */
  guideFound(accountId: number): void {
    this.guidesFoundCount++;
    this.guideList.push(accountId);
    registerMessage('create_user', this.id, 'createUserListener');
  }

  /**
   * Create user listener - called when a user is created in room
   */
  createUserListener(name: string, id: string): void {
    // Check if created user is a guide
    // Would need access to room component
  }

  /**
   * Handle achievements selection
   */
  private handleAchievementsSelection(): void {
    // Would select own user in room
  }

  /**
   * Set asking skip state
   */
  setAskingSkip(val: boolean): void {
    this.askingForSkip = val;
    if (!val) {
      this.setHelpItemClosed('asktoshowhelp');
    }
  }

  /**
   * Set tutorial as finished
   */
  setTutorialFinished(): void {
    if (this.tutorialStructName === 'NUH.finish') {
      return;
    }

    this.postponedHelps = [];

    if (this.askingForSkip) {
      this.setHelpItemClosed('asktoshowhelp');
      this.askingForSkip = false;
    }

    // Clear all current help items
    for (const helpId of Object.keys(this.helpStatusData)) {
      this.setHelpItemClosed(helpId);
      const timeoutId = `NUH_help_${helpId}`;
      const timeout = this.helpTimeouts.get(timeoutId);
      if (timeout) {
        clearTimeout(timeout);
        this.helpTimeouts.delete(timeoutId);
      }
    }

    // Switch to finish structure
    this.tutorialStructName = 'NUH.finish';
    this.helpStatusData = {};

    // Would load finish help items from config
    this.showNewUserHelpItems();
  }

  /**
   * Get open helps
   */
  getOpenHelps(): string[] {
    return [...this.openHelps];
  }

  /**
   * Is inviting
   */
  isInviting(): boolean {
    return this.inviting;
  }
}
