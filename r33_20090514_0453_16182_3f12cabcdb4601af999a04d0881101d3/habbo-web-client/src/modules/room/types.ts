/**
 * Room Module Type Definitions
 *
 * Types for the room system ported from hh_room
 */

// Room types
export type RoomType = 'public' | 'private';

// Object types
export type RoomObjectType = 'user' | 'active' | 'passive' | 'item';

// Direction (0-7, representing 8 directions)
export type Direction = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7;

// Location in 3D room space
export interface RoomLocation {
  x: number;
  y: number;
  h: number; // height
}

// Screen coordinate
export interface ScreenCoordinate {
  x: number;
  y: number;
  z: number; // z-order
}

// Height map tile values
export const TILE_BLOCKED = 200000;
export const TILE_DOOR = 100000;

// Room geometry configuration
export interface GeometryConfig {
  offsetX: number;
  offsetY: number;
  offsetZ: number;
  factorX: number;
  factorY: number;
  factorH: number;
}

// Room data from server
export interface RoomData {
  id: string;
  name: string;
  type: RoomType;
  owner?: string;
  ownerId?: number;
  description?: string;
  model: string;
  heightMap?: string;
  floorMap?: string;
}

// User object definition
export interface UserObjectDef {
  id: string;
  webId?: number;
  name: string;
  custom: string; // motto
  figure: string;
  sex: 'M' | 'F';
  x: number;
  y: number;
  h: number;
  direction: Direction[];
  badge?: Record<string, string>;
  groupId?: string;
  groupStatus?: string;
  xp?: number;
  swimFigure?: string;
}

// Active object (floor furniture) definition
export interface ActiveObjectDef {
  id: string;
  class: string;
  x: number;
  y: number;
  altitude: number;
  direction: Direction[];
  dimensions?: [number, number];
  colors?: string;
  props?: string;
  expire?: number;
}

// Passive object (wall/decoration) definition
export interface PassiveObjectDef {
  id: string;
  class: string;
  x: number;
  y: number;
  h?: number;
  direction: Direction[];
  dimensions?: [number, number];
  colors?: string;
  props?: string;
}

// Item object (wall item) definition
export interface ItemObjectDef {
  id: string;
  class: string;
  type?: string;
  x: number;
  y: number;
  h?: number;
  z?: number;
  wallX: number;
  wallY: number;
  localX: number;
  localY: number;
  formatVersion: 'old' | 'new';
  direction: 'leftwall' | 'rightwall';
  props?: string;
  expire?: number;
}

// Object status update
export interface StatusUpdate {
  id: string;
  x: number;
  y: number;
  h: number;
  headDirection: Direction;
  bodyDirection: Direction;
  actions: ActionDef[];
}

// Action definition
export interface ActionDef {
  name: string;
  params: string;
}

// Chat message
export interface ChatMessage {
  userId: string;
  message: string;
  type: 'chat' | 'shout' | 'whisper';
  gesture?: number;
}

// Trade state
export interface TradeState {
  active: boolean;
  partnerId?: string;
  ownItems: string[];
  partnerItems: string[];
  ownAccepted: boolean;
  partnerAccepted: boolean;
}

// Slide object data
export interface SlideObjectData {
  objectId: string;
  fromLoc: RoomLocation;
  toLoc: RoomLocation;
  startTime: number;
  hasCharacter?: boolean;
}

// Room visualizer layout
export interface RoomVisualizerLayout {
  name: string;
  parts: RoomVisualizerPart[];
}

// Room visualizer part (wall segment, floor tile, etc.)
export interface RoomVisualizerPart {
  type: 'floor' | 'wallleft' | 'wallright' | 'door';
  x: number;
  y: number;
  locH: number;
  locV: number;
  locZ: number;
  member: string;
  width?: number;
  height?: number;
}

