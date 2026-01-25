/**
 * Purse Component Class
 *
 * Manages wallet state including credits, tickets, and transactions.
 * Ported from hh_purse Cast External ParentScript 3.
 */

import { PurseState, Transaction } from './types';

export class PurseComponent {
  private state: PurseState;
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor() {
    this.state = {
      credits: 0,
      tickets: 0,
      transactions: [],
      transactionPages: [],
      hasTransactions: false,
    };
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
   * Reset purse state
   */
  reset(): void {
    this.state.credits = 0;
    this.state.tickets = 0;
    this.state.transactions = [];
    this.state.transactionPages = [];
    this.state.hasTransactions = false;
  }

  // ============== Credits ==============

  /**
   * Get current credits
   */
  getCredits(): number {
    return this.state.credits;
  }

  /**
   * Set credits
   */
  setCredits(credits: number): void {
    const oldCredits = this.state.credits;
    this.state.credits = credits;
    this.emit('credits_updated', { credits, oldCredits });
  }

  // ============== Tickets ==============

  /**
   * Get current tickets
   */
  getTickets(): number {
    return this.state.tickets;
  }

  /**
   * Set tickets
   */
  setTickets(tickets: number): void {
    const oldTickets = this.state.tickets;
    this.state.tickets = tickets;
    this.emit('tickets_updated', { tickets, oldTickets });
  }

  // ============== Transactions ==============

  /**
   * Get all transactions
   */
  getTransactions(): Transaction[] {
    return this.state.transactions;
  }

  /**
   * Get transaction pages
   */
  getTransactionPages(): Transaction[][] {
    return this.state.transactionPages;
  }

  /**
   * Set transactions and paginate
   */
  setTransactions(transactions: Transaction[]): void {
    this.state.transactions = transactions;
    this.state.hasTransactions = transactions.length > 0;

    // Paginate (10 per page)
    this.state.transactionPages = [];
    const pageSize = 10;

    for (let i = 0; i < transactions.length; i += pageSize) {
      this.state.transactionPages.push(transactions.slice(i, i + pageSize));
    }

    this.emit('transactions_loaded', {
      transactions,
      pages: this.state.transactionPages,
    });
  }

  /**
   * Check if has transactions
   */
  hasTransactions(): boolean {
    return this.state.hasTransactions;
  }

  /**
   * Get transaction page count
   */
  getPageCount(): number {
    return this.state.transactionPages.length;
  }

  /**
   * Get specific transaction page
   */
  getPage(pageIndex: number): Transaction[] | undefined {
    return this.state.transactionPages[pageIndex];
  }

  // ============== Parsing ==============

  /**
   * Parse credit log data from server
   */
  parseTransactionLog(data: string): Transaction[] {
    const transactions: Transaction[] = [];
    const lines = data.split('\r');

    for (let i = lines.length - 2; i >= 0; i--) {
      const line = lines[i];
      if (!line || line.trim() === '') continue;

      const parts = line.split('\t');
      if (parts.length >= 6) {
        transactions.push({
          date: parts[0],
          time: parts[1],
          creditValue: parseFloat(parts[2]) || 0,
          realValue: parseFloat(parts[3]) || 0,
          currency: parts[4],
          transactionSystemName: parts[5],
        });
      }
    }

    return transactions;
  }
}

// Singleton instance
let purseComponent: PurseComponent | null = null;

export function getPurseComponent(): PurseComponent {
  if (!purseComponent) {
    purseComponent = new PurseComponent();
  }
  return purseComponent;
}

export function resetPurseComponent(): void {
  if (purseComponent) {
    purseComponent.reset();
  }
  purseComponent = null;
}
