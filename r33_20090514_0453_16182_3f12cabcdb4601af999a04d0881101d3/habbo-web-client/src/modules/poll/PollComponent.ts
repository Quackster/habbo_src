/**
 * Poll Component Class - Business logic for polls/surveys
 *
 * Ported from: hh_poll/Cast External ParentScript 4 - Poll Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { PollQuestion, PollOffer, PollQuestionType, PollSelectionData } from './types';
import { PollInterface } from './PollInterface';

export class PollComponent extends BaseObject {
  private questionList: PollQuestion[] = [];
  private questionIndex: number = 0;
  private confirmedAction: string = '';
  private pollOfferId: number = 0;
  private thanksText: string = '';

  construct(): void {
    super.construct();
    registerMessage('show_poll_question', this.id, 'parseQuestion');
  }

  deconstruct(): void {
    unregisterMessage('show_poll_question', this.id);
    super.deconstruct();
  }

  /**
   * Check if question is available
   */
  getQuestionAvailable(): boolean {
    return this.questionList.length > this.questionIndex;
  }

  /**
   * Navigate to next/previous question
   */
  getNewQuestion(next: boolean): void {
    if (next) {
      if (this.questionIndex < this.questionList.length - 1) {
        this.questionIndex++;
      }
    } else {
      if (this.questionIndex > 0) {
        this.questionIndex--;
      }
    }
  }

  /**
   * Get poll headline
   */
  getPollHeadLine(): string {
    return this.getQuestionData('pollHeadLine') as string ?? '';
  }

  /**
   * Get question text
   */
  getQuestionText(): string {
    return this.getQuestionData('questionText') as string ?? '';
  }

  /**
   * Get current question number
   */
  getQuestionNumber(): number {
    return this.getQuestionData('questionNumber') as number ?? 0;
  }

  /**
   * Get total question count
   */
  getQuestionCount(): number {
    return this.getQuestionData('questionCount') as number ?? 0;
  }

  /**
   * Get question type
   */
  getQuestionType(): PollQuestionType {
    return this.getQuestionData('questionType') as PollQuestionType ?? PollQuestionType.FREE_TEXT;
  }

  /**
   * Get selection count for multiple choice
   */
  getSelectionCount(): number {
    const selectionData = this.getQuestionData('selectionData') as PollSelectionData | undefined;
    return selectionData?.questions?.length ?? 0;
  }

  /**
   * Get minimum selection count
   */
  getSelectionMinCount(): number {
    const selectionData = this.getQuestionData('selectionData') as PollSelectionData | undefined;
    return selectionData?.minSelect ?? 0;
  }

  /**
   * Get maximum selection count
   */
  getSelectionMaxCount(): number {
    const selectionData = this.getQuestionData('selectionData') as PollSelectionData | undefined;
    return selectionData?.maxSelect ?? 0;
  }

  /**
   * Get selection text at index
   */
  getSelectionText(index: number): string {
    const selectionData = this.getQuestionData('selectionData') as PollSelectionData | undefined;
    if (!selectionData?.questions) return '';
    if (index < 0 || index >= selectionData.questions.length) return '';
    return selectionData.questions[index];
  }

  /**
   * Get selection state at index
   */
  getSelectionState(index: number): number {
    const selections = this.getQuestionData('answerSelections') as number[] | undefined;
    if (!selections) return 0;
    if (index < 0 || index >= selections.length) return 0;
    return selections[index];
  }

  /**
   * Change selection state
   */
  changeSelectionState(index: number): boolean {
    const question = this.questionList[this.questionIndex];
    if (!question?.answerSelections) return false;

    const selections = question.answerSelections;
    if (index < 0 || index >= selections.length) return false;

    const maxSelect = this.getSelectionMaxCount();

    if (maxSelect === 1) {
      // Single select - clear all and select this one
      for (let i = 0; i < selections.length; i++) {
        selections[i] = 0;
      }
      selections[index] = 1;
    } else {
      // Multi select - toggle
      const newState = selections[index] === 0 ? 1 : 0;
      const currentCount = selections.filter((s) => s !== 0).length;

      if (currentCount + newState > maxSelect) {
        return false;
      }

      selections[index] = newState;
    }

    return true;
  }

  /**
   * Set answer text
   */
  setAnswerText(text: string): boolean {
    if (this.questionIndex >= this.questionList.length) return false;
    this.questionList[this.questionIndex].answerText = text;
    return true;
  }

  /**
   * Get answer text
   */
  getAnswerText(): string {
    return this.getQuestionData('answerText') as string ?? '';
  }

  /**
   * Get thanks text
   */
  getThanks(): string {
    return this.thanksText;
  }

  /**
   * Set thanks text
   */
  setThanks(text: string): void {
    this.thanksText = text;
  }

  /**
   * Confirm action
   */
  confirmAction(action: string): boolean {
    this.confirmedAction = action;
    return true;
  }

  /**
   * Handle confirmed action
   */
  actionConfirmed(): void {
    if (this.confirmedAction === 'cancel') {
      this.cancelAnswer();
      const iface = this.getInterface() as PollInterface | null;
      if (iface) {
        iface.hideQuestion();
      }
    }
  }

  /**
   * Send answer
   */
  sendAnswer(): boolean {
    if (!this.getQuestionAvailable()) return false;

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    const totalQuestions = this.questionIndex + 1;

    for (let idx = 0; idx < totalQuestions; idx++) {
      this.questionIndex = 0;
      const pollId = this.getQuestionData('pollID') as number;
      const questionId = this.getQuestionData('questionID') as number;
      const questionType = this.getQuestionType();

      const reply: (number | string)[] = [pollId, questionId];

      if (questionType === PollQuestionType.SINGLE_SELECT || questionType === PollQuestionType.MULTI_SELECT) {
        const selectionCount = this.getSelectionCount();
        const minSelect = this.getSelectionMinCount();

        let selected = 0;
        const selections: number[] = [];

        for (let i = 0; i < selectionCount; i++) {
          const state = this.getSelectionState(i);
          if (state !== 0) {
            selected++;
            selections.push(i + 1); // 1-indexed
          }
        }

        if (selected < minSelect) {
          this.questionIndex = totalQuestions - (idx + 1);
          return false;
        }

        reply.push(selected);
        reply.push(...selections);
      } else {
        const answerText = this.getAnswerText();
        if (answerText.length === 0) {
          this.questionIndex = totalQuestions - (idx + 1);
          return false;
        }
        reply.push(answerText);
      }

      conn.send('POLL_ANSWER', { values: reply });
      this.questionList.shift();
    }

    this.questionIndex = 0;
    return true;
  }

  /**
   * Cancel answer
   */
  cancelAnswer(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return;

    let lastPollId: number | null = null;

    for (let i = 0; i < this.questionList.length; i++) {
      this.questionIndex = i;
      const pollId = this.getQuestionData('pollID') as number;
      const questionId = this.getQuestionData('questionID') as number;

      if (pollId !== lastPollId) {
        lastPollId = pollId;
        conn.send('POLL_CANCEL', { integers: [pollId, questionId] });
      }
    }

    this.questionList = [];
    this.questionIndex = 0;
  }

  /**
   * Get question data property
   */
  private getQuestionData(property: keyof PollQuestion): unknown {
    if (this.questionIndex >= this.questionList.length) return undefined;
    return this.questionList[this.questionIndex][property];
  }

  /**
   * Offer poll to user
   */
  offerPoll(data: PollOffer): void {
    this.pollOfferId = data.pollID;
    const iface = this.getInterface() as PollInterface | null;
    if (iface) {
      iface.showOffer(data.pollDescription);
    }
  }

  /**
   * Accept poll offer
   */
  acceptPoll(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('POLL_START', { integer: this.pollOfferId });
    }
  }

  /**
   * Reject poll offer
   */
  rejectPoll(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('POLL_REJECT', { integer: this.pollOfferId });
    }
  }

  /**
   * Parse incoming question
   */
  parseQuestion(data: PollQuestion): void {
    if (!this.validateQuestion(data)) return;

    // Initialize answer data
    data.answerText = '';
    data.answerSelections = [];

    const selectionCount = data.selectionData?.questions?.length ?? 0;
    for (let i = 0; i < selectionCount; i++) {
      data.answerSelections.push(0);
    }

    this.questionList.push(data);

    const iface = this.getInterface() as PollInterface | null;
    if (iface) {
      iface.showQuestion();
    }
  }

  /**
   * Validate question data
   */
  private validateQuestion(data: PollQuestion): boolean {
    const required: (keyof PollQuestion)[] = [
      'pollID',
      'pollHeadLine',
      'questionID',
      'questionNumber',
      'questionCount',
      'questionType',
      'questionText',
    ];

    for (const key of required) {
      if (data[key] === undefined) return false;
    }

    if (data.questionType === PollQuestionType.SINGLE_SELECT || data.questionType === PollQuestionType.MULTI_SELECT) {
      if (!data.selectionData) return false;
      if (!data.selectionData.questions || data.selectionData.questions.length === 0) return false;
      if (data.selectionData.maxSelect < 1) return false;
      if (data.selectionData.minSelect > data.selectionData.maxSelect) return false;
    }

    return true;
  }

  /**
   * Handle poll error
   */
  pollError(): void {
    const iface = this.getInterface() as PollInterface | null;
    if (iface) {
      iface.hideWindows();
      iface.showAlert('Server error occurred');
    }
  }

  /**
   * Get current question index
   */
  getCurrentQuestionIndex(): number {
    return this.questionIndex;
  }

  /**
   * Get question list
   */
  getQuestionList(): PollQuestion[] {
    return [...this.questionList];
  }
}
