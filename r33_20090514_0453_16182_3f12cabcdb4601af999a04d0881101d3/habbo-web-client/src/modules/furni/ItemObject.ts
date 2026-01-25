/**
 * Item Object Class - Wall items (posters, post-its, photos)
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 5 - Item Object Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  ItemObjectDefinition,
  FurnitureInfo,
  FurnitureSpriteInfo,
  ItemClasses,
  DEFAULT_INK,
  DEFAULT_BLEND,
} from './types';

/**
 * Item object - wall-mounted items
 */
export class ItemObject extends BaseObject {
  protected pClass: string = '';
  protected pName: string = '';
  protected pCustom: string = '';
  protected pType: string = '';
  protected pSprList: FurnitureSpriteInfo[] = [];
  protected pLocX: number = 0;
  protected pLocY: number = 0;
  protected pLocH: number = 0;
  protected pLocZ: number = 0;
  protected pXFactor: number = 64;
  protected pWallX: number = 0;
  protected pWallY: number = 0;
  protected pLocalX: number = 0;
  protected pLocalY: number = 0;
  protected pFormatVer: 'old' | 'new' = 'old';
  protected pDirection: string = 'leftwall';
  protected pParentWallLocZ: number | null = null;
  protected pExpireTimeStamp: number = -1;

  // Geometry reference
  protected geometry: { getScreenCoordinate: (x: number, y: number, h: number) => [number, number, number]; pXFactor: number } | null = null;

  construct(): void {
    super.construct();
    this.pClass = '';
    this.pName = '';
    this.pCustom = '';
    this.pType = '';
    this.pSprList = [];
    this.pLocX = 0;
    this.pLocY = 0;
    this.pLocH = 0;
    this.pLocZ = 0;
    this.pWallX = 0;
    this.pWallY = 0;
    this.pLocalX = 0;
    this.pLocalY = 0;
    this.pFormatVer = 'old';
    this.pDirection = 'leftwall';
    this.pParentWallLocZ = null;
    this.pExpireTimeStamp = -1;
  }