// Object info for info stand
export interface ObjectInfo {
  name?: string;
  class: string;
  custom?: string;
  image?: HTMLCanvasElement | ImageData;
  smallMember?: string;
  ctrl?: string;
  badges?: Record<string, string>;
  groupId?: string;
  xp?: number;
  fx?: number;
  expire?: number;
}

// Event data for room events
export interface RoomEventData {
  type: string;
  objectId: string;
  objectType: RoomObjectType;
  x?: number;
  y?: number;
  spriteId?: number;
}

// Message handler types
export type RoomMessageHandler = (data: unknown) => void;

// Room connection commands
export interface RoomCommands {
  MOVE: number;
  CHAT: number;
  SHOUT: number;
  WHISPER: number;
  LOOKTO: number;
  WAVE: number;
  DANCE: number;
  SIGN: number;
  PLACESTUFF: number;
  MOVESTUFF: number;
  SETSTUFFDATA: number;
  REMOVESTUFF: number;
  TRADE_OPEN: number;
  TRADE_ADDITEM: number;
  TRADE_REMOVEITEM: number;
  TRADE_ACCEPT: number;
  TRADE_UNACCEPT: number;
  TRADE_CLOSE: number;
  TRADE_CONFIRM: number;
  ASSIGNRIGHTS: number;
  REMOVERIGHTS: number;
  KICKUSER: number;
  LETUSERIN: number;
  GIVERESPECT: number;
}

// Default room commands (message IDs)
export const ROOM_COMMANDS: RoomCommands = {
  MOVE: 75,
  CHAT: 52,
  SHOUT: 55,
  WHISPER: 56,
  LOOKTO: 79,
  WAVE: 94,
  DANCE: 93,
  SIGN: 100,
  PLACESTUFF: 90,
  MOVESTUFF: 73,
  SETSTUFFDATA: 89,
  REMOVESTUFF: 67,
  TRADE_OPEN: 71,
  TRADE_ADDITEM: 72,
  TRADE_REMOVEITEM: 77,
  TRADE_ACCEPT: 69,
  TRADE_UNACCEPT: 70,
  TRADE_CLOSE: 95,
  TRADE_CONFIRM: 68,
  ASSIGNRIGHTS: 164,
  REMOVERIGHTS: 165,
  KICKUSER: 96,
  LETUSERIN: 97,
  GIVERESPECT: 440,
};

// Incoming message IDs
export interface RoomMessageIds {
  USERS: number;
  LOGOUT: number;
  OBJECTS: number;
  HEIGHTMAP: number;
  ACTIVEOBJECTS: number;
  ITEMS: number;
  STATUS: number;
  CHAT: number;
  SHOUT: number;
  WHISPER: number;
  TRADE_ITEMS: number;
  TRADE_ACCEPT: number;
  TRADE_CLOSE: number;
  TRADE_COMPLETED: number;
  FLATPROPERTY: number;
  DOORBELL_RINGING: number;
  ROOM_READY: number;
  YOUAROWNER: number;
  YOUARECONTROLLER: number;
  SLIDEOBJECTBUNDLE: number;
  OBJECTS_DATAUPDATE: number;
}

export const ROOM_MESSAGE_IDS: RoomMessageIds = {
  USERS: 28,
  LOGOUT: 29,
  OBJECTS: 30,
  HEIGHTMAP: 31,
  ACTIVEOBJECTS: 32,
  ITEMS: 45,
  STATUS: 34,
  CHAT: 24,
  SHOUT: 26,
  WHISPER: 25,
  TRADE_ITEMS: 108,
  TRADE_ACCEPT: 109,
  TRADE_CLOSE: 110,
  TRADE_COMPLETED: 111,
  FLATPROPERTY: 46,
  DOORBELL_RINGING: 91,
  ROOM_READY: 69,
  YOUAROWNER: 42,
  YOUARECONTROLLER: 43,
  SLIDEOBJECTBUNDLE: 230,
  OBJECTS_DATAUPDATE: 88,
};
