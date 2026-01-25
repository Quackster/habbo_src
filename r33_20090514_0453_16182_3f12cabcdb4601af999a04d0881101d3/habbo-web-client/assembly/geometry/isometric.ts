/**
 * Isometric Coordinate Conversions
 *
 * Habbo uses a standard isometric projection:
 * - Tiles are typically 64x32 pixels (2:1 ratio)
 * - X axis goes right-down, Y axis goes left-down
 * - Height (H) goes straight up
 */

// Default tile dimensions
export const DEFAULT_TILE_WIDTH: f64 = 64.0;
export const DEFAULT_TILE_HEIGHT: f64 = 32.0;
export const DEFAULT_HEIGHT_FACTOR: f64 = 32.0;

/**
 * Convert world coordinates to screen coordinates
 *
 * @param worldX - Tile X position
 * @param worldY - Tile Y position
 * @param worldH - Height (elevation)
 * @param factorX - Tile width factor
 * @param factorY - Tile height factor
 * @param factorH - Height factor
 * @param offsetX - Screen X offset
 * @param offsetY - Screen Y offset
 * @returns Packed result [screenX, screenY, zOrder]
 */
export function worldToScreen(
  worldX: f64,
  worldY: f64,
  worldH: f64,
  factorX: f64,
  factorY: f64,
  factorH: f64,
  offsetX: f64,
  offsetY: f64
): StaticArray<i32> {
  const result = new StaticArray<i32>(3);

  // Isometric projection formulas from Room Geometry Class
  const screenX = ((worldX - worldY) * (factorX * 0.5)) + offsetX;
  const screenY = ((worldY + worldX) * (factorY * 0.5)) + offsetY - (worldH * factorH);
  const zOrder = 1000.0 * (worldX + worldY + 1.0);

  unchecked(result[0] = i32(screenX));
  unchecked(result[1] = i32(screenY));
  unchecked(result[2] = i32(zOrder));

  return result;
}

/**
 * Convert screen coordinates to world floor coordinates (height = 0)
 *
 * @param screenX - Screen X position
 * @param screenY - Screen Y position
 * @param factorX - Tile width factor
 * @param factorY - Tile height factor
 * @param offsetX - Screen X offset
 * @param offsetY - Screen Y offset
 * @returns [tileX, tileY] or [-1, -1] if invalid
 */
export function screenToWorld(
  screenX: f64,
  screenY: f64,
  factorX: f64,
  factorY: f64,
  offsetX: f64,
  offsetY: f64
): StaticArray<i32> {
  const result = new StaticArray<i32>(2);

  // Reverse the isometric projection
  const adjX = screenX - factorY - offsetX;
  const adjY = screenY - offsetY;

  const tileX = (adjX / factorX) + (adjY / factorY);
  const tileY = (adjY / factorY) - (adjX / factorX);

  unchecked(result[0] = i32(Math.floor(tileX)));
  unchecked(result[1] = i32(Math.floor(tileY)));

  return result;
}

/**
 * Calculate Z-order value for sprite sorting
 *
 * Higher values are drawn later (in front)
 */
export function calculateZOrder(
  worldX: f64,
  worldY: f64,
  worldH: f64,
  baseZ: f64
): i32 {
  const tileSum = worldX + worldY;
  return i32(baseZ + (tileSum * 1000.0) + (worldH * 100.0));
}

/**
 * Get the 8-direction index from movement delta
 *
 * Directions in Habbo:
 * 0 = South (down-right)
 * 1 = South-West
 * 2 = West (down-left)
 * 3 = North-West
 * 4 = North (up-left)
 * 5 = North-East
 * 6 = East (up-right)
 * 7 = South-East
 */
export function getDirection(dx: i32, dy: i32): i32 {
  if (dx === 0 && dy === 0) return 0;

  if (dx > 0) {
    if (dy > 0) return 0;      // South
    if (dy < 0) return 6;      // East
    return 7;                   // South-East
  } else if (dx < 0) {
    if (dy > 0) return 2;      // West
    if (dy < 0) return 4;      // North
    return 3;                   // North-West
  } else {
    if (dy > 0) return 1;      // South-West
    return 5;                   // North-East
  }
}

/**
 * Check if a point is inside a diamond-shaped tile
 *
 * @param localX - X relative to tile top-left
 * @param localY - Y relative to tile top-left
 * @param tileWidth - Tile width
 * @param tileHeight - Tile height
 */
export function isInsideTile(
  localX: i32,
  localY: i32,
  tileWidth: i32,
  tileHeight: i32
): bool {
  const halfW = tileWidth / 2;
  const halfH = tileHeight / 2;

  const dx = Math.abs(f64(localX - halfW)) / f64(halfW);
  const dy = Math.abs(f64(localY - halfH)) / f64(halfH);

  return (dx + dy) <= 1.0;
}

/**
 * Calculate distance between two tiles (Manhattan-ish for isometric)
 */
export function tileDistance(x1: i32, y1: i32, x2: i32, y2: i32): i32 {
  return abs(x1 - x2) + abs(y1 - y2);
}
