/**
 * Messenger Handler Class
 *
 * Handles server messages for the messenger system.
 * Ported from hh_messenger Cast External ParentScript 5.
 */

import {
  MESSENGER_MESSAGE_IDS,
  MESSENGER_COMMANDS,
  BuddyData,
  FriendRequest,
  MessageData,
  FollowFailureType,
  InvitationData,
} from './types';
import { getMessengerComponent } from './MessengerComponent';

type MessageHandler = (data: DataView, offset: number) => number;

export class MessengerHandler {
  private handlers: Map<number, MessageHandler>;
  private sendMessage: (msgId: number, data?: ArrayBuffer | string) => void;
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor(sendMessage: (msgId: number, data?: ArrayBuffer | string) => void) {
    this.sendMessage = sendMessage;
    this.handlers = new Map();
    this.registerHandlers();
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
   * Register all message handlers
   */
  private registerHandlers(): void {
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.MESSENGER_INIT,
      this.handleMessengerInit.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.BUDDYLIST,
      this.handleBuddyList.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.CONSOLE_UPDATE,
      this.handleConsoleUpdate.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.MEMBERINFO,
      this.handleMemberInfo.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.BUDDY_REQUEST,
      this.handleBuddyRequest.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.BUDDY_REQUEST_LIST,
      this.handleBuddyRequestList.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.BUDDY_REQUEST_RESULT,
      this.handleBuddyRequestResult.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.ADD_BUDDY,
      this.handleAddBuddy.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.REMOVE_BUDDY,
      this.handleRemoveBuddy.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.MY_PERSISTENT_MESSAGE,
      this.handleMyPersistentMessage.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.MESSENGER_MESSAGES,
      this.handleMessengerMessages.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.MESSENGER_ERROR,
      this.handleMessengerError.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.FOLLOW_FAILED,
      this.handleFollowFailed.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.INVITATION,
      this.handleInvitation.bind(this)
    );
    this.handlers.set(
      MESSENGER_MESSAGE_IDS.INVITATION_EXPIRED,
      this.handleInvitationExpired.bind(this)
    );
  }

  /**
   * Handle incoming message
   */
  handleMessage(msgId: number, data: DataView): boolean {
    const handler = this.handlers.get(msgId);
    if (handler) {
      handler(data, 0);
      return true;
    }
    return false;
  }

  // ============== Message Handlers ==============

  /**
   * Handle messenger initialization
   */
  private handleMessengerInit(data: DataView, offset: number): number {
    const component = getMessengerComponent();

    // Parse buddy list
    const buddyData = this.parseBuddyList(data, offset);
    component.receiveBuddyList(buddyData.buddies);

    // Request messages and friend requests
    this.sendAskForMessages();
    this.sendAskForFriendRequests();

    component.setReady(true);
    this.emit('messenger_ready', null);

    return buddyData.newOffset;
  }

  /**
   * Handle buddy list message
   */
  private handleBuddyList(data: DataView, offset: number): number {
    const component = getMessengerComponent();
    const result = this.parseBuddyList(data, offset);
    component.receiveBuddyList(result.buddies);
    return result.newOffset;
  }

  /**
   * Handle console update
   */
  private handleConsoleUpdate(data: DataView, offset: number): number {
    // Parse buddy updates
    const loopCount = data.getInt32(offset, false);
    offset += 4;

    const updates: BuddyData[] = [];
    for (let i = 0; i < loopCount; i++) {
      const result = this.parseBuddyInfo(data, offset);
      if (result.buddy) {
        updates.push(result.buddy);
      }
      offset = result.newOffset;
    }

    getMessengerComponent().updateBuddyList(updates);
    return offset;
  }

