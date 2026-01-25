/**
 * Club Component Class - Business logic for Habbo Club
 *
 * Ported from: hh_club/Cast External ParentScript 3 - Club Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { session } from '../../core/Session';
import { ClubStatus, ClubState, ClubSubscriptionLength } from './types';
import { ClubInterface } from './ClubInterface';

export class ClubComponent extends BaseObject {
  private state: ClubState = {
    status: null,
    giftCount: 0,
    acceptedGifts: 0,
  };
  private giftTimeout: ReturnType<typeof setTimeout> | null = null;

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    if (this.giftTimeout) {
      clearTimeout(this.giftTimeout);
      this.giftTimeout = null;
    }
    this.state.status = null;
    super.deconstruct();
  }

  /**
   * Show gift dialogs
   */
  showGifts(count: number): void {
    this.state.giftCount = count;
    this.state.acceptedGifts = 0;

    if (this.state.giftCount > 0) {
      const iface = this.getInterface() as ClubInterface | null;
      if (iface) {
        iface.showGiftInfo();
      }
    }
  }

  /**
   * Accept a gift
   */
  acceptGift(): void {
    if (this.state.giftCount > this.state.acceptedGifts) {
      this.state.acceptedGifts++;

      if (this.state.giftCount > this.state.acceptedGifts) {
        // More gifts to accept
        if (this.giftTimeout) {
          clearTimeout(this.giftTimeout);
        }
        this.giftTimeout = setTimeout(() => this.showNextGift(), 1000);
      } else {
        // All gifts accepted
        this.sendAcceptGift();
      }
    }
  }

  /**
   * Reject remaining gifts
   */
  rejectGift(): void {
    if (this.state.giftCount > 0) {
      this.state.giftCount = 0;
      if (this.state.acceptedGifts > 0) {
        this.sendAcceptGift();
      }
    }
  }

  /**
   * Send gift acceptance to server
   */
  private sendAcceptGift(): boolean {
    const acceptedGifts = this.state.acceptedGifts;
    this.resetGiftList();

    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) {
      console.error('ClubComponent: Could not find connection:', connId);
      return false;
    }

    conn.send('SCR_GIFT_APPROVAL', { integer: acceptedGifts });
    return true;
  }

  /**
   * Reset gift list
   */
  resetGiftList(): void {
    this.state.giftCount = 0;
    this.state.acceptedGifts = 0;
  }

  /**
   * Show next gift dialog
   */
  private showNextGift(): void {
    const iface = this.getInterface() as ClubInterface | null;
    if (iface) {
      iface.showGiftInfo();
    }
  }

  /**
   * Set club status
   */
  setStatus(status: ClubStatus, responseFlag: number): void {
    const oldStatus = this.state.status;
    this.state.status = status;

    // Update session
    session.set('club_status', status);

    // Notify interface
    const iface = this.getInterface() as ClubInterface | null;
    if (iface) {
      iface.updateClubStatus(status, responseFlag, oldStatus);
    }

    // Broadcast status update
    executeMessage('updateClubStatus', status);
  }

  /**
   * Get club status
   */
  getStatus(): ClubStatus | null {
    return this.state.status;
  }

  /**
   * Subscribe to Habbo Club
   */
  subscribe(chosenLength: ClubSubscriptionLength): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) {
      console.error('ClubComponent: Could not find connection:', connId);
      return false;
    }

    conn.send('SCR_BUY', {
      string: 'club_habbo',
      integer: chosenLength,
    });
    return true;
  }

  /**
   * Ask for badge update
   */
  askForBadgeUpdate(): boolean {
    const connId = getVariable('connection.info.id', 'Info') as string;
    const conn = getConnection(connId);
    if (!conn) {
      console.error('ClubComponent: Could not find connection:', connId);
      return false;
    }

    conn.send('GETAVAILABLEBADGES');
    return true;
  }

  /**
   * Check if user is a club member
   */
  isClubMember(): boolean {
    return this.state.status !== null && this.state.status.daysLeft > 0;
  }

  /**
   * Get days left
   */
  getDaysLeft(): number {
    return this.state.status?.daysLeft ?? 0;
  }

  /**
   * Get elapsed periods
   */
  getElapsedPeriods(): number {
    return this.state.status?.elapsedPeriods ?? 0;
  }

  /**
   * Get prepaid periods
   */
  getPrepaidPeriods(): number {
    return this.state.status?.prepaidPeriods ?? 0;
  }
}
