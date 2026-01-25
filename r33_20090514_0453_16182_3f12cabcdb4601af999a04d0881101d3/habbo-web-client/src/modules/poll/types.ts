/**
 * Poll Types
 *
 * Ported from: hh_poll/*.ls
 */

/**
 * Poll question types
 */
export enum PollQuestionType {
  SINGLE_SELECT = 1,
  MULTI_SELECT = 2,
  FREE_TEXT = 3,
  LONG_TEXT = 4,
}

/**
 * Selection data for multiple choice questions
 */
export interface PollSelectionData {
  minSelect: number;
  maxSelect: number;
  questions: string[];
}

/**
 * Poll question data
 */
export interface PollQuestion {
  pollID: number;
  pollHeadLine: string;
  questionID: number;
  questionNumber: number;
  questionCount: number;
  questionType: PollQuestionType;
  questionText: string;
  selectionData?: PollSelectionData;
  answerText?: string;
  answerSelections?: number[];
}

/**
 * Poll offer data
 */
export interface PollOffer {
  pollID: number;
  pollDescription: string;
}

/**
 * Poll incoming message IDs
 */
export const PollMessages = {
  POLL_OFFER: 316,
  POLL_CONTENTS: 317,
  POLL_ERROR: 318,
} as const;

/**
 * Poll outgoing command IDs
 */
export const PollCommands = {
  POLL_START: 234,
  POLL_REJECT: 235,
  POLL_ANSWER: 236,
  POLL_CANCEL: 237,
} as const;
