/**
 * Friend List Component Class - Business logic for friend list
 *
 * Ported from: hh_friend_list/Cast External ParentScript 4 - Friend List Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import {
  FriendData,
  FriendRequest,
  FriendRequestState,
  HabboSearchResult,
  HabboSearchResults,
  FriendCategory,
} from './types';
import { FriendListContainer } from './FriendListContainer';
import { FriendRequestContainer } from './FriendRequestContainer';
import { FriendListInterface } from './FriendListInterface';

export class FriendListComponent extends BaseObject {
  private friendDataContainer: FriendListContainer;
  private friendRequestContainer: FriendRequestContainer;
  private updateIntervalId: ReturnType<typeof setInterval> | null = null;
  private readyFlag: boolean = false;
  private newMail: boolean = false;
  private habboSearchResults: HabboSearchResults = { friends: [], habbos: [] };
  private habboSearchLastString: string = '';
  private sentFriendRequests: string[] = [];

  constructor() {
    super();
    this.friendDataContainer = new FriendListContainer();
    this.friendRequestContainer = new FriendRequestContainer();
  }

  construct(): void {
    super.construct();
    registerMessage('externalFriendRequest', this.id, 'externalFriendRequest');
  }

  deconstruct(): void {
    if (this.updateIntervalId) {
      clearInterval(this.updateIntervalId);
      this.updateIntervalId = null;
    }
    unregisterMessage('externalFriendRequest', this.id);
    super.deconstruct();
  }

  /**
   * Mark friend list as initialized
   */
  setFriendListInited(): void {
    const interval = getVariable('fr.update.interval', 60000) as number;
    this.updateIntervalId = setInterval(() => this.requestFriendListUpdate(), interval);
    executeMessage('friendListReady');
    this.readyFlag = true;
  }

  /**
   * Check if friend list is initialized
   */
  isFriendListInited(): boolean {
    return this.readyFlag;
  }

  /**
   * Populate category data
   */
  populateCategoryData(data: Map<string, string>): void {
    this.friendDataContainer.populateCategoryData(data);
    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      iface.changeCategory();
    }
  }

  /**
   * Populate friend data
   */
  populateFriendData(data: Map<string, FriendData>): void {
    this.friendDataContainer.populateFriendData(data);
  }

  /**
   * Add a friend
   */
  addFriend(friendData: FriendData): void {
    if (friendData) {
      // Remove from sent requests if present
      const idx = this.sentFriendRequests.indexOf(friendData.name);
      if (idx !== -1) {
        this.sentFriendRequests.splice(idx, 1);
      }
    }
    this.friendDataContainer.addFriend(friendData);
    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      iface.addFriend(friendData);
    }
  }

  /**
   * Update a friend
   */
  updateFriend(friendData: FriendData, holdRender: boolean = false): void {
    if (!friendData) return;

    const oldFriendData = this.friendDataContainer.getFriendByID(friendData.id);

    // Remove from sent requests if present
    const idx = this.sentFriendRequests.indexOf(friendData.name);
    if (idx !== -1) {
      this.sentFriendRequests.splice(idx, 1);
    }

    if (oldFriendData && oldFriendData.categoryId !== friendData.categoryId) {
      // Category changed - remove from old, add to new
      const iface = this.getInterface() as FriendListInterface | null;
      if (iface) {
        iface.removeFriend(oldFriendData.id, oldFriendData.categoryId);
      }
      this.friendDataContainer.updateFriend(friendData);
      const updatedFriend = this.friendDataContainer.getFriendByID(friendData.id);
      if (updatedFriend && iface) {
        iface.addFriend(updatedFriend, holdRender);
      }
    } else {
      this.friendDataContainer.updateFriend(friendData);
      const updatedFriend = this.friendDataContainer.getFriendByID(friendData.id);
      if (updatedFriend) {
        const iface = this.getInterface() as FriendListInterface | null;
        if (iface) {
          iface.updateFriend(updatedFriend, holdRender);
        }
      }
    }

    executeMessage('friendDataUpdated', friendData.id);
  }

  /**
   * Remove a friend
   */
  removeFriend(friendId: number): void {
    const friendData = this.getFriendByID(friendId);
    if (!friendData) return;

    const categoryId = friendData.categoryId;
    this.friendDataContainer.removeFriend(friendId);

    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      iface.removeFriend(friendId, categoryId);
    }
  }

  /**
   * Add a friend request
   */
  addFriendRequest(requestData: FriendRequest): void {
    this.friendRequestContainer.addRequest(requestData);
    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      iface.addFriendRequest(requestData);
    }
  }

  /**
   * Set unread mail count
   */
  setUnreadMailCount(count: number): void {
    const iface = this.getInterface() as FriendListInterface | null;
    if (count > 0) {
      this.newMail = true;
      if (iface) {
        iface.activateMailIcon(true);
        iface.startInboxBlink();
      }
    } else {
      this.newMail = false;
      if (iface) {
        iface.activateMailIcon(false);
        iface.endInboxBlink();
      }
    }
    this.updateFriendListIconStatus();
  }

  /**
   * Handle new mail notification
   */
  newMailFrom(userId: string): void {
    this.newMail = true;
    this.updateFriendListIconStatus();

    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      iface.activateMailIcon(true);
      iface.startInboxBlink();
    }

    // Play sound
    const soundMemName = getVariable('fr.new.mail.sound', 'mail_received') as string;
    executeMessage('playSound', soundMemName, { loopCount: 1 });
  }

  /**
   * Notify about friend requests
   */
  notifyFriendRequests(): void {
    const pendingList = this.getPendingFriendRequests();
    const pendingCount = pendingList.size;

    executeMessage('updateFriendRequestCount', pendingCount);

    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      if (pendingCount > 0) {
        iface.setCategoryHighlight('-2');
      } else {
        iface.removeCategoryHighlight('-2');
      }
    }
    this.updateFriendListIconStatus();
  }

  /**
   * Update friend list icon status
   */
  updateFriendListIconStatus(): void {
    let active = false;
    const frList = this.getPendingFriendRequests();
    if (frList.size > 0) {
      active = true;
    }
    if (this.newMail) {
      active = true;
    }
    executeMessage('updateFriendListIcon', active);
  }

  /**
   * Set friend limits
   */
  setFriendLimits(userLimit: number, normalLimit: number, extendedLimit: number): void {
    this.friendDataContainer.setListLimit(userLimit);
  }

  /**
   * Check if friend list is full
   */
  isFriendListFull(): boolean {
    return this.friendDataContainer.isListFull();
  }

  /**
   * Update a friend request
   */
  updateFriendRequest(requestData: FriendRequest, state: FriendRequestState): void {
    if (!requestData) return;

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return;

    if (state === 'rejected') {
      conn.send('FRIENDLIST_DECLINEFRIEND', { integers: [0, 1, parseInt(requestData.id)] });
    } else if (state === 'accepted') {
      conn.send('FRIENDLIST_ACCEPTFRIEND', { integers: [1, parseInt(requestData.id)] });
    }

    requestData.state = state;
    this.friendRequestContainer.updateRequest(requestData);
    this.notifyFriendRequests();
  }

  /**
   * Handle all friend requests at once
   */
  handleAllRequests(state: FriendRequestState): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    const requests = this.getPendingFriendRequests();
    if (requests.size === 0) return true;

    const ids: number[] = [];
    for (const request of requests.values()) {
      ids.push(parseInt(request.id));
      request.state = state;
      this.friendRequestContainer.updateRequest(request);
    }

    if (state === 'accepted') {
      conn.send('FRIENDLIST_ACCEPTFRIEND', { integers: [ids.length, ...ids] });
    } else {
      conn.send('FRIENDLIST_DECLINEFRIEND', { integers: [0, ids.length, ...ids] });
    }

    this.notifyFriendRequests();
    return true;
  }

  /**
   * Get pending friend requests
   */
  getPendingFriendRequests(): Map<string, FriendRequest> {
    return this.friendRequestContainer.getPendingRequests();
  }

  /**
   * Send remove friend request
   */
  sendRemoveFriend(friendId: number): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('FRIENDLIST_REMOVEFRIEND', { integers: [1, friendId] });
    }
  }

  /**
   * Get friend by ID
   */
  getFriendByID(friendId: number): FriendData | null {
    return this.friendDataContainer.getFriendByID(friendId);
  }

  /**
   * Get friend by name
   */
  getFriendByName(name: string): FriendData | null {
    return this.friendDataContainer.getFriendByName(name);
  }

  /**
   * Get friends in category
   */
  getFriendsInCategory(categoryId: string): Map<string, FriendData> {
    return this.friendDataContainer.getFriendsInCategory(categoryId);
  }

  /**
   * Get category list
   */
  getCategoryList(): Map<string, FriendCategory> {
    return this.friendDataContainer.getCategoryList();
  }

  /**
   * Get category name
   */
  getCategoryName(id: string): string {
    return this.friendDataContainer.getCategoryName(id);
  }

  /**
   * Get item count for category
   */
  getItemCountForCategory(categoryId: string): number {
    const catIdNum = parseInt(categoryId);
    if (catIdNum >= -1) {
      const list = this.friendDataContainer.getFriendsInCategory(categoryId);
      return list.size;
    } else if (categoryId === '-2') {
      return this.friendRequestContainer.getPendingCount();
    } else if (categoryId === '-3') {
      return this.habboSearchResults.friends.length + this.habboSearchResults.habbos.length;
    }
    return 0;
  }

  /**
   * Request friend list update from server
   */
  requestFriendListUpdate(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('FRIENDLIST_UPDATE');
    }
  }

  /**
   * Send external friend request
   */
  externalFriendRequest(targetUserName: string): void {
    if (this.isFriendListFull()) {
      executeMessage('alert', 'console_fr_limit_exceeded_error');
      return;
    }

    if (!targetUserName || targetUserName === '') {
      return;
    }

    const text = `${targetUserName} Friend request sent`;
    executeMessage('alert', text);

    if (!this.sentFriendRequests.includes(targetUserName)) {
      this.sentFriendRequests.push(targetUserName);
    }

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('FRIENDLIST_FRIENDREQUEST', { string: targetUserName });
    }
  }

  /**
   * Send request for friend requests list
   */
  sendAskForFriendRequests(): void {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('FRIENDLIST_GETFRIENDREQUESTS');
    }
  }

  /**
   * Send habbo search
   */
  sendHabboSearch(searchString: string): void {
    if (typeof searchString !== 'string' || searchString === '') {
      return;
    }
    if (searchString === this.habboSearchLastString) {
      return;
    }

    this.habboSearchLastString = searchString;

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('MESSENGER_HABBOSEARCH', { string: searchString });
    }
  }

  /**
   * Set friend request result
   */
  setFriendRequestResult(errorList: Map<string, number>): void {
    for (const [name] of errorList) {
      const idx = this.sentFriendRequests.indexOf(name);
      if (idx !== -1) {
        this.sentFriendRequests.splice(idx, 1);
      }
    }

    // Show error messages for failures
    if (errorList.size > 0) {
      executeMessage('alert', 'Friend request failed');
    }
  }

  /**
   * Set habbo search results
   */
  setHabboSearchResults(resultsFriends: HabboSearchResult[], resultsHabbos: HabboSearchResult[]): void {
    this.habboSearchResults.friends = resultsFriends;

    // Mark pending requests
    for (const item of resultsHabbos) {
      if (this.sentFriendRequests.includes(item.name)) {
        item.fr_pending = true;
      }
    }
    this.habboSearchResults.habbos = resultsHabbos;

    const iface = this.getInterface() as FriendListInterface | null;
    if (iface) {
      iface.updateCategoryCounts();
    }
  }

  /**
   * Get habbo search results
   */
  getHabboSearchResults(): HabboSearchResults {
    return this.habboSearchResults;
  }

  /**
   * Get habbo search last string
   */
  getHabboSearchLastString(): string {
    return this.habboSearchLastString;
  }

  /**
   * Check if has new mail
   */
  hasNewMail(): boolean {
    return this.newMail;
  }
}
