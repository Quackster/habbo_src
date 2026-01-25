/**
 * Photo Item Class - Furniture item for photos
 *
 * Ported from: hh_photo/Cast External ParentScript 5 - Photo Item Class.ls
 */

import { executeMessage } from '../../core/MessageBus';

/**
 * Photo item furniture class
 * Handles selection of photo items in the room to open photo viewer
 */
export class PhotoItem {
  private id: string;
  private sprites: Array<{ loc: [number, number] }> = [];

  constructor(id: string) {
    this.id = id;
  }

  /**
   * Get item ID
   */
  getID(): string {
    return this.id;
  }

  /**
   * Set sprite locations
   */
  setSprites(sprites: Array<{ loc: [number, number] }>): void {
    this.sprites = sprites;
  }

  /**
   * Get sprite locations
   */
  getSprites(): Array<{ loc: [number, number] }> {
    return this.sprites;
  }

  /**
   * Called when photo item is selected/clicked
   */
  select(): boolean {
    if (this.sprites.length < 1) {
      return false;
    }

    const loc = this.sprites[0].loc;

    // Request photo component to open photo viewer at item location
    executeMessage('openPhoto', {
      itemId: this.id,
      x: loc[0],
      y: loc[1],
    });

    return true;
  }
}
