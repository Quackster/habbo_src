/**
 * Static Bubble Class - Stationary help bubble
 *
 * Ported from: hh_tutorial/Cast External ParentScript 9 - Static Bubble Class.ls
 */

import { Bubble } from './Bubble';
import { BubblePointerDirection } from './types';

/**
 * Static bubble that stays at a fixed position
 */
export class StaticBubble extends Bubble {
  protected targetX: number = -1000;
  protected targetY: number = 0;
  protected bubbleId: string = '';

  constructor(id?: string) {
    super(id);
    this.textWidth = 160;
    this.locX = -1000;
    this.locY = 0;
    this.targetX = this.locX;
    this.targetY = this.locY;
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
      case 'bubbleId':
        this.bubbleId = String(value);
        break;
      case 'targetX':
        this.targetX = Number(value);
        this.selectPointerAndPosition(this.direction);
        break;
      case 'targetY':
        this.targetY = Number(value);
        this.selectPointerAndPosition(this.direction);
        break;
      default:
        super.setProperty(property, value);
    }
  }

  /**
   * Get bubble ID
   */
  getBubbleId(): string {
    return this.bubbleId;
  }

  /**
   * Move to position
   */
  moveTo(locX: number, locY: number): void {
    this.locX = locX;
    this.locY = locY;
    this.events.emit('moved', { x: locX, y: locY });
  }

  /**
   * Set text
   */
  setText(text: string): void {
    super.setText(text);
    this.selectPointerAndPosition(this.direction);
  }

  /**
   * Select pointer and position bubble
   */
  selectPointerAndPosition(pointerIndex: BubblePointerDirection): void {
    this.selectPointer(pointerIndex);

    const marginH = 20;
    const marginV = 15;

    switch (pointerIndex) {
      case 1:
        this.locX = this.targetX - marginH;
        this.locY = this.targetY;
        break;
      case 2:
        this.locX = this.targetX - this.width + marginH;
        this.locY = this.targetY;
        break;
      case 3:
        this.locX = this.targetX - this.width;
        this.locY = this.targetY - marginV;
        break;
      case 4:
        this.locX = this.targetX - this.width;
        this.locY = this.targetY - this.height + marginV;
        break;
      case 5:
        this.locX = this.targetX - this.width + marginH;
        this.locY = this.targetY - this.height;
        break;
      case 6:
        this.locX = this.targetX - marginH;
        this.locY = this.targetY - this.height;
        break;
      case 7:
        this.locX = this.targetX;
        this.locY = this.targetY - this.height + marginV;
        break;
      case 8:
        this.locX = this.targetX;
        this.locY = this.targetY - marginV;
        break;
    }

    this.events.emit('positioned', {
      x: this.locX,
      y: this.locY,
      pointer: pointerIndex,
    });
  }

  /**
   * Hide close button
   */
  hideCloseButton(): void {
    this.events.emit('hideCloseButton');
  }

  /**
   * Handle close button click
   */
  onCloseClick(): void {
    this.events.emit('close', { bubbleId: this.bubbleId });
  }
}
