/**
 * ConnectionManager - WebSocket connection management
 *
 * Ported from: fuse_client/Cast External ParentScript 33 - Connection Manager Class.ls
 *
 * Manages:
 * - Multiple connections (info connection, room connection, etc.)
 * - Message listeners per connection (incoming message routing)
 * - Command ID registration (outgoing message encoding)
 */

import { ObjectId, MessageCallback } from '../types';
import { HabboConnection } from '../network/HabboConnection';
import { getObject } from '../core/ObjectManager';

export class ConnectionManager {
  private connections: Map<ObjectId, HabboConnection> = new Map();

  // Listeners: connectionId -> messageType -> [callbacks]
  private listeners: Map<ObjectId, Map<number, MessageCallback[]>> = new Map();

  // Commands: connectionId -> commandName -> encodedId
  private commands: Map<ObjectId, Map<string, string>> = new Map();

  // Last message tracking (for debugging)
  private lastMessageData: {
    id?: number;
    message?: string;
    isParsed?: boolean;
  } = {};

  /**
   * Create a new connection
   *
   * Lingo: createConnection(#Info, host, port)
   */
  create(connectionId: ObjectId, host: string, port: number): HabboConnection | null {
    if (this.connections.has(connectionId)) {
      console.error(`ConnectionManager: Connection already exists: ${connectionId}`);
      return null;
    }

    // Initialize listener and command maps for this connection
    this.listeners.set(connectionId, new Map());
    this.commands.set(connectionId, new Map());

    const connection = new HabboConnection(
      connectionId,
      host,
      port,
      this.listeners.get(connectionId)!,
      this.commands.get(connectionId)!,
      (objId, method, msg) => this.dispatchMessage(objId, method, msg)
    );

    this.connections.set(connectionId, connection);
    return connection;
  }

  /**
   * Get a connection
   *
   * Lingo: getConnection(#Info)
   */
  get(connectionId: ObjectId): HabboConnection | null {
    return this.connections.get(connectionId) ?? null;
  }

  /**
   * Alias for get (matching original API)
   */
  GET(connectionId: ObjectId): HabboConnection | null {
    return this.get(connectionId);
  }

  /**
   * Check if connection exists
   *
   * Lingo: connectionExists(#Info)
   */
  exists(connectionId: ObjectId): boolean {
    return this.connections.has(connectionId);
  }

  /**
   * Remove a connection
   */
  remove(connectionId: ObjectId): boolean {
    const conn = this.connections.get(connectionId);
    if (!conn) {
      return false;
    }

    conn.disconnect(true);
    this.connections.delete(connectionId);
    this.listeners.delete(connectionId);
    this.commands.delete(connectionId);
    return true;
  }

  /**
   * Register message listeners for a connection
   *
   * Lingo: registerListener(#Info, me.getID(), [0: #handleHello, 3: #handleLoginOK, ...])
   */
  registerListener(
    connectionId: ObjectId,
    objectId: ObjectId,
    messageMap: Record<number, string> | Map<number, string>
  ): boolean {
    const listeners = this.listeners.get(connectionId);
    if (!listeners) {
      console.error(`ConnectionManager: Connection not found: ${connectionId}`);
      return false;
    }

    const entries =
      messageMap instanceof Map
        ? messageMap.entries()
        : Object.entries(messageMap).map(([k, v]) => [Number(k), v] as [number, string]);

    for (const [msgType, methodName] of entries) {
      if (!listeners.has(msgType)) {
        listeners.set(msgType, []);
      }
      listeners.get(msgType)!.push([objectId, methodName]);
    }

    return true;
  }

  /**
   * Unregister message listeners
   *
   * Lingo: unregisterListener(#Info, me.getID(), [...])
   */
  unregisterListener(
    connectionId: ObjectId,
    objectId: ObjectId,
    messageMap: Record<number, string> | Map<number, string>
  ): boolean {
    const listeners = this.listeners.get(connectionId);
    if (!listeners) return false;

    const entries =
      messageMap instanceof Map
        ? messageMap.entries()
        : Object.entries(messageMap).map(([k, v]) => [Number(k), v] as [number, string]);

    for (const [msgType] of entries) {
      const callbacks = listeners.get(msgType);
      if (callbacks) {
        const filtered = callbacks.filter(([objId]) => objId !== objectId);
        if (filtered.length > 0) {
          listeners.set(msgType, filtered);
        } else {
          listeners.delete(msgType);
        }
      }
    }

    return true;
  }

