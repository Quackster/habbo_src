/**
 * Purse Module Types
 *
 * Type definitions for the purse/wallet system ported from hh_purse
 */

// Transaction record
export interface Transaction {
  date: string;
  time: string;
  creditValue: number;
  realValue: number;
  currency: string;
  transactionSystemName: string;
}

// Voucher result
export interface VoucherResult {
  success: boolean;
  products?: VoucherProduct[];
  errorCode?: string;
}

// Voucher product (for furniture vouchers)
export interface VoucherProduct {
  name: string;
  description: string;
}

// Purse state
export interface PurseState {
  credits: number;
  tickets: number;
  transactions: Transaction[];
  transactionPages: Transaction[][];
  hasTransactions: boolean;
}

// Message IDs from original Lingo code
export const PURSE_MESSAGE_IDS = {
  PURSE: 6,
  TICKETS: 72,
  NO_TICKETS: 73,
  TICKETS_BUY: 124,
  CREDIT_LOG: 209,
  VOUCHER_OK: 212,
  VOUCHER_ERROR: 213,
} as const;

// Command IDs for sending messages
export const PURSE_COMMANDS = {
  GET_CREDITS: 8,
  GET_USER_CREDIT_LOG: 127,
  REDEEM_VOUCHER: 129,
} as const;

// Purse event types
export type PurseEventType =
  | 'credits_updated'
  | 'tickets_updated'
  | 'transactions_loaded'
  | 'voucher_success'
  | 'voucher_error'
  | 'no_tickets';

export interface PurseEvent {
  type: PurseEventType;
  data: unknown;
}
