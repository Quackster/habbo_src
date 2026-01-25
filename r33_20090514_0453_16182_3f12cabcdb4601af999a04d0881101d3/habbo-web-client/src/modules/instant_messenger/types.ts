/**
 * Instant Messenger Types
 *
 * Ported from: hh_instant_messenger/*.ls
 */

import { FriendData } from '../friend_list/types';

/**
 * Chat message entry
 */
export interface ChatEntry {
  type: ChatEntryType;
  userID?: number | string;
  Msg: string;
  time: string;
}

/**
 * Chat entry types
 */
export type ChatEntryType = 'message' | 'error' | 'notification' | 'invitation';

/**
 * Chat data (list of messages)
 */
export type ChatData = ChatEntry[];

/**
 * IM state
 */
export type IMState = 'Active' | 'highlighted';

/**
 * IM window view
 */
export type IMWindowView = 'normal' | 'empty';

/**
 * IM error codes
 */
export enum IMErrorCode {
  RECEIVER_MUTED = 3,
  SENDER_MUTED = 4,
  OFFLINE = 5,
  NOT_FRIEND = 6,
  BUSY = 7,
}

/**
 * IM notification types
 */
export type IMNotificationType = 'moderation' | 'online' | 'offline';

/**
 * IM incoming message IDs
 */
export const IMMessages = {
  IM_MESSAGE: 134,
  IM_INVITATION: 135,
  IM_ERROR: 261,
  INVITATION_ERROR: 262,
} as const;

/**
 * IM outgoing command IDs
 */
export const IMCommands = {
  MESSENGER_SENDMSG: 33,
  FRIEND_INVITE: 34,
} as const;

/**
 * IM configuration
 */
export interface IMConfig {
  windowHeightMin: number;
  batchSize: number;
  batchInterval: number;
  cachedChats: number;
  marginRight: number;
  marginTop: number;
}
