/**
 * Song Timeline Class - Manages song timeline data
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 8 - Song TimeLine Class.ls
 */

import {
  TimelineSample,
  SongData,
  SongSound,
  TIMELINE_CONSTANTS,
  getSampleSetId,
  encodeTimelineData,
  resolveSongLength,
} from './types';

export class SongTimeline {
  private songId: number = 0;
  private songName: string = '';
  private songLength: number = 0;
  private ready: boolean = false;
  private dataReady: boolean = false;
  private changed: boolean = false;

  private timelineData: (number | null)[][] = [];
  private songData: (TimelineSample | null)[][] = [];

  private readonly channelCount = TIMELINE_CONSTANTS.CHANNEL_COUNT;
  private readonly slotCount = TIMELINE_CONSTANTS.SLOT_COUNT;
  private readonly slotDuration = TIMELINE_CONSTANTS.SLOT_DURATION;
  private readonly sampleNameBase = TIMELINE_CONSTANTS.SAMPLE_NAME_BASE;

  private sampleLengthCache: Map<number, number> = new Map();
  private getSampleLengthFn: (name: string) => number = () => 0;

  construct(): void {
    this.clearTimeline();
  }

  deconstruct(): void {
    this.sampleLengthCache.clear();
  }

  /**
   * Set sample length resolver function
   */
  setSampleLengthResolver(fn: (name: string) => number): void {
    this.getSampleLengthFn = fn;
  }

  /**
   * Reset timeline state
   */
  reset(waitForData: boolean): void {
    this.dataReady = !waitForData;
    this.songId = 0;
    this.songName = '';
    this.songLength = 0;
    this.clearTimeline();
  }

  /**
   * Reset changed flag
   */
  resetChanged(): void {
    this.changed = false;
  }

  /**
   * Update song ID
   */
  updateSongId(id: number): void {
    this.songId = id;
  }

  /**
   * Update song name
   */
  updateSongName(name: string): void {
    this.songName = name;
  }

  /**
   * Handle sound set removal
   */
  soundSetRemoved(setId: number): void {
    // Clear from timeline data
    for (const channel of this.timelineData) {
      for (let slot = 0; slot < channel.length; slot++) {
        const sampleId = channel[slot];
        if (sampleId !== null) {
          const id = Math.abs(sampleId);
          if (getSampleSetId(id) === setId) {
            this.changed = true;
            channel[slot] = null;
          }
        }
      }
    }

    // Clear from song data
    for (const channel of this.songData) {
      for (let slot = 0; slot < channel.length; slot++) {
        const sample = channel[slot];
        if (sample !== null) {
          if (getSampleSetId(sample.id) === setId) {
            this.changed = true;
            channel[slot] = null;
          }
        }
      }
    }
  }

