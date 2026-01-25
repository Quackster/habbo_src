/**
 * ObjectManager - Central object lifecycle management
 *
 * Ported from: fuse_client/Cast External ParentScript 27 - Object Manager Class.ls
 *
 * This is the core object registry that manages:
 * - Object creation and destruction
 * - Update/prepare frame loops
 * - Manager registration (singleton services)
 *
 * Original Lingo patterns:
 *   createObject(#myObj, "My Class Name")
 *   getObject(#myObj)
 *   removeObject(#myObj)
 */

import { ObjectId, IManagedObject, ObjectClass } from '../types';

export class ObjectManager {
  private objects: Map<ObjectId, IManagedObject> = new Map();
  private updateList: Set<IManagedObject> = new Set();
  private prepareList: Set<IManagedObject> = new Set();
  private managers: Set<ObjectId> = new Set();
  private instances: Set<ObjectId> = new Set();
  private eraseLock: boolean = false;
  private updatePaused: boolean = false;

  private idCounter: number = 0;

  /**
   * Create a new managed object
   *
   * Lingo: createObject(#myObject, "My Class Name")
   *        createObject(#random, "My Class Name")  -- generates unique ID
   *        createObject(#temp, "My Class Name")    -- not registered
   */
  create<T extends IManagedObject>(
    id: ObjectId | 'random' | 'temp',
    ClassRef: ObjectClass<T>
  ): T | null {
    let actualId: ObjectId;
    const isTemp = id === 'temp';

    if (id === 'random') {
      actualId = this.generateUniqueId();
    } else if (isTemp) {
      actualId = `temp_${this.idCounter++}`;
    } else {
      actualId = id;
    }

    // Check for existing object (unless temp)
    if (!isTemp && this.objects.has(actualId)) {
      console.error(`ObjectManager: Object already exists: ${actualId}`);
      return null;
    }

    try {
      // Create instance
      const instance = new ClassRef() as T & { id: ObjectId };

      // Inject ID (matching Lingo's tBase.id = tID)
      (instance as { id: ObjectId }).id = actualId;

      // Register if not temp
      if (!isTemp) {
        this.objects.set(actualId, instance);
        this.instances.add(actualId);
      }

      // Call construct if defined
      if (instance.construct) {
        instance.construct();
      }

      return instance;
    } catch (error) {
      console.error(`ObjectManager: Failed to create object ${actualId}:`, error);
      if (!isTemp) {
        this.objects.delete(actualId);
      }
      return null;
    }
  }

  /**
   * Get an existing object by ID
   *
   * Lingo: getObject(#myObject)
   */
  get<T extends IManagedObject>(id: ObjectId): T | null {
    const obj = this.objects.get(id);
    return (obj as T) ?? null;
  }

  /**
   * Remove and destroy an object
   *
   * Lingo: removeObject(#myObject)
   */
  remove(id: ObjectId): boolean {
    const obj = this.objects.get(id);
    if (!obj) {
      return false;
    }

    // Remove from update/prepare lists
    this.updateList.delete(obj);
    this.prepareList.delete(obj);

    // Call deconstruct
    if (obj.deconstruct) {
      obj.deconstruct();
    }

    // Remove from registry (unless erase locked)
    if (!this.eraseLock) {
      this.objects.delete(id);
      this.instances.delete(id);
      this.managers.delete(id);
    }

    return true;
  }

  /**
   * Check if object exists
   *
   * Lingo: objectExists(#myObject)
   */
  exists(id: ObjectId): boolean {
    return this.objects.has(id);
  }

  /**
   * Register an object as a manager (singleton service)
   *
   * Lingo: registerManager(#myManager)
   */
  registerManager(id: ObjectId): boolean {
    if (!this.exists(id)) {
      console.error(`ObjectManager: Cannot register manager, object not found: ${id}`);
      return false;
    }
    if (this.managers.has(id)) {
      console.warn(`ObjectManager: Manager already registered: ${id}`);
      return false;
    }
    this.instances.delete(id);
    this.managers.add(id);
    return true;
  }

  /**
   * Unregister a manager
   */
  unregisterManager(id: ObjectId): boolean {
    if (!this.exists(id)) {
      return false;
    }
    if (!this.managers.has(id)) {
      return false;
    }
    this.managers.delete(id);
    this.instances.add(id);
    return true;
  }

  /**
   * Get a registered manager
   *
   * Lingo: getManager(#myManager)
   */
  getManager<T extends IManagedObject>(id: ObjectId): T | null {
    if (!this.managers.has(id)) {
      console.error(`ObjectManager: Manager not found: ${id}`);
      return null;
    }
    return this.get<T>(id);
  }

  /**
   * Check if manager exists
   *
   * Lingo: managerExists(#myManager)
   */
  managerExists(id: ObjectId): boolean {
    return this.managers.has(id);
  }

