/**
 * Habbo Protocol Definitions
 *
 * Ported from: hh_entry/Cast External ParentScript 8 - Login Handler Class.ls
 *
 * Message IDs are the 2-byte identifiers used in the protocol.
 * Commands are outgoing, Messages are incoming.
 */

// === INCOMING MESSAGE IDs (Server -> Client) ===
export const IncomingMessages = {
  // Connection / Handshake
  DISCONNECT: -1,
  HELLO: 0,
  SECRET_KEY: 1,
  RIGHTS: 2,
  LOGIN_OK: 3,
  USER_OBJ: 5,

  // Errors
  ERROR: 33,
  USER_BANNED: 35,

  // General
  PING: 50,
  EPS_NOTIFY: 52,

  // Catalogue
  CATALOG_INDEX: 126,
  CATALOG_PAGE: 127,

  // System
  SYSTEM_BROADCAST: 139,
  CHECKSUM: 141,
  MOD_ALERT: 161,

  // Navigator
  NAVNODEINFO: 220,

  // Badges
  AVAILABLE_BADGES: 229,

  // Session
  SESSION_PARAMETERS: 257,
  BUDDY_LIST: 263,

  // Crypto
  CRYPTO_PARAMETERS: 277,
  END_CRYPTO: 278,

  // Hotel
  HOTEL_LOGOUT: 287,
  SOUND_SETTING: 308,

  // Room
  ROOM_READY: 69,
  ROOM_URL: 166,
  HEIGHTMAP: 31,
  FLAT_PROPERTY: 46,
  OBJECTS: 30,
  ITEMS: 45,
  USERS: 28,
  STATUS: 34,
  CHAT: 24,
  WHISPER: 25,
  SHOUT: 26,
  FLATINFO: 54,
  DOORBELL: 91,
  FLAT_LETIN: 41,
  ROOM_RATING: 345,
  ROOM_EVENT: 370,

  // Trading
  TRADE_OPEN: 104,
  TRADE_CLOSE: 110,
  TRADE_ACCEPT: 103,
  TRADE_COMPLETE: 111,
  TRADE_ITEMS: 105,

  // Purse
  PURSE: 6,
  TICKETS: 72,
  VOUCHER_OK: 212,
  VOUCHER_ERROR: 213,

  // Messenger
  MESSENGER_INIT: 12,
  FRIEND_REQUEST: 132,
  FRIEND_REQUEST_RESULT: 315,
  INSTANT_MESSAGE: 134,
  NEW_FRIEND: 137,
  BUDDY_ONLINE: 304,
  REMOVE_BUDDY: 138,
  CHAT_INVITE: 135,
  ROOM_INVITE: 135,

  // Effects
  FIGURE_CHANGE: 266,
  AVATAR_EFFECT: 461,
  AVATAR_EFFECT_EXPIRE: 462,
  AVATAR_EFFECT_SELECTED: 463,

  // Pets
  PET_STATUS: 601,
  PET_FIGURE: 602,

  // Games
  GAME_STATUS: 233,
  GAME_INVITE: 234,
} as const;

