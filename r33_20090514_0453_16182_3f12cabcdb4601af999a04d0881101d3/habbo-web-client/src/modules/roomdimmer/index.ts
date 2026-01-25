/**
 * Room Dimmer Module - Room lighting/mood control
 *
 * Ported from: hh_roomdimmer/*.ls
 *
 * This module provides:
 * - Room dimmer control with presets
 * - Color transitions with smooth animation
 * - HSL color manipulation
 * - Toggle on/off
 *
 * Usage:
 * ```typescript
 * import { createRoomDimmerModule } from './modules/roomdimmer';
 *
 * const dimmer = createRoomDimmerModule();
 * dimmer.initialize();
 *
 * // Toggle dimmer
 * dimmer.component.toggleOnOff();
 *
 * // Listen for events
 * dimmer.interface.getEvents().on('updateInterface', () => {
 *   console.log('Dimmer updated');
 * });
 * ```
 */

// Types
export * from './types';

// Core Components
export { RoomDimmerComponent } from './RoomDimmerComponent';
export { RoomDimmerInterface } from './RoomDimmerInterface';
export { RoomDimmerHandler } from './RoomDimmerHandler';

// Imports for factory function
import { RoomDimmerComponent } from './RoomDimmerComponent';
import { RoomDimmerInterface } from './RoomDimmerInterface';
import { RoomDimmerHandler } from './RoomDimmerHandler';

/**
 * Room Dimmer module instance
 */
export interface RoomDimmerModule {
  component: RoomDimmerComponent;
  interface: RoomDimmerInterface;
  handler: RoomDimmerHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create room dimmer module
 */
export function createRoomDimmerModule(): RoomDimmerModule {
  const component = new RoomDimmerComponent();
  const iface = new RoomDimmerInterface();
  const handler = new RoomDimmerHandler();

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
