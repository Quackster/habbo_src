/**
 * Recycler Component Class - Business logic for item recycling
 *
 * Ported from: hh_recycler/Cast External ParentScript 4 - Recycler Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { registerMessage, unregisterMessage, executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import { RecyclerState, RecyclerFurniItem } from './types';
import { RecyclerInterface } from './RecyclerInterface';

export class RecyclerComponent extends BaseObject {
  private serviceEnabled: boolean = false;
  private recyclerState: RecyclerState | null = null;
  private giveFurniPool: RecyclerFurniItem[] = [];
  private isVisible: boolean = false;
  private openingRequestPending: boolean = false;
  private givePoolSize: number = 5;
  private timeout: number = 0;

  construct(): void {
    super.construct();
    registerMessage('userloggedin', this.id, 'initialize');
  }

  deconstruct(): void {
    unregisterMessage('userloggedin', this.id);
    super.deconstruct();
  }

  /**
   * Initialize after login
   */
  initialize(): void {
    // Ready to use recycler
  }

  /**
   * Enable/disable service
   */
  enableService(enabled: boolean): void {
    this.serviceEnabled = enabled;
  }

  /**
   * Set recycler state
   */
  setState(state: RecyclerState, timeout?: number): void {
    this.recyclerState = state;
    if (timeout !== undefined) {
      this.timeout = timeout;
    }
    this.openRecyclerWithState(state);
  }

  /**
   * Handle recycling finished
   */
  recyclingFinished(success: boolean): void {
    if (!success) return;

    executeMessage('showPurchaseOk');
    this.requestRecyclerState();
  }

  /**
   * Request recycler state from server
   */
  requestRecyclerState(): void {
    const connId = getVariable('connection.room.id', 'Room') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send('GET_RECYCLER_STATUS');
    }
  }

  /**
   * Open recycler
   */
  openRecycler(): void {
    this.openingRequestPending = true;
    this.requestRecyclerState();
  }

  /**
   * Open recycler with state
   */
  private openRecyclerWithState(state: RecyclerState): void {
    if (this.openingRequestPending) {
      this.isVisible = true;
      this.openingRequestPending = false;
    }
    this.setStateTo(state);
  }

  /**
   * Close recycler
   */
  closeRecycler(): void {
    this.isVisible = false;
    this.openingRequestPending = false;
    this.giveFurniPool = [];

    const iface = this.getInterface() as RecyclerInterface | null;
    if (iface) {
      iface.setHostWindowObject(null);
    }

    executeMessage('refreshRoom');
  }

  /**
   * Start recycling process
   */
  startRecycling(): boolean {
    if (!this.isPoolFull()) {
      return false;
    }

    // Check if trading window is open
    const traderOpen = false; // TODO: Check trading state
    if (traderOpen) {
      executeMessage('alert', { Msg: 'Cannot recycle while trading', modal: true });
      return false;
    }

    this.setState('closed');

    const connId = getVariable('connection.room.id', 'Room') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    const stripIds = this.giveFurniPool.map((item) => parseInt(item.props.stripId));
    conn.send('RECYCLE_ITEMS', { integers: [5, ...stripIds] });

    return true;
  }

  /**
   * Check if recycler is open and visible
   */
  isRecyclerOpenAndVisible(): boolean {
    return this.recyclerState === 'open' && this.isVisible;
  }

  /**
   * Get furniture give pool
   */
  getGiveFurniPool(): RecyclerFurniItem[] {
    return [...this.giveFurniPool];
  }

  /**
   * Get recycler state
   */
  getState(): RecyclerState | null {
    return this.recyclerState;
  }

  /**
   * Get timeout
   */
  getTimeout(): number {
    return this.timeout;
  }

  /**
   * Remove furniture from give pool
   */
  removeFurniFromGivePool(index: number): void {
    if (index >= 0 && index < this.giveFurniPool.length) {
      this.giveFurniPool.splice(index, 1);
      const iface = this.getInterface() as RecyclerInterface | null;
      if (iface) {
        iface.updateRecycleButton();
      }
    }
  }

  /**
   * Add furniture to give pool
   */
  addFurnitureToGivePool(itemClass: string, id: string, props: Record<string, unknown>): boolean {
    if (this.isFurniInRecycler(props.stripId as string)) {
      return false;
    }
    if (this.isPoolFull()) {
      return false;
    }

    this.giveFurniPool.push({
      class: itemClass,
      id,
      props: props as RecyclerFurniItem['props'],
    });

    const iface = this.getInterface() as RecyclerInterface | null;
    if (iface) {
      iface.updateSlots();
    }

    return true;
  }

  /**
   * Check if pool is full
   */
  isPoolFull(): boolean {
    return this.giveFurniPool.length >= this.givePoolSize;
  }

  /**
   * Check if furniture is already in recycler
   */
  isFurniInRecycler(stripId: string): boolean {
    if (this.recyclerState !== 'open' || this.giveFurniPool.length === 0) {
      return false;
    }
    return this.giveFurniPool.some((item) => item.props.stripId === stripId);
  }

  /**
   * Set state to specific value
   */
  private setStateTo(state: RecyclerState): void {
    this.recyclerState = state;

    switch (state) {
      case 'open':
        this.giveFurniPool = [];
        executeMessage('setRoomClickAction', 'tradeItem');
        break;
      case 'closed':
      case 'timeout':
        executeMessage('setRoomClickAction', 'moveHuman');
        break;
    }

    const iface = this.getInterface() as RecyclerInterface | null;
    if (iface) {
      iface.updateView(state);
    }
  }

  /**
   * Check if service is enabled
   */
  isServiceEnabled(): boolean {
    return this.serviceEnabled;
  }
}