  /**
   * Handle member info (user search result)
   */
  private handleMemberInfo(data: DataView, offset: number): number {
    const searchId = this.readString(data, offset);
    offset = searchId.newOffset;

    if (searchId.value !== 'MESSENGER') {
      return offset;
    }

    const result = this.parseUserInfo(data, offset);
    if (result.buddy) {
      this.emit('user_found', result.buddy);
    } else {
      this.emit('user_not_found', null);
    }

    return result.newOffset;
  }

  /**
   * Handle single buddy request
   */
  private handleBuddyRequest(data: DataView, offset: number): number {
    const result = this.parseBuddyRequest(data, offset);
    getMessengerComponent().receiveFriendRequests([result.request]);
    return result.newOffset;
  }

  /**
   * Handle buddy request list
   */
  private handleBuddyRequestList(data: DataView, offset: number): number {
    const totalRequests = data.getInt32(offset, false);
    offset += 4;
    const requestCount = data.getInt32(offset, false);
    offset += 4;

    const requests: FriendRequest[] = [];
    for (let i = 0; i < requestCount; i++) {
      const result = this.parseBuddyRequest(data, offset);
      requests.push(result.request);
      offset = result.newOffset;
    }

    const component = getMessengerComponent();
    component.setFriendRequestUpdateRequired(totalRequests > requestCount);
    component.receiveFriendRequests(requests);

    return offset;
  }

  /**
   * Handle buddy request result
   */
  private handleBuddyRequestResult(data: DataView, offset: number): number {
    const failureCount = data.getInt32(offset, false);
    offset += 4;

    const errors: Map<string, number> = new Map();
    for (let i = 0; i < failureCount; i++) {
      const name = this.readString(data, offset);
      offset = name.newOffset;
      const errorCode = data.getInt32(offset, false);
      offset += 4;
      errors.set(name.value, errorCode);
    }

    this.emit('friend_request_result', { errors, failureCount });
    return offset;
  }

  /**
   * Handle add buddy
   */
  private handleAddBuddy(data: DataView, offset: number): number {
    const result = this.parseUserInfo(data, offset);
    if (result.buddy) {
      getMessengerComponent().appendBuddy(result.buddy);
    }
    return result.newOffset;
  }

  /**
   * Handle remove buddy
   */
  private handleRemoveBuddy(data: DataView, offset: number): number {
    const count = data.getInt32(offset, false);
    offset += 4;

    const buddyIds: string[] = [];
    for (let i = 0; i < count; i++) {
      const id = data.getInt32(offset, false);
      offset += 4;
      buddyIds.push(String(id));
    }

    getMessengerComponent().removeBuddies(buddyIds);
    return offset;
  }

  /**
   * Handle persistent message update
   */
  private handleMyPersistentMessage(data: DataView, offset: number): number {
    const msg = this.readString(data, offset);
    getMessengerComponent().setPersistentMessage(msg.value);
    return msg.newOffset;
  }

  /**
   * Handle messenger messages
   */
  private handleMessengerMessages(data: DataView, offset: number): number {
    const totalMessages = data.getInt32(offset, false);
    offset += 4;
    const messageCount = data.getInt32(offset, false);
    offset += 4;

    const component = getMessengerComponent();
    component.setMessageUpdateRequired(totalMessages > messageCount);

    for (let i = 0; i < messageCount; i++) {
      const result = this.parseConsoleMessage(data, offset);
      if (result.message) {
        component.receiveMessage(result.message);
      }
      offset = result.newOffset;
    }

    return offset;
  }

  /**
   * Handle messenger error
   */
  private handleMessengerError(data: DataView, offset: number): number {
    const clientMessageId = data.getInt32(offset, false);
    offset += 4;
    const errorCode = data.getInt32(offset, false);
    offset += 4;

    this.emit('messenger_error', { clientMessageId, errorCode });
    return offset;
  }

  /**
   * Handle follow failed
   */
  private handleFollowFailed(data: DataView, offset: number): number {
    const failureType = data.getInt32(offset, false) as FollowFailureType;
    offset += 4;

    this.emit('follow_failed', { failureType });
    return offset;
  }

