/**
 * Photo Module - Camera and photo system
 *
 * Ported from: hh_photo/*.ls
 *
 * This module provides:
 * - Camera interface with live preview
 * - Photo capture with vintage effect
 * - Zoom functionality
 * - Photo storage with text captions
 * - Photo viewer for room items
 * - Film count management
 *
 * Usage:
 * ```typescript
 * import { createPhotoModule } from './modules/photo';
 *
 * const photo = createPhotoModule();
 * photo.initialize();
 *
 * // Open camera
 * photo.interface.open();
 *
 * // Listen for events
 * photo.interface.getEvents().on('photoCapture', (canvas) => {
 *   console.log('Photo captured');
 * });
 * ```
 */

// Types
export * from './types';

// Core Components
export { PhotoComponent } from './PhotoComponent';
export { PhotoInterface } from './PhotoInterface';
export { PhotoHandler } from './PhotoHandler';
export { PhotoItem } from './PhotoItem';

// Imports for factory function
import { PhotoComponent } from './PhotoComponent';
import { PhotoInterface } from './PhotoInterface';
import { PhotoHandler } from './PhotoHandler';

/**
 * Photo module instance
 */
export interface PhotoModule {
  component: PhotoComponent;
  interface: PhotoInterface;
  handler: PhotoHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create photo module
 */
export function createPhotoModule(): PhotoModule {
  const component = new PhotoComponent();
  const iface = new PhotoInterface();
  const handler = new PhotoHandler();

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
