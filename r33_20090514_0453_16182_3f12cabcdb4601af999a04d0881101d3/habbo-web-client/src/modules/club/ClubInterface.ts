/**
 * Club Interface Class - UI management for Habbo Club
 *
 * Ported from: hh_club/Cast External ParentScript 2 - Club Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getVariable, variableExists } from '../../core/VariableContainer';
import { session } from '../../core/Session';
import { EventEmitter } from '../../core/events';
import { ClubStatus, ClubResponseFlag, ClubSubscriptionLength } from './types';
import { ClubComponent } from './ClubComponent';

export class ClubInterface extends BaseObject {
  private dialogId: string = 'window_clubinfo1';
  private giftDialogId: string = 'window_clubgift';
  private chosenLength: ClubSubscriptionLength = 1;
  private subscribeFromHotel: boolean = true;
  private events: EventEmitter = new EventEmitter();

  construct(): void {
    super.construct();

    if (variableExists('club.subscription.disabled')) {
      this.subscribeFromHotel = !(getVariable('club.subscription.disabled') as number > 0);
    }

    registerMessage('show_clubinfo', this.id, 'showClubInfo');
  }

  deconstruct(): void {
    unregisterMessage('show_clubinfo', this.id);
    super.deconstruct();
  }

  /**
   * Show gift info dialog
   */
  showGiftInfo(): void {
    this.events.emit('showGiftDialog', {
      id: this.giftDialogId,
      title: 'Club Gift', // getText("club_confirm_gift_title")
      text: 'You have a gift waiting!', // getText("club_confirm_gift_text")
    });
  }

  /**
   * Setup ended window
   */
  private setupEndedWindow(): void {
    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    const status = component.getStatus();
    if (!status) return;

    this.events.emit('setupEndedWindow', {
      id: this.dialogId,
      elapsedPeriods: status.elapsedPeriods,
    });
  }

  /**
   * Setup status window
   */
  private setupStatusWindow(type?: 'FirstTimer' | 'BeenHcBefore'): void {
    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    const status = component.getStatus();
    if (!status) return;

    const daysLeft = status.daysLeft;
    const elapsed = status.elapsedPeriods;
    const prepaid = status.prepaidPeriods;

    // Calculate arrow position (day indicator)
    const arrowOffset = (31 - daysLeft) * 5;

    this.events.emit('setupStatusWindow', {
      id: this.dialogId,
      daysLeft,
      elapsedPeriods: elapsed,
      prepaidPeriods: prepaid,
      arrowOffset,
      isFirstTimer: type === 'FirstTimer',
      hideExtend: prepaid === -1,
    });
  }

  /**
   * Change texts to extend mode
   */
  private changeTextsToExtend(): void {
    this.events.emit('changeToExtendMode', {
      id: this.dialogId,
      headerText: 'Extend Your Subscription', // getText("club_extend_title")
      bodyText: 'Extend your Habbo Club subscription.', // getText("club_extend_text")
    });
  }

  /**
   * Setup buy window
   */
  private setupBuyWindow(): void {
    this.events.emit('setupBuyWindow', {
      id: this.dialogId,
    });
  }

  /**
   * Replace credits text in confirm dialog
   */
  private replaceCreditsText(): void {
    const credits = session.GET<number>('user_walletbalance') ?? 0;

    this.events.emit('updateCreditsText', {
      id: this.dialogId,
      credits,
      length: this.chosenLength,
    });
  }

  /**
   * Show club info
   */
  showClubInfo(): boolean {
    const component = this.getComponent() as ClubComponent | null;
    if (!component) return false;

    const status = component.getStatus();
    if (!status) return false;

    // Check if hotel is closing
    const hotelClosing = { showDialog: true, retval: 0 };
    executeMessage('getHotelClosingStatus', hotelClosing);
    if (hotelClosing.retval === 1) {
      return true;
    }

    if (status.daysLeft === 0 && status.elapsedPeriods === 0) {
      // Never been a member
      if (!this.subscribeFromHotel) {
        this.openBuyInHabboWeb();
        return true;
      }

      this.events.emit('showBuyWindow', {
        id: this.dialogId,
        useJpLayout: false, // getText("club_paybycash_url").startsWith("http")
      });
      this.setupBuyWindow();
    } else if (status.daysLeft === 0 && status.elapsedPeriods > 0) {
      // Was a member, expired
      this.events.emit('showEndedWindow', {
        id: this.dialogId,
      });
      this.setupEndedWindow();
    } else {
      // Active member
      this.events.emit('showStatusWindow', {
        id: this.dialogId,
      });
      this.setupStatusWindow();
    }

    return true;
  }

  /**
   * Update club status
   */
  updateClubStatus(status: ClubStatus, responseFlag: number, oldStatus: ClubStatus | null): void {
    if (responseFlag === ClubResponseFlag.PURCHASED) {
      // Just purchased
      this.events.emit('showStatusWindow', {
        id: this.dialogId,
      });

      const isFirstTimer = oldStatus?.elapsedPeriods === 0 && oldStatus?.daysLeft === 0;
      this.setupStatusWindow(isFirstTimer ? 'FirstTimer' : 'BeenHcBefore');

      executeMessage('refresh_catalogue', 'club');
    } else if (responseFlag === ClubResponseFlag.EXPIRED) {
      // Subscription expired
      this.events.emit('showEndedWindow', {
        id: this.dialogId,
        modal: true,
      });
      this.setupEndedWindow();
    }
  }

  /**
   * Open buy page in Habbo web
   */
  openBuyInHabboWeb(): boolean {
    this.events.emit('openExternalBuy');
    executeMessage('externalLinkClick');
    return true;
  }

  /**
   * Handle dialog events
   */
  handleDialogEvent(event: string, elementId: string): void {
    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    switch (elementId) {
      case 'club_button_extend':
        if (!this.subscribeFromHotel) {
          this.openBuyInHabboWeb();
          this.events.emit('closeWindow', { id: this.dialogId });
          return;
        }
        this.events.emit('showBuyWindow', { id: this.dialogId });
        this.changeTextsToExtend();
        break;

      case 'club_isp_change':
        this.events.emit('openIspChange');
        break;

      case 'club_intro_link':
      case 'club_general_infolink':
        this.events.emit('openClubInfo');
        break;

      case 'club_isp_buy':
        this.events.emit('openIspBuy');
        break;

      case 'club_button_1_period':
        this.chosenLength = 1;
        this.events.emit('showConfirmWindow', { id: this.dialogId });
        this.replaceCreditsText();
        break;

      case 'club_button_2_period':
        this.chosenLength = 2;
        this.events.emit('showConfirmWindow', { id: this.dialogId });
        this.replaceCreditsText();
        break;

      case 'club_button_3_period':
        this.chosenLength = 3;
        this.events.emit('showConfirmWindow', { id: this.dialogId });
        this.replaceCreditsText();
        break;

      case 'club_confirm_ok':
        component.subscribe(this.chosenLength);
        this.events.emit('closeWindow', { id: this.dialogId });
        break;

      case 'club_confirm_cancel':
      case 'club_button_close':
      case 'close':
        this.events.emit('closeWindow', { id: this.dialogId });
        break;
    }
  }

  /**
   * Handle gift dialog events
   */
  handleGiftDialogEvent(event: string, elementId: string): void {
    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    switch (elementId) {
      case 'club_confirm_ok':
        this.events.emit('closeWindow', { id: this.giftDialogId });
        component.acceptGift();
        break;

      case 'club_confirm_cancel':
      case 'club_button_close':
        this.events.emit('closeWindow', { id: this.giftDialogId });
        component.rejectGift();
        break;

      case 'close':
        component.resetGiftList();
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
   * Can subscribe from hotel
   */
  canSubscribeFromHotel(): boolean {
    return this.subscribeFromHotel;
  }
}
