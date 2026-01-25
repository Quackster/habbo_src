/**
 * Friend List Interface Class - UI management for friend list
 *
 * Ported from: hh_friend_list/Cast External ParentScript 3 - Friend List Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getVariable, variableExists } from '../../core/VariableContainer';
import { getConnection } from '../../managers/ConnectionManager';
import { EventEmitter } from '../../core/events';
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

export class FriendListInterface extends BaseObject {
  private friendListWindowId: string = 'Friend List';
  private removeConfirmId: string = '';
  private confirmDeleteFriend: FriendData | null = null;
  private maxCategories: number = 0;
  private maxFreeCategories: number = 5;
  private windowDefaultHeight: number = 400;
  private currentCategoryId: string = '0';
  private minimized: boolean = false;
  private viewsList: Map<string, FriendListViewObject> = new Map();
  private highlightedCategories: Set<string> = new Set();
  private highlightTimeouts: Map<string, ReturnType<typeof setTimeout>> = new Map();
  private inboxBlinkStep: number = 0;
  private inboxBlinkInterval: ReturnType<typeof setInterval> | null = null;
  private events: EventEmitter = new EventEmitter();

  construct(): void {
    super.construct();

    this.removeConfirmId = 'friend_list_confirm_remove';
    this.currentCategoryId = getVariable('fr.window.default.category.id', '0') as string;
    this.maxFreeCategories = getVariable('fr.window.max.free.categories', 5) as number;
    this.maxCategories = this.maxFreeCategories + 4;

    registerMessage('toggle_friend_list', this.id, 'toggleFriendList');
    registerMessage('enterRoom', this.id, 'updateActionIconsState');
    registerMessage('leaveRoom', this.id, 'updateActionIconsState');
    registerMessage('changeRoom', this.id, 'updateActionIconsState');
    registerMessage('enterRoomDirect', this.id, 'updateActionIconsState');
    registerMessage('gamesystem_constructed', this.id, 'closeFriendList');
  }

  deconstruct(): void {
    this.endInboxBlink();
    this.clearHighlightTimeouts();

    unregisterMessage('toggle_friend_list', this.id);
    unregisterMessage('enterRoom', this.id);
    unregisterMessage('leaveRoom', this.id);
    unregisterMessage('changeRoom', this.id);
    unregisterMessage('enterRoomDirect', this.id);
    unregisterMessage('gamesystem_constructed', this.id);

    super.deconstruct();
  }

  /**
   * Clear all highlight timeouts
   */
  private clearHighlightTimeouts(): void {
    for (const timeout of this.highlightTimeouts.values()) {
      clearTimeout(timeout);
    }
    this.highlightTimeouts.clear();
  }

  /**
   * Create friend list window
   */
  createFriendList(): boolean {
    const component = this.getComponent() as FriendListComponent | null;
    if (!component?.isFriendListInited()) {
      return false;
    }

    this.events.emit('createWindow', {
      id: this.friendListWindowId,
      template: 'friends_list_base.window',
    });

    this.changeCategory(this.currentCategoryId);
    return true;
  }

  /**
   * Open friend list
   */
  openFriendList(): void {
    this.createFriendList();
    this.events.emit('showWindow', { id: this.friendListWindowId, x: 15, y: 65 });
  }

  /**
   * Close friend list
   */
  closeFriendList(): void {
    this.events.emit('hideWindow', { id: this.friendListWindowId });
  }

  /**
   * Toggle friend list visibility
   */
  toggleFriendList(): void {
    this.events.emit('toggleWindow', { id: this.friendListWindowId });
  }

  /**
   * Toggle minimized view
   */
  minimizedView(minimized?: boolean): void {
    if (minimized === undefined) {
      this.minimized = !this.minimized;
    } else {
      this.minimized = minimized;
    }
    this.changeCategory(this.currentCategoryId);
  }

  /**
   * Check if friend request view is open
   */
  isFriendRequestViewOpen(): boolean {
    return this.currentCategoryId === CategoryIds.REQUESTS;
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

    if (!holdRender && this.currentCategoryId === categoryId) {
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

    if (this.currentCategoryId === categoryId) {
      this.updateOpenCategoryPanel();
    }
  }

  /**
   * Set category highlight
   */
  setCategoryHighlight(categoryId: string): void {
    const allowedCategories = getVariable('fr.category.highlights.allowed', ['-2']) as string[];

    if (allowedCategories.includes(categoryId) && (this.currentCategoryId !== categoryId || this.minimized)) {
      this.highlightedCategories.add(categoryId);
      this.showCategoryTitle(categoryId);

      // Clear existing timeout
      const existingTimeout = this.highlightTimeouts.get(categoryId);
      if (existingTimeout) {
        clearTimeout(existingTimeout);
      }

      // Set new timeout
      const duration = getVariable('fr.category.highlight.duration', 5000) as number;
      const timeout = setTimeout(() => this.removeCategoryHighlight(categoryId), duration);
      this.highlightTimeouts.set(categoryId, timeout);
    }
  }

  /**
   * Remove category highlight
   */
  removeCategoryHighlight(categoryId: string): void {
    if (this.highlightedCategories.delete(categoryId)) {
      this.showCategoryTitle(categoryId);
    }
    const timeout = this.highlightTimeouts.get(categoryId);
    if (timeout) {
      clearTimeout(timeout);
      this.highlightTimeouts.delete(categoryId);
    }
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

    if (!holdRender && this.currentCategoryId === friendData.categoryId) {
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

    if (!holdRender && this.currentCategoryId === category) {
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
      categoryId = this.currentCategoryId;
    }

    this.removeCategoryHighlight(categoryId);

    if (categoryId !== this.currentCategoryId) {
      this.events.emit('categoryChanged', {
        from: this.currentCategoryId,
        to: categoryId,
      });
    }

    this.currentCategoryId = categoryId;
    this.updateOpenCategoryPanel();
    this.updateActionIconsState();

    if (!this.minimized && categoryId === CategoryIds.REQUESTS) {
      executeMessage('FriendRequestListOpened');
    }
  }

  /**
   * Update open category panel
   */
  updateOpenCategoryPanel(): void {
    const viewObj = this.getViewListObject(this.currentCategoryId);
    if (!viewObj) return;

    if (this.currentCategoryId === CategoryIds.REQUESTS) {
      viewObj.cleanUp();
    }

    if (viewObj.needsRender()) {
      viewObj.resetRenderFlag();
      viewObj.renderListImage();
    }

    const listImage = viewObj.getViewImage();
    this.events.emit('updateListPanel', { image: listImage });
    this.updateActionIconsState();
  }

  /**
   * Show category title
   */
  showCategoryTitle(id: string, locV?: number, name?: string, itemCount?: number): void {
    const component = this.getComponent() as FriendListComponent | null;
    if (!component) return;

    const highlighted = this.highlightedCategories.has(id);
    const categoryName = name ?? component.getCategoryName(id);
    const count = itemCount ?? component.getItemCountForCategory(id);

    this.events.emit('updateCategoryTitle', {
      id,
      name: categoryName,
      count,
      highlighted,
      locV,
    });
  }

  /**
   * Activate/deactivate mail icon
   */
  activateMailIcon(active: boolean): void {
    this.events.emit('mailIconState', { active });
  }

  /**
   * Start inbox blink animation
   */
  startInboxBlink(): void {
    if (this.inboxBlinkInterval) return;

    this.inboxBlinkInterval = setInterval(() => {
      this.inboxBlinkStep = this.inboxBlinkStep > 0 ? 0 : 1;
      this.events.emit('mailIconBlink', { step: this.inboxBlinkStep });
    }, 1000);
  }

  /**
   * End inbox blink animation
   */
  endInboxBlink(): void {
    if (this.inboxBlinkInterval) {
      clearInterval(this.inboxBlinkInterval);
      this.inboxBlinkInterval = null;
    }
    this.events.emit('mailIconState', { active: false });
  }

  /**
   * Update action icons state
   */
  updateActionIconsState(): void {
    const viewObj = this.getViewListObject(this.currentCategoryId);
    if (!viewObj) return;

    const catIdNum = parseInt(this.currentCategoryId);

    if (catIdNum >= -1) {
      const selectedFriends = viewObj.getSelectedFriends();
      const invitesInUse = variableExists('client.use.invites') && getVariable('client.use.invites') === 1;

      this.events.emit('updateActionIcons', {
        selectedCount: selectedFriends.length,
        invitesEnabled: invitesInUse,
        categoryId: this.currentCategoryId,
      });
    } else if (catIdNum === -2) {
      const component = this.getComponent() as FriendListComponent | null;
      const requests = component?.getPendingFriendRequests();
      const count = requests?.size ?? 0;

      this.events.emit('updateRequestActions', {
        hasRequests: count > 0,
      });
    }
  }

  /**
   * Get or create view list object
   */
  getViewListObject(categoryId: string): FriendListViewObject | null {
    const catIdStr = String(categoryId);
    let viewObj = this.viewsList.get(catIdStr);

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

      this.viewsList.set(catIdStr, viewObj);
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
   */
  showConfirmRemoveUser(friend: FriendData): void {
    this.confirmDeleteFriend = friend;
    this.events.emit('showConfirmRemove', {
      id: this.removeConfirmId,
      friendName: friend.name,
    });
  }

  /**
   * Hide confirm remove user dialog
   */
  hideConfirmRemoveUser(): void {
    this.events.emit('hideConfirmRemove', { id: this.removeConfirmId });
    this.confirmDeleteFriend = null;
  }

  /**
   * Confirm remove user
   */
  confirmRemoveUser(): void {
    if (this.confirmDeleteFriend) {
      const component = this.getComponent() as FriendListComponent | null;
      if (component) {
        component.sendRemoveFriend(this.confirmDeleteFriend.id);
      }
      this.hideConfirmRemoveUser();
    }
  }

  /**
   * Handle list panel events
   */
  handleListPanelEvent(event: string, locX: number, locY: number): void {
    const viewObj = this.getViewListObject(this.currentCategoryId);
    if (!viewObj) return;

    if (event === 'mouseLeave') {
      this.events.emit('hideInfoPopup');
      return;
    }

    const eventData = viewObj.relayEvent(event, locX, locY);
    if (!eventData) return;

    const friend = eventData.friend;
    const element = eventData.element;

    if (eventData.event === 'mouseWithin') {
      this.events.emit('showInfoPopup', { data: eventData });
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
          this.events.emit('openMailCompose', { recipientId: friend.id });
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
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Get current category ID
   */
  getCurrentCategoryId(): string {
    return this.currentCategoryId;
  }

  /**
   * Check if minimized
   */
  isMinimized(): boolean {
    return this.minimized;
  }
}
