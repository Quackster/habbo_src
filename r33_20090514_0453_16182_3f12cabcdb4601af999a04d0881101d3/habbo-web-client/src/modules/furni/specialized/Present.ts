/**
 * Furniture Present Class - Gift box furniture
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 59 - Furniture Present Class.ls
 */

import { ActiveObjectExtension } from '../ActiveObjectExtension';

/**
 * Present (gift box) furniture
 */
export class Present extends ActiveObjectExtension {
  private pMessage: string = '';
  private pCardObjId: string = 'PackageCardObj';

  protected prepare(data?: Record<string, unknown>): boolean {
    const stuffdata = data?.stuffdata as string | undefined;

    if (stuffdata) {
      if (stuffdata.charAt(0) === '!') {
        // New format: message after !
        this.pMessage = stuffdata.substring(1);
      } else {
        // Old format: item4:item5:item6:message
        const parts = stuffdata.split(':');
        this.pMessage = parts.slice(3).join(':');
      }
    }

    return true;
  }

  /**
   * Handle selection (double-click shows card)
   */
  select(): boolean {
    // Would check for double-click
    this.showCard();
    return true;
  }

  /**
   * Show the gift message card
   */
  showCard(): void {
    // Would create and show package card UI
    // if (objectExists(pCardObj)) removeObject(pCardObj)
    // createObject(pCardObj, "Package Card Class")
    // getObject(pCardObj).define([#id: me.getID(), #Msg: pMessage, #loc: me.pSprList[1].loc])

    // Emit event for UI to handle
    // Would emit event with gift message data
  }

  /**
   * Get gift message
   */
  getMessage(): string {
    return this.pMessage;
  }

  /**
   * Set gift message
   */
  setMessage(message: string): void {
    this.pMessage = message;
  }

  /**
   * Get card display location
   */
  getCardLocation(): { x: number; y: number } {
    if (this.pSprList.length > 0) {
      return {
        x: this.pSprList[0].x,
        y: this.pSprList[0].y,
      };
    }
    return { x: 0, y: 0 };
  }
}
