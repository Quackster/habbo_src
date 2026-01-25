/**
 * Recycler Module - Item recycling system
 *
 * Ported from: hh_recycler/*.ls
 *
 * This module provides:
 * - Recycling 5 items into mystery prizes
 * - Recycler status tracking
 * - Timeout handling
 *
 * Usage:
 * ```typescript
 * import { createRecyclerModule } from './modules/recycler';
 *
 * const recycler = createRecyclerModule();
 * recycler.initialize();
 *
 * // Open recycler
 * recycler.component.openRecycler();
 *
 * // Add items
 * recycler.component.addFurnitureToGivePool('class', 'id', { stripId: '123' });
 * ```
 */

// Types
export * from './types';

// Core Components
export { RecyclerComponent } from './RecyclerComponent';
export { RecyclerInterface } from './RecyclerInterface';
export { RecyclerHandler } from './RecyclerHandler';

// Imports for factory function
import { RecyclerComponent } from './RecyclerComponent';
import { RecyclerInterface } from './RecyclerInterface';
import { RecyclerHandler } from './RecyclerHandler';

/**
 * Recycler module instance
 */
export interface RecyclerModule {
  component: RecyclerComponent;
  interface: RecyclerInterface;
  handler: RecyclerHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create recycler module
 */
export function createRecyclerModule(): RecyclerModule {
  const component = new RecyclerComponent();
  const iface = new RecyclerInterface();
  const handler = new RecyclerHandler();

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
