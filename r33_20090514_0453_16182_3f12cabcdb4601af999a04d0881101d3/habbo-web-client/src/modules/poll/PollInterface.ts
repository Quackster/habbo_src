/**
 * Poll Interface Class - UI for polls/surveys
 *
 * Ported from: hh_poll/Cast External ParentScript 3 - Poll Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { executeMessage } from '../../core/MessageBus';
import { PollComponent } from './PollComponent';
import { PollQuestion } from './types';

export class PollInterface extends BaseInterface {
  private pOfferWindowId: string = 'poll_offer_window';
  private pQuestionWindowId: string = 'poll_question_window';

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Show poll offer dialog
   *
   * Lingo: createWindow(pOfferWindowID, "poll_offer.window", VOID, VOID, #modal)
   */
  async showOffer(description: string): Promise<void> {
    await this.createModalWindow(this.pOfferWindowId, 'poll_offer.window');
    this.registerWindowProcedure(this.pOfferWindowId, 'offerEventProc');

    // Set description text
    if (this.elementExists(this.pOfferWindowId, 'description_text')) {
      this.setText(this.pOfferWindowId, 'description_text', description);
    }
  }

  /**
   * Show question dialog
   *
   * Lingo: createWindow(pQuestionWindowID, "poll_question.window")
   */
  async showQuestion(): Promise<void> {
    const component = this.getComponent() as PollComponent | null;
    if (!component) return;

    const question = component.getCurrentQuestion();
    if (!question) return;

    if (!this.windowExists(this.pQuestionWindowId)) {
      await this.createWindow(this.pQuestionWindowId, 'poll_question.window');
      this.registerWindowProcedure(this.pQuestionWindowId, 'questionEventProc');
      this.centerWindow(this.pQuestionWindowId);
    }

    this.populateQuestion(question);
  }

  /**
   * Populate question UI
   */
  private populateQuestion(question: PollQuestion): void {
    if (!this.windowExists(this.pQuestionWindowId)) return;

    // Set question text
    if (this.elementExists(this.pQuestionWindowId, 'question_text')) {
      this.setText(this.pQuestionWindowId, 'question_text', question.text);
    }

    // Set question number
    const component = this.getComponent() as PollComponent | null;
    if (component && this.elementExists(this.pQuestionWindowId, 'question_number')) {
      const current = component.getCurrentQuestionIndex() + 1;
      const total = component.getTotalQuestions();
      this.setText(this.pQuestionWindowId, 'question_number', `Question ${current} of ${total}`);
    }

    // Setup answer options based on question type
    if (question.type === 'selection') {
      this.setupSelectionQuestion(question);
    } else if (question.type === 'text') {
      this.setupTextQuestion();
    }
  }

  /**
   * Setup selection question (radio/checkbox)
   */
  private setupSelectionQuestion(question: PollQuestion): void {
    if (!question.choices) return;

    // Hide text input
    if (this.elementExists(this.pQuestionWindowId, 'text_input')) {
      this.hideElement(this.pQuestionWindowId, 'text_input');
    }

    // Show choices
    for (let i = 0; i < question.choices.length; i++) {
      const choiceId = `choice_${i}`;
      if (this.elementExists(this.pQuestionWindowId, choiceId)) {
        this.setText(this.pQuestionWindowId, choiceId, question.choices[i]);
        this.showElement(this.pQuestionWindowId, choiceId);
      }
    }

    // Hide unused choice slots
    for (let i = question.choices.length; i < 10; i++) {
      const choiceId = `choice_${i}`;
      if (this.elementExists(this.pQuestionWindowId, choiceId)) {
        this.hideElement(this.pQuestionWindowId, choiceId);
      }
    }
  }

  /**
   * Setup text question
   */
  private setupTextQuestion(): void {
    // Hide choice options
    for (let i = 0; i < 10; i++) {
      const choiceId = `choice_${i}`;
      if (this.elementExists(this.pQuestionWindowId, choiceId)) {
        this.hideElement(this.pQuestionWindowId, choiceId);
      }
    }

    // Show text input
    if (this.elementExists(this.pQuestionWindowId, 'text_input')) {
      this.showElement(this.pQuestionWindowId, 'text_input');
      this.setText(this.pQuestionWindowId, 'text_input', '');
    }
  }

  /**
   * Hide question dialog
   *
   * Lingo: removeWindow(pQuestionWindowID)
   */
  hideQuestion(): void {
    this.removeWindow(this.pQuestionWindowId);
  }

  /**
   * Hide all windows
   *
   * Lingo: hideWindows()
   */
  hideWindows(): void {
    this.removeWindow(this.pOfferWindowId);
    this.removeWindow(this.pQuestionWindowId);
  }

  /**
   * Show alert message
   *
   * Lingo: showAlert(message)
   */
  showAlert(message: string): void {
    executeMessage('alert', { Msg: message });
  }

  /**
   * Offer window event procedure
   *
   * Lingo: offerEventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  offerEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as PollComponent | null;

    switch (spriteId) {
      case 'button_accept':
      case 'button_ok':
        if (component) {
          component.acceptPoll();
        }
        this.removeWindow(this.pOfferWindowId);
        break;
      case 'button_reject':
      case 'button_cancel':
      case 'close':
        if (component) {
          component.rejectPoll();
        }
        this.removeWindow(this.pOfferWindowId);
        break;
    }
  }

  /**
   * Question window event procedure
   *
   * Lingo: questionEventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  questionEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as PollComponent | null;

    switch (spriteId) {
      case 'button_next':
      case 'button_submit':
        if (component) {
          // Get selected answer(s)
          const question = component.getCurrentQuestion();
          if (question?.type === 'text') {
            const answer = this.getText(this.pQuestionWindowId, 'text_input');
            component.submitAnswer([answer]);
          } else {
            // Get selected choices
            const selectedChoices: string[] = [];
            for (let i = 0; i < 10; i++) {
              const choiceId = `choice_${i}`;
              if (this.elementExists(this.pQuestionWindowId, choiceId)) {
                const selected = this.getElementProperty(this.pQuestionWindowId, choiceId, 'selected');
                if (selected) {
                  selectedChoices.push(String(i));
                }
              }
            }
            component.submitAnswer(selectedChoices);
          }
        }
        break;
      case 'close':
        this.hideQuestion();
        break;
      default:
        // Handle choice selection
        if (spriteId.startsWith('choice_')) {
          const choiceIdx = parseInt(spriteId.replace('choice_', ''));
          if (!isNaN(choiceIdx)) {
            // Toggle selection
            const currentSelected = this.getElementProperty(this.pQuestionWindowId, spriteId, 'selected');
            this.setElementProperty(this.pQuestionWindowId, spriteId, 'selected', !currentSelected);
          }
        }
        break;
    }
  }

  /**
   * Get offer window ID
   */
  getOfferWindowId(): string {
    return this.pOfferWindowId;
  }

  /**
   * Get question window ID
   */
  getQuestionWindowId(): string {
    return this.pQuestionWindowId;
  }
}
