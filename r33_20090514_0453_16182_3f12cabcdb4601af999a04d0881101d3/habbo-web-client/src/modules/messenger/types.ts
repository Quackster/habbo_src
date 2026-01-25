/**
 * Messenger Module Types
 *
 * Type definitions for the messenger/friend system ported from hh_messenger
 */

// Buddy/friend data
export interface BuddyData {
  id: string;
  name: string;
  sex: 'M' | 'F';
  customText: string;
  online: boolean;
  canFollow: boolean;
  location: string;
  lastAccess: string;
  figureData: string;
  msgs: number;
  update: boolean;
  category?: number;
}

// Friend request data
export interface FriendRequest {
  id: string;
  name: string;
  webId: string;
  state: RequestState;
}

export type RequestState = 'pending' | 'sent' | 'accepted' | 'declined' | 'failed';

// Message data
export interface MessageData {
  id: string;
  senderId: string;
  time: string;
  message: string;
  campaign?: boolean;
  url?: string;
  link?: string;
}

// Campaign message
export interface CampaignMessage extends MessageData {
  campaign: true;
  url: string;
  link: string;
}

// Buddy list structure
export interface BuddyList {
  buddies: Map<string, BuddyData>;
  online: string[];
  offline: string[];
  render: string[];
}

// Messenger state
export interface MessengerState {
  ready: boolean;
  paused: boolean;
  buddyList: BuddyList;
  messages: Map<string, Map<string, MessageData>>;
  msgCount: Map<string, number>;
  totalMsgCount: number;
  friendRequests: FriendRequest[];
  persistentMessage: string;
  friendRequestUpdateRequired: boolean;
  messageUpdateRequired: boolean;
}

// Buddy list limits
export interface BuddyListLimits {
  own: number;
  normal: number;
  club: number;
}

// Invitation data
export interface InvitationData {
  userId: string;
  name: string;
}

// Message IDs from original Lingo code
export const MESSENGER_MESSAGE_IDS = {
  OK: 3,
  MESSENGER_INIT: 12,
  CONSOLE_UPDATE: 13,
  MEMBERINFO: 128,
  BUDDY_REQUEST: 132,
  ADD_BUDDY: 137,
  REMOVE_BUDDY: 138,
  MY_PERSISTENT_MESSAGE: 147,
  MESSENGER_ERROR: 260,
  BUDDYLIST: 263,
  MESSENGER_MESSAGES: 313,
  BUDDY_REQUEST_LIST: 314,
  BUDDY_REQUEST_RESULT: 315,
  FOLLOW_FAILED: 349,
  INVITATION: 355,
  INVITATION_FOLLOW_FAILED: 359,
  INVITATION_EXPIRED: 360,
} as const;

// Command IDs for sending messages
export const MESSENGER_COMMANDS = {
  MESSENGERINIT: 12,
  MESSENGER_UPDATE: 15,
  MESSENGER_C_CLICK: 30,
  MESSENGER_C_READ: 31,
  MESSENGER_MARKREAD: 32,
  MESSENGER_SENDMSG: 33,
  MESSENGER_ASSIGNPERSMSG: 36,
  MESSENGER_ACCEPTBUDDY: 37,
  MESSENGER_DECLINEBUDDY: 38,
  MESSENGER_REQUESTBUDDY: 39,
  MESSENGER_REMOVEBUDDY: 40,
  FINDUSER: 41,
  MESSENGER_GETMESSAGES: 191,
  MESSENGER_REPORTMESSAGE: 201,
  GET_BUDDY_REQUESTS: 233,
  FOLLOW_FRIEND: 262,
  ACCEPT_TUTOR_INVITATION: 357,
  REJECT_TUTOR_INVITATION: 358,
} as const;

// Follow failure types
export enum FollowFailureType {
  NOT_FRIEND = 0,
  OFFLINE = 1,
  HOTEL_VIEW = 2,
  PREVENTED = 3,
}

// Messenger error codes
export enum MessengerErrorCode {
  UNDEFINED = 0,
  TARGET_FRIEND_LIST_FULL = 2,
  TARGET_DOES_NOT_ACCEPT = 3,
  FRIEND_REQUEST_NOT_FOUND = 4,
  BUDDY_LIMIT = 37,
  BUDDY_MASSREMOVE = 39,
  CONCURRENCY = 42,
}

// Buddy request error codes
export enum BuddyRequestErrorCode {
  FR_LIMIT_EXCEEDED = 1,
  TARGET_FRIEND_LIST_FULL = 2,
  TARGET_DOES_NOT_ACCEPT = 3,
  FRIEND_REQUEST_NOT_FOUND = 4,
  CONCURRENCY = 42,
}

// Messenger event types
export type MessengerEventType =
  | 'ready'
  | 'buddy_list_updated'
  | 'buddy_added'
  | 'buddy_removed'
  | 'message_received'
  | 'friend_request_received'
  | 'friend_request_result'
  | 'user_found'
  | 'user_not_found'
  | 'follow_failed'
  | 'invitation'
  | 'error';

export interface MessengerEvent {
  type: MessengerEventType;
  data: unknown;
}
