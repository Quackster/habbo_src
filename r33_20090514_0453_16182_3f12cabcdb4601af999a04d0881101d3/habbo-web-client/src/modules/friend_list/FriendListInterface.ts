/**
 * Friend List Interface Class - UI management for friend list
 *
 * Ported from: hh_friend_list/Cast External ParentScript 3 - Friend List Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getVariable, variableExists } from '../../core/VariableContainer';
import { getConnection } from '../../managers/ConnectionManager';
import { FriendData, FriendRequest, ListPanelEventData, CategoryIds } from './types';
import { FriendListComponent } from './FriendListComponent';

export interface FriendListViewObject {
  addFriend(friend: FriendData): void;
  updateFriend(friend: FriendData): void;
  removeFriend(friendId: number): void;
  addRequest(request: FriendRequest): void;
  setListData(data: unknown): void;
  getSelectedFriends(): FriendData[];
  getViewImage(): ImageData | null;
  needsRender(): boolean;
  resetRenderFlag(): void;
  renderListImage(): void;
  hasQueue(): boolean;
  update(element: unknown): void;
  cleanUp(): void;
  relayEvent(event: string, locX: number, locY: number): ListPanelEventData | null;
  handleAll(state: 'accepted' | 'rejected'): void;
}

export class FriendListInterface extends BaseInterface {
  private pWindowId: string = 'friendlist_window';
  private pRemoveConfirmId: string = 'friend_list_confirm_remove';
  private pConfirmDeleteFriend: FriendData | null = null;
  private pMaxCategories: number = 0;
  private pMaxFreeCategories: number = 5;
  private pWindowDefaultHeight: number = 400;
  private pCurrentCategoryId: string = '0';
  private pMinimized: boolean = false;
  private pViewsList: Map<string, FriendListViewObject> = new Map();
  private pHighlightedCategories: Set<string> = new Set();
  private pInboxBlinkStep: number = 0;

  construct(): void {
    super.construct();

    this.pRemoveConfirmId = 'friend_list_confirm_remove';
    this.pCurrentCategoryId = getVariable('fr.window.default.category.id', '0') as string;
    this.pMaxFreeCategories = getVariable('fr.window.max.free.categories', 5) as number;
    this.pMaxCategories = this.pMaxFreeCategories + 4;

    this.registerMsg('toggle_friend_list', 'toggleFriendList');
    this.registerMsg('enterRoom', 'updateActionIconsState');
    this.registerMsg('leaveRoom', 'updateActionIconsState');
    this.registerMsg('changeRoom', 'updateActionIconsState');
    this.registerMsg('enterRoomDirect', 'updateActionIconsState');
    this.registerMsg('gamesystem_constructed', 'closeFriendList');
  }

  deconstruct(): void {
    this.endInboxBlink();
    this.clearHighlightTimeouts();
    super.deconstruct();
  }

  /**
   * Clear all highlight timeouts
   */
  private clearHighlightTimeouts(): void {
    for (const categoryId of this.pHighlightedCategories) {
      this.removeTimeout(`highlight_${categoryId}`);
    }
    this.pHighlightedCategories.clear();
  }

  /**
   * Create friend list window
   *
   * Lingo: createWindow(pWindowID, "friends_list_base.window")
   */
  async createFriendList(): Promise<boolean> {
    const component = this.getComponent() as FriendListComponent | null;
    if (!component?.isFriendListInited()) {
      return false;
    }

    if (this.windowExists(this.pWindowId)) {
      return true;
    }

    const result = await this.createWindow(this.pWindowId, 'friends_list_base.window');
    if (!result) {
      return false;
    }

    // Register event handler
    this.registerWindowProcedure(this.pWindowId, 'eventProc');

    this.changeCategory(this.pCurrentCategoryId);
    return true;
  }

  /**
   * Open friend list
   *
   * Lingo: openFriendList()
   */
  async openFriendList(): Promise<void> {
    await this.createFriendList();
    if (this.windowExists(this.pWindowId)) {
      this.moveWindow(this.pWindowId, 15, 65);
      this.showWindow(this.pWindowId);
      this.activateWindow(this.pWindowId);
    }
  }

  /**
   * Close friend list
   *
   * Lingo: closeFriendList()
   */
  closeFriendList(): void {
    if (this.windowExists(this.pWindowId)) {
      this.hideWindow(this.pWindowId);
    }
  }

  /**
   * Toggle friend list visibility
   *
   * Lingo: toggleFriendList()
   */
  async toggleFriendList(): Promise<void> {
    if (this.windowExists(this.pWindowId)) {
      const wnd = this.getWindow(this.pWindowId);
      if (wnd?.getProperty('visible')) {
        this.closeFriendList();
      } else {
        this.showWindow(this.pWindowId);
        this.activateWindow(this.pWindowId);
      }
    } else {
      await this.openFriendList();
    }
  }

  /**
   * Toggle minimized view
   */
  minimizedView(minimized?: boolean): void {
    if (minimized === undefined) {
      this.pMinimized = !this.pMinimized;
    } else {
      this.pMinimized = minimized;
    }
    this.changeCategory(this.pCurrentCategoryId);
  }

  /**
   * Check if friend request view is open
   */
  isFriendRequestViewOpen(): boolean {
    return this.pCurrentCategoryId === CategoryIds.REQUESTS;
  }

  /**
   * Add a friend to the view
   */
  addFriend(friendData: FriendData, holdRender: boolean = false): void {
    if (!friendData) return;

    const categoryId = friendData.categoryId;
    const viewObj = this.getViewListObject(categoryId);
    if (!viewObj) return;

    viewObj.addFriend(friendData);
    this.setCategoryHighlight(categoryId);

    if (!holdRender && this.pCurrentCategoryId === categoryId) {
      this.updateOpenCategoryPanel();
    }
    this.updateCategoryCounts();
  }

  /**
   * Add a friend request
   */
  addFriendRequest(request: FriendRequest): void {
    const categoryId = CategoryIds.REQUESTS;
    const viewObj = this.getViewListObject(categoryId);
    if (!viewObj) return;

    viewObj.addRequest(request);
    this.setCategoryHighlight(categoryId);

    if (this.pCurrentCategoryId === categoryId) {
      this.updateOpenCategoryPanel();
    }
  }

  /**
   * Set category highlight
   */
  setCategoryHighlight(categoryId: string): void {
    const allowedCategories = getVariable('fr.category.highlights.allowed', ['-2']) as string[];

    if (allowedCategories.includes(categoryId) && (this.pCurrentCategoryId !== categoryId || this.pMinimized)) {
      this.pHighlightedCategories.add(categoryId);
      this.showCategoryTitle(categoryId);

      // Create timeout to remove highlight
      const duration = getVariable('fr.category.highlight.duration', 5000) as number;
      this.createTimeout(`highlight_${categoryId}`, duration, 'removeCategoryHighlight', [categoryId]);
    }
  }

  /**
   * Remove category highlight
   */
  removeCategoryHighlight(categoryId: string): void {
    if (this.pHighlightedCategories.delete(categoryId)) {
      this.showCategoryTitle(categoryId);
    }
    this.removeTimeout(`highlight_${categoryId}`);
  }

  /**
   * Update friend in view
   */
  updateFriend(friendData: FriendData, holdRender: boolean = false): void {
    if (!friendData) return;

    const viewObj = this.getViewListObject(friendData.categoryId);
    if (viewObj) {
      viewObj.updateFriend(friendData);
    }

    if (!holdRender && this.pCurrentCategoryId === friendData.categoryId) {
      this.updateOpenCategoryPanel();
    }
  }

  /**
   * Remove friend from view
   */
  removeFriend(friendId: number, category: string, holdRender: boolean = false): void {
    const viewObj = this.getViewListObject(category);
    if (viewObj) {
      viewObj.removeFriend(friendId);
    }

    if (!holdRender && this.pCurrentCategoryId === category) {
      this.updateOpenCategoryPanel();
    }
  }

  /**
   * Update category counts
   */
  updateCategoryCounts(): void {
    const component = this.getComponent() as FriendListComponent | null;
    if (!component) return;

    const categoryList = component.getCategoryList();
    for (const category of categoryList.values()) {
      const count = component.getItemCountForCategory(category.id);
      this.showCategoryTitle(category.id, undefined, undefined, count);
    }
  }

  /**
   * Change category
   */
  changeCategory(categoryId?: string): void {
    if (categoryId === undefined) {
      categoryId = this.pCurrentCategoryId;
    }

    this.removeCategoryHighlight(categoryId);
    this.pCurrentCategoryId = categoryId;
    this.updateOpenCategoryPanel();
    this.updateActionIconsState();

    if (!this.pMinimized && categoryId === CategoryIds.REQUESTS) {
      executeMessage('FriendRequestListOpened');
    }
  }

  /**
   * Update open category panel
   */
  updateOpenCategoryPanel(): void {
    if (!this.windowExists(this.pWindowId)) return;

    const viewObj = this.getViewListObject(this.pCurrentCategoryId);
    if (!viewObj) return;

    if (this.pCurrentCategoryId === CategoryIds.REQUESTS) {
      viewObj.cleanUp();
    }

    if (viewObj.needsRender()) {
      viewObj.resetRenderFlag();
      viewObj.renderListImage();
    }

    const listImage = viewObj.getViewImage();
    if (listImage && this.elementExists(this.pWindowId, 'list_panel')) {
      // Feed image to list panel element
      const canvas = document.createElement('canvas');
      canvas.width = listImage.width;
      canvas.height = listImage.height;
      const ctx = canvas.getContext('2d')!;
      ctx.putImageData(listImage, 0, 0);
      this.feedImage(this.pWindowId, 'list_panel', canvas);
    }

    this.updateActionIconsState();
  }

  /**
   * Show category title
   *
   * Lingo: showCategoryTitle(id, locV, name, itemCount)
   */
  showCategoryTitle(id: string, locV?: number, name?: string, itemCount?: number): void {
    if (!this.windowExists(this.pWindowId)) return;

    const component = this.getComponent() as FriendListComponent | null;
    if (!component) return;

    const highlighted = this.pHighlightedCategories.has(id);
    const categoryName = name ?? component.getCategoryName(id);
    const count = itemCount ?? component.getItemCountForCategory(id);

    // Update category element
    const elemId = `category_${id}`;
    if (this.elementExists(this.pWindowId, elemId)) {
      this.setText(this.pWindowId, elemId, `${categoryName} (${count})`);
      this.setElementProperty(this.pWindowId, elemId, 'highlighted', highlighted);
      if (locV !== undefined) {
        this.setElementProperty(this.pWindowId, elemId, 'locV', locV);
      }
    }
  }

  /**
   * Activate/deactivate mail icon
   *
   * Lingo: activateMailIcon(active)
   */
  activateMailIcon(active: boolean): void {
    if (!this.windowExists(this.pWindowId)) return;

    if (this.elementExists(this.pWindowId, 'mail_icon')) {
      this.setElementProperty(this.pWindowId, 'mail_icon', 'active', active);
    }
  }

  /**
   * Start inbox blink animation
   */
  startInboxBlink(): void {
    if (this.timeoutExists('inbox_blink')) return;

    const blink = (): void => {
      this.pInboxBlinkStep = this.pInboxBlinkStep > 0 ? 0 : 1;
      if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'mail_icon')) {
        this.setElementProperty(this.pWindowId, 'mail_icon', 'blink_step', this.pInboxBlinkStep);
      }
      this.createTimeout('inbox_blink', 1000, 'inboxBlinkTick');
    };

    blink();
  }

  /**
   * Inbox blink tick handler
   */
  private inboxBlinkTick(): void {
    this.pInboxBlinkStep = this.pInboxBlinkStep > 0 ? 0 : 1;
    if (this.windowExists(this.pWindowId) && this.elementExists(this.pWindowId, 'mail_icon')) {
      this.setElementProperty(this.pWindowId, 'mail_icon', 'blink_step', this.pInboxBlinkStep);
    }
    this.createTimeout('inbox_blink', 1000, 'inboxBlinkTick');
  }

  /**
   * End inbox blink animation
   */
  endInboxBlink(): void {
    this.removeTimeout('inbox_blink');
    this.activateMailIcon(false);
  }

  /**
   * Update action icons state
   */
  updateActionIconsState(): void {
    if (!this.windowExists(this.pWindowId)) return;

    const viewObj = this.getViewListObject(this.pCurrentCategoryId);
    if (!viewObj) return;

    const catIdNum = parseInt(this.pCurrentCategoryId);

    if (catIdNum >= -1) {
      const selectedFriends = viewObj.getSelectedFriends();
      const invitesInUse = variableExists('client.use.invites') && getVariable('client.use.invites') === 1;

      // Update action button states
      const hasSelection = selectedFriends.length > 0;
      if (this.elementExists(this.pWindowId, 'btn_im')) {
        this.setElementProperty(this.pWindowId, 'btn_im', 'enabled', hasSelection);
      }
      if (this.elementExists(this.pWindowId, 'btn_follow')) {
        this.setElementProperty(this.pWindowId, 'btn_follow', 'enabled', hasSelection);
      }
      if (this.elementExists(this.pWindowId, 'btn_invite')) {
        this.setElementProperty(this.pWindowId, 'btn_invite', 'visible', invitesInUse);
        this.setElementProperty(this.pWindowId, 'btn_invite', 'enabled', hasSelection);
      }
    } else if (catIdNum === -2) {
      const component = this.getComponent() as FriendListComponent | null;
      const requests = component?.getPendingFriendRequests();
      const count = requests?.size ?? 0;

      // Update request action buttons
      if (this.elementExists(this.pWindowId, 'btn_accept_all')) {
        this.setElementProperty(this.pWindowId, 'btn_accept_all', 'enabled', count > 0);
      }
      if (this.elementExists(this.pWindowId, 'btn_reject_all')) {
        this.setElementProperty(this.pWindowId, 'btn_reject_all', 'enabled', count > 0);
      }
    }
  }

  /**
   * Get or create view list object
   */
  getViewListObject(categoryId: string): FriendListViewObject | null {
    const catIdStr = String(categoryId);
    let viewObj = this.pViewsList.get(catIdStr);

    if (!viewObj) {
      viewObj = this.createListViewObject(catIdStr);
      if (!viewObj) return null;

      // Populate with data if not requests/search category
      const catIdNum = parseInt(catIdStr);
      if (catIdNum > -2) {
        const component = this.getComponent() as FriendListComponent | null;
        if (component) {
          const categoryContent = component.getFriendsInCategory(catIdStr);
          viewObj.setListData(categoryContent);
        }
      }

      this.pViewsList.set(catIdStr, viewObj);
    }

    return viewObj;
  }

  /**
   * Create list view object
   */
  createListViewObject(categoryId: string): FriendListViewObject {
    // Return a basic implementation - actual rendering would be done by UI layer
    return {
      addFriend: () => {},
      updateFriend: () => {},
      removeFriend: () => {},
      addRequest: () => {},
      setListData: () => {},
      getSelectedFriends: () => [],
      getViewImage: () => null,
      needsRender: () => false,
      resetRenderFlag: () => {},
      renderListImage: () => {},
      hasQueue: () => false,
      update: () => {},
      cleanUp: () => {},
      relayEvent: () => null,
      handleAll: () => {},
    };
  }

  /**
   * Show habbo search results
   */
  showHabboSearchResults(): void {
    const component = this.getComponent() as FriendListComponent | null;
    if (!component) return;

    const viewObj = this.getViewListObject(CategoryIds.SEARCH);
    if (viewObj) {
      viewObj.setListData(component.getHabboSearchResults());
    }

    this.updateOpenCategoryPanel();
    this.updateActionIconsState();
  }

  /**
   * Show confirm remove user dialog
   *
   * Lingo: createWindow(pRemoveConfirmID, "confirm_remove.window", VOID, VOID, #modal)
   */
  async showConfirmRemoveUser(friend: FriendData): Promise<void> {
    this.pConfirmDeleteFriend = friend;
    await this.createModalWindow(this.pRemoveConfirmId, 'confirm_remove.window');
    this.registerWindowProcedure(this.pRemoveConfirmId, 'confirmDialogEventProc');

    // Set text with friend name
    if (this.elementExists(this.pRemoveConfirmId, 'confirm_text')) {
      this.setText(this.pRemoveConfirmId, 'confirm_text', `Remove ${friend.name} from your friends?`);
    }
  }

  /**
   * Hide confirm remove user dialog
   */
  hideConfirmRemoveUser(): void {
    this.removeWindow(this.pRemoveConfirmId);
    this.pConfirmDeleteFriend = null;
  }

  /**
   * Confirm remove user
   */
  confirmRemoveUser(): void {
    if (this.pConfirmDeleteFriend) {
      const component = this.getComponent() as FriendListComponent | null;
      if (component) {
        component.sendRemoveFriend(this.pConfirmDeleteFriend.id);
      }
      this.hideConfirmRemoveUser();
    }
  }

  /**
   * Confirm dialog event procedure
   */
  confirmDialogEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'confirm_ok':
      case 'btn_ok':
        this.confirmRemoveUser();
        break;
      case 'confirm_cancel':
      case 'btn_cancel':
      case 'close':
        this.hideConfirmRemoveUser();
        break;
    }
  }

  /**
   * Handle list panel events
   */
  handleListPanelEvent(event: string, locX: number, locY: number): void {
    const viewObj = this.getViewListObject(this.pCurrentCategoryId);
    if (!viewObj) return;

    if (event === 'mouseLeave') {
      // Hide any info popup
      return;
    }

    const eventData = viewObj.relayEvent(event, locX, locY);
    if (!eventData) return;

    const friend = eventData.friend;
    const element = eventData.element;

    if (eventData.event === 'mouseWithin') {
      // Show info popup
      return;
    }

    // Handle click actions
    if (!element) return;

    const component = this.getComponent() as FriendListComponent | null;
    if (!component) return;

    switch (element) {
      case 'im':
        if (friend) {
          executeMessage('startIMChat', friend.name, '');
        }
        break;
      case 'follow':
        if (friend) {
          const connId = getVariable('connection.info.id', 'Info') as string;
          const conn = getConnection(connId);
          if (conn) {
            conn.send('FOLLOW_FRIEND', { integer: friend.id });
          }
        }
        break;
      case 'request_accept':
        if (eventData.request) {
          component.updateFriendRequest(eventData.request, 'accepted');
        }
        break;
      case 'request_reject':
        if (eventData.request) {
          component.updateFriendRequest(eventData.request, 'rejected');
        }
        break;
      case 'mail':
        if (friend) {
          executeMessage('openMailCompose', { recipientId: friend.id });
        }
        break;
      case 'addFriend':
        if (friend) {
          component.externalFriendRequest(friend.name);
        }
        break;
    }

    if (eventData.update) {
      this.updateOpenCategoryPanel();
    }
    this.updateActionIconsState();
  }

  /**
   * Main window event procedure
   *
   * Lingo: eventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  override eventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'close':
      case 'btn_close':
        this.closeFriendList();
        break;
      case 'btn_minimize':
        this.minimizedView();
        break;
      case 'btn_search':
        // Open search
        break;
      case 'btn_im':
        this.handleIMAction();
        break;
      case 'btn_follow':
        this.handleFollowAction();
        break;
      case 'btn_remove':
        this.handleRemoveAction();
        break;
      case 'btn_accept_all':
        this.handleAcceptAllRequests();
        break;
      case 'btn_reject_all':
        this.handleRejectAllRequests();
        break;
      default:
        // Check for category buttons
        if (spriteId.startsWith('category_')) {
          const categoryId = spriteId.replace('category_', '');
          this.changeCategory(categoryId);
        }
        break;
    }
  }

  /**
   * Handle IM action
   */
  private handleIMAction(): void {
    const viewObj = this.getViewListObject(this.pCurrentCategoryId);
    if (!viewObj) return;

    const selectedFriends = viewObj.getSelectedFriends();
    if (selectedFriends.length > 0) {
      executeMessage('startIMChat', selectedFriends[0].name, '');
    }
  }

  /**
   * Handle follow action
   */
  private handleFollowAction(): void {
    const viewObj = this.getViewListObject(this.pCurrentCategoryId);
    if (!viewObj) return;

    const selectedFriends = viewObj.getSelectedFriends();
    if (selectedFriends.length > 0) {
      const connId = getVariable('connection.info.id', 'Info') as string;
      const conn = getConnection(connId);
      if (conn) {
        conn.send('FOLLOW_FRIEND', { integer: selectedFriends[0].id });
      }
    }
  }

  /**
   * Handle remove action
   */
  private handleRemoveAction(): void {
    const viewObj = this.getViewListObject(this.pCurrentCategoryId);
    if (!viewObj) return;

    const selectedFriends = viewObj.getSelectedFriends();
    if (selectedFriends.length > 0) {
      this.showConfirmRemoveUser(selectedFriends[0]);
    }
  }

  /**
   * Handle accept all requests
   */
  private handleAcceptAllRequests(): void {
    const viewObj = this.getViewListObject(CategoryIds.REQUESTS);
    if (viewObj) {
      viewObj.handleAll('accepted');
    }
  }

  /**
   * Handle reject all requests
   */
  private handleRejectAllRequests(): void {
    const viewObj = this.getViewListObject(CategoryIds.REQUESTS);
    if (viewObj) {
      viewObj.handleAll('rejected');
    }
  }

  /**
   * Get current category ID
   */
  getCurrentCategoryId(): string {
    return this.pCurrentCategoryId;
  }

  /**
   * Check if minimized
   */
  isMinimized(): boolean {
    return this.pMinimized;
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }
}
