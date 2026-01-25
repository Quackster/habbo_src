/**
 * Poll Handler Class - Server message handlers
 *
 * Ported from: hh_poll/Cast External ParentScript 5 - Poll Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import { PollQuestion, PollOffer, PollQuestionType, PollMessages, PollCommands } from './types';
import { PollComponent } from './PollComponent';

export class PollHandler extends BaseObject {
  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Handle poll offer message
   */
  handlePollOffer(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const pollId = conn.GetIntFrom(msg);
    const pollDescription = conn.GetStrFrom(msg);

    const offer: PollOffer = {
      pollID: pollId,
      pollDescription,
    };

    const component = this.getComponent() as PollComponent | null;
    if (component) {
      component.offerPoll(offer);
    }
  }

  /**
   * Handle poll contents message
   */
  handlePollContents(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const pollId = conn.GetIntFrom(msg);
    const pollHeadLine = conn.GetStrFrom(msg);
    const pollThankYou = conn.GetStrFrom(msg);

    const component = this.getComponent() as PollComponent | null;
    if (component) {
      component.setThanks(pollThankYou);
    }

    const questionCount = conn.GetIntFrom(msg);

    for (let i = 0; i < questionCount; i++) {
      const question: PollQuestion = {
        pollID: pollId,
        pollHeadLine,
        questionID: conn.GetIntFrom(msg),
        questionNumber: conn.GetIntFrom(msg),
        questionCount,
        questionType: conn.GetIntFrom(msg) as PollQuestionType,
        questionText: conn.GetStrFrom(msg),
      };

      // Parse selection data for multiple choice questions
      if (question.questionType === PollQuestionType.SINGLE_SELECT || question.questionType === PollQuestionType.MULTI_SELECT) {
        const selectionCount = conn.GetIntFrom(msg);
        const minSelect = conn.GetIntFrom(msg);
        const maxSelect = conn.GetIntFrom(msg);

        const questions: string[] = [];
        for (let j = 0; j < selectionCount; j++) {
          questions.push(conn.GetStrFrom(msg));
        }

        question.selectionData = {
          minSelect,
          maxSelect,
          questions,
        };
      }

      if (component) {
        component.parseQuestion(question);
      }
    }
  }

  /**
   * Handle poll error message
   */
  handlePollError(msg: HabboMessage): void {
    const component = this.getComponent() as PollComponent | null;
    if (component) {
      component.pollError();
    }
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [PollMessages.POLL_OFFER]: 'handlePollOffer',
      [PollMessages.POLL_CONTENTS]: 'handlePollContents',
      [PollMessages.POLL_ERROR]: 'handlePollError',
    };

    const commands: Record<string, number> = {
      POLL_START: PollCommands.POLL_START,
      POLL_REJECT: PollCommands.POLL_REJECT,
      POLL_ANSWER: PollCommands.POLL_ANSWER,
      POLL_CANCEL: PollCommands.POLL_CANCEL,
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
