/**
 * Session - Global session state
 *
 * Lingo equivalent: getObject(#session)
 *
 * Stores user session data like:
 * - user_name, user_index, user_customData, user_figure
 * - room_controller, room_owner
 * - club_status
 * - user_rights
 * - Configuration flags (conf_coppa, conf_voucher, etc.)
 */

import { PropList } from '../types';

export class Session {
  private data: Map<string, unknown> = new Map();

  /**
   * Set a session value
   *
   * Lingo: getObject(#session).SET("key", value)
   *        getObject(#session).set("user_name", tName)
   */
  set(key: string, value: unknown): void {
    this.data.set(key, value);
  }

  /**
   * Get a session value
   *
   * Lingo: getObject(#session).GET("user_name")
   */
  GET<T = unknown>(key: string): T | undefined {
    return this.data.get(key) as T | undefined;
  }

  /**
   * Alias for GET (lowercase version used in original)
   */
  get<T = unknown>(key: string): T | undefined {
    return this.GET<T>(key);
  }

  /**
   * Check if key exists
   *
   * Lingo: getObject(#session).exists("key")
   */
  exists(key: string): boolean {
    return this.data.has(key);
  }

  /**
   * Delete a key
   */
  delete(key: string): boolean {
    return this.data.delete(key);
  }

  /**
   * Clear all session data
   */
  clear(): void {
    this.data.clear();
  }

  /**
   * Get all data as object
   */
  toObject(): PropList {
    const obj: PropList = {};
    for (const [key, value] of this.data) {
      obj[key] = value;
    }
    return obj;
  }

  /**
   * Get all keys
   */
  keys(): string[] {
    return Array.from(this.data.keys());
  }

  /**
   * Debug: print all session data
   */
  print(): void {
    console.log('=== Session Data ===');
    for (const [key, value] of this.data) {
      console.log(`  ${key}: ${JSON.stringify(value)}`);
    }
  }

  // === Common session accessors ===

  /** Get user name */
  getUserName(): string {
    return this.GET<string>('user_name') ?? '';
  }

  /** Get user figure string */
  getUserFigure(): string {
    return this.GET<string>('user_figure') ?? '';
  }

  /** Get user sex/gender */
  getUserSex(): string {
    return this.GET<string>('user_sex') ?? 'M';
  }

  /** Check if user is logged in */
  isLoggedIn(): boolean {
    return this.GET<boolean>('userLoggedIn') ?? false;
  }

  /** Get user rights array */
  getUserRights(): string[] {
    return this.GET<string[]>('user_rights') ?? [];
  }

  /** Check if user has a specific right */
  hasRight(right: string): boolean {
    const rights = this.getUserRights();
    return rights.includes(right);
  }

  /** Check if user is club member */
  isClubMember(): boolean {
    const status = this.GET<number>('club_status') ?? 0;
    return status > 0;
  }
}

// Global singleton
export const session = new Session();

// Convenience function to match Lingo pattern
export function getSession(): Session {
  return session;
}
