/**
 * Hobba Component Class - Moderation system (CFH handling)
 *
 * Ported from: hh_shared/Cast External ParentScript 4 - Hobba Component Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { CFHData, CFHType, CFHCategory, HobbaCommands } from '../types';
import { HobbaInterface } from './HobbaInterface';

/**
 * Hobba component - handles Call For Help (CFH) moderation
 */
export class HobbaComponent extends BaseObject {
  private pCryDataBase: Map<string, CFHData> = new Map();
  private iface: HobbaInterface | null = null;

  construct(): void {
    super.construct();
    this.pCryDataBase = new Map();

    // Would register for sendCallForHelp message
  }

  deconstruct(): void {
    this.pCryDataBase.clear();
    // Would unregister message
    super.deconstruct();
  }

  /**
   * Set interface reference
   */
  setInterface(iface: HobbaInterface): void {
    this.iface = iface;
  }

  /**
   * Get interface
   */
  getInterface(): HobbaInterface | null {
    return this.iface;
  }

  /**
   * Get pending CFHs from server
   */
  getPendingCFHs(): void {
    // Would send GET_PENDING_CALLS_FOR_HELP command
    this.emit('send_command', { command: HobbaCommands.GET_PENDING_CALLS });
  }

  /**
   * Receive cry for help
   */
  receiveCryForHelp(msg: CFHData): boolean {
    this.pCryDataBase.set(msg.cry_id, msg);
    this.iface?.showAlert();
    this.iface?.updateCryWindow();
    return true;
  }

  /**
   * Receive picked cry notification
   */
  receivePickedCry(msg: { cry_id: string; picker: string; block?: boolean }): boolean {
    const cry = this.pCryDataBase.get(msg.cry_id);
    if (!cry) {
      return false;
    }

    cry.picker = msg.picker;
    cry.block = msg.block;
    this.iface?.updateCryWindow();
    return true;
  }

  /**
   * Delete cry from database
   */
  deleteCry(cryId: string): boolean {
    this.pCryDataBase.delete(cryId);

    if (this.pCryDataBase.size === 0) {
      this.iface?.hideAlert();
    }

    this.iface?.updateCryWindow();
    return true;
  }

  /**
   * Change CFH category (moderators <-> helpers)
   */
  sendChangeCFHType(cryId: string, categoryNum: number): boolean {
    let newCategory: number;

    if (categoryNum === CFHCategory.HELPERS) {
      newCategory = CFHCategory.MODERATORS;
      this.emit('alert', { msg: 'hobba_sent_to_moderators' });
    } else if (categoryNum === CFHCategory.MODERATORS) {
      newCategory = CFHCategory.HELPERS;
      this.emit('alert', { msg: 'hobba_sent_to_helpers' });
    } else {
      console.error(`Original category number illegal: ${categoryNum}`);
      return false;
    }

    // Would send CHANGECALLCATEGORY command
    this.emit('send_command', {
      command: HobbaCommands.CHANGE_CALL_CATEGORY,
      data: { cryId, category: newCategory },
    });

    return true;
  }

  /**
   * Pick a cry for help
   */
  sendCryPick(cryId: string, goHelp: boolean): boolean {
    // Send PICK_CRYFORHELP command
    this.emit('send_command', {
      command: HobbaCommands.PICK_CRY,
      data: { cryId, block: 0 },
    });

    if (goHelp) {
      const data = this.pCryDataBase.get(cryId);
      if (!data) {
        return false;
      }

      // Validate data
      const isValid = (
        typeof data.picker === 'string' &&
        typeof data.url_id === 'string' &&
        typeof data.roomname === 'string' &&
        typeof data.cry_id === 'string' &&
        typeof data.type === 'string' &&
        typeof data.msg === 'string'
      );

      if (!isValid) {
        console.error('Invalid or missing data in saved help cry!');
        return false;
      }

      // Emit event to go help
      this.emit('go_help', { cryId, data });

      // Send FOLLOW_CRYFORHELP command
      this.emit('send_command', {
        command: HobbaCommands.FOLLOW_CRY,
        data: { cryId },
      });
    }

    return true;
  }

  /**
   * Block a cry for help
   */
  sendBlockCFH(cryId: string): void {
    this.emit('send_command', {
      command: HobbaCommands.PICK_CRY,
      data: { cryId, block: 1 },
    });
  }

  /**
   * Send a cry for help
   */
  sendCryForHelp(message: string, type: CFHType): boolean {
    // Sanitize message
    let msg = message.replace(/\//g, ' ');
    msg = msg.replace(/\n/g, '<br>');

    // Determine send type
    let sendType: number;
    if (type === 'habbo_helpers') {
      sendType = CFHCategory.HELPERS;
    } else if (type === 'emergency') {
      sendType = CFHCategory.MODERATORS;
    } else {
      console.error('Illegal type for CFH!');
      return false;
    }

    // Send CALL_FOR_HELP command
    this.emit('send_command', {
      command: HobbaCommands.CALL_FOR_HELP,
      data: { message: msg, type: sendType },
    });

    return true;
  }

  /**
   * Send reply to CFH
   */
  sendCFHReply(cryId: string, message: string): boolean {
    // Add line breaks for long messages
    let msg = '';
    let charsCounted = 0;

    for (const char of message) {
      charsCounted++;
      if (charsCounted > 45 && char === ' ') {
        msg += '<br>';
        charsCounted = 0;
      } else {
        msg += char;
      }
    }

    msg = msg.replace(/\n/g, '<br>');

    // Send MESSAGETOCALLER command
    this.emit('send_command', {
      command: HobbaCommands.MESSAGE_TO_CALLER,
      data: { cryId, message: msg },
    });

    return true;
  }

  /**
   * Get cry database
   */
  getCryDataBase(): Map<string, CFHData> {
    return this.pCryDataBase;
  }

  /**
   * Get cry by ID
   */
  getCry(cryId: string): CFHData | undefined {
    return this.pCryDataBase.get(cryId);
  }

  /**
   * Clear cry database
   */
  clearCryDataBase(): boolean {
    this.pCryDataBase.clear();
    return true;
  }

  /**
   * Get count of pending cries
   */
  getPendingCount(): number {
    return this.pCryDataBase.size;
  }
}
