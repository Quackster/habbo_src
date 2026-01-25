/**
 * MessageBus - Pub/sub message system (Broker Manager)
 *
 * Ported from: fuse_client/Cast External ParentScript 40 - Broker Manager Class.ls
 *
 * This implements the message passing system used throughout Habbo:
 *   registerMessage(#messageType, receiverID, #handlerMethod)
 *   executeMessage(#messageType, data)
 *   unregisterMessage(#messageType, receiverID)
 *
 * Original behavior:
 * - Iterates subscribers in reverse order (last registered first)
 * - Supports up to 3 arguments (tArgA, tArgB, tArgC)
 * - Auto-unregisters if object no longer exists
 */

import { ObjectId, MessageHandler } from '../types';
import { getObject } from './ObjectManager';

interface Subscription {
  receiverId: ObjectId;
  methodName: string;
  handler?: MessageHandler;
}

export class MessageBus {
  private subscriptions: Map<string, Subscription[]> = new Map();
  private messageQueue: Array<{ type: string; args: unknown[] }> = [];
  private processing: boolean = false;
  private lastExecutedMessage: string = '';

  /**
   * Create a message type (optional pre-registration)
   *
   * Lingo: getBrokerManager().create(#messageType)
   */
  create(messageType: string): boolean {
    if (this.subscriptions.has(messageType)) {
      console.warn(`MessageBus: Message type already exists: ${messageType}`);
      return false;
    }
    this.subscriptions.set(messageType, []);
    return true;
  }

  /**
   * Remove a message type
   *
   * Lingo: getBrokerManager().Remove(#messageType)
   */
  remove(messageType: string): boolean {
    return this.subscriptions.delete(messageType);
  }

  /**
   * Register a message handler by method name (original Lingo style)
   *
   * Lingo: registerMessage(#userlogin, me.getID(), #showEntryBar)
   */
  register(messageType: string, receiverId: ObjectId, methodName: string): boolean {
    if (!this.subscriptions.has(messageType)) {
      this.subscriptions.set(messageType, []);
    }

    const subs = this.subscriptions.get(messageType)!;

    // Check for duplicate
    const existing = subs.find(s => s.receiverId === receiverId && s.methodName === methodName);
    if (existing) {
      console.warn(`MessageBus: ${receiverId} already registered for ${messageType}`);
      return false;
    }

    subs.push({ receiverId, methodName });
    return true;
  }

  /**
   * Register with a direct handler function (TypeScript style)
   */
  on(messageType: string, receiverId: ObjectId, handler: MessageHandler): boolean {
    if (!this.subscriptions.has(messageType)) {
      this.subscriptions.set(messageType, []);
    }

    const subs = this.subscriptions.get(messageType)!;
    subs.push({ receiverId, methodName: '', handler });
    return true;
  }

  /**
   * Unregister a message handler
   *
   * Lingo: unregisterMessage(#userlogin, me.getID())
   */
  unregister(messageType: string, receiverId: ObjectId): boolean {
    const subs = this.subscriptions.get(messageType);
    if (!subs) return false;

    const initialLength = subs.length;
    const filtered = subs.filter(s => s.receiverId !== receiverId);

    if (filtered.length === 0) {
      this.subscriptions.delete(messageType);
    } else {
      this.subscriptions.set(messageType, filtered);
    }

    return filtered.length < initialLength;
  }

  /**
   * Unregister all handlers for a specific receiver
   */
  unregisterAll(receiverId: ObjectId): void {
    for (const [messageType, subs] of this.subscriptions) {
      const filtered = subs.filter(s => s.receiverId !== receiverId);
      if (filtered.length === 0) {
        this.subscriptions.delete(messageType);
      } else {
        this.subscriptions.set(messageType, filtered);
      }
    }
  }

  /**
   * Execute/emit a message to all subscribers
   *
   * Lingo: executeMessage(#userlogin)
   *        executeMessage(#updateCreditCount, tCount)
   *        executeMessage(#someEvent, tArgA, tArgB, tArgC)
   */
  execute(messageType: string, ...args: unknown[]): boolean {
    // Queue message if we're in the middle of processing
    if (this.processing) {
      this.messageQueue.push({ type: messageType, args });
      return true;
    }

    this.processing = true;

    try {
      const subs = this.subscriptions.get(messageType);
      if (!subs || subs.length === 0) {
        return false;
      }

      // Iterate in reverse order (matching original behavior)
      // Create a copy to allow modifications during iteration
      const subsCopy = [...subs].reverse();

      for (const sub of subsCopy) {
        try {
          if (sub.handler) {
            // Direct handler function
            sub.handler(...args);
          } else {
            // Method name style - get object and call method
            const obj = getObject(sub.receiverId);
            if (!obj) {
              // Auto-unregister if object doesn't exist
              this.unregister(messageType, sub.receiverId);
              continue;
            }

            const method = (obj as Record<string, unknown>)[sub.methodName];
            if (typeof method === 'function') {
              this.lastExecutedMessage = `${messageType}-${sub.methodName}`;
              method.call(obj, ...args);
            }
          }
        } catch (error) {
          console.error(
            `MessageBus: Error in handler for ${messageType} (receiver: ${sub.receiverId}):`,
            error
          );
        }
      }

      return true;
    } finally {
      this.processing = false;
    }

    // Process any queued messages
    while (this.messageQueue.length > 0) {
      const queued = this.messageQueue.shift()!;
      this.execute(queued.type, ...queued.args);
    }
  }

  /**
   * Check if message type exists
   */
  exists(messageType: string): boolean {
    return this.subscriptions.has(messageType);
  }

  /**
   * Check if any handlers are registered for a message type
   */
  hasSubscribers(messageType: string): boolean {
    const subs = this.subscriptions.get(messageType);
    return subs !== undefined && subs.length > 0;
  }

  /**
   * Get subscriber count for a message type
   */
  getSubscriberCount(messageType: string): number {
    return this.subscriptions.get(messageType)?.length ?? 0;
  }

  /**
   * Get last executed message ID (for debugging)
   */
  getLastExecutedMessageId(): string {
    return this.lastExecutedMessage;
  }

  /**
   * Debug: print all subscriptions
   */
  print(): void {
    console.log('=== MessageBus Subscriptions ===');
    for (const [type, subs] of this.subscriptions) {
      console.log(`  ${type}:`);
      for (const sub of subs) {
        console.log(`    - ${sub.receiverId} -> ${sub.methodName || '(handler)'}`);
      }
    }
  }

  /**
   * Clear all subscriptions
   */
  clear(): void {
    this.subscriptions.clear();
    this.messageQueue = [];
    this.lastExecutedMessage = '';
  }
}

// Global singleton instance
export const messageBus = new MessageBus();

// Convenience functions matching Lingo API
export function registerMessage(
  messageType: string,
  receiverId: ObjectId,
  methodName: string
): boolean {
  return messageBus.register(messageType, receiverId, methodName);
}

export function unregisterMessage(messageType: string, receiverId: ObjectId): boolean {
  return messageBus.unregister(messageType, receiverId);
}

export function executeMessage(messageType: string, ...args: unknown[]): boolean {
  return messageBus.execute(messageType, ...args);
}

export function getBrokerManager(): MessageBus {
  return messageBus;
}
