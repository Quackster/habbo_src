/**
 * Room UI Module Types
 *
 * Ported from: hh_room_ui/*.ls
 */

/**
 * Object type for infostand display
 */
export type ObjectDisplayType = 'user' | 'bot' | 'active' | 'item' | 'pet';

/**
 * Room bar layout types
 */
export type RoomBarLayout =
  | 'room_bar.window'
  | 'room_bar_wide.window'
  | 'room_bar_spectator.window'
  | 'room_bar_spectator_wide.window';

/**
 * Speech mode for chat
 */
export type SpeechMode = 'talk' | 'shout' | 'whisper';

/**
 * Window alignment for object displayer
 */
export type WindowAlignment = 'left' | 'right';

/**
 * IM icon state
 */
export type IMIconState = 'Active' | 'highlighted' | 'inactive';

/**
 * Object displayer window types
 */
export type DisplayerWindowType =
  | 'motto'
  | 'avatar'
  | 'bot'
  | 'furni'
  | 'pet'
  | 'tags_user'
  | 'xp_user'
  | 'fx_user'
  | 'links_human'
  | 'actions_human'
  | 'actions_furni'
  | 'bottom';

/**
 * Room info data
 */
export interface RoomInfoData {
  name: string;
  owner: string;
  type: 'public' | 'private';
  rating?: number;
  hasRated?: boolean;
}

/**
 * Room event data
 */
export interface RoomEventData {
  hostID: number;
  name: string;
  desc: string;
}

/**
 * User tag data
 */
export interface UserTagData {
  tags: string[];
  lastUpdate: number;
}

/**
 * Object display props for user
 */
export interface UserDisplayProps {
  name: string;
  figure: string;
  sex: 'M' | 'F';
  motto: string;
  badges?: Record<number, string>;
  groupID?: number;
  xp?: number;
  FX?: Array<{ id: number; name: string }>;
  dancing?: number;
  webID?: number;
}

/**
 * Object display props for furniture
 */
export interface FurnitureDisplayProps {
  name: string;
  description: string;
  class: string;
  id: string;
}

/**
 * Object display props for pet
 */
export interface PetDisplayProps {
  name: string;
  ownerName: string;
  type: number;
  race: number;
  level: number;
  happiness: number;
  experience: number;
  energy: number;
  nutrition: number;
}

/**
 * Room bar event types
 */
export const RoomBarEvents = {
  HELP_CLICK: 'help_click',
  HAND_CLICK: 'hand_click',
  CATALOG_CLICK: 'catalog_click',
  PURSE_CLICK: 'purse_click',
  GAMES_CLICK: 'games_click',
  EVENTS_CLICK: 'events_click',
  NAVIGATOR_CLICK: 'navigator_click',
  SOUND_TOGGLE: 'sound_toggle',
  IM_TOGGLE: 'im_toggle',
  FRIEND_LIST_TOGGLE: 'friend_list_toggle',
  CHAT_SUBMIT: 'chat_submit',
  SPEECH_MODE_CHANGE: 'speech_mode_change',
  VOTE_SUBMIT: 'vote_submit',
  SPECTATOR_CLOSE: 'spectator_close',
} as const;

/**
 * Infostand action types
 */
export const InfostandActions = {
  DANCE: 'dance',
  WAVE: 'wave',
  BADGES: 'badges',
  MOVE: 'move',
  ROTATE: 'rotate',
  PICK: 'pick',
  DELETE: 'delete',
  KICK: 'kick',
  BAN: 'ban',
  GIVE_RIGHTS: 'give_rights',
  TAKE_RIGHTS: 'take_rights',
  FRIEND: 'friend',
  RESPECT: 'respect',
  TRADE: 'trade',
  IGNORE: 'ignore',
  UNIGNORE: 'unignore',
  CLOSE: 'close',
  LOOKS: 'looks',
  HOME: 'home',
  GROUP: 'group',
  FX: 'fx',
} as const;

/**
 * Popup types for popup controller
 */
export type PopupType = 'navigator' | 'events' | 'games' | 'fx';

/**
 * Popup position
 */
export interface PopupPosition {
  x: number;
  y: number;
  anchor?: 'top' | 'bottom' | 'left' | 'right';
}

/**
 * Flood blocking settings
 */
export interface FloodSettings {
  countLimit: number;
  timerLimit: number;
  timeout: number;
}

/**
 * Default flood settings
 */
export const DEFAULT_FLOOD_SETTINGS: FloodSettings = {
  countLimit: 2,
  timerLimit: 3000,
  timeout: 30000,
};

/**
 * Window IDs
 */
export const WindowIds = {
  ROOM_BAR: 'RoomBarID',
  ROOM_INFO: 'RoomInfoWindow',
  EVENT_INFO: 'EventInfoWindow',
  OBJECT_DISPLAYER_BASE: 'obj_disp_base',
} as const;
