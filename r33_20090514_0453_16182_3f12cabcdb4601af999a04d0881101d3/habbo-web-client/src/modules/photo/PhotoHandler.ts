/**
 * Photo Handler Class - Server message handlers
 *
 * Ported from: hh_photo/Cast External ParentScript 4 - Photo Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import {
  registerListener,
  unregisterListener,
} from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { executeMessage } from '../../core/MessageBus';
import { PhotoMessages } from './types';
import { PhotoComponent } from './PhotoComponent';

export class PhotoHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle film count message
   */
  handleFilm(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const filmCount = conn.GetIntFrom(msg);

    const component = this.getComponent() as PhotoComponent | null;
    if (component) {
      component.setFilm(filmCount);
    }

    // Update session data
    executeMessage('sessionSet', { key: 'user_photo_film', value: filmCount });
    executeMessage('updateFilmCount');
  }

  /**
   * Handle film count from MUS (multiuser server)
   */
  handleFilmMUS(msg: { content: string }): void {
    const filmCount = parseInt(msg.content, 10);

    const component = this.getComponent() as PhotoComponent | null;
    if (component) {
      component.setFilm(filmCount);
    }

    executeMessage('sessionSet', { key: 'user_photo_film', value: filmCount });
    executeMessage('updateFilmCount');
  }

  /**
   * Register/unregister message listeners
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [PhotoMessages.FILM_COUNT]: 'handleFilm',
    };

    if (register) {
      registerListener(connId, this.id, messages);
    } else {
      unregisterListener(connId, this.id, messages);
    }
  }
}
