/**
 * Friend List Handler Class - Server message handlers
 *
 * Ported from: hh_friend_list/Cast External ParentScript 5 - Friend List Handler Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { HabboMessage } from '../../types';
import { executeMessage } from '../../core/MessageBus';
import { getVariable } from '../../core/VariableContainer';
import { registerListener, registerCommands, unregisterListener, unregisterCommands, getConnection } from '../../managers/ConnectionManager';
import { HabboConnection } from '../../network/HabboConnection';
import {
  FriendData,
  FriendRequest,
  HabboSearchResult,
  FriendListMessages,
  FriendListCommands,
  FriendUpdateType,
  FollowFailureType,
} from './types';
import { FriendListComponent } from './FriendListComponent';
import { FriendListInterface } from './FriendListInterface';

export class FriendListHandler extends BaseObject {
  private catAliases: Map<string, string> = new Map();

  construct(): void {
    super.construct();
    this.regMsgList(true);
  }

  deconstruct(): void {
    this.regMsgList(false);
    super.deconstruct();
  }

  /**
   * Clear category aliases
   */
  clearCatAliases(): void {
    this.catAliases.clear();
  }

  /**
   * Get slot category alias
   */
  getSlotCatAlias(uniqueCatId: string): string {
    const catIdStr = String(uniqueCatId);
    const catIdNum = parseInt(catIdStr);

    if (catIdNum <= 0) {
      return catIdStr;
    }

    if (this.catAliases.has(catIdStr)) {
      return this.catAliases.get(catIdStr)!;
    }

    const maxFreeCount = getVariable('fr.window.max.free.categories', 5) as number;
    for (let slotNo = 1; slotNo <= maxFreeCount; slotNo++) {
      const slotStr = String(slotNo);
      let slotInUse = false;
      for (const [, value] of this.catAliases) {
        if (value === slotStr) {
          slotInUse = true;
          break;
        }
      }
      if (!slotInUse) {
        this.catAliases.set(catIdStr, slotStr);
        return slotStr;
      }
    }

    console.error(`FriendListHandler: Could not map category id to a slot: ${uniqueCatId}`);
    return '0';
  }

  /**
   * Remove unused categories
   */
  removeUnusedCategories(idsInUse: string[]): void {
    const aliasesToRemove: string[] = [];
    for (const id of this.catAliases.keys()) {
      if (!idsInUse.includes(id)) {
        aliasesToRemove.push(id);
      }
    }
    for (const id of aliasesToRemove) {
      this.catAliases.delete(id);
    }
  }

  /**
   * Handle OK message - request friend list init
   */
  handleOk(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    conn.send('FRIENDLIST_INIT');
  }

  /**
   * Handle friend list init
   */
  handleFriendListInit(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const userLimit = conn.GetIntFrom(msg);
    const normalLimit = conn.GetIntFrom(msg);
    const extendedLimit = conn.GetIntFrom(msg);
    const categoryCount = conn.GetIntFrom(msg);

    const categories = new Map<string, string>();
    for (let i = 0; i < categoryCount; i++) {
      const uniqueId = String(conn.GetIntFrom(msg));
      const name = conn.GetStrFrom(msg);
      const id = this.getSlotCatAlias(uniqueId);
      if (id !== '0') {
        categories.set(id, name);
      }
    }

    const friendCount = conn.GetIntFrom(msg);
    const friendList = new Map<string, FriendData>();
    for (let i = 0; i < friendCount; i++) {
      const friend = this.parseFriendData(msg);
      if (friend) {
        friendList.set(String(friend.id), friend);
      }
    }

    const friendRequestLimit = conn.GetIntFrom(msg);
    const friendRequestCount = conn.GetIntFrom(msg);

    const component = this.getComponent() as FriendListComponent | null;
    if (component) {
      component.setFriendLimits(userLimit, normalLimit, extendedLimit);
      component.populateCategoryData(categories);
      component.populateFriendData(friendList);
      component.sendAskForFriendRequests();
      component.setFriendListInited();
    }
  }

  /**
   * Handle friend list update
   */
  handleFriendListUpdate(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const categoryCount = conn.GetIntFrom(msg);
    if (categoryCount > 0) {
      const categoriesTemp = new Map<string, string>();
      const usedIds: string[] = [];

      for (let i = 0; i < categoryCount; i++) {
        const id = String(conn.GetIntFrom(msg));
        const name = conn.GetStrFrom(msg);
        categoriesTemp.set(id, name);
        usedIds.push(id);
      }

      this.removeUnusedCategories(usedIds);

      const categories = new Map<string, string>();
      for (const [uniqueId, name] of categoriesTemp) {
        const slotId = this.getSlotCatAlias(uniqueId);
        if (slotId !== '0') {
          categories.set(slotId, name);
        }
      }

      const component = this.getComponent() as FriendListComponent | null;
      if (component) {
        component.populateCategoryData(categories);
      }
    }

    const friendCount = conn.GetIntFrom(msg);
    const component = this.getComponent() as FriendListComponent | null;
    const iface = this.getInterface() as FriendListInterface | null;

    for (let i = 0; i < friendCount; i++) {
      const updateType = conn.GetIntFrom(msg);

      switch (updateType) {
        case FriendUpdateType.REMOVED: {
          const friendId = conn.GetIntFrom(msg);
          if (component) {
            component.removeFriend(friendId);
          }
          break;
        }
        case FriendUpdateType.UPDATED: {
          const friend: FriendData = {
            id: conn.GetIntFrom(msg),
            name: conn.GetStrFrom(msg),
            sex: conn.GetIntFrom(msg),
            online: conn.GetIntFrom(msg),
            canfollow: conn.GetIntFrom(msg),
            figure: conn.GetStrFrom(msg),
            categoryId: this.getSlotCatAlias(String(conn.GetIntFrom(msg))),
            mission: conn.GetStrFrom(msg),
            lastAccess: conn.GetStrFrom(msg),
          };

          // Fix category for offline friends
          const catIdNum = parseInt(friend.categoryId);
          if (catIdNum < 0) {
            friend.categoryId = '0';
          }
          if (friend.online === 0) {
            friend.categoryId = '-1';
          }

          if (component) {
            component.updateFriend(friend, true);
          }
          break;
        }
        case FriendUpdateType.ADDED: {
          const friend = this.parseFriendData(msg);
          if (friend && component) {
            component.addFriend(friend);
          }
          break;
        }
      }
    }

    if ((friendCount > 0 || categoryCount > 0) && iface) {
      iface.updateCategoryCounts();
      iface.updateOpenCategoryPanel();
    }
  }

  /**
   * Handle error
   */
  handleError(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const clientMessageId = conn.GetIntFrom(msg);
    const errorCode = conn.GetIntFrom(msg);

    switch (errorCode) {
      case 0:
        console.error('FriendListHandler: Undefined friend list error!');
        break;
      case 2:
        executeMessage('alert', { Msg: 'console_target_friend_list_full' });
        break;
      case 3:
        executeMessage('alert', { Msg: 'console_target_does_not_accept' });
        break;
      case 4:
        executeMessage('alert', { Msg: 'console_friend_request_not_found' });
        break;
      case 37: {
        const reason = conn.GetIntFrom(msg);
        if (reason === 1 || reason === 2) {
          executeMessage('alert', { Msg: 'console_buddylimit_requester', modal: true });
        } else if (reason === 42) {
          executeMessage('alert', { Msg: 'console_buddylist_concurrency', modal: true });
          const connId = getVariable('connection.info.id', 'Info') as string;
          const connection = getConnection(connId);
          if (connection) {
            connection.send('FRIENDLIST_UPDATE');
          }
        }
        break;
      }
      case 39:
      case 42:
        executeMessage('alert', { Msg: 'console_concurrency_error' });
        break;
      default:
        console.error(`FriendListHandler: Error ${errorCode} triggered by message ${clientMessageId}`);
    }
  }

  /**
   * Handle friend request list
   */
  handleFriendRequestList(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const totalFriendRequests = conn.GetIntFrom(msg);
    const friendRequestCount = conn.GetIntFrom(msg);

    const component = this.getComponent() as FriendListComponent | null;
    const iface = this.getInterface() as FriendListInterface | null;

    for (let i = 0; i < friendRequestCount; i++) {
      const request = this.parseFriendRequest(msg);
      if (request && component) {
        component.addFriendRequest(request);
      }
    }

    if (iface) {
      iface.updateCategoryCounts();
    }
    if (component) {
      component.notifyFriendRequests();
    }
  }

  /**
   * Handle single friend request
   */
  handleFriendRequest(msg: HabboMessage): void {
    const request = this.parseFriendRequest(msg);
    if (!request) return;

    const component = this.getComponent() as FriendListComponent | null;
    const iface = this.getInterface() as FriendListInterface | null;

    if (component) {
      component.addFriendRequest(request);
      component.notifyFriendRequests();
    }
    if (iface) {
      iface.updateCategoryCounts();
    }
  }

  /**
   * Handle friend request result
   */
  handleFriendRequestResult(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const failureCount = conn.GetIntFrom(msg);
    const errorList = new Map<string, number>();

    for (let i = 0; i < failureCount; i++) {
      const senderName = conn.GetStrFrom(msg);
      const errorCode = conn.GetIntFrom(msg);
      errorList.set(senderName, errorCode);
    }

    const component = this.getComponent() as FriendListComponent | null;
    if (component) {
      component.setFriendRequestResult(errorList);
    }
  }

  /**
   * Handle follow failed
   */
  handleFollowFailed(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const failureType = conn.GetIntFrom(msg);
    let textKey: string;

    switch (failureType) {
      case FollowFailureType.NOT_FRIEND:
        textKey = 'console_follow_not_friend';
        break;
      case FollowFailureType.OFFLINE:
        textKey = 'console_follow_offline';
        break;
      case FollowFailureType.HOTELVIEW:
        textKey = 'console_follow_hotelview';
        break;
      case FollowFailureType.PREVENTED:
        textKey = 'console_follow_prevented';
        break;
      default:
        return;
    }

    executeMessage('alert', { Msg: textKey, id: 'follow_failure_notice' });
  }

  /**
   * Handle mail notification
   */
  handleMailNotification(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const userId = conn.GetStrFrom(msg);
    const component = this.getComponent() as FriendListComponent | null;
    if (component) {
      component.newMailFrom(userId);
    }
  }

  /**
   * Handle mail count notification
   */
  handleMailCountNotification(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const unreadMailCount = conn.GetIntFrom(msg);
    const component = this.getComponent() as FriendListComponent | null;
    if (component) {
      component.setUnreadMailCount(unreadMailCount);
    }
  }

  /**
   * Handle habbo search result
   */
  handleHabboSearchResult(msg: HabboMessage): void {
    const conn = msg.connection as HabboConnection;
    if (!conn) return;

    const resultFriendsCount = conn.GetIntFrom(msg);
    const resultsFriends: HabboSearchResult[] = [];
    for (let i = 0; i < resultFriendsCount; i++) {
      const result = this.parseHabboSearchResult(msg);
      if (result) {
        resultsFriends.push(result);
      }
    }

    const resultHabbosCount = conn.GetIntFrom(msg);
    const resultsHabbos: HabboSearchResult[] = [];
    for (let i = 0; i < resultHabbosCount; i++) {
      const result = this.parseHabboSearchResult(msg);
      if (result) {
        resultsHabbos.push(result);
      }
    }

    const component = this.getComponent() as FriendListComponent | null;
    const iface = this.getInterface() as FriendListInterface | null;

    if (component) {
      component.setHabboSearchResults(resultsFriends, resultsHabbos);
    }
    if (iface) {
      iface.showHabboSearchResults();
    }
  }

  /**
   * Parse friend request from message
   */
  parseFriendRequest(msg: HabboMessage): FriendRequest | null {
    const conn = msg.connection as HabboConnection;
    if (!conn) return null;

    return {
      id: String(conn.GetIntFrom(msg)),
      name: conn.GetStrFrom(msg),
      userID: conn.GetStrFrom(msg),
      state: 'pending',
    };
  }

  /**
   * Parse friend data from message
   */
  parseFriendData(msg: HabboMessage): FriendData | null {
    const conn = msg.connection as HabboConnection;
    if (!conn) return null;

    const friend: FriendData = {
      id: conn.GetIntFrom(msg),
      name: conn.GetStrFrom(msg),
      sex: conn.GetIntFrom(msg),
      online: conn.GetIntFrom(msg),
      canfollow: conn.GetIntFrom(msg),
      figure: conn.GetStrFrom(msg),
      categoryId: this.getSlotCatAlias(String(conn.GetIntFrom(msg))),
      mission: conn.GetStrFrom(msg),
      lastAccess: conn.GetStrFrom(msg),
    };

    // Fix category for offline friends
    const catIdNum = parseInt(friend.categoryId);
    if (catIdNum < 0) {
      friend.categoryId = '0';
    }
    if (friend.online === 0) {
      friend.categoryId = '-1';
    }

    return friend;
  }

  /**
   * Parse habbo search result from message
   */
  parseHabboSearchResult(msg: HabboMessage): HabboSearchResult | null {
    const conn = msg.connection as HabboConnection;
    if (!conn) return null;

    return {
      id: conn.GetIntFrom(msg),
      name: conn.GetStrFrom(msg),
      mission: conn.GetStrFrom(msg),
      online: conn.GetIntFrom(msg),
      canfollow: conn.GetIntFrom(msg),
      roomname: conn.GetStrFrom(msg),
      sex: conn.GetIntFrom(msg),
      figure: conn.GetStrFrom(msg),
      lastAccess: conn.GetStrFrom(msg),
    };
  }

  /**
   * Register/unregister message listeners and commands
   */
  private regMsgList(register: boolean): void {
    const connId = getVariable('connection.info.id', 'Info') as string;

    const messages: Record<number, string> = {
      [FriendListMessages.OK]: 'handleOk',
      [FriendListMessages.FRIENDLIST_INIT]: 'handleFriendListInit',
      [FriendListMessages.FRIENDLIST_UPDATE]: 'handleFriendListUpdate',
      [FriendListMessages.FRIENDLIST_REQUEST]: 'handleFriendRequest',
      [FriendListMessages.FRIENDLIST_ERROR]: 'handleError',
      [FriendListMessages.FRIENDLIST_REQUEST_LIST]: 'handleFriendRequestList',
      [FriendListMessages.FRIENDLIST_REQUEST_RESULT]: 'handleFriendRequestResult',
      [FriendListMessages.FOLLOW_FAILED]: 'handleFollowFailed',
      [FriendListMessages.MAIL_NOTIFICATION]: 'handleMailNotification',
      [FriendListMessages.MAIL_COUNT_NOTIFICATION]: 'handleMailCountNotification',
      [FriendListMessages.HABBO_SEARCH_RESULT]: 'handleHabboSearchResult',
    };

    const commands: Record<string, number> = {
      FRIENDLIST_INIT: FriendListCommands.FRIENDLIST_INIT,
      FRIENDLIST_UPDATE: FriendListCommands.FRIENDLIST_UPDATE,
      FRIENDLIST_GETOFFLINEFRIENDS: FriendListCommands.FRIENDLIST_GETOFFLINEFRIENDS,
      FRIENDLIST_REMOVEFRIEND: FriendListCommands.FRIENDLIST_REMOVEFRIEND,
      MESSENGER_HABBOSEARCH: FriendListCommands.MESSENGER_HABBOSEARCH,
      FRIENDLIST_ACCEPTFRIEND: FriendListCommands.FRIENDLIST_ACCEPTFRIEND,
      FRIENDLIST_DECLINEFRIEND: FriendListCommands.FRIENDLIST_DECLINEFRIEND,
      FRIENDLIST_FRIENDREQUEST: FriendListCommands.FRIENDLIST_FRIENDREQUEST,
      FRIENDLIST_GETFRIENDREQUESTS: FriendListCommands.FRIENDLIST_GETFRIENDREQUESTS,
      FOLLOW_FRIEND: FriendListCommands.FOLLOW_FRIEND,
    };

    if (register) {
      registerListener(connId, this.id, messages);
      registerCommands(connId, commands);
    } else {
      unregisterListener(connId, this.id, messages);
      unregisterCommands(connId, this.id, commands);
    }
  }
}
