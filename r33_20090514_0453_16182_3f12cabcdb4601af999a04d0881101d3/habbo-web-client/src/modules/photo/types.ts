/**
 * Photo Module Types
 *
 * Ported from: hh_photo/*.ls
 */

/**
 * Camera mode states
 */
export enum CameraMode {
  CLOSED = 'closed',
  LIVE = 'live',
  STILL = 'still',
  SAVE = 'save',
}

/**
 * Photo data stored in cache
 */
export interface PhotoData {
  image: ImageData | Blob;
  time: string;
  checksum: number;
}

/**
 * Photo item data from server
 */
export interface PhotoItemData {
  id: string;
  authorId: string;
  time: string;
  text: string;
}

/**
 * Camera button IDs
 */
export type CameraButtonId =
  | 'cam_shoot'
  | 'cam_release'
  | 'cam_save'
  | 'cam_zoom_in'
  | 'cam_zoom_out'
  | 'cam_txtscreen'
  | 'cam_close';

/**
 * Photo incoming message IDs
 */
export const PhotoMessages = {
  FILM_COUNT: 4,
} as const;

/**
 * Photo outgoing command IDs
 */
export const PhotoCommands = {
  CARRY_OBJECT: 'CARRYOBJECT',
  USE_OBJECT: 'USEOBJECT',
  GET_ITEM_DATA: 'G_IDATA',
  REMOVE_ITEM: 'REMOVEITEM',
  PHOTO_TEXT: 'PHOTOTXT',
} as const;

/**
 * Hand item ID for camera
 */
export const CAMERA_HAND_ITEM_ID = 20;

/**
 * Scandinavian character encoding map
 */
export const SCANDINAVIAN_CHARS: Record<string, string> = {
  '&AUML;': 'Ä',
  '&OUML;': 'Ö',
  '&auml;': 'ä',
  '&ouml;': 'ö',
};

/**
 * Decode scandinavian characters from legacy encoding
 */
export function decodeScandinavian(text: string): string {
  if (text.length < 6) return text;

  let result = '';
  let i = 0;

  while (i < text.length) {
    if (text[i] === '&' && i + 5 < text.length) {
      const chunk = text.substring(i, i + 6);
      const decoded = SCANDINAVIAN_CHARS[chunk];
      if (decoded) {
        result += decoded;
        i += 6;
        continue;
      }
    }
    result += text[i];
    i++;
  }

  return result;
}

/**
 * Checksum coefficients for photo validation
 */
export const CHECKSUM_COEFFICIENTS = [
  3, 2, 73, 28, 83, 21, 43, 90, 92, 91, 37, 4, 3, 84, 12, 102, 103, 108, 97, 43,
  44, 89, 109, 65, 61, -4, 76,
];

/**
 * Calculate checksum for photo image
 */
export function calculateChecksum(imageData: ImageData): number {
  const coefficients = CHECKSUM_COEFFICIENTS;
  let checksum = 0;
  const width = imageData.width;
  const height = imageData.height;

  for (let i = 1; i <= 100; i++) {
    const x = i % width;
    const y = (i * i) % height;
    const pixelIndex = (y * width + x) * 4;

    // Use grayscale value as palette index approximation
    const gray = Math.floor(
      (imageData.data[pixelIndex] +
        imageData.data[pixelIndex + 1] +
        imageData.data[pixelIndex + 2]) /
        3
    );

    const coeffIndex = i % coefficients.length;
    checksum = (checksum + gray * coefficients[coeffIndex]) % 85000;
  }

  return checksum;
}