// === OUTGOING COMMAND IDs (Client -> Server) ===
export const OutgoingCommands = {
  // Login / Session
  TRY_LOGIN: 4,
  VERSIONCHECK: 5,
  UNIQUEID: 6,
  GET_INFO: 7,
  GET_CREDITS: 8,
  GET_PASSWORD: 47,
  LANGCHECK: 58,
  BTCKS: 105,
  GETAVAILABLEBADGES: 157,
  GET_SESSION_PARAMETERS: 181,
  PONG: 196,
  GENERATEKEY: 202,
  SSO: 204,
  INIT_CRYPTO: 206,
  SECRETKEY: 207,
  GET_SOUND_SETTING: 228,
  SET_SOUND_SETTING: 229,

  // Navigation
  NAVIGATE: 150,
  GETFLATINFO: 21,
  SUSERF: 16,
  SRCHF: 17,
  GETFLATCAT: 151,
  GETSPACENODEUSERS: 155,
  CONVERT_ROOMID: 160,
  REMOVEALLRIGHTS: 167,
  DELETEFLAT: 24,
  SETFLATCAT: 152,
  SETFLATINFO: 25,
  UPDATEFLAT: 26,
  GETFVRF: 153,
  ADD_FAVORITE_ROOM: 19,
  DEL_FAVORITE_ROOM: 20,
  GET_RECOMMENDED_ROOMS: 264,

  // Room
  ROOM_DIRECTORY: 2,
  G_HMAP: 60,
  GET_FLOORMAP: 181,
  G_USRS: 61,
  G_OBJS: 62,
  G_ITEMS: 63,
  G_STAT: 64,
  MOVE: 75,
  CHAT: 52,
  SHOUT: 55,
  WHISPER: 56,
  LOOK: 79,
  WAVE: 93,
  DANCE: 94,
  SIT: 95,
  STOP: 80,
  SIGN: 89,
  TRYFLAT: 57,
  GOTOFLAT: 59,
  GOVIADOOR: 182,
  GETINTERST: 180,
  GETROOMAD: 126,

  // Furniture
  FLATPROPBYITEM: 220,
  MOVEOBJECT: 73,
  PLACESTUFF: 90,
  MOVESTUFF: 67,
  ADDSTRIPITEM: 66,
  SETSTUFFDATA: 69,
  SETWALLITEM: 83,
  REMOVEWALLITEM: 84,
  PRESENTOPEN: 99,

  // Trading
  TRADE_OPEN: 71,
  TRADE_ADDITEM: 72,
  TRADE_UNACCEPT: 103,
  TRADE_ACCEPT: 69,
  TRADE_CLOSE: 95,
  TRADE_CONFIRM: 68,

  // Catalogue
  GCIX: 101,
  GCAP: 102,
  GPRC: 100,
  BTN_CANCEL: 104,

  // Messenger
  MESSENGER_INIT: 12,
  FINDUSER: 41,
  REQUESTBUDDY: 34,
  DECLINEBUDDY: 33,
  ACCEPTBUDDY: 137,
  REMOVEBUDDY: 40,
  MESSENGER_SENDMSG: 36,
  MESSENGER_MARKREAD: 35,
  FOLLOW_FRIEND: 262,
  HABBO_SEARCH: 42,

  // Effects
  GET_AVATAR_EFFECTS: 370,
  AVATAR_EFFECT_SELECT: 371,
  AVATAR_EFFECT_ACTIVATE: 372,

  // Room Events
  GET_ROOMEVENT_TYPE_COUNT: 345,
  GET_ROOMEVENTS_BY_TYPE: 346,
  CREATE_ROOMEVENT: 348,
  EDIT_ROOMEVENT: 349,

  // Club
  GET_CLUB_STATUS: 26,
  BUY_CLUB: 190,

  // Misc
  REGISTER_RECYCLER: 300,
  RECYCLE_ITEMS: 301,
  REDEEM_VOUCHER: 129,
  UPDATE_BADGE: 158,
  MODERATORACTION: 200,
  ROOM_MUTE: 201,
} as const;

// Type helpers
export type IncomingMessageId = typeof IncomingMessages[keyof typeof IncomingMessages];
export type OutgoingCommandId = typeof OutgoingCommands[keyof typeof OutgoingCommands];

/**
 * Create a command map for the connection manager
 */
export function createCommandMap(): Map<string, string> {
  const map = new Map<string, string>();

  for (const [name, id] of Object.entries(OutgoingCommands)) {
    // Encode command ID as 2-byte Base64-like string
    const byte1 = ((id >> 6) & 63) | 64;
    const byte2 = (id & 63) | 64;
    map.set(name, String.fromCharCode(byte1, byte2));
  }

  return map;
}

/**
 * Get message name by ID (for debugging)
 */
export function getMessageName(id: number): string {
  for (const [name, msgId] of Object.entries(IncomingMessages)) {
    if (msgId === id) return name;
  }
  return `UNKNOWN_${id}`;
}

/**
 * Get command name by ID (for debugging)
 */
export function getCommandName(id: number): string {
  for (const [name, cmdId] of Object.entries(OutgoingCommands)) {
    if (cmdId === id) return name;
  }
  return `UNKNOWN_${id}`;
}
