/**
 * Sprite Manager - Manages canvas-based sprites
 *
 * Ported from: fuse_client/Cast External ParentScript 34 - Sprite Manager Class.ls
 *
 * In the original Director, sprites were managed through the score.
 * Here we use off-screen canvas elements that get composited to the main canvas.
 */

import { SpriteData, Point } from './types';

const MAX_SPRITES = 1000;

class SpriteManager {
  private sprites: Map<number, SpriteData> = new Map();
  private spriteOwners: Map<number, string> = new Map();
  private eventBrokers: Map<number, string> = new Map();
  private availableSprites: number[] = [];
  private nextSpriteNum = 1;

  constructor() {
    // Pre-allocate sprite numbers
    for (let i = MAX_SPRITES; i >= 1; i--) {
      this.availableSprites.push(i);
    }
  }

  /**
   * Reserve a sprite for an owner
   */
  reserveSprite(ownerId: string): number {
    if (this.availableSprites.length === 0) {
      console.error('SpriteManager: Out of sprites!');
      return -1;
    }

    const spriteNum = this.availableSprites.pop()!;
    this.spriteOwners.set(spriteNum, ownerId);

    // Create the sprite data with an off-screen canvas
    const canvas = document.createElement('canvas');
    canvas.width = 1;
    canvas.height = 1;
    const ctx = canvas.getContext('2d')!;

    const sprite: SpriteData = {
      id: `sprite_${spriteNum}`,
      canvas,
      ctx,
      x: 0,
      y: 0,
      z: 0,
      width: 1,
      height: 1,
      visible: true,
      blend: 100,
      ink: 0,
      color: '#000000',
      bgColor: '#FFFFFF',
      cursor: 'default',
    };

    this.sprites.set(spriteNum, sprite);

    return spriteNum;
  }

  /**
   * Release a sprite back to the pool
   */
  releaseSprite(spriteNum: number, ownerId?: string): boolean {
    if (!this.sprites.has(spriteNum)) {
      return false;
    }

    // Verify ownership if specified
    if (ownerId && this.spriteOwners.get(spriteNum) !== ownerId) {
      return false;
    }

    this.sprites.delete(spriteNum);
    this.spriteOwners.delete(spriteNum);
    this.eventBrokers.delete(spriteNum);
    this.availableSprites.push(spriteNum);

    return true;
  }

  /**
   * Get a sprite by number
   */
  getSprite(spriteNum: number): SpriteData | null {
    return this.sprites.get(spriteNum) ?? null;
  }

  /**
   * Set the event broker (element ID) for a sprite
   */
  setEventBroker(spriteNum: number, elementId: string): void {
    this.eventBrokers.set(spriteNum, elementId);
  }

  /**
   * Get the event broker for a sprite
   */
  getEventBroker(spriteNum: number): string | null {
    return this.eventBrokers.get(spriteNum) ?? null;
  }

  /**
   * Find sprite at a given point
   */
  getSpriteAt(point: Point): number | null {
    // Sort sprites by z-order (highest first) and find the first visible one at the point
    const sortedSprites = Array.from(this.sprites.entries())
      .filter(([_, sprite]) => sprite.visible)
      .sort((a, b) => b[1].z - a[1].z);

    for (const [spriteNum, sprite] of sortedSprites) {
      if (
        point.x >= sprite.x &&
        point.x < sprite.x + sprite.width &&
        point.y >= sprite.y &&
        point.y < sprite.y + sprite.height
      ) {
        // Check if pixel at this point is not transparent
        const localX = point.x - sprite.x;
        const localY = point.y - sprite.y;
        const pixel = sprite.ctx.getImageData(localX, localY, 1, 1).data;
        if (pixel[3] > 0) {
          return spriteNum;
        }
      }
    }

    return null;
  }

  /**
   * Get all sprites sorted by z-order for rendering
   */
  getSpritesByZOrder(): Array<[number, SpriteData]> {
    return Array.from(this.sprites.entries())
      .filter(([_, sprite]) => sprite.visible)
      .sort((a, b) => a[1].z - b[1].z);
  }

  /**
   * Render all sprites to the main canvas
   */
  renderTo(ctx: CanvasRenderingContext2D): void {
    const sortedSprites = this.getSpritesByZOrder();

    for (const [_, sprite] of sortedSprites) {
      if (sprite.blend < 100) {
        ctx.globalAlpha = sprite.blend / 100;
      }

      ctx.drawImage(sprite.canvas, sprite.x, sprite.y);

      if (sprite.blend < 100) {
        ctx.globalAlpha = 1;
      }
    }
  }

  /**
   * Get available sprite count
   */
  getAvailableCount(): number {
    return this.availableSprites.length;
  }

  /**
   * Clear all sprites owned by a specific owner
   */
  clearOwner(ownerId: string): void {
    const toRelease: number[] = [];

    for (const [spriteNum, owner] of this.spriteOwners.entries()) {
      if (owner === ownerId) {
        toRelease.push(spriteNum);
      }
    }

    for (const spriteNum of toRelease) {
      this.releaseSprite(spriteNum);
    }
  }
}

// Singleton instance
export const spriteManager = new SpriteManager();

// API functions (matching original Lingo API)
export function reserveSprite(ownerId: string): number {
  return spriteManager.reserveSprite(ownerId);
}

export function releaseSprite(spriteNum: number, ownerId?: string): boolean {
  return spriteManager.releaseSprite(spriteNum, ownerId);
}

export function getSprite(spriteNum: number): SpriteData | null {
  return spriteManager.getSprite(spriteNum);
}

export function getSpriteManager(): SpriteManager {
  return spriteManager;
}
