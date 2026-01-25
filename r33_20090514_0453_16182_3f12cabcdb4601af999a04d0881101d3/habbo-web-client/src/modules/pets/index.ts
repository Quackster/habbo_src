/**
 * Pets Common Module - Pet rendering and animation
 *
 * Ported from: hh_pets_common/*.ls
 *
 * This module provides:
 * - Pet entity with parts (head, body, tail)
 * - Pet animations (walk, sit, lay, jump, etc.)
 * - Pet gesture system (emotions, expressions)
 * - Part-based rendering with palettes and colors
 * - Direction-based sprite selection with flipping
 *
 * Usage:
 * ```typescript
 * import { Pet, PetData, PetDefinition } from './modules/pets';
 *
 * // Create pet
 * const pet = new Pet();
 * pet.construct();
 * pet.setGeometry(roomGeometry);
 * pet.setPetDefinitions(petDefs);
 * pet.setAssetCallbacks(getAsset, applyPalette);
 *
 * // Define pet from server data
 * pet.define({
 *   name: 'Fluffy',
 *   class: 'dog',
 *   direction: [2],
 *   x: 5,
 *   y: 5,
 *   h: 0,
 *   figure: '0 4 AA98EF',
 * });
 *
 * // Update each frame
 * pet.update();
 *
 * // Get canvas for rendering
 * const canvas = pet.getCanvas();
 * const renderData = pet.getRenderData();
 *
 * // Trigger actions
 * pet.action_sit('sit 0.5');
 * pet.action_wav('');
 * pet.action_gst('gst sml');
 * ```
 */

// Types
export * from './types';

// Core Classes
export { PetPart } from './PetPart';
export { Pet } from './Pet';
