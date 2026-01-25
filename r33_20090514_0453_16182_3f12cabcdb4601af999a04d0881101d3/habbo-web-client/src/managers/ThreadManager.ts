/**
 * ThreadManager - Module lifecycle management
 *
 * Ported from: fuse_client/Cast External ParentScript 29 - Thread Manager Class.ls
 *
 * In Habbo, each module (hh_entry, hh_room, etc.) is a "thread" containing:
 * - Interface: UI/visual presentation layer
 * - Component: Business logic and state management
 * - Handler: Server message parsing and protocol handling
 *
 * The original loads thread configurations from "index" fields in cast libraries.
 */

import { ObjectId, IManagedObject, IThread, ThreadConfig, ObjectClass } from '../types';
import {
  objectManager,
  createObject,
  removeObject,
} from '../core/ObjectManager';
import { VariableContainer } from '../core/VariableContainer';

export class ThreadManager {
  private threads: Map<ObjectId, IThread> = new Map();
  private varManager: VariableContainer = new VariableContainer();

  // Registry of module configurations
  private moduleConfigs: Map<string, ThreadConfig> = new Map();

  // Registry of class constructors
  private classRegistry: Map<string, ObjectClass> = new Map();

  /**
   * Register a class for instantiation
   */
  registerClass(className: string, ctor: ObjectClass): void {
    this.classRegistry.set(className, ctor);
  }

  /**
   * Register multiple classes
   */
  registerClasses(classes: Record<string, ObjectClass>): void {
    for (const [name, ctor] of Object.entries(classes)) {
      this.classRegistry.set(name, ctor);
    }
  }

  /**
   * Register a module configuration
   */
  registerModule(config: ThreadConfig): void {
    this.moduleConfigs.set(config['thread.id'], config);
  }

  /**
   * Initialize a thread by ID
   *
   * Lingo: getThreadManager().create(#room, "room.index")
   *        getThreadManager().initThread(tCastNum)
   */
  create(threadId: ObjectId, initField?: string): boolean {
    if (this.threads.has(threadId)) {
      console.warn(`ThreadManager: Thread already exists: ${threadId}`);
      return false;
    }

    const config = this.moduleConfigs.get(threadId);
    if (!config) {
      console.error(`ThreadManager: Module config not found: ${threadId}`);
      return false;
    }

    const thread: IThread = {
      id: threadId,
      interface: null,
      component: null,
      handler: null,
    };

    // Build each module part (Interface, Component, Handler)
    for (const moduleType of ['interface', 'component', 'handler'] as const) {
      const classKey = `${moduleType}.class` as keyof ThreadConfig;
      const classNames = config[classKey];

      if (classNames) {
        const objectId = `${threadId}_${moduleType}`;
        const classList = Array.isArray(classNames) ? classNames : [classNames];

        const obj = this.buildThreadObject(objectId, classList, thread);
        if (obj) {
          thread[moduleType] = obj;
        }
      }
    }

    this.threads.set(threadId, thread);
    return true;
  }

  /**
   * Alias for create (matching original API)
   */
  initThread(threadIdOrCast: ObjectId | number, threadId?: ObjectId): boolean {
    if (typeof threadIdOrCast === 'string') {
      return this.create(threadIdOrCast);
    }
    // Cast number style - would need to look up config
    if (threadId) {
      return this.create(threadId);
    }
    return false;
  }

  /**
   * Get a thread by ID
   *
   * Lingo: getThread(#room)
   */
  get(threadId: ObjectId): IThread | null {
    return this.threads.get(threadId) ?? null;
  }

  /**
   * Alias for get (matching original API)
   */
  GET(threadId: ObjectId): IThread | null {
    return this.get(threadId);
  }

  /**
   * Check if thread exists
   *
   * Lingo: threadExists(#room)
   */
  exists(threadId: ObjectId): boolean {
    return this.threads.has(threadId);
  }

  /**
   * Close/remove a thread
   *
   * Lingo: getThreadManager().Remove(#room)
   *        getThreadManager().closeThread(#room)
   */
  remove(threadId: ObjectId): boolean {
    const thread = this.threads.get(threadId);
    if (!thread) {
      return false;
    }

    // Remove all parts
    if (thread.interface) {
      removeObject((thread.interface as IManagedObject & { id: ObjectId }).id);
    }
    if (thread.component) {
      removeObject((thread.component as IManagedObject & { id: ObjectId }).id);
    }
    if (thread.handler) {
      removeObject((thread.handler as IManagedObject & { id: ObjectId }).id);
    }

    this.threads.delete(threadId);
    return true;
  }

  /**
   * Alias for remove
   */
  closeThread(threadId: ObjectId): boolean {
    return this.remove(threadId);
  }

  /**
   * Close all threads
   */
  closeAll(): void {
    for (const threadId of [...this.threads.keys()]) {
      this.remove(threadId);
    }
  }

  /**
   * Build a thread object with class hierarchy
   */
  private buildThreadObject(
    objectId: ObjectId,
    classNames: string[],
    thread: IThread
  ): IManagedObject | null {
    // Get the primary class (last in the list, as original does)
    const primaryClassName = classNames[classNames.length - 1];
    const ClassCtor = this.classRegistry.get(primaryClassName);

    if (!ClassCtor) {
      console.error(`ThreadManager: Class not found: ${primaryClassName}`);
      return null;
    }

    const obj = createObject(objectId, ClassCtor);
    if (!obj) {
      return null;
    }

    // Inject thread reference for getThread(), getInterface(), etc.
    (obj as Record<string, unknown>)._thread = thread;

    return obj;
  }

  /**
   * Debug: print all threads
   */
  print(): void {
    console.log('=== ThreadManager ===');
    for (const [id, thread] of this.threads) {
      console.log(`  ${id}:`);
      console.log(`    interface: ${thread.interface ? 'yes' : 'no'}`);
      console.log(`    component: ${thread.component ? 'yes' : 'no'}`);
      console.log(`    handler: ${thread.handler ? 'yes' : 'no'}`);
    }
  }
}

// Global singleton
export const threadManager = new ThreadManager();

// Convenience functions matching Lingo API
export function getThread(threadId: ObjectId): IThread | null {
  return threadManager.get(threadId);
}

export function threadExists(threadId: ObjectId): boolean {
  return threadManager.exists(threadId);
}

export function getThreadManager(): ThreadManager {
  return threadManager;
}
