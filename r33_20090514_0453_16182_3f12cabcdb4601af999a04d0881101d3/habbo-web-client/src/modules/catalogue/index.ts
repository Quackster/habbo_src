/**
 * Catalogue Module Exports
 *
 * Complete catalogue/shop system ported from hh_cat_code:
 * - Catalogue index and page browsing
 * - Product purchasing
 * - Gift functionality
 * - Credits and tickets tracking
 */

// Types
export * from './types';

// Catalogue Component
export {
  CatalogueComponent,
  getCatalogueComponent,
  resetCatalogueComponent,
} from './CatalogueComponent';

// Catalogue Handler
export {
  CatalogueHandler,
  getCatalogueHandler,
  resetCatalogueHandler,
} from './CatalogueHandler';
