/**
 * Preview Renderer Class - Renders furniture preview images
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 8 - Preview Renderer Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { PreviewRenderOptions, LAYER_PARTS } from './types';

/**
 * Preview renderer - generates furniture preview thumbnails
 */
export class PreviewRenderer extends BaseObject {
  private canvas: HTMLCanvasElement | null = null;
  private ctx: CanvasRenderingContext2D | null = null;

  construct(): void {
    super.construct();

    // Create canvas for rendering previews
    this.canvas = document.createElement('canvas');
    this.ctx = this.canvas.getContext('2d');
  }

  deconstruct(): void {
    this.canvas = null;
    this.ctx = null;
    super.deconstruct();
  }

  /**
   * Get preview member for an image
   */
  getPreviewMember(image: ImageData | HTMLImageElement | null): HTMLCanvasElement | null {
    if (!image || !this.canvas || !this.ctx) {
      return null;
    }

    // Draw image to canvas
    if (image instanceof ImageData) {
      this.canvas.width = image.width;
      this.canvas.height = image.height;
      this.ctx.putImageData(image, 0, 0);
    } else {
      this.canvas.width = image.width;
      this.canvas.height = image.height;
      this.ctx.drawImage(image, 0, 0);
    }

    return this.canvas;
  }

  /**
   * Resolve class name to small member name
   */
  solveClass(furniClass: string, memStr?: string): string {
    let name = furniClass;

    // Handle special class names with *
    if (name.includes('*')) {
      const smallMem = name + '_small';
      name = name.substring(0, name.indexOf('*'));
      // Check if member exists, otherwise use base name
      return smallMem;
    }

    const smallMem = furniClass + '_small';

    // Would check if member exists
    // Return smallMem if exists, or memStr if provided and exists, or fallback
    return smallMem || memStr || 'no_icon_small';
  }

  /**
   * Solve color list from string
   */
  solveColorList(partColors?: string): string[] {
    if (!partColors || partColors === '') {
      partColors = '0,0,0';
    }

    const partList: string[] = [];
    const parts = partColors.split(',');

    for (const part of parts) {
      partList.push(String(part));
    }

    // Pad to at least 4 colors
    while (partList.length < 4) {
      partList.push('#ffffff');
    }

    return partList;
  }

  /**
   * Render preview image
   */
  renderPreviewImage(options: PreviewRenderOptions): ImageData | HTMLImageElement | null {
    let memStr = options.memberStr;
    let colorList = options.colorList;

    if (!memStr) {
      memStr = this.solveClass(options.furniClass, memStr);
    }

    if (options.colorListToSolve) {
      colorList = this.solveColorList(options.colorListToSolve);
    }

    // Check if layers exist
    if (!this.doLayersExist(memStr)) {
      // No layers, just apply color to base image
      const color = this.getSmallsColor(memStr, colorList);

      // Would load and return the member image
      // If color is valid, apply darken effect
      return null;
    }

    // Has layers - render composite
    return this.renderLayeredPreview(memStr, colorList || []);
  }

  /**
   * Get color for small preview
   */
  private getSmallsColor(memStr: string, colorList?: string[]): string | null {
    const color = this.getLastColor(colorList);

    if (color === 'ffffff' || color === '#ffffff' || memStr.includes('*')) {
      return null;
    }

    return color;
  }

  /**
   * Check if layers exist for a member
   */
  private doLayersExist(memStr: string): boolean {
    // Would check if any layer members exist (memStr_a, memStr_b, etc.)
    return false;
  }

  /**
   * Get last non-white color from list
   */
  private getLastColor(colorList?: string[]): string {
    let color = 'ffffff';

    if (Array.isArray(colorList)) {
      for (const c of colorList) {
        if (c.includes('ffffff') || c === '0' || c === 'null') {
          continue;
        }
        color = c;
      }
    }

    return color;
  }

  /**
   * Render layered preview
   */
  private renderLayeredPreview(memStr: string, colorList: string[]): ImageData | null {
    if (!this.canvas || !this.ctx) return null;

    // Would load base member and each layer, compositing them together
    // with appropriate colors

    const offset = { x: 50, y: 50 };

    // Set up canvas size (would be based on actual member dimensions)
    const width = 100 + offset.x * 2;
    const height = 100 + offset.y * 2;

    this.canvas.width = width;
    this.canvas.height = height;

    // Would draw base member
    // this.ctx.drawImage(baseMember, offset.x, offset.y);

    // Add each layer
    for (let i = 0; i < LAYER_PARTS.length; i++) {
      const layerName = `${memStr}_${LAYER_PARTS[i]}`;
      // Would check if layer exists and add it
      // this.addLayerToImage(i, memStr, colorList, offset);
    }

    // Trim white space (would calculate actual bounds)
    return this.ctx.getImageData(0, 0, width, height);
  }

  /**
   * Add a layer to the preview image
   */
  private addLayerToImage(
    layerIndex: number,
    memStr: string,
    colorList: string[],
    offset: { x: number; y: number }
  ): void {
    if (!this.ctx) return;

    const layerPart = LAYER_PARTS[layerIndex];
    const color = layerIndex < colorList.length ? colorList[layerIndex] : 'ffffff';

    // Would load layer member
    // const layerMem = loadMember(`${memStr}_${layerPart}`);

    // Calculate position based on registration points
    // const regP = layerMem.regPoint - baseMem.regPoint - offset;

    // Draw with color multiply effect
    // this.ctx.globalCompositeOperation = 'multiply';
    // this.ctx.fillStyle = color;
    // this.ctx.drawImage(layerMem, x, y);
  }

  /**
   * Apply darken color effect to an image
   */
  applyDarkenColor(
    sourceImage: ImageData | HTMLImageElement,
    color: string
  ): ImageData | null {
    if (!this.canvas || !this.ctx) return null;

    // Set canvas size
    const width = sourceImage instanceof ImageData ? sourceImage.width : sourceImage.width;
    const height = sourceImage instanceof ImageData ? sourceImage.height : sourceImage.height;

    this.canvas.width = width;
    this.canvas.height = height;

    // Draw source image
    if (sourceImage instanceof ImageData) {
      this.ctx.putImageData(sourceImage, 0, 0);
    } else {
      this.ctx.drawImage(sourceImage, 0, 0);
    }

    // Apply color multiply
    this.ctx.globalCompositeOperation = 'multiply';
    this.ctx.fillStyle = color.startsWith('#') ? color : `#${color}`;
    this.ctx.fillRect(0, 0, width, height);

    // Reset composite operation
    this.ctx.globalCompositeOperation = 'source-over';

    return this.ctx.getImageData(0, 0, width, height);
  }
}
