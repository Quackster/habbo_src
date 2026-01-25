/**
 * Hobba Handler Class - Server message handling for moderation
 *
 * Ported from: hh_shared/Cast External ParentScript 5 - Hobba Handler Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { HobbaComponent } from './HobbaComponent';
import { HobbaInterface } from './HobbaInterface';
import { CFHData, HobbaMessages } from '../types';

/**
 * Message data from server
 */
interface MessageData {
  cry_id?: string;
  sender?: string;
  msg?: string;
  type?: string;
  room_id?: number;
  roomname?: string;
  url_id?: string;
  picker?: string;
  block?: boolean;
  casts?: string;
}

/**
 * Hobba handler - processes moderation messages
 */
export class HobbaHandler extends BaseObject {
  private component: HobbaComponent | null = null;
  private iface: HobbaInterface | null = null;

  construct(): void {
    super.construct();
    this.registerMessages(true);
  }

  deconstruct(): void {
    this.registerMessages(false);
    super.deconstruct();
  }

  /**
   * Set component reference
   */
  setComponent(component: HobbaComponent): void {
    this.component = component;
  }

  /**
   * Get component
   */
  getComponent(): HobbaComponent | null {
    return this.component;
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
   * Handle incoming cry for help
   */
  handleCryForHelp(msg: MessageData): void {
    const cfhData: CFHData = {
      cry_id: msg.cry_id || '',
      sender: msg.sender || '',
      msg: msg.msg || '',
      type: (msg.type as CFHData['type']) || 'public',
      room_id: msg.room_id || 0,
      roomname: msg.roomname || '',
      url_id: msg.url_id || '',
    };

    // Parse casts if string
    if (typeof msg.casts === 'string') {
      cfhData.casts = msg.casts.split(',').map((c) => c.trim());
    }

    this.component?.receiveCryForHelp(cfhData);
  }

  /**
   * Handle cry picked notification
   */
  handleCryPicked(msg: MessageData): void {
    this.component?.receivePickedCry({
      cry_id: msg.cry_id || '',
      picker: msg.picker || '',
      block: msg.block,
    });
  }

  /**
   * Handle cry deleted notification
   */
  handleCryDeleted(msg: MessageData): void {
    if (msg.cry_id) {
      this.component?.deleteCry(msg.cry_id);
    }
  }

  /**
   * Register/unregister message handlers
   */
  private registerMessages(register: boolean): void {
    // Would register handlers for CFH messages
    if (register) {
      this.emit('handlers_registered', {
        [HobbaMessages.CRY_FOR_HELP]: this.handleCryForHelp.bind(this),
        [HobbaMessages.CRY_PICKED]: this.handleCryPicked.bind(this),
        [HobbaMessages.CRY_DELETED]: this.handleCryDeleted.bind(this),
      });
    } else {
      this.emit('handlers_unregistered');
    }
  }
}
