/**
 * Instant Messenger Interface Class - UI management for IM
 *
 * Ported from: hh_instant_messenger/Cast External ParentScript 3 - Instant Messenger Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { executeMessage } from '../../core/MessageBus';
import { getVariable } from '../../core/VariableContainer';
import { getConnection } from '../../managers/ConnectionManager';
import { session } from '../../core/Session';
import { FriendData } from '../friend_list/types';
import { ChatEntry, IMState, IMWindowView } from './types';
import { InstantMessengerComponent } from './InstantMessengerComponent';

export class InstantMessengerInterface extends BaseInterface {
  private pWindowId: string = 'im_window';
  private pInvitationWindowId: string = 'im_invitation_window';
  private pActiveChatId: string = '';
  private pNames: Map<string, string> = new Map();
  private pCachedChatIds: string[] = [];
  private pFollowFlashList: string[] = [];
  private pFollowFlashState: boolean = false;
  private pMinHeight: number = 200;
  private pBatchSize: number = 10;
  private pBatchInterval: number = 100;
  private pCacheSize: number = 5;
  private pState: IMState = 'Active';
  private pView: IMWindowView = 'normal';
  private pChatRenderers: Map<string, unknown> = new Map();

  construct(): void {
    super.construct();

    this.pMinHeight = getVariable('im.window.height.min', 200) as number;
    this.pBatchSize = getVariable('im.batch.size', 10) as number;
    this.pBatchInterval = getVariable('im.batch.interval', 100) as number;
    this.pCacheSize = getVariable('im.cached.chats', 5) as number;

    this.registerMsg('toggle_im', 'toggleIMWindow');
    this.registerMsg('gamesystem_constructed', 'closeIMWindow');

    this.setState('Active');
  }

  deconstruct(): void {
    this.removeTimeout('follow_flash');
    super.deconstruct();
  }

  /**
   * Create IM window
   *
   * Lingo: createWindow(pWindowID, "instant_message.window", locX, locY)
   */
  async createIMWindow(): Promise<void> {
    const marginRight = getVariable('im.window.margin.right', 300) as number;
    const marginTop = getVariable('im.window.margin.top', 100) as number;

    const locX = window.innerWidth - marginRight;
    const locY = marginTop;

    await this.createWindow(this.pWindowId, 'instant_message.window', locX, locY);
    this.registerWindowProcedure(this.pWindowId, 'eventProc');

    this.pView = 'normal';
  }

  /**
   * Open IM window
   *
   * Lingo: openIMWindow()
   */
  async openIMWindow(): Promise<void> {
    if (!this.windowExists(this.pWindowId)) {
      await this.createIMWindow();
    }

    this.showWindow(this.pWindowId);
    this.activateWindow(this.pWindowId);

    if (this.pChatRenderers.size === 0) {
      this.changeWindowView('empty');
    }

    this.updateInterface();
    this.setState('Active');
  }

  /**
   * Close IM window
   *
   * Lingo: closeIMWindow()
   */
  closeIMWindow(): void {
    if (this.windowExists(this.pWindowId)) {
      this.hideWindow(this.pWindowId);
    }
  }

  /**
   * Toggle IM window
   *
   * Lingo: toggleIMWindow()
   */
  async toggleIMWindow(): Promise<void> {
    if (this.windowExists(this.pWindowId)) {
      const wnd = this.getWindow(this.pWindowId);
      if (wnd?.getProperty('visible')) {
        this.closeIMWindow();
      } else {
        this.showWindow(this.pWindowId);
        this.activateWindow(this.pWindowId);
        this.setState('Active');
      }
    } else {
      await this.openIMWindow();
    }
  }

  /**
   * Add a chat
   *
   * Lingo: addChat(chatId, friend, dontPlaySound)
   */
  addChat(chatId: string, friend: FriendData, dontPlaySound: boolean = false): boolean {
    this.pChatRenderers.set(chatId, {});

    if (!dontPlaySound) {
      const soundName = getVariable('im.new.tab.sound', 'im_new') as string;
      executeMessage('playSound', soundName, { loopCount: 1 });
    }

    this.pNames.set(chatId, friend.name);

    // Add tab to window
    if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'tabs')) {
      this.setElementProperty(this.pWindowId, 'tabs', 'addTab', { id: chatId, name: friend.name });
    }

    if (this.pChatRenderers.size === 1) {
      this.activateChat(chatId);
    }

    this.updateInterface();
    return true;
  }

  /**
   * Remove a chat
   *
   * Lingo: removeChat(chatId)
   */
  removeChat(chatId: string): boolean {
    if (!this.pChatRenderers.has(chatId)) {
      return false;
    }

    this.pActiveChatId = '';
    this.pChatRenderers.delete(chatId);
    this.pNames.delete(chatId);

    // Remove tab from window
    if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'tabs')) {
      this.setElementProperty(this.pWindowId, 'tabs', 'removeTab', chatId);
    }

    const cacheIdx = this.pCachedChatIds.indexOf(chatId);
    if (cacheIdx !== -1) {
      this.pCachedChatIds.splice(cacheIdx, 1);
    }

    if (this.pChatRenderers.size === 0) {
      this.changeWindowView('empty');
      return true;
    }

    // Activate another chat
    const chatIds = Array.from(this.pChatRenderers.keys());
    if (chatIds.length > 0) {
      this.activateChat(chatIds[0]);
    }

    return true;
  }

  /**
   * Remove all chats
   *
   * Lingo: removeAllChats()
   */
  removeAllChats(): void {
    while (this.pChatRenderers.size > 0) {
      const chatId = Array.from(this.pChatRenderers.keys())[0];
      this.removeChat(chatId);
    }
    this.closeIMWindow();
  }

  /**
   * Activate a chat
   *
   * Lingo: activateChat(chatId)
   */
  activateChat(chatId: string): void {
    if (!chatId) return;

    if (chatId === '#left' || chatId === '#right') {
      // Scroll tabs
      if (this.elementExists(this.pWindowId, 'tabs')) {
        this.setElementProperty(this.pWindowId, 'tabs', 'scroll', chatId === '#left' ? -1 : 1);
      }
      return;
    }

    this.changeWindowView('normal');
    this.pActiveChatId = chatId;

    // Activate tab in UI
    if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'tabs')) {
      this.setElementProperty(this.pWindowId, 'tabs', 'activeTab', chatId);
    }

    // Update cache
    const cacheIdx = this.pCachedChatIds.indexOf(chatId);
    if (cacheIdx === -1) {
      if (this.pCachedChatIds.length >= this.pCacheSize) {
        this.pCachedChatIds.shift();
      }
      this.pCachedChatIds.push(chatId);
    } else {
      this.pCachedChatIds.splice(cacheIdx, 1);
      this.pCachedChatIds.push(chatId);
    }

    // Handle follow flash
    const flashIdx = this.pFollowFlashList.indexOf(chatId);
    if (flashIdx !== -1) {
      this.flashFollowButton('start');
      this.pFollowFlashList.splice(flashIdx, 1);
    } else {
      this.flashFollowButton('stop');
    }

    this.updateInterface();
  }

  /**
   * Flash follow button
   *
   * Lingo: flashFollowButton(action)
   */
  private flashFollowButton(action: 'start' | 'stop' | 'flash'): void {
    switch (action) {
      case 'start':
        this.removeTimeout('follow_flash');
        this.pFollowFlashState = false;
        this.doFollowFlash();
        break;
      case 'stop':
        this.removeTimeout('follow_flash');
        if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'button_follow')) {
          this.setElementProperty(this.pWindowId, 'button_follow', 'highlighted', false);
        }
        break;
      case 'flash':
        this.doFollowFlash();
        break;
    }
  }

  /**
   * Execute follow flash animation
   */
  private doFollowFlash(): void {
    this.pFollowFlashState = !this.pFollowFlashState;
    if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'button_follow')) {
      this.setElementProperty(this.pWindowId, 'button_follow', 'highlighted', this.pFollowFlashState);
    }
    this.createTimeout('follow_flash', 500, 'flashFollowButton', ['flash']);
  }

  /**
   * Add a message to the chat
   *
   * Lingo: addMessage(chatId, entry)
   */
  addMessage(chatId: string, entry: ChatEntry): void {
    if (!this.pChatRenderers.has(chatId)) {
      const component = this.getComponent() as InstantMessengerComponent | null;
      if (component) {
        component.addChat(chatId);
      }
    }

    // Add message to chat display
    if (this.windowExists(this.pWindowId) && chatId === this.pActiveChatId) {
      if (this.elementExists(this.pWindowId, 'chat_display')) {
        this.setElementProperty(this.pWindowId, 'chat_display', 'addMessage', entry);
      }
    }

    // Highlight tab for messages and invitations
    if (entry.type === 'message' || entry.type === 'invitation') {
      if (this.elementExists(this.pWindowId, 'tabs')) {
        this.setElementProperty(this.pWindowId, 'tabs', 'highlightTab', chatId);
      }
      this.setState('highlighted');
    }

    // Handle follow flash for invitations
    if (entry.type === 'invitation') {
      if (chatId === this.pActiveChatId) {
        this.flashFollowButton('start');
      } else {
        if (!this.pFollowFlashList.includes(chatId)) {
          this.pFollowFlashList.push(chatId);
        }
      }
    }

    this.updateInterface();
  }

  /**
   * Update interface
   *
   * Lingo: updateInterface()
   */
  updateInterface(): void {
    if (this.pView === 'empty') return;
    if (!this.pActiveChatId) return;
    if (!this.windowExists(this.pWindowId)) return;

    const component = this.getComponent() as InstantMessengerComponent | null;
    if (!component) return;

    const friend = component.getFriend(this.pActiveChatId);
    if (!friend) return;

    // Update name display
    if (this.elementExists(this.pWindowId, 'name_text')) {
      this.setText(this.pWindowId, 'name_text', this.pNames.get(this.pActiveChatId) ?? '');
    }

    // Update follow button state
    if (this.elementExists(this.pWindowId, 'button_follow')) {
      this.setElementProperty(this.pWindowId, 'button_follow', 'enabled', friend.canfollow);
    }
  }

  /**
   * Set state
   *
   * Lingo: setState(state)
   */
  setState(state: IMState): void {
    this.pState = state;
    executeMessage('IMStateChanged');
  }

  /**
   * Get state
   */
  getState(): IMState {
    return this.pState;
  }

  /**
   * Show invitation window
   *
   * Lingo: createWindow(pInvitationWindowID, "invitation.window", VOID, VOID, #modal)
   */
  async showInvitationWindow(count: number): Promise<void> {
    await this.createModalWindow(this.pInvitationWindowId, 'invitation.window');
    this.registerWindowProcedure(this.pInvitationWindowId, 'invitationEventProc');

    // Set invitation text
    if (this.elementExists(this.pInvitationWindowId, 'summary_text')) {
      this.setText(this.pInvitationWindowId, 'summary_text', `You are inviting ${count} friend(s).`);
    }
  }

  /**
   * Close invitation window
   *
   * Lingo: removeWindow(pInvitationWindowID)
   */
  closeInvitationWindow(): void {
    this.removeWindow(this.pInvitationWindowId);
  }

  /**
   * Send invitation
   *
   * Lingo: sendInvitation(text)
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
   *
   * Lingo: changeWindowView(view)
   */
  changeWindowView(view: IMWindowView): boolean {
    if (view === this.pView) return true;

    this.pView = view;

    if (!this.windowExists(this.pWindowId)) return true;

    // Show/hide appropriate elements based on view
    if (view === 'empty') {
      if (this.elementExists(this.pWindowId, 'chat_container')) {
        this.hideElement(this.pWindowId, 'chat_container');
      }
      if (this.elementExists(this.pWindowId, 'empty_message')) {
        this.showElement(this.pWindowId, 'empty_message');
      }
    } else {
      if (this.elementExists(this.pWindowId, 'chat_container')) {
        this.showElement(this.pWindowId, 'chat_container');
      }
      if (this.elementExists(this.pWindowId, 'empty_message')) {
        this.hideElement(this.pWindowId, 'empty_message');
      }
    }

    this.updateInterface();
    return true;
  }

  /**
   * Main window event procedure
   *
   * Lingo: eventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  override eventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    const component = this.getComponent() as InstantMessengerComponent | null;

    if (event === 'mouseUp') {
      switch (spriteId) {
        case 'close':
        case 'button_close_window':
          this.closeIMWindow();
          break;
        case 'button_close_chat':
          if (component) {
            component.removeChat(this.pActiveChatId);
          }
          break;
        case 'button_follow':
          const connId = getVariable('connection.info.id', 'Info') as string;
          const conn = getConnection(connId);
          if (conn) {
            conn.send('FOLLOW_FRIEND', { integer: parseInt(this.pActiveChatId) });
          }
          break;
        case 'button_minimail':
          executeMessage('openMailCompose', { recipientId: this.pActiveChatId });
          break;
        default:
          // Handle tab clicks
          if (spriteId.startsWith('tab_')) {
            const chatId = spriteId.replace('tab_', '');
            this.activateChat(chatId);
          }
          break;
      }
    } else if (event === 'submit' && spriteId === 'chat_input') {
      if (typeof param === 'string' && param !== '') {
        if (component) {
          component.sendMessage(this.pActiveChatId, param);
        }
      }
    }
  }

  /**
   * Invitation window event procedure
   *
   * Lingo: invitationEventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  invitationEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'button_send':
        // Get text from input
        const text = this.getText(this.pInvitationWindowId, 'invitation_input');
        this.sendInvitation(text);
        break;
      case 'button_cancel':
      case 'close':
        this.closeInvitationWindow();
        break;
    }
  }

  /**
   * Get active chat ID
   */
  getActiveChatId(): string {
    return this.pActiveChatId;
  }

  /**
   * Get current view
   */
  getView(): IMWindowView {
    return this.pView;
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }
}
