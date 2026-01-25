/**
 * Room Geometry Class
 *
 * Ported from: hh_room/Cast External ParentScript 7 - Room Geometry Class.ls
 *
 * Handles coordinate transformations between room (tile) coordinates
 * and screen coordinates for isometric rendering.
 */

import { GeometryConfig, RoomLocation, ScreenCoordinate, TILE_BLOCKED, TILE_DOOR } from './types';

export class RoomGeometry {
  // Offset values for screen positioning
  public xOffset: number = 0;
  public yOffset: number = 0;
  public zOffset: number = 0;

  // Factor values for coordinate transformation
  public xFactor: number = 64;  // Tile width (64 for large, 32 for small)
  public yFactor: number = 32;  // Tile height factor
  public hFactor: number = 32;  // Height factor

  // Height map (walkable areas and heights)
  private heightMap: number[][] = [];

  // Place map (where objects can be placed)
  private placeMap: number[][] = [];

  // Floor map (for floor patterns)
  private floorMap: number[][] = [];

  constructor(config?: Partial<GeometryConfig>) {
    if (config) {
      this.define(config);
    }
  }

  /**
   * Define geometry parameters
   */
  define(config: Partial<GeometryConfig>): boolean {
    if (config.offsetX !== undefined) this.xOffset = config.offsetX;
    if (config.offsetY !== undefined) this.yOffset = config.offsetY;
    if (config.offsetZ !== undefined) this.zOffset = config.offsetZ;
    if (config.factorX !== undefined) this.xFactor = config.factorX;
    if (config.factorY !== undefined) this.yFactor = config.factorY;
    if (config.factorH !== undefined) this.hFactor = config.factorH;
    return true;
  }

  /**
   * Load height map from string data
   * Format: Each line represents a row, each character represents a tile
   * 'x' = blocked, 'y' = door, '0'-'9' = height, 'A'-'H' = higher heights
   */
  loadHeightMap(data: string, useFloorMap: boolean = false): boolean {
    if (useFloorMap) {
      this.floorMap = [];
    } else {
      this.heightMap = [];
      this.placeMap = [];
    }

    const lines = data.split('\n').filter(line => line.trim() !== '');

    for (const line of lines) {
      const heights: number[] = [];
      const places: number[] = [];

      for (const char of line) {
        if (char === 'x') {
          // Blocked tile
          heights.push(TILE_BLOCKED);
          places.push(TILE_BLOCKED);
        } else if (char === 'y') {
          // Door tile
          heights.push(0);
          places.push(TILE_DOOR);
        } else if (char >= 'A' && char < 'I') {
          // High elevation (A=0, B=1, etc. with door marker)
          heights.push(char.charCodeAt(0) - 65);
          places.push(TILE_DOOR);
        } else {
          // Normal height (0-9)
          const height = parseInt(char, 10);
          heights.push(isNaN(height) ? 0 : height);
          places.push(0);
        }
      }

      if (useFloorMap) {
        this.floorMap.push(heights);
      } else {
        this.heightMap.push(heights);
        this.placeMap.push(places);
      }
    }

    return true;
  }

  /**
   * Convert room coordinates to screen coordinates
   */
  getScreenCoordinate(locX: number, locY: number, height: number = 0): ScreenCoordinate {
    // Isometric transformation
    const locH = ((locX - locY) * (this.xFactor * 0.5)) + this.xOffset;
    const locV = ((locY + locX) * this.yFactor * 0.5) + this.yOffset - (height * this.hFactor);
    const locZ = (1000 * (locX + locY + 1)) + this.zOffset;

    return {
      x: Math.floor(locH),
      y: Math.floor(locV),
      z: Math.floor(locZ),
    };
  }

  /**
   * Get height at a specific coordinate
   */
  getCoordinateHeight(x: number, y: number): number {
    const ix = Math.floor(x);
    const iy = Math.floor(y);

    if (iy < 0 || iy >= this.heightMap.length) {
      return 0;
    }

    const row = this.heightMap[iy];
    if (ix < 0 || ix >= row.length) {
      return 0;
    }

    return row[ix];
  }

  /**
   * Convert screen coordinates to world coordinates
   */
  getWorldCoordinate(screenX: number, screenY: number): RoomLocation | null {
    if (this.heightMap.length === 0) {
      return null;
    }

    // Reverse isometric transformation
    let tX = Math.floor(
      ((screenX - this.yFactor - this.xOffset) / this.xFactor) +
      ((screenY - this.yOffset) / this.yFactor)
    );
    let tY = Math.floor(
      ((screenY - this.yOffset) / this.yFactor) -
      ((screenX - this.yFactor - this.xOffset) / this.xFactor)
    );

    let height = this.getHeightAtCoord(tX, tY);

    if (height === 0) {
      return { x: tX, y: tY, h: 0 };
    }

    // Check for elevated tiles
    for (let i = 1; i <= 9; i++) {
      tX = Math.floor(
        ((screenX - this.yFactor - this.xOffset) / this.xFactor) +
        ((screenY + (i * this.hFactor) - this.yOffset) / this.yFactor)
      );
      tY = Math.floor(
        ((screenY + (i * this.hFactor) - this.yOffset) / this.yFactor) -
        ((screenX - this.yFactor - this.xOffset) / this.xFactor)
      );

      height = this.getHeightAtCoord(tX, tY);
      if (height === i) {
        return { x: tX, y: tY, h: height };
      }
    }

    return null;
  }

