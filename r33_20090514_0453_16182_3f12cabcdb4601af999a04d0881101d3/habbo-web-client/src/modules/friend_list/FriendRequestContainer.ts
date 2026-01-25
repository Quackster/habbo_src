/**
 * Friend Request Container - Data storage for friend requests
 *
 * Ported from: hh_friend_list/Cast External ParentScript 8 - Friend Request List Container.ls
 */

import { FriendRequest, FriendRequestState } from './types';

export class FriendRequestContainer {
  private requests: Map<string, FriendRequest> = new Map();

  /**
   * Add a friend request
   */
  addRequest(request: FriendRequest): void {
    this.requests.set(request.id, { ...request });
  }

  /**
   * Update a friend request
   */
  updateRequest(request: FriendRequest): void {
    const existing = this.requests.get(request.id);
    if (existing) {
      this.requests.set(request.id, { ...existing, ...request });
    }
  }

  /**
   * Remove a friend request
   */
  removeRequest(requestId: string): void {
    this.requests.delete(requestId);
  }

  /**
   * Get pending friend requests
   */
  getPendingRequests(): Map<string, FriendRequest> {
    const pending = new Map<string, FriendRequest>();
    for (const [id, request] of this.requests) {
      if (request.state === 'pending') {
        pending.set(id, { ...request });
      }
    }
    return pending;
  }

  /**
   * Get all requests
   */
  getAllRequests(): Map<string, FriendRequest> {
    return new Map(this.requests);
  }

  /**
   * Get request by ID
   */
  getRequestById(requestId: string): FriendRequest | null {
    return this.requests.get(requestId) ?? null;
  }

  /**
   * Clear all requests
   */
  clear(): void {
    this.requests.clear();
  }

  /**
   * Get pending count
   */
  getPendingCount(): number {
    let count = 0;
    for (const request of this.requests.values()) {
      if (request.state === 'pending') {
        count++;
      }
    }
    return count;
  }
}