  deconstruct(): void {
    this.pSprList = [];
    this.pParentWallLocZ = null;
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
   * Define the item object
   */
  define(props: ItemObjectDefinition): boolean {
    this.pClass = props.class;
    this.pLocX = props.x;
    this.pLocY = props.y;
    this.pLocH = props.h;
    this.pLocZ = props.z;
    this.pLocalX = props.local_x;
    this.pLocalY = props.local_y;
    this.pWallX = props.wall_x;
    this.pWallY = props.wall_y;
    this.pFormatVer = props.formatVersion;
    this.pDirection = props.direction;
    this.pType = props.type;
    this.pExpireTimeStamp = props.expire || -1;

    // Set name and description based on class
    switch (this.pClass) {
      case ItemClasses.POSTER:
        this.pName = `poster_${this.pType}_name`;
        this.pCustom = `poster_${this.pType}_desc`;
        break;
      case ItemClasses.POST_IT:
      case ItemClasses.POST_IT_VD:
        this.pName = 'Post-It';
        this.pCustom = 'A sticky note';
        break;
      case ItemClasses.PHOTO:
        this.pName = 'Photo';
        this.pCustom = 'A photo';
        break;
    }

    if (!this.solveMembers()) {
      return false;
    }

    if (!this.prepare(props)) {
      return false;
    }

    this.updateLocation();
    return true;
  }

  /**
   * Get class
   */
  getClass(): string {
    return this.pClass;
  }

  /**
   * Set direction
   */
  setDirection(direction: string): void {
    this.pDirection = direction;
  }

  /**
   * Get furniture info
   */
  getInfo(): FurnitureInfo {
    return {
      name: this.pName,
      class: this.pClass,
      custom: this.pCustom,
      smallmember: `${this.pClass}_small`,
      expire: this.pExpireTimeStamp,
      image: null,
    };
  }

  /**
   * Get location (wall coordinates)
   */
  getLocation(): [number, number] {
    return [this.pWallX, this.pWallY];
  }

  /**
   * Get custom description
   */
  getCustom(): string {
    return this.pCustom;
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
    return true;
  }

  /**
   * Check if item has URL (for ad items)
   */
  hasURL(): boolean {
    // Would check if text exists for ad URL
    return false;
  }

  /**
   * Get URL (for ad items)
   */
  getUrl(): string {
    return '';
  }

  /**
   * Prepare (override in subclasses)
   */
  protected prepare(data: ItemObjectDefinition): boolean {
    return true;
  }

  /**
   * Get ink effect
   */
  protected solveInk(part: string, className?: string): number {
    return DEFAULT_INK;
  }

  /**
   * Get blend value
   */
  protected solveBlend(part: string, className?: string): number {
    return DEFAULT_BLEND;
  }

  /**
   * Get z-shift
   */
  protected solveLocZ(part: string, direction: number, className?: string): number {
    return 0;
  }

  /**
   * Get location shift
   */
  protected solveLocShift(part: string, direction: number, className?: string): { x: number; y: number } | number {
    return 0;
  }

  /**
   * Check if member exists
   */
  protected memberExists(name: string): boolean {
    return true;
  }

  /**
   * Resolve members for the item
   */
  protected solveMembers(): boolean {
    let memName: string;

    switch (this.pClass) {
      case ItemClasses.POST_IT:
      case ItemClasses.POST_IT_VD:
        memName = `${this.pDirection} ${this.pClass}`;
        break;
      case ItemClasses.POSTER:
        memName = `${this.pDirection} ${this.pClass} ${this.pType}`;
        break;
      case ItemClasses.PHOTO:
        memName = `${this.pDirection} ${this.pClass}`;
        break;
      default:
        console.warn(`Unknown item class: ${this.pClass}`);
        return false;
    }

    if (this.pXFactor === 32) {
      memName = 's_' + memName;
    }

    // Replace spaces with underscores for member name
    memName = memName.replace(/ /g, '_');

    if (!this.memberExists(memName)) {
      return false;
    }

    // Create sprite info
    const spriteInfo: FurnitureSpriteInfo = {
      memberName: memName,
      x: 0,
      y: 0,
      z: 0,
      width: 64,
      height: 64,
      ink: DEFAULT_INK,
      blend: DEFAULT_BLEND,
      visible: true,
    };

    this.pSprList = [spriteInfo];
    this.updateColor(this.pType);

    return true;
  }

  /**
   * Set state (updates color for post-its)
   */
  setState(value: string): void {
    this.updateColor(value);
  }

  /**
   * Update color based on type/hex string
   */
  protected updateColor(hexStr: string): void {
    if (this.pSprList.length === 0) return;

    const spr = this.pSprList[0];
    spr.ink = DEFAULT_INK;

    if (this.pClass === ItemClasses.POST_IT) {
      if (!hexStr) {
        hexStr = '#FFFF33';
      }
      spr.color = hexStr;
    } else if (this.pClass === ItemClasses.POST_IT_VD) {
      spr.color = '#FFFFFF';
    }
  }

  /**
   * Update sprite location
   */
  protected updateLocation(): void {
    if (this.pFormatVer === 'old') {
      // Old format: use room coordinates
      if (this.geometry) {
        const screenLocs = this.geometry.getScreenCoordinate(
          this.pLocX,
          this.pLocY,
          this.pLocH * 18 / 32
        );

        for (const spr of this.pSprList) {
          spr.x = screenLocs[0];
          spr.y = screenLocs[1];
        }
      }
    } else {
      // New format: use wall coordinates + local offset
      // Would need to find parent wall object and calculate position
      // For now, use local coordinates directly
      for (const spr of this.pSprList) {
        spr.x = this.pLocalX;
        spr.y = this.pLocalY;
      }
    }

    // Update z-index
    if (this.pParentWallLocZ !== null) {
      for (let i = 0; i < this.pSprList.length; i++) {
        this.pSprList[i].z = this.pParentWallLocZ + 20000 + i;
      }
    }
  }

  /**
   * Get type
   */
  getType(): string {
    return this.pType;
  }
}
