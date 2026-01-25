/**
 * Room Bar Class - Bottom bar with chat and icons
 *
 * Ported from: hh_room_ui/Cast External ParentScript 3 - Room Bar Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  RoomBarLayout,
  SpeechMode,
  IMIconState,
  RoomBarEvents,
  FloodSettings,
  DEFAULT_FLOOD_SETTINGS,
  WindowIds,
} from './types';

/**
 * Room bar - bottom UI bar with chat, icons, and controls
 */
export class RoomBar extends BaseObject {
  private pBottomBarId: string = WindowIds.ROOM_BAR;
  private pFloodblocking: boolean = false;
  private pFloodTimer: number = 0;
  private pFloodEnterCount: number = 0;
  private pTextIsHelpText: boolean = false;
  private pIMFlashState: boolean = false;
  private pDisableRoomEvents: boolean = false;
  private pSignState: number | null = null;
  private pOldPosH: number = -1;
  private pOldPosV: number = -1;
  private pTypingTimeoutName: string = 'typing_state_timeout';
  private pCurrentLayout: RoomBarLayout | null = null;

  private floodSettings: FloodSettings = DEFAULT_FLOOD_SETTINGS;
  private typingTimeout: ReturnType<typeof setTimeout> | null = null;
  private imFlashTimeout: ReturnType<typeof setTimeout> | null = null;

  construct(): void {
    super.construct();

    this.pFloodblocking = false;
    this.pFloodTimer = 0;
    this.pFloodEnterCount = 0;
    this.pTextIsHelpText = false;
    this.pDisableRoomEvents = false;

    // Would check variable disable.roomevents
    // Would register messages for updateMessageCount, updateFriendListIcon, etc.
  }

