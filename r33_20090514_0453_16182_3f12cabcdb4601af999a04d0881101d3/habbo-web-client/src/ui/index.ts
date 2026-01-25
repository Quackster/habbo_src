/**
 * UI System Exports
 *
 * Complete UI system ported from fuse_client:
 * - Window Manager and Window Instance
 * - Visualizer Manager
 * - Layout Parser
 * - Sprite Manager
 * - Element classes (Base, Unique, Wrapper)
 */

// Types
export * from './types';

// Sprite Manager
export { spriteManager, getSpriteManager, reserveSprite, releaseSprite, getSprite } from './SpriteManager';

// Layout Parser
export { layoutParser, getLayoutParser } from './LayoutParser';

// Window System
export {
  getWindowManager,
  createWindow,
  removeWindow,
  getWindow,
  windowExists,
  activateWindow,
  deactivateWindow,
  mergeWindow,
  registerClient,
  registerProcedure,
  showWindows,
  hideWindows,
  lockWindowLayering,
  unlockWindowLayering,
  getWindowIdList,
} from './WindowManager';

export { WindowInstance } from './WindowInstance';

// Visualizer System
export {
  getVisualizerManager,
  createVisualizer,
  removeVisualizer,
  getVisualizer,
  visualizerExists,
  hideVisualizers,
  showVisualizers,
  type VisualizerInstance,
} from './VisualizerManager';

// Element classes
export { BaseElement, UniqueElement, WrapperElement } from './elements';
