/**
 * Instant Messenger Component Class - Business logic for IM
 *
 * Ported from: hh_instant_messenger/Cast External ParentScript 4 - Instant Messenger Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { session } from '../../core/Session';
import { FriendData } from '../friend_list/types';
import { ChatEntry, ChatData, IMErrorCode, IMNotificationType } from './types';
import { InstantMessengerInterface } from './InstantMessengerInterface';

export class InstantMessengerComponent extends BaseObject {
  private chats: Map<string, ChatData> = new Map();
  private friends: Map<string, FriendData> = new Map();
  private userId: number = 0;
  private showModNotification: boolean = true;
  private invitees: number[] = [];

  construct(): void {
    super.construct();

    registerMessage('userlogin', this.id, 'setUserId');
    registerMessage('startIMChat', this.id, 'startIMChat');
    registerMessage('friendDataUpdated', this.id, 'updateChat');
  }

  deconstruct(): void {
    unregisterMessage('startIMChat', this.id);
    super.deconstruct();
  }

  /**
   * Set user ID after login
   */
  setUserId(): void {
    this.userId = session.GET<number>('user_user_id') ?? 0;
  }

  /**
   * Start a chat with a user
   */
  startIMChat(receiverName: string, text?: string): void {
    // Get friend data from friend list component
    const friendData = this.getFriendByName(receiverName);
    if (!friendData) return;

    const receiverId = friendData.id;
    if (!receiverId) return;

    this.addChat(String(receiverId), true);

    if (text && text !== '') {
      this.sendMessage(String(receiverId), text);
    }

    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.activateChat(String(receiverId));
      iface.openIMWindow();
    }

    this.updateChat(String(receiverId));
  }

  /**
   * Invite friends
   */
  inviteFriends(idList: number[]): void {
    if (!Array.isArray(idList)) return;

    this.invitees = idList;
    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.showInvitationWindow(this.invitees.length);
    }
  }

  /**
   * Send invitation
   */
  sendInvitation(invitationText: string): boolean {
    if (this.invitees.length === 0) return false;

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    conn.send('FRIEND_INVITE', {
      integers: [this.invitees.length, ...this.invitees],
      string: invitationText,
    });

    return true;
  }

  /**
   * Add a chat
   */
  addChat(chatId: string, dontPlaySound: boolean = false): boolean {
    if (this.chats.has(chatId)) {
      return false;
    }

    const friend = this.updateFriend(chatId);
    if (!friend) return false;

    this.friends.set(chatId, friend);
    this.chats.set(chatId, []);

    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.addChat(chatId, friend, dontPlaySound);
    }

    if (this.showModNotification) {
      this.receiveNotification(chatId, 'moderation');
      this.showModNotification = false;
    }

    return true;
  }

  /**
   * Update a chat
   */
  updateChat(chatId: string): void {
    if (!chatId) return;
    if (!this.chats.has(chatId)) return;

    const friend = this.friends.get(chatId);
    if (!friend) return;

    const wasOnline = friend.online;
    const friendUpdated = this.updateFriend(chatId);
    if (!friendUpdated) return;

    const isOnlineNow = friendUpdated.online;
    if (isOnlineNow !== wasOnline) {
      if (isOnlineNow) {
        this.receiveNotification(chatId, 'online');
      } else {
        this.receiveNotification(chatId, 'offline');
      }
    }

    this.friends.set(chatId, friendUpdated);

    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.updateInterface();
    }
  }

  /**
   * Remove a chat
   */
  removeChat(chatId: string): boolean {
    if (!this.chats.has(chatId)) {
      return false;
    }

    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.removeChat(chatId);
    }

    return true;
  }

  /**
   * Remove all chats
   */
  removeAllChats(): void {
    this.chats.clear();
    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.removeAllChats();
    }
  }

  /**
   * Get chat data
   */
  getChat(chatId: string): ChatData | null {
    let chat = this.chats.get(chatId);
    if (!chat) {
      if (!this.addChat(chatId)) {
        return null;
      }
      chat = this.chats.get(chatId);
    }
    return chat ?? null;
  }

  /**
   * Receive a message
   */
  receiveMessage(senderId: string, text: string): void {
    const entry: ChatEntry = {
      type: 'message',
      userID: senderId,
      Msg: text,
      time: new Date().toLocaleTimeString(),
    };
    this.addMessage(senderId, entry);
  }

  /**
   * Receive an error
   */
  receiveError(chatId: string, errorType: number): void {
    let textKey: string;
    switch (errorType) {
      case IMErrorCode.RECEIVER_MUTED:
        textKey = 'Receiver is muted';
        break;
      case IMErrorCode.SENDER_MUTED:
        textKey = 'You are muted';
        break;
      case IMErrorCode.OFFLINE:
        textKey = 'User is offline';
        break;
      case IMErrorCode.NOT_FRIEND:
        textKey = 'User is not your friend';
        break;
      case IMErrorCode.BUSY:
        textKey = 'User is busy';
        break;
      default:
        textKey = 'Unknown error';
    }

    const entry: ChatEntry = {
      type: 'error',
      Msg: textKey,
      time: new Date().toLocaleTimeString(),
    };
    this.addMessage(chatId, entry);
  }

  /**
   * Receive a notification
   */
  receiveNotification(chatId: string, notificationType: IMNotificationType): void {
    let msg: string;
    switch (notificationType) {
      case 'moderation':
        msg = 'Remember: Never share personal information.';
        break;
      case 'online':
        msg = 'User is now online.';
        break;
      case 'offline':
        msg = 'User is now offline.';
        break;
      default:
        msg = 'Notification';
    }

    const entry: ChatEntry = {
      type: 'notification',
      Msg: msg,
      time: new Date().toLocaleTimeString(),
    };
    this.addMessage(chatId, entry);
  }

  /**
   * Receive an invitation
   */
  receiveInvitation(chatId: string, text: string): void {
    const entry: ChatEntry = {
      type: 'invitation',
      userID: chatId,
      Msg: `You have been invited:\n\n${text}`,
      time: new Date().toLocaleTimeString(),
    };
    this.addMessage(chatId, entry);
  }

  /**
   * Send a message
   */
  sendMessage(receiverId: string, text: string): boolean {
    if (!receiverId) return false;

    // Add to local chat
    const entry: ChatEntry = {
      type: 'message',
      userID: this.userId,
      Msg: text,
      time: new Date().toLocaleTimeString(),
    };
    this.addMessage(receiverId, entry);

    // Send to server
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    conn.send('MESSENGER_SENDMSG', {
      integer: parseInt(receiverId),
      string: text,
    });

    return true;
  }

  /**
   * Add a message to a chat
   */
  addMessage(chatId: string, entry: ChatEntry): void {
    let chat = this.getChat(chatId);
    if (!chat) return;

    chat.push(entry);

    const iface = this.getInterface() as InstantMessengerInterface | null;
    if (iface) {
      iface.addMessage(chatId, entry);
    }
  }

  /**
   * Update friend data from friend list
   */
  private updateFriend(userId: string): FriendData | null {
    // This would call friend list component
    executeMessage('getFriendByID', parseInt(userId));
    return null; // TODO: Integrate with friend list module
  }

  /**
   * Get friend by name from friend list
   */
  private getFriendByName(name: string): FriendData | null {
    // This would call friend list component
    executeMessage('getFriendByName', name);
    return null; // TODO: Integrate with friend list module
  }

  /**
   * Get friend data
   */
  getFriend(userId: string): FriendData | null {
    return this.friends.get(userId) ?? null;
  }

  /**
   * Get user ID
   */
  getUserId(): number {
    return this.userId;
  }

  /**
   * Get all chat IDs
   */
  getChatIds(): string[] {
    return Array.from(this.chats.keys());
  }

  /**
   * Check if chat exists
   */
  hasChat(chatId: string): boolean {
    return this.chats.has(chatId);
  }
}