  /**
   * Convert screen coordinates to floor coordinates
   */
  getFloorCoordinate(screenX: number, screenY: number): RoomLocation | null {
    if (this.floorMap.length === 0) {
      return this.getWorldCoordinate(screenX, screenY);
    }

    let tX = Math.floor(
      ((screenX - this.yFactor - this.xOffset) / this.xFactor) +
      ((screenY - this.yOffset) / this.yFactor)
    );
    let tY = Math.floor(
      ((screenY - this.yOffset) / this.yFactor) -
      ((screenX - this.yFactor - this.xOffset) / this.xFactor)
    );

    let height = this.getFloorHeightAtCoord(tX, tY);

    if (height === 0) {
      return { x: tX, y: tY, h: 0 };
    }

    // Check for elevated tiles
    for (let i = 1; i <= 9; i++) {
      tX = Math.floor(
        ((screenX - this.yFactor - this.xOffset) / this.xFactor) +
        ((screenY + (i * this.hFactor) - this.yOffset) / this.yFactor)
      );
      tY = Math.floor(
        ((screenY + (i * this.hFactor) - this.yOffset) / this.yFactor) -
        ((screenX - this.yFactor - this.xOffset) / this.xFactor)
      );

      height = this.getFloorHeightAtCoord(tX, tY);
      if (height === i) {
        return { x: tX, y: tY, h: height };
      }
    }

    return null;
  }

  /**
   * Helper to get height at coordinate
   */
  private getHeightAtCoord(x: number, y: number): number {
    if (y < 0 || y >= this.heightMap.length) return -1;
    if (x < 0 || x >= this.heightMap[y].length) return -1;
    return this.heightMap[y][x];
  }

  /**
   * Helper to get floor height at coordinate
   */
  private getFloorHeightAtCoord(x: number, y: number): number {
    if (y < 0 || y >= this.floorMap.length) return -1;
    if (x < 0 || x >= this.floorMap[y].length) return -1;
    return this.floorMap[y][x];
  }

  /**
   * Get the place map (where objects can be placed)
   */
  getObjectPlaceMap(): number[][] {
    return this.placeMap;
  }

  /**
   * Get the height map
   */
  getObjectHeightMap(): number[][] {
    return this.heightMap;
  }

  /**
   * Get tile height (Y factor)
   */
  getTileHeight(): number {
    return this.yFactor;
  }

  /**
   * Get tile width (X factor)
   */
  getTileWidth(): number {
    return this.xFactor;
  }

  /**
   * Check if a tile is empty (can place objects)
   */
  emptyTile(x: number, y: number): boolean {
    const px = x + 1;
    const py = y + 1;

    if (py < 1 || py > this.placeMap.length) return false;
    if (px < 1 || px > this.placeMap[py - 1].length) return false;

    return this.placeMap[py - 1][px - 1] < TILE_DOOR;
  }

  /**
   * Check if coordinates are valid (within map bounds)
   */
  isValidCoordinate(x: number, y: number): boolean {
    if (y < 0 || y >= this.heightMap.length) return false;
    if (x < 0 || x >= this.heightMap[y].length) return false;
    return this.heightMap[y][x] < TILE_DOOR;
  }

  /**
   * Check if a tile is blocked
   */
  isBlocked(x: number, y: number): boolean {
    const height = this.getHeightAtCoord(x, y);
    return height >= TILE_BLOCKED;
  }

  /**
   * Check if a tile is a door
   */
  isDoor(x: number, y: number): boolean {
    if (y < 0 || y >= this.placeMap.length) return false;
    if (x < 0 || x >= this.placeMap[y].length) return false;
    return this.placeMap[y][x] >= TILE_DOOR && this.placeMap[y][x] < TILE_BLOCKED;
  }

  /**
   * Get map dimensions
   */
  getMapDimensions(): { width: number; height: number } {
    const height = this.heightMap.length;
    const width = height > 0 ? Math.max(...this.heightMap.map(row => row.length)) : 0;
    return { width, height };
  }

  /**
   * Print debug info
   */
  print(): void {
    console.log('--- Room Geometry ---');
    console.log(`Offset: (${this.xOffset}, ${this.yOffset}, ${this.zOffset})`);
    console.log(`Factor: (${this.xFactor}, ${this.yFactor}, ${this.hFactor})`);
    console.log('Height Map:');
    for (const row of this.heightMap) {
      const rowStr = row.map(h => {
        if (h >= TILE_BLOCKED) return '.';
        if (h >= TILE_DOOR) return 'x';
        return h.toString();
      }).join(' ');
      console.log(`  ${rowStr}`);
    }
  }
}
