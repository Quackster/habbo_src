/**
 * Furniture Module - Room furniture and wall items
 *
 * Ported from: hh_furni_classes/*.ls
 *
 * This module provides:
 * - ActiveObject: Base class for interactive floor furniture
 * - PassiveObject: Static wall/floor decorations
 * - ItemObject: Wall-mounted items (posters, post-its, photos)
 * - ActiveObjectExtension: Animated/stateful furniture
 * - Specialized furniture classes (Dice, Wheel, Present, etc.)
 * - PreviewRenderer: Furniture preview image generation
 *
 * Class Hierarchy:
 * ```
 * BaseObject
 *   ├── ActiveObject (floor furniture)
 *   │     └── ActiveObjectExtension (animated furniture)
 *   │           ├── Dice
 *   │           ├── HabboWheel
 *   │           └── Present
 *   ├── PassiveObject (static decorations)
 *   ├── ItemObject (wall items)
 *   │     └── PostItItem
 *   └── PreviewRenderer
 * ```
 *
 * Usage:
 * ```typescript
 * import {
 *   ActiveObject,
 *   ActiveObjectExtension,
 *   ItemObject,
 *   Dice,
 *   createFurnitureModule
 * } from './modules/furni';
 *
 * // Create furniture module
 * const furni = createFurnitureModule();
 * furni.initialize();
 *
 * // Create floor furniture
 * const chair = new ActiveObject();
 * chair.setGeometry(roomGeometry);
 * chair.define({
 *   class: 'chair_polyfon',
 *   x: 5, y: 3,
 *   direction: [2],
 *   dimensions: [1, 1],
 *   altitude: 0,
 *   colors: '255,255,255'
 * });
 *
 * // Create animated furniture
 * const lamp = new ActiveObjectExtension();
 * lamp.define({
 *   class: 'lamp_basic',
 *   x: 2, y: 4,
 *   direction: [0],
 *   dimensions: [1, 1],
 *   altitude: 0,
 *   props: { stuffdata: '1' }  // State
 * });
 * lamp.update();  // Animate
 *
 * // Create dice
 * const dice = new Dice();
 * dice.define({ class: 'edice', x: 3, y: 3, ... });
 * dice.throwDice();
 *
 * // Clean up
 * furni.destroy();
 * ```
 */

// Types
export * from './types';

// Base Classes
export { ActiveObject } from './ActiveObject';
export { PassiveObject } from './PassiveObject';
export { ItemObject } from './ItemObject';
export { ActiveObjectExtension } from './ActiveObjectExtension';

// Utilities
export { PreviewRenderer } from './PreviewRenderer';

// Specialized Furniture
export * from './specialized';

// Factory function
import { PreviewRenderer } from './PreviewRenderer';
import { PostItManager } from './specialized';

/**
 * Furniture module instance
 */
export interface FurnitureModule {
  previewRenderer: PreviewRenderer;
  postItManager: PostItManager;

  initialize(): void;
  destroy(): void;
}

/**
 * Create furniture module
 */
export function createFurnitureModule(): FurnitureModule {
  const previewRenderer = new PreviewRenderer();
  const postItManager = new PostItManager();

  return {
    previewRenderer,
    postItManager,

    initialize(): void {
      previewRenderer.construct();
      postItManager.construct();
    },

    destroy(): void {
      postItManager.deconstruct();
      previewRenderer.deconstruct();
    },
  };
}

/**
 * Furniture class registry
 * Maps furniture class names to their specialized implementations
 */
export const FurnitureClassRegistry: Record<string, new () => ActiveObject | ActiveObjectExtension | ItemObject> = {
  // Add specialized classes here as they're implemented
  // 'edice': Dice,
  // 'habbowheel': HabboWheel,
  // 'present_gen': Present,
  // 'post.it': PostItItem,
};

// Import for factory function
import { ActiveObject } from './ActiveObject';
import { ActiveObjectExtension } from './ActiveObjectExtension';
import { ItemObject } from './ItemObject';

/**
 * Create furniture instance by class name
 */
export function createFurnitureByClass(
  className: string,
  isAnimated: boolean = false
): ActiveObject | ActiveObjectExtension | ItemObject {
  const ClassConstructor = FurnitureClassRegistry[className];

  if (ClassConstructor) {
    return new ClassConstructor();
  }

  // Return base class based on naming conventions
  if (className.includes('post.it') || className === 'poster' || className === 'photo') {
    return new ItemObject();
  }

  // Return animated or basic active object
  if (isAnimated) {
    return new ActiveObjectExtension();
  }

  return new ActiveObject();
}
