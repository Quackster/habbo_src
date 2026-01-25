/**
 * Room Handler Class
 *
 * Ported from: hh_room/Cast External ParentScript 5 - Room Handler Class.ls
 *
 * Handles all incoming server messages related to room state,
 * users, objects, chat, and trading.
 */

import { messageBus } from '../../core/MessageBus';
import { getConnection, HabboConnection } from '../../network/HabboConnection';
import { getRoomComponent, RoomComponent } from './RoomComponent';
import { getRoomInterface, RoomInterface } from './RoomInterface';
import {
  ROOM_MESSAGE_IDS,
  ROOM_COMMANDS,
  RoomType,
  Direction,
  RoomLocation,
  UserObjectDef,
  ActiveObjectDef,
  PassiveObjectDef,
  ItemObjectDef,
  StatusUpdate,
  ActionDef,
  ChatMessage,
  SlideObjectData,
  GeometryConfig,
} from './types';

// Parser helpers
function parseDelimited(str: string, delimiter: string): string[] {
  return str.split(delimiter).filter(s => s.length > 0);
}

function parseKeyValue(str: string, pairDelim: string, kvDelim: string): Map<string, string> {
  const result = new Map<string, string>();
  const pairs = str.split(pairDelim);
  for (const pair of pairs) {
    const [key, value] = pair.split(kvDelim, 2);
    if (key) {
      result.set(key, value ?? '');
    }
  }
  return result;
}

/**
 * Room Handler Class
 */
export class RoomHandler {
  private id: string = 'room_handler';
  private component: RoomComponent;
  private interface: RoomInterface;
  private connection: HabboConnection | null = null;
  private connectionId: string = 'connection.room.id';

  // Message handlers map
  private handlers: Map<number, (data: string) => void> = new Map();

  constructor() {
    this.component = getRoomComponent();
    this.interface = getRoomInterface();

    this.registerHandlers();
  }

  /**
   * Register all message handlers
   */
  private registerHandlers(): void {
    const ids = ROOM_MESSAGE_IDS;

    this.handlers.set(ids.USERS, this.handleUsers.bind(this));
    this.handlers.set(ids.LOGOUT, this.handleLogout.bind(this));
    this.handlers.set(ids.OBJECTS, this.handleObjects.bind(this));
    this.handlers.set(ids.HEIGHTMAP, this.handleHeightmap.bind(this));
    this.handlers.set(ids.ACTIVEOBJECTS, this.handleActiveObjects.bind(this));
    this.handlers.set(ids.ITEMS, this.handleItems.bind(this));
    this.handlers.set(ids.STATUS, this.handleStatus.bind(this));
    this.handlers.set(ids.CHAT, this.handleChat.bind(this));
    this.handlers.set(ids.SHOUT, this.handleShout.bind(this));
    this.handlers.set(ids.WHISPER, this.handleWhisper.bind(this));
    this.handlers.set(ids.TRADE_ITEMS, this.handleTradeItems.bind(this));
    this.handlers.set(ids.TRADE_ACCEPT, this.handleTradeAccept.bind(this));
    this.handlers.set(ids.TRADE_CLOSE, this.handleTradeClose.bind(this));
    this.handlers.set(ids.TRADE_COMPLETED, this.handleTradeCompleted.bind(this));
    this.handlers.set(ids.FLATPROPERTY, this.handleFlatProperty.bind(this));
    this.handlers.set(ids.DOORBELL_RINGING, this.handleDoorbellRinging.bind(this));
    this.handlers.set(ids.ROOM_READY, this.handleRoomReady.bind(this));
    this.handlers.set(ids.YOUAROWNER, this.handleYouAreOwner.bind(this));
    this.handlers.set(ids.YOUARECONTROLLER, this.handleYouAreController.bind(this));
    this.handlers.set(ids.SLIDEOBJECTBUNDLE, this.handleSlideObjectBundle.bind(this));
    this.handlers.set(ids.OBJECTS_DATAUPDATE, this.handleObjectsDataUpdate.bind(this));
  }

