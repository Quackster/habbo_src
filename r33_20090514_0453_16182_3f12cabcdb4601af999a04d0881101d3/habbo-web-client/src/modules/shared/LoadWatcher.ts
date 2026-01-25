/**
 * Load Watcher Component Class - Asset loading tracking
 *
 * Ported from: hh_shared/Cast External ParentScript 13 - Load Watcher Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';

/**
 * Load watcher - tracks when essential data has loaded
 */
export class LoadWatcher extends BaseObject {
  private pGotProductData: boolean = false;
  private pGotFurniData: boolean = false;
  private pGotFigureData: boolean = false;
  private pGotRoomData: boolean = false;

  construct(): void {
    super.construct();

    this.pGotProductData = false;
    this.pGotFurniData = false;
    this.pGotFigureData = false;
    this.pGotRoomData = false;

    // Would register for various data received messages
  }

  deconstruct(): void {
    // Would unregister messages
    super.deconstruct();
  }

  /**
   * Mark product data as received
   */
  productDataReceived(): void {
    this.pGotProductData = true;
    this.checkInitComplete();
  }

  /**
   * Mark furni data as received
   */
  furniDataReceived(): void {
    this.pGotFurniData = true;
    this.checkInitComplete();
  }

  /**
   * Mark figure data as received
   */
  figureDataReceived(): void {
    this.pGotFigureData = true;
    this.checkInitComplete();
  }

  /**
   * Mark room data as received
   */
  roomDataReceived(): void {
    this.pGotRoomData = true;
    this.checkInitComplete();
  }

  /**
   * Check if initial data loading is complete
   */
  private checkInitComplete(): void {
    if (this.pGotProductData && this.pGotFurniData) {
      this.emit('heavy_init_finished');

      // Would call JavaScript function
      // callJavaScriptFunction('clientHeavyInitFinished', String(getClientUpTime()));
    }
  }

  /**
   * Check if all data is loaded
   */
  isFullyLoaded(): boolean {
    return (
      this.pGotProductData &&
      this.pGotFurniData &&
      this.pGotFigureData &&
      this.pGotRoomData
    );
  }

  /**
   * Get loading status
   */
  getLoadingStatus(): Record<string, boolean> {
    return {
      productData: this.pGotProductData,
      furniData: this.pGotFurniData,
      figureData: this.pGotFigureData,
      roomData: this.pGotRoomData,
    };
  }

  /**
   * Reset loading status
   */
  reset(): void {
    this.pGotProductData = false;
    this.pGotFurniData = false;
    this.pGotFigureData = false;
    this.pGotRoomData = false;
  }
}
