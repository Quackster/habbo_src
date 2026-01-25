/**
 * Avatar System Exports
 *
 * Complete avatar/figure rendering system ported from hh_human:
 * - Figure data parsing and management
 * - Avatar sprite composition
 * - Animation frame handling
 * - Color tinting and rendering
 */

// Types
export * from './types';

// Figure Data
export { FigureData } from './FigureData';

// Figure System
export { FigureSystem, getFigureSystem, resetFigureSystem } from './FigureSystem';

// Avatar Renderer
export { AvatarRenderer } from './AvatarRenderer';
