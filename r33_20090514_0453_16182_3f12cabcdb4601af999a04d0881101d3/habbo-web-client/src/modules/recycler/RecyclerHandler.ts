/**
 * Recycler Handler Class - Server message handlers
 *
 * Ported from: hh_recycler/Cast External ParentScript 5 - Recycler Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { RecyclerState, RecyclerMessages, RecyclerCommands } from './types';
import { RecyclerComponent } from './RecyclerComponent';

export class RecyclerHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle recycler status message
   */
  handleRecyclerStatus(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const stateCode = conn.GetIntFrom(msg);
    let state: RecyclerState;
    let timeout: number | undefined;

    switch (stateCode) {
      case 1:
        state = 'open';
        break;
      case 2:
        state = 'closed';
        break;
      case 3:
        state = 'timeout';
        timeout = conn.GetIntFrom(msg);
        break;
      default:
        state = 'closed';
    }

    const component = this.getComponent() as RecyclerComponent | null;
    if (component) {
      component.setState(state, timeout);
    }
  }

  /**
   * Handle recycling finished message
   */
  handleRecyclerFinished(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const success = conn.GetIntFrom(msg) === 1;
    const prizeId = conn.GetIntFrom(msg);

    const component = this.getComponent() as RecyclerComponent | null;
    if (component) {
      component.recyclingFinished(success);
    }
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.room.id', 'Room') as string;

    const messages: Record<number, string> = {
      [RecyclerMessages.RECYCLER_STATUS]: 'handleRecyclerStatus',
      [RecyclerMessages.RECYCLER_FINISHED]: 'handleRecyclerFinished',
    };

    const commands: Record<string, number> = {
      GET_RECYCLER_STATUS: RecyclerCommands.GET_RECYCLER_STATUS,
      RECYCLE_ITEMS: RecyclerCommands.RECYCLE_ITEMS,
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
