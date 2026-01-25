/**
 * Sound Machine Module - Music creation and jukebox
 *
 * Ported from: hh_soundmachine/*.ls
 *
 * This module provides:
 * - Sound machine music editor with timeline
 * - Sample-based song composition
 * - Sound set management (load/eject)
 * - Song saving and playlist management
 * - Jukebox with disk management
 * - Song playback control
 *
 * Usage:
 * ```typescript
 * import { createSoundMachineModule } from './modules/soundmachine';
 *
 * const soundmachine = createSoundMachineModule();
 * soundmachine.initialize();
 *
 * // Show sound machine editor
 * soundmachine.interface.showSoundMachine();
 *
 * // Show jukebox
 * soundmachine.interface.showJukebox();
 *
 * // Listen for events
 * soundmachine.interface.getEvents().on('showSoundMachine', () => {
 *   console.log('Sound machine opened');
 * });
 * ```
 */

// Types
export * from './types';

// Core Classes
export { SongTimeline } from './SongTimeline';
export { SongListManager } from './SongListManager';
export { JukeboxManager } from './JukeboxManager';

// Core Components
export { SoundMachineComponent } from './SoundMachineComponent';
export { SoundMachineInterface } from './SoundMachineInterface';
export { SoundMachineHandler } from './SoundMachineHandler';

// Imports for factory function
import { SoundMachineComponent } from './SoundMachineComponent';
import { SoundMachineInterface } from './SoundMachineInterface';
import { SoundMachineHandler } from './SoundMachineHandler';

/**
 * Sound Machine module instance
 */
export interface SoundMachineModule {
  component: SoundMachineComponent;
  interface: SoundMachineInterface;
  handler: SoundMachineHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create sound machine module
 */
export function createSoundMachineModule(): SoundMachineModule {
  const component = new SoundMachineComponent();
  const iface = new SoundMachineInterface();
  const handler = new SoundMachineHandler();

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