  /**
   * Register outgoing command IDs
   *
   * Lingo: registerCommands(#Info, me.getID(), ["TRY_LOGIN": 4, "GET_INFO": 7, ...])
   *
   * Command IDs are encoded as 2-byte Base64-like:
   * byte1 = (id / 64) | 64
   * byte2 = (id & 63) | 64
   */
  registerCommands(
    connectionId: ObjectId,
    commandMap: Record<string, number> | Map<string, number>
  ): boolean {
    const commands = this.commands.get(connectionId);
    if (!commands) {
      console.error(`ConnectionManager: Connection not found: ${connectionId}`);
      return false;
    }

    const entries =
      commandMap instanceof Map
        ? commandMap.entries()
        : Object.entries(commandMap).map(([k, v]) => [k, Number(v)] as [string, number]);

    for (const [cmdName, cmdId] of entries) {
      // Encode command ID as 2 bytes
      const byte1 = String.fromCharCode((cmdId >> 6) | 64);
      const byte2 = String.fromCharCode((cmdId & 63) | 64);
      commands.set(cmdName, byte1 + byte2);
    }

    return true;
  }

  /**
   * Unregister commands (mostly a no-op in original)
   */
  unregisterCommands(
    connectionId: ObjectId,
    _objectId: ObjectId,
    _commandMap: Record<string, number>
  ): boolean {
    // Original doesn't actually remove commands
    return this.commands.has(connectionId);
  }

  /**
   * Dispatch a message to the appropriate handler
   */
  private dispatchMessage(
    objectId: ObjectId,
    methodName: string,
    message: unknown
  ): void {
    const obj = getObject(objectId);
    if (!obj) {
      console.warn(`ConnectionManager: Object not found for message dispatch: ${objectId}`);
      return;
    }

    const method = (obj as Record<string, unknown>)[methodName];
    if (typeof method === 'function') {
      try {
        method.call(obj, message);
      } catch (error) {
        console.error(`ConnectionManager: Error in handler ${objectId}.${methodName}:`, error);
      }
    }
  }

  /**
   * Register last message (for debugging)
   */
  registerLastMessage(messageId: number, message: string): void {
    this.lastMessageData = {
      id: messageId,
      message: `${messageId}-${message}`.slice(0, 128),
      isParsed: false,
    };
  }

  /**
   * Mark last message as parsed
   */
  lastMessageParsed(): void {
    if (this.lastMessageData) {
      this.lastMessageData.isParsed = true;
    }
  }

  /**
   * Get last message data
   */
  getLastMessageData(): typeof this.lastMessageData {
    return { ...this.lastMessageData };
  }

  /**
   * Close all connections
   */
  closeAll(): void {
    for (const conn of this.connections.values()) {
      conn.disconnect(true);
    }
    this.connections.clear();
    this.listeners.clear();
    this.commands.clear();
  }

  /**
   * Debug: print all connections
   */
  print(): void {
    console.log('=== ConnectionManager ===');
    for (const [id, conn] of this.connections) {
      console.log(`  ${id}: ${conn.isReady() ? 'connected' : 'disconnected'}`);
    }
  }
}

// Global singleton
export const connectionManager = new ConnectionManager();

// Convenience functions matching Lingo API
export function createConnection(
  id: ObjectId,
  host: string,
  port: number
): HabboConnection | null {
  return connectionManager.create(id, host, port);
}

export function getConnection(id: ObjectId): HabboConnection | null {
  return connectionManager.get(id);
}

export function connectionExists(id: ObjectId): boolean {
  return connectionManager.exists(id);
}

export function removeConnection(id: ObjectId): boolean {
  return connectionManager.remove(id);
}

export function registerListener(
  connId: ObjectId,
  objId: ObjectId,
  msgMap: Record<number, string>
): boolean {
  return connectionManager.registerListener(connId, objId, msgMap);
}

export function unregisterListener(
  connId: ObjectId,
  objId: ObjectId,
  msgMap: Record<number, string>
): boolean {
  return connectionManager.unregisterListener(connId, objId, msgMap);
}

export function registerCommands(
  connId: ObjectId,
  cmdMap: Record<string, number>
): boolean {
  return connectionManager.registerCommands(connId, cmdMap);
}

export function unregisterCommands(
  connId: ObjectId,
  objId: ObjectId,
  cmdMap: Record<string, number>
): boolean {
  return connectionManager.unregisterCommands(connId, objId, cmdMap);
}

export function getConnectionManager(): ConnectionManager {
  return connectionManager;
}
