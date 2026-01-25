/**
 * Poll Module - Survey/poll system
 *
 * Ported from: hh_poll/*.ls
 *
 * This module provides:
 * - Poll offer handling
 * - Multiple choice questions
 * - Free text answers
 * - Multi-question polls
 *
 * Usage:
 * ```typescript
 * import { createPollModule } from './modules/poll';
 *
 * const poll = createPollModule();
 * poll.initialize();
 *
 * // Listen for poll offers
 * poll.interface.getEvents().on('showOffer', (data) => {
 *   console.log('Poll offered:', data.description);
 * });
 * ```
 */

// Types
export * from './types';

// Core Components
export { PollComponent } from './PollComponent';
export { PollInterface } from './PollInterface';
export { PollHandler } from './PollHandler';

// Imports for factory function
import { PollComponent } from './PollComponent';
import { PollInterface } from './PollInterface';
import { PollHandler } from './PollHandler';

/**
 * Poll module instance
 */
export interface PollModule {
  component: PollComponent;
  interface: PollInterface;
  handler: PollHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create poll module
 */
export function createPollModule(): PollModule {
  const component = new PollComponent();
  const iface = new PollInterface();
  const handler = new PollHandler();

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
