/**
 * WASM Loader - Handles loading and instantiation of AssemblyScript modules
 *
 * Loads the compiled WASM modules for performance-critical operations.
 */

// WASM module interfaces
export interface GeometryModule {
  // Isometric conversions
  worldToScreenX(worldX: number, worldY: number, height: number): number;
  worldToScreenY(worldX: number, worldY: number, height: number): number;
  worldToScreenZ(worldX: number, worldY: number): number;
  screenToWorldX(screenX: number, screenY: number): number;
  screenToWorldY(screenX: number, screenY: number): number;
  setOffsets(x: number, y: number, z: number): void;
  setFactors(xFac: number, yFac: number, hFac: number): void;

  // Room geometry
  defineGeometry(offX: number, offY: number, offZ: number, facX: number, facY: number, facH: number): void;
  initHeightMap(width: number, height: number): void;
  setHeight(x: number, y: number, height: number): void;
  setPlaceFlag(x: number, y: number, flag: number): void;
  getHeight(x: number, y: number): number;
  getPlaceFlag(x: number, y: number): number;
  isWalkable(x: number, y: number): boolean;
  canPlace(x: number, y: number): boolean;
  getScreenCoordinate(locX: number, locY: number, height: number): Int32Array;
  getWorldCoordinate(screenX: number, screenY: number): Int32Array;
  getMapWidth(): number;
  getMapHeight(): number;
  parseHeightChar(charCode: number): number;
  parsePlaceChar(charCode: number): number;
}

export interface PathfindingModule {
  findPath(startX: number, startY: number, goalX: number, goalY: number): Int32Array;
  hasDirectPath(x1: number, y1: number, x2: number, y2: number): boolean;
  getNextStep(currentX: number, currentY: number, goalX: number, goalY: number): Int32Array;
}

// Module instances
let geometryModule: GeometryModule | null = null;
let pathfindingModule: PathfindingModule | null = null;

// Loading state
let isLoading = false;
let loadPromise: Promise<void> | null = null;

/**
 * Load all WASM modules
 */
export async function loadWasmModules(): Promise<void> {
  if (loadPromise) {
    return loadPromise;
  }

  if (geometryModule && pathfindingModule) {
    return Promise.resolve();
  }

  isLoading = true;

  loadPromise = (async () => {
    try {
      // Load modules in parallel
      const [geometry, pathfinding] = await Promise.all([
        loadGeometryModule(),
        loadPathfindingModule(),
      ]);

      geometryModule = geometry;
      pathfindingModule = pathfinding;

      console.log('WASM modules loaded successfully');
    } catch (error) {
      console.error('Failed to load WASM modules:', error);
      throw error;
    } finally {
      isLoading = false;
    }
  })();

  return loadPromise;
}

/**
 * Load the geometry WASM module
 */
async function loadGeometryModule(): Promise<GeometryModule> {
  try {
    const response = await fetch('/wasm/geometry.wasm');
    const buffer = await response.arrayBuffer();

    const { instance } = await WebAssembly.instantiate(buffer, {
      env: {
        abort: (msg: number, file: number, line: number, col: number) => {
          console.error(`WASM abort at ${file}:${line}:${col}`);
        },
      },
    });

    return instance.exports as unknown as GeometryModule;
  } catch (error) {
    console.warn('WASM geometry module not available, using fallback');
    return createGeometryFallback();
  }
}

/**
 * Load the pathfinding WASM module
 */
async function loadPathfindingModule(): Promise<PathfindingModule> {
  try {
    const response = await fetch('/wasm/pathfinding.wasm');
    const buffer = await response.arrayBuffer();

    const { instance } = await WebAssembly.instantiate(buffer, {
      env: {
        abort: (msg: number, file: number, line: number, col: number) => {
          console.error(`WASM abort at ${file}:${line}:${col}`);
        },
      },
      geometry: {
        isWalkable: (x: number, y: number) => getGeometry()?.isWalkable(x, y) ?? false,
        getMapWidth: () => getGeometry()?.getMapWidth() ?? 0,
        getMapHeight: () => getGeometry()?.getMapHeight() ?? 0,
      },
    });

    return instance.exports as unknown as PathfindingModule;
  } catch (error) {
    console.warn('WASM pathfinding module not available, using fallback');
    return createPathfindingFallback();
  }
}

/**
 * Get the geometry module
 */
export function getGeometry(): GeometryModule | null {
  return geometryModule;
}

/**
 * Get the pathfinding module
 */
export function getPathfinding(): PathfindingModule | null {
  return pathfindingModule;
}

