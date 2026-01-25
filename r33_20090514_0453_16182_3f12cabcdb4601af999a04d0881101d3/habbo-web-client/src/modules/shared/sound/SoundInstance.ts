/**
 * Sound Instance Class - Individual sound playback
 *
 * Ported from: hh_shared/Cast External ParentScript 53 - Sound Instance Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { SoundProps, SoundPriority } from '../types';

/**
 * Sound instance - represents a single sound to be played
 */
export class SoundInstance extends BaseObject {
  private pMemberName: string = '';
  private pPriority: SoundPriority = 'pass';
  private pProps: SoundProps = {};
  private audio: HTMLAudioElement | null = null;

  /**
   * Define sound instance
   */
  define(memberName: string, priority?: SoundPriority, props?: SoundProps): boolean {
    this.pMemberName = memberName;
    this.pPriority = priority || 'pass';
    this.pProps = props || {};

    // Set default values
    if (this.pProps.volume === undefined) {
      this.pProps.volume = 255;
    }
    if (this.pProps.loopCount === undefined) {
      this.pProps.loopCount = 1;
    }

    return true;
  }

  /**
   * Get audio element (create if needed)
   */
  getMember(): HTMLAudioElement | null {
    if (!this.audio) {
      try {
        this.audio = new Audio();
        // Would set source from asset loader
        // this.audio.src = assetLoader.getSoundUrl(this.pMemberName);
      } catch {
        return null;
      }
    }
    return this.audio;
  }

  /**
   * Get property
   */
  getProperty(propId: string): unknown {
    switch (propId) {
      case 'volume':
        return this.pProps.volume ?? 255;
      case 'loopCount':
        return this.pProps.loopCount ?? 1;
      case 'infiniteloop':
        return this.pProps.infiniteloop ?? false;
      case 'startTime':
        return this.pProps.startTime ?? 0;
      case 'endTime':
        return this.pProps.endTime ?? 0;
      default:
        return undefined;
    }
  }

  /**
   * Get all props
   */
  getProps(): SoundProps {
    return { ...this.pProps };
  }

  /**
   * Get member name
   */
  getMemberName(): string {
    return this.pMemberName;
  }

  /**
   * Get priority
   */
  getPriority(): SoundPriority {
    return this.pPriority;
  }

  /**
   * Clean up
   */
  deconstruct(): void {
    if (this.audio) {
      this.audio.pause();
      this.audio.src = '';
      this.audio = null;
    }
    super.deconstruct();
  }
}
