/**
 * Active Object Class - Base class for interactive floor furniture
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 3 - Active Object Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  FurnitureDefinition,
  FurnitureInfo,
  FurnitureSpriteInfo,
  SlideState,
  PartPropsMap,
  DEFAULT_INK,
  DEFAULT_BLEND,
  RoomType,
} from './types';

/**
 * Active object - interactive floor furniture
 */
export class ActiveObject extends BaseObject {
  protected pClass: string = '';
  protected pName: string = '';
  protected pCustom: string = '';
  protected pSprList: FurnitureSpriteInfo[] = [];
  protected pDirection: number[] = [];
  protected pDimensions: number[] = [];
  protected pLoczList: number[][] = [];
  protected pLocShiftList: Array<Array<{ x: number; y: number } | number>> = [];
  protected pPartColors: string[] = [];
  protected pAnimFrame: number = 0;
  protected pLocX: number = 0;
  protected pLocY: number = 0;
  protected pLocH: number = 0;
  protected pAltitude: number = 0;
  protected pXFactor: number = 64;
  protected pCorrectLocZ: boolean = false;
  protected pSmallMember: string = '';
  protected pExpireTimeStamp: number = -1;
  protected pSlideTimePerTile: number = 500;
  protected pSlideState: SlideState | null = null;

  // Geometry reference
  protected geometry: { getScreenCoordinate: (x: number, y: number, h: number) => [number, number, number]; pXFactor: number } | null = null;

  construct(): void {
    super.construct();
    this.pClass = '';
    this.pName = '';
    this.pCustom = '';
    this.pSprList = [];
    this.pDirection = [];
    this.pDimensions = [];
    this.pLoczList = [];
    this.pLocShiftList = [];
    this.pPartColors = [];
    this.pAnimFrame = 0;
    this.pLocX = 0;
    this.pLocY = 0;
    this.pLocH = 0;
    this.pAltitude = 0;
    this.pExpireTimeStamp = -1;
    this.pSlideTimePerTile = 500;
  }

  deconstruct(): void {
    this.pSprList = [];
    super.deconstruct();
  }

  /**
   * Set geometry reference for coordinate calculations
   */
  setGeometry(geometry: typeof this.geometry): void {
    this.geometry = geometry;
    if (geometry) {
      this.pXFactor = geometry.pXFactor;
    }
  }

  /**
   * Set room type (affects z-index calculation)
   */
  setRoomType(roomType: RoomType): void {
    this.pCorrectLocZ = roomType === 'private';
  }

