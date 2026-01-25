/**
 * Club Types
 *
 * Ported from: hh_club/*.ls
 */

/**
 * Club status data
 */
export interface ClubStatus {
  productName: string;
  daysLeft: number;
  elapsedPeriods: number;
  prepaidPeriods: number;
}

/**
 * Club state
 */
export interface ClubState {
  status: ClubStatus | null;
  giftCount: number;
  acceptedGifts: number;
}

/**
 * Club response flags from server
 */
export enum ClubResponseFlag {
  INITIAL = 0,
  INFO = 1,
  PURCHASED = 2,
  EXPIRED = 3,
}

/**
 * Club subscription length options
 */
export type ClubSubscriptionLength = 1 | 2 | 3;

/**
 * Club incoming message IDs
 */
export const ClubMessages = {
  OK: 3,
  SCR_SINFO: 7,
  SCR_GIFT: 280,
} as const;

/**
 * Club outgoing command IDs
 */
export const ClubCommands = {
  SCR_GET_USER_INFO: 26,
  SCR_BUY: 190,
  SCR_GIFT_APPROVAL: 210,
} as const;
