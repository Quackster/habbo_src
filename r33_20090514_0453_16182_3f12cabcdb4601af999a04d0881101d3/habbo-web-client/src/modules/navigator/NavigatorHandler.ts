/**
 * Navigator Handler Class
 *
 * Handles server messages for the navigator system.
 * Ported from hh_navigator Cast External ParentScript 6.
 */

import {
  NAVIGATOR_MESSAGE_IDS,
  NAVIGATOR_COMMANDS,
  NavNode,
  FlatInfo,
  FavoriteRoom,
  UserFlatCategory,
  CreateRoomParams,
  UpdateRoomParams,
} from './types';
import { getNavigatorComponent } from './NavigatorComponent';

type MessageHandler = (msgData: string) => void;

export class NavigatorHandler {
  private handlers: Map<number, MessageHandler>;
  private sendMessage: (msgId: number, data?: string) => void;
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor(sendMessage: (msgId: number, data?: string) => void) {
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
      NAVIGATOR_MESSAGE_IDS.NAVNODEINFO,
      this.handleNavNodeInfo.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.FLATINFO,
      this.handleFlatInfo.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.USERFLATCATS,
      this.handleUserFlatCats.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.FLAT_RESULTS,
      this.handleFlatResults.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.NOFLATS,
      this.handleNoFlats.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.FAVOURITES,
      this.handleFavorites.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.FAVOURITE_CHANGED,
      this.handleFavoriteChanged.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.FLATNOTALLOWEDTOENTER,
      this.handleFlatNotAllowedToEnter.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.NAVNODEINFO_OWN,
      this.handleNavNodeInfoOwn.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.POPULAR_TAGS,
      this.handlePopularTags.bind(this)
    );
    this.handlers.set(
      NAVIGATOR_MESSAGE_IDS.FLATTOOSMALL,
      this.handleFlatTooSmall.bind(this)
    );
  }

  /**
   * Handle incoming message
   */
  handleMessage(msgId: number, msgData: string): boolean {
    const handler = this.handlers.get(msgId);
    if (handler) {
      handler(msgData);
      return true;
    }
    return false;
  }

  /**
   * Handle navigator node info
   */
  private handleNavNodeInfo(msgData: string): void {
    const component = getNavigatorComponent();
    const node = component.parseNodeData(msgData);

    if (node) {
      component.cacheNode(node);
      component.setCurrentNodeId(node.id);

      // Also cache children
      if (node.children) {
        for (const child of node.children) {
          child.parentId = node.id;
          component.cacheNode(child);
        }
      }

      this.emit('node_loaded', node);
    }
  }

  /**
   * Handle flat info response
   */
  private handleFlatInfo(msgData: string): void {
    const component = getNavigatorComponent();
    const flatInfo = component.parseFlatInfo(msgData);

    if (flatInfo) {
      component.setFlatInfo(flatInfo);
      this.emit('flat_info', flatInfo);
    }
  }

  /**
   * Handle user flat categories
   */
  private handleUserFlatCats(msgData: string): void {
    const categories: UserFlatCategory[] = [];
    const lines = msgData.split('\r');

    for (const line of lines) {
      if (!line.trim()) continue;
      const parts = line.split('\t');
      if (parts.length >= 2) {
        categories.push({
          id: parseInt(parts[0], 10),
          name: parts[1],
        });
      }
    }

    const component = getNavigatorComponent();
    component.setUserFlatCategories(categories);
    this.emit('categories_loaded', categories);
  }

  /**
   * Handle flat search results
   */
  private handleFlatResults(msgData: string): void {
    const component = getNavigatorComponent();
    const flats = component.parseFlatList(msgData);

    component.setSearchResults(flats);
    this.emit('search_results', flats);
  }

  /**
   * Handle no flats found
   */
  private handleNoFlats(_msgData: string): void {
    const component = getNavigatorComponent();
    component.setSearchResults([]);
    this.emit('no_flats', null);
  }

  /**
   * Handle favorites list
   */
  private handleFavorites(msgData: string): void {
    const favorites: FavoriteRoom[] = [];
    const lines = msgData.split('\r');

    for (const line of lines) {
      if (!line.trim()) continue;
      const parts = line.split('\t');
      if (parts.length >= 2) {
        favorites.push({
          id: parseInt(parts[0], 10),
          name: parts[1],
        });
      }
    }

    const component = getNavigatorComponent();
    component.setFavoriteRooms(favorites);
    this.emit('favorites_loaded', favorites);
  }

  /**
   * Handle favorite changed notification
   */
  private handleFavoriteChanged(msgData: string): void {
    // Format: added/removed\troomId\troomName
    const parts = msgData.split('\t');
    if (parts.length < 3) return;

    const action = parts[0];
    const roomId = parseInt(parts[1], 10);
    const roomName = parts[2];

    const component = getNavigatorComponent();
    if (action === 'added') {
      component.addFavorite({ id: roomId, name: roomName });
    } else if (action === 'removed') {
      component.removeFavorite(roomId);
    }

    this.emit('favorite_changed', { action, roomId, roomName });
  }

  /**
   * Handle not allowed to enter flat
   */
  private handleFlatNotAllowedToEnter(msgData: string): void {
    this.emit('entry_denied', { reason: msgData });
  }

  /**
   * Handle own rooms in category
   */
  private handleNavNodeInfoOwn(msgData: string): void {
    const component = getNavigatorComponent();
    const flats = component.parseFlatList(msgData);

    component.setOwnRoomsInCategory(flats);
    this.emit('own_rooms_loaded', flats);
  }

  /**
   * Handle popular tags
   */
  private handlePopularTags(msgData: string): void {
    const tags = msgData.split('\t').filter((t) => t.trim());
    const component = getNavigatorComponent();
    component.setPopularTags(tags);
    this.emit('popular_tags', tags);
  }

  /**
   * Handle flat too small
   */
  private handleFlatTooSmall(_msgData: string): void {
    this.emit('flat_too_small', null);
  }

  // ============== Command Senders ==============

  /**
   * Request navigation node info
   */
  navigate(nodeId: number, hideFull: boolean = false, goBack: boolean = false): void {
    const hideFullFlag = hideFull ? 1 : 0;
    const goBackFlag = goBack ? 1 : 0;
    this.sendMessage(
      NAVIGATOR_COMMANDS.NAVIGATE,
      `${nodeId}\t${hideFullFlag}\t${goBackFlag}`
    );
  }

  /**
   * Request flat info
   */
  getFlatInfo(flatId: number): void {
    this.sendMessage(NAVIGATOR_COMMANDS.GETFLATINFO, `${flatId}`);
  }

  /**
   * Get own flats
   */
  getOwnFlats(): void {
    this.sendMessage(NAVIGATOR_COMMANDS.GETOWNFLATS);
  }

  /**
   * Search for flats
   */
  searchFlats(query: string): void {
    getNavigatorComponent().setLastSearchString(query);
    this.sendMessage(NAVIGATOR_COMMANDS.SEARCHFLAT, query);
  }

  /**
   * Add room to favorites
   */
  addFavorite(roomId: number): void {
    this.sendMessage(NAVIGATOR_COMMANDS.ADDFAVOURITE, `${roomId}`);
  }

  /**
   * Remove room from favorites
   */
  removeFavorite(roomId: number): void {
    this.sendMessage(NAVIGATOR_COMMANDS.DELFAVOURITE, `${roomId}`);
  }

  /**
   * Get favorites list
   */
  getFavorites(): void {
    this.sendMessage(NAVIGATOR_COMMANDS.GETFAVOURITES);
  }

  /**
   * Create a new flat
   */
  createFlat(params: CreateRoomParams): void {
    const data = [
      params.name,
      params.model,
      params.accessType,
      params.password || '',
      params.showOwnerName ? '1' : '0',
      params.categoryId.toString(),
    ].join('\t');
    this.sendMessage(NAVIGATOR_COMMANDS.CREATEFLAT, data);
  }

  /**
   * Update flat settings
   */
  updateFlat(params: UpdateRoomParams): void {
    const parts: string[] = [params.id.toString()];

    if (params.name !== undefined) parts.push(`name=${params.name}`);
    if (params.description !== undefined)
      parts.push(`description=${params.description}`);
    if (params.accessType !== undefined) parts.push(`access=${params.accessType}`);
    if (params.password !== undefined) parts.push(`password=${params.password}`);
    if (params.maxUsers !== undefined)
      parts.push(`maxusers=${params.maxUsers}`);
    if (params.allowTrading !== undefined)
      parts.push(`trading=${params.allowTrading ? '1' : '0'}`);
    if (params.wallPaper !== undefined) parts.push(`wallpaper=${params.wallPaper}`);
    if (params.floor !== undefined) parts.push(`floor=${params.floor}`);

    this.sendMessage(NAVIGATOR_COMMANDS.UPDATEFLAT, parts.join('\t'));
  }

  /**
   * Delete a flat
   */
  deleteFlat(flatId: number): void {
    this.sendMessage(NAVIGATOR_COMMANDS.DELETEFLAT, `${flatId}`);
  }

  /**
   * Leave current room
   */
  goAway(): void {
    this.sendMessage(NAVIGATOR_COMMANDS.GOAWAY);
  }

  /**
   * Try to enter a flat
   */
  tryFlat(flatId: number, password?: string): void {
    const data = password ? `${flatId}\t${password}` : `${flatId}`;
    this.sendMessage(NAVIGATOR_COMMANDS.TRYFLAT, data);
  }

  /**
   * Go to a specific flat
   */
  goToFlat(flatId: number): void {
    this.sendMessage(NAVIGATOR_COMMANDS.GOTOFLAT, `${flatId}`);
  }

  /**
   * Let a user into doorbell room
   */
  letUserIn(userName: string): void {
    this.sendMessage(NAVIGATOR_COMMANDS.LETUSERIN, userName);
  }

  /**
   * Get popular tags
   */
  getPopularTags(): void {
    this.sendMessage(NAVIGATOR_COMMANDS.GETPOPULARTAGS);
  }

  /**
   * Search rooms by tag
   */
  searchByTag(tag: string): void {
    this.sendMessage(NAVIGATOR_COMMANDS.SEARCHBYTAG, tag);
  }
}

// Singleton instance
let navigatorHandler: NavigatorHandler | null = null;

export function getNavigatorHandler(
  sendMessage?: (msgId: number, data?: string) => void
): NavigatorHandler {
  if (!navigatorHandler) {
    if (!sendMessage) {
      throw new Error('sendMessage function required for initial creation');
    }
    navigatorHandler = new NavigatorHandler(sendMessage);
  }
  return navigatorHandler;
}

export function resetNavigatorHandler(): void {
  navigatorHandler = null;
}
