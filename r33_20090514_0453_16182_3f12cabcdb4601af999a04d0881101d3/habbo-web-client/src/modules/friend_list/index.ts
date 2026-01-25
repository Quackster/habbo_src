/**
 * Friend List Module
 *
 * Ported from: hh_friend_list/*.ls
 *
 * This module provides:
 * - Friend list management with categories
 * - Friend request handling (accept/reject)
 * - Habbo search functionality
 * - Mail notifications
 * - Follow friend functionality
 *
 * Usage:
 * ```typescript
 * import { createFriendListModule } from './modules/friend_list';
 *
 * const friendList = createFriendListModule();
 * friendList.initialize();
 *
 * // Access components
 * const component = friendList.component;
 * const iface = friendList.interface;
 *
 * // Listen for events
 * iface.getEvents().on('categoryChanged', (data) => {
 *   console.log('Category changed:', data);
 * });
 * ```
 */

// Types
export * from './types';

// Containers
export { FriendListContainer } from './FriendListContainer';
export { FriendRequestContainer } from './FriendRequestContainer';

// Core Components
export { FriendListComponent } from './FriendListComponent';
export { FriendListInterface, type FriendListViewObject } from './FriendListInterface';
export { FriendListHandler } from './FriendListHandler';

// Imports for factory function
import { FriendListComponent } from './FriendListComponent';
import { FriendListInterface } from './FriendListInterface';
import { FriendListHandler } from './FriendListHandler';

/**
 * Friend list module instance
 */
export interface FriendListModule {
  component: FriendListComponent;
  interface: FriendListInterface;
  handler: FriendListHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create friend list module
 */
export function createFriendListModule(): FriendListModule {
  const component = new FriendListComponent();
  const iface = new FriendListInterface();
  const handler = new FriendListHandler();

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
