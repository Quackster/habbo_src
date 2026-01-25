/**
 * E-Dice Class - Dice furniture
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 56 - E-Dice Class.ls
 */

import { ActiveObjectExtension } from '../ActiveObjectExtension';
import { DiceStates } from '../types';

/**
 * Dice furniture - can be thrown to show random value
 */
export class Dice extends ActiveObjectExtension {
  private pActive: boolean = true;
  private pValue: number = 1;

  protected prepare(data?: Record<string, unknown>): boolean {
    this.pActive = true;

    const stuffdata = data?.stuffdata;
    let value = typeof stuffdata === 'string' ? parseInt(stuffdata, 10) : stuffdata as number;

    if (isNaN(value) || value === undefined) {
      value = 1;
    }

    // Clamp value to valid range
    if (value > DiceStates.MAX) {
      value = DiceStates.MAX;
    }
    if (value < DiceStates.MIN) {
      value = DiceStates.MIN;
    }

    this.pValue = value;
    return true;
  }

  /**
   * Handle selection (double-click to roll)
   */
  select(): boolean {
    if (this.pSprList.length < 2) {
      return false;
    }

    // Check if clicking on dice top (sprite 2)
    // Would check rollover in real implementation

    // Check if double click
    // Would check the doubleClick in real implementation

    // Check if user is close enough
    // const userObj = getOwnUser();
    // if (abs(userObj.locX - this.pLocX) > 1 || abs(userObj.locY - this.pLocY) > 1) {
    //   // Move to adjacent tile
    //   return true;
    // }

    if (!this.pActive) {
      // Send throw dice command
      this.throwDice();
    }

    return true;
  }

  /**
   * Called when dice is thrown
   */
  diceThrown(value: number): void {
    this.pActive = true;

    if (value > DiceStates.MAX) {
      this.pValue = DiceStates.MIN;
    } else {
      this.pValue = value;
    }
  }

  /**
   * Update animation
   */
  update(): boolean {
    if (!this.pActive) {
      return true;
    }

    if (this.pSprList.length < 2) {
      return false;
    }

    const sprite = this.pSprList[1];
    const memName = sprite.memberName;

    // Extract class from member name
    const parts = memName.split('_');
    const className = parts.slice(0, -6).join('_');

    if (this.pValue < 0) {
      // Rolling animation - alternate between frames 7 and 0
      const currentFrame = memName.endsWith('_7') ? 0 : 7;
      sprite.memberName = `${className}_b_0_1_1_0_${currentFrame}`;
    } else {
      // Show final value
      sprite.memberName = `${className}_b_0_1_1_0_${this.pValue}`;
      this.pActive = false;
    }

    return true;
  }

  /**
   * Throw the dice (send to server)
   */
  throwDice(): void {
    // Would send THROW_DICE command to server
    // getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", [#integer: integer(me.getID())])
  }

  /**
   * Turn off dice (close without value showing)
   */
  turnOff(): void {
    // Would send DICE_OFF command to server
    // getThread(#room).getComponent().getRoomConnection().send("DICE_OFF", [#integer: integer(me.getID())])
  }

  /**
   * Get current value
   */
  getValue(): number {
    return this.pValue;
  }

  /**
   * Check if dice is rolling
   */
  isRolling(): boolean {
    return this.pActive && this.pValue < 0;
  }
}
