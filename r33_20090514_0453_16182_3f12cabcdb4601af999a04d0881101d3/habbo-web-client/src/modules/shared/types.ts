/**
 * Shared Module Types
 *
 * Ported from: hh_shared/*.ls
 */

/**
 * Sound play priority
 */
export type SoundPriority = 'pass' | 'cut' | 'queue';

/**
 * Sound properties
 */
export interface SoundProps {
  volume?: number;
  loopCount?: number;
  infiniteloop?: boolean;
  startTime?: number;
  endTime?: number;
}

/**
 * Sound instance data
 */
export interface SoundInstanceData {
  name: string;
  priority?: SoundPriority;
  props: SoundProps;
}

/**
 * Date format type
 */
export type DateFormatType = 'dd-mm-yyyy' | 'mm-dd-yyyy' | 'yyyy-mm-dd' | string;

/**
 * Tooltip parameters
 */
export interface TooltipParams {
  msg: string;
  pos: { x: number; y: number } | { left: number; top: number; right: number; bottom: number };
}

/**
 * Bounce state
 */
export interface BounceState {
  bounceOn: boolean;
  offset: number;
  speed: number;
}

/**
 * CFH (Call For Help) type
 */
export type CFHType = 'private' | 'public' | 'habbo_helpers' | 'emergency';

/**
 * CFH category
 */
export const CFHCategory = {
  MODERATORS: 1,
  HELPERS: 2,
} as const;

/**
 * CFH data structure
 */
export interface CFHData {
  cry_id: string;
  sender: string;
  msg: string;
  type: CFHType;
  room_id: number;
  roomname: string;
  url_id: string;
  picker?: string;
  block?: boolean;
  casts?: string[];
}

/**
 * Error report data
 */
export interface ErrorReportData {
  errorId: string;
  errorMsg: string;
  timestamp?: number;
}

/**
 * Statistics tracking message
 */
export const StatisticsMessages = {
  TRACKING_CODE: 166,
} as const;

/**
 * Hobba message IDs
 */
export const HobbaMessages = {
  CRY_FOR_HELP: 1, // Placeholder
  CRY_PICKED: 2,
  CRY_DELETED: 3,
} as const;

/**
 * Hobba command IDs
 */
export const HobbaCommands = {
  GET_PENDING_CALLS: 'GET_PENDING_CALLS_FOR_HELP',
  PICK_CRY: 'PICK_CRYFORHELP',
  FOLLOW_CRY: 'FOLLOW_CRYFORHELP',
  CALL_FOR_HELP: 'CALL_FOR_HELP',
  MESSAGE_TO_CALLER: 'MESSAGETOCALLER',
  CHANGE_CALL_CATEGORY: 'CHANGECALLCATEGORY',
} as const;

/**
 * Element position data for bouncer
 */
export interface ElementPositionData {
  elementId: string;
  origX: number;
  origY: number;
}
