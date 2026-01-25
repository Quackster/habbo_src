/**
 * Instant Messenger Module
 *
 * Ported from: hh_instant_messenger/*.ls
 *
 * This module provides:
 * - Real-time chat with friends
 * - Friend invitations to rooms
 * - Chat notifications and tabs
 * - Online/offline status notifications
 *
 * Usage:
 * ```typescript
 * import { createInstantMessengerModule } from './modules/instant_messenger';
 *
 * const im = createInstantMessengerModule();
 * im.initialize();
 *
 * // Start a chat
 * im.component.startIMChat('FriendName', 'Hello!');
 *
 * // Listen for events
 * im.interface.getEvents().on('addMessage', (data) => {
 *   console.log('New message:', data);
 * });
 * ```
 */

// Types
export * from './types';

// Core Components
export { InstantMessengerComponent } from './InstantMessengerComponent';
export { InstantMessengerInterface } from './InstantMessengerInterface';
export { InstantMessengerHandler } from './InstantMessengerHandler';

// Imports for factory function
import { InstantMessengerComponent } from './InstantMessengerComponent';
import { InstantMessengerInterface } from './InstantMessengerInterface';
import { InstantMessengerHandler } from './InstantMessengerHandler';

/**
 * Instant Messenger module instance
 */
export interface InstantMessengerModule {
  component: InstantMessengerComponent;
  interface: InstantMessengerInterface;
  handler: InstantMessengerHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create instant messenger module
 */
export function createInstantMessengerModule(): InstantMessengerModule {
  const component = new InstantMessengerComponent();
  const iface = new InstantMessengerInterface();
  const handler = new InstantMessengerHandler();

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