/**
 * Check if modules are loaded
 */
export function isLoaded(): boolean {
  return geometryModule !== null && pathfindingModule !== null;
}

/**
 * Create JavaScript fallback for geometry (when WASM unavailable)
 */
function createGeometryFallback(): GeometryModule {
  let xOffset = 0, yOffset = 0, zOffset = 0;
  let xFactor = 64, yFactor = 32, hFactor = 32;
  let heightMap: number[] = [];
  let placeMap: number[] = [];
  let mapWidth = 0, mapHeight = 0;

  const BLOCKED = 200000;
  const DOOR = 100000;

  return {
    worldToScreenX: (wx, wy, h) => ((wx - wy) * (xFactor * 0.5)) + xOffset,
    worldToScreenY: (wx, wy, h) => ((wy + wx) * (yFactor * 0.5)) + yOffset - (h * hFactor),
    worldToScreenZ: (wx, wy) => (1000 * (wx + wy + 1)) + zOffset,
    screenToWorldX: (sx, sy) => {
      const adjX = sx - yFactor - xOffset;
      const adjY = sy - yOffset;
      return Math.floor((adjX / xFactor) + (adjY / yFactor));
    },
    screenToWorldY: (sx, sy) => {
      const adjX = sx - yFactor - xOffset;
      const adjY = sy - yOffset;
      return Math.floor((adjY / yFactor) - (adjX / xFactor));
    },
    setOffsets: (x, y, z) => { xOffset = x; yOffset = y; zOffset = z; },
    setFactors: (xF, yF, hF) => { xFactor = xF; yFactor = yF; hFactor = hF; },
    defineGeometry: (ox, oy, oz, fx, fy, fh) => {
      xOffset = ox; yOffset = oy; zOffset = oz;
      xFactor = fx; yFactor = fy; hFactor = fh;
    },
    initHeightMap: (w, h) => {
      mapWidth = w; mapHeight = h;
      heightMap = new Array(w * h).fill(0);
      placeMap = new Array(w * h).fill(0);
    },
    setHeight: (x, y, h) => {
      if (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
        heightMap[y * mapWidth + x] = h;
      }
    },
    setPlaceFlag: (x, y, f) => {
      if (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
        placeMap[y * mapWidth + x] = f;
      }
    },
    getHeight: (x, y) => {
      if (x < 0 || x >= mapWidth || y < 0 || y >= mapHeight) return 0;
      return heightMap[y * mapWidth + x];
    },
    getPlaceFlag: (x, y) => {
      if (x < 0 || x >= mapWidth || y < 0 || y >= mapHeight) return BLOCKED;
      return placeMap[y * mapWidth + x];
    },
    isWalkable: (x, y) => {
      const h = heightMap[y * mapWidth + x] ?? BLOCKED;
      const p = placeMap[y * mapWidth + x] ?? BLOCKED;
      return h < DOOR && p < DOOR;
    },
    canPlace: (x, y) => (placeMap[y * mapWidth + x] ?? BLOCKED) < DOOR,
    getScreenCoordinate: (lx, ly, h) => new Int32Array([
      Math.floor(((lx - ly) * (xFactor * 0.5)) + xOffset),
      Math.floor(((ly + lx) * (yFactor * 0.5)) + yOffset - (h * hFactor)),
      Math.floor((1000 * (lx + ly + 1)) + zOffset)
    ]),
    getWorldCoordinate: (sx, sy) => {
      const adjX = sx - yFactor - xOffset;
      const adjY = sy - yOffset;
      const tx = Math.floor((adjX / xFactor) + (adjY / yFactor));
      const ty = Math.floor((adjY / yFactor) - (adjX / xFactor));
      if (tx >= 0 && tx < mapWidth && ty >= 0 && ty < mapHeight) {
        return new Int32Array([tx, ty, heightMap[ty * mapWidth + tx]]);
      }
      return new Int32Array([-1, -1, -1]);
    },
    getMapWidth: () => mapWidth,
    getMapHeight: () => mapHeight,
    parseHeightChar: (c) => {
      if (c === 120) return BLOCKED;
      if (c === 121) return 0;
      if (c >= 48 && c <= 57) return c - 48;
      if (c >= 65 && c < 73) return c - 65;
      return 0;
    },
    parsePlaceChar: (c) => {
      if (c === 120) return BLOCKED;
      if (c === 121) return DOOR;
      if (c >= 65 && c < 73) return DOOR;
      return 0;
    },
  };
}

/**
 * Create JavaScript fallback for pathfinding (when WASM unavailable)
 */
