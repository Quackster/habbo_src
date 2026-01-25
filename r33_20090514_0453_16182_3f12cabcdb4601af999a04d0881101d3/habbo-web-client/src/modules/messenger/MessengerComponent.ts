/**
 * Messenger Component Class
 *
 * Manages messenger state, buddy list, messages, and friend requests.
 * Ported from hh_messenger Cast External ParentScript 4.
 */

import {
  BuddyData,
  BuddyList,
  FriendRequest,
  MessageData,
  MessengerState,
  BuddyListLimits,
  RequestState,
} from './types';

export class MessengerComponent {
  private state: MessengerState;
  private paused: boolean = false;
  private updateBuddiesInterval: number = 120000;
  private lastBuddiesUpdateTime: number = 0;
  private buddyListLimits: BuddyListLimits = { own: 0, normal: 100, club: 600 };
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor() {
    this.state = {
      ready: false,
      paused: false,
      buddyList: {
        buddies: new Map(),
        online: [],
        offline: [],
        render: [],
      },
      messages: new Map(),
      msgCount: new Map(),
      totalMsgCount: 0,
      friendRequests: [],
      persistentMessage: '',
      friendRequestUpdateRequired: false,
      messageUpdateRequired: false,
    };
  }

  /**
   * Set event callback
   */
  setEventCallback(callback: (event: string, data: unknown) => void): void {
    this.eventCallback = callback;
  }

  /**
   * Emit event to listeners
   */
  private emit(event: string, data: unknown): void {
    if (this.eventCallback) {
      this.eventCallback(event, data);
    }
  }

  /**
   * Reset messenger state
   */
  reset(): void {
    this.state.ready = false;
    this.state.buddyList.buddies.clear();
    this.state.buddyList.online = [];
    this.state.buddyList.offline = [];
    this.state.buddyList.render = [];
    this.state.messages.clear();
    this.state.msgCount.clear();
    this.state.totalMsgCount = 0;
    this.state.friendRequests = [];
    this.state.persistentMessage = '';
  }

  /**
   * Check if messenger is ready
   */
  isReady(): boolean {
    return this.state.ready;
  }

  /**
   * Set ready state
   */
  setReady(ready: boolean): void {
    this.state.ready = ready;
    if (ready) {
      this.emit('ready', null);
    }
  }

  /**
   * Get buddy list data
   */
  getBuddyList(): BuddyList {
    return this.state.buddyList;
  }

  /**
   * Get buddy by ID
   */
  getBuddy(buddyId: string): BuddyData | undefined {
    return this.state.buddyList.buddies.get(buddyId);
  }

  /**
   * Get buddy by name
   */
  getBuddyByName(name: string): BuddyData | undefined {
    for (const buddy of this.state.buddyList.buddies.values()) {
      if (buddy.name === name) {
        return buddy;
      }
    }
    return undefined;
  }

  /**
   * Receive new buddy list from server
   */
  receiveBuddyList(buddyData: Map<string, BuddyData>): void {
    this.state.buddyList.buddies = buddyData;
    this.sortBuddyList();
    this.emit('buddy_list_updated', this.state.buddyList);
  }

  /**
   * Update buddy list with partial updates
   */
  updateBuddyList(updates: BuddyData[]): void {
    for (const update of updates) {
      const existing = this.state.buddyList.buddies.get(update.id);
      if (existing) {
        // Merge updates
        Object.assign(existing, update);

        // Update message count from stored messages
        const msgList = this.state.messages.get(update.id);
        if (msgList) {
          existing.msgs = msgList.size;
        }

        // Update online/offline lists
        if (update.online) {
          const offlineIdx = this.state.buddyList.offline.indexOf(existing.name);
          if (offlineIdx !== -1) {
            this.state.buddyList.offline.splice(offlineIdx, 1);
          }
          if (!this.state.buddyList.online.includes(existing.name)) {
            this.state.buddyList.online.push(existing.name);
          }
        } else {
          const onlineIdx = this.state.buddyList.online.indexOf(existing.name);
          if (onlineIdx !== -1) {
            this.state.buddyList.online.splice(onlineIdx, 1);
          }
          if (!this.state.buddyList.offline.includes(existing.name)) {
            this.state.buddyList.offline.push(existing.name);
          }
        }
      }
    }
    this.rebuildRenderList();
    this.emit('buddy_list_updated', this.state.buddyList);
  }

