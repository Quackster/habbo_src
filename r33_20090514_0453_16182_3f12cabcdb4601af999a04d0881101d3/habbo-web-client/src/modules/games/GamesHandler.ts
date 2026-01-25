/**
 * Games Handler Class - Server message handlers
 *
 * Ported from: hh_games/Cast External ParentScript 4 - Games Handler Class.ls
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
import { GamesMessages, GamesCommands, GameProps, ItemMessage } from './types';
import { GamesComponent } from './GamesComponent';

/**
 * Games handler - processes server messages
 */
export class GamesHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle open game board message
   */
  handleOpenGameBoard(msg: HabboMessage): void {
    const content = msg.content as string;
    const lines = content.split('\n');
    const firstLine = lines[0];

    // Parse using tab or semicolon delimiter
    const delim = firstLine.includes('\t') ? '\t' : ';';
    const items = firstLine.split(delim);

    const props: GameProps = {
      id: items[0],
      name: items[1] as GameProps['name'],
      data: content,
    };

    const component = this.getComponent() as GamesComponent | null;
    if (component) {
      component.openGameBoard(props);
    }
  }

  /**
   * Handle close game board message
   */
  handleCloseGameBoard(msg: HabboMessage): void {
    const content = msg.content as string;
    const lines = content.split('\n');
    const firstLine = lines[0];

    const delim = firstLine.includes('\t') ? '\t' : ';';
    const items = firstLine.split(delim);

    const props = {
      id: items[0],
      name: items[1] as GameProps['name'],
      data: content,
    };

    const component = this.getComponent() as GamesComponent | null;
    if (component) {
      component.closeGameBoard(props);
    }
  }

  /**
   * Handle item message
   */
  handleItemMsg(msg: HabboMessage): void {
    const content = msg.content as string;
    const lines = content.split('\n');

    const itemMsg: ItemMessage = {
      id: lines[0],
      command: lines[1] || '',
      data: lines.slice(2).join('\n'),
    };

    const component = this.getComponent() as GamesComponent | null;
    if (component) {
      component.processItemMessage(itemMsg);
    }
  }

  /**
   * Register/unregister message listeners
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.room.id') as string;

    const messages: Record<number, string> = {
      [GamesMessages.ITEM_MSG]: 'handleItemMsg',
      [GamesMessages.OPEN_GAMEBOARD]: 'handleOpenGameBoard',
      [GamesMessages.CLOSE_GAMEBOARD]: 'handleCloseGameBoard',
    };

    const commands: Record<string, number> = {
      IIM: GamesCommands.IIM,
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
