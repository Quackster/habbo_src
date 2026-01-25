/**
 * Passive Object Class - Static wall decorations
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 4 - Passive Object Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  PassiveObjectDefinition,
  FurnitureInfo,
  FurnitureSpriteInfo,
  DEFAULT_INK,
  DEFAULT_BLEND,
  RoomType,
} from './types';

/**
 * Passive object - static wall/floor decorations
 */
export class PassiveObject extends BaseObject {
  protected pClass: string = '';
  protected pCustom: string = '';
  protected pSprList: FurnitureSpriteInfo[] = [];
  protected pDirection: number[] = [];
  protected pDimensions: number[] = [];
  protected pLoczList: number[] = [];
  protected pPartColors: string[] = [];
  protected pAnimFrame: number = 0;
  protected pLocX: number = 0;
  protected pLocY: number = 0;
  protected pLocH: number = 0;
  protected pAltitude: number = 0;
  protected pXFactor: number = 64;
  protected pCorrectLocZ: boolean = false;

  // Geometry reference
  protected geometry: { getScreenCoordinate: (x: number, y: number, h: number) => [number, number, number]; pXFactor: number } | null = null;

  construct(): void {
    super.construct();
    this.pClass = '';
    this.pCustom = '';
    this.pSprList = [];
    this.pDirection = [];
    this.pDimensions = [];
    this.pLoczList = [];
    this.pPartColors = [];
    this.pAnimFrame = 0;
    this.pLocX = 0;
    this.pLocY = 0;
    this.pLocH = 0;
    this.pAltitude = 0;
  }

  deconstruct(): void {
    this.pSprList = [];
    super.deconstruct();
  }

  /**
   * Set geometry reference
   */
  setGeometry(geometry: typeof this.geometry): void {
    this.geometry = geometry;
    if (geometry) {
      this.pXFactor = geometry.pXFactor;
    }
  }

  /**
   * Set room type
   */
  setRoomType(roomType: RoomType): void {
    this.pCorrectLocZ = roomType === 'private';
  }

  /**
   * Define the passive object
   */
  define(data: PassiveObjectDefinition): boolean {
    this.pClass = data.class;
    this.pDirection = data.direction || [0];
    this.pDimensions = data.dimensions || [];
    this.pLocX = data.x;
    this.pLocY = data.y;
    this.pLocH = data.h || 0;

    this.solveColors(data.colors);

    if (!this.solveMembers()) {
      return false;
    }

    if (!this.prepare(data.props)) {
      return false;
    }

    this.updateLocation();
    return true;
  }

  /**
   * Prepare (override in subclasses)
   */
  protected prepare(data?: Record<string, unknown>): boolean {
    return true;
  }

  /**
   * Get furniture info
   */
  getInfo(): FurnitureInfo {
    return {
      name: this.pClass,
      class: this.pClass,
      custom: this.pCustom,
      expire: -1,
    };
  }

  /**
   * Get current location
   */
  getLocation(): [number, number, number] {
    return [this.pLocX, this.pLocY, this.pLocH];
  }

  /**
   * Get direction
   */
  getDirection(): number[] {
    return this.pDirection;
  }

  /**
   * Get sprite list
   */
  getSprites(): FurnitureSpriteInfo[] {
    return this.pSprList;
  }

  /**
   * Handle selection
   */
  select(): boolean {
    return false;
  }

  /**
   * Parse color string
   */
  protected solveColors(partColors?: string): void {
    if (!partColors) {
      partColors = '0,0,0';
    }

    this.pPartColors = [];
    const parts = partColors.split(',');

    for (const part of parts) {
      this.pPartColors.push(String(part));
    }

    while (this.pPartColors.length < 4) {
      this.pPartColors.push('#ffffff');
    }
  }

  /**
   * Get ink effect for a part
   */
  protected solveInk(part: string): number {
    // Would load from .props file
    return DEFAULT_INK;
  }

