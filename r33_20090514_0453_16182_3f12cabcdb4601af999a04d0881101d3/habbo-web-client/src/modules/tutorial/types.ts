/**
 * Tutorial Module Types (New User Help - NUH)
 *
 * Ported from: hh_tutorial/*.ls
 */

/**
 * Help item status data
 * Key is help item name, value is whether it's active (1) or closed (0)
 */
export type HelpStatusData = Record<string, number>;

/**
 * Help item configuration
 */
export interface HelpItem {
  id: string;
  text: string;
  topic?: string;
  timeout?: number;
  autoOpen?: boolean;
  bgColor?: string;
  txtColor?: string;
  highlighter?: string;
}

/**
 * Bubble pointer direction (1-8, clockwise from top-left)
 * 1: top-left, 2: top-right, 3: right-top, 4: right-bottom
 * 5: bottom-right, 6: bottom-left, 7: left-bottom, 8: left-top
 */
export type BubblePointerDirection = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8;

/**
 * Bubble state
 */
export interface BubbleState {
  id: string;
  text: string;
  x: number;
  y: number;
  width: number;
  height: number;
  pointerDirection: BubblePointerDirection;
  visible: boolean;
  blend: number;
  targetX?: number;
  targetY?: number;
}

/**
 * Invitation status
 */
export type InvitationStatus =
  | 'search'     // Searching for tutors
  | 'room_left'  // Inviter left room
  | 'success'    // Found tutors
  | 'failure';   // No tutors found

/**
 * Invitation close result
 */
export type InvitationCloseResult = 'yes' | 'no' | 'never';

/**
 * Infofeed item data
 */
export interface InfofeedItem {
  type: 'help';
  value: string;
  helpId: string;
  topic?: string;
  autoOpen?: number;
  bgColor?: string;
  txtColor?: string;
}

/**
 * Highlighter list
 * Maps help item ID to element name
 */
export type HighlighterList = Record<string, string>;

/**
 * Tutorial message IDs
 */
export const TutorialMessages = {
  HELP_ITEMS: 352,
  TUTORS_AVAILABLE: 356,
  INVITING_COMPLETED: 357,
  INVITATION_EXISTS: 358,
  INVITATION_SENT: 421,
  GUIDE_FOUND: 423,
  INVITER_LEFT_ROOM: 424,
} as const;

/**
 * Tutorial command IDs
 */
export const TutorialCommands = {
  REMOVE_ACCOUNT_HELP_TEXT: 313,
  GET_TUTORS_AVAILABLE: 355,
  INVITE_TUTORS: 356,
  CANCEL_TUTOR_INVITATIONS: 359,
} as const;

/**
 * Default bubble text width
 */
export const DEFAULT_BUBBLE_TEXT_WIDTH = 120;

/**
 * Fade speed for bubbles
 */
export const BUBBLE_FADE_SPEED = 5;

/**
 * Highlighter blink interval in ms
 */
export const HIGHLIGHTER_BLINK_INTERVAL = 750;

/**
 * Search animation interval in ms
 */
export const SEARCH_ANIM_INTERVAL = 250;
