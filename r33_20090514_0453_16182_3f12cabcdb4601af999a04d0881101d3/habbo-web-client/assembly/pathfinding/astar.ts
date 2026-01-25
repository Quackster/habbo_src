/**
 * A* Pathfinding for Habbo Rooms
 *
 * Finds optimal paths on the isometric tile grid.
 */

import { isWalkable, getMapWidth, getMapHeight } from '../geometry/roomGeometry';

// Maximum path length
const MAX_PATH_LENGTH: i32 = 100;

// Direction vectors (8-way movement)
const DX: StaticArray<i32> = StaticArray.fromArray<i32>([1, 0, -1, 0, 1, -1, -1, 1]);
const DY: StaticArray<i32> = StaticArray.fromArray<i32>([0, 1, 0, -1, 1, 1, -1, -1]);

// Node storage for A*
class PathNode {
  x: i32;
  y: i32;
  g: i32; // Cost from start
  h: i32; // Heuristic to goal
  f: i32; // g + h
  parentX: i32;
  parentY: i32;

  constructor(x: i32, y: i32) {
    this.x = x;
    this.y = y;
    this.g = 0;
    this.h = 0;
    this.f = 0;
    this.parentX = -1;
    this.parentY = -1;
  }
}

// Open and closed sets
let openList: PathNode[] = [];
let closedSet: Map<i32, bool> = new Map<i32, bool>();
let nodeMap: Map<i32, PathNode> = new Map<i32, PathNode>();

/**
 * Create position key for maps
 */
function posKey(x: i32, y: i32): i32 {
  return y * 1000 + x;
}

/**
 * Manhattan distance heuristic
 */
function heuristic(x1: i32, y1: i32, x2: i32, y2: i32): i32 {
  return abs(x1 - x2) + abs(y1 - y2);
}

/**
 * Find path using A* algorithm
 *
 * @returns Flat array [x1, y1, x2, y2, ...] of path points, empty if no path
 */
export function findPath(
  startX: i32,
  startY: i32,
  goalX: i32,
  goalY: i32
): StaticArray<i32> {
  // Reset state
  openList = [];
  closedSet = new Map<i32, bool>();
  nodeMap = new Map<i32, PathNode>();

  const mapWidth = getMapWidth();
  const mapHeight = getMapHeight();

  // Check if goal is reachable
  if (!isWalkable(goalX, goalY)) {
    return new StaticArray<i32>(0);
  }

  // Already at goal
  if (startX === goalX && startY === goalY) {
    return new StaticArray<i32>(0);
  }

  // Create start node
  const startNode = new PathNode(startX, startY);
  startNode.h = heuristic(startX, startY, goalX, goalY);
  startNode.f = startNode.h;

  openList.push(startNode);
  nodeMap.set(posKey(startX, startY), startNode);

  while (openList.length > 0) {
    // Find node with lowest f score
    let bestIdx: i32 = 0;
    let bestF: i32 = openList[0].f;

    for (let i: i32 = 1; i < openList.length; i++) {
      if (openList[i].f < bestF) {
        bestF = openList[i].f;
        bestIdx = i;
      }
    }

    const current = openList[bestIdx];

    // Remove from open list
    openList.splice(bestIdx, 1);

    // Add to closed set
    const currentKey = posKey(current.x, current.y);
    closedSet.set(currentKey, true);

    // Check if reached goal
    if (current.x === goalX && current.y === goalY) {
      return reconstructPath(current, startX, startY);
    }

    // Explore neighbors
    for (let dir: i32 = 0; dir < 8; dir++) {
      const nx = current.x + unchecked(DX[dir]);
      const ny = current.y + unchecked(DY[dir]);

      // Check bounds
      if (nx < 0 || nx >= mapWidth || ny < 0 || ny >= mapHeight) {
        continue;
      }

      const neighborKey = posKey(nx, ny);

      // Skip if blocked or in closed set
      if (!isWalkable(nx, ny) || closedSet.has(neighborKey)) {
        continue;
      }

      // For diagonal movement, check adjacent tiles
      if (dir >= 4) {
        const ax = current.x + unchecked(DX[dir - 4]);
        const ay = current.y + unchecked(DY[dir - 4]);
        if (!isWalkable(ax, current.y) || !isWalkable(current.x, ay)) {
          continue; // Can't cut corners
        }
      }

      // Cost: 10 for cardinal, 14 for diagonal
      const moveCost: i32 = dir < 4 ? 10 : 14;
      const tentativeG = current.g + moveCost;

      let neighbor: PathNode;

      if (nodeMap.has(neighborKey)) {
        neighbor = nodeMap.get(neighborKey);

        // Skip if we already found a better path
        if (tentativeG >= neighbor.g) {
          continue;
        }
      } else {
        neighbor = new PathNode(nx, ny);
        nodeMap.set(neighborKey, neighbor);
        openList.push(neighbor);
      }

      // Update neighbor
      neighbor.parentX = current.x;
      neighbor.parentY = current.y;
      neighbor.g = tentativeG;
      neighbor.h = heuristic(nx, ny, goalX, goalY);
      neighbor.f = neighbor.g + neighbor.h;
    }

    // Safety check
    if (closedSet.size > MAX_PATH_LENGTH * 10) {
      return new StaticArray<i32>(0);
    }
  }

  // No path found
  return new StaticArray<i32>(0);
}

