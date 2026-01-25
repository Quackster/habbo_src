/**
 * Habbo Wheel Class - Wheel of fortune furniture
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 10 - Habbo Wheel Class.ls
 */

import { ActiveObjectExtension } from '../ActiveObjectExtension';
import { FurnitureDefinition } from '../types';

/**
 * Wheel of fortune furniture
 */
export class HabboWheel extends ActiveObjectExtension {
  private pRunning: boolean = false;
  private pStateCount: number = 0;
  private pTargetState: number = 0;

  /**
   * Define the wheel
   */
  define(data: FurnitureDefinition): boolean {
    this.pRunning = false;
    this.pTargetState = 0;

    const result = super.define(data);

    // Calculate state count from sequence list
    // States are organized as: [result states] [spin transitions] [idle]
    this.pStateCount = Math.floor((this.pStateSequenceList.length - 2) / 3);
    this.pRunning = true;

    return result;
  }

  /**
   * Handle selection (double-click to spin)
   */
  select(): boolean {
    // Would send SPIN_WHEEL_OF_FORTUNE command
    // getThread(#room).getComponent().getRoomConnection().send("SPIN_WHEEL_OF_FORTUNE", [#integer: integer(me.getID())])
    return true;
  }

  /**
   * Update animation
   */
  update(): boolean {
    // Check if any animation is still playing
    if (!this.pIsAnimatingList.includes(1)) {
      // Animation finished, transition to next state

      // Check if in spinning state (stateCount * 3 + 1)
      if (this.pState === (this.pStateCount * 3) + 1) {
        // Move to idle spinning
        this.setState((this.pStateCount * 3) + 2);
      } else if (this.pState === (this.pStateCount * 3) + 2) {
        // In idle spinning, check if target is set
        if (this.pTargetState) {
          // Move to slowdown state for target
          this.setState(this.pStateCount + this.pTargetState);
        } else {
          // Keep spinning idle
          this.setState((this.pStateCount * 3) + 2);
        }
      } else if (this.pState === (this.pStateCount + this.pTargetState) && this.pTargetState !== 0) {
        // Finished slowdown, show result
        this.setState((this.pStateCount * 2) + this.pTargetState);
        this.pTargetState = 0;
      }
    }

    return super.update();
  }

  /**
   * Set state with wheel logic
   */
  setState(newState: string | number | undefined): boolean {
    let state = typeof newState === 'string' ? parseInt(newState, 10) : (newState ?? 0);

    // Handle special state -1 (start spinning or show idle)
    if (state === -1) {
      if (this.pRunning) {
        state = (this.pStateCount * 3) + 1;
      } else {
        state = (this.pStateCount * 3) + 2;
      }
    }

    // Check if this is a result state (1 to stateCount)
    if (state >= 1 && state <= this.pStateCount) {
      if (this.pRunning) {
        // Set as target if currently spinning
        if (
          this.pTargetState === 0 &&
          (this.pState === (this.pStateCount * 3) + 1 || this.pState === (this.pStateCount * 3) + 2)
        ) {
          this.pTargetState = state;
        }
        return true;
      } else {
        // Not running, set directly
        return super.setState(state - 1);
      }
    }

    return super.setState(state - 1);
  }

  /**
   * Start spinning
   */
  spin(): void {
    // Would send command to server
  }

  /**
   * Get state count
   */
  getStateCount(): number {
    return this.pStateCount;
  }

  /**
   * Check if wheel is spinning
   */
  isSpinning(): boolean {
    return this.pRunning && this.pTargetState === 0 &&
      (this.pState === (this.pStateCount * 3) + 1 || this.pState === (this.pStateCount * 3) + 2);
  }

  /**
   * Get target state (result to land on)
   */
  getTargetState(): number {
    return this.pTargetState;
  }
}
