/**
 * Catalogue Module Types
 *
 * Type definitions for the catalogue/shop system ported from hh_cat_code
 */

// Product definition
export interface CatalogueProduct {
  purchaseCode: string;
  name: string;
  description?: string;
  specialText?: string;
  price: number;
  class: string;
  objectType: string;
  direction: number;
  dimensions: string;
  partColors?: string;
  prewImage?: number;
  smallPrewImg?: number;
  smallColorFlag?: number;
  dealNumber?: number;
  dealList?: DealItem[];
  extraParam?: string;
}

// Deal item (for product bundles)
export interface DealItem {
  class: string;
  count: number;
  partColors?: string;
}

// Catalogue page definition
export interface CataloguePage {
  id: string;
  pageName: string;
  layout: string;
  headerText: string;
  headerImage?: string;
  teaserText?: string;
  teaserImgList?: string[];
  teaserSpecialText?: string;
  textList?: string[];
  linkList?: string[];
  productList: CatalogueProduct[];
}

// Catalogue index entry
export interface CatalogueIndexEntry {
  id: string;
  name: string;
  color: string;
  icon: string;
  visible: boolean;
}

// Gift properties
export interface GiftProps {
  gift: boolean;
  giftReceiver?: string;
  giftMsg?: string;
}

// Product order data
export interface ProductOrderData {
  name: string;
  purchaseCode: string;
  price: number;
  extraParam?: string;
}

// Catalogue state
export interface CatalogueState {
  catalogueIndex: Map<string, CatalogueIndexEntry>;
  pages: Map<string, CataloguePage>;
  currentPageId: string | null;
  lastSelectedPageId: string | null;
  productOrderData: ProductOrderData | null;
  editMode: 'production' | 'develop';
  loadingProps: Map<string, LoadingPageData>;
}

// Loading page data (for async asset loading)
export interface LoadingPageData {
  loadList: string[];
  data: CataloguePage;
}

// Message IDs from original Lingo code
export const CATALOGUE_MESSAGE_IDS = {
  PURSE: 6,
  PURCHASE_ERROR: 65,
  PURCHASE_OK: 67,
  PURCHASE_NOBALANCE: 68,
  TICKETS: 72,
  TICKETS_ALT: 124,
  CATALOG_INDEX: 126,
  CATALOG_PAGE: 127,
  PURCHASE_NOT_ALLOWED: 296,
} as const;

// Command IDs for sending messages
export const CATALOGUE_COMMANDS = {
  PURCHASE_FROM_CATALOG: 100,
  GCIX: 101, // Get Catalogue Index
  GCAP: 102, // Get Catalogue Page
} as const;

// Purchase result status
export type PurchaseStatus = 'OK' | 'NOBALANCE' | 'ERROR';

// Product types
export enum ProductType {
  FLOOR = 's',
  WALL = 'i',
}

// Catalogue event types
export type CatalogueEventType =
  | 'index_loaded'
  | 'page_loaded'
  | 'purchase_ok'
  | 'purchase_error'
  | 'purchase_nobalance'
  | 'credits_updated'
  | 'tickets_updated';

export interface CatalogueEvent {
  type: CatalogueEventType;
  data: unknown;
}
