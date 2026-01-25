/**
 * Instant Messenger Interface Class - UI management for IM
 *
 * Ported from: hh_instant_messenger/Cast External ParentScript 3 - Instant Messenger Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getVariable } from '../../core/VariableContainer';
import { getConnection } from '../../managers/ConnectionManager';
import { session } from '../../core/Session';
import { EventEmitter } from '../../core/events';
import { FriendData } from '../friend_list/types';
import { ChatEntry, IMState, IMWindowView } from './types';
import { InstantMessengerComponent } from './InstantMessengerComponent';

export class InstantMessengerInterface extends BaseObject {
  private windowId: string = 'Instant Messenger';
  private invitationWindowId: string = 'Friend Invitation Window';
  private activeChatId: string = '';
  private names: Map<string, string> = new Map();
  private cachedChatIds: string[] = [];
  private followFlashList: string[] = [];
  private followFlashState: boolean = false;
  private followFlashInterval: ReturnType<typeof setInterval> | null = null;
  private minHeight: number = 200;
  private batchSize: number = 10;
  private batchInterval: number = 100;
  private cacheSize: number = 5;
  private state: IMState = 'Active';
  private view: IMWindowView = 'normal';
  private events: EventEmitter = new EventEmitter();
  private chatRenderers: Map<string, unknown> = new Map();
  private tabsObj: unknown = null;

  construct(): void {
    super.construct();

    this.minHeight = getVariable('im.window.height.min', 200) as number;
    this.batchSize = getVariable('im.batch.size', 10) as number;
    this.batchInterval = getVariable('im.batch.interval', 100) as number;
    this.cacheSize = getVariable('im.cached.chats', 5) as number;

    registerMessage('toggle_im', this.id, 'toggleIMWindow');
    registerMessage('gamesystem_constructed', this.id, 'closeIMWindow');

    this.setState('Active');
  }

  deconstruct(): void {
    if (this.followFlashInterval) {
      clearInterval(this.followFlashInterval);
      this.followFlashInterval = null;
    }

    unregisterMessage('toggle_im', this.id);
    unregisterMessage('gamesystem_constructed', this.id);

    super.deconstruct();
  }

  /**
   * Create IM window
   */
  createIMWindow(): void {
    const marginRight = getVariable('im.window.margin.right', 300) as number;
    const marginTop = getVariable('im.window.margin.top', 100) as number;

    this.events.emit('createWindow', {
      id: this.windowId,
      template: 'instant_message.window',
      x: window.innerWidth - marginRight,
      y: marginTop,
    });

    this.view = 'normal';
  }

  /**
   * Open IM window
   */
  openIMWindow(): void {
    this.events.emit('showWindow', { id: this.windowId });

    if (this.chatRenderers.size === 0) {
      this.changeWindowView('empty');
    }

    this.updateInterface();
    this.setState('Active');
  }

  /**
   * Close IM window
   */
  closeIMWindow(): void {
    this.events.emit('hideWindow', { id: this.windowId });
  }

  /**
   * Toggle IM window
   */
  toggleIMWindow(): void {
    this.events.emit('toggleWindow', { id: this.windowId });
  }

  /**
   * Add a chat
   */
  addChat(chatId: string, friend: FriendData, dontPlaySound: boolean = false): boolean {
    this.chatRenderers.set(chatId, {});

    if (!dontPlaySound) {
      const soundName = getVariable('im.new.tab.sound', 'im_new') as string;
      executeMessage('playSound', soundName, { loopCount: 1 });
    }

    this.names.set(chatId, friend.name);

    if (this.chatRenderers.size === 1) {
      this.activateChat(chatId);
    }

    this.updateInterface();
    return true;
  }

  /**
   * Remove a chat
   */
  removeChat(chatId: string): boolean {
    if (!this.chatRenderers.has(chatId)) {
      return false;
    }

    this.activeChatId = '';
    this.chatRenderers.delete(chatId);
    this.names.delete(chatId);

    const cacheIdx = this.cachedChatIds.indexOf(chatId);
    if (cacheIdx !== -1) {
      this.cachedChatIds.splice(cacheIdx, 1);
    }

    if (this.chatRenderers.size === 0) {
      this.changeWindowView('empty');
      return true;
    }

    // Activate another chat
    const chatIds = Array.from(this.chatRenderers.keys());
    if (chatIds.length > 0) {
      this.activateChat(chatIds[0]);
    }

    return true;
  }

  /**
   * Remove all chats
   */
  removeAllChats(): void {
    while (this.chatRenderers.size > 0) {
      const chatId = Array.from(this.chatRenderers.keys())[0];
      this.removeChat(chatId);
    }
    this.closeIMWindow();
  }

  /**
   * Activate a chat
   */
  activateChat(chatId: string): void {
    if (!chatId) return;

    if (chatId === '#left' || chatId === '#right') {
      this.events.emit('scrollTabs', { direction: chatId === '#left' ? 'left' : 'right' });
      return;
    }

    this.changeWindowView('normal');
    this.activeChatId = chatId;

    this.events.emit('activateTab', { chatId });

    // Update cache
    const cacheIdx = this.cachedChatIds.indexOf(chatId);
    if (cacheIdx === -1) {
      if (this.cachedChatIds.length >= this.cacheSize) {
        this.cachedChatIds.shift();
      }
      this.cachedChatIds.push(chatId);
    } else {
      this.cachedChatIds.splice(cacheIdx, 1);
      this.cachedChatIds.push(chatId);
    }

    // Handle follow flash
    const flashIdx = this.followFlashList.indexOf(chatId);
    if (flashIdx !== -1) {
      this.flashFollowButton('start');
      this.followFlashList.splice(flashIdx, 1);
    } else {
      this.flashFollowButton('stop');
    }

    this.updateInterface();
  }

  /**
   * Flash follow button
   */
  private flashFollowButton(action: 'start' | 'stop' | 'flash'): void {
    switch (action) {
      case 'start':
        if (!this.followFlashInterval) {
          this.followFlashInterval = setInterval(() => this.flashFollowButton('flash'), 500);
        }
        this.followFlashState = false;
        break;
      case 'stop':
        if (this.followFlashInterval) {
          clearInterval(this.followFlashInterval);
          this.followFlashInterval = null;
        }
        this.events.emit('followButtonState', { highlighted: false });
        break;
      case 'flash':
        this.followFlashState = !this.followFlashState;
        this.events.emit('followButtonState', { highlighted: this.followFlashState });
        break;
    }
  }

  /**
   * Add a message to the chat
   */
  addMessage(chatId: string, entry: ChatEntry): void {
    if (!this.chatRenderers.has(chatId)) {
      const component = this.getComponent() as InstantMessengerComponent | null;
      if (component) {
        component.addChat(chatId);
      }
    }

    this.events.emit('addMessage', { chatId, entry });

    // Highlight tab for messages and invitations
    if (entry.type === 'message' || entry.type === 'invitation') {
      this.events.emit('highlightTab', { chatId });
      this.setState('highlighted');
    }

    // Handle follow flash for invitations
    if (entry.type === 'invitation') {
      if (chatId === this.activeChatId) {
        this.flashFollowButton('start');
      } else {
        if (!this.followFlashList.includes(chatId)) {
          this.followFlashList.push(chatId);
        }
      }
    }

    this.updateInterface();
  }

  /**
   * Update interface
   */
  updateInterface(): void {
    if (this.view === 'empty') return;
    if (!this.activeChatId) return;

    const component = this.getComponent() as InstantMessengerComponent | null;
    if (!component) return;

    const friend = component.getFriend(this.activeChatId);
    if (!friend) return;

    this.events.emit('updateInterface', {
      chatId: this.activeChatId,
      name: this.names.get(this.activeChatId),
      canFollow: friend.canfollow,
      figure: friend.figure,
      sex: friend.sex,
    });
  }

  /**
   * Set state
   */
  setState(state: IMState): void {
    this.state = state;
    executeMessage('IMStateChanged');
  }

  /**
   * Get state
   */
  getState(): IMState {
    return this.state;
  }

  /**
   * Show invitation window
   */
  showInvitationWindow(count: number): void {
    this.events.emit('showInvitationWindow', {
      id: this.invitationWindowId,
      count,
      summary: `You are inviting ${count} friend(s).`,
    });
  }

  /**
   * Close invitation window
   */
  closeInvitationWindow(): void {
    this.events.emit('closeWindow', { id: this.invitationWindowId });
  }

  /**
   * Send invitation
   */
  sendInvitation(text: string): void {
    const lastRoom = session.GET<string>('lastroom');
    if (lastRoom === 'Entry') {
      executeMessage('alert', 'Cannot send invitation from hotel view');
      return;
    }

    if (!text || text === '') {
      executeMessage('alert', 'Please enter an invitation message');
      return;
    }

    const component = this.getComponent() as InstantMessengerComponent | null;
    if (component) {
      component.sendInvitation(text);
    }

    this.closeInvitationWindow();
  }

  /**
   * Change window view
   */
  changeWindowView(view: IMWindowView): boolean {
    if (view === this.view) return true;

    this.view = view;
    this.events.emit('changeWindowView', { view });
    this.updateInterface();

    return true;
  }

  /**
   * Handle window event
   */
  handleWindowEvent(event: string, elementId: string, param?: unknown): void {
    const component = this.getComponent() as InstantMessengerComponent | null;

    switch (elementId) {
      case 'button.close.window':
        this.closeIMWindow();
        break;
      case 'button.close.chat':
        if (component) {
          component.removeChat(this.activeChatId);
        }
        break;
      case 'tabs':
        if (typeof param === 'string') {
          this.activateChat(param);
        }
        break;
      case 'button.follow':
        const connId = getVariable('connection.info.id', 'Info') as string;
        const conn = getConnection(connId);
        if (conn) {
          conn.send('FOLLOW_FRIEND', { integer: parseInt(this.activeChatId) });
        }
        break;
      case 'button.minimail':
        this.events.emit('openMailCompose', { recipientId: this.activeChatId });
        break;
      case 'chat.input':
        if (event === 'submit' && typeof param === 'string' && param !== '') {
          if (component) {
            component.sendMessage(this.activeChatId, param);
          }
        }
        break;
    }
  }

  /**
   * Handle invitation window event
   */
  handleInvitationEvent(event: string, elementId: string): void {
    switch (elementId) {
      case 'button.send':
        // The text would come from the input element
        break;
      case 'button.cancel':
      case 'button.close.window':
        this.closeInvitationWindow();
        break;
    }
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Get active chat ID
   */
  getActiveChatId(): string {
    return this.activeChatId;
  }

  /**
   * Get current view
   */
  getView(): IMWindowView {
    return this.view;
  }
}
