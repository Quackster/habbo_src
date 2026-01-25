/**
 * Room Dimmer Types
 *
 * Ported from: hh_roomdimmer/*.ls
 */

/**
 * RGB Color
 */
export interface RGBColor {
  red: number;
  green: number;
  blue: number;
}

/**
 * HSL Color
 */
export interface HSLColor {
  hue: number;
  saturation: number;
  lightness: number;
}

/**
 * Dimmer preset data
 */
export interface DimmerPreset {
  presetID: number;
  effectID: number;
  color: RGBColor | string;
  lightness: number;
  apply?: boolean;
}

/**
 * Dimmer state data
 */
export interface DimmerState {
  dimmerID: number;
  isOn: boolean;
  presetID: number;
  effectID: number;
  color: RGBColor;
  lightness: number;
}

/**
 * Dimmer effect types
 */
export enum DimmerEffect {
  SET_DIMMER_COLOR = 1,
  COLORIZE_ROOM = 2,
}

/**
 * Room dimmer incoming message IDs
 */
export const RoomDimmerMessages = {
  DIMMER_PRESETS: 365,
} as const;

/**
 * Room dimmer outgoing command IDs
 */
export const RoomDimmerCommands = {
  MSG_ROOMDIMMER_GET_PRESETS: 341,
  MSG_ROOMDIMMER_SET_PRESET: 342,
  MSG_ROOMDIMMER_CHANGE_STATE: 343,
} as const;

/**
 * Convert RGB to hex string
 */
export function rgbToHex(color: RGBColor): string {
  const r = Math.round(color.red).toString(16).padStart(2, '0');
  const g = Math.round(color.green).toString(16).padStart(2, '0');
  const b = Math.round(color.blue).toString(16).padStart(2, '0');
  return `#${r}${g}${b}`;
}

/**
 * Parse hex string to RGB
 */
export function hexToRgb(hex: string): RGBColor {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  if (!result) {
    return { red: 255, green: 255, blue: 255 };
  }
  return {
    red: parseInt(result[1], 16),
    green: parseInt(result[2], 16),
    blue: parseInt(result[3], 16),
  };
}

/**
 * Convert RGB to HSL
 */
export function rgbToHsl(color: RGBColor): HSLColor {
  const r = color.red / 255;
  const g = color.green / 255;
  const b = color.blue / 255;

  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h = 0;
  let s = 0;
  const l = (max + min) / 2;

  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch (max) {
      case r:
        h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
        break;
      case g:
        h = ((b - r) / d + 2) / 6;
        break;
      case b:
        h = ((r - g) / d + 4) / 6;
        break;
    }
  }

  return { hue: h * 360, saturation: s * 100, lightness: l * 100 };
}

/**
 * Convert HSL to RGB
 */
export function hslToRgb(color: HSLColor): RGBColor {
  const h = color.hue / 360;
  const s = color.saturation / 100;
  const l = color.lightness / 100;

  let r: number, g: number, b: number;

  if (s === 0) {
    r = g = b = l;
  } else {
    const hue2rgb = (p: number, q: number, t: number) => {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    };

    const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    const p = 2 * l - q;
    r = hue2rgb(p, q, h + 1 / 3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1 / 3);
  }

  return { red: r * 255, green: g * 255, blue: b * 255 };
}