  /**
   * Handle invitation
   */
  private handleInvitation(data: DataView, offset: number): number {
    const userId = this.readString(data, offset);
    offset = userId.newOffset;
    const name = this.readString(data, offset);
    offset = name.newOffset;

    const invitation: InvitationData = {
      userId: userId.value,
      name: name.value,
    };

    this.emit('invitation', invitation);
    return offset;
  }

  /**
   * Handle invitation expired
   */
  private handleInvitationExpired(_data: DataView, offset: number): number {
    this.emit('invitation_expired', null);
    return offset;
  }

  // ============== Parsing Helpers ==============

  /**
   * Parse buddy list from data
   */
  private parseBuddyList(
    data: DataView,
    offset: number
  ): { buddies: Map<string, BuddyData>; newOffset: number } {
    const buddies = new Map<string, BuddyData>();
    const count = data.getInt32(offset, false);
    offset += 4;

    for (let i = 0; i < count; i++) {
      const result = this.parseUserInfo(data, offset);
      if (result.buddy) {
        buddies.set(result.buddy.id, result.buddy);
      }
      offset = result.newOffset;
    }

    return { buddies, newOffset: offset };
  }

  /**
   * Parse user info from data
   */
  private parseUserInfo(
    data: DataView,
    offset: number
  ): { buddy: BuddyData | null; newOffset: number } {
    const id = data.getInt32(offset, false);
    offset += 4;

    if (id === 0) {
      return { buddy: null, newOffset: offset };
    }

    const name = this.readString(data, offset);
    offset = name.newOffset;

    const gender = data.getInt32(offset, false);
    offset += 4;

    const customText = this.readString(data, offset);
    offset = customText.newOffset;

    const online = data.getInt32(offset, false) !== 0;
    offset += 4;

    const canFollow = data.getInt32(offset, false) !== 0;
    offset += 4;

    const lastAccess = this.readString(data, offset);
    offset = lastAccess.newOffset;

    const figureData = this.readString(data, offset);
    offset = figureData.newOffset;

    const categoryId = data.getInt32(offset, false);
    offset += 4;

    const buddy: BuddyData = {
      id: String(id),
      name: name.value,
      sex: gender === 0 ? 'F' : 'M',
      customText: customText.value,
      online,
      canFollow,
      location: '',
      lastAccess: lastAccess.value,
      figureData: figureData.value,
      msgs: 0,
      update: true,
      category: categoryId,
    };

    return { buddy, newOffset: offset };
  }

  /**
   * Parse buddy info (for updates)
   */
  private parseBuddyInfo(
    data: DataView,
    offset: number
  ): { buddy: BuddyData | null; newOffset: number } {
    const id = data.getInt32(offset, false);
    offset += 4;

    const name = this.readString(data, offset);
    offset = name.newOffset;

    const gender = data.getInt32(offset, false);
    offset += 4;

    const _null = this.readString(data, offset);
    offset = _null.newOffset;

    const online = data.getInt8(offset) !== 0;
    offset += 1;

    const canFollow = data.getInt32(offset, false) !== 0;
    offset += 4;

    const lastAccess = this.readString(data, offset);
    offset = lastAccess.newOffset;

    const figure = this.readString(data, offset);
    offset = figure.newOffset;

    const category = data.getInt32(offset, false);
    offset += 4;

    const buddy: BuddyData = {
      id: String(id),
      name: name.value,
      sex: gender === 0 ? 'F' : 'M',
      customText: '',
      online,
      canFollow,
      location: '',
      lastAccess: lastAccess.value,
      figureData: figure.value,
      msgs: 0,
      update: true,
      category,
    };

    return { buddy, newOffset: offset };
  }

