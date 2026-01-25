/**
 * Update Bubble Class - Bubble that follows a user object
 *
 * Ported from: hh_tutorial/Cast External ParentScript 10 - Update Bubble Class.ls
 */

import { StaticBubble } from './StaticBubble';
import { BubblePointerDirection } from './types';

/**
 * User object interface for bubble tracking
 */
interface UserObject {
  getPartLocation(part: string): { x: number; y: number };
}

/**
 * Update bubble that follows a user/pet in the room
 */
export class UpdateBubble extends StaticBubble {
  private humanObj: UserObject | null = null;
  private skipFrames: boolean = true;
  private needsUpdate: boolean = true;

  constructor(id?: string) {
    super(id);
    this.textWidth = 160;
  }

  /**
   * Deconstruct
   */
  deconstruct(): void {
    this.needsUpdate = false;
    super.deconstruct();
  }

  /**
   * Set text
   */
  setText(text: string): void {
    super.setText(text);
    this.selectPointerAndPosition(this.direction);
  }

  /**
   * Set target user object
   */
  setTargetHumanObj(humanObj: UserObject): void {
    this.humanObj = humanObj;
  }

  /**
   * Update (called each frame)
   */
  update(): void {
    // Skip every other frame for performance
    this.skipFrames = !this.skipFrames;
    if (this.skipFrames) {
      return;
    }

    if (!this.humanObj) {
      return;
    }

    // Get head location from user object
    const humanLoc = this.humanObj.getPartLocation('hd');
    this.setProperty('targetX', humanLoc.x);
    this.setProperty('targetY', humanLoc.y);

    // Position bubble based on user position
    const sideThreshold = this.width - 10;
    if (humanLoc.x < sideThreshold) {
      this.selectPointerAndPosition(7);
    } else {
      this.selectPointerAndPosition(4);
    }
  }

  /**
   * Check if needs update
   */
  getNeedsUpdate(): boolean {
    return this.needsUpdate;
  }
}

/**
 * Tutor Bubble Class - Bubble for showing tutor arrival
 *
 * Ported from: hh_tutorial/Cast External ParentScript 11 - Tutor Bubble Class.ls
 */
export class TutorBubble extends UpdateBubble {
  constructor(id?: string) {
    super(id);
  }

  /**
   * Handle close click - removes from NUH interface
   */
  onCloseClick(): void {
    this.events.emit('tutorBubbleClose', { bubbleId: this.bubbleId });
  }
}
