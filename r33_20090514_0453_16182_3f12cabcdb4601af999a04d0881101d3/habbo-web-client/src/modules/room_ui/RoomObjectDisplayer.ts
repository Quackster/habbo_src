/**
 * Room Object Displayer Class - Infostand for users, furniture, pets
 *
 * Ported from: hh_room_ui/Cast External ParentScript 5 - Room Object Displayer Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  ObjectDisplayType,
  DisplayerWindowType,
  UserDisplayProps,
  FurnitureDisplayProps,
  PetDisplayProps,
  UserTagData,
  InfostandActions,
} from './types';

/**
 * Room object displayer - manages infostand windows
 */
export class RoomObjectDisplayer extends BaseObject {
  private pWindowList: string[] = [];
  private pTagRequestTimeout: number = 120000;
  private pShowActions: boolean = true;
  private pShowUserTags: boolean = true;
  private pLastSelectedObjType: ObjectDisplayType | null = null;
  private pLastSelectedObj: string | null = null;
  private pTagLists: Map<string, UserTagData> = new Map();
  private pClosed: boolean = false;

  construct(): void {
    super.construct();

    this.pWindowList = [];
    this.pTagRequestTimeout = 120000; // Would get from variable
    this.pShowActions = true;
    this.pShowUserTags = true;
    this.pLastSelectedObjType = null;
    this.pTagLists = new Map();

    // Would create base windows
    // Would register for various messages
  }

  deconstruct(): void {
    this.clearWindowDisplayList();
    // Would unregister messages
    super.deconstruct();
  }

  /**
   * Show object info
   */
  showObjectInfo(objType: ObjectDisplayType, refresh?: boolean): boolean {
    if (this.pClosed && refresh) {
      return true;
    }

    this.clearWindowDisplayList();
    this.pLastSelectedObjType = objType;

    // Would get selected object from room interface
    const selectedObj = this.pLastSelectedObj;
    if (!selectedObj) {
      return false;
    }

    // Get window types based on object type
    const windowTypes = this.getWindowTypesForObject(objType);

    for (const windowType of windowTypes) {
      this.createDisplayWindow(windowType, objType);
    }

    this.alignWindows();
    this.pClosed = false;

    this.emit('object_info_shown', { type: objType, id: selectedObj });
    return true;
  }

  /**
   * Get window types for object type
   */
  private getWindowTypesForObject(objType: ObjectDisplayType): DisplayerWindowType[] {
    switch (objType) {
      case 'user':
        // Would check if own user for different window set
        return ['avatar', 'motto', 'tags_user', 'xp_user', 'fx_user', 'links_human', 'actions_human', 'bottom'];
      case 'bot':
        return ['bot', 'bottom'];
      case 'active':
      case 'item':
        return ['furni', 'actions_furni', 'bottom'];
      case 'pet':
        return ['pet', 'bottom'];
      default:
        return [];
    }
  }

  /**
   * Create display window
   */
  private createDisplayWindow(windowType: DisplayerWindowType, objType: ObjectDisplayType): void {
    // Would create appropriate window based on type
    this.emit('window_created', { type: windowType, objType });
  }

  /**
   * Clear window display list
   */
  clearWindowDisplayList(): void {
    for (const windowId of this.pWindowList) {
      // Would clear/hide window
    }
    this.pWindowList = [];
    this.emit('windows_cleared');
  }

  /**
   * Refresh view
   */
  refreshView(): void {
    this.clearWindowDisplayList();
    if (this.pLastSelectedObjType) {
      this.showObjectInfo(this.pLastSelectedObjType, true);
    }
  }

  /**
   * Show/hide actions
   */
  showHideActions(): void {
    this.pShowActions = !this.pShowActions;
    this.refreshView();
  }

  /**
   * Show/hide tags
   */
  showHideTags(): void {
    this.pShowUserTags = !this.pShowUserTags;
    this.refreshView();
  }

  /**
   * Update user tags
   */
  updateUserTags(userId: number, tagList?: string[]): void {
    const userIdStr = String(userId);
    const timeNow = Date.now();

    if (tagList !== undefined) {
      // Update tag list
      this.pTagLists.set(userIdStr, {
        tags: tagList,
        lastUpdate: timeNow,
      });
      this.refreshView();
      return;
    }

    // Check if we need to request tags
    const userData = this.pTagLists.get(userIdStr);
    const lastUpdateTime = userData?.lastUpdate || 0;

    if (timeNow - lastUpdateTime > this.pTagRequestTimeout) {
      this.pTagLists.set(userIdStr, {
        tags: [],
        lastUpdate: timeNow,
      });

      // Would send GET_USER_TAGS command
      this.emit('request_user_tags', { userId });
    }
  }

