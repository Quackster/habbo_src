/**
 * Navigator Component Class
 *
 * Manages navigator state and node caching.
 * Ported from hh_navigator Cast External ParentScript 5.
 */

import {
  NavNode,
  FlatInfo,
  FavoriteRoom,
  UserFlatCategory,
  NavigatorState,
  NodeType,
} from './types';

export class NavigatorComponent {
  private state: NavigatorState;
  private hideFullFlats: boolean = false;
  private lastSearchString: string = '';
  private forwardingType: number = 0;
  private forwardingName: string = '';

  constructor() {
    this.state = {
      currentNodeId: 0,
      currentCategoryId: 0,
      nodeCache: new Map(),
      categoryIndex: new Map(),
      flatInfo: null,
      ownFlats: [],
      searchResults: [],
      favoriteRooms: [],
      userFlatCategories: [],
      popularTags: [],
      ownRoomsInCategory: [],
    };
  }

  /**
   * Reset navigator state
   */
  reset(): void {
    this.state.nodeCache.clear();
    this.state.categoryIndex.clear();
    this.state.flatInfo = null;
    this.state.ownFlats = [];
    this.state.searchResults = [];
    this.state.ownRoomsInCategory = [];
    this.state.currentNodeId = 0;
    this.state.currentCategoryId = 0;
  }

  /**
   * Get current node ID
   */
  getCurrentNodeId(): number {
    return this.state.currentNodeId;
  }

  /**
   * Set current node ID
   */
  setCurrentNodeId(nodeId: number): void {
    this.state.currentNodeId = nodeId;
  }

  /**
   * Get current category ID
   */
  getCurrentCategoryId(): number {
    return this.state.currentCategoryId;
  }

  /**
   * Set current category ID
   */
  setCurrentCategoryId(categoryId: number): void {
    this.state.currentCategoryId = categoryId;
  }

  /**
   * Get cached node by ID
   */
  getNode(nodeId: number): NavNode | undefined {
    return this.state.nodeCache.get(nodeId);
  }

  /**
   * Cache a node
   */
  cacheNode(node: NavNode): void {
    this.state.nodeCache.set(node.id, node);
  }

  /**
   * Clear node cache
   */
  clearNodeCache(): void {
    this.state.nodeCache.clear();
  }

  /**
   * Update node in cache
   */
  updateNodeInCache(nodeId: number, updates: Partial<NavNode>): void {
    const existing = this.state.nodeCache.get(nodeId);
    if (existing) {
      this.state.nodeCache.set(nodeId, { ...existing, ...updates });
    }
  }

  /**
   * Set user flat categories
   */
  setUserFlatCategories(categories: UserFlatCategory[]): void {
    this.state.userFlatCategories = categories;
    // Build category index
    this.state.categoryIndex.clear();
    categories.forEach((cat, index) => {
      this.state.categoryIndex.set(cat.id, index);
    });
  }

  /**
   * Get user flat categories
   */
  getUserFlatCategories(): UserFlatCategory[] {
    return this.state.userFlatCategories;
  }

  /**
   * Get category index by ID
   */
  getCategoryIndex(categoryId: number): number {
    return this.state.categoryIndex.get(categoryId) ?? -1;
  }

  /**
   * Set current flat info
   */
  setFlatInfo(info: FlatInfo | null): void {
    this.state.flatInfo = info;
  }

  /**
   * Get current flat info
   */
  getFlatInfo(): FlatInfo | null {
    return this.state.flatInfo;
  }

  /**
   * Set own flats list
   */
  setOwnFlats(flats: FlatInfo[]): void {
    this.state.ownFlats = flats;
  }

  /**
   * Get own flats
   */
  getOwnFlats(): FlatInfo[] {
    return this.state.ownFlats;
  }

  /**
   * Set search results
   */
  setSearchResults(results: FlatInfo[]): void {
    this.state.searchResults = results;
  }

  /**
   * Get search results
   */
  getSearchResults(): FlatInfo[] {
    return this.state.searchResults;
  }

  /**
   * Set favorite rooms
   */
  setFavoriteRooms(rooms: FavoriteRoom[]): void {
    this.state.favoriteRooms = rooms;
  }

  /**
   * Get favorite rooms
   */
  getFavoriteRooms(): FavoriteRoom[] {
    return this.state.favoriteRooms;
  }

  /**
   * Add room to favorites
   */
  addFavorite(room: FavoriteRoom): void {
    if (!this.state.favoriteRooms.find((r) => r.id === room.id)) {
      this.state.favoriteRooms.push(room);
    }
  }

  /**
   * Remove room from favorites
   */
  removeFavorite(roomId: number): void {
    this.state.favoriteRooms = this.state.favoriteRooms.filter(
      (r) => r.id !== roomId
    );
  }

  /**
   * Check if room is favorite
   */
  isFavorite(roomId: number): boolean {
    return this.state.favoriteRooms.some((r) => r.id === roomId);
  }

  /**
   * Set popular tags
   */
  setPopularTags(tags: string[]): void {
    this.state.popularTags = tags;
  }

  /**
   * Get popular tags
   */
  getPopularTags(): string[] {
    return this.state.popularTags;
  }