  /**
   * Get blend value for a part
   */
  protected solveBlend(part: string): number {
    // Would load from .props file
    return DEFAULT_BLEND;
  }

  /**
   * Get z-shift for a part
   */
  protected solveLocZ(part: string, direction?: number): number {
    // Would load from .props file
    return 0;
  }

  /**
   * Check if member exists
   */
  protected memberExists(name: string): boolean {
    return true;
  }

  /**
   * Resolve members/sprites
   */
  protected solveMembers(): boolean {
    const tmpDirection = [...this.pDirection];

    this.pSprList = [];
    this.pLoczList = [];

    let memNum = 1;
    let i = 'a'.charCodeAt(0);
    let j = 0;

    while (memNum > 0) {
      const partChar = String.fromCharCode(i);

      // Build member name
      let memNameA = `${this.pClass}_${partChar}_0`;

      if (this.pDimensions.length >= 2) {
        memNameA += `_${this.pDimensions[0]}_${this.pDimensions[1]}`;
      }

      let memName: string;
      const dir = tmpDirection.length > j ? tmpDirection[j] : tmpDirection[0] || 0;
      memName = `${memNameA}_${dir}_${this.pAnimFrame}`;

      // Check if member exists
      memNum = this.memberExists(memName) ? 1 : 0;

      if (memNum === 0 && j === 0) {
        // Try next direction
        if (tmpDirection[0] < 7) {
          for (let d = 0; d < tmpDirection.length; d++) {
            tmpDirection[d] = (tmpDirection[d] + 1) % 8;
          }
          continue;
        } else {
          break;
        }
      }

      if (memNum !== 0) {
        // Calculate locz
        const locz = this.solveLocZ(partChar, dir);
        this.pLoczList.push(locz);

        // Create sprite info
        const spriteInfo: FurnitureSpriteInfo = {
          memberName: memName,
          x: 0,
          y: 0,
          z: 0,
          width: 64,
          height: 64,
          ink: this.solveInk(partChar),
          blend: this.solveBlend(partChar),
          color: j < this.pPartColors.length ? this.pPartColors[j] : undefined,
          rotation: 0,
          visible: true,
        };

        this.pSprList.push(spriteInfo);
      }

      i++;
      j++;

      if (i > 'z'.charCodeAt(0)) break;
    }

    // Handle shadow
    this.solveShadow();

    return this.pSprList.length > 0;
  }

  /**
   * Solve shadow sprite
   */
  protected solveShadow(): void {
    let shadowName = `${this.pClass}_sd`;

    if (this.pDirection.length > 0) {
      shadowName += `_${this.pDirection[0]}`;
    }

    // Would check if shadow exists and add with low z-index
  }

  /**
   * Update sprite locations
   */
  protected updateLocation(): void {
    if (!this.geometry) return;

    const screenLocs = this.geometry.getScreenCoordinate(this.pLocX, this.pLocY, this.pLocH);

    for (let i = 0; i < this.pSprList.length; i++) {
      const spr = this.pSprList[i];

      spr.x = screenLocs[0];
      spr.y = screenLocs[1];

      // Apply rotation offset
      if (spr.rotation === 180) {
        spr.x += this.pXFactor;
      }

      // Calculate z-index
      const locz = i < this.pLoczList.length ? this.pLoczList[i] : 0;

      if (this.pCorrectLocZ) {
        spr.z = screenLocs[2] + (this.pLocH * 1000) + locz;
      } else {
        spr.z = screenLocs[2] + locz;
      }
    }
  }

  /**
   * Show object
   */
  show(): void {
    for (const spr of this.pSprList) {
      spr.visible = true;
    }
  }

  /**
   * Hide object
   */
  hide(): void {
    for (const spr of this.pSprList) {
      spr.visible = false;
    }
  }

  /**
   * Get class
   */
  getClass(): string {
    return this.pClass;
  }
}
