/**
 * Avatar Renderer Class
 *
 * Renders avatar figures on canvas using the figure system.
 * Handles sprite sheet loading and avatar composition.
 */

import {
  ParsedFigure,
  AvatarRenderState,
  SpriteFrame,
  AvatarSpriteSheet,
} from './types';
import { getFigureSystem } from './FigureSystem';

export class AvatarRenderer {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private spriteSheets: Map<string, AvatarSpriteSheet> = new Map();
  private loadingSheets: Set<string> = new Set();
  private assetBaseUrl: string = '';

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d')!;
  }

  /**
   * Set asset base URL
   */
  setAssetBaseUrl(url: string): void {
    this.assetBaseUrl = url.endsWith('/') ? url : url + '/';
  }

  /**
   * Load sprite sheet for a library
   */
  async loadSpriteSheet(libName: string): Promise<boolean> {
    if (this.spriteSheets.has(libName) || this.loadingSheets.has(libName)) {
      return true;
    }

    this.loadingSheets.add(libName);

    try {
      // Load spritesheet image
      const imageUrl = `${this.assetBaseUrl}${libName}/${libName}.png`;
      const image = await this.loadImage(imageUrl);

      // Load spritesheet manifest
      const manifestUrl = `${this.assetBaseUrl}${libName}/${libName}.json`;
      const response = await fetch(manifestUrl);
      const manifest = await response.json();

      const frames = new Map<string, SpriteFrame>();

      // Parse manifest frames
      if (manifest.frames) {
        for (const [frameName, frameData] of Object.entries(manifest.frames)) {
          const data = frameData as any;
          frames.set(frameName, {
            x: data.frame.x,
            y: data.frame.y,
            width: data.frame.w,
            height: data.frame.h,
            regX: data.spriteSourceSize?.x || 0,
            regY: data.spriteSourceSize?.y || 0,
            flipH: data.rotated || false,
          });
        }
      }

      this.spriteSheets.set(libName, { image, frames });
      this.loadingSheets.delete(libName);
      return true;
    } catch (error) {
      console.error(`Failed to load sprite sheet: ${libName}`, error);
      this.loadingSheets.delete(libName);
      return false;
    }
  }

  /**
   * Load image as promise
   */
  private loadImage(url: string): Promise<HTMLImageElement> {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => resolve(img);
      img.onerror = reject;
      img.src = url;
    });
  }

  /**
   * Render avatar to canvas
   */
  render(
    state: AvatarRenderState,
    x: number,
    y: number,
    scale: number = 1
  ): void {
    const system = getFigureSystem();
    if (!system.isLoaded()) {
      return;
    }

    const drawOrder = system.getDrawOrder(state.action, state.direction);

    // Clear the area first
    this.ctx.save();
    this.ctx.translate(x, y);
    this.ctx.scale(scale, scale);

    // Apply ghost effect if needed
    if (state.isGhost) {
      this.ctx.globalAlpha = 0.5;
    }

    // Render each part in draw order
    for (const partType of drawOrder) {
      const part = state.figure[partType];
      if (!part) continue;

      this.renderPart(partType, part, state);
    }

    this.ctx.restore();
  }

  /**
   * Render a single avatar part
   */
  private renderPart(
    partType: string,
    part: { model: string; color: string },
    state: AvatarRenderState
  ): void {
    const system = getFigureSystem();

    // Build asset name
    // Format: h_std_hr_1_2_0 (size_action_part_model_direction_frame)
    const size = 'h';
    const action = state.action;
    const direction = state.direction;
    const frame = system.getAnimationFrame(action, partType, state.frame);

    const assetName = `${size}_${action}_${partType}_${part.model}_${direction}_${frame}`;

    // Find sprite sheet containing this asset
    for (const [, sheet] of this.spriteSheets) {
      const frameData = sheet.frames.get(assetName);
      if (frameData) {
        this.drawFrame(sheet.image, frameData, part.color);
        return;
      }
    }
  }

  /**
   * Draw a sprite frame
   */
  private drawFrame(
    image: HTMLImageElement | ImageBitmap,
    frame: SpriteFrame,
    tintColor: string
  ): void {
    // Create offscreen canvas for tinting
    const offscreen = document.createElement('canvas');
    offscreen.width = frame.width;
    offscreen.height = frame.height;
    const offCtx = offscreen.getContext('2d')!;

    // Draw sprite
    offCtx.drawImage(
      image,
      frame.x,
      frame.y,
      frame.width,
      frame.height,
      0,
      0,
      frame.width,
      frame.height
    );

    // Apply color tint
    if (tintColor !== '#EEEEEE' && tintColor !== '#eeeeee') {
      offCtx.globalCompositeOperation = 'multiply';
      offCtx.fillStyle = tintColor;
      offCtx.fillRect(0, 0, frame.width, frame.height);

      offCtx.globalCompositeOperation = 'destination-atop';
      offCtx.drawImage(
        image,
        frame.x,
        frame.y,
        frame.width,
        frame.height,
        0,
        0,
        frame.width,
        frame.height
      );
    }

    // Draw to main canvas
    this.ctx.save();
    if (frame.flipH) {
      this.ctx.scale(-1, 1);
      this.ctx.drawImage(
        offscreen,
        -(frame.regX + frame.width),
        -frame.regY
      );
    } else {
      this.ctx.drawImage(offscreen, -frame.regX, -frame.regY);
    }
    this.ctx.restore();
  }

  /**
   * Get canvas
   */
  getCanvas(): HTMLCanvasElement {
    return this.canvas;
  }

  /**
   * Get context
   */
  getContext(): CanvasRenderingContext2D {
    return this.ctx;
  }

  /**
   * Clear canvas
   */
  clear(): void {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
  }

  /**
   * Check if sprite sheet is loaded
   */
  hasSpriteSheet(libName: string): boolean {
    return this.spriteSheets.has(libName);
  }
}
