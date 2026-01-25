/**
 * Wrapper Element Class
 *
 * Ported from: fuse_client/Cast External ParentScript 56 - Element Wrapper Class.ls
 *
 * A wrapper element contains multiple child elements and manages their
 * collective rendering to a single buffer/sprite.
 */

import { BaseElement } from './BaseElement';
import { ElementProps, ScaleMode, SpriteData } from '../types';

export class WrapperElement extends BaseElement {
  private elements: BaseElement[] = [];

  define(props: ElementProps): boolean {
    super.define(props);

    // Set buffer from props
    const buffer = (props as unknown as { buffer: HTMLCanvasElement }).buffer;
    const sprite = (props as unknown as { sprite: SpriteData }).sprite;

    if (buffer) {
      this.buffer = buffer;
      this.bufferCtx = buffer.getContext('2d');
    }
    if (sprite) {
      this.sprite = sprite;
    }

    this.locX = (props as unknown as { locX: number }).locX ?? props.locH;
    this.locY = (props as unknown as { locY: number }).locY ?? props.locV;
    this._width = this.buffer?.width ?? 0;
    this._height = this.buffer?.height ?? 0;

    return true;
  }

  /**
   * Add a child element
   */
  add(element: BaseElement): boolean {
    if (!element) return false;

    // Check if any child has scaling, propagate to wrapper
    const childScaleH = element.getProperty('scaleH') as ScaleMode;
    const childScaleV = element.getProperty('scaleV') as ScaleMode;

    if (childScaleH !== 'fixed') {
      this.scaleH = 'scale';
    }
    if (childScaleV !== 'fixed') {
      this.scaleV = 'scale';
    }

    this.elements.push(element);
    return true;
  }

  /**
   * Get a child element by index
   */
  getElement(index: number): BaseElement | null {
    return this.elements[index] ?? null;
  }

  /**
   * Get all child elements
   */
  getElements(): BaseElement[] {
    return this.elements;
  }

  /**
   * Prepare all child elements
   */
  prepare(): void {
    for (const element of this.elements) {
      element.prepare();
    }
  }

  /**
   * Render all child elements to the buffer
   */
  render(): void {
    if (!this.visible) return;

    for (const element of this.elements) {
      element.render();
    }
  }

  /**
   * Draw debug outlines for all children
   */
  draw(color: string = '#FF0000'): void {
    for (const element of this.elements) {
      element.draw(color);
    }
  }

  /**
   * Move to absolute position
   */
  moveTo(x: number, y: number): void {
    const offX = x - this.locX;
    const offY = y - this.locY;
    this.moveBy(offX, offY);
  }

  /**
   * Move by offset
   */
  moveBy(offX: number, offY: number): void {
    this.locX += offX;
    this.locY += offY;

    if (this.sprite) {
      this.sprite.x += offX;
      this.sprite.y += offY;
    }
  }

  /**
   * Resize by offset - propagates to children
   */
  resizeBy(offW: number, offH: number, forced?: boolean): void {
    if (offW === 0 && offH === 0) return;

    let actualOffW = offW;
    let actualOffH = offH;

    // Handle horizontal scaling mode
    switch (this.scaleH) {
      case 'fixed':
        actualOffW = 0;
        break;
      case 'scale':
        this._width += offW;
        break;
      case 'move':
        this.moveBy(offW, 0);
        break;
      case 'center':
        this.moveBy(offW / 2, 0);
        break;
    }

    if (this.scaleH !== 'scale') {
      actualOffW = 0;
    }

    // Handle vertical scaling mode
    switch (this.scaleV) {
      case 'fixed':
        actualOffH = 0;
        break;
      case 'scale':
        this._height += offH;
        break;
      case 'move':
        this.moveBy(0, offH);
        break;
      case 'center':
        this.moveBy(0, offH / 2);
        break;
    }

    if (this.scaleV !== 'scale') {
      actualOffH = 0;
    }

    // Resize buffer if needed
    if (actualOffW !== 0 || actualOffH !== 0) {
      if (this._width < 1) this._width = 1;
      if (this._height < 1) this._height = 1;

      if (this.buffer) {
        // Create new buffer with new size
        const newCanvas = document.createElement('canvas');
        newCanvas.width = this._width;
        newCanvas.height = this._height;
        const newCtx = newCanvas.getContext('2d')!;

        // Copy old content if any
        newCtx.drawImage(this.buffer, 0, 0);

        this.buffer = newCanvas;
        this.bufferCtx = newCtx;
      }

      if (this.sprite) {
        this.sprite.width = this._width;
        this.sprite.height = this._height;
      }

      // Propagate resize to children
      for (const element of this.elements) {
        element.resizeBy(actualOffW, actualOffH, forced);
      }
    }
  }

  /**
   * Show the element and all children
   */
  show(): boolean {
    this.visible = true;
    if (this.sprite) {
      this.sprite.visible = true;
    }
    return true;
  }

  /**
   * Hide the element and all children
   */
  hide(): boolean {
    this.visible = false;
    if (this.sprite) {
      this.sprite.visible = false;
    }
    return true;
  }

  getProperty(prop: string): unknown {
    switch (prop) {
      case 'image':
        return this.buffer;
      case 'palette':
        return this.palette;
      default:
        return super.getProperty(prop);
    }
  }

  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'image':
        if (this.buffer && this.bufferCtx && value instanceof ImageData) {
          this.bufferCtx.putImageData(value, 0, 0);
          if (this.sprite) {
            this.sprite.width = this.buffer.width;
            this.sprite.height = this.buffer.height;
          }
          this._width = this.buffer.width;
          this._height = this.buffer.height;
        }
        return true;
      case 'buffer':
      case 'member':
        if (value instanceof HTMLCanvasElement) {
          this.buffer = value;
          this.bufferCtx = value.getContext('2d');
          this._width = value.width;
          this._height = value.height;
          if (this.sprite) {
            this.sprite.canvas = value;
            this.sprite.ctx = this.bufferCtx!;
          }
        }
        return true;
      case 'palette':
        this.palette = value as string;
        return true;
      case 'depth':
        // For canvas, depth is always 32-bit RGBA
        return true;
      default:
        return super.setProperty(prop, value);
    }
  }

  deconstruct(): void {
    // Deconstruct all children
    for (const element of this.elements) {
      element.deconstruct();
    }
    this.elements = [];
    super.deconstruct();
  }
}