/**
 * Reconstruct path from goal to start
 */
function reconstructPath(goalNode: PathNode, startX: i32, startY: i32): StaticArray<i32> {
  const pathPoints: i32[] = [];

  let current: PathNode | null = goalNode;

  while (current !== null) {
    pathPoints.push(current.x);
    pathPoints.push(current.y);

    if (current.x === startX && current.y === startY) {
      break;
    }

    if (current.parentX < 0) {
      break;
    }

    const parentKey = posKey(current.parentX, current.parentY);
    current = nodeMap.has(parentKey) ? nodeMap.get(parentKey) : null;

    // Safety check
    if (pathPoints.length > MAX_PATH_LENGTH * 2) {
      break;
    }
  }

  // Reverse path (goal->start to start->goal)
  const result = new StaticArray<i32>(pathPoints.length);
  for (let i: i32 = 0; i < pathPoints.length; i += 2) {
    const revIdx = pathPoints.length - 2 - i;
    unchecked(result[i] = pathPoints[revIdx]);
    unchecked(result[i + 1] = pathPoints[revIdx + 1]);
  }

  return result;
}

/**
 * Check if a direct path exists (no obstacles)
 */
export function hasDirectPath(
  x1: i32,
  y1: i32,
  x2: i32,
  y2: i32
): bool {
  const dx = abs(x2 - x1);
  const dy = abs(y2 - y1);
  const sx: i32 = x1 < x2 ? 1 : -1;
  const sy: i32 = y1 < y2 ? 1 : -1;

  let err = dx - dy;
  let x = x1;
  let y = y1;

  while (x !== x2 || y !== y2) {
    if (!isWalkable(x, y)) {
      return false;
    }

    const e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x += sx;
    }
    if (e2 < dx) {
      err += dx;
      y += sy;
    }
  }

  return isWalkable(x2, y2);
}

/**
 * Get next step towards a goal (simple greedy)
 */
export function getNextStep(
  currentX: i32,
  currentY: i32,
  goalX: i32,
  goalY: i32
): StaticArray<i32> {
  const result = new StaticArray<i32>(2);

  let bestX = currentX;
  let bestY = currentY;
  let bestDist = heuristic(currentX, currentY, goalX, goalY);

  // Check all 8 neighbors
  for (let dir: i32 = 0; dir < 8; dir++) {
    const nx = currentX + unchecked(DX[dir]);
    const ny = currentY + unchecked(DY[dir]);

    if (isWalkable(nx, ny)) {
      const dist = heuristic(nx, ny, goalX, goalY);
      if (dist < bestDist) {
        bestDist = dist;
        bestX = nx;
        bestY = ny;
      }
    }
  }

  unchecked(result[0] = bestX);
  unchecked(result[1] = bestY);
  return result;
}
