/**
 * PostIt Manager Class - Manages sticky note editing
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 22 - PostIt Manager Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { EventEmitter } from '../../../core/events';
import { PostItColors } from '../types';

/**
 * Available post-it colors
 */
export const POSTIT_COLOR_OPTIONS = [
  PostItColors.YELLOW, // #FFFF33
  PostItColors.GREEN,  // #9CFF9C
  PostItColors.PINK,   // #FF9CFF
  PostItColors.BLUE,   // #9CCEFF
] as const;

/**
 * PostIt manager - handles sticky note UI and editing
 */
export class PostItManager extends BaseObject {
  private events: EventEmitter = new EventEmitter();
  private pActivePostItId: string = '';
  private pText: string = '';
  private pColor: string = PostItColors.YELLOW;
  private pLocX: number = 0;
  private pLocY: number = 0;
  private pIsController: boolean = false;
  private pChanged: boolean = false;
  private pIsOwner: boolean = false;
  private pCanRemoveStickies: boolean = false;
  private pWindowOpen: boolean = false;
  private pIsVDStickie: boolean = false;

  construct(): void {
    super.construct();
    // Would register for leaveRoom and changeRoom messages
  }

  deconstruct(): void {
    // Would unregister messages
    super.deconstruct();
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Open post-it editor
   */
  open(id: string, color: string, locX: number, locY: number): void {
    this.pColor = color;
    this.pLocX = locX;
    this.pLocY = locY;
    this.pActivePostItId = id;
    this.pWindowOpen = false;

    // Would request item data from server
    // getThread(#room).getComponent().getRoomConnection().send("G_IDATA", [#integer: integer(id)])

    this.events.emit('requestItemData', { id });
  }

  /**
   * Close post-it editor
   */
  close(): void {
    if (this.pActivePostItId && this.pWindowOpen) {
      // Save changes if modified
      if (this.pChanged) {
        this.events.emit('savePostIt', {
          id: this.pActivePostItId,
          color: this.pColor,
          text: this.pText,
        });
      }
    }

    this.pWindowOpen = false;
    this.pActivePostItId = '';
    this.events.emit('close');
  }

  /**
   * Delete the post-it
   */
  delete(): void {
    if (this.pActivePostItId) {
      this.events.emit('deletePostIt', { id: this.pActivePostItId });
      // Would send REMOVEITEM command
    }

    this.pWindowOpen = false;
    this.pActivePostItId = '';
    this.events.emit('close');
  }

  /**
   * Handle item data received from server
   */
  setItemData(msg: { id: string; type: string; text: string }): void {
    const id = msg.id;
    const type = msg.type;

    // Text starts after first word (color code)
    const textParts = msg.text.split(' ');
    const text = textParts.slice(1).join(' ');

    this.pActivePostItId = id;
    this.pText = text;

    // Determine window type
    this.pIsVDStickie = type === 'FFFFFF'; // Valentine's day stickie

    // Set color
    this.setColor(type, false);

    this.pWindowOpen = true;
    this.pChanged = false;

    this.events.emit('openWindow', {
      id,
      text,
      color: this.pColor,
      locX: this.pLocX,
      locY: this.pLocY,
      isVD: this.pIsVDStickie,
      isController: this.pIsController,
      isOwner: this.pIsOwner,
      canRemove: this.pCanRemoveStickies,
    });
  }

  /**
   * Set post-it color
   */
  setColor(color: string, byUser: boolean = false): void {
    if (byUser) {
      this.pChanged = true;
    }

    this.pColor = color;

    this.events.emit('colorChanged', {
      id: this.pActivePostItId,
      color,
    });
  }

  /**
   * Set permissions
   */
  setPermissions(isController: boolean, isOwner: boolean, canRemoveStickies: boolean): void {
    this.pIsController = isController;
    this.pIsOwner = isOwner;
    this.pCanRemoveStickies = canRemoveStickies;
  }

  /**
   * Handle text change
   */
  onTextChange(newText: string): void {
    this.pText = newText;
    this.pChanged = true;
  }

  /**
   * Handle color button click
   */
  onColorClick(colorIndex: number): void {
    if (!this.pIsController) return;

    if (colorIndex >= 0 && colorIndex < POSTIT_COLOR_OPTIONS.length) {
      this.setColor(POSTIT_COLOR_OPTIONS[colorIndex], true);
    }
  }

  /**
   * Get active post-it ID
   */
  getActiveId(): string {
    return this.pActivePostItId;
  }

  /**
   * Get current color
   */
  getColor(): string {
    return this.pColor;
  }

  /**
   * Get current text
   */
  getText(): string {
    return this.pText;
  }

  /**
   * Check if window is open
   */
  isOpen(): boolean {
    return this.pWindowOpen;
  }

  /**
   * Check if user can edit
   */
  canEdit(): boolean {
    return this.pIsController;
  }
}
