/**
 * Bubble Class - Base bubble for tutorial hints
 *
 * Ported from: hh_tutorial/Cast External ParentScript 7 - Bubble Class.ls
 */

import { EventEmitter } from '../../core/events';
import {
  BubblePointerDirection,
  BubbleState,
  DEFAULT_BUBBLE_TEXT_WIDTH,
  BUBBLE_FADE_SPEED,
} from './types';

/**
 * Base bubble class for tutorial help bubbles
 */
export class Bubble {
  protected windowId: string;
  protected targetElementId: string = '';
  protected targetWindowId: string = '';
  protected locX: number = 0;
  protected locY: number = 0;
  protected text: string = '';
  protected offsetX: number = 0;
  protected offsetY: number = 0;
  protected direction: BubblePointerDirection = 6;
  protected special: string = '';
  protected textWidth: number = DEFAULT_BUBBLE_TEXT_WIDTH;
  protected textHeight: number = 0;
  protected fadeState: 'ready' | 'in' | 'out' = 'ready';
  protected faded: boolean = false;
  protected emptySizeX: number = 0;
  protected emptySizeY: number = 0;
  protected pointerX: number = 0;
  protected pointerY: number = 0;
  protected width: number = 0;
  protected height: number = 0;
  protected blend: number = 100;
  protected visible: boolean = false;

  protected events: EventEmitter = new EventEmitter();

  constructor(id?: string) {
    this.windowId = id || `Bubble_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.init();
  }

  /**
   * Initialize bubble
   */
  protected init(): void {
    this.selectPointer(6);
    this.emptySizeX = 200;
    this.emptySizeY = 100;
    this.hide();
  }

  /**
   * Deconstruct bubble
   */
  deconstruct(): void {
    this.events.removeAllListeners();
  }

  /**
   * Hide bubble
   */
  hide(): void {
    this.visible = false;
    this.targetWindowId = '';
    this.events.emit('hide');
  }

  /**
   * Show bubble
   */
  show(): void {
    this.visible = true;
    this.events.emit('show');
  }

  /**
   * Set text
   */
  setText(text: string): void {
    this.text = text;
    // Calculate text height based on content
    const lineCount = text.split('\n').length;
    this.textHeight = lineCount * 14 + 20; // Approximate line height
    this.height = this.emptySizeY + this.textHeight;
    this.updatePointer();
    this.events.emit('textChanged', { text, height: this.textHeight });
  }

  /**
   * Add text
   */
  addText(textKey: string): void {
    this.setText(this.text + '\n\n' + textKey);
  }

  /**
   * Get property
   */
  getProperty(prop: string): unknown {
    switch (prop) {
      case 'windowID':
        return this.windowId;
      case 'targetWindowID':
        return this.targetWindowId;
      case 'text':
        return this.text;
      case 'direction':
        return this.direction;
      case 'special':
        return this.special;
      case 'visible':
        return this.visible;
      case 'width':
        return this.width;
      case 'height':
        return this.height;
      default:
        return undefined;
    }
  }

  /**
   * Set property
   */
  setProperty(property: string | Record<string, unknown>, value?: unknown): void {
    if (typeof property === 'object') {
      for (const [key, val] of Object.entries(property)) {
        this.setProperty(key, val);
      }
      return;
    }

    switch (property) {
      case 'textKey':
        this.setText(String(value).replace(/\\n/g, '\n\n'));
        break;
      case 'targetID':
        this.targetElementId = String(value);
        break;
      case 'direction':
        this.selectPointer(value as BubblePointerDirection);
        break;
      case 'offsetx':
        this.offsetX = Number(value);
        break;
      case 'offsety':
        this.offsetY = Number(value);
        break;
      case 'special':
        this.special = String(value);
        break;
    }
  }

  /**
   * Select pointer direction
   */
  selectPointer(pointerNum: BubblePointerDirection): void {
    this.direction = pointerNum;
    this.updatePointer();
    this.events.emit('pointerChanged', { direction: pointerNum });
  }

  /**
   * Update (called each frame)
   */
  update(): void {
    if (this.faded) {
      // Check if mouse is outside bubble
      // If so, unfade
      this.faded = false;
      this.show();
    }
    this.updateFade();
    this.updatePosition();
  }

  /**
   * Update pointer position based on direction
   */
  protected updatePointer(): void {
    switch (this.direction) {
      case 1:
        this.pointerX = 33;
        this.pointerY = 0;
        break;
      case 2:
        this.pointerX = this.width - 33;
        this.pointerY = 0;
        break;
      case 3:
        this.pointerX = this.width;
        this.pointerY = 26;
        break;
      case 4:
        this.pointerX = this.width;
        this.pointerY = this.height - 26;
        break;
      case 5:
        this.pointerX = this.width - 33;
        this.pointerY = this.height;
        break;
      case 6:
        this.pointerX = 33;
        this.pointerY = this.height;
        break;
      case 7:
        this.pointerX = 0;
        this.pointerY = this.height - 26;
        break;
      case 8:
        this.pointerX = 0;
        this.pointerY = 26;
        break;
    }
  }

  /**
   * Update position based on target element
   */
  protected updatePosition(): void {
    if (!this.targetElementId) {
      return;
    }

    // Position would be calculated based on target element
    // For now, emit event for UI to handle
    this.events.emit('positionUpdate', {
      x: this.locX,
      y: this.locY,
      pointerX: this.pointerX,
      pointerY: this.pointerY,
    });
  }

  /**
   * Update fade animation
   */
  protected updateFade(): void {
    if (this.fadeState === 'ready') {
      return;
    }

    let newBlend: number;
    if (this.fadeState === 'in') {
      newBlend = this.blend + BUBBLE_FADE_SPEED;
    } else {
      newBlend = this.blend - BUBBLE_FADE_SPEED;
    }

    if (newBlend >= 100) {
      newBlend = 100;
      this.fadeState = 'ready';
    }

    if (newBlend <= 0) {
      newBlend = 0;
      this.fadeState = 'ready';
      this.faded = true;
      this.visible = false;
    }

    this.blend = newBlend;
    this.events.emit('blendChanged', { blend: newBlend });
  }

  /**
   * Handle mouse enter (start fade out)
   */
  onMouseEnter(): void {
    this.fadeState = 'out';
  }

  /**
   * Handle mouse leave (start fade in)
   */
  onMouseLeave(): void {
    this.fadeState = 'in';
  }

  /**
   * Get state for rendering
   */
  getState(): BubbleState {
    return {
      id: this.windowId,
      text: this.text,
      x: this.locX,
      y: this.locY,
      width: this.width,
      height: this.height,
      pointerDirection: this.direction,
      visible: this.visible,
      blend: this.blend,
    };
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }
}
