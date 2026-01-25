/**
 * Catalogue Component Class
 *
 * Manages catalogue state, pages, and purchase operations.
 * Ported from hh_cat_code Cast External ParentScript 4.
 */

import {
  CatalogueState,
  CataloguePage,
  CatalogueIndexEntry,
  CatalogueProduct,
  ProductOrderData,
  GiftProps,
  LoadingPageData,
  PurchaseStatus,
} from './types';

export class CatalogueComponent {
  private state: CatalogueState;
  private imageLibraryUrl: string =
    'http://images.habbohotel.com/c_images/';
  private language: string = 'en';
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor() {
    this.state = {
      catalogueIndex: new Map(),
      pages: new Map(),
      currentPageId: null,
      lastSelectedPageId: null,
      productOrderData: null,
      editMode: 'production',
      loadingProps: new Map(),
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
   * Reset catalogue state
   */
  reset(): void {
    this.state.catalogueIndex.clear();
    this.state.pages.clear();
    this.state.currentPageId = null;
    this.state.lastSelectedPageId = null;
    this.state.productOrderData = null;
    this.state.loadingProps.clear();
  }

  /**
   * Set language
   */
  setLanguage(lang: string): void {
    this.language = lang;
  }

  /**
   * Get language
   */
  getLanguage(): string {
    return this.language;
  }

  /**
   * Set image library URL
   */
  setImageLibraryUrl(url: string): void {
    this.imageLibraryUrl = url;
  }

  /**
   * Get image library URL
   */
  getImageLibraryUrl(): string {
    return this.imageLibraryUrl;
  }

  /**
   * Set edit mode
   */
  setEditMode(mode: 'production' | 'develop'): void {
    this.state.editMode = mode;
  }

  /**
   * Get edit mode
   */
  getEditMode(): 'production' | 'develop' {
    return this.state.editMode;
  }

  // ============== Index ==============

  /**
   * Save catalogue index
   */
  saveCatalogueIndex(entries: Map<string, CatalogueIndexEntry>): void {
    this.state.catalogueIndex = entries;
    this.emit('index_loaded', entries);
  }

  /**
   * Get catalogue index
   */
  getCatalogueIndex(): Map<string, CatalogueIndexEntry> {
    return this.state.catalogueIndex;
  }

  /**
   * Check if index is loaded
   */
  hasIndex(): boolean {
    return this.state.catalogueIndex.size > 0;
  }

  // ============== Pages ==============

  /**
   * Save catalogue page
   */
  saveCataloguePage(page: CataloguePage): void {
    this.state.pages.set(page.id, page);
    this.state.currentPageId = page.id;
    this.emit('page_loaded', page);
  }

  /**
   * Get catalogue page
   */
  getCataloguePage(pageId: string): CataloguePage | undefined {
    return this.state.pages.get(pageId);
  }

  /**
   * Get current page
   */
  getCurrentPage(): CataloguePage | undefined {
    if (this.state.currentPageId) {
      return this.state.pages.get(this.state.currentPageId);
    }
    return undefined;
  }

  /**
   * Set last selected page ID
   */
  setLastSelectedPageId(pageId: string): void {
    this.state.lastSelectedPageId = pageId;
  }

  /**
   * Get last selected page ID
   */
  getLastSelectedPageId(): string | null {
    return this.state.lastSelectedPageId;
  }

  // ============== Product Order ==============

  /**
   * Check product order and store order data
   */
  checkProductOrder(product: CatalogueProduct): boolean {
    if (!product.purchaseCode) {
      return false;
    }

    this.state.productOrderData = {
      name: product.name || 'ERROR',
      purchaseCode: product.purchaseCode,
      price: product.price || 0,
      extraParam: product.extraParam || '-',
    };

    return true;
  }

  /**
   * Get product order data
   */
  getProductOrderData(): ProductOrderData | null {
    return this.state.productOrderData;
  }

  /**
   * Clear product order data
   */
  clearProductOrderData(): void {
    this.state.productOrderData = null;
  }

  /**
   * Build purchase message data
   */
  buildPurchaseData(giftProps?: GiftProps): string[] | null {
    const orderData = this.state.productOrderData;
    if (!orderData) {
      return null;
    }

    const data: string[] = [
      this.state.editMode,
      this.state.lastSelectedPageId || '',
      this.language,
      orderData.purchaseCode,
      this.convertSpecialChars(orderData.extraParam || '-'),
    ];

    if (giftProps?.gift && giftProps.giftReceiver) {
      data.push('1'); // gift flag
      data.push(giftProps.giftReceiver);
      data.push(this.convertSpecialChars(giftProps.giftMsg || ''));
    } else {
      data.push('0'); // not a gift
    }

    return data;
  }

  // ============== Purchase Results ==============

  /**
   * Handle purchase result
   */
  handlePurchaseResult(status: PurchaseStatus, message?: string): void {
    switch (status) {
      case 'OK':
        this.emit('purchase_ok', null);
        break;
      case 'NOBALANCE':
        this.emit('purchase_nobalance', null);
        break;
      case 'ERROR':
        this.emit('purchase_error', { message });
        break;
    }
  }

  // ============== Loading State ==============

  /**
   * Set page loading data
   */
  setLoadingData(pageId: string, data: LoadingPageData): void {
    this.state.loadingProps.set(pageId, data);
  }

  /**
   * Get page loading data
   */
  getLoadingData(pageId: string): LoadingPageData | undefined {
    return this.state.loadingProps.get(pageId);
  }

  /**
   * Remove loading data
   */
  removeLoadingData(pageId: string): void {
    this.state.loadingProps.delete(pageId);
  }

  /**
   * Check if product is loading
   */
  isProductLoading(productName: string, pageId: string): boolean {
    const loadingData = this.state.loadingProps.get(pageId);
    if (!loadingData) {
      return false;
    }

    const className = this.getClassName(productName);
    return loadingData.loadList.includes(className);
  }

  /**
   * Mark item as downloaded
   */
  markDownloaded(classId: string): void {
    for (const [pageId, loadingData] of this.state.loadingProps) {
      const index = loadingData.loadList.indexOf(classId);
      if (index !== -1) {
        loadingData.loadList.splice(index, 1);

        // If all items loaded, remove loading data
        if (loadingData.loadList.length === 0) {
          this.state.loadingProps.delete(pageId);

          // Emit page loaded if this was the current page
          if (pageId === this.state.lastSelectedPageId) {
            this.emit('page_loaded', loadingData.data);
          }
        }
      }
    }
  }

  // ============== Helpers ==============

  /**
   * Get class name (strip color suffix)
   */
  getClassName(className: string | undefined): string {
    if (!className) {
      return '';
    }
    const asteriskIndex = className.indexOf('*');
    if (asteriskIndex !== -1) {
      return className.substring(0, asteriskIndex);
    }
    return className;
  }

  /**
   * Convert special characters for server
   */
  private convertSpecialChars(text: string): string {
    // Replace special characters that could interfere with protocol
    return text
      .replace(/\r/g, '\\r')
      .replace(/\n/g, '\\n')
      .replace(/\t/g, '\\t');
  }

  /**
   * Parse catalogue index from server data
   */
  parseIndexData(data: string): Map<string, CatalogueIndexEntry> {
    const index = new Map<string, CatalogueIndexEntry>();
    const lines = data.split('\r');

    for (const line of lines) {
      if (line.length < 4) continue;

      const parts = line.split('\t');
      if (parts.length >= 2) {
        const id = parts[0];
        const values = parts[1];

        index.set(id, {
          id,
          name: values,
          color: '',
          icon: '',
          visible: true,
        });
      }
    }

    return index;
  }

  /**
   * Parse catalogue page from server data
   */
  parsePageData(data: string): CataloguePage | null {
    const page: Partial<CataloguePage> = {
      productList: [],
      textList: [],
    };

    const lines = data.split('\r');

    for (const line of lines) {
      if (line.length < 3) continue;

      const prop = line.charAt(0);
      const colonIndex = line.indexOf(':');
      if (colonIndex === -1) continue;

      const content = line.substring(colonIndex + 1);

      switch (prop) {
        case 'i':
          page.id = content;
          break;
        case 'n':
          page.pageName = content;
          break;
        case 'l':
          page.layout = content;
          break;
        case 'h':
          page.headerText = content.replace(/<br>/g, '\n');
          break;
        case 'g':
          page.headerImage = content;
          break;
        case 'w':
          page.teaserText = content.replace(/<br>/g, '\n');
          break;
        case 'e':
          page.teaserImgList = content.split(',').filter((s) => s.length > 0);
          break;
        case 's':
          page.teaserSpecialText = content.replace(/<br>/g, '\n');
          break;
        case 't':
          if (!page.textList) page.textList = [];
          page.textList.push(content.replace(/<br>/g, '\n'));
          break;
        case 'u':
          page.linkList = content.split(',');
          break;
        case 'p':
          const product = this.parseProductData(content);
          if (product) {
            page.productList!.push(product);
          }
          break;
      }
    }

    if (!page.id || !page.layout) {
      return null;
    }

    return page as CataloguePage;
  }

  /**
   * Parse product data from line
   */
  private parseProductData(data: string): CatalogueProduct | null {
    const parts = data.split('\t');
    if (parts.length < 4) return null;

    const product: CatalogueProduct = {
      purchaseCode: parts[0],
      price: parseInt(parts[1], 10) || 0,
      name: '',
      class: '',
      objectType: parts[2],
      direction: 0,
      dimensions: '1,1',
    };

    // Parse class ID and potential color suffix
    const classIdStr = parts[3];
    const spaceIndex = classIdStr.indexOf(' ');
    if (spaceIndex !== -1) {
      product.class = classIdStr.substring(spaceIndex + 1);
    }

    // Parse deal items if present
    if (parts.length > 5) {
      product.dealList = [];
      const count = parseInt(parts[4], 10) || 1;
      product.dealList.push({
        class: product.class,
        count,
      });

      // Additional deal items
      for (let i = 5; i < parts.length; i += 3) {
        if (i + 2 < parts.length) {
          product.dealList.push({
            class: parts[i + 1] || '',
            count: parseInt(parts[i + 2], 10) || 1,
          });
        }
      }

      product.dealNumber = product.dealList.length > 1 ? 1 : 0;
      product.class = '';
    }

    return product;
  }
}

// Singleton instance
let catalogueComponent: CatalogueComponent | null = null;

export function getCatalogueComponent(): CatalogueComponent {
  if (!catalogueComponent) {
    catalogueComponent = new CatalogueComponent();
  }
  return catalogueComponent;
}

export function resetCatalogueComponent(): void {
  if (catalogueComponent) {
    catalogueComponent.reset();
  }
  catalogueComponent = null;
}
