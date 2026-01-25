/**
 * AssemblyScript WASM Entry Point
 *
 * Exports performance-critical functions for:
 * - Isometric geometry calculations
 * - A* pathfinding
 * - Animation state management
 */

export * from './geometry/isometric';
export * from './geometry/roomGeometry';
export * from './pathfinding/astar';

// Memory management helpers
export function allocateMemory(size: i32): usize {
  return heap.alloc(size);
}

export function freeMemory(ptr: usize): void {
  heap.free(ptr);
}
