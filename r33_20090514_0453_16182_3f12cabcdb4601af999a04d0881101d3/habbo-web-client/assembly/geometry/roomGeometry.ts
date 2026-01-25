/**
 * Room Geometry - Height map and coordinate system
 *
 * Ported from: hh_room/Cast External ParentScript 7 - Room Geometry Class.ls
 */

// Geometry factors (configurable per room)
let xOffset: f64 = 0.0;
let yOffset: f64 = 0.0;
let zOffset: f64 = 0.0;
let xFactor: f64 = 64.0;
let yFactor: f64 = 32.0;
let hFactor: f64 = 32.0;

// Height map storage
let heightMapData: StaticArray<i32> = new StaticArray<i32>(0);
let placeMapData: StaticArray<i32> = new StaticArray<i32>(0);
let mapWidth: i32 = 0;
let mapHeight: i32 = 0;

// Special height values
const BLOCKED: i32 = 200000;
const DOOR: i32 = 100000;

/**
 * Define room geometry parameters
 */
export function defineGeometry(
  offX: f64,
  offY: f64,
  offZ: f64,
  facX: f64,
  facY: f64,
  facH: f64
): void {
  xOffset = offX;
  yOffset = offY;
  zOffset = offZ;
  xFactor = facX;
  yFactor = facY;
  hFactor = facH;
}

/**
 * Initialize height map with dimensions
 */
export function initHeightMap(width: i32, height: i32): void {
  mapWidth = width;
  mapHeight = height;
  heightMapData = new StaticArray<i32>(width * height);
  placeMapData = new StaticArray<i32>(width * height);
}

/**
 * Set height at a specific tile
 */
export function setHeight(x: i32, y: i32, height: i32): void {
  if (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
    unchecked(heightMapData[y * mapWidth + x] = height);
  }
}

/**
 * Set place flag at a specific tile
 */
export function setPlaceFlag(x: i32, y: i32, flag: i32): void {
  if (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
    unchecked(placeMapData[y * mapWidth + x] = flag);
  }
}

/**
 * Get height at a specific tile
 */
export function getHeight(x: i32, y: i32): i32 {
  if (x < 0 || x >= mapWidth || y < 0 || y >= mapHeight) {
    return 0;
  }
  return unchecked(heightMapData[y * mapWidth + x]);
}

/**
 * Get place flag at a specific tile
 */
export function getPlaceFlag(x: i32, y: i32): i32 {
  if (x < 0 || x >= mapWidth || y < 0 || y >= mapHeight) {
    return BLOCKED;
  }
  return unchecked(placeMapData[y * mapWidth + x]);
}

/**
 * Check if a tile is walkable
 */
export function isWalkable(x: i32, y: i32): bool {
  const height = getHeight(x, y);
  const place = getPlaceFlag(x, y);
  return height < DOOR && place < DOOR;
}

/**
 * Check if a tile can have objects placed on it
 */
export function canPlace(x: i32, y: i32): bool {
  return getPlaceFlag(x, y) < DOOR;
}

/**
 * Check if a tile is empty (no furniture)
 */
export function isEmpty(x: i32, y: i32): bool {
  return getPlaceFlag(x, y) < DOOR;
}

/**
 * Convert world coordinates to screen coordinates
 */
export function getScreenCoordinate(
  locX: f64,
  locY: f64,
  height: f64
): StaticArray<i32> {
  const result = new StaticArray<i32>(3);

  const screenX = ((locX - locY) * (xFactor * 0.5)) + xOffset;
  const screenY = ((locY + locX) * (yFactor * 0.5)) + yOffset - (height * hFactor);
  const screenZ = (1000.0 * (locX + locY + 1.0)) + zOffset;

  unchecked(result[0] = i32(screenX));
  unchecked(result[1] = i32(screenY));
  unchecked(result[2] = i32(screenZ));

  return result;
}

/**
 * Convert screen coordinates to world coordinates
 */
export function getWorldCoordinate(screenX: f64, screenY: f64): StaticArray<i32> {
  const result = new StaticArray<i32>(3);

  const adjX = screenX - yFactor - xOffset;
  const adjY = screenY - yOffset;

  let tileX = i32((adjX / xFactor) + (adjY / yFactor));
  let tileY = i32((adjY / yFactor) - (adjX / xFactor));
  let height: i32 = -1;

  // Check height at this position
  if (tileY >= 0 && tileY < mapHeight && tileX >= 0 && tileX < mapWidth) {
    height = getHeight(tileX, tileY);
  }

  if (height >= 0 && height < DOOR) {
    unchecked(result[0] = tileX);
    unchecked(result[1] = tileY);
    unchecked(result[2] = height);
    return result;
  }

  // Check elevated tiles
  for (let h: i32 = 1; h <= 9; h++) {
    const elevatedY = screenY + (f64(h) * hFactor);
    const tX = i32((adjX / xFactor) + (elevatedY / yFactor));
    const tY = i32((elevatedY / yFactor) - (adjX / xFactor));

    if (tY >= 0 && tY < mapHeight && tX >= 0 && tX < mapWidth) {
      const tHeight = getHeight(tX, tY);
      if (tHeight === h) {
        unchecked(result[0] = tX);
        unchecked(result[1] = tY);
        unchecked(result[2] = tHeight);
        return result;
      }
    }
  }

  // Not found
  unchecked(result[0] = -1);
  unchecked(result[1] = -1);
  unchecked(result[2] = -1);
  return result;
}

/**
 * Get coordinate height (matching original API)
 */
export function getCoordinateHeight(x: i32, y: i32): i32 {
  return getHeight(x, y);
}

/**
 * Get tile width
 */
export function getTileWidth(): f64 {
  return xFactor;
}

/**
 * Get tile height
 */
export function getTileHeight(): f64 {
  return yFactor;
}

/**
 * Get map dimensions
 */
export function getMapWidth(): i32 {
  return mapWidth;
}

export function getMapHeight(): i32 {
  return mapHeight;
}

/**
 * Parse height map character to height value
 *
 * Characters: 0-9 = heights, x = blocked, y = door, A-H = elevated platforms
 */
export function parseHeightChar(charCode: i32): i32 {
  // 'x' = blocked
  if (charCode === 120) return BLOCKED;
  // 'y' = door
  if (charCode === 121) return 0;
  // '0'-'9' = height
  if (charCode >= 48 && charCode <= 57) return charCode - 48;
  // 'A'-'H' = elevated
  if (charCode >= 65 && charCode < 73) return charCode - 65;
  return 0;
}

/**
 * Parse place map character to flag value
 */
export function parsePlaceChar(charCode: i32): i32 {
  // 'x' = blocked
  if (charCode === 120) return BLOCKED;
  // 'y' = door (walkable but can't place)
  if (charCode === 121) return DOOR;
  // 'A'-'H' = elevated (can't place)
  if (charCode >= 65 && charCode < 73) return DOOR;
  return 0;
}
