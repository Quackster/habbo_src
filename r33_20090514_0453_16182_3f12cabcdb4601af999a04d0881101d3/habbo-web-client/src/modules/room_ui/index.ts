/**
 * Room UI Module - Room interface components
 *
 * Ported from: hh_room_ui/*.ls
 *
 * This module provides:
 * - RoomGUI: Main coordinator for room UI elements
 * - RoomBar: Bottom bar with chat, icons, and controls
 * - RoomInfo: Room name, owner, ratings, and events
 * - RoomObjectDisplayer: Infostand for users, furniture, pets
 * - EffectInventory: Avatar effects management
 *
 * Features:
 * - Chat input with flood protection
 * - Speech modes (talk, shout, whisper)
 * - Icon buttons (navigator, catalog, purse, etc.)
 * - Room rating system
 * - Room event display
 * - Object infostand with actions
 * - User tags display
 * - Avatar effects UI
 * - Typing indicator
 * - IM icon with flash/bounce
 *
 * Usage:
 * ```typescript
 * import { createRoomUIModule } from './modules/room_ui';
 *
 * const roomUI = createRoomUIModule();
 * roomUI.initialize();
 *
 * // Show room bar
 * roomUI.gui.showRoomBar();
 *
 * // Show object info
 * roomUI.gui.showObjectInfo('user');
 *
 * // Listen for events
 * roomUI.gui.getRoomBar()?.on('chat_submit', ({ text }) => {
 *   console.log('Chat:', text);
 * });
 *
 * // Clean up
 * roomUI.destroy();
 * ```
 */

// Types
export * from './types';

// Classes
export { RoomGUI } from './RoomGUI';
export { RoomBar } from './RoomBar';
export { RoomInfo } from './RoomInfo';
export { RoomObjectDisplayer } from './RoomObjectDisplayer';
export { EffectInventory, type EffectData } from './EffectInventory';

// Imports for factory function
import { RoomGUI } from './RoomGUI';
import { RoomBar } from './RoomBar';
import { RoomInfo } from './RoomInfo';
import { RoomObjectDisplayer } from './RoomObjectDisplayer';
import { EffectInventory } from './EffectInventory';

/**
 * Room UI module instance
 */
export interface RoomUIModule {
  gui: RoomGUI;
  roomBar: RoomBar;
  roomInfo: RoomInfo;
  objectDisplayer: RoomObjectDisplayer;
  effectInventory: EffectInventory;

  initialize(): void;
  destroy(): void;
}

/**
 * Create room UI module
 */
export function createRoomUIModule(): RoomUIModule {
  const gui = new RoomGUI();
  const roomBar = new RoomBar();
  const roomInfo = new RoomInfo();
  const objectDisplayer = new RoomObjectDisplayer();
  const effectInventory = new EffectInventory();

  return {
    gui,
    roomBar,
    roomInfo,
    objectDisplayer,
    effectInventory,

    initialize(): void {
      roomBar.construct();
      roomInfo.construct();
      objectDisplayer.construct();
      effectInventory.construct();
      gui.construct();
    },

    destroy(): void {
      gui.deconstruct();
      effectInventory.deconstruct();
      objectDisplayer.deconstruct();
      roomInfo.deconstruct();
      roomBar.deconstruct();
    },
  };
}