  deconstruct(): void {
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout);
      this.typingTimeout = null;
    }

    if (this.imFlashTimeout) {
      clearTimeout(this.imFlashTimeout);
      this.imFlashTimeout = null;
    }

    // Would unregister messages
    super.deconstruct();
  }

  /**
   * Show room bar
   */
  showRoomBar(layout?: RoomBarLayout): boolean {
    // Would create window if not exists
    // Would get layout based on spectator mode and screen width

    if (!layout) {
      if (this.getWideDocksEnabled()) {
        layout = 'room_bar_wide.window';
      } else {
        layout = 'room_bar.window';
      }
    }

    this.pCurrentLayout = layout;

    // Would create and configure window
    // Would register event procedures
    // Would update sound button, IM icon, hide hiliters

    this.updateSoundButton();
    this.updateIMIcon();
    this.hideHiliters();

    this.emit('room_bar_shown', { layout });
    return true;
  }

  /**
   * Hide room bar
   */
  hideRoomBar(): void {
    if (this.imFlashTimeout) {
      clearTimeout(this.imFlashTimeout);
      this.imFlashTimeout = null;
    }

    // Would remove window
    // Would hide icon bar extensions

    this.pCurrentLayout = null;
    this.emit('room_bar_hidden');
  }

  /**
   * Apply chat help text for tutorial
   */
  applyChatHelpText(): void {
    // Would set chat field text to tutorial help
    this.pTextIsHelpText = true;
    this.emit('chat_help_text_applied');
  }

  /**
   * Set speech dropdown mode
   */
  setSpeechDropdown(mode: SpeechMode): boolean {
    // Would update dropdown element
    this.emit('speech_mode_changed', { mode });
    return true;
  }

  /**
   * Set rollover info text
   */
  setRollOverInfo(info: string): void {
    // Would update tooltip text element
    this.emit('rollover_info_changed', { info });
  }

  /**
   * Update message count indicator
   */
  updateMessageCount(count: number): void {
    this.updateFriendListIcon(count > 0);
  }

  /**
   * Update friend list icon
   */
  updateFriendListIcon(active: boolean): void {
    // Would update friend list icon member
    this.emit('friend_list_icon_updated', { active });
  }

  /**
   * Bounce IM icon for notification
   */
  bounceIMIcon(state: boolean): void {
    // Would use ElementBouncer to bounce the IM icon
    this.emit('im_icon_bounce', { state });
  }

  /**
   * Update sound button state
   */
  updateSoundButton(): void {
    // Would update sound icon based on sound state
    this.emit('sound_button_updated');
  }

  /**
   * Set typing state
   */
  setTypingState(state: boolean): void {
    const timeoutTime = 2000;

    if (!state) {
      if (this.typingTimeout) {
        clearTimeout(this.typingTimeout);
        this.typingTimeout = null;
      } else {
        this.sendTypingState(false);
      }
    } else {
      if (this.typingTimeout) {
        clearTimeout(this.typingTimeout);
      }

      this.typingTimeout = setTimeout(() => {
        this.sendTypingState(true);
        this.typingTimeout = null;
      }, timeoutTime);
    }
  }

  /**
   * Send typing state to server
   */
  sendTypingState(state: boolean): void {
    // Would send USER_START_TYPING or USER_CANCEL_TYPING
    this.emit('typing_state_sent', { state });
  }

  /**
   * Show vote UI
   */
  showVote(): void {
    // Would resize chat field and show vote element
    this.pSignState = null;
    this.pOldPosH = -1;
    this.pOldPosV = -1;

    this.emit('vote_shown');
  }

  /**
   * Update IM icon state
   */
  updateIMIcon(): boolean {
    // Would get IM state from instant messenger thread
    const state: IMIconState = 'inactive';

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

    this.emit('im_icon_updated', { state });
    return true;
  }

  /**
   * Flash IM icon
   */
  flashIMIcon(state: 'start' | 'stop' | 'flash'): void {
    switch (state) {
      case 'start':
        if (this.imFlashTimeout) {
          clearTimeout(this.imFlashTimeout);
        }
        this.imFlashTimeout = setTimeout(() => this.flashIMIcon('flash'), 500);
        break;

      case 'stop':
        if (this.imFlashTimeout) {
          clearTimeout(this.imFlashTimeout);
          this.imFlashTimeout = null;
        }
        break;

      case 'flash':
        this.pIMFlashState = !this.pIMFlashState;
        this.emit('im_icon_flash', { state: this.pIMFlashState });

        // Continue flashing
        this.imFlashTimeout = setTimeout(() => this.flashIMIcon('flash'), 500);
        break;
    }
  }

  /**
   * Hide all hiliters
   */
  hideHiliters(): void {
    // Would hide all elements containing 'hilite' in name
    this.emit('hiliters_hidden');
  }

  /**
   * Check if wide docks should be enabled
   */
  getWideDocksEnabled(): boolean {
    return window.innerWidth >= 960;
  }

  /**
   * Handle chat field key down
   */
  handleChatKeyDown(key: string, keyCode: number, chatText: string): boolean {
    // Clear help text on first input
    if (this.pTextIsHelpText) {
      this.emit('clear_chat_field');
      this.pTextIsHelpText = false;
    }

    // Handle enter key (36 = Enter, 76 = Numpad Enter)
    if (keyCode === 36 || keyCode === 76 || keyCode === 13) {
      if (chatText.length === 0) {
        return true;
      }

      // Check flood blocking
      if (this.pFloodblocking) {
        if (Date.now() < this.pFloodTimer) {
          return false;
        } else {
          this.pFloodEnterCount = 0;
        }
      }

      // Check for flood
      if (this.pFloodEnterCount === 0) {
        this.pFloodEnterCount = 0;
        this.pFloodblocking = false;
        this.pFloodTimer = Date.now();
      } else {
        this.pFloodEnterCount++;

        if (this.pFloodEnterCount > this.floodSettings.countLimit) {
          if (Date.now() < this.pFloodTimer + this.floodSettings.timerLimit) {
            // Flood detected
            this.emit('flood_detected', {
              timeout: this.floodSettings.timeout,
            });
            this.pFloodblocking = true;
            this.pFloodTimer = Date.now() + this.floodSettings.timeout;
            return true;
          } else {
            this.pFloodEnterCount = 0;
          }
        }
      }

      // Submit chat
      this.emit(RoomBarEvents.CHAT_SUBMIT, { text: chatText });

      // Clear typing timeout
      if (this.typingTimeout) {
        clearTimeout(this.typingTimeout);
        this.typingTimeout = null;
      }

      return true;
    }

    // Handle delete/backspace
    if (keyCode === 51 || keyCode === 8) {
      if (chatText.length === 1) {
        this.setTypingState(false);
      }
    }

    // Handle escape
    if (keyCode === 117 || keyCode === 27) {
      if (chatText.length > 0) {
        this.setTypingState(false);
      }
      this.emit('clear_chat_field');
    }

    // Start typing indicator
    if (chatText.length === 0) {
      this.setTypingState(true);
    }

    return false;
  }

  /**
   * Handle room bar UI event
   */
  handleEvent(event: string, spriteId: string, param?: unknown): void {
    if (event === 'mouseUp') {
      switch (spriteId) {
        case 'int_help_image':
          this.emit(RoomBarEvents.HELP_CLICK);
          break;
        case 'int_hand_image':
          this.emit(RoomBarEvents.HAND_CLICK);
          break;
        case 'int_brochure_image':
          this.emit(RoomBarEvents.CATALOG_CLICK);
          break;
        case 'int_purse_image':
          this.emit(RoomBarEvents.PURSE_CLICK);
          break;
        case 'int_controller_image':
          this.emit(RoomBarEvents.GAMES_CLICK);
          break;
        case 'int_event_image':
          if (!this.pDisableRoomEvents) {
            this.emit(RoomBarEvents.EVENTS_CLICK);
          }
          break;
        case 'int_nav_image':
          this.emit(RoomBarEvents.NAVIGATOR_CLICK);
          break;
        case 'int_sound_image':
        case 'int_sound_bg_image':
          this.emit(RoomBarEvents.SOUND_TOGGLE);
          break;
        case 'int_tv_close':
          this.emit(RoomBarEvents.SPECTATOR_CLOSE);
          break;
        case 'im_icon':
          this.emit(RoomBarEvents.IM_TOGGLE);
          break;
        case 'friend_list_icon':
          this.emit(RoomBarEvents.FRIEND_LIST_TOGGLE);
          break;
        case 'int_speechmode_dropmenu':
          this.emit(RoomBarEvents.SPEECH_MODE_CHANGE, { mode: param });
          break;
        case 'int_drop_vote':
          this.handleVoteEvent(event, param);
          break;
      }
    }

    if (event === 'mouseEnter' || event === 'mouseLeave') {
      this.handleRollover(event, spriteId);
    }
  }

  /**
   * Handle rollover events
   */
  private handleRollover(event: string, spriteId: string): void {
    if (event === 'mouseLeave') {
      this.setRollOverInfo('');
      return;
    }

    const tooltips: Record<string, string> = {
      'int_help_image': 'interface_icon_help',
      'int_hand_image': 'interface_icon_hand',
      'int_brochure_image': 'interface_icon_catalog',
      'int_purse_image': 'interface_icon_purse',
      'int_controller_image': 'interface_icon_ig',
      'int_event_image': 'interface_icon_events',
      'int_nav_image': 'interface_icon_navigator',
      'int_sound_image': 'interface_icon_sound',
      'int_tv_close': 'interface_icon_tv_close',
      'im_icon': 'im_tooltip',
      'friend_list_icon': 'friend_list_title',
    };

    const tooltip = tooltips[spriteId];
    if (tooltip) {
      this.setRollOverInfo(tooltip);
    }
  }

  /**
   * Handle vote event
   */
  private handleVoteEvent(event: string, param?: unknown): void {
    if (event === 'mouseDown') {
      this.pSignState = 1;
    } else if (event === 'mouseUp') {
      if (this.pSignState !== null && this.pOldPosV < 7) {
        const signMode = Math.min(14, Math.max(1, (this.pOldPosH * 7) + (this.pOldPosV + 1)));
        this.emit(RoomBarEvents.VOTE_SUBMIT, { value: signMode });
      }
      this.pSignState = null;
    } else if (event === 'mouseUpOutSide') {
      this.pSignState = null;
    } else if (event === 'mouseWithin' && this.pSignState !== null) {
      // Would update sign highlight based on mouse position
    }
  }

  /**
   * Get current layout
   */
  getCurrentLayout(): RoomBarLayout | null {
    return this.pCurrentLayout;
  }

  /**
   * Set flood settings
   */
  setFloodSettings(settings: Partial<FloodSettings>): void {
    this.floodSettings = { ...this.floodSettings, ...settings };
  }
}
