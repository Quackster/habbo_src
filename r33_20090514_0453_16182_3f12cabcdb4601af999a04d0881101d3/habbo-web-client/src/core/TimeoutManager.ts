/**
 * TimeoutManager - Delayed execution system
 *
 * Lingo equivalents:
 *   createTimeout(id, ms, #handler, objectId, arg, once)
 *   removeTimeout(id)
 *   timeoutExists(id)
 *
 * Also handles object-level delays from BaseObject:
 *   me.delay(1000, #myMethod, [args])
 *   me.Cancel(delayId)
 */

import { ObjectId, TimeoutEntry } from '../types';

export class TimeoutManager {
  private timeouts: Map<ObjectId, TimeoutEntry> = new Map();
  private timerId: number = 0;

  /**
   * Create a timeout
   *
   * Lingo: createTimeout(#myTimeout, 1000, #myHandler, me.getID(), tArg, 1)
   */
  create(
    id: ObjectId,
    delayMs: number,
    callback: () => void,
    repeat: boolean = false
  ): boolean {
    if (this.timeouts.has(id)) {
      console.warn(`TimeoutManager: Timeout already exists: ${id}`);
      return false;
    }

    const entry: TimeoutEntry = {
      id,
      callback,
      targetTime: performance.now() + delayMs,
      repeat,
      interval: delayMs,
    };

    this.timeouts.set(id, entry);
    return true;
  }

  /**
   * Remove a timeout
   *
   * Lingo: removeTimeout(#myTimeout)
   */
  remove(id: ObjectId): boolean {
    return this.timeouts.delete(id);
  }

  /**
   * Check if timeout exists
   *
   * Lingo: timeoutExists(#myTimeout)
   */
  exists(id: ObjectId): boolean {
    return this.timeouts.has(id);
  }

  /**
   * Get a timeout entry
   */
  get(id: ObjectId): TimeoutEntry | undefined {
    return this.timeouts.get(id);
  }

  /**
   * Process timeouts - called each frame by MainLoop
   */
  update(): void {
    const now = performance.now();
    const toRemove: ObjectId[] = [];

    for (const [id, entry] of this.timeouts) {
      if (now >= entry.targetTime) {
        try {
          entry.callback();
        } catch (error) {
          console.error(`TimeoutManager: Error in timeout ${id}:`, error);
        }

        if (entry.repeat) {
          entry.targetTime = now + entry.interval;
        } else {
          toRemove.push(id);
        }
      }
    }

    for (const id of toRemove) {
      this.timeouts.delete(id);
    }
  }

  /**
   * Generate unique timeout ID
   */
  generateId(prefix: string = 'timeout'): ObjectId {
    return `${prefix}_${Date.now()}_${this.timerId++}`;
  }

  /**
   * Clear all timeouts
   */
  clear(): void {
    this.timeouts.clear();
  }

  /**
   * Get count of active timeouts
   */
  getCount(): number {
    return this.timeouts.size;
  }

  /**
   * Debug: print all timeouts
   */
  print(): void {
    console.log('=== TimeoutManager ===');
    const now = performance.now();
    for (const [id, entry] of this.timeouts) {
      const remaining = Math.max(0, entry.targetTime - now);
      console.log(`  ${id}: ${remaining.toFixed(0)}ms remaining, repeat=${entry.repeat}`);
    }
  }
}

// Global singleton
export const timeoutManager = new TimeoutManager();

// Convenience functions matching Lingo API
export function createTimeout(
  id: ObjectId,
  delayMs: number,
  callback: () => void,
  repeat: boolean = false
): boolean {
  return timeoutManager.create(id, delayMs, callback, repeat);
}

export function removeTimeout(id: ObjectId): boolean {
  return timeoutManager.remove(id);
}

export function timeoutExists(id: ObjectId): boolean {
  return timeoutManager.exists(id);
}