  /**
   * Check if sound set has references in timeline
   */
  checkSoundSetReferences(setId: number): boolean {
    for (const channel of this.timelineData) {
      for (const sampleId of channel) {
        if (sampleId !== null) {
          const id = Math.abs(sampleId);
          if (getSampleSetId(id) === setId) {
            return true;
          }
        }
      }
    }

    for (const channel of this.songData) {
      for (const sample of channel) {
        if (sample !== null) {
          if (getSampleSetId(sample.id) === setId) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /**
   * Get song ID
   */
  getSongId(): number {
    return this.songId;
  }

  /**
   * Get song name
   */
  getSongName(): string {
    return this.songName;
  }

  /**
   * Get channel count
   */
  getChannelCount(): number {
    return this.channelCount;
  }

  /**
   * Get slot count
   */
  getSlotCount(): number {
    return this.slotCount;
  }

  /**
   * Get changed flag
   */
  getChanged(): boolean {
    return this.changed;
  }

  /**
   * Get ready flag
   */
  getReady(): boolean {
    return this.ready;
  }

  /**
   * Get data ready flag
   */
  getDataReady(): boolean {
    return this.dataReady;
  }

  /**
   * Get slot duration in ms
   */
  getSlotDuration(): number {
    return this.slotDuration;
  }

  /**
   * Get timeline data
   */
  getTimelineData(): (number | null)[][] {
    return this.timelineData;
  }

  /**
   * Clear timeline
   */
  clearTimeline(songLength?: number): void {
    this.timelineData = [];
    this.songData = [];
    const length = songLength ?? this.slotCount;

    for (let i = 0; i < this.channelCount; i++) {
      const channel: (number | null)[] = new Array(this.slotCount).fill(null);
      const songChannel: (TimelineSample | null)[] = new Array(length).fill(null);
      this.timelineData.push(channel);
      this.songData.push(songChannel);
    }

    this.ready = true;
    this.changed = true;
  }

  /**
   * Parse song data from server
   */
  parseSongData(
    data: TimelineSample[][],
    songId: number,
    songName: string
  ): boolean {
    this.songId = songId;
    this.songName = songName;

    // Calculate song length
    let songLength = 0;
    for (const channel of data) {
      let slot = 0;
      for (const sample of channel) {
        slot += sample.length;
      }
      if (slot > songLength) {
        songLength = slot;
      }
    }

    this.clearTimeline(songLength);
    this.changed = false;

    // Fill song data
    for (let i = 0; i < Math.min(data.length, this.songData.length); i++) {
      const channel = data[i];
      let slot = 0;

      for (const sample of channel) {
        if (slot < this.songData[i].length) {
          this.songData[i][slot] = { ...sample };
        }
        slot += sample.length;
      }
    }

    this.ready = false;
    this.dataReady = true;
    return true;
  }

  /**
   * Process song data into timeline
   */
  processSongData(): boolean {
    if (this.ready) return true;
    if (!this.dataReady) return false;

    // Clear negative samples
    for (const channel of this.timelineData) {
      for (let j = 0; j < channel.length; j++) {
        if (channel[j] !== null && channel[j]! < 0) {
          channel[j] = null;
        }
      }
    }

    let allReady = true;

    for (let i = 0; i < Math.min(this.songData.length, this.timelineData.length); i++) {
      const songChannel = this.songData[i];
      const timelineChannel = this.timelineData[i];

      for (let j = 0; j < songChannel.length; j++) {
        const sample = songChannel[j];
        if (sample === null) continue;

        let sampleLength = this.getSampleLength(sample.id);
        let wasReady = true;

        if (sampleLength === 0) {
          sampleLength = 1;
          wasReady = false;
          allReady = false;
        }

        const id = wasReady ? sample.id : -sample.id;
        const isFreeBlock = this.isFreeBlock(j, i, sample.length);

        const repeats = Math.floor(sample.length / sampleLength);
        for (let k = 0; k < repeats; k++) {
          const pos = j + k * sampleLength;
          const canInsert = isFreeBlock || this.canInsertSample(pos, i, sample.id);
          if (canInsert && pos < timelineChannel.length) {
            timelineChannel[pos] = id;
          }
        }

        if (wasReady) {
          songChannel[j] = null;
        }
      }
    }

    this.ready = allReady;
    return allReady;
  }

  /**
   * Resolve actual song length from timeline
   */
  resolveSongLength(): number {
    return resolveSongLength(this.timelineData, (id) => this.getSampleLength(id));
  }

  /**
   * Check if sample can be inserted
   */
  canInsertSample(x: number, y: number, id: number): boolean {
    const length = this.getSampleLength(id);
    return this.isFreeBlock(x, y, length);
  }

  /**
   * Check if block is free
   */
  isFreeBlock(x: number, y: number, length: number): boolean {
    if (length === 0) return false;
    if (x < 0 || x + length > this.slotCount) return false;
    if (y < 0 || y >= this.timelineData.length) return false;

    const channel = this.timelineData[y];

    // Check if target slots are free
    for (let i = x; i < x + length; i++) {
      if (channel[i] !== null) return false;
    }

    // Check if previous sample overlaps
    for (let i = x - 1; i >= 0; i--) {
      const sampleId = channel[i];
      if (sampleId !== null) {
        const prevLength = this.getSampleLength(Math.abs(sampleId));
        if (i + prevLength > x) return false;
        break;
      }
    }

    return true;
  }

  /**
   * Get song data for playback
   */
  getSongData(): SongData | null {
    this.songLength = this.resolveSongLength();
    if (this.songLength === 0) return null;

    const songData: SongData = { offset: 0, sounds: [] };

    for (let channel = 0; channel < this.timelineData.length; channel++) {
      const channelData = this.timelineData[channel];
      let isEmpty = true;

      for (let i = 0; i < this.songLength; i++) {
        if (channelData[i] !== null) {
          isEmpty = false;
          break;
        }
      }

      if (isEmpty) continue;

      let slot = 0;
      while (slot < this.songLength) {
        const sampleId = channelData[slot];

        if (sampleId !== null && sampleId !== undefined) {
          const sampleLength = this.getSampleLength(Math.abs(sampleId));

          if (sampleLength > 0 && sampleId >= 0) {
            let count = 0;
            while (channelData[slot] === sampleId) {
              count++;
              slot += sampleLength;
              if (slot >= this.songLength) break;
            }

            const sampleData: SongSound = {
              name: this.getSampleName(sampleId),
              loops: count,
              channel: channel + 1,
            };
            songData.sounds.push(sampleData);
          } else {
            songData.sounds.push({
              name: this.getSampleName(0),
              loops: 1,
              channel: channel + 1,
            });
            slot++;
          }
        } else {
          let count = 0;
          while (channelData[slot] === null || channelData[slot] === undefined) {
            count++;
            slot++;
            if (slot >= this.songLength) break;
          }

          songData.sounds.push({
            name: this.getSampleName(0),
            loops: count,
            channel: channel + 1,
          });
        }
      }
    }

    return songData;
  }

  /**
   * Get silent song data
   */
  getSilentSongData(): SongData {
    return {
      offset: 0,
      sounds: [{ name: 'sound_machine_sample_0', loops: 10, channel: 1 }],
    };
  }

  /**
   * Insert sample at position
   */
  insertSample(slot: number, channel: number, id: number): boolean {
    if (!this.canInsertSample(slot, channel, id)) return false;

    this.changed = true;
    this.timelineData[channel][slot] = id;
    return true;
  }

  /**
   * Remove sample at position
   */
  removeSample(slot: number, channel: number): boolean {
    if (channel < 0 || channel >= this.timelineData.length) return false;
    if (slot < 0 || slot >= this.timelineData[channel].length) return false;

    const channelData = this.timelineData[channel];

    if (channelData[slot] !== null) {
      if (channelData[slot]! < 0) return false;
    } else {
      // Find sample that covers this slot
      for (let i = slot - 1; i >= 0; i--) {
        const sampleId = channelData[i];
        if (sampleId !== null && sampleId >= 0) {
          const length = this.getSampleLength(sampleId);
          if (i + length > slot) {
            slot = i;
            break;
          }
          return false;
        }
      }
    }

    this.changed = true;
    channelData[slot] = null;
    return true;
  }

  /**
   * Encode timeline data for server
   */
  encodeTimelineData(): string {
    if (!this.ready || !this.dataReady) return '';
    return encodeTimelineData(this.timelineData, (id) => this.getSampleLength(id));
  }

  /**
   * Get sample length
   */
  getSampleLength(sampleId: number): number {
    if (sampleId < 0) return 1;
    if (sampleId === 0) return 1;

    if (this.sampleLengthCache.has(sampleId)) {
      return this.sampleLengthCache.get(sampleId)!;
    }

    const sampleName = this.getSampleName(sampleId);
    const lengthMs = this.getSampleLengthFn(sampleName);

    if (lengthMs > 0) {
      const length = Math.ceil(lengthMs / this.slotDuration);
      this.sampleLengthCache.set(sampleId, length);
      return length;
    }

    return 0;
  }

  /**
   * Get sample name
   */
  getSampleName(sampleId: number): string {
    return `${this.sampleNameBase}${sampleId}`;
  }
}
