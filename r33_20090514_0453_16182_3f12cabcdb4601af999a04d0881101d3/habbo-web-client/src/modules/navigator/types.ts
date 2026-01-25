/**
 * Navigator Module Types
 *
 * Type definitions for the navigator system ported from hh_navigator
 */

// Node types for navigator tree structure
export enum NodeType {
  PUBLIC = 0,
  PRIVATE = 1,
  CATEGORY = 2,
}

export enum NodeMask {
  OPEN = 0,
  CLOSED = 1,
  PASSWORD = 2,
  INVISIBLE = 4,
}

// Navigator node definition
export interface NavNode {
  id: number;
  name: string;
  nodeType: NodeType;
  nodeMask: number;
  tradingLevel?: number;
  parentId: number;
  userCount: number;
  maxUsers: number;
  hasChildren: boolean;
  children?: NavNode[];
}

// Flat (room) info definition
export interface FlatInfo {
  id: number;
  name: string;
  ownerName: string;
  accessType: string; // 'open', 'closed', 'password'
  userCount: number;
  maxUsers: number;
  description: string;
  tradingLevel: number;
  score: number;
  parentId: number;
  superuser: boolean;
  doorX?: number;
  doorY?: number;
  doorDir?: number;
}

// User flat category
export interface UserFlatCategory {
  id: number;
  name: string;
}

// Favorite room reference
export interface FavoriteRoom {
  id: number;
  name: string;
}

// Navigator state
export interface NavigatorState {
  currentNodeId: number;
  currentCategoryId: number;
  nodeCache: Map<number, NavNode>;
  categoryIndex: Map<number, number>;
  flatInfo: FlatInfo | null;
  ownFlats: FlatInfo[];
  searchResults: FlatInfo[];
  favoriteRooms: FavoriteRoom[];
  userFlatCategories: UserFlatCategory[];
  popularTags: string[];
  ownRoomsInCategory: FlatInfo[];
}

// Message IDs from original Lingo code
export const NAVIGATOR_MESSAGE_IDS = {
  NAVNODEINFO: 220,      // Node information
  FLATINFO: 54,          // Room information
  USERFLATCATS: 221,     // User flat categories
  FLAT_RESULTS: 55,      // Search results
  NOFLATS: 57,           // No flats found
  FAVOURITES: 458,       // Favorite rooms
  FAVOURITE_CHANGED: 459, // Favorite added/removed
  FLATNOTALLOWEDTOENTER: 224, // Entry denied
  NAVNODEINFO_OWN: 364,  // Own rooms in category
  POPULAR_TAGS: 452,     // Popular room tags
  FLATTOOSMALL: 256,     // Room too small
} as const;

// Command IDs for sending messages
export const NAVIGATOR_COMMANDS = {
  NAVIGATE: 150,         // Request node info
  GETFLATINFO: 21,       // Request flat info
  GETOWNFLATS: 63,       // Get own rooms
  SEARCHFLAT: 57,        // Search for rooms
  ADDFAVOURITE: 287,     // Add favorite
  DELFAVOURITE: 288,     // Remove favorite
  GETFAVOURITES: 286,    // Get favorites list
  CREATEFLAT: 29,        // Create new room
  UPDATEFLAT: 151,       // Update room settings
  DELETEFLAT: 153,       // Delete room
  SETFLATINFO: 152,      // Set room info
  GOAWAY: 53,            // Leave current room
  TRYFLAT: 57,           // Try to enter room
  GOTOFLAT: 59,          // Go to specific room
  LETUSERIN: 60,         // Let user in (doorbell)
  GETPOPULARTAGS: 282,   // Get popular tags
  SEARCHBYTAG: 283,      // Search rooms by tag
} as const;

// Category configuration
export interface CategoryConfig {
  id: number;
  name: string;
  allowTrading: boolean;
  maxUsers: number;
}

// Room creation parameters
export interface CreateRoomParams {
  name: string;
  model: string;
  accessType: 'open' | 'closed' | 'password';
  password?: string;
  showOwnerName: boolean;
  categoryId: number;
}

// Room update parameters
export interface UpdateRoomParams {
  id: number;
  name?: string;
  description?: string;
  accessType?: 'open' | 'closed' | 'password';
  password?: string;
  maxUsers?: number;
  allowTrading?: boolean;
  allowPets?: boolean;
  superuser?: boolean;
  wallPaper?: string;
  floor?: string;
  landscape?: string;
}

// Navigator event types
export type NavigatorEventType =
  | 'node_loaded'
  | 'flat_info'
  | 'search_results'
  | 'favorites_updated'
  | 'room_created'
  | 'room_deleted'
  | 'entry_denied';

export interface NavigatorEvent {
  type: NavigatorEventType;
  data: unknown;
}