  /**
   * Append a new buddy
   */
  appendBuddy(buddy: BuddyData): void {
    this.state.buddyList.buddies.set(buddy.id, buddy);

    if (buddy.online) {
      if (!this.state.buddyList.online.includes(buddy.name)) {
        this.state.buddyList.online.push(buddy.name);
      }
    } else {
      if (!this.state.buddyList.offline.includes(buddy.name)) {
        this.state.buddyList.offline.push(buddy.name);
      }
    }

    this.rebuildRenderList();

    // Check if this matches a pending friend request
    for (const request of this.state.friendRequests) {
      if (request.webId === buddy.id && request.state === 'sent') {
        request.state = 'accepted';
      }
    }

    this.emit('buddy_added', buddy);
  }

  /**
   * Remove buddies
   */
  removeBuddies(buddyIds: string[]): void {
    for (const buddyId of buddyIds) {
      const buddy = this.state.buddyList.buddies.get(buddyId);
      if (buddy) {
        const buddyName = buddy.name;
        this.state.buddyList.buddies.delete(buddyId);

        // Remove from online/offline lists
        const onlineIdx = this.state.buddyList.online.indexOf(buddyName);
        if (onlineIdx !== -1) {
          this.state.buddyList.online.splice(onlineIdx, 1);
        }
        const offlineIdx = this.state.buddyList.offline.indexOf(buddyName);
        if (offlineIdx !== -1) {
          this.state.buddyList.offline.splice(offlineIdx, 1);
        }

        // Remove messages from this buddy
        this.eraseMessagesBySenderId(buddyId);
      }
    }

    this.rebuildRenderList();
    this.emit('buddy_removed', buddyIds);
  }

  /**
   * Sort buddy list
   */
  private sortBuddyList(): void {
    this.state.buddyList.online = [];
    this.state.buddyList.offline = [];

    for (const buddy of this.state.buddyList.buddies.values()) {
      if (buddy.online) {
        this.state.buddyList.online.push(buddy.name);
      } else {
        this.state.buddyList.offline.push(buddy.name);
      }
    }

    this.state.buddyList.online.sort();
    this.state.buddyList.offline.sort();
    this.rebuildRenderList();
  }

  /**
   * Rebuild render list
   */
  private rebuildRenderList(): void {
    this.state.buddyList.render = [
      ...this.state.buddyList.online,
      ...this.state.buddyList.offline,
    ];
  }

  // ============== Messages ==============

  /**
   * Receive a message
   */
  receiveMessage(msg: MessageData): void {
    if (!this.state.messages.has(msg.senderId)) {
      this.state.messages.set(msg.senderId, new Map());
    }
    this.state.messages.get(msg.senderId)!.set(msg.id, msg);

    // Update counts
    const senderCount = this.state.msgCount.get(msg.senderId) || 0;
    this.state.msgCount.set(msg.senderId, senderCount + 1);
    this.state.totalMsgCount++;

    // Update buddy message count
    const sender = this.state.buddyList.buddies.get(msg.senderId);
    if (sender) {
      sender.msgs = (sender.msgs || 0) + 1;
      sender.update = true;
    }

    this.emit('message_received', msg);
  }

  /**
   * Mark message as read and remove it
   */
  markMessageRead(messageId: string, senderId: string): void {
    this.decreaseMsgCount(senderId);

    const senderMessages = this.state.messages.get(senderId);
    if (senderMessages) {
      senderMessages.delete(messageId);
      if (senderMessages.size === 0) {
        this.state.messages.delete(senderId);
      }
    }
  }

  /**
   * Get messages from a sender
   */
  getMessagesBySenderId(senderId: string): MessageData[] {
    const messages = this.state.messages.get(senderId);
    return messages ? Array.from(messages.values()) : [];
  }

  /**
   * Get next unread message
   */
  getNextMessage(): MessageData | undefined {
    for (const senderMessages of this.state.messages.values()) {
      for (const msg of senderMessages.values()) {
        return msg;
      }
    }
    return undefined;
  }

  /**
   * Get total message count
   */
  getNumOfMessages(): number {
    return this.state.totalMsgCount;
  }

  /**
   * Erase all messages from a sender
   */
  eraseMessagesBySenderId(senderId: string): void {
    const senderMessages = this.state.messages.get(senderId);
    const msgCount = senderMessages ? senderMessages.size : 0;

    this.state.messages.delete(senderId);
    this.state.msgCount.set(senderId, 0);
    this.state.totalMsgCount = Math.max(0, this.state.totalMsgCount - msgCount);
  }