  /**
   * Set the connection to use
   */
  setConnection(connection: HabboConnection): void {
    this.connection = connection;

    // Subscribe to messages
    for (const [msgId, handler] of this.handlers) {
      connection.onMessage(msgId, (data: string) => handler(data));
    }
  }

  /**
   * Get the room connection
   */
  getRoomConnection(): HabboConnection | null {
    return this.connection;
  }

  /**
   * Send a command to the server
   */
  send(command: keyof typeof ROOM_COMMANDS, params: unknown[] = []): void {
    if (!this.connection) {
      console.warn('RoomHandler: No connection available');
      return;
    }

    const msgId = ROOM_COMMANDS[command];
    this.connection.send(msgId, params);
  }

  // ==================== Message Handlers ====================

  /**
   * Handle users entering the room
   * Format: id\tname\tfigure\tx\ty\th\tdir\tcustom\tbadges\tswimfigure\twebid\tgroupid\tgroupstatus
   */
  private handleUsers(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split('\t');
      if (parts.length < 8) continue;

      const [id, name, figure, xStr, yStr, hStr, dirStr, custom, ...rest] = parts;

      const userDef: UserObjectDef = {
        id,
        name,
        figure,
        sex: figure.includes('M') ? 'M' : 'F', // Simplified
        x: parseInt(xStr, 10),
        y: parseInt(yStr, 10),
        h: parseFloat(hStr),
        direction: [parseInt(dirStr, 10) as Direction],
        custom,
      };

      // Parse optional fields
      if (rest.length > 0 && rest[0]) {
        // Parse badges (format: badge1,badge2,badge3)
        userDef.badge = {};
        const badges = rest[0].split(',');
        for (let i = 0; i < badges.length; i++) {
          if (badges[i]) {
            userDef.badge[`badge${i + 1}`] = badges[i];
          }
        }
      }

      if (rest.length > 1) userDef.swimFigure = rest[1];
      if (rest.length > 2) userDef.webId = parseInt(rest[2], 10);
      if (rest.length > 3) userDef.groupId = rest[3];
      if (rest.length > 4) userDef.groupStatus = rest[4];

      this.component.createUserObject(userDef);
    }
  }

  /**
   * Handle user leaving the room
   */
  private handleLogout(data: string): void {
    const userId = data.trim();
    this.component.removeUserObject(userId);
  }

  /**
   * Handle passive objects (walls, etc.)
   * Format: class x y dir\rclass x y dir\r...
   */
  private handleObjects(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split(' ');
      if (parts.length < 4) continue;

      const [objClass, xStr, yStr, dirStr] = parts;

      const objectDef: PassiveObjectDef = {
        id: `passive_${Date.now()}_${Math.random()}`,
        class: objClass,
        x: parseInt(xStr, 10),
        y: parseInt(yStr, 10),
        direction: [parseInt(dirStr, 10) as Direction],
      };

      this.component.createPassiveObject(objectDef);
    }
  }

  /**
   * Handle height map data
   */
  private handleHeightmap(data: string): void {
    this.interface.loadHeightMap(data, false);
    this.component.validateHeightMap();
  }

  /**
   * Handle active objects (floor furniture)
   * Format: id class x y h dir colors\rid class x y h dir colors\r...
   */
  private handleActiveObjects(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split(' ');
      if (parts.length < 6) continue;

      const [id, objClass, xStr, yStr, hStr, dirStr, ...rest] = parts;

      // Parse dimensions if present (format: class=widthxheight)
      let dimensions: [number, number] = [1, 1];
      let actualClass = objClass;
      if (objClass.includes('*')) {
        const [cls, dims] = objClass.split('*');
        actualClass = cls;
        if (dims) {
          const [w, h] = dims.split(',').map(Number);
          dimensions = [w || 1, h || 1];
        }
      }

      const objectDef: ActiveObjectDef = {
        id,
        class: actualClass,
        x: parseInt(xStr, 10),
        y: parseInt(yStr, 10),
        altitude: parseFloat(hStr),
        direction: [parseInt(dirStr, 10) as Direction],
        dimensions,
        colors: rest[0] || undefined,
      };

      this.component.createActiveObject(objectDef);
    }
  }

  /**
   * Handle wall items
   * Format: id class type wallx wally localx localy direction
   */
  private handleItems(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split('\t');
      if (parts.length < 8) continue;

      const [id, objClass, type, wallXStr, wallYStr, localXStr, localYStr, direction] = parts;

      const itemDef: ItemObjectDef = {
        id,
        class: objClass,
        type,
        x: 0,
        y: 0,
        wallX: parseInt(wallXStr, 10),
        wallY: parseInt(wallYStr, 10),
        localX: parseInt(localXStr, 10),
        localY: parseInt(localYStr, 10),
        formatVersion: 'new',
        direction: direction as 'leftwall' | 'rightwall',
      };

      this.component.createItemObject(itemDef);
    }
  }

  /**
   * Handle status updates for users
   * Format: id x,y,h/action1 param/action2 param\rid x,y,h/action1 param\r...
   */
  private handleStatus(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split(' ');
      if (parts.length < 2) continue;

      const id = parts[0];
      const locationParts = parts[1].split(',');

      if (locationParts.length < 3) continue;

      const x = parseInt(locationParts[0], 10);
      const y = parseInt(locationParts[1], 10);
      const h = parseFloat(locationParts[2].split('/')[0]);

      // Parse directions and actions
      let headDir: Direction = 0;
      let bodyDir: Direction = 0;
      const actions: ActionDef[] = [];

      // The rest after location contains actions
      const actionStr = parts.slice(2).join(' ');
      const actionParts = actionStr.split('/').filter(s => s.length > 0);

      for (const action of actionParts) {
        const [name, ...paramParts] = action.split(' ');
        const params = paramParts.join(' ');

        if (name === 'mv') {
          actions.push({ name: 'mv', params });
        } else if (name === 'sit') {
          actions.push({ name: 'sit', params });
        } else if (name === 'lay') {
          actions.push({ name: 'lay', params });
        } else if (name === 'dance') {
          actions.push({ name: 'dance', params });
        } else if (name === 'wave') {
          actions.push({ name: 'wave', params: '' });
        } else if (name === 'flatctrl') {
          actions.push({ name: 'flatctrl', params });
        } else if (name === 'sign') {
          actions.push({ name: 'sign', params });
        } else if (name === 'carryd' || name === 'carryf' || name === 'cri') {
          actions.push({ name, params });
        } else if (name === 'trd') {
          actions.push({ name: 'trd', params: '' });
        } else if (name === 'fx') {
          actions.push({ name: 'fx', params });
        } else if (name === 'gest') {
          actions.push({ name: 'gest', params });
        } else if (name.match(/^\d$/)) {
          // Direction update (single digit is body direction)
          bodyDir = parseInt(name, 10) as Direction;
          if (paramParts[0]?.match(/^\d$/)) {
            headDir = parseInt(paramParts[0], 10) as Direction;
          } else {
            headDir = bodyDir;
          }
        }
      }

      const update: StatusUpdate = {
        id,
        x,
        y,
        h,
        headDirection: headDir,
        bodyDirection: bodyDir,
        actions,
      };

      this.component.updateUserStatus(update);
    }
  }

  /**
   * Handle chat message
   */
  private handleChat(data: string): void {
    const [userId, message] = data.split('\r', 2);

    this.component.handleChat({
      userId,
      message,
      type: 'chat',
    });
  }

  /**
   * Handle shout message
   */
  private handleShout(data: string): void {
    const [userId, message] = data.split('\r', 2);

    this.component.handleChat({
      userId,
      message,
      type: 'shout',
    });
  }

  /**
   * Handle whisper message
   */
  private handleWhisper(data: string): void {
    const [userId, message] = data.split('\r', 2);

    this.component.handleChat({
      userId,
      message,
      type: 'whisper',
    });
  }

  /**
   * Handle trade items update
   */
  private handleTradeItems(data: string): void {
    const parts = data.split('\r');
    if (parts.length < 2) return;

    const ownItems = parts[0].split('\t').filter(s => s.length > 0);
    const partnerItems = parts[1].split('\t').filter(s => s.length > 0);

    this.component.updateTradeItems(ownItems, partnerItems);
  }

  /**
   * Handle trade acceptance
   */
  private handleTradeAccept(data: string): void {
    const [ownStr, partnerStr] = data.split('\r');
    const ownAccepted = ownStr === '1';
    const partnerAccepted = partnerStr === '1';

    this.component.setTradeAcceptance(ownAccepted, partnerAccepted);
  }

  /**
   * Handle trade close
   */
  private handleTradeClose(data: string): void {
    this.component.closeTrade();
  }

  /**
   * Handle trade completed
   */
  private handleTradeCompleted(data: string): void {
    this.component.closeTrade();
    messageBus.emit('trade:completed', {});
  }

  /**
   * Handle flat property (room settings)
   */
  private handleFlatProperty(data: string): void {
    const kv = parseKeyValue(data, '\r', '=');

    messageBus.emit('room:propertyUpdated', {
      properties: Object.fromEntries(kv),
    });
  }

  /**
   * Handle doorbell ringing
   */
  private handleDoorbellRinging(data: string): void {
    const userName = data.trim();
    messageBus.emit('room:doorbellRinging', { userName });
  }

  /**
   * Handle room ready (initial setup)
   */
  private handleRoomReady(data: string): void {
    const parts = data.split(' ');
    if (parts.length < 2) return;

    const model = parts[0];
    const roomId = parts[1];

    messageBus.emit('room:ready', { model, roomId });
  }

  /**
   * Handle "you are owner" message
   */
  private handleYouAreOwner(data: string): void {
    this.component.setOwner(true);
  }

  /**
   * Handle "you are controller" message
   */
  private handleYouAreController(data: string): void {
    const level = parseInt(data.trim(), 10);
    this.component.setControllerLevel(level);
  }

  /**
   * Handle sliding objects (furniture on rollers)
   */
  private handleSlideObjectBundle(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split(' ');
      if (parts.length < 7) continue;

      const [objectId, fromXStr, fromYStr, fromHStr, toXStr, toYStr, toHStr, hasChar] = parts;

      const slideData: SlideObjectData = {
        objectId,
        fromLoc: {
          x: parseInt(fromXStr, 10),
          y: parseInt(fromYStr, 10),
          h: parseFloat(fromHStr),
        },
        toLoc: {
          x: parseInt(toXStr, 10),
          y: parseInt(toYStr, 10),
          h: parseFloat(toHStr),
        },
        startTime: Date.now(),
        hasCharacter: hasChar === '1',
      };

      // Check if it's a user or furniture
      const user = this.component.getUserObject(objectId);
      const activeObj = this.component.getActiveObject(objectId);

      if (user) {
        user.actionMv(slideData.toLoc.x, slideData.toLoc.y, slideData.toLoc.h);
      } else if (activeObj) {
        activeObj.setSlideTo(
          slideData.fromLoc,
          slideData.toLoc,
          slideData.startTime,
          slideData.hasCharacter
        );
        this.component.addSlideObject(slideData);
      }
    }
  }

  /**
   * Handle object data update (furniture state change)
   */
  private handleObjectsDataUpdate(data: string): void {
    const lines = data.split('\r').filter(line => line.length > 0);

    for (const line of lines) {
      const parts = line.split('\t');
      if (parts.length < 2) continue;

      const [objectId, state] = parts;

      // Try active object first
      this.component.updateActiveObjectData(objectId, state);

      // Then item object
      this.component.updateItemObjectState(objectId, state);
    }
  }

  // ==================== Command Senders ====================

  /**
   * Send move command
   */
  sendMove(x: number, y: number): void {
    this.send('MOVE', [x, y]);
  }

  /**
   * Send chat message
   */
  sendChat(message: string): void {
    this.send('CHAT', [message]);
  }

  /**
   * Send shout message
   */
  sendShout(message: string): void {
    this.send('SHOUT', [message]);
  }

  /**
   * Send whisper message
   */
  sendWhisper(userId: string, message: string): void {
    this.send('WHISPER', [userId, message]);
  }

  /**
   * Send look-at command
   */
  sendLookTo(x: number, y: number): void {
    this.send('LOOKTO', [x, y]);
  }

  /**
   * Send wave action
   */
  sendWave(): void {
    this.send('WAVE', []);
  }

  /**
   * Send dance action
   */
  sendDance(style: number): void {
    this.send('DANCE', [style]);
  }

  /**
   * Send sign action
   */
  sendSign(signId: number): void {
    this.send('SIGN', [signId]);
  }

  /**
   * Send place furniture command
   */
  sendPlaceStuff(stripId: number, x: number, y: number, direction: number): void {
    this.send('PLACESTUFF', [stripId, x, y, direction]);
  }

  /**
   * Send move furniture command
   */
  sendMoveStuff(objectId: number, x: number, y: number, direction: number): void {
    this.send('MOVESTUFF', [objectId, x, y, direction]);
  }

  /**
   * Send set furniture data command
   */
  sendSetStuffData(objectId: number, data: string): void {
    this.send('SETSTUFFDATA', [objectId, data]);
  }

  /**
   * Send remove furniture command
   */
  sendRemoveStuff(objectId: number): void {
    this.send('REMOVESTUFF', [objectId]);
  }

  /**
   * Send open trade request
   */
  sendTradeOpen(userId: number): void {
    this.send('TRADE_OPEN', [userId]);
    this.component.openTrade(userId.toString());
  }

  /**
   * Send add item to trade
   */
  sendTradeAddItem(stripId: number): void {
    this.send('TRADE_ADDITEM', [stripId]);
  }

  /**
   * Send remove item from trade
   */
  sendTradeRemoveItem(stripId: number): void {
    this.send('TRADE_REMOVEITEM', [stripId]);
  }

  /**
   * Send accept trade
   */
  sendTradeAccept(): void {
    this.send('TRADE_ACCEPT', []);
  }

  /**
   * Send unaccept trade
   */
  sendTradeUnaccept(): void {
    this.send('TRADE_UNACCEPT', []);
  }

  /**
   * Send close trade
   */
  sendTradeClose(): void {
    this.send('TRADE_CLOSE', []);
    this.component.closeTrade();
  }

  /**
   * Send confirm trade
   */
  sendTradeConfirm(): void {
    this.send('TRADE_CONFIRM', []);
  }

  /**
   * Send assign rights
   */
  sendAssignRights(userId: number): void {
    this.send('ASSIGNRIGHTS', [userId]);
  }

  /**
   * Send remove rights
   */
  sendRemoveRights(userId: number): void {
    this.send('REMOVERIGHTS', [userId]);
  }

  /**
   * Send kick user
   */
  sendKickUser(userId: number): void {
    this.send('KICKUSER', [userId]);
  }

  /**
   * Send let user in (doorbell response)
   */
  sendLetUserIn(userName: string, allow: boolean): void {
    this.send('LETUSERIN', [userName, allow ? 1 : 0]);
  }

  /**
   * Send give respect
   */
  sendGiveRespect(userId: number): void {
    this.send('GIVERESPECT', [userId]);
  }
}

// Singleton instance
let roomHandlerInstance: RoomHandler | null = null;

export function getRoomHandler(): RoomHandler {
  if (!roomHandlerInstance) {
    roomHandlerInstance = new RoomHandler();
  }
  return roomHandlerInstance;
}

export function resetRoomHandler(): void {
  roomHandlerInstance = null;
}
