/**
 * Entry Component - Business logic for entry/login flow
 *
 * Ported from: hh_entry/Cast External ParentScript 4 - Entry Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { session } from '../../core/Session';
import { getConnection, createConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';

type EntryState = 'reset' | 'hotelView' | 'entryBar' | 'initialize';

export class EntryComponent extends BaseObject {
  private state: EntryState = 'reset';
  private okToLogin: boolean = true;

  construct(): void {
    super.construct();

    // Register for messages
    this.registerMsg('enterRoom', 'leaveEntry');
    this.registerMsg('leaveRoom', 'enterEntry');
    this.registerMsg('Initialize', 'updateState');
  }

  deconstruct(): void {
    unregisterMessage('enterRoom', this.id);
    unregisterMessage('leaveRoom', this.id);
    unregisterMessage('Initialize', this.id);

    this.updateState('reset');
    super.deconstruct();
  }

  /**
   * Called when entering the hotel view (leaving a room)
   */
  enterEntry(): boolean {
    this.updateState('hotelView');
    this.updateState('entryBar');
    return true;
  }

  /**
   * Called when leaving entry (entering a room)
   */
  leaveEntry(): boolean {
    return this.updateState('reset');
  }

  /**
   * Get current state
   */
  getState(): EntryState {
    return this.state;
  }

  /**
   * Update the entry state
   */
  updateState(newState: EntryState | string): boolean {
    const iface = this.getInterface<EntryInterface>();

    switch (newState) {
      case 'reset':
        this.state = 'reset';
        return iface?.hideAll() ?? false;

      case 'hotelView':
      case 'initialize':
        this.state = newState as EntryState;
        return iface?.showHotel() ?? false;

      case 'entryBar':
        this.state = 'entryBar';
        return iface?.showEntryBar() ?? false;

      default:
        console.warn(`EntryComponent: Unknown state: ${newState}`);
        return false;
    }
  }

  /**
   * Initialize connection to server
   */
  initConnection(host: string, port: number): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const connection = createConnection(connId, host, port);
    if (!connection) {
      console.error('EntryComponent: Failed to create connection');
      return false;
    }

    return true;
  }

  /**
   * Send login request
   */
  sendLogin(connection: unknown): void {
    if (!this.okToLogin) {
      return;
    }

    const username = session.GET<string>('userName') ?? '';
    const password = session.GET<string>('Password') ?? '';

    if (username && password) {
      // Regular login
      (connection as { send: (cmd: string, params: unknown) => void }).send('TRY_LOGIN', {
        string: username,
        string2: password,
      });
    } else {
      // SSO login
      const ssoTicket = session.GET<string>('sso.ticket');
      if (ssoTicket) {
        (connection as { send: (cmd: string, params: unknown) => void }).send('SSO', {
          string: ssoTicket,
        });
      }
    }
  }

  /**
   * Handle disconnect
   */
  disconnect(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const connection = getConnection(connId);
    if (connection) {
      connection.disconnect(true);
    }
  }

  /**
   * Set OK to login flag
   */
  setOkToLogin(value: boolean): void {
    this.okToLogin = value;
  }
}

// Interface placeholder (will be in separate file)
interface EntryInterface {
  hideAll(): boolean;
  showHotel(): boolean;
  showEntryBar(): boolean;
}