  /**
   * Define the furniture object
   */
  define(data: FurnitureDefinition): boolean {
    this.pClass = data.class;
    this.pDirection = data.direction || [0];
    this.pDimensions = data.dimensions || [1, 1];
    this.pAltitude = data.altitude || 0;
    this.pLocX = data.x;
    this.pLocY = data.y;
    this.pLocH = this.pAltitude;
    this.pExpireTimeStamp = data.expire || -1;

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
   * Get furniture info
   */
  getInfo(): FurnitureInfo {
    return {
      name: this.pName || this.pClass,
      class: this.pClass,
      custom: this.pCustom,
      expire: this.pExpireTimeStamp,
      smallmember: this.pSmallMember,
      image: null,
    };
  }

  /**
   * Get current location
   */
  getLocation(): [number, number, number] {
    return [this.pLocX, this.pLocY, this.pLocH];
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
   * Handle selection (click)
   */
  select(): boolean {
    return false;
  }

  /**
   * Move to absolute position
   */
  moveTo(x: number, y: number, h: number): void {
    this.pLocX = x;
    this.pLocY = y;
    this.pLocH = h + this.pAltitude;
    this.updateLocation();
  }

  /**
   * Move by relative amount
   */
  moveBy(dx: number, dy: number, dh: number): void {
    this.pLocX += dx;
    this.pLocY += dy;
    this.pLocH += dh;
    this.updateLocation();
  }

  /**
   * Rotate the furniture
   */
  rotate(change: number = 2): number {
    if (this.pSprList.length === 0) return -1;

    let newDirection = this.pDirection[0];

    for (let j = 0; j <= 3; j++) {
      newDirection = (newDirection + change + j) % 8;
      if (newDirection < 0) {
        newDirection = 8 + newDirection;
      }

      // Check if member exists for this direction
      if (this.memberExists(this.getMemberName(newDirection))) {
        break;
      }
    }

    return newDirection;
  }

  /**
   * Set up slide animation
   */
  setSlideTo(fromLoc: [number, number, number], toLoc: [number, number, number], timeNow?: number): void {
    const startTime = timeNow ?? Date.now();
    this.pLocX = fromLoc[0];
    this.pLocY = fromLoc[1];
    this.pLocH = fromLoc[2];

    const distances = [
      Math.abs(fromLoc[0] - toLoc[0]),
      Math.abs(fromLoc[1] - toLoc[1]),
      Math.abs(fromLoc[2] - toLoc[2]),
    ];

    const moveTime = Math.max(...distances) * this.pSlideTimePerTile;

    this.pSlideState = {
      startTime,
      endTime: startTime + moveTime,
      startLoc: [this.pLocX, this.pLocY, this.pLocH],
      destLoc: toLoc,
      timePerTile: this.pSlideTimePerTile,
    };

    this.updateLocation();
  }

  /**
   * Animate slide (call each frame)
   */
  animateSlide(timeNow?: number): boolean {
    if (!this.pSlideState) return true;

    const now = timeNow ?? Date.now();

    if (this.pSlideState.endTime < now) {
      // Animation complete
      this.pLocX = Math.floor(this.pSlideState.destLoc[0]);
      this.pLocY = Math.floor(this.pSlideState.destLoc[1]);
      this.pLocH = this.pSlideState.destLoc[2];
      this.pSlideState = null;
      this.updateLocation();
      return true;
    }

    // Interpolate position
    const timeUsed = now - this.pSlideState.startTime;
    const duration = this.pSlideState.endTime - this.pSlideState.startTime;
    const percent = timeUsed / duration;

    const startLoc = this.pSlideState.startLoc;
    const destLoc = this.pSlideState.destLoc;

    this.pLocX = (destLoc[0] - startLoc[0]) * percent + startLoc[0];
    this.pLocY = (destLoc[1] - startLoc[1]) * percent + startLoc[1];
    this.pLocH = (destLoc[2] - startLoc[2]) * percent + startLoc[2];

    this.updateLocation();
    return true;
  }

  /**
   * Apply ghost effect (semi-transparent)
   */
  ghostObject(): void {
    for (const spr of this.pSprList) {
      if (spr.ink === 33) {
        spr.visible = false;
      } else {
        spr.blend = 35;
      }
    }
  }

  /**
   * Remove ghost effect
   */
  removeGhostEffect(): void {
    for (const spr of this.pSprList) {
      spr.visible = true;
      spr.blend = 100;
    }
  }

  /**
   * Get screen location
   */
  getScreenLocation(): { x: number; y: number } {
    if (this.pSprList.length === 0) {
      return { x: 0, y: 0 };
    }

    const spr = this.pSprList[0];
    return {
      x: spr.x + spr.width / 2,
      y: spr.y + spr.height / 2,
    };
  }

  /**
   * Prepare furniture (override in subclasses)
   */
  protected prepare(data?: Record<string, unknown>): boolean {
    return true;
  }

  /**
   * Called after location update (override in subclasses)
   */
  protected relocate(spriteList: FurnitureSpriteInfo[]): boolean {
    return true;
  }

  /**
   * Parse color string into array
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

    // Pad to at least 4 colors
    while (this.pPartColors.length < 4) {
      this.pPartColors.push('#ffffff');
    }
  }

  /**
   * Get ink effect for a part
   */
  protected solveInk(part: string, className?: string): number {
    const props = this.getPartProps(part, className);
    return props?.ink ?? DEFAULT_INK;
  }

  /**
   * Get blend value for a part
   */
  protected solveBlend(part: string, className?: string): number {
    const props = this.getPartProps(part, className);
    return props?.blend ?? DEFAULT_BLEND;
  }

  /**
   * Check if part captures events
   */
  protected capturesEvents(part: string, className?: string): boolean {
    const props = this.getPartProps(part, className);
    return props?.events !== false;
  }

  /**
   * Get z-shift for a part at a direction
   */
  protected solveLocZ(part: string, direction: number, className?: string): number {
    const props = this.getPartProps(part, className);
    if (!props?.zshift) return 0;

    const dir = direction >= props.zshift.length ? 0 : direction;
    return props.zshift[dir] || 0;
  }

  /**
   * Get location shift for a part at a direction
   */
  protected solveLocShift(part: string, direction: number, className?: string): { x: number; y: number } | number {
    const props = this.getPartProps(part, className);
    if (!props?.locshift) return 0;

    const dir = direction >= props.locshift.length ? 0 : direction;
    return props.locshift[dir] || 0;
  }

  /**
   * Get part properties (would load from .props files)
   */
  protected getPartProps(part: string, className?: string): PartPropsMap[string] | null {
    // In a real implementation, this would load from {class}.props files
    // For now, return default values
    return null;
  }

  /**
   * Check if member exists
   */
  protected memberExists(name: string): boolean {
    // Would check asset registry
    return true;
  }

  /**
   * Get member name for current state
   */
  protected getMemberName(direction?: number): string {
    const dir = direction ?? (this.pDirection[0] || 0);
    let name = this.pClass;

    if (this.pXFactor === 32) {
      name = 's_' + name;
    }

    name += '_a_0';

    if (this.pDimensions.length >= 2) {
      name += `_${this.pDimensions[0]}_${this.pDimensions[1]}`;
    }

    name += `_${dir}_${this.pAnimFrame}`;

    return name;
  }

  /**
   * Resolve members/sprites for the furniture
   */
  protected solveMembers(): boolean {
    let className = this.pClass;

    // Handle special class names with *
    if (className.includes('*')) {
      const smallMem = className + '_small';
      className = className.substring(0, className.indexOf('*'));
      this.pSmallMember = smallMem;
    } else {
      this.pSmallMember = className + '_small';
    }

    if (this.pXFactor === 32) {
      className = 's_' + className;
    }

    // Clear existing sprites
    this.pSprList = [];
    this.pLoczList = [];
    this.pLocShiftList = [];

    let memNum = 1;
    let i = 'a'.charCodeAt(0);
    let j = 0;
    let loczAdjust = -5;

    while (memNum > 0) {
      const partChar = String.fromCharCode(i);

      // Build member name
      let memNameA = `${className}_${partChar}_0`;

      if (this.pDimensions.length >= 2) {
        memNameA += `_${this.pDimensions[0]}_${this.pDimensions[1]}`;
      }

      let memName: string;
      const dir = this.pDirection.length > j ? this.pDirection[j] : this.pDirection[0];
      memName = `${memNameA}_${dir}_${this.pAnimFrame}`;

      // Check if member exists (would be actual asset check)
      memNum = this.memberExists(memName) ? 1 : 0;

      if (memNum === 0 && j === 0) {
        // Try next direction
        if (this.pDirection[0] < 7) {
          for (let d = 0; d < this.pDirection.length; d++) {
            this.pDirection[d] = (this.pDirection[d] + 1) % 8;
          }
          continue;
        } else {
          // Use placeholder
          memName = this.pXFactor === 32 ? 's_room_object_placeholder' : 'room_object_placeholder';
          memNum = 1;
        }
      }

      if (memNum !== 0) {
        // Build locz list for this sprite
        const loczForDir: number[] = [];
        const locShiftForDir: Array<{ x: number; y: number } | number> = [];

        for (let direction = 0; direction <= 7; direction++) {
          loczForDir.push(this.solveLocZ(partChar, direction, className) + loczAdjust);
          locShiftForDir.push(this.solveLocShift(partChar, direction, className));
        }

        this.pLoczList.push(loczForDir);
        this.pLocShiftList.push(locShiftForDir);

        // Create sprite info
        const spriteInfo: FurnitureSpriteInfo = {
          memberName: memName,
          x: 0,
          y: 0,
          z: 0,
          width: 64, // Would be actual member width
          height: 64, // Would be actual member height
          ink: this.solveInk(partChar, className),
          blend: this.solveBlend(partChar, className),
          color: j < this.pPartColors.length ? this.pPartColors[j] : undefined,
          rotation: 0,
          visible: true,
        };

        this.pSprList.push(spriteInfo);
        loczAdjust++;
      }

      i++;
      j++;

      // Stop if we've gone through all letters
      if (i > 'z'.charCodeAt(0)) break;
    }

    // Handle shadow
    this.solveShadow(className);

    return this.pSprList.length > 0;
  }

  /**
   * Solve shadow sprite
   */
  protected solveShadow(className: string): void {
    let shadowName = `${className}_sd`;

    if (this.pDirection.length > 0) {
      shadowName += `_${this.pDirection[0]}`;
    }

    // Would check if shadow member exists and add to sprite list
    // Shadow sprites have very low z-index (-4000)
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

      // Apply location shift
      const dir = this.pDirection[0] || 0;
      if (i < this.pLocShiftList.length && dir < this.pLocShiftList[i].length) {
        const shift = this.pLocShiftList[i][dir];
        if (typeof shift === 'object') {
          spr.x += shift.x;
          spr.y += shift.y;
        }
      }

      // Calculate z-index
      const zShift = i < this.pLoczList.length && dir < this.pLoczList[i].length
        ? this.pLoczList[i][dir]
        : 0;

      if (this.pCorrectLocZ) {
        spr.z = screenLocs[2] + (this.pLocH * 1000) + zShift - 1;
      } else {
        spr.z = screenLocs[2] + zShift - 1;
      }
    }

    this.relocate(this.pSprList);
  }

  /**
   * Get furniture class
   */
  getClass(): string {
    return this.pClass;
  }

  /**
   * Get direction
   */
  getDirection(): number[] {
    return this.pDirection;
  }
}
