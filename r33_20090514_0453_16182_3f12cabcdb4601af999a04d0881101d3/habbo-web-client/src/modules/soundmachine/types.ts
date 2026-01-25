/**
 * Sound Machine Module Types
 *
 * Ported from: hh_soundmachine/*.ls
 */

/**
 * Sound sample data
 */
export interface SoundSample {
  id: number;
  length: number;
}

/**
 * Sound set data
 */
export interface SoundSet {
  id: number;
  samples: SoundSample[];
}

/**
 * Song data
 */
export interface Song {
  id: number;
  length: number;
  name: string;
  author?: string;
  locked?: boolean;
}

/**
 * Disk data for jukebox
 */
export interface Disk {
  id: number;
  name: string;
}

/**
 * Song playback data
 */
export interface SongData {
  offset: number;
  sounds: SongSound[];
}

/**
 * Song sound entry
 */
export interface SongSound {
  name: string;
  loops: number;
  channel: number;
}

/**
 * Timeline sample
 */
export interface TimelineSample {
  id: number;
  length: number;
}

/**
 * Playlist song data
 */
export interface PlaylistSong {
  id: number;
  length: number;
  name: string;
  author: string;
}

/**
 * Sound machine state
 */
export interface SoundMachineState {
  id: string;
  furniOn: boolean;
}

/**
 * Jukebox state
 */
export interface JukeboxState {
  id: string;
  owner: boolean;
}

/**
 * Confirmed action types
 */
export type ConfirmAction =
  | 'eject'
  | 'close'
  | 'clear'
  | 'save'
  | 'delete'
  | 'burn'
  | 'save_list'
  | 'close_list';

/**
 * Sound machine incoming message IDs
 */
export const SoundMachineMessages = {
  SONG_INFO: 300,
  MACHINE_SOUND_PACKAGES: 301,
  USER_SOUND_PACKAGES: 302,
  SONG_LIST: 322,
  PLAY_LIST: 323,
  SONG_MISSING_PACKAGES: 324,
  PLAY_LIST_INVALID: 325,
  SONG_LIST_FULL: 326,
  NEW_SONG: 331,
  INVALID_SONG_NAME: 332,
  USER_SONG_DISKS: 333,
  JUKEBOX_DISKS: 334,
  JUKEBOX_SONG_ADDED: 335,
  SONG_LOCKED: 336,
  JUKEBOX_PLAYLIST_FULL: 337,
  INVALID_SONG_LENGTH: 338,
  SONG_SAVED: 339,
} as const;

/**
 * Sound machine outgoing command IDs
 */
export const SoundMachineCommands = {
  INSERT_SOUND_PACKAGE: 219,
  EJECT_SOUND_PACKAGE: 220,
  GET_SONG_INFO: 221,
  NEW_SONG: 239,
  SAVE_SONG_NEW: 240,
  EDIT_SONG: 241,
  SAVE_SONG_EDIT: 242,
  UPDATE_PLAY_LIST: 243,
  GET_SONG_LIST: 244,
  GET_PLAY_LIST: 245,
  SONG_EDIT_CLOSE: 246,
  DELETE_SONG: 248,
  BURN_SONG: 254,
  ADD_JUKEBOX_DISC: 255,
  REMOVE_JUKEBOX_DISC: 256,
  JUKEBOX_PLAYLIST_ADD: 257,
  GET_JUKEBOX_DISCS: 258,
  GET_USER_SONG_DISCS: 259,
  RESET_JUKEBOX: 260,
} as const;

/**
 * Timeline constants
 */
export const TIMELINE_CONSTANTS = {
  CHANNEL_COUNT: 4,
  SLOT_COUNT: 150,
  SLOT_DURATION: 2000, // ms
  VIEW_SLOT_COUNT: 24,
  SAMPLE_NAME_BASE: 'sound_machine_sample_',
} as const;

/**
 * Sound set constants
 */
