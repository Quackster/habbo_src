/**
 * Room GUI Class - Main room UI coordinator
 *
 * Ported from: hh_room_ui/Cast External ParentScript 2 - Room GUI Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { RoomBar } from './RoomBar';
import { RoomInfo } from './RoomInfo';
import { RoomObjectDisplayer } from './RoomObjectDisplayer';
import { EffectInventory } from './EffectInventory';
import { ObjectDisplayType, RoomBarLayout } from './types';

/**
 * Room GUI - coordinates all room UI components
 */
export class RoomGUI extends BaseObject {
  private pRoomBarID: string = 'RoomBarProgram';
  private pRoomInfoID: string = 'RoomInfoProgram';
  private pObjectDispID: string = 'ObjectDisplayerProgram';
  private pBadgeObjID: string = 'room.obj.disp.badge.mngr';
  private pFxInvObjID: string = 'room.obj.fx.inventory';

  private roomBar: RoomBar | null = null;
  private roomInfo: RoomInfo | null = null;
  private objectDisplayer: RoomObjectDisplayer | null = null;
  private effectInventory: EffectInventory | null = null;

  construct(): void {
    super.construct();

    // Create sub-components
    this.roomInfo = new RoomInfo();
    this.roomInfo.construct();

    this.roomBar = new RoomBar();
    this.roomBar.construct();

    this.objectDisplayer = new RoomObjectDisplayer();
    this.objectDisplayer.construct();

    this.effectInventory = new EffectInventory();
    this.effectInventory.construct();

    // Would register for takingPhoto message
  }

  deconstruct(): void {
    // Would unregister takingPhoto message

    this.effectInventory?.deconstruct();
    this.objectDisplayer?.deconstruct();
    this.roomBar?.deconstruct();
    this.roomInfo?.deconstruct();

    this.effectInventory = null;
    this.objectDisplayer = null;
    this.roomBar = null;
    this.roomInfo = null;

    super.deconstruct();
  }

  /**
   * Get badge manager object
   */
  getBadgeObject(): unknown {
    // Would return badge manager
    return null;
  }

  /**
   * Get FX inventory
   */
  getFxInventory(): EffectInventory | null {
    return this.effectInventory;
  }

  /**
   * Get room bar
   */
  getRoomBar(): RoomBar | null {
    return this.roomBar;
  }

  /**
   * Get room info
   */
  getRoomInfo(): RoomInfo | null {
    return this.roomInfo;
  }

  /**
   * Get object displayer
   */
  getObjectDisplayer(): RoomObjectDisplayer | null {
    return this.objectDisplayer;
  }

  /**
   * Show room bar
   */
  showRoomBar(layout?: RoomBarLayout): void {
    this.roomInfo?.showRoomInfo();
    this.roomBar?.showRoomBar(layout);

    // Would check for tutorial chat help
    // if (threadExists('new_user_help')) {
    //   const component = getThread('new_user_help').getComponent();
    //   if (component.isChatHelpOn()) {
    //     this.roomBar?.applyChatHelpText();
    //   }
    // }
  }

  /**
   * Hide room bar
   */
  hideRoomBar(): void {
    this.roomInfo?.hideRoomInfo();
    this.roomBar?.hideRoomBar();
  }

  /**
   * Set rollover info text
   */
  setRollOverInfo(infoText: string): void {
    this.roomBar?.setRollOverInfo(infoText);
  }

  /**
   * Show infostand (placeholder)
   */
  showInfostand(): void {
    // Currently does nothing
  }

  /**
   * Hide infostand
   */
  hideInfoStand(): void {
    this.objectDisplayer?.clearWindowDisplayList();
  }

  /**
   * Show object info in infostand
   */
  showObjectInfo(objType: ObjectDisplayType): void {
    this.emit('process_tracking', 780);
    this.objectDisplayer?.showObjectInfo(objType);
    this.emit('process_tracking', 781);
  }

  /**
   * Show vote UI
   */
  showVote(): void {
    this.roomBar?.showVote();
  }
}