  /**
   * Register object to receive prepare() calls each frame
   *
   * Lingo: receivePrepare(objectID)
   */
  receivePrepare(id: ObjectId): boolean {
    const obj = this.objects.get(id);
    if (!obj) return false;
    this.prepareList.add(obj);
    return true;
  }

  /**
   * Unregister object from prepare() calls
   *
   * Lingo: removePrepare(objectID)
   */
  removePrepare(id: ObjectId): boolean {
    const obj = this.objects.get(id);
    if (!obj) return false;
    this.prepareList.delete(obj);
    return true;
  }

  /**
   * Register object to receive update() calls each frame
   *
   * Lingo: receiveUpdate(objectID)
   */
  receiveUpdate(id: ObjectId): boolean {
    const obj = this.objects.get(id);
    if (!obj) return false;
    this.updateList.add(obj);
    return true;
  }

  /**
   * Unregister object from update() calls
   *
   * Lingo: removeUpdate(objectID)
   */
  removeUpdate(id: ObjectId): boolean {
    const obj = this.objects.get(id);
    if (!obj) return false;
    this.updateList.delete(obj);
    return true;
  }

  /**
   * Frame tick - called by MainLoop
   *
   * Lingo: on prepareFrame me (in Object Manager)
   */
  prepareFrame(): void {
    if (this.updatePaused) return;

    // Call prepare on all registered objects
    for (const obj of this.prepareList) {
      if (obj.prepare) {
        try {
          obj.prepare();
        } catch (error) {
          console.error(`ObjectManager: Error in prepare() for ${obj.id}:`, error);
        }
      }
    }

    // Call update on all registered objects
    for (const obj of this.updateList) {
      if (obj.update) {
        try {
          obj.update();
        } catch (error) {
          console.error(`ObjectManager: Error in update() for ${obj.id}:`, error);
        }
      }
    }
  }

  /** Pause update loop */
  pauseUpdate(): void {
    this.updatePaused = true;
  }

  /** Resume update loop */
  resumeUpdate(): void {
    this.updatePaused = false;
  }

  /** Generate unique ID */
  private generateUniqueId(): ObjectId {
    return `obj_${Date.now()}_${this.idCounter++}`;
  }

  /** Destroy all objects (cleanup) */
  destroy(): void {
    this.eraseLock = true;

    // Destroy instances first, then managers
    for (const id of [...this.instances]) {
      this.remove(id);
    }
    for (const id of [...this.managers]) {
      this.remove(id);
    }

    this.objects.clear();
    this.updateList.clear();
    this.prepareList.clear();
    this.managers.clear();
    this.instances.clear();
    this.eraseLock = false;
  }

  /** Debug: print all objects */
  print(): void {
    console.log('=== ObjectManager Contents ===');
    for (const [id, obj] of this.objects) {
      const type = this.managers.has(id) ? 'MANAGER' : 'INSTANCE';
      console.log(`  ${id} [${type}]: ${obj.constructor.name}`);
    }
  }

  /** Register an existing object (for external objects) */
  registerObject(id: ObjectId, obj: IManagedObject): boolean {
    if (this.objects.has(id)) {
      console.warn(`ObjectManager: Object already exists: ${id}`);
      return false;
    }
    this.objects.set(id, obj);
    this.instances.add(id);
    return true;
  }

  /** Unregister without destroying */
  unregisterObject(id: ObjectId): boolean {
    if (!this.objects.has(id)) {
      return false;
    }
    const obj = this.objects.get(id)!;
    this.objects.delete(id);
    this.updateList.delete(obj);
    this.prepareList.delete(obj);
    this.instances.delete(id);
    return true;
  }
}

// Global singleton instance
export const objectManager = new ObjectManager();

// Convenience functions matching Lingo API
export function createObject<T extends IManagedObject>(
  id: ObjectId | 'random' | 'temp',
  ClassRef: ObjectClass<T>
): T | null {
  return objectManager.create(id, ClassRef);
}

export function getObject<T extends IManagedObject>(id: ObjectId): T | null {
  return objectManager.get<T>(id);
}

export function removeObject(id: ObjectId): boolean {
  return objectManager.remove(id);
}

export function objectExists(id: ObjectId): boolean {
  return objectManager.exists(id);
}

export function receiveUpdate(id: ObjectId): boolean {
  return objectManager.receiveUpdate(id);
}

export function removeUpdate(id: ObjectId): boolean {
  return objectManager.removeUpdate(id);
}

export function receivePrepare(id: ObjectId): boolean {
  return objectManager.receivePrepare(id);
}

export function removePrepare(id: ObjectId): boolean {
  return objectManager.removePrepare(id);
}

export function getObjectManager(): ObjectManager {
  return objectManager;
}