export const SOUND_SET_CONSTANTS = {
  LIMIT: 4,
  SAMPLES_PER_SET: 9,
  LIST_PAGE_SIZE: 3,
  SAMPLE_HOR_COUNT: 3,
  SAMPLE_VER_COUNT: 3,
} as const;

/**
 * Format time as mm:ss or "X min Y sec"
 */
export function formatTime(seconds: number, verbose: boolean = false): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  const secStr = secs.toString().padStart(2, '0');

  if (verbose) {
    if (seconds < 60) {
      return `${secs} sec`;
    }
    return `${mins} min ${secStr} sec`;
  }

  return `${mins}:${secStr}`;
}

/**
 * Get sound set ID from sample ID
 */
export function getSampleSetId(sampleId: number): number {
  return 1 + Math.floor((sampleId - 1) / SOUND_SET_CONSTANTS.SAMPLES_PER_SET);
}

/**
 * Parse song data string from server
 */
export function parseSongDataString(str: string): TimelineSample[][] {
  const channels: TimelineSample[][] = [];
  const parts = str.split(':');

  for (let i = 0; i < parts.length - 1; i += 2) {
    const channelNum = parseInt(parts[i], 10);
    const channelData = parts[i + 1];

    if (isNaN(channelNum)) continue;

    const samples: TimelineSample[] = [];
    const sampleParts = channelData.split(';');

    for (const samplePart of sampleParts) {
      if (!samplePart) continue;
      const [idStr, lengthStr] = samplePart.split(',');
      const id = parseInt(idStr, 10);
      const length = parseInt(lengthStr, 10);
      if (!isNaN(id) && !isNaN(length)) {
        samples.push({ id, length });
      }
    }

    channels[channelNum - 1] = samples;
  }

  return channels;
}

/**
 * Encode timeline data to string for server
 */
export function encodeTimelineData(
  timelineData: (number | null)[][],
  getSampleLength: (id: number) => number
): string {
  let str = '';
  const songLength = resolveSongLength(timelineData, getSampleLength);

  if (songLength === 0) return '';

  for (let channel = 0; channel < timelineData.length; channel++) {
    const channelData = timelineData[channel];
    str += `${channel + 1}:`;

    const samples: TimelineSample[] = [];
    let slot = 0;

    while (slot < songLength) {
      const sampleId = channelData[slot];

      if (sampleId === null || sampleId === undefined) {
        samples.push({ id: 0, length: 1 });
        slot++;
      } else {
        const length = getSampleLength(Math.abs(sampleId));
        samples.push({
          id: sampleId < 0 ? -sampleId : sampleId,
          length: length || 1,
        });
        slot += length || 1;
      }
    }

    // Merge consecutive same samples
    const merged: TimelineSample[] = [];
    for (const sample of samples) {
      const last = merged[merged.length - 1];
      if (last && last.id === sample.id) {
        last.length += sample.length;
      } else {
        merged.push({ ...sample });
      }
    }

    str +=
      merged.map((s) => `${s.id},${s.length}`).join(';') + ':';
  }

  return str;
}

/**
 * Calculate song length from timeline data
 */
export function resolveSongLength(
  timelineData: (number | null)[][],
  getSampleLength: (id: number) => number
): number {
  let length = 0;

  for (const channelData of timelineData) {
    let slot = 0;

    while (slot < channelData.length) {
      const sampleId = channelData[slot];

      if (sampleId !== null && sampleId !== undefined) {
        const sampleLength = getSampleLength(Math.abs(sampleId));
        if (sampleLength > 0 && sampleId >= 0) {
          // Count consecutive same samples
          while (channelData[slot] === sampleId) {
            slot += sampleLength;
            if (slot > length) {
              length = slot;
            }
            if (slot > channelData.length) break;
          }
        } else {
          slot++;
          if (sampleId < 0 && slot > length) {
            length = slot;
          }
        }
      } else {
        slot++;
      }
    }
  }

  return length;
}