  /**
   * Parse console message
   */
  private parseConsoleMessage(
    data: DataView,
    offset: number
  ): { message: MessageData | null; newOffset: number } {
    const id = data.getInt32(offset, false);
    offset += 4;

    const senderId = data.getInt32(offset, false);
    offset += 4;

    const time = this.readString(data, offset);
    offset = time.newOffset;

    const message = this.readString(data, offset);
    offset = message.newOffset;

    const msg: MessageData = {
      id: String(id),
      senderId: String(senderId),
      time: time.value,
      message: message.value,
    };

    return { message: msg, newOffset: offset };
  }

  /**
   * Parse buddy request
   */
  private parseBuddyRequest(
    data: DataView,
    offset: number
  ): { request: FriendRequest; newOffset: number } {
    const id = data.getInt32(offset, false);
    offset += 4;

    const name = this.readString(data, offset);
    offset = name.newOffset;

    const webId = this.readString(data, offset);
    offset = webId.newOffset;

    const request: FriendRequest = {
      id: String(id),
      name: name.value,
      webId: webId.value,
      state: 'pending',
    };

    return { request, newOffset: offset };
  }

  /**
   * Read string from data
   */
  private readString(
    data: DataView,
    offset: number
  ): { value: string; newOffset: number } {
    const length = data.getUint16(offset, false);
    offset += 2;

    const bytes = new Uint8Array(data.buffer, data.byteOffset + offset, length);
    const value = new TextDecoder().decode(bytes);
    offset += length;

    return { value, newOffset: offset };
  }

  // ============== Command Senders ==============

  /**
   * Initialize messenger
   */
  sendMessengerInit(): void {
    this.sendMessage(MESSENGER_COMMANDS.MESSENGERINIT);
  }

