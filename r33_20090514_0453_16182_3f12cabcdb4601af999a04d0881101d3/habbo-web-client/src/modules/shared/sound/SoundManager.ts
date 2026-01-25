/**
 * Sound Manager Class - Audio playback management
 *
 * Ported from: hh_shared/Cast External ParentScript 51 - Sound Manager Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { SoundChannel } from './SoundChannel';
import { SoundInstance } from './SoundInstance';
import { SoundPriority, SoundProps } from '../types';

/**
 * Sound manager - manages multiple audio channels
 */
export class SoundManager extends BaseObject {
  private pChannelCount: number = 5;
  private pChannelList: SoundChannel[] = [];
  private pMuted: boolean = false;

  construct(): void {
    super.construct();

    this.pMuted = false;
    this.pChannelList = [];

    // Create channels
    for (let i = 1; i <= this.pChannelCount; i++) {
      const channel = new SoundChannel();
      if (channel.define(i)) {
        this.pChannelList.push(channel);
      }
    }

    this.pChannelCount = this.pChannelList.length;

    // Would register for set_all_sounds message
  }

  deconstruct(): void {
    // Reset all channels
    for (const channel of this.pChannelList) {
      channel.reset();
      channel.deconstruct();
    }

    this.pChannelList = [];
    super.deconstruct();
  }

  /**
   * Get property
   */
  getProperty(propId: string): unknown {
    switch (propId) {
      case 'channelCount':
        return this.pChannelList.length;
      default:
        return undefined;
    }
  }

  /**
   * Get channel by number (1-based)
   */
  getChannel(num: number): SoundChannel | null {
    if (num < 1 || num > this.pChannelList.length) {
      return null;
    }
    return this.pChannelList[num - 1];
  }

  /**
   * Play a sound
   */
  play(memberName: string, priority?: SoundPriority, props?: SoundProps): number {
    const soundObj = this.createSoundInstance(memberName, priority, props);
    if (!soundObj) return 0;

    switch (priority) {
      case 'pass':
      case undefined:
        // Find first free channel
        for (const channel of this.pChannelList) {
          if (channel.getTimeRemaining() === 0) {
            return channel.play(soundObj);
          }
        }
        return 0;

      case 'cut':
        // Find first free channel, or cut shortest playing
        {
          const statusList: Array<{ remaining: number | 'infinite'; index: number }> = [];

          for (let i = 0; i < this.pChannelList.length; i++) {
            const status = this.pChannelList[i].getTimeRemaining();

            if (status === 0) {
              return this.pChannelList[i].play(soundObj);
            }

            if (!this.pChannelList[i].getIsReserved()) {
              statusList.push({
                remaining: status === 'infinite' ? Infinity : status,
                index: i,
              });
            }
          }

          if (statusList.length === 0) return 0;

          // Sort by remaining time (shortest first)
          statusList.sort((a, b) => {
            const aVal = a.remaining === 'infinite' ? Infinity : (a.remaining as number);
            const bVal = b.remaining === 'infinite' ? Infinity : (b.remaining as number);
            return aVal - bVal;
          });

          return this.pChannelList[statusList[0].index].play(soundObj);
        }

      case 'queue':
        // Find first free channel, or queue to shortest
        {
          const statusList: Array<{ remaining: number | 'infinite'; index: number }> = [];

          for (let i = 0; i < this.pChannelList.length; i++) {
            const status = this.pChannelList[i].getTimeRemaining();

            if (status === 0) {
              return this.pChannelList[i].play(soundObj);
            }

            if (!this.pChannelList[i].getIsReserved()) {
              statusList.push({
                remaining: status === 'infinite' ? Infinity : status,
                index: i,
              });
            }
          }

          if (statusList.length === 0) return 0;

          // Sort by remaining time
          statusList.sort((a, b) => {
            const aVal = a.remaining === 'infinite' ? Infinity : (a.remaining as number);
            const bVal = b.remaining === 'infinite' ? Infinity : (b.remaining as number);
            return aVal - bVal;
          });

          this.pChannelList[statusList[0].index].queue(soundObj);
          return statusList[0].index + 1;
        }
    }

    return 0;
  }

  /**
   * Play in specific channel
   */
  playInChannel(memberName: string, channelNum: number): number {
    const channel = this.getChannel(channelNum);
    if (!channel) {
      console.error(`Invalid sound channel: ${channelNum}`);
      return 0;
    }

    const soundObj = this.createSoundInstance(memberName);
    if (!soundObj) return 0;

    channel.reset();
    return channel.play(soundObj);
  }

  /**
   * Queue sound in specific channel
   */
  queue(memberName: string, channelNum: number, props?: SoundProps): boolean {
    const channel = this.getChannel(channelNum);
    if (!channel) {
      console.error(`Invalid sound channel: ${channelNum}`);
      return false;
    }

    const soundObj = this.createSoundInstance(memberName, undefined, props);
    if (!soundObj) return false;

    const result = channel.queue(soundObj);
    if (result) {
      channel.setReserved();
    }

    return result;
  }

  /**
   * Stop channel
   */
  stopChannel(num: number): boolean {
    if (num < 1 || num > this.pChannelList.length) {
      return false;
    }
    return this.pChannelList[num - 1].reset();
  }

  /**
   * Start playing channel (from queue)
   */
  playChannel(num: number): boolean {
    if (num < 1 || num > this.pChannelList.length) {
      return false;
    }
    return this.pChannelList[num - 1].startPlaying();
  }

  /**
   * Stop all sounds
   */
  stopAllSounds(): boolean {
    for (const channel of this.pChannelList) {
      channel.reset();
    }
    return true;
  }

  /**
   * Set sound state (mute/unmute all)
   */
  setSoundState(enabled: boolean): boolean {
    this.pMuted = !enabled;

    for (const channel of this.pChannelList) {
      channel.setSoundState(enabled);
    }

    return true;
  }

  /**
   * Get sound state
   */
  getSoundState(): boolean {
    return !this.pMuted;
  }

  /**
   * Create sound instance
   */
  private createSoundInstance(
    memberName: string,
    priority?: SoundPriority,
    props?: SoundProps
  ): SoundInstance | null {
    const soundObj = new SoundInstance();
    soundObj.define(memberName, priority, props);
    return soundObj;
  }
}
