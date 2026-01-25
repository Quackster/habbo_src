/**
 * Friend List Types
 *
 * Ported from: hh_friend_list/*.ls
 */

/**
 * Friend data structure
 */
export interface FriendData {
  id: number;
  name: string;
  sex: number;
  online: number;
  canfollow: number;
  figure: string;
  categoryId: string;
  mission: string;
  lastAccess: string;
}

/**
 * Friend request data
 */
export interface FriendRequest {
  id: string;
  name: string;
  userID: string;
  state: FriendRequestState;
}

/**
 * Friend request state
 */
export type FriendRequestState = 'pending' | 'accepted' | 'rejected';

/**
 * Friend category data
 */
export interface FriendCategory {
  id: string;
  name: string;
}

/**
 * Search result data
 */
export interface HabboSearchResult {
  id: number;
  name: string;
  mission: string;
  online: number;
  canfollow: number;
  roomname: string;
  sex: number;
  figure: string;
  lastAccess: string;
  fr_pending?: boolean;
}

/**
 * Search results container
 */
export interface HabboSearchResults {
  friends: HabboSearchResult[];
  habbos: HabboSearchResult[];
}

/**
 * Friend list state
 */
export interface FriendListState {
  friends: Map<string, FriendData>;
  categories: Map<string, FriendCategory>;
  requests: Map<string, FriendRequest>;
  listLimit: number;
  newMail: boolean;
  searchResults: HabboSearchResults;
  searchLastString: string;
  sentRequests: string[];
  ready: boolean;
}

/**
 * Friend list configuration
 */
export interface FriendListConfig {
  updateInterval: number;
  maxFreeCategories: number;
  categoryHeight: number;
  categoryOffsetTop: number;
  highlightDuration: number;
}

/**
 * List panel event data
 */
export interface ListPanelEventData {
  event: string;
  friend?: FriendData;
  request?: FriendRequest;
  element?: ListElementType;
  cursor?: string;
  item_y?: number;
  update?: boolean;
}

/**
 * List element types
 */
export type ListElementType = 'mail' | 'im' | 'follow' | 'addFriend' | 'request_accept' | 'request_reject';

/**
 * Friend list incoming message IDs
 */
export const FriendListMessages = {
  OK: 3,
  FRIENDLIST_INIT: 12,
  FRIENDLIST_UPDATE: 13,
  FRIENDLIST_REQUEST: 132,
  FRIENDLIST_ERROR: 260,
  FRIENDLIST_REQUEST_LIST: 314,
  FRIENDLIST_REQUEST_RESULT: 315,
  FOLLOW_FAILED: 349,
  MAIL_NOTIFICATION: 363,
  MAIL_COUNT_NOTIFICATION: 364,
  HABBO_SEARCH_RESULT: 435,
} as const;

/**
 * Friend list outgoing command IDs
 */
export const FriendListCommands = {
  FRIENDLIST_INIT: 12,
  FRIENDLIST_UPDATE: 15,
  FRIENDLIST_GETOFFLINEFRIENDS: 32,
  FRIENDLIST_REMOVEFRIEND: 40,
  MESSENGER_HABBOSEARCH: 41,
  FRIENDLIST_ACCEPTFRIEND: 37,
  FRIENDLIST_DECLINEFRIEND: 38,
  FRIENDLIST_FRIENDREQUEST: 39,
  FRIENDLIST_GETFRIENDREQUESTS: 233,
  FOLLOW_FRIEND: 262,
} as const;

/**
 * Friend update types from server
 */
export enum FriendUpdateType {
  REMOVED = -1,
  UPDATED = 0,
  ADDED = 1,
}

/**
 * Follow failure types
 */
export enum FollowFailureType {
  NOT_FRIEND = 0,
  OFFLINE = 1,
  HOTELVIEW = 2,
  PREVENTED = 3,
}

/**
 * Friend request error codes
 */
export enum FriendRequestError {
  UNDEFINED = 0,
  TARGET_LIST_FULL = 2,
  TARGET_NOT_ACCEPT = 3,
  REQUEST_NOT_FOUND = 4,
  REQUESTER_LIMIT = 37,
  CONCURRENCY = 42,
}

/**
 * Default category IDs
 */
export const CategoryIds = {
  ONLINE: '0',
  OFFLINE: '-1',
  REQUESTS: '-2',
  SEARCH: '-3',
} as const;
