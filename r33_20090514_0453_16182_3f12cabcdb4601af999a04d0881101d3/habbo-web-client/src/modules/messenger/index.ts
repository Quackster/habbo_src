/**
 * Messenger Module Exports
 *
 * Complete messenger/friend system ported from hh_messenger:
 * - Buddy list management
 * - Friend requests
 * - Instant messaging
 * - Follow friend functionality
 */

// Types
export * from './types';

// Messenger Component
export {
  MessengerComponent,
  getMessengerComponent,
  resetMessengerComponent,
} from './MessengerComponent';

// Messenger Handler
export {
  MessengerHandler,
  getMessengerHandler,
  resetMessengerHandler,
} from './MessengerHandler';
