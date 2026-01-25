/**
 * Club Interface Class - UI management for Habbo Club
 *
 * Ported from: hh_club/Cast External ParentScript 2 - Club Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { executeMessage } from '../../core/MessageBus';
import { getVariable, variableExists } from '../../core/VariableContainer';
import { session } from '../../core/Session';
import { ClubStatus, ClubResponseFlag, ClubSubscriptionLength } from './types';
import { ClubComponent } from './ClubComponent';

export class ClubInterface extends BaseInterface {
  private pWindowId: string = 'clubinfo_window';
  private pGiftDialogId: string = 'clubgift_window';
  private pChosenLength: ClubSubscriptionLength = 1;
  private pSubscribeFromHotel: boolean = true;

  construct(): void {
    super.construct();

    if (variableExists('club.subscription.disabled')) {
      this.pSubscribeFromHotel = !(getVariable('club.subscription.disabled') as number > 0);
    }

    this.registerMsg('show_clubinfo', 'showClubInfo');
  }

  deconstruct(): void {
    super.deconstruct();
  }

  /**
   * Show gift info dialog
   *
   * Lingo: createWindow(pGiftDialogID, "clubgift.window", VOID, VOID, #modal)
   */
  async showGiftInfo(): Promise<void> {
    await this.createModalWindow(this.pGiftDialogId, 'clubgift.window');
    this.registerWindowProcedure(this.pGiftDialogId, 'giftDialogEventProc');

    // Set dialog text
    if (this.elementExists(this.pGiftDialogId, 'title_text')) {
      this.setText(this.pGiftDialogId, 'title_text', 'Club Gift');
    }
    if (this.elementExists(this.pGiftDialogId, 'body_text')) {
      this.setText(this.pGiftDialogId, 'body_text', 'You have a gift waiting!');
    }
  }

  /**
   * Setup ended window
   *
   * Lingo: setupEndedWindow()
   */
  private setupEndedWindow(): void {
    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    const status = component.getStatus();
    if (!status) return;

    // Set elapsed periods text
    if (this.elementExists(this.pWindowId, 'elapsed_text')) {
      this.setText(this.pWindowId, 'elapsed_text', `${status.elapsedPeriods} months`);
    }
  }

  /**
   * Setup status window
   *
   * Lingo: setupStatusWindow(type)
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

    // Update days left text
    if (this.elementExists(this.pWindowId, 'days_left_text')) {
      this.setText(this.pWindowId, 'days_left_text', `${daysLeft} days left`);
    }

    // Update elapsed periods text
    if (this.elementExists(this.pWindowId, 'elapsed_text')) {
      this.setText(this.pWindowId, 'elapsed_text', `${elapsed} months`);
    }

    // Update prepaid periods text
    if (this.elementExists(this.pWindowId, 'prepaid_text')) {
      this.setText(this.pWindowId, 'prepaid_text', `${prepaid} months prepaid`);
    }

    // Position day indicator arrow
    if (this.elementExists(this.pWindowId, 'day_arrow')) {
      this.setElementProperty(this.pWindowId, 'day_arrow', 'locH', arrowOffset);
    }

    // Show/hide first timer message
    if (this.elementExists(this.pWindowId, 'first_timer_msg')) {
      if (type === 'FirstTimer') {
        this.showElement(this.pWindowId, 'first_timer_msg');
      } else {
        this.hideElement(this.pWindowId, 'first_timer_msg');
      }
    }

    // Hide extend button if prepaid is -1
    if (prepaid === -1 && this.elementExists(this.pWindowId, 'club_button_extend')) {
      this.hideElement(this.pWindowId, 'club_button_extend');
    }
  }

  /**
   * Change texts to extend mode
   *
   * Lingo: changeTextsToExtend()
   */
  private changeTextsToExtend(): void {
    if (this.elementExists(this.pWindowId, 'header_text')) {
      this.setText(this.pWindowId, 'header_text', 'Extend Your Subscription');
    }
    if (this.elementExists(this.pWindowId, 'body_text')) {
      this.setText(this.pWindowId, 'body_text', 'Extend your Habbo Club subscription.');
    }
  }

  /**
   * Setup buy window
   *
   * Lingo: setupBuyWindow()
   */
  private setupBuyWindow(): void {
    // Configure buy window elements
    // Prices would come from variables
  }

  /**
   * Replace credits text in confirm dialog
   *
   * Lingo: replaceCreditsText()
   */
  private replaceCreditsText(): void {
    const credits = session.GET<number>('user_walletbalance') ?? 0;

    if (this.elementExists(this.pWindowId, 'credits_text')) {
      this.setText(this.pWindowId, 'credits_text', `You have ${credits} credits`);
    }
    if (this.elementExists(this.pWindowId, 'period_text')) {
      this.setText(this.pWindowId, 'period_text', `${this.pChosenLength} month(s)`);
    }
  }

  /**
   * Show club info
   *
   * Lingo: showClubInfo()
   */
  async showClubInfo(): Promise<boolean> {
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
      if (!this.pSubscribeFromHotel) {
        this.openBuyInHabboWeb();
        return true;
      }

      await this.createModalWindow(this.pWindowId, 'clubbuy.window');
      this.registerWindowProcedure(this.pWindowId, 'eventProc');
      this.setupBuyWindow();
    } else if (status.daysLeft === 0 && status.elapsedPeriods > 0) {
      // Was a member, expired
      await this.createModalWindow(this.pWindowId, 'clubended.window');
      this.registerWindowProcedure(this.pWindowId, 'eventProc');
      this.setupEndedWindow();
    } else {
      // Active member
      await this.createModalWindow(this.pWindowId, 'clubstatus.window');
      this.registerWindowProcedure(this.pWindowId, 'eventProc');
      this.setupStatusWindow();
    }

    return true;
  }

  /**
   * Update club status
   *
   * Lingo: updateClubStatus(status, responseFlag, oldStatus)
   */
  async updateClubStatus(status: ClubStatus, responseFlag: number, oldStatus: ClubStatus | null): Promise<void> {
    if (responseFlag === ClubResponseFlag.PURCHASED) {
      // Just purchased - show status window
      await this.createModalWindow(this.pWindowId, 'clubstatus.window');
      this.registerWindowProcedure(this.pWindowId, 'eventProc');

      const isFirstTimer = oldStatus?.elapsedPeriods === 0 && oldStatus?.daysLeft === 0;
      this.setupStatusWindow(isFirstTimer ? 'FirstTimer' : 'BeenHcBefore');

      executeMessage('refresh_catalogue', 'club');
    } else if (responseFlag === ClubResponseFlag.EXPIRED) {
      // Subscription expired
      await this.createModalWindow(this.pWindowId, 'clubended.window');
      this.registerWindowProcedure(this.pWindowId, 'eventProc');
      this.setupEndedWindow();
    }
  }

  /**
   * Open buy page in Habbo web
   *
   * Lingo: openBuyInHabboWeb()
   */
  openBuyInHabboWeb(): boolean {
    executeMessage('externalLinkClick');
    // Would open external URL
    return true;
  }

  /**
   * Show buy window
   *
   * Lingo: Shows buy selection after extend click
   */
  private async showBuyWindow(): Promise<void> {
    // Merge buy layout
    await this.mergeWindow(this.pWindowId, 'clubbuy_selection.window');
    this.changeTextsToExtend();
  }

  /**
   * Show confirm window
   *
   * Lingo: Shows confirmation dialog
   */
  private async showConfirmWindow(): Promise<void> {
    await this.mergeWindow(this.pWindowId, 'clubbuy_confirm.window');
    this.replaceCreditsText();
  }

  /**
   * Main window event procedure
   *
   * Lingo: eventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  override eventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    switch (spriteId) {
      case 'club_button_extend':
        if (!this.pSubscribeFromHotel) {
          this.openBuyInHabboWeb();
          this.removeWindow(this.pWindowId);
          return;
        }
        this.showBuyWindow();
        break;

      case 'club_isp_change':
        // Open ISP change URL
        break;

      case 'club_intro_link':
      case 'club_general_infolink':
        // Open club info URL
        break;

      case 'club_isp_buy':
        // Open ISP buy URL
        break;

      case 'club_button_1_period':
        this.pChosenLength = 1;
        this.showConfirmWindow();
        break;

      case 'club_button_2_period':
        this.pChosenLength = 2;
        this.showConfirmWindow();
        break;

      case 'club_button_3_period':
        this.pChosenLength = 3;
        this.showConfirmWindow();
        break;

      case 'club_confirm_ok':
        component.subscribe(this.pChosenLength);
        this.removeWindow(this.pWindowId);
        break;

      case 'club_confirm_cancel':
      case 'club_button_close':
      case 'close':
        this.removeWindow(this.pWindowId);
        break;
    }
  }

  /**
   * Gift dialog event procedure
   *
   * Lingo: giftDialogEventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  giftDialogEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as ClubComponent | null;
    if (!component) return;

    switch (spriteId) {
      case 'club_confirm_ok':
        this.removeWindow(this.pGiftDialogId);
        component.acceptGift();
        break;

      case 'club_confirm_cancel':
      case 'club_button_close':
        this.removeWindow(this.pGiftDialogId);
        component.rejectGift();
        break;

      case 'close':
        component.resetGiftList();
        break;
    }
  }

  /**
   * Can subscribe from hotel
   */
  canSubscribeFromHotel(): boolean {
    return this.pSubscribeFromHotel;
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }
}
