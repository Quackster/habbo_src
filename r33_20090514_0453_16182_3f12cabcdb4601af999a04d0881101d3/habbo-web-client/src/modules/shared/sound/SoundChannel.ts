/**
 * Sound Channel Class - Individual audio channel
 *
 * Ported from: hh_shared/Cast External ParentScript 52 - Sound Channel Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { SoundInstance } from './SoundInstance';

/**
 * Sound channel - manages a single audio playback channel
 */
export class SoundChannel extends BaseObject {
  private pChannelNum: number = 0;
  private pEndTime: number = 0;
  private pMuted: boolean = false;
  private pVolume: number = 255;
  private pReserved: boolean = false;
  private pQueue: SoundInstance[] = [];
  private currentSound: SoundInstance | null = null;
  private audio: HTMLAudioElement | null = null;

  /**
   * Define channel
   */
  define(channelNum: number): boolean {
    this.pChannelNum = channelNum;
    this.pEndTime = 0;
    this.pMuted = false;
    this.pVolume = 255;
    this.pReserved = false;
    this.pQueue = [];

    // Create audio element for this channel
    this.audio = new Audio();
    this.audio.addEventListener('ended', () => this.onSoundEnded());

    return true;
  }

  /**
   * Set sound state (mute/unmute)
   */
  setSoundState(state: boolean): void {
    if (this.audio) {
      if (state) {
        this.audio.volume = this.pVolume / 255;
        this.pMuted = false;
      } else {
        this.audio.volume = 0;
        this.pMuted = true;
      }
    }
  }

  /**
   * Reset channel - stop playing and clear queue
   */
  reset(): boolean {
    this.pEndTime = 0;
    this.pReserved = false;
    this.pQueue = [];
    this.currentSound = null;

    if (this.audio) {
      this.audio.pause();
      this.audio.currentTime = 0;
    }

    return true;
  }

  /**
   * Play a sound instance
   */
  play(soundObj: SoundInstance): number {
    const member = soundObj.getMember();
    if (!member || !this.audio) {
      return 0;
    }

    this.currentSound = soundObj;

    const infiniteLoop = soundObj.getProperty('infiniteloop') as boolean;
    let loopCount = (soundObj.getProperty('loopCount') as number) || 1;

    this.pVolume = (soundObj.getProperty('volume') as number) || 255;

    if (!this.pMuted) {
      this.audio.volume = this.pVolume / 255;
    } else {
      this.audio.volume = 0;
    }

    // Set loop
    this.audio.loop = infiniteLoop || loopCount === 0;

    // Calculate end time
    const duration = member.duration || 0;
    if (loopCount === 0 || infiniteLoop) {
      this.pEndTime = -1; // Infinite
    } else {
      this.pEndTime = Date.now() + (duration * loopCount * 1000);
    }

    // Copy source and play
    this.audio.src = member.src;
    this.audio.play().catch(() => {
      // Audio play failed (often due to autoplay policy)
    });

    return this.pChannelNum;
  }

  /**
   * Queue a sound to play after current
   */
  queue(soundObj: SoundInstance): boolean {
    const member = soundObj.getMember();
    if (!member) {
      return false;
    }

    this.pQueue.push(soundObj);
    return true;
  }

  /**
   * Start playing (from queue)
   */
  startPlaying(): boolean {
    if (this.pQueue.length > 0) {
      const next = this.pQueue.shift()!;
      this.play(next);
      return true;
    }
    return false;
  }

  /**
   * Get time remaining on current sound
   */
  getTimeRemaining(): number | 'infinite' {
    if (!this.audio) {
      return 0;
    }

    // Check if busy
    const isBusy = !this.audio.paused && !this.audio.ended;

    if (!isBusy && !this.pReserved) {
      return 0;
    }

    if (this.pEndTime === -1) {
      return 'infinite';
    }

    let durationLeft = this.pEndTime - Date.now();
    if (durationLeft < 0) {
      durationLeft = 0;
    }

    if (this.pReserved && durationLeft === 0) {
      durationLeft = 100000;
    }

    return durationLeft;
  }

  /**
   * Set channel as reserved
   */
  setReserved(): void {
    this.pReserved = true;
  }

  /**
   * Get if channel is reserved
   */
  getIsReserved(): boolean {
    return this.pReserved;
  }

  /**
   * Get channel number
   */
  getChannelNum(): number {
    return this.pChannelNum;
  }

  /**
   * Handle sound ended
   */
  private onSoundEnded(): void {
    this.pReserved = false;
    this.currentSound = null;

    // Play next from queue
    if (this.pQueue.length > 0) {
      const next = this.pQueue.shift()!;
      this.play(next);
    }
  }

  /**
   * Clean up
   */
  deconstruct(): void {
    this.reset();
    if (this.audio) {
      this.audio.removeEventListener('ended', () => this.onSoundEnded());
      this.audio = null;
    }
    super.deconstruct();
  }
}
