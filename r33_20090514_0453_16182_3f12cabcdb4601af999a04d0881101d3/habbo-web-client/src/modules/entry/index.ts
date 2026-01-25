/**
 * Entry Module - Complete entry/login system
 *
 * Ported from:
 * - hh_entry/*.ls - Main entry module
 * - hh_entry_base/*.ls - Base entry interface and animations
 * - hh_entry_init/*.ls - Login initialization
 * - hh_entry_[region]/*.ls - Regional hotel view variants (es, fr, it, jp, nl, no, pl, ru, se, sg, uk, us)
 *
 * This module provides:
 * - Configurable login types (SSO, credentials, quick login)
 * - Regional hotel view animations (clouds, cars, boats, trains, etc.)
 * - Entry bar (bottom toolbar) with icons
 * - Hotel opening hours management
 *
 * Usage:
 * ```typescript
 * import { createEntryModule, EntryConfig, HotelRegion } from './modules/entry';
 *
 * const config: EntryConfig = {
 *   entryType: 'sso',
 *   region: 'uk',
 *   ssoTicket: 'my-sso-ticket',
 *   connection: { host: 'game.habbo.com', port: 30000 },
 * };
 *
 * const entry = createEntryModule(config);
 * entry.initialize();
 *
 * // Change region dynamically
 * entry.setRegion('jp');
 * ```
 */

// Types
export * from './types';

// Animation system
export * from './animations';

// Core Components
export { EntryComponent } from './EntryComponent';
export { EntryInterface, type EntryBarElements } from './EntryInterface';

// Login Components
export { LoginComponent } from './LoginComponent';
export { LoginInterface, type LoginFormState } from './LoginInterface';
export { LoginHandler } from './LoginHandler';

// Opening Hours Components
export { OpeningHoursComponent } from './OpeningHoursComponent';
export { OpeningHoursInterface } from './OpeningHoursInterface';
export { OpeningHoursHandler } from './OpeningHoursHandler';

// Import for factory function
import { EntryConfig, HotelRegion, RegionalConfigs } from './types';
import { EntryComponent } from './EntryComponent';
import { EntryInterface } from './EntryInterface';
import { LoginComponent } from './LoginComponent';
import { LoginInterface } from './LoginInterface';
import { LoginHandler } from './LoginHandler';
import { OpeningHoursComponent } from './OpeningHoursComponent';
import { OpeningHoursInterface } from './OpeningHoursInterface';
import { OpeningHoursHandler } from './OpeningHoursHandler';

/**
 * Entry module instance containing all components
 */
export interface EntryModule {
  // Components
  entryComponent: EntryComponent;
  entryInterface: EntryInterface;
  loginComponent: LoginComponent;
  loginInterface: LoginInterface;
  loginHandler: LoginHandler;
  openingHoursComponent: OpeningHoursComponent;
  openingHoursInterface: OpeningHoursInterface;
  openingHoursHandler: OpeningHoursHandler;

  // Methods
  initialize(): void;
  destroy(): void;
  setRegion(region: HotelRegion): void;
  getConfig(): EntryConfig;
}

/**
 * Create a complete entry module with all components
 */
export function createEntryModule(config: Partial<EntryConfig> = {}): EntryModule {
  // Create default config
  const fullConfig: EntryConfig = {
    entryType: config.entryType ?? 'auto',
    region: config.region ?? 'default',
    connection: config.connection ?? { host: 'localhost', port: 12321 },
    ...config,
  };

  // Create all components
  const entryComponent = new EntryComponent();
  const entryInterface = new EntryInterface(fullConfig);
  const loginComponent = new LoginComponent();
  const loginInterface = new LoginInterface();
  const loginHandler = new LoginHandler();
  const openingHoursComponent = new OpeningHoursComponent();
  const openingHoursInterface = new OpeningHoursInterface();
  const openingHoursHandler = new OpeningHoursHandler();

  // Configure components
  loginComponent.configure(fullConfig);
  loginInterface.configure(fullConfig);

  // Set up ICH relationships (Interface-Component-Handler pattern)
  entryComponent.setInterface(entryInterface);
  entryInterface.setComponent(entryComponent);

  loginComponent.setInterface(loginInterface);
  loginInterface.setComponent(loginComponent);
  loginHandler.setInterface(loginInterface);
  loginHandler.setComponent(loginComponent);

  openingHoursComponent.setInterface(openingHoursInterface);
  openingHoursInterface.setComponent(openingHoursComponent);
  openingHoursHandler.setInterface(openingHoursInterface);
  openingHoursHandler.setComponent(openingHoursComponent);

  return {
    entryComponent,
    entryInterface,
    loginComponent,
    loginInterface,
    loginHandler,
    openingHoursComponent,
    openingHoursInterface,
    openingHoursHandler,

    initialize(): void {
      entryComponent.construct();
      entryInterface.construct();
      loginComponent.construct();
      loginInterface.construct();
      loginHandler.construct();
      openingHoursComponent.construct();
      openingHoursInterface.construct();
      openingHoursHandler.construct();
    },

    destroy(): void {
      openingHoursHandler.deconstruct();
      openingHoursInterface.deconstruct();
      openingHoursComponent.deconstruct();
      loginHandler.deconstruct();
      loginInterface.deconstruct();
      loginComponent.deconstruct();
      entryInterface.deconstruct();
      entryComponent.deconstruct();
    },

    setRegion(region: HotelRegion): void {
      entryInterface.setRegion(region);
      fullConfig.region = region;
    },

    getConfig(): EntryConfig {
      return { ...fullConfig };
    },
  };
}

/**
 * Get available hotel regions
 */
export function getAvailableRegions(): HotelRegion[] {
  return Object.keys(RegionalConfigs) as HotelRegion[];
}

/**
 * Get regional configuration
 */
export function getRegionalConfig(region: HotelRegion) {
  return RegionalConfigs[region] ?? RegionalConfigs.default;
}
