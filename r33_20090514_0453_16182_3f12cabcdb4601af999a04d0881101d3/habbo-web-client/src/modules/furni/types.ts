/**
 * Furniture Module Types
 *
 * Ported from: hh_furni_classes/*.ls
 */

/**
 * Furniture object types
 */
export type FurnitureType = 'active' | 'passive' | 'item';

/**
 * Room type affects rendering behavior
 */
export type RoomType = 'public' | 'private';

/**
 * Ink effects for sprites
 */
export const InkEffects = {
  COPY: 0,
  TRANSPARENT: 1,
  REVERSE: 2,
  GHOST: 3,
  NOT_COPY: 4,
  NOT_TRANSPARENT: 5,
  NOT_REVERSE: 6,
  NOT_GHOST: 7,
  MATTE: 8,
  MASK: 9,
  BLEND: 32,
  ADD_PIN: 33,
  ADD: 34,
  SUBTRACT: 35,
  BACKGROUND_TRANSPARENT: 36,
  LIGHTEST: 37,
  SUBTRACT_PIN: 38,
  DARKEST: 39,
  LIGHTEN: 40,
  DARKEN: 41,
} as const;

/**
 * Default ink effect
 */
export const DEFAULT_INK = InkEffects.MATTE;
export const DEFAULT_BLEND = 100;

/**
 * Base furniture definition data
 */
export interface FurnitureDefinition {
  class: string;
  direction?: number[];
  dimensions?: number[];
  altitude?: number;
  x: number;
  y: number;
  h?: number;
  colors?: string;
  props?: Record<string, unknown>;
  expire?: number;
}

/**
 * Active object specific definition
 */
export interface ActiveObjectDefinition extends FurnitureDefinition {
  altitude: number;
}

/**
 * Passive object definition
 */
export interface PassiveObjectDefinition extends FurnitureDefinition {
  h: number;
}

/**
 * Item (wall) object definition
 */
export interface ItemObjectDefinition {
  class: string;
  x: number;
  y: number;
  h: number;
  z: number;
  local_x: number;
  local_y: number;
  wall_x: number;
  wall_y: number;
  formatVersion: 'old' | 'new';
  direction: 'leftwall' | 'rightwall';
  type: string;
  expire?: number;
}

/**
 * Furniture info returned by getInfo()
 */
export interface FurnitureInfo {
  name: string;
  class: string;
  custom: string;
  expire: number;
  smallmember?: string;
  image?: ImageData | HTMLImageElement | null;
}

/**
 * Screen location with z-index
 */
export interface ScreenLocation {
  x: number;
  y: number;
  z: number;
}

/**
 * Sprite properties from .props file
 */
export interface SpriteProps {
  ink?: number;
  blend?: number;
  zshift?: number[];
  locshift?: Array<{ x: number; y: number } | number>;
  events?: boolean;
  transparent?: boolean;
}

/**
 * Part properties mapping
 */
export type PartPropsMap = Record<string, SpriteProps>;

/**
 * Slide animation state
 */
export interface SlideState {
  startTime: number;
  endTime: number;
  startLoc: [number, number, number];
  destLoc: [number, number, number];
  timePerTile: number;
}

/**
 * Animation layer data
 */
export interface LayerData {
  frames?: number[];
  sequences?: number[][];
  delay?: number;
  loop?: number;
  random?: boolean;
  blend?: number[];
  paletteFrames?: string[];
  paletteIndex?: string[];
}

/**
 * State sequence list for animated furniture
 */
export type StateSequence = number | number[];

/**
 * Animation data from .data files
 */
export interface AnimationData {
  states?: StateSequence[];
  layers?: Record<string, LayerData[]>;
}

/**
 * Shadow properties
 */
export interface ShadowProps {
  member: string;
  locH: number;
  locV: number;
  width: number;
  height: number;
  id: string;
  multiflip?: boolean;
  offsetx?: number;
}

/**
 * Post-it note colors
 */
export const PostItColors = {
  YELLOW: '#FFFF33',
  BLUE: '#9CCEFF',
  PINK: '#FF9CFF',
  GREEN: '#9CFF9C',
  WHITE: '#FFFFFF',
} as const;

/**
 * Dice states
 */
export const DiceStates = {
  MIN: 0,
  MAX: 6,
  ROLLING: -1,
} as const;

/**
 * Item classes
 */
export const ItemClasses = {
  POST_IT: 'post.it',
  POST_IT_VD: 'post.it.vd',
  POSTER: 'poster',
  PHOTO: 'photo',
} as const;

/**
 * Furniture sprite info
 */
export interface FurnitureSpriteInfo {
  memberName: string;
  x: number;
  y: number;
  z: number;
  width: number;
  height: number;
  ink: number;
  blend: number;
  color?: string;
  rotation?: number;
  visible: boolean;
}

/**
 * Preview renderer options
 */
export interface PreviewRenderOptions {
  memberStr?: string;
  colorList?: string[];
  colorListToSolve?: string;
  furniClass: string;
}

/**
 * Possible layer parts (a-l)
 */
export const LAYER_PARTS = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'] as const;

/**
 * Furniture event types
 */
export type FurnitureEventType =
  | 'click'
  | 'doubleClick'
  | 'mouseEnter'
  | 'mouseLeave'
  | 'stateChange';

/**
 * Furniture event handler
 */
export interface FurnitureEventHandler {
  (objectId: string, eventType: FurnitureEventType, data?: unknown): void;
}
