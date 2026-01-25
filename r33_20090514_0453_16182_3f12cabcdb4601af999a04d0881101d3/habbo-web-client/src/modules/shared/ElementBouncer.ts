/**
 * Element Bouncer Class - UI bounce animation
 *
 * Ported from: hh_shared/Cast External ParentScript 9 - Element Bouncer Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { ElementPositionData, BounceState } from './types';

/**
 * Element bouncer - bounces UI elements for attention
 */
export class ElementBouncer extends BaseObject {
  private pWindowID: string = '';
  private pElemIdList: string[] = [];
  private pBounceOn: boolean = false;
  private pOrigPositions: Map<string, { x: number; y: number }> = new Map();
  private pOffset: number = 0;
  private pSpeed: number = 6;
  private animationFrame: number | null = null;

  construct(): void {
    super.construct();
    this.pOrigPositions = new Map();
  }

  deconstruct(): void {
    this.setBounce(false);
    super.deconstruct();
  }

  /**
   * Register elements for bouncing
   */
  registerElement(windowId: string, elemIdList: string | string[]): boolean {
    if (!Array.isArray(elemIdList)) {
      elemIdList = [elemIdList];
    }

    this.pWindowID = windowId;
    this.pElemIdList = elemIdList;

    // Store original positions
    for (const elemId of elemIdList) {
      const element = document.getElementById(elemId);
      if (element) {
        const rect = element.getBoundingClientRect();
        this.pOrigPositions.set(elemId, { x: rect.left, y: rect.top });
      }
    }

    return true;
  }

  /**
   * Register elements with DOM elements directly
   */
  registerElements(elements: HTMLElement[]): boolean {
    this.pElemIdList = [];
    this.pOrigPositions.clear();

    for (const element of elements) {
      const id = element.id || `bouncer_${Date.now()}_${Math.random()}`;
      if (!element.id) {
        element.id = id;
      }
      this.pElemIdList.push(id);
      this.pOrigPositions.set(id, {
        x: element.offsetLeft,
        y: element.offsetTop,
      });
    }

    return true;
  }

  /**
   * Get current bounce state
   */
  getState(): boolean {
    return this.pBounceOn || this.animationFrame !== null;
  }

  /**
   * Set bounce on/off
   */
  setBounce(bounceOn: boolean): boolean {
    if (bounceOn) {
      this.pBounceOn = true;
      this.resetBounce();
      this.startUpdate();
    } else {
      if (this.animationFrame !== null) {
        cancelAnimationFrame(this.animationFrame);
        this.animationFrame = null;
      }
      this.pBounceOn = false;
      this.resetPosition();
    }

    return true;
  }

  /**
   * Reset bounce animation
   */
  private resetBounce(): void {
    this.pBounceOn = true;
    this.pOffset = 0;
    this.pSpeed = 6;
  }

  /**
   * Reset elements to original position
   */
  private resetPosition(): void {
    for (const elemId of this.pElemIdList) {
      const element = document.getElementById(elemId);
      const origPos = this.pOrigPositions.get(elemId);

      if (element && origPos) {
        element.style.transform = '';
      }
    }
  }

  /**
   * Start animation loop
   */
  private startUpdate(): void {
    const update = () => {
      if (!this.pBounceOn) return;

      if (!this.update()) {
        return;
      }

      this.animationFrame = requestAnimationFrame(update);
    };

    this.animationFrame = requestAnimationFrame(update);
  }

  /**
   * Update animation frame
   */
  private update(): boolean {
    if (!this.pBounceOn) {
      return false;
    }

    // Physics update
    this.pSpeed -= 1;
    this.pOffset += this.pSpeed;

    // Bounce at ground
    if (this.pOffset <= 0) {
      this.pOffset = 0;
      this.pSpeed = Math.abs(this.pSpeed);

      // Check if bounce has stopped
      if (Math.floor(this.pSpeed) === 0) {
        this.setBounce(false);
        return false;
      }
    }

    // Update element positions
    for (const elemId of this.pElemIdList) {
      const element = document.getElementById(elemId);
      if (element) {
        element.style.transform = `translateY(${-this.pOffset}px)`;
      }
    }

    return true;
  }

  /**
   * Get bounce state data
   */
  getBounceState(): BounceState {
    return {
      bounceOn: this.pBounceOn,
      offset: this.pOffset,
      speed: this.pSpeed,
    };
  }

  /**
   * Trigger a single bounce
   */
  bounce(): void {
    this.setBounce(true);
  }
}
