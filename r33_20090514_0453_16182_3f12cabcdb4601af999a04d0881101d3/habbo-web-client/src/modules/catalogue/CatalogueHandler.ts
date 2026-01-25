/**
 * Catalogue Handler Class
 *
 * Handles server messages for the catalogue system.
 * Ported from hh_cat_code Cast External ParentScript 5.
 */

import {
  CATALOGUE_MESSAGE_IDS,
  CATALOGUE_COMMANDS,
  GiftProps,
} from './types';
import { getCatalogueComponent } from './CatalogueComponent';

type MessageHandler = (data: string) => void;

export class CatalogueHandler {
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
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.PURSE,
      this.handlePurse.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.PURCHASE_ERROR,
      this.handlePurchaseError.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.PURCHASE_OK,
      this.handlePurchaseOk.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.PURCHASE_NOBALANCE,
      this.handlePurchaseNoBalance.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.TICKETS,
      this.handleTickets.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.TICKETS_ALT,
      this.handleTickets.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.CATALOG_INDEX,
      this.handleCatalogIndex.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.CATALOG_PAGE,
      this.handleCatalogPage.bind(this)
    );
    this.handlers.set(
      CATALOGUE_MESSAGE_IDS.PURCHASE_NOT_ALLOWED,
      this.handlePurchaseNotAllowed.bind(this)
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
    this.emit('credits_updated', { credits });
  }

  /**
   * Handle purchase OK
   */
  private handlePurchaseOk(_msgData: string): void {
    getCatalogueComponent().handlePurchaseResult('OK');
  }

  /**
   * Handle purchase error
   */
  private handlePurchaseError(msgData: string): void {
    getCatalogueComponent().handlePurchaseResult('ERROR', msgData);
  }

  /**
   * Handle purchase no balance
   */
  private handlePurchaseNoBalance(_msgData: string): void {
    getCatalogueComponent().handlePurchaseResult('NOBALANCE');
  }

  /**
   * Handle tickets update
   */
  private handleTickets(msgData: string): void {
    const tickets = parseInt(msgData.split(/\s+/)[0], 10) || 0;
    this.emit('tickets_updated', { tickets });
  }

  /**
   * Handle catalogue index
   */
  private handleCatalogIndex(msgData: string): void {
    const component = getCatalogueComponent();
    const indexData = component.parseIndexData(msgData);
    component.saveCatalogueIndex(indexData);
  }

  /**
   * Handle catalogue page
   */
  private handleCatalogPage(msgData: string): void {
    const component = getCatalogueComponent();
    const pageData = component.parsePageData(msgData);

    if (pageData) {
      component.saveCataloguePage(pageData);
    }
  }

  /**
   * Handle purchase not allowed
   */
  private handlePurchaseNotAllowed(msgData: string): void {
    const code = parseInt(msgData, 10) || 0;

    let reason = 'unknown';
    switch (code) {
      case 0:
        reason = 'generic';
        break;
      case 1:
        reason = 'hc_required';
        break;
    }

    this.emit('purchase_not_allowed', { code, reason });
  }

  // ============== Command Senders ==============

  /**
   * Request catalogue index
   */
  requestCatalogueIndex(): void {
    const component = getCatalogueComponent();
    const editMode = component.getEditMode();
    const language = component.getLanguage();

    // Check if we already have the index cached
    if (component.hasIndex() && editMode !== 'develop') {
      this.emit('index_loaded', component.getCatalogueIndex());
      return;
    }

    this.sendMessage(CATALOGUE_COMMANDS.GCIX, `${editMode}/${language}`);
  }

  /**
   * Request catalogue page
   */
  requestCataloguePage(pageId: string): void {
    const component = getCatalogueComponent();
    const editMode = component.getEditMode();
    const language = component.getLanguage();

    component.setLastSelectedPageId(pageId);
    component.clearProductOrderData();

    // Check if we already have the page cached
    const cachedPage = component.getCataloguePage(pageId);
    if (cachedPage && editMode !== 'develop') {
      this.emit('page_loaded', cachedPage);
      return;
    }

    this.sendMessage(
      CATALOGUE_COMMANDS.GCAP,
      `${editMode}/${pageId}/${language}`
    );
  }

  /**
   * Purchase product
   */
  purchaseProduct(giftProps?: GiftProps): boolean {
    const component = getCatalogueComponent();
    const purchaseData = component.buildPurchaseData(giftProps);

    if (!purchaseData) {
      return false;
    }

    // Build message
    const parts: string[] = [];

    // Edit mode
    parts.push(purchaseData[0]);
    // Page ID
    parts.push(purchaseData[1]);
    // Language
    parts.push(purchaseData[2]);
    // Purchase code
    parts.push(purchaseData[3]);
    // Extra param
    parts.push(purchaseData[4]);

    // Gift flag and data
    if (purchaseData[5] === '1') {
      parts.push('1');
      parts.push(purchaseData[6] || ''); // receiver
      parts.push(purchaseData[7] || ''); // message
    } else {
      parts.push('0');
    }

    this.sendMessage(CATALOGUE_COMMANDS.PURCHASE_FROM_CATALOG, parts.join('\t'));
    return true;
  }

  /**
   * Purchase product as gift
   */
  purchaseAsGift(receiverName: string, message: string): boolean {
    return this.purchaseProduct({
      gift: true,
      giftReceiver: receiverName,
      giftMsg: message,
    });
  }
}

// Singleton instance
let catalogueHandler: CatalogueHandler | null = null;

export function getCatalogueHandler(
  sendMessage?: (msgId: number, data?: string) => void
): CatalogueHandler {
  if (!catalogueHandler) {
    if (!sendMessage) {
      throw new Error('sendMessage function required for initial creation');
    }
    catalogueHandler = new CatalogueHandler(sendMessage);
  }
  return catalogueHandler;
}

export function resetCatalogueHandler(): void {
  catalogueHandler = null;
}
