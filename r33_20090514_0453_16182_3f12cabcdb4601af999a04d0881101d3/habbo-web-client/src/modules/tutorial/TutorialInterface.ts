/**
 * Tutorial Interface Class (NUH Interface) - UI handling
 *
 * Ported from: hh_tutorial/Cast External ParentScript 3 - NUH Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';
import { registerMessage, unregisterMessage } from '../../core/MessageBus';
import { Bubble } from './Bubble';
import { StaticBubble } from './StaticBubble';
import { UpdateBubble, TutorBubble } from './UpdateBubble';
import {
  InvitationStatus,
  HighlighterList,
  HIGHLIGHTER_BLINK_INTERVAL,
  SEARCH_ANIM_INTERVAL,
} from './types';
import { TutorialComponent } from './TutorialComponent';

/**
 * Tutorial interface - manages help bubbles and UI
 */
export class TutorialInterface extends BaseObject {
  private events: EventEmitter = new EventEmitter();
  private bubbles: Map<string, Bubble> = new Map();
  private searchAnimFrame: number = 1;
  private highlighterList: HighlighterList | null = null;
  private highlighterBlinkPhase: number = 1;

  // Window IDs
  private invitationWindowId: string = 'NUH_invite_window_ID';
  private invitationStatusWindowId: string = 'NUH_invite_status_window_ID';
  private skipWindowId: string = 'NUH_skip_window_ID';

  // Timeouts
  private invitationStatusTimeout: ReturnType<typeof setTimeout> | null = null;
  private highlighterBlinkTimeout: ReturnType<typeof setInterval> | null = null;

  construct(): void {
    super.construct();

    this.bubbles = new Map();
    this.highlighterList = null;
    this.highlighterBlinkPhase = 1;
    this.searchAnimFrame = 1;

    registerMessage('gamesystem_constructed', this.id, 'hideInvitationStatusWindow');
    registerMessage('roomReady', this.id, 'hideHighlighters');
  }

  deconstruct(): void {
    this.removeAll();
    this.hideInvitationStatusWindow();

    unregisterMessage('gamesystem_constructed', this.id);
    unregisterMessage('roomReady', this.id);

    super.deconstruct();
  }

  /**
   * Remove all bubbles and windows
   */
  removeAll(): void {
    this.removeBlinkTimeout();

    for (const bubble of this.bubbles.values()) {
      bubble.deconstruct();
    }
    this.bubbles.clear();

    this.hideInvitationWindow();
    this.hideSkipOrNotWindow();

    this.events.emit('removeAll');
  }

  /**
   * Show own user help bubble
   */
  showOwnUserHelp(helpId: string = 'own_user'): void {
    // Would get user object from room
    // For now, create bubble with text
    const bubble = new UpdateBubble();
    const text = `NUH_${helpId}`; // Would be localized text

    bubble.setProperty('bubbleId', helpId);
    bubble.setText(text);
    bubble.selectPointerAndPosition(7);
    bubble.show();

    // Remove previous bubble with same ID if exists
    const previous = this.bubbles.get(helpId);
    if (previous) {
      previous.deconstruct();
    }

    this.bubbles.set(helpId, bubble);
    this.events.emit('showOwnUserHelp', { helpId, bubble: bubble.getState() });
  }

  /**
   * Show skip or not window
   */
  showSkipOrNotWindow(helpId: string): void {
    this.events.emit('showSkipWindow', {
      helpId,
      title: 'NUH_asktoshowhelp_title',
      text: 'NUH_asktoshowhelp_text',
      okText: 'NUH_asktoshowhelp_decision_ok',
      cancelText: 'NUH_asktoshowhelp_decision_cancel',
    });
  }

  /**
   * Hide skip or not window
   */
  hideSkipOrNotWindow(): void {
    this.events.emit('hideSkipWindow');
  }

  /**
   * Show generic help
   */
  showGenericHelp(helpId: string): void {
    // Create infofeed item
    const text = `NUH_${helpId}`;
    const topic = `NUH_${helpId}_topic`;

    this.events.emit('showGenericHelp', {
      helpId,
      type: 'help',
      value: text,
      topic,
    });
  }

  /**
   * Show guide arrived bubble
   */
  showGuideArrivedBubble(accountId: number, autoSelected: boolean): void {
    const bubble = new TutorBubble();
    const helpId = autoSelected ? 'guide_info_autoselected' : 'guide_info';
    const text = `NUH_${helpId}`;

    bubble.setProperty('bubbleId', helpId);
    bubble.setText(text);
    bubble.selectPointerAndPosition(7);
    bubble.show();

    const previous = this.bubbles.get(helpId);
    if (previous) {
      previous.deconstruct();
    }

    this.bubbles.set(helpId, bubble);
    this.events.emit('showGuideArrivedBubble', {
      accountId,
      autoSelected,
      bubble: bubble.getState(),
    });
  }

  /**
   * Remove help bubble
   */
  removeHelpBubble(helpItemName: string): void {
    const bubble = this.bubbles.get(helpItemName);
    if (bubble) {
      bubble.deconstruct();
      this.bubbles.delete(helpItemName);
    }

    this.events.emit('removeHelpBubble', { helpId: helpItemName });
  }

  /**
   * Show invitation window
   */
  showInviteWindow(): void {
    this.hideInvitationWindow();

    this.events.emit('showInviteWindow', {
      header: 'send_invitation_header',
      text: 'send_invitation_text',
    });
  }

