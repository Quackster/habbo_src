/**
 * PostIt Item Class - Sticky note wall item
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 21 - PostIt Item Class.ls
 */

import { ItemObject } from '../ItemObject';
import { PostItColors } from '../types';

/**
 * PostIt item - sticky note on wall
 */
export class PostItItem extends ItemObject {
  /**
   * Handle selection - opens post-it manager
   */
  select(): boolean {
    // Would get or create post-it manager
    // const postItMgr = getObject(#postit_manager) || createObject(#postit_manager, "PostIt Manager Class");

    let locX = 200;
    let locY = 200;

    if (this.pSprList.length > 0) {
      locX = this.pSprList[0].x;
      locY = this.pSprList[0].y;
    }

    // Would call postItMgr.open(this.id, this.getColor(), locX, locY);
    return false;
  }

  /**
   * Set post-it color
   */
  setColor(color: string): boolean {
    if (this.pSprList.length === 0) {
      return true;
    }

    this.pSprList[0].color = color;
    this.pType = color;
    return true;
  }

  /**
   * Get color as RGB object
   */
  getColor(): string {
    return this.pType || PostItColors.YELLOW;
  }
}
