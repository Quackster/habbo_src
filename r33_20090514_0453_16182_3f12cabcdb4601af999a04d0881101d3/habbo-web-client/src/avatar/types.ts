/**
 * Avatar/Figure System Types
 *
 * Type definitions for the figure rendering system ported from hh_human
 */

// Figure part definition
export interface FigurePart {
  model: string;
  color: string; // RGB hex color
  setId?: string;
  colorId?: string | number;
}

// Parsed figure data
export interface ParsedFigure {
  [partType: string]: FigurePart;
}

// Figure set data
export interface FigureSetData {
  id: string;
  type: string;
  gender: 'M' | 'F' | 'U';
  club: number;
  colorable: boolean;
  selectable: boolean;
  previewable: boolean;
  hiddenLayers?: string[];
  parts: FigureSetPart[];
}

// Figure set part
export interface FigureSetPart {
  id: string;
  type: string;
  colorable: boolean;
  colorIndex?: number;
}

// Figure color data
export interface FigureColor {
  id: number;
  index: number;
  club: number;
  selectable: boolean;
  hexColor: string;
}

// Animation frame
export interface AnimationFrame {
  number: number;
  assetPartDefinition?: string;
  repeats?: number;
}

// Animation definition
export interface AnimationDefinition {
  id: string;
  parts: {
    [partType: string]: AnimationFrame[];
  };
}

// Draw order for direction
export interface DrawOrder {
  direction: number;
  parts: string[];
}

// Avatar action
export interface AvatarAction {
  id: string;
  state: string;
  precedence: number;
  main: boolean;
  geometryType: string;
  activePartSet?: string;
  assetPartDefinition?: string;
  lay?: string;
  preventHeadTurn?: boolean;
}

// Avatar effect
export interface AvatarEffect {
  id: number;
  lib: string;
  type: string;
  duration: number;
}

// Avatar sprite sheet
export interface AvatarSpriteSheet {
  image: HTMLImageElement | ImageBitmap;
  frames: Map<string, SpriteFrame>;
}

// Sprite frame
export interface SpriteFrame {
  x: number;
  y: number;
  width: number;
  height: number;
  regX: number;
  regY: number;
  flipH?: boolean;
}

// Avatar render state
export interface AvatarRenderState {
  figure: ParsedFigure;
  direction: number;
  headDirection: number;
  action: string;
  gesture: string;
  carryItem?: number;
  effect?: number;
  frame: number;
  isGhost: boolean;
}

// Part set definition
export interface PartSetDefinition {
  full: string[];
  swim: string[];
  small: string[];
  swimSmall: string[];
  flipList: Map<string, string>;
  removeList: Map<string, string>;
}

// Active part set
export interface ActivePartSet {
  id: string;
  parts: string[];
}