  /**
   * Hide invitation window
   */
  hideInvitationWindow(): void {
    this.events.emit('hideInviteWindow');
  }

  /**
   * Show invitation status window
   */
  showInvitationStatusWindow(status: InvitationStatus): void {
    this.hideInvitationStatusWindow();

    this.events.emit('showInvitationStatus', { status });

    // Clear existing timeout
    if (this.invitationStatusTimeout) {
      clearTimeout(this.invitationStatusTimeout);
      this.invitationStatusTimeout = null;
    }

    switch (status) {
      case 'search':
        // Start animation
        this.invitationStatusTimeout = setInterval(() => {
          this.updateInvitationStatusWindow();
        }, SEARCH_ANIM_INTERVAL);
        break;

      case 'success':
        // Auto-hide after 3 seconds
        this.invitationStatusTimeout = setTimeout(() => {
          this.hideInvitationStatusWindow();
        }, 3000);
        break;
    }
  }

  /**
   * Hide invitation status window
   */
  hideInvitationStatusWindow(): void {
    if (this.invitationStatusTimeout) {
      clearTimeout(this.invitationStatusTimeout);
      clearInterval(this.invitationStatusTimeout as unknown as ReturnType<typeof setInterval>);
      this.invitationStatusTimeout = null;
    }

    this.events.emit('hideInvitationStatus');
  }

  /**
   * Update invitation status window (search animation)
   */
  private updateInvitationStatusWindow(): void {
    this.searchAnimFrame++;
    if (this.searchAnimFrame > 3) {
      this.searchAnimFrame = 1;
    }

    const component = this.getComponent() as TutorialComponent | null;
    const guideCount = component?.getGuideCount() || 0;

    this.events.emit('updateInvitationStatus', {
      frame: this.searchAnimFrame,
      guideCount,
    });
  }

  /**
   * Get highlighter list
   */
  getHighlighterList(): HighlighterList {
    if (!this.highlighterList) {
      this.highlighterList = {};
      // Would load from NUH.ids configuration
    }
    return this.highlighterList;
  }

  /**
   * Hide all highlighters
   */
  hideHighlighters(): void {
    this.removeBlinkTimeout();
    this.events.emit('hideHighlighters');
  }

  /**
   * Show highlighter for help item
   */
  showHighlighter(helpId: string): void {
    const highlighters = this.getHighlighterList();
    const elementName = highlighters[helpId];

    if (!elementName) {
      return;
    }

    this.events.emit('showHighlighter', {
      helpId,
      elementName,
      phase: this.highlighterBlinkPhase,
    });

    this.createBlinkTimeout();
  }

  /**
   * Create highlighter blink timeout
   */
  private createBlinkTimeout(): void {
    if (!this.highlighterBlinkTimeout) {
      this.highlighterBlinkTimeout = setInterval(() => {
        this.blinkHighlighters();
      }, HIGHLIGHTER_BLINK_INTERVAL);
    }
  }

  /**
   * Remove highlighter blink timeout
   */
  private removeBlinkTimeout(): void {
    if (this.highlighterBlinkTimeout) {
      clearInterval(this.highlighterBlinkTimeout);
      this.highlighterBlinkTimeout = null;
    }
  }

  /**
   * Blink highlighters
   */
  private blinkHighlighters(): void {
    this.highlighterBlinkPhase++;
    if (this.highlighterBlinkPhase > 2) {
      this.highlighterBlinkPhase = 1;
    }

    this.events.emit('blinkHighlighters', { phase: this.highlighterBlinkPhase });
  }

  /**
   * Handle invitation dialog event
   */
  eventProcInvitation(event: string, sprId: string): void {
    const component = this.getComponent() as TutorialComponent | null;
    if (!component) return;

    switch (sprId) {
      case 'nuh_invitation_yes':
        component.closeInvitation('yes');
        break;
      case 'nuh_invitation_no':
        component.closeInvitation('no');
        break;
      case 'nuh_invitation_never':
        component.closeInvitation('never');
        break;
    }
  }

  /**
   * Handle invitation status event
   */
  eventProcInvitationStatus(event: string, sprId: string): void {
    const component = this.getComponent() as TutorialComponent | null;
    if (!component) return;

    // Handle option buttons
    if (sprId.startsWith('nuh_invitation_option')) {
      // Would execute configured message
      this.hideInvitationStatusWindow();
      return;
    }

    switch (sprId) {
      case 'nuh_invitation_status_cancel':
      case 'nuh_invitation_status_close':
        component.cancelInvitations();
        this.hideInvitationStatusWindow();
        break;

      case 'nuh_room_left_back':
        component.goToInvitationRoom();
        break;

      case 'close_button':
        this.hideInvitationStatusWindow();
        break;
    }
  }

  /**
   * Handle skip tutorial event
   */
  eventProcSkipTutorial(event: string, sprId: string): void {
    const component = this.getComponent() as TutorialComponent | null;
    if (!component) return;

    switch (sprId) {
      case 'habbo_decision_ok':
        component.setAskingSkip(false);
        this.hideSkipOrNotWindow();
        break;

      case 'habbo_decision_cancel':
        component.setTutorialFinished();
        this.hideSkipOrNotWindow();
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
   * Update bubbles (called each frame)
   */
  update(): void {
    for (const bubble of this.bubbles.values()) {
      if (bubble instanceof UpdateBubble && bubble.getNeedsUpdate()) {
        bubble.update();
      }
    }
  }
}
