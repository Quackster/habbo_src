/**
 * Club Module - Habbo Club subscription management
 *
 * Ported from: hh_club/*.ls
 *
 * This module provides:
 * - Club status tracking (days left, periods, etc.)
 * - Club subscription purchasing
 * - Club gift handling
 * - Club info dialogs
 *
 * Usage:
 * ```typescript
 * import { createClubModule } from './modules/club';
 *
 * const club = createClubModule();
 * club.initialize();
 *
 * // Check club status
 * if (club.component.isClubMember()) {
 *   console.log('Days left:', club.component.getDaysLeft());
 * }
 *
 * // Listen for events
 * club.interface.getEvents().on('showStatusWindow', (data) => {
 *   console.log('Showing club status');
 * });
 * ```
 */

// Types
export * from './types';

// Core Components
export { ClubComponent } from './ClubComponent';
export { ClubInterface } from './ClubInterface';
export { ClubHandler } from './ClubHandler';

// Imports for factory function
import { ClubComponent } from './ClubComponent';
import { ClubInterface } from './ClubInterface';
import { ClubHandler } from './ClubHandler';

/**
 * Club module instance
 */
export interface ClubModule {
  component: ClubComponent;
  interface: ClubInterface;
  handler: ClubHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create club module
 */
export function createClubModule(): ClubModule {
  const component = new ClubComponent();
  const iface = new ClubInterface();
  const handler = new ClubHandler();

  // Set up ICH relationships
  component.setInterface(iface);
  iface.setComponent(component);
  handler.setInterface(iface);
  handler.setComponent(component);

  return {
    component,
    interface: iface,
    handler,

    initialize(): void {
      component.construct();
      iface.construct();
      handler.construct();
    },

    destroy(): void {
      handler.deconstruct();
      iface.deconstruct();
      component.deconstruct();
    },
  };
}
