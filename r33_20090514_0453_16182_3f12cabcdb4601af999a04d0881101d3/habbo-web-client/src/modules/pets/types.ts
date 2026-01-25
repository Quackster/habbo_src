/**
 * Pets Common Module Types
 *
 * Ported from: hh_pets_common/*.ls
 */

/**
 * Pet action types
 */
export type PetAction =
  | 'std'  // Standard/idle
  | 'wlk'  // Walk
  | 'sit'  // Sit
  | 'lay'  // Lay down
  | 'slp'  // Sleep
  | 'jmp'  // Jump
  | 'scr'  // Scratch
  | 'bnd'  // Bend
  | 'beg'  // Beg
  | 'pla'  // Play
  | 'ded'  // Dead
  | 'eat'  // Eat
  | 'snf'  // Sniff
  | 'wav'  // Tail wave
  | 'spk'  // Speak/talk
  | 'rdy'  // Ready
  | 'eyb'  // Eyes blink
  | 'sml'  // Smile gesture
  | 'agr'  // Angry gesture
  | 'sad'  // Sad gesture
  | 'puz'; // Puzzled gesture

/**
 * Pet part types
 */
export type PetPartType = 'hd' | 'bd' | 'tl'; // head, body, tail

/**
 * Pet data from server
 */
export interface PetData {
  name: string;
  class: string;
  direction: number[];
  x: number;
  y: number;
  h: number;
  webID?: string;
  figure: string; // "race palette color" e.g. "0 4 AA98EF"
}

/**
 * Pet definition from pet.definitions
 */
export interface PetDefinition {
  paletteid: string;
  offsetid: string;
  parts: Record<PetPartType, string>; // part type -> model number
}

/**
 * Pet part offset data
 */
export type OffsetData = [number, number]; // [x, y]
export type OffsetList = Record<string, OffsetData[]>; // key -> offsets for each direction

/**
 * Pet info structure
 */
export interface PetInfo {
  name: string;
  class: string;
  custom: string;
  image?: ImageData | null;
}

/**
 * Draw properties for pet parts
 */
export interface DrawProps {
  maskImage: ImageData | null;
  ink: number;
  bgColor: string;
  palette: string;
}

/**
 * Screen location [x, y, z]
 */
export type ScreenLocation = [number, number, number];

/**
 * Pet sprite data
 */
export interface PetSprite {
  x: number;
  y: number;
  z: number;
  width: number;
  height: number;
  flipH: boolean;
  visible: boolean;
  image: ImageData | null;
}

/**
 * Flip list for direction mapping
 * Maps direction (0-7) to flip direction
 */
export const FLIP_LIST = [0, 1, 2, 3, 2, 1, 0, 7];

/**
 * Default canvas size [width, height, depth, regPointOffset]
 */
export const DEFAULT_CANVAS_SIZE: [number, number, number, number] = [62, 62, 32, -18];

/**
 * Move time in milliseconds
 */
export const MOVE_TIME = 500;

/**
 * Animation counter modulo
 */
export const ANIM_COUNTER_MOD = 4;
