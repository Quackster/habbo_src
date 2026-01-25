/**
 * Tutorial Interface Class (NUH Interface) - UI handling
 *
 * Ported from: hh_tutorial/Cast External ParentScript 3 - NUH Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { registerMessage, unregisterMessage } from '../../core/MessageBus';
import { Bubble } from './Bubble';
import { UpdateBubble, TutorBubble } from './UpdateBubble';
import {
  InvitationStatus,
  HighlighterList,
  HIGHLIGHTER_BLINK_INTERVAL,
  SEARCH_ANIM_INTERVAL,
} from './types';
import { TutorialComponent } from './TutorialComponent';

// Timeout names
const TIMEOUT_INVITATION_STATUS = 'NUH_invite_status_timeout_ID';
const TIMEOUT_HIGHLIGHTER_BLINK = 'NUH_hiliter_blink_timeout';

/**
 * Tutorial interface - manages help bubbles and UI
 */
export class TutorialInterface extends BaseInterface {
  private bubbles: Map<string, Bubble> = new Map();
  private searchAnimFrame: number = 1;
  private highlighterList: HighlighterList | null = null;
  private highlighterBlinkPhase: number = 1;

  // Window IDs
  private pInvitationWindowId: string = 'NUH_invite_window_ID';
  private pInvitationStatusWindowId: string = 'NUH_invite_status_window_ID';
  private pSkipWindowId: string = 'NUH_skip_window_ID';
  private pRoomBarId: string = 'RoomBarID';

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
   *
   * Lingo: removeAll()
   */
  removeAll(): void {
    this.removeBlinkTimeout();

    for (const bubble of this.bubbles.values()) {
      bubble.deconstruct();
    }
    this.bubbles.clear();

    this.hideInvitationWindow();
    this.hideSkipOrNotWindow();
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
   *
   * Lingo: createWindow(pSkipWindowID, "bubble.window")
   *        tWindow.merge("habbo_decision_plain.window")
   */
  async showSkipOrNotWindow(helpId: string): Promise<void> {
    // Check if in room (not game)
    // Would check room component for room ID

    await this.createWindow(this.pSkipWindowId, 'bubble.window');

    if (!this.windowExists(this.pSkipWindowId)) return;

    // Hide pointers except #4
    for (let i = 1; i <= 8; i++) {
      if (i !== 4) {
        const pointerElem = `pointer_${i}`;
        if (this.elementExists(this.pSkipWindowId, pointerElem)) {
          this.hideElement(this.pSkipWindowId, pointerElem);
        }
        const pointerShadow = `pointer_${i}_shadow`;
        if (this.elementExists(this.pSkipWindowId, pointerShadow)) {
          this.hideElement(this.pSkipWindowId, pointerShadow);
        }
      }
    }

    // Merge decision layout
    await this.mergeWindow(this.pSkipWindowId, 'habbo_decision_plain.window');

    // Register event procedure
    this.registerWindowProcedure(this.pSkipWindowId, 'eventProcSkipTutorial', 'mouseUp');

    // Set text elements
    if (this.elementExists(this.pSkipWindowId, 'habbo_decision_text_a')) {
      this.setText(this.pSkipWindowId, 'habbo_decision_text_a', 'NUH_asktoshowhelp_title');
    }
    if (this.elementExists(this.pSkipWindowId, 'habbo_decision_text_b')) {
      this.setText(this.pSkipWindowId, 'habbo_decision_text_b', 'NUH_asktoshowhelp_text');
    }
    if (this.elementExists(this.pSkipWindowId, 'habbo_decision_cancel')) {
      this.setText(this.pSkipWindowId, 'habbo_decision_cancel', 'NUH_asktoshowhelp_decision_cancel');
    }
    if (this.elementExists(this.pSkipWindowId, 'habbo_decision_ok')) {
      this.setText(this.pSkipWindowId, 'habbo_decision_ok', 'NUH_asktoshowhelp_decision_ok');
    }

    // Position window (would use config value)
    this.moveWindow(this.pSkipWindowId, 100, 100);
  }

  /**
   * Hide skip or not window
   *
   * Lingo: removeWindow(pSkipWindowID)
   */
  hideSkipOrNotWindow(): void {
    if (this.windowExists(this.pSkipWindowId)) {
      this.removeWindow(this.pSkipWindowId);
    }
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
   *
   * Lingo: createWindow(pInvitationWindowID, "nuh_invitation.window")
   */
  async showInviteWindow(): Promise<void> {
    this.hideInvitationWindow();

    await this.createWindow(this.pInvitationWindowId, 'nuh_invitation.window');

    if (!this.windowExists(this.pInvitationWindowId)) return;

    // Set header and text
    if (this.elementExists(this.pInvitationWindowId, 'nuh_invitation_header')) {
      this.setText(this.pInvitationWindowId, 'nuh_invitation_header', 'send_invitation_header');
    }
    if (this.elementExists(this.pInvitationWindowId, 'nuh_invitation_text')) {
      this.setText(this.pInvitationWindowId, 'nuh_invitation_text', 'send_invitation_text');
    }

    // Position window (would use config value)
    this.moveWindow(this.pInvitationWindowId, 10, 10);

    // Register event procedure
    this.registerWindowProcedure(this.pInvitationWindowId, 'eventProcInvitation', 'mouseUp');
  }

  /**
   * Hide invitation window
   *
   * Lingo: removeWindow(pInvitationWindowID)
   */
  hideInvitationWindow(): void {
    if (this.windowExists(this.pInvitationWindowId)) {
      this.removeWindow(this.pInvitationWindowId);
    }
  }

  /**
   * Show invitation status window
   *
   * Lingo: createWindow(pInvitationStatusWindowID, tLayout)
   *        createTimeout(pInvitationStatusTimeoutID, ...)
   */
  async showInvitationStatusWindow(status: InvitationStatus): Promise<void> {
    this.hideInvitationStatusWindow();

    // Determine layout based on status
    let layout: string;
    switch (status) {
      case 'search':
        layout = 'nuh_invitation_status.window';
        break;
      case 'room_left':
        layout = 'nuh_room_left.window';
        break;
      case 'success':
        layout = 'nuh_invitation_success.window';
        break;
      case 'failure':
        layout = 'nuh_invitation_failure.window';
        break;
      default:
        return;
    }

    await this.createWindow(this.pInvitationStatusWindowId, layout);

    if (!this.windowExists(this.pInvitationStatusWindowId)) return;

    this.moveWindow(this.pInvitationStatusWindowId, 10, 10);
    this.registerWindowProcedure(this.pInvitationStatusWindowId, 'eventProcInvitationStatus', 'mouseUp');

    // Remove existing timeout
    this.removeTimeout(TIMEOUT_INVITATION_STATUS);

    switch (status) {
      case 'search':
        // Start animation timeout (repeating)
        this.createRepeatingTimeout(TIMEOUT_INVITATION_STATUS, SEARCH_ANIM_INTERVAL, 'updateInvitationStatusWindow');
        break;
      case 'success':
        // Auto-hide after 3 seconds (one-shot)
        this.createTimeout(TIMEOUT_INVITATION_STATUS, 3000, 'hideInvitationStatusWindow');
        break;
    }
  }

  /**
   * Hide invitation status window
   *
   * Lingo: removeWindow(pInvitationStatusWindowID)
   *        removeTimeout(pInvitationStatusTimeoutID)
   */
  hideInvitationStatusWindow(): void {
    if (this.windowExists(this.pInvitationStatusWindowId)) {
      this.removeWindow(this.pInvitationStatusWindowId);
    }
    this.removeTimeout(TIMEOUT_INVITATION_STATUS);
  }

  /**
   * Create a repeating timeout (interval)
   */
  private createRepeatingTimeout(name: string, intervalMs: number, handlerMethod: string): void {
    // Store interval ID for cleanup
    const intervalId = setInterval(() => {
      const handler = (this as Record<string, unknown>)[handlerMethod];
      if (typeof handler === 'function') {
        handler.call(this);
      }
    }, intervalMs);

    // Store for cleanup (using internal map)
    (this as any)[`_interval_${name}`] = intervalId;
  }

  /**
   * Override removeTimeout to handle intervals too
   */
  protected override removeTimeout(name: string): boolean {
    // Check for interval
    const intervalKey = `_interval_${name}`;
    if ((this as any)[intervalKey]) {
      clearInterval((this as any)[intervalKey]);
      delete (this as any)[intervalKey];
      return true;
    }
    return super.removeTimeout(name);
  }

  /**
   * Update invitation status window (search animation)
   *
   * Lingo: updateInvitationStatusWindow()
   */
  private updateInvitationStatusWindow(): void {
    if (!this.windowExists(this.pInvitationStatusWindowId)) return;

    // Update search animation
    if (this.elementExists(this.pInvitationStatusWindowId, 'nuh_search')) {
      this.searchAnimFrame++;
      if (this.searchAnimFrame > 3) {
        this.searchAnimFrame = 1;
      }
      // Would set image: nuh_search_1, nuh_search_2, nuh_search_3
      this.setElementProperty(
        this.pInvitationStatusWindowId,
        'nuh_search',
        'frame',
        this.searchAnimFrame
      );
    }

    // Update guide counter
    if (this.elementExists(this.pInvitationStatusWindowId, 'nuh_invitation_status_counter')) {
      const component = this.getComponent() as TutorialComponent | null;
      const guideCount = component?.getGuideCount() || 0;
      const text = `NUH_invitation_guides_found ${guideCount}`;
      this.setText(this.pInvitationStatusWindowId, 'nuh_invitation_status_counter', text);
    }
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
   *
   * Lingo: hideHighlighters()
   */
  hideHighlighters(): void {
    if (!this.windowExists(this.pRoomBarId)) return;

    const highlighters = this.getHighlighterList();
    for (const elementName of Object.values(highlighters)) {
      if (this.elementExists(this.pRoomBarId, elementName)) {
        this.hideElement(this.pRoomBarId, elementName);
      }
    }
    this.removeBlinkTimeout();
  }

  /**
   * Show highlighter for help item
   *
   * Lingo: showHighlighter(tHelpId)
   */
  showHighlighter(helpId: string): void {
    if (!this.windowExists(this.pRoomBarId)) return;

    const highlighters = this.getHighlighterList();
    const elementName = highlighters[helpId];

    if (!elementName) {
      return;
    }

    if (this.elementExists(this.pRoomBarId, elementName)) {
      this.showElement(this.pRoomBarId, elementName);
      this.setElementProperty(
        this.pRoomBarId,
        elementName,
        'member',
        `bar_hilite_icon_${this.highlighterBlinkPhase}`
      );
    }

    this.createBlinkTimeout();
  }

  /**
   * Create highlighter blink timeout
   *
   * Lingo: createTimeout(pHighlighterBlinkTimeoutID, 750, #blinkHighlighters, ...)
   */
  private createBlinkTimeout(): void {
    if ((this as any)[`_interval_${TIMEOUT_HIGHLIGHTER_BLINK}`]) {
      return; // Already exists
    }
    this.createRepeatingTimeout(TIMEOUT_HIGHLIGHTER_BLINK, HIGHLIGHTER_BLINK_INTERVAL, 'blinkHighlighters');
  }

  /**
   * Remove highlighter blink timeout
   *
   * Lingo: removeTimeout(pHighlighterBlinkTimeoutID)
   */
  private removeBlinkTimeout(): void {
    this.removeTimeout(TIMEOUT_HIGHLIGHTER_BLINK);
  }

  /**
   * Blink highlighters
   *
   * Lingo: blinkHighlighters()
   */
  private blinkHighlighters(): void {
    if (!this.windowExists(this.pRoomBarId)) return;

    const highlighters = this.getHighlighterList();

    for (const elementName of Object.values(highlighters)) {
      if (this.elementExists(this.pRoomBarId, elementName)) {
        const visible = this.getElementProperty(this.pRoomBarId, elementName, 'visible');
        if (visible) {
          this.setElementProperty(
            this.pRoomBarId,
            elementName,
            'member',
            `bar_hilite_icon_${this.highlighterBlinkPhase}`
          );
        }
      }
    }

    this.highlighterBlinkPhase++;
    if (this.highlighterBlinkPhase > 2) {
      this.highlighterBlinkPhase = 1;
    }
  }

  /**
   * Handle invitation dialog event
   *
   * Lingo: eventProcInvitation(tEvent, tSprID)
   */
  eventProcInvitation(event: string, sprId: string, param: unknown, windowId: string): void {
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
   *
   * Lingo: eventProcInvitationStatus(tEvent, tSprID)
   */
  eventProcInvitationStatus(event: string, sprId: string, param: unknown, windowId: string): void {
    const component = this.getComponent() as TutorialComponent | null;
    if (!component) return;

    // Handle option buttons
    if (sprId.startsWith('nuh_invitation_option')) {
      const option = sprId.charAt(sprId.length - 1);
      // Would execute configured message from NUH.invitation.option.<option>
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
   *
   * Lingo: eventProcSkipTutorial(tEvent, tSprID)
   */
  eventProcSkipTutorial(event: string, sprId: string, param: unknown, windowId: string): void {
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
