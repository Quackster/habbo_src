/**
 * Purse Handler Class
 *
 * Handles server messages for the purse/wallet system.
 * Ported from hh_purse Cast External ParentScript 4.
 */

import {
  PURSE_MESSAGE_IDS,
  PURSE_COMMANDS,
  VoucherProduct,
} from './types';
import { getPurseComponent } from './PurseComponent';

type MessageHandler = (data: string, connection?: unknown) => void;

export class PurseHandler {
  private handlers: Map<number, MessageHandler>;
  private sendMessage: (msgId: number, data?: string) => void;
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor(sendMessage: (msgId: number, data?: string) => void) {
    this.sendMessage = sendMessage;
    this.handlers = new Map();
    this.registerHandlers();
  }

  /**
   * Set event callback
   */
  setEventCallback(callback: (event: string, data: unknown) => void): void {
    this.eventCallback = callback;
  }

  /**
   * Emit event to listeners
   */
  private emit(event: string, data: unknown): void {
    if (this.eventCallback) {
      this.eventCallback(event, data);
    }
  }

  /**
   * Register all message handlers
   */
  private registerHandlers(): void {
    this.handlers.set(PURSE_MESSAGE_IDS.PURSE, this.handlePurse.bind(this));
    this.handlers.set(
      PURSE_MESSAGE_IDS.CREDIT_LOG,
      this.handleCreditLog.bind(this)
    );
    this.handlers.set(
      PURSE_MESSAGE_IDS.VOUCHER_OK,
      this.handleVoucherOk.bind(this)
    );
    this.handlers.set(
      PURSE_MESSAGE_IDS.VOUCHER_ERROR,
      this.handleVoucherError.bind(this)
    );
    this.handlers.set(PURSE_MESSAGE_IDS.TICKETS, this.handleTickets.bind(this));
    this.handlers.set(
      PURSE_MESSAGE_IDS.TICKETS_BUY,
      this.handleTicketsBuy.bind(this)
    );
    this.handlers.set(
      PURSE_MESSAGE_IDS.NO_TICKETS,
      this.handleNoTickets.bind(this)
    );
  }

  /**
   * Handle incoming message
   */
  handleMessage(msgId: number, msgData: string): boolean {
    const handler = this.handlers.get(msgId);
    if (handler) {
      handler(msgData);
      return true;
    }
    return false;
  }

  // ============== Message Handlers ==============

  /**
   * Handle purse/credits update
   */
  private handlePurse(msgData: string): void {
    const credits = parseInt(msgData.split(/\s+/)[0], 10) || 0;
    getPurseComponent().setCredits(credits);
  }

  /**
   * Handle credit log (transaction history)
   */
  private handleCreditLog(msgData: string): void {
    const component = getPurseComponent();
    const transactions = component.parseTransactionLog(msgData);
    component.setTransactions(transactions);
  }

  /**
   * Handle voucher redemption success
   */
  private handleVoucherOk(msgData: string): void {
    const products: VoucherProduct[] = [];

    // Parse product list if present
    const lines = msgData.split('\r');
    for (let i = 0; i < lines.length; i += 2) {
      const name = lines[i];
      const description = lines[i + 1] || '';
      if (name && name.trim()) {
        products.push({ name, description });
      }
    }

    this.emit('voucher_success', {
      products: products.length > 0 ? products : null,
    });
  }

  /**
   * Handle voucher redemption error
   */
  private handleVoucherError(msgData: string): void {
    const parts = msgData.split('\t');
    const errorCode = parts[0] || 'unknown';
    this.emit('voucher_error', { errorCode });
  }

  /**
   * Handle tickets update
   */
  private handleTickets(msgData: string): void {
    const tickets = parseInt(msgData.split(/\s+/)[0], 10) || 0;
    getPurseComponent().setTickets(tickets);
  }

  /**
   * Handle tickets purchase update
   */
  private handleTicketsBuy(msgData: string): void {
    const tickets = parseInt(msgData.split(/\s+/)[0], 10) || 0;
    getPurseComponent().setTickets(tickets);
  }

  /**
   * Handle no tickets notification
   */
  private handleNoTickets(_msgData: string): void {
    this.emit('no_tickets', null);
  }

  // ============== Command Senders ==============

  /**
   * Request credits balance
   */
  requestCredits(): void {
    this.sendMessage(PURSE_COMMANDS.GET_CREDITS);
  }

  /**
   * Request transaction history
   */
  requestCreditLog(): void {
    this.sendMessage(PURSE_COMMANDS.GET_USER_CREDIT_LOG);
  }

  /**
   * Redeem a voucher code
   */
  redeemVoucher(code: string): void {
    this.sendMessage(PURSE_COMMANDS.REDEEM_VOUCHER, code);
  }
}

// Singleton instance
let purseHandler: PurseHandler | null = null;

export function getPurseHandler(
  sendMessage?: (msgId: number, data?: string) => void
): PurseHandler {
  if (!purseHandler) {
    if (!sendMessage) {
      throw new Error('sendMessage function required for initial creation');
    }
    purseHandler = new PurseHandler(sendMessage);
  }
  return purseHandler;
}

export function resetPurseHandler(): void {
  purseHandler = null;
}
