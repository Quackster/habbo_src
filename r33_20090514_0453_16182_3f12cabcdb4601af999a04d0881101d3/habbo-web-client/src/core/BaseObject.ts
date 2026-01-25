/**
 * BaseObject - Base class for all managed objects
 *
 * Ported from: fuse_client/Cast External ParentScript 46 - Object Base Class.ls
 *
 * Provides common functionality that all Habbo objects inherit:
 * - ID management
 * - Message registration helpers
 * - Delay/timeout helpers
 * - Update loop registration
 * - Thread/component access (when part of a thread)
 */

import { ObjectId, IManagedObject, IThread } from '../types';
import { registerMessage, unregisterMessage, messageBus } from './MessageBus';
import { timeoutManager } from './TimeoutManager';
import { receiveUpdate, removeUpdate, receivePrepare, removePrepare } from './ObjectManager';

export abstract class BaseObject implements IManagedObject {
  public id: ObjectId = '';
  private _delays: Map<ObjectId, number> = new Map();
  private _registeredMessages: Array<{ type: string; method: string }> = [];
  private _thread: IThread | null = null;
  private _valid: boolean = true;

  /**
   * Get object ID
   *
   * Lingo: me.getID()
   */
  getID(): ObjectId {
    return this.id;
  }

  /**
   * Set object ID (called by ObjectManager during creation)
   */
  setID(id: ObjectId): void {
    if (this.id && this.id !== id) {
      console.warn(`BaseObject: Attempted to redefine object ID: ${this.id} -> ${id}`);
      return;
    }
    this.id = id;
  }

  /**
   * Check if object is still valid
   */
  get valid(): boolean {
    return this._valid;
  }

  set valid(value: boolean) {
    this._valid = value;
  }

  /**
   * Get all active delays
   */
  get delays(): Map<ObjectId, number> {
    return this._delays;
  }

  /**
   * Called after object creation
   * Override in subclasses
   */
  construct(): void {
    this._valid = true;
    this._delays = new Map();
  }

  /**
   * Called before object destruction
   * Override in subclasses
   */
  deconstruct(): void {
    // Cancel all delays
    for (const delayId of this._delays.keys()) {
      this.Cancel(delayId);
    }
    this._delays.clear();

    // Unregister all messages
    for (const reg of this._registeredMessages) {
      unregisterMessage(reg.type, this.id);
    }
    this._registeredMessages = [];

    // Remove from update loops
    removeUpdate(this.id);
    removePrepare(this.id);

    this._valid = false;
  }

  /**
   * Called each frame for preparation
   * Override in subclasses
   */
  prepare(): void {
    // Override in subclass
  }

  /**
   * Called each frame for updates
   * Override in subclasses
   */
  update(): void {
    // Override in subclass
  }

  // === Update loop registration ===

  /** Register for update loop */
  protected registerUpdate(): void {
    receiveUpdate(this.id);
  }

  /** Unregister from update loop */
  protected unregisterUpdate(): void {
    removeUpdate(this.id);
  }

  /** Register for prepare loop */
  protected registerPrepare(): void {
    receivePrepare(this.id);
  }

  /** Unregister from prepare loop */
  protected unregisterPrepare(): void {
    removePrepare(this.id);
  }

  // === Message registration ===

  /**
   * Register a message handler
   *
   * Lingo: registerMessage(#msgType, me.getID(), #handler)
   */
  protected registerMsg(messageType: string, methodName: string): void {
    registerMessage(messageType, this.id, methodName);
    this._registeredMessages.push({ type: messageType, method: methodName });
  }

  /**
   * Unregister a message handler
   *
   * Lingo: unregisterMessage(#msgType, me.getID())
   */
  protected unregisterMsg(messageType: string): void {
    unregisterMessage(messageType, this.id);
    this._registeredMessages = this._registeredMessages.filter(r => r.type !== messageType);
  }

  // === Delay/timeout helpers ===

  /**
   * Execute a delayed callback
   *
   * Lingo: me.delay(1000, #myMethod, [args])
   */
  protected delay(delayMs: number, methodName: string, args?: unknown[]): ObjectId {
    const delayId = `Delay_${this.id}_${performance.now()}`;

    timeoutManager.create(
      delayId,
      delayMs,
      () => {
        this._delays.delete(delayId);
        const method = (this as Record<string, unknown>)[methodName];
        if (typeof method === 'function') {
          if (args) {
            method.call(this, ...args);
          } else {
            method.call(this);
          }
        }
      },
      false
    );

    this._delays.set(delayId, performance.now() + delayMs);
    return delayId;
  }

  /**
   * Cancel a delayed callback
   *
   * Lingo: me.Cancel(delayId)
   */
  protected Cancel(delayId: ObjectId): boolean {
    if (this._delays.has(delayId)) {
      timeoutManager.remove(delayId);
      this._delays.delete(delayId);
      return true;
    }
    return false;
  }

  // === Thread/component access (for objects that are part of a thread) ===

  /**
   * Get the thread this object belongs to
   */
  protected getThread(): IThread | null {
    return this._thread;
  }

  /**
   * Get the interface object from this thread
   */
  protected getInterface<T extends IManagedObject>(): T | null {
    return this._thread?.interface as T ?? null;
  }

  /**
   * Get the component object from this thread
   */
  protected getComponent<T extends IManagedObject>(): T | null {
    return this._thread?.component as T ?? null;
  }

  /**
   * Get the handler object from this thread
   */
  protected getHandler<T extends IManagedObject>(): T | null {
    return this._thread?.handler as T ?? null;
  }

  // === Property access (for Lingo compatibility) ===

  /**
   * Get a property
   *
   * Lingo: me.getProperty(#propName)
   */
  getProperty(propName: string): unknown {
    return (this as Record<string, unknown>)[propName];
  }

  /**
   * Set a property
   *
   * Lingo: me.setProperty(#propName, value)
   */
  setProperty(propName: string, value: unknown): void {
    (this as Record<string, unknown>)[propName] = value;
  }

  /**
   * Set a property (alternate name used in original)
   */
  setaProp(propName: string, value: unknown): void {
    this.setProperty(propName, value);
  }

  /**
   * Get a property (alternate name)
   */
  getaProp(propName: string): unknown {
    return this.getProperty(propName);
  }

  /**
   * Check if object has a handler/method
   *
   * Lingo: tObject.handler(#methodName)
   */
  handler(methodName: string): boolean {
    return typeof (this as Record<string, unknown>)[methodName] === 'function';
  }

  /**
   * Debug print
   */
  print(): void {
    console.log(this.toString());
  }

  toString(): string {
    return `<${this.constructor.name} id="${this.id}">`;
  }
}