function createPathfindingFallback(): PathfindingModule {
  const DX = [1, 0, -1, 0, 1, -1, -1, 1];
  const DY = [0, 1, 0, -1, 1, 1, -1, -1];

  function heuristic(x1: number, y1: number, x2: number, y2: number): number {
    return Math.abs(x1 - x2) + Math.abs(y1 - y2);
  }

  return {
    findPath: (startX, startY, goalX, goalY) => {
      const geom = getGeometry();
      if (!geom || !geom.isWalkable(goalX, goalY)) {
        return new Int32Array(0);
      }
      if (startX === goalX && startY === goalY) {
        return new Int32Array(0);
      }

      const mapWidth = geom.getMapWidth();
      const mapHeight = geom.getMapHeight();
      const openList: { x: number; y: number; g: number; f: number; px: number; py: number }[] = [];
      const closedSet = new Set<number>();
      const nodeMap = new Map<number, typeof openList[0]>();

      const posKey = (x: number, y: number) => y * 1000 + x;

      const startNode = { x: startX, y: startY, g: 0, f: heuristic(startX, startY, goalX, goalY), px: -1, py: -1 };
      openList.push(startNode);
      nodeMap.set(posKey(startX, startY), startNode);

      while (openList.length > 0) {
        openList.sort((a, b) => a.f - b.f);
        const current = openList.shift()!;
        const currentKey = posKey(current.x, current.y);
        closedSet.add(currentKey);

        if (current.x === goalX && current.y === goalY) {
          // Reconstruct path
          const path: number[] = [];
          let node: typeof current | undefined = current;
          while (node) {
            path.push(node.x, node.y);
            if (node.px < 0) break;
            node = nodeMap.get(posKey(node.px, node.py));
          }
          path.reverse();
          // The path is now [x0, y0, x1, y1, ...] but reversed pairs
          const result = new Int32Array(path.length);
          for (let i = 0; i < path.length; i += 2) {
            result[path.length - 2 - i] = path[i];
            result[path.length - 1 - i] = path[i + 1];
          }
          return result;
        }

        for (let dir = 0; dir < 8; dir++) {
          const nx = current.x + DX[dir];
          const ny = current.y + DY[dir];

          if (nx < 0 || nx >= mapWidth || ny < 0 || ny >= mapHeight) continue;

          const neighborKey = posKey(nx, ny);
          if (!geom.isWalkable(nx, ny) || closedSet.has(neighborKey)) continue;

          const moveCost = dir < 4 ? 10 : 14;
          const tentativeG = current.g + moveCost;

          let neighbor = nodeMap.get(neighborKey);
          if (neighbor) {
            if (tentativeG >= neighbor.g) continue;
          } else {
            neighbor = { x: nx, y: ny, g: 0, f: 0, px: -1, py: -1 };
            nodeMap.set(neighborKey, neighbor);
            openList.push(neighbor);
          }

          neighbor.px = current.x;
          neighbor.py = current.y;
          neighbor.g = tentativeG;
          neighbor.f = tentativeG + heuristic(nx, ny, goalX, goalY);
        }

        if (closedSet.size > 1000) break;
      }

      return new Int32Array(0);
    },

    hasDirectPath: (x1, y1, x2, y2) => {
      const geom = getGeometry();
      if (!geom) return false;

      const dx = Math.abs(x2 - x1);
      const dy = Math.abs(y2 - y1);
      const sx = x1 < x2 ? 1 : -1;
      const sy = y1 < y2 ? 1 : -1;

      let err = dx - dy;
      let x = x1, y = y1;

      while (x !== x2 || y !== y2) {
        if (!geom.isWalkable(x, y)) return false;
        const e2 = 2 * err;
        if (e2 > -dy) { err -= dy; x += sx; }
        if (e2 < dx) { err += dx; y += sy; }
      }

      return geom.isWalkable(x2, y2);
    },

    getNextStep: (currentX, currentY, goalX, goalY) => {
      const geom = getGeometry();
      if (!geom) return new Int32Array([currentX, currentY]);

      let bestX = currentX, bestY = currentY;
      let bestDist = heuristic(currentX, currentY, goalX, goalY);

      for (let dir = 0; dir < 8; dir++) {
        const nx = currentX + DX[dir];
        const ny = currentY + DY[dir];
        if (geom.isWalkable(nx, ny)) {
          const dist = heuristic(nx, ny, goalX, goalY);
          if (dist < bestDist) {
            bestDist = dist;
            bestX = nx;
            bestY = ny;
          }
        }
      }

      return new Int32Array([bestX, bestY]);
    },
  };
}