  /**
   * Set own rooms in current category
   */
  setOwnRoomsInCategory(rooms: FlatInfo[]): void {
    this.state.ownRoomsInCategory = rooms;
  }

  /**
   * Get own rooms in current category
   */
  getOwnRoomsInCategory(): FlatInfo[] {
    return this.state.ownRoomsInCategory;
  }

  /**
   * Set hide full flats preference
   */
  setHideFullFlats(hide: boolean): void {
    this.hideFullFlats = hide;
  }

  /**
   * Get hide full flats preference
   */
  getHideFullFlats(): boolean {
    return this.hideFullFlats;
  }

  /**
   * Set last search string
   */
  setLastSearchString(search: string): void {
    this.lastSearchString = search;
  }

  /**
   * Get last search string
   */
  getLastSearchString(): string {
    return this.lastSearchString;
  }

  /**
   * Set forwarding info (for room transitions)
   */
  setForwarding(type: number, name: string): void {
    this.forwardingType = type;
    this.forwardingName = name;
  }

  /**
   * Get forwarding type
   */
  getForwardingType(): number {
    return this.forwardingType;
  }

  /**
   * Get forwarding name
   */
  getForwardingName(): string {
    return this.forwardingName;
  }

  /**
   * Clear forwarding info
   */
  clearForwarding(): void {
    this.forwardingType = 0;
    this.forwardingName = '';
  }

  /**
   * Parse node data from server message
   */
  parseNodeData(data: string): NavNode | null {
    // Format: nodeId\tnodeMask\tnodeName\tuserCount\tmaxUsers\tparentId\tchildInfo
    const parts = data.split('\t');
    if (parts.length < 6) return null;

    const node: NavNode = {
      id: parseInt(parts[0], 10),
      nodeMask: parseInt(parts[1], 10),
      name: parts[2],
      userCount: parseInt(parts[3], 10),
      maxUsers: parseInt(parts[4], 10),
      parentId: parseInt(parts[5], 10),
      nodeType: NodeType.CATEGORY,
      hasChildren: parts.length > 6,
    };

    // Parse children if present
    if (parts.length > 6) {
      node.children = [];
      for (let i = 6; i < parts.length; i++) {
        const childNode = this.parseChildNode(parts[i]);
        if (childNode) {
          node.children.push(childNode);
        }
      }
    }

    return node;
  }

  /**
   * Parse child node from sub-data
   */
  private parseChildNode(data: string): NavNode | null {
    // Format varies by node type
    const fields = data.split('/');
    if (fields.length < 5) return null;

    return {
      id: parseInt(fields[0], 10),
      name: fields[1],
      userCount: parseInt(fields[2], 10),
      maxUsers: parseInt(fields[3], 10),
      nodeType: parseInt(fields[4], 10) as NodeType,
      nodeMask: 0,
      parentId: 0,
      hasChildren: false,
    };
  }

  /**
   * Parse flat info from server message
   */
  parseFlatInfo(data: string): FlatInfo | null {
    // Format: superuser\tid\townerName\taccessType\tname\tdescription\tuserCount\tmaxUsers\ttradingLevel\tscore\tparentId
    const parts = data.split('\t');
    if (parts.length < 10) return null;

    return {
      superuser: parts[0] === '1',
      id: parseInt(parts[1], 10),
      ownerName: parts[2],
      accessType: parts[3],
      name: parts[4],
      description: parts[5] || '',
      userCount: parseInt(parts[6], 10),
      maxUsers: parseInt(parts[7], 10),
      tradingLevel: parseInt(parts[8], 10),
      score: parseInt(parts[9], 10),
      parentId: parts.length > 10 ? parseInt(parts[10], 10) : 0,
    };
  }

  /**
   * Parse flat list from server message
   */
  parseFlatList(data: string): FlatInfo[] {
    const flats: FlatInfo[] = [];
    const lines = data.split('\r');

    for (const line of lines) {
      if (!line.trim()) continue;
      const flat = this.parseFlatInfo(line);
      if (flat) {
        flats.push(flat);
      }
    }

    return flats;
  }

  /**
   * Filter flats based on preferences
   */
  filterFlats(flats: FlatInfo[]): FlatInfo[] {
    if (!this.hideFullFlats) {
      return flats;
    }
    return flats.filter((flat) => flat.userCount < flat.maxUsers);
  }

  /**
   * Sort flats by user count (descending)
   */
  sortFlatsByPopularity(flats: FlatInfo[]): FlatInfo[] {
    return [...flats].sort((a, b) => b.userCount - a.userCount);
  }

  /**
   * Sort flats by score (descending)
   */
  sortFlatsByScore(flats: FlatInfo[]): FlatInfo[] {
    return [...flats].sort((a, b) => b.score - a.score);
  }
}

// Singleton instance
let navigatorComponent: NavigatorComponent | null = null;

export function getNavigatorComponent(): NavigatorComponent {
  if (!navigatorComponent) {
    navigatorComponent = new NavigatorComponent();
  }
  return navigatorComponent;
}

export function resetNavigatorComponent(): void {
  if (navigatorComponent) {
    navigatorComponent.reset();
  }
  navigatorComponent = null;
}
