/**
 * Unique Element Class
 *
 * Ported from: fuse_client/Cast External ParentScript 58 - Unique Element Class.ls
 *
 * A unique element is a single visual element that renders directly to its buffer.
 * It handles image loading, flipping, and rendering with blend/ink effects.
 */

import { BaseElement } from './BaseElement';
import { ElementProps, SpriteData } from '../types';
import { resourceManager } from '../../managers/ResourceManager';

export class UniqueElement extends BaseElement {
  private image: ImageData | null = null;
  private imageCanvas: HTMLCanvasElement | null = null;
  private imageCtx: CanvasRenderingContext2D | null = null;
  private depth: number = 32;
  private params: Record<string, unknown> = {};

  define(props: ElementProps): boolean {
    super.define(props);

    this.motherId = (props as unknown as { mother: string }).mother ?? '';

    // Create image canvas
    this.imageCanvas = document.createElement('canvas');
    this.imageCanvas.width = props.width || 1;
    this.imageCanvas.height = props.height || 1;
    this.imageCtx = this.imageCanvas.getContext('2d')!;

    // Load member image if specified
    if (props.member) {
      this.loadMemberImage(props.member);
    } else {
      // Create empty image
      this.depth = 32;
      this.imageCtx.fillStyle = 'transparent';
      this.imageCtx.fillRect(0, 0, this.imageCanvas.width, this.imageCanvas.height);
    }

    // Handle flipping
    if (props.flipH) {
      this.flipH();
    }
    if (props.flipV) {
      this.flipV();
    }

    // Store rendering parameters
    if (props.blend !== undefined && props.blend < 100) {
      this.params.blend = props.blend;
    }
    if (props.color && props.color !== '#000000') {
      this.params.color = props.color;
    }
    if (props.bgColor && props.bgColor !== '#FFFFFF') {
      this.params.bgColor = props.bgColor;
    }
    if (props.ink !== undefined && props.ink !== 0) {
      this.params.ink = props.ink;
    }

    return true;
  }

  /**
   * Load an image from a member resource
   */
  private async loadMemberImage(memberName: string): Promise<void> {
    try {
      const imageData = await resourceManager.getImage(memberName);
      if (imageData && this.imageCtx && this.imageCanvas) {
        // Resize canvas to match image
        this.imageCanvas.width = imageData.width;
        this.imageCanvas.height = imageData.height;
        this._width = imageData.width;
        this._height = imageData.height;

        // Draw image to canvas
        if (imageData instanceof ImageData) {
          this.imageCtx.putImageData(imageData, 0, 0);
        } else if (imageData instanceof HTMLImageElement) {
          this.imageCtx.drawImage(imageData, 0, 0);
        }
      }
    } catch (error) {
      console.warn(`UniqueElement: Failed to load member ${memberName}:`, error);
    }
  }

  /**
   * Flip the image horizontally
   */
  flipH(): void {
    if (!this.imageCanvas || !this.imageCtx) return;

    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = this.imageCanvas.width;
    tempCanvas.height = this.imageCanvas.height;
    const tempCtx = tempCanvas.getContext('2d')!;

    // Save current image
    tempCtx.drawImage(this.imageCanvas, 0, 0);

    // Clear and flip
    this.imageCtx.clearRect(0, 0, this.imageCanvas.width, this.imageCanvas.height);
    this.imageCtx.save();
    this.imageCtx.scale(-1, 1);
    this.imageCtx.drawImage(tempCanvas, -this.imageCanvas.width, 0);
    this.imageCtx.restore();
  }

  /**
   * Flip the image vertically
   */
  flipV(): void {
    if (!this.imageCanvas || !this.imageCtx) return;

    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = this.imageCanvas.width;
    tempCanvas.height = this.imageCanvas.height;
    const tempCtx = tempCanvas.getContext('2d')!;

    // Save current image
    tempCtx.drawImage(this.imageCanvas, 0, 0);

    // Clear and flip
    this.imageCtx.clearRect(0, 0, this.imageCanvas.width, this.imageCanvas.height);
    this.imageCtx.save();
    this.imageCtx.scale(1, -1);
    this.imageCtx.drawImage(tempCanvas, 0, -this.imageCanvas.height);
    this.imageCtx.restore();
  }

  /**
   * Render the element to its buffer
   */
  render(): void {
    if (!this.buffer || !this.bufferCtx || !this.imageCanvas) return;

    // Clear buffer
    this.bufferCtx.clearRect(0, 0, this.buffer.width, this.buffer.height);

    // Apply rendering parameters
    if (this.params.blend !== undefined) {
      this.bufferCtx.globalAlpha = (this.params.blend as number) / 100;
    }

    // Draw image to buffer
    this.bufferCtx.drawImage(
      this.imageCanvas,
      0,
      0,
      this.imageCanvas.width,
      this.imageCanvas.height,
      0,
      0,
      this.buffer.width,
      this.buffer.height
    );

    // Reset alpha
    if (this.params.blend !== undefined) {
      this.bufferCtx.globalAlpha = 1;
    }
  }

  resizeBy(offW: number, offH: number, forced?: boolean): void {
    super.resizeBy(offW, offH, forced);

    // Re-render after resize
    this.render();
  }

  getProperty(prop: string): unknown {
    switch (prop) {
      case 'image':
        return this.imageCanvas;
      case 'depth':
        return this.depth;
      case 'rect':
        return {
          x: this.sprite?.x ?? 0,
          y: this.sprite?.y ?? 0,
          width: this.sprite?.width ?? this._width,
          height: this.sprite?.height ?? this._height,
        };
      default:
        return super.getProperty(prop);
    }
  }

  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'image':
        if (value instanceof HTMLCanvasElement) {
          this.imageCanvas = value;
          this.imageCtx = value.getContext('2d');
          this.render();
        }
        return true;
      case 'depth':
        this.depth = value as number;
        return true;
      default:
        return super.setProperty(prop, value);
    }
  }

  deconstruct(): void {
    this.image = null;
    this.imageCanvas = null;
    this.imageCtx = null;
    super.deconstruct();
  }
}
