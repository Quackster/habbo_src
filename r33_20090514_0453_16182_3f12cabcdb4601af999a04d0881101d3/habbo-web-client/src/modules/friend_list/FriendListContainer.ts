/**
 * Friend List Container - Data storage for friends and categories
 *
 * Ported from: hh_friend_list/Cast External ParentScript 7 - Friend List Container.ls
 */

import { FriendData, FriendCategory, CategoryIds } from './types';

export class FriendListContainer {
  private categories: Map<string, FriendCategory> = new Map();
  private friendList: Map<string, FriendData> = new Map();
  private listLimit: number = 0;

  /**
   * Populate category data from server
   */
  populateCategoryData(data: Map<string, string>): void {
    this.categories.clear();

    // Add online category (always first)
    this.categories.set(CategoryIds.ONLINE, {
      id: CategoryIds.ONLINE,
      name: 'Online', // getText("friend_list_online_category")
    });

    // Add custom categories
    data.forEach((name, id) => {
      this.categories.set(id, { id, name });
    });

    // Add offline category
    this.categories.set(CategoryIds.OFFLINE, {
      id: CategoryIds.OFFLINE,
      name: 'Offline', // getText("friend_list_offline_category")
    });

    // Add requests category
    this.categories.set(CategoryIds.REQUESTS, {
      id: CategoryIds.REQUESTS,
      name: 'Friend Requests', // getText("friend_list_friend_requests_category")
    });

    // Add search category
    this.categories.set(CategoryIds.SEARCH, {
      id: CategoryIds.SEARCH,
      name: 'Search', // getText("friend_list_search_category")
    });
  }

  /**
   * Populate friend data
   */
  populateFriendData(friends: Map<string, FriendData>): void {
    friends.forEach((friend) => {
      this.addFriend(friend);
    });
  }

  /**
   * Set list limit
   */
  setListLimit(limit: number): void {
    this.listLimit = limit;
  }

  /**
   * Check if friend list is full
   */
  isListFull(): boolean {
    if (this.listLimit === -1) {
      return false;
    }
    return this.friendList.size >= this.listLimit;
  }

  /**
   * Add a friend
   */
  addFriend(friend: FriendData): void {
    const id = String(friend.id);
    this.friendList.set(id, { ...friend });
  }

  /**
   * Update friend data
   */
  updateFriend(friendData: FriendData): void {
    const id = String(friendData.id);
    const existing = this.friendList.get(id);

    if (existing) {
      // Update properties, but don't overwrite figure with empty string
      const updated = { ...existing };
      for (const [key, value] of Object.entries(friendData)) {
        if (!(key === 'figure' && value === '')) {
          (updated as Record<string, unknown>)[key] = value;
        }
      }
      this.friendList.set(id, updated);
    }
  }

  /**
   * Remove a friend
   */
  removeFriend(friendId: number): void {
    this.friendList.delete(String(friendId));
  }

  /**
   * Get friend by ID
   */
  getFriendByID(friendId: number): FriendData | null {
    return this.friendList.get(String(friendId)) ?? null;
  }

  /**
   * Get friend by name
   */
  getFriendByName(name: string): FriendData | null {
    for (const friend of this.friendList.values()) {
      if (friend.name === name) {
        return friend;
      }
    }
    return null;
  }

  /**
   * Get all friends in a category
   */
  getFriendsInCategory(categoryId: string): Map<string, FriendData> {
    const result = new Map<string, FriendData>();
    const entries: Array<[string, FriendData]> = [];

    for (const friend of this.friendList.values()) {
      if (friend.categoryId === categoryId) {
        entries.push([friend.name, friend]);
      }
    }

    // Sort by name
    entries.sort((a, b) => a[0].localeCompare(b[0]));
    entries.forEach(([name, friend]) => result.set(name, friend));

    return result;
  }

  /**
   * Get category list
   */
  getCategoryList(): Map<string, FriendCategory> {
    return new Map(this.categories);
  }

  /**
   * Get category name
   */
  getCategoryName(catId: string): string {
    const category = this.categories.get(String(catId));
    return category?.name ?? '';
  }

  /**
   * Get friend count
   */
  getFriendCount(): number {
    return this.friendList.size;
  }

  /**
   * Get list limit
   */
  getListLimit(): number {
    return this.listLimit;
  }
}