  /**
   * Align windows vertically
   */
  alignWindows(): void {
    if (this.pWindowList.length === 0) return;

    // Would position windows stacked from bottom
    this.emit('windows_aligned');
  }

  /**
   * Update badge
   */
  updateBadge(): void {
    this.refreshView();
  }

  /**
   * User removed - check if currently displayed
   */
  userRemoved(objectId: string): boolean {
    if (this.pLastSelectedObj === objectId) {
      this.refreshView();
    }
    return true;
  }

  /**
   * Handle UI event
   */
  handleEvent(event: string, spriteId: string, param?: unknown): void {
    if (event === 'mouseUp') {
      switch (spriteId) {
        case 'badges.button':
          this.emit('action', { action: InfostandActions.BADGES });
          break;
        case 'dance.button':
          this.emit('action', { action: InfostandActions.DANCE, param: 'toggle' });
          break;
        case 'hcdance.button':
          this.emit('action', { action: InfostandActions.DANCE, param });
          break;
        case 'wave.button':
          this.emit('action', { action: InfostandActions.WAVE });
          break;
        case 'fx.button':
          this.emit('action', { action: InfostandActions.FX, param });
          break;
        case 'move.button':
          this.emit('action', { action: InfostandActions.MOVE });
          break;
        case 'rotate.button':
          this.emit('action', { action: InfostandActions.ROTATE });
          break;
        case 'pick.button':
          this.emit('action', { action: InfostandActions.PICK });
          this.clearWindowDisplayList();
          break;
        case 'delete.button':
          this.emit('action', { action: InfostandActions.DELETE });
          break;
        case 'kick.button':
          this.emit('action', { action: InfostandActions.KICK });
          this.clearWindowDisplayList();
          break;
        case 'ban.button':
          this.emit('action', { action: InfostandActions.BAN });
          this.clearWindowDisplayList();
          break;
        case 'give_rights.button':
          this.emit('action', { action: InfostandActions.GIVE_RIGHTS });
          this.clearWindowDisplayList();
          break;
        case 'take_rights.button':
          this.emit('action', { action: InfostandActions.TAKE_RIGHTS });
          this.clearWindowDisplayList();
          break;
        case 'friend.button':
          this.emit('action', { action: InfostandActions.FRIEND });
          break;
        case 'respect.button':
          this.emit('action', { action: InfostandActions.RESPECT });
          break;
        case 'trade.button':
          this.emit('action', { action: InfostandActions.TRADE });
          break;
        case 'ignore.button':
          this.emit('action', { action: InfostandActions.IGNORE });
          this.clearWindowDisplayList();
          break;
        case 'unignore.button':
          this.emit('action', { action: InfostandActions.UNIGNORE });
          this.clearWindowDisplayList();
          break;
        case 'room_obj_disp_close':
          this.pClosed = true;
          this.clearWindowDisplayList();
          break;
        case 'room_obj_disp_looks':
        case 'room_obj_disp_icon_avatar':
        case 'room_obj_disp_avatar':
        case 'outlook.button':
          this.emit('action', { action: InfostandActions.LOOKS });
          break;
        case 'room_obj_disp_home':
        case 'room_obj_disp_icon_home':
        case 'room_obj_disp_name':
          this.emit('action', { action: InfostandActions.HOME });
          break;
        case 'info_group_badge':
          this.emit('action', { action: InfostandActions.GROUP });
          break;
        case 'object_displayer_toggle_actions':
        case 'object_displayer_toggle_actions_icon':
          this.showHideActions();
          break;
        case 'object_displayer_toggle_tags':
        case 'object_displayer_toggle_tags_icon':
          this.showHideTags();
          break;
        case 'room_obj_disp_tags':
          // Would handle tag click
          this.emit('tag_clicked', { param });
          break;
      }

      // Handle badge info display
      if (spriteId.includes('info_badge')) {
        this.emit('badge_clicked', { spriteId });
      }
    } else if (event === 'mouseEnter') {
      if (spriteId.includes('info_badge')) {
        this.emit('badge_hover_enter', { spriteId });
      }
    } else if (event === 'mouseLeave') {
      if (spriteId.includes('info_badge')) {
        this.emit('badge_hover_leave');
      }
    }
  }

  /**
   * Set selected object
   */
  setSelectedObject(objId: string, objType: ObjectDisplayType): void {
    this.pLastSelectedObj = objId;
    this.pLastSelectedObjType = objType;
  }

  /**
   * Get selected object
   */
  getSelectedObject(): string | null {
    return this.pLastSelectedObj;
  }

  /**
   * Get selected object type
   */
  getSelectedObjectType(): ObjectDisplayType | null {
    return this.pLastSelectedObjType;
  }
}
