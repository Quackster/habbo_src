/**
 * Entry Interface Class - UI layer for entry/hotel view
 *
 * Ported from:
 * - hh_entry/Cast External ParentScript 3 - Entry Interface Class.ls
 * - hh_entry_base/Cast External ParentScript 3 - Entry Interface Class.ls
 *
 * Supports configurable regional hotel views with different animations.
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { session } from '../../core/Session';
import { EventEmitter } from '../../core/events';
import {
  EntryConfig,
  HotelRegion,
  RegionalConfigs,
  HotelViewAnimation,
  RegionalHotelConfig,
} from './types';
import {
  IHotelViewAnimation,
  createAnimation,
  SwapAnimation,
} from './animations';

export interface EntryBarElements {
  username: string;
  mission: string;
  credits: string;
  clubStatus: string;
  newMessages: number;
  buddyRequests: number;
}

export class EntryInterface extends BaseObject {
  // Configuration
  private config: EntryConfig | null = null;
  private regionalConfig: RegionalHotelConfig;

  // Visual identifiers
  private entryVisual: string = 'entry_view';
  private bottomBar: string = 'entry_bar';

  // Animation timing
  private viewMaxTime: number = 500;
  private viewOpenTime: number | null = null;
  private viewCloseTime: number | null = null;

  // Animation state
  private animUpdate: boolean = false;
  private updateTasks: Set<string> = new Set();
  private animationFrameId: number | null = null;

  // Hotel view animations
  private hotelAnimations: IHotelViewAnimation[] = [];
  private swapAnimations: SwapAnimation[] = [];

  // Entry bar state
  private inActiveIconBlend: number = 40;
  private newMsgCount: number = 0;
  private newBuddyRequests: number = 0;
  private clubDaysCount: number = 0;
  private messengerFlash: boolean = false;
  private firstInit: boolean = true;
  private imFlashState: boolean = false;
  private flashIntervalId: number | null = null;
  private disableRoomEvents: boolean = false;
  private useWideEntryBar: boolean = false;

  // Events for UI binding
  private events: EventEmitter = new EventEmitter();

  constructor(config?: Partial<EntryConfig>) {
    super();

    // Set default region
    this.regionalConfig = RegionalConfigs.default;

    if (config) {
      this.configure(config);
    }
  }

  /**
   * Configure the entry interface
   */
  configure(config: Partial<EntryConfig>): void {
    this.config = {
      entryType: config.entryType ?? 'auto',
      region: config.region ?? 'default',
      connection: config.connection ?? { host: 'localhost', port: 12321 },
      ...config,
    };

    // Set regional config
    this.regionalConfig = RegionalConfigs[this.config.region] ?? RegionalConfigs.default;

    // Apply custom animations if provided
    if (this.config.customAnimations) {
      this.regionalConfig = {
        ...this.regionalConfig,
        animations: this.config.customAnimations,
      };
    }

    this.disableRoomEvents = this.config.disableRoomEvents ?? false;
    this.useWideEntryBar = this.config.useWideEntryBar ?? false;
  }

  /**
   * Set the hotel region dynamically
   */
  setRegion(region: HotelRegion): void {
    this.regionalConfig = RegionalConfigs[region] ?? RegionalConfigs.default;

    // Restart hotel view if currently visible
    if (this.hotelAnimations.length > 0) {
      this.hideHotel();
      this.showHotel();
    }

    this.events.emit('regionChanged', region);
  }

  /**
   * Get current region
   */
  getRegion(): HotelRegion {
    return this.regionalConfig.region;
  }

  construct(): void {
    super.construct();

    registerMessage('userlogin', this.id, 'showEntryBar');
    registerMessage('showHotelView', this.id, 'showHotel');
    registerMessage('IMStateChanged', this.id, 'updateIMIcon');

    executeMessage('requestHotelView');
  }

  deconstruct(): void {
    unregisterMessage('userlogin', this.id);
    unregisterMessage('showHotelView', this.id);
    unregisterMessage('IMStateChanged', this.id);

    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
    }
    if (this.flashIntervalId !== null) {
      clearInterval(this.flashIntervalId);
    }

    this.hideAll();
    super.deconstruct();
  }

  /**
   * Show the hotel view with regional animations
   */
  showHotel(): boolean {
    // Clean up existing animations
    this.destroyHotelAnimations();

    // Create animations for the current region
    this.createHotelAnimations();

    this.viewOpenTime = Date.now() + 500;

    // Start the open animation
    setTimeout(() => {
      this.addAnimTask('openView');
    }, 500);

    // Start animation loop for hotel view
    this.startHotelAnimationLoop();

    // Emit event for UI to render hotel view
    this.events.emit('showHotel', {
      region: this.regionalConfig.region,
      animations: this.hotelAnimations,
    });

    return true;
  }

  /**
   * Create hotel view animations based on regional config
   */
  private createHotelAnimations(): void {
    for (const animConfig of this.regionalConfig.animations) {
      const animation = createAnimation(animConfig.animationType, animConfig.config);
      if (animation) {
        // In real implementation, would find sprites by prefix
        animation.define(document.createElement('div'), this.hotelAnimations.length);
        this.hotelAnimations.push(animation);
      }
    }

    // Create swap animations
    if (this.regionalConfig.swapAnimations) {
      for (const swapConfig of this.regionalConfig.swapAnimations) {
        const swap = new SwapAnimation();
        swap.define(document.createElement('div'), this.swapAnimations.length);
        swap.configure(swapConfig);
        this.swapAnimations.push(swap);
      }
    }
  }

  /**
   * Destroy hotel view animations
   */
  private destroyHotelAnimations(): void {
    for (const anim of this.hotelAnimations) {
      anim.destroy();
    }
    this.hotelAnimations = [];

    for (const swap of this.swapAnimations) {
      swap.destroy();
    }
    this.swapAnimations = [];
  }

  /**
   * Start the hotel animation update loop
   */
  private startHotelAnimationLoop(): void {
    const updateAnimations = () => {
      if (this.hotelAnimations.length === 0 && this.swapAnimations.length === 0) {
        return;
      }

      // Toggle animation update (every other frame)
      this.animUpdate = !this.animUpdate;
      if (this.animUpdate) {
        for (const anim of this.hotelAnimations) {
          anim.update();
        }
        for (const swap of this.swapAnimations) {
          swap.update();
        }

        this.events.emit('hotelAnimationUpdate', {
          animations: this.hotelAnimations,
          swapAnimations: this.swapAnimations,
        });
      }

      if (this.hotelAnimations.length > 0 || this.swapAnimations.length > 0) {
        requestAnimationFrame(updateAnimations);
      }
    };

    requestAnimationFrame(updateAnimations);
  }

  /**
   * Hide the hotel view
   */
  hideHotel(): boolean {
    this.addAnimTask('closeView');
    this.remAnimTask('animSign');
    this.remAnimTask('openView');
    this.viewCloseTime = Date.now();

    // Destroy animations
    this.destroyHotelAnimations();

    this.events.emit('hideHotel');

    return true;
  }

  /**
   * Show the entry bar (bottom toolbar)
   */
  showEntryBar(): boolean {
    const layout = this.useWideEntryBar ? 'entry_bar_wide.window' : 'entry_bar.window';

    if (this.disableRoomEvents) {
      this.events.emit('disableRoomEventsIcon');
    }

    this.updateIMIcon();

    registerMessage('updateCreditCount', this.id, 'updateCreditCount');
    registerMessage('updateFriendListIcon', this.id, 'updateFriendListIcon');
    registerMessage('updateFigureData', this.id, 'updateEntryBar');
    registerMessage('updateClubStatus', this.id, 'updateClubStatus');

    this.addAnimTask('animEntryBar');
    this.updateEntryBar();

    this.events.emit('showEntryBar', { layout, disableRoomEvents: this.disableRoomEvents });

    return true;
  }

  /**
   * Hide the entry bar
   */
  hideEntryBar(): boolean {
    unregisterMessage('updateCreditCount', this.id);
    unregisterMessage('updateFriendListIcon', this.id);
    unregisterMessage('updateFigureData', this.id);
    unregisterMessage('updateClubStatus', this.id);

    if (this.flashIntervalId !== null) {
      clearInterval(this.flashIntervalId);
      this.flashIntervalId = null;
    }

    this.events.emit('hideEntryBar');

    return true;
  }

  /**
   * Hide all entry UI
   */
  hideAll(): boolean {
    this.hideHotel();
    this.hideEntryBar();
    return true;
  }

  /**
   * Update the entry bar with current user data
   */
  updateEntryBar(): boolean {
    const name = session.GET<string>('user_name') ?? '';
    const text = session.GET<string>('user_customData') ?? '';
    const credits = session.GET<number>('user_walletbalance');
    const clubStatus = session.GET<Record<string, unknown>>('club_status');

    if (this.firstInit) {
      this.deActivateAllIcons();
      this.firstInit = false;
    }

    const elements: EntryBarElements = {
      username: name,
      mission: text,
      credits: credits !== undefined ? `${credits} Credits` : 'Loading...',
      clubStatus: clubStatus ? this.formatClubStatus(clubStatus) : 'Loading...',
      newMessages: this.newMsgCount,
      buddyRequests: this.newBuddyRequests,
    };

    this.events.emit('updateEntryBar', elements);

    executeMessage('messageUpdateRequest');
    executeMessage('buddyUpdateRequest');

    return true;
  }

  /**
   * Format club status for display
   */
  private formatClubStatus(status: Record<string, unknown>): string {
    const daysLeft = (status.daysLeft as number) ?? 0;
    const prepaidPeriods = (status.PrepaidPeriods as number) ?? 0;
    const totalDays = daysLeft + prepaidPeriods * 31;

    if (prepaidPeriods < 0) {
      return 'HC Member';
    } else if (totalDays === 0) {
      return 'Join Habbo Club!';
    } else {
      return `HC: ${totalDays} days`;
    }
  }

  /**
   * Add an animation task
   */
  private addAnimTask(method: string): void {
    this.updateTasks.add(method);
    this.startUpdateLoop();
  }

  /**
   * Remove an animation task
   */
  private remAnimTask(method: string): void {
    this.updateTasks.delete(method);
    if (this.updateTasks.size === 0) {
      this.stopUpdateLoop();
    }
  }

  /**
   * Start the update loop
   */
  private startUpdateLoop(): void {
    if (this.animationFrameId !== null) return;

    const update = () => {
      this.updateTasks.forEach((task) => {
        this.executeAnimTask(task);
      });

      if (this.updateTasks.size > 0) {
        this.animationFrameId = requestAnimationFrame(update);
      }
    };

    this.animationFrameId = requestAnimationFrame(update);
  }

  /**
   * Stop the update loop
   */
  private stopUpdateLoop(): void {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
  }

  /**
   * Execute an animation task
   */
  private executeAnimTask(task: string): void {
    switch (task) {
      case 'openView':
        this.animOpenView();
        break;
      case 'closeView':
        this.animCloseView();
        break;
      case 'animSign':
        this.animSign();
        break;
      case 'animEntryBar':
        this.animEntryBar();
        break;
    }
  }

  /**
   * Opening animation for hotel view
   */
  private animOpenView(): void {
    if (this.viewOpenTime === null) {
      this.remAnimTask('openView');
      return;
    }

    const timeLeft = (this.viewMaxTime - (Date.now() - this.viewOpenTime)) / 1000.0;

    if (timeLeft <= 0) {
      this.addAnimTask('animSign');
      this.remAnimTask('openView');
      this.events.emit('viewOpened');
    } else {
      const progress = 1 - timeLeft / (this.viewMaxTime / 1000);
      this.events.emit('openViewProgress', progress);
    }
  }

  /**
   * Closing animation for hotel view
   */
  private animCloseView(): void {
    if (this.viewCloseTime === null) {
      this.remAnimTask('closeView');
      return;
    }

    const timeLeft = (this.viewMaxTime - (Date.now() - this.viewCloseTime)) / 1000.0;

    if (timeLeft <= 0) {
      this.remAnimTask('closeView');
      this.events.emit('viewClosed');
    } else {
      const progress = 1 - timeLeft / (this.viewMaxTime / 1000);
      this.events.emit('closeViewProgress', progress);
    }
  }

  /**
   * Sign drop animation
   */
  private animSign(): void {
    this.events.emit('animSign');
    this.remAnimTask('animSign');
  }

  /**
   * Entry bar slide up animation
   */
  private animEntryBar(): void {
    this.events.emit('animEntryBar');
    this.remAnimTask('animEntryBar');
  }

  /**
   * Update credit count display
   */
  updateCreditCount(count: number | string): boolean {
    this.events.emit('updateCredits', count);
    return true;
  }

  /**
   * Update club status display
   */
  updateClubStatus(status: Record<string, unknown>): boolean {
    this.clubDaysCount = (status.daysLeft as number) ?? 0;
    this.events.emit('updateClubStatus', this.formatClubStatus(status));
    return true;
  }

  /**
   * Update friend list icon state
   */
  updateFriendListIcon(active: boolean): void {
    this.events.emit('updateFriendListIcon', active);
  }

  /**
   * Update IM icon based on messenger state
   */
  updateIMIcon(state?: 'Active' | 'highlighted' | 'inactive'): void {
    if (!state) {
      state = 'inactive';
    }

    switch (state) {
      case 'Active':
        this.bounceIMIcon(false);
        this.flashIMIcon('stop');
        break;
      case 'highlighted':
        this.bounceIMIcon(true);
        this.flashIMIcon('start');
        break;
      case 'inactive':
        this.bounceIMIcon(false);
        this.flashIMIcon('stop');
        break;
    }

    this.events.emit('updateIMIcon', state);
  }

  /**
   * Bounce the IM icon
   */
  private bounceIMIcon(bounce: boolean): void {
    this.events.emit('bounceIMIcon', bounce);
  }

  /**
   * Flash the IM icon
   */
  private flashIMIcon(action: 'start' | 'stop' | 'flash'): void {
    switch (action) {
      case 'start':
        if (this.flashIntervalId !== null) {
          clearInterval(this.flashIntervalId);
        }
        this.flashIntervalId = setInterval(() => {
          this.flashIMIcon('flash');
        }, 500) as unknown as number;
        break;
      case 'stop':
        if (this.flashIntervalId !== null) {
          clearInterval(this.flashIntervalId);
          this.flashIntervalId = null;
        }
        break;
      case 'flash':
        this.imFlashState = !this.imFlashState;
        this.events.emit('imIconFlash', this.imFlashState);
        break;
    }
  }

  /**
   * Activate an icon
   */
  activateIcon(icon: 'navigator' | 'messenger'): void {
    this.events.emit('activateIcon', icon);
  }

  /**
   * Deactivate an icon
   */
  deActivateIcon(icon: 'navigator' | 'messenger'): void {
    this.events.emit('deActivateIcon', icon, this.inActiveIconBlend);
  }

  /**
   * Deactivate all icons
   */
  deActivateAllIcons(): void {
    this.events.emit('deActivateAllIcons', this.inActiveIconBlend);
  }

  /**
   * Handle entry bar click events
   */
  handleEntryBarClick(elementId: string): void {
    switch (elementId) {
      case 'help_icon_image':
        executeMessage('openGeneralDialog', 'help');
        break;
      case 'get_credit_text':
      case 'purse_icon_image':
        executeMessage('openGeneralDialog', 'purse');
        break;
      case 'event_icon_image':
        if (!this.disableRoomEvents) {
          executeMessage('show_hide_roomevents');
        }
        break;
      case 'nav_icon_image':
        executeMessage('show_hide_navigator');
        break;
      case 'friend_list_icon':
        executeMessage('toggle_friend_list');
        break;
      case 'update_habboid_text':
      case 'ownhabbo_icon_image':
        const allowModify = session.GET<boolean>('allow_profile_editing') ?? true;
        if (allowModify) {
          executeMessage('openFigureUpdate');
        } else {
          executeMessage('externalLinkClick');
        }
        break;
      case 'club_icon_image':
      case 'club_bottombar_text2':
        executeMessage('show_clubinfo');
        break;
      case 'im_icon':
        executeMessage('toggle_im');
        break;
      case 'int_controller_image':
        executeMessage('toggle_ig');
        break;
      case 'int_brochure_image':
        executeMessage('show_hide_catalogue');
        break;
    }
  }

  /**
   * Create the user's head icon in the entry bar
   */
  createMyHeadIcon(): void {
    this.events.emit('createMyHeadIcon');
  }

  /**
   * Get the events emitter for UI binding
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Get the current hotel animations
   */
  getHotelAnimations(): IHotelViewAnimation[] {
    return this.hotelAnimations;
  }

  /**
   * Get the current swap animations
   */
  getSwapAnimations(): SwapAnimation[] {
    return this.swapAnimations;
  }
}
