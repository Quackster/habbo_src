/**
 * Recycler Types
 *
 * Ported from: hh_recycler/*.ls
 */

/**
 * Recycler state
 */
export type RecyclerState = 'open' | 'closed' | 'timeout';

/**
 * Furniture item in recycler pool
 */
export interface RecyclerFurniItem {
  class: string;
  id: string;
  props: {
    stripId: string;
    [key: string]: unknown;
  };
}

/**
 * Recycler incoming message IDs
 */
export const RecyclerMessages = {
  RECYCLER_STATUS: 507,
  RECYCLER_FINISHED: 508,
} as const;

/**
 * Recycler outgoing command IDs
 */
export const RecyclerCommands = {
  GET_RECYCLER_STATUS: 413,
  RECYCLE_ITEMS: 414,
} as const;

/**
 * Recycler configuration
 */
export interface RecyclerConfig {
  givePoolSize: number;
  recyclingTimeoutMinutes: number;
}