  /**
   * Request buddy list update
   */
  sendMessengerUpdate(): void {
    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_UPDATE);
  }

  /**
   * Send a message to buddies
   */
  sendMessage2(receiverIds: number[], message: string): void {
    const encoder = new TextEncoder();
    const msgBytes = encoder.encode(message);

    const buffer = new ArrayBuffer(4 + receiverIds.length * 4 + 2 + msgBytes.length);
    const view = new DataView(buffer);
    let offset = 0;

    // Receiver count
    view.setInt32(offset, receiverIds.length, false);
    offset += 4;

    // Receiver IDs
    for (const id of receiverIds) {
      view.setInt32(offset, id, false);
      offset += 4;
    }

    // Message length and content
    view.setUint16(offset, msgBytes.length, false);
    offset += 2;
    new Uint8Array(buffer, offset).set(msgBytes);

    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_SENDMSG, buffer);
  }

  /**
   * Mark message as read
   */
  sendMarkRead(messageId: number, campaign: boolean = false): void {
    const buffer = new ArrayBuffer(4);
    const view = new DataView(buffer);
    view.setInt32(0, messageId, false);

    const cmd = campaign
      ? MESSENGER_COMMANDS.MESSENGER_C_READ
      : MESSENGER_COMMANDS.MESSENGER_MARKREAD;
    this.sendMessage(cmd, buffer);
  }

  /**
   * Set persistent message
   */
  sendAssignPersistentMessage(message: string): void {
    const encoder = new TextEncoder();
    const msgBytes = encoder.encode(message);

    const buffer = new ArrayBuffer(2 + msgBytes.length);
    const view = new DataView(buffer);
    view.setUint16(0, msgBytes.length, false);
    new Uint8Array(buffer, 2).set(msgBytes);

    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_ASSIGNPERSMSG, buffer);
  }

  /**
   * Accept buddy request
   */
  sendAcceptBuddy(requestIds: number[]): void {
    const buffer = new ArrayBuffer(4 + requestIds.length * 4);
    const view = new DataView(buffer);
    let offset = 0;

    view.setInt32(offset, requestIds.length, false);
    offset += 4;

    for (const id of requestIds) {
      view.setInt32(offset, id, false);
      offset += 4;
    }

    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_ACCEPTBUDDY, buffer);
  }

  /**
   * Decline buddy request
   */
  sendDeclineBuddy(requestIds: number[], declineAll: boolean = false): void {
    const buffer = new ArrayBuffer(4 + 4 + requestIds.length * 4);
    const view = new DataView(buffer);
    let offset = 0;

    view.setInt32(offset, declineAll ? 1 : 0, false);
    offset += 4;

    view.setInt32(offset, requestIds.length, false);
    offset += 4;

    for (const id of requestIds) {
      view.setInt32(offset, id, false);
      offset += 4;
    }

    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_DECLINEBUDDY, buffer);
  }

  /**
   * Request to be someone's buddy
   */
  sendRequestBuddy(buddyName: string): void {
    const encoder = new TextEncoder();
    const nameBytes = encoder.encode(buddyName);

    const buffer = new ArrayBuffer(2 + nameBytes.length);
    const view = new DataView(buffer);
    view.setUint16(0, nameBytes.length, false);
    new Uint8Array(buffer, 2).set(nameBytes);

    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_REQUESTBUDDY, buffer);
  }

  /**
   * Remove buddy
   */
  sendRemoveBuddy(buddyIds: number[]): void {
    const buffer = new ArrayBuffer(4 + buddyIds.length * 4);
    const view = new DataView(buffer);
    let offset = 0;

    view.setInt32(offset, buddyIds.length, false);
    offset += 4;

    for (const id of buddyIds) {
      view.setInt32(offset, id, false);
      offset += 4;
    }

    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_REMOVEBUDDY, buffer);
  }

  /**
   * Find user by name
   */
  sendFindUser(name: string): void {
    const encoder = new TextEncoder();
    const nameBytes = encoder.encode(name);
    const searchIdBytes = encoder.encode('MESSENGER');

    const buffer = new ArrayBuffer(
      2 + nameBytes.length + 2 + searchIdBytes.length
    );
    const view = new DataView(buffer);
    let offset = 0;

    view.setUint16(offset, nameBytes.length, false);
    offset += 2;
    new Uint8Array(buffer, offset, nameBytes.length).set(nameBytes);
    offset += nameBytes.length;

    view.setUint16(offset, searchIdBytes.length, false);
    offset += 2;
    new Uint8Array(buffer, offset, searchIdBytes.length).set(searchIdBytes);

    this.sendMessage(MESSENGER_COMMANDS.FINDUSER, buffer);
  }

  /**
   * Request messages
   */
  sendAskForMessages(): void {
    const buffer = new ArrayBuffer(4);
    const view = new DataView(buffer);
    view.setInt32(0, 1, false);
    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_GETMESSAGES, buffer);
  }

  /**
   * Request friend requests
   */
  sendAskForFriendRequests(): void {
    this.sendMessage(MESSENGER_COMMANDS.GET_BUDDY_REQUESTS);
  }

  /**
   * Report a message
   */
  sendReportMessage(messageId: number): void {
    const buffer = new ArrayBuffer(4);
    const view = new DataView(buffer);
    view.setInt32(0, messageId, false);
    this.sendMessage(MESSENGER_COMMANDS.MESSENGER_REPORTMESSAGE, buffer);
  }

  /**
   * Follow a friend
   */
  sendFollowFriend(buddyId: number): void {
    const buffer = new ArrayBuffer(4);
    const view = new DataView(buffer);
    view.setInt32(0, buddyId, false);
    this.sendMessage(MESSENGER_COMMANDS.FOLLOW_FRIEND, buffer);
  }
}

// Singleton instance
let messengerHandler: MessengerHandler | null = null;

export function getMessengerHandler(
  sendMessage?: (msgId: number, data?: ArrayBuffer | string) => void
): MessengerHandler {
  if (!messengerHandler) {
    if (!sendMessage) {
      throw new Error('sendMessage function required for initial creation');
    }
    messengerHandler = new MessengerHandler(sendMessage);
  }
  return messengerHandler;
}

export function resetMessengerHandler(): void {
  messengerHandler = null;
}