  /**
   * Decrease message count for sender
   */
  private decreaseMsgCount(senderId: string): void {
    const current = this.state.msgCount.get(senderId) || 0;
    this.state.msgCount.set(senderId, Math.max(0, current - 1));
    this.state.totalMsgCount = Math.max(0, this.state.totalMsgCount - 1);

    // Update buddy message count
    const buddy = this.state.buddyList.buddies.get(senderId);
    if (buddy && buddy.msgs > 0) {
      buddy.msgs--;
      buddy.update = true;
    }
  }

  /**
   * Delete all messages
   */
  deleteAllMessages(): void {
    this.state.messages.clear();
    this.state.msgCount.clear();
    this.state.totalMsgCount = 0;
  }

  // ============== Persistent Message ==============

  /**
   * Set persistent message (motto)
   */
  setPersistentMessage(msg: string): void {
    this.state.persistentMessage = msg;
  }

  /**
   * Get persistent message
   */
  getPersistentMessage(): string {
    return this.state.persistentMessage;
  }

  // ============== Friend Requests ==============

  /**
   * Receive friend requests
   */
  receiveFriendRequests(requests: FriendRequest[]): void {
    for (const request of requests) {
      this.state.friendRequests.push(request);
    }
    this.emit('friend_request_received', requests);
  }

  /**
   * Get all friend requests
   */
  getFriendRequests(): FriendRequest[] {
    return this.state.friendRequests;
  }

  /**
   * Get friend requests by state
   */
  getRequestsByState(state: RequestState): FriendRequest[] {
    return this.state.friendRequests.filter((r) => r.state === state);
  }

  /**
   * Get pending request count
   */
  getPendingRequestCount(): number {
    return this.state.friendRequests.filter((r) => r.state === 'pending').length;
  }

  /**
   * Get total request count
   */
  getRequestCount(): number {
    return this.state.friendRequests.length;
  }

  /**
   * Set request state
   */
  setRequestState(requestId: string, state: RequestState): void {
    const request = this.state.friendRequests.find((r) => r.id === requestId);
    if (request) {
      request.state = state;
    }
  }

  /**
   * Clear completed/failed requests
   */
  clearRequests(): void {
    this.state.friendRequests = this.state.friendRequests.filter(
      (r) => r.state === 'pending' || r.state === 'sent'
    );
  }

  /**
   * Get request set (for pagination)
   */
  getRequestSet(setIndex: number, requestsInSet: number): FriendRequest[] {
    const startIndex = (setIndex - 1) * requestsInSet;
    const endIndex = Math.min(
      startIndex + requestsInSet,
      this.state.friendRequests.length
    );
    return this.state.friendRequests.slice(startIndex, endIndex);
  }

  /**
   * Set friend request update required flag
   */
  setFriendRequestUpdateRequired(required: boolean): void {
    this.state.friendRequestUpdateRequired = required;
  }

  /**
   * Get friend request update required flag
   */
  getFriendRequestUpdateRequired(): boolean {
    return this.state.friendRequestUpdateRequired;
  }

  /**
   * Set message update required flag
   */
  setMessageUpdateRequired(required: boolean): void {
    this.state.messageUpdateRequired = required;
  }

  /**
   * Get message update required flag
   */
  getMessageUpdateRequired(): boolean {
    return this.state.messageUpdateRequired;
  }

  // ============== Buddy List Limits ==============

  /**
   * Set buddy list limits
   */
  setBuddyListLimits(own: number, normal: number, club: number): void {
    this.buddyListLimits = { own, normal, club };
  }

  /**
   * Get buddy list limits
   */
  getBuddyListLimits(): BuddyListLimits {
    return this.buddyListLimits;
  }

  // ============== Pause/Resume ==============

  /**
   * Pause messenger updates
   */
  pause(): void {
    this.paused = true;
  }

  /**
   * Resume messenger updates
   */
  resume(): void {
    this.paused = false;
  }

  /**
   * Check if paused
   */
  isPaused(): boolean {
    return this.paused;
  }
}

// Singleton instance
let messengerComponent: MessengerComponent | null = null;

export function getMessengerComponent(): MessengerComponent {
  if (!messengerComponent) {
    messengerComponent = new MessengerComponent();
  }
  return messengerComponent;
}

export function resetMessengerComponent(): void {
  if (messengerComponent) {
    messengerComponent.reset();
  }
  messengerComponent = null;
}
