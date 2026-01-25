/**
 * Hobba Interface Class - Moderation UI
 *
 * Ported from: hh_shared/Cast External ParentScript 3 - Hobba Interface Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { HobbaComponent } from './HobbaComponent';
import { CFHData } from '../types';

/**
 * Hobba interface - UI for Call For Help moderation
 */
export class HobbaInterface extends BaseObject {
  private component: HobbaComponent | null = null;
  private windowVisible: boolean = false;
  private alertVisible: boolean = false;

  construct(): void {
    super.construct();
    this.windowVisible = false;
    this.alertVisible = false;
  }

  deconstruct(): void {
    this.hideWindow();
    this.hideAlert();
    super.deconstruct();
  }

  /**
   * Set component reference
   */
  setComponent(component: HobbaComponent): void {
    this.component = component;
  }

  /**
   * Get component
   */
  getComponent(): HobbaComponent | null {
    return this.component;
  }

  /**
   * Show alert indicator
   */
  showAlert(): void {
    if (this.alertVisible) return;

    this.alertVisible = true;
    this.emit('alert_shown');
  }

  /**
   * Hide alert indicator
   */
  hideAlert(): void {
    if (!this.alertVisible) return;

    this.alertVisible = false;
    this.emit('alert_hidden');
  }

  /**
   * Update cry window with current data
   */
  updateCryWindow(): void {
    const cryData = this.component?.getCryDataBase();
    if (!cryData) return;

    // Convert to array for UI
    const cries: CFHData[] = Array.from(cryData.values());

    this.emit('cry_window_updated', { cries });
  }

  /**
   * Show cry window
   */
  showWindow(): void {
    if (this.windowVisible) return;

    this.windowVisible = true;
    this.updateCryWindow();
    this.emit('window_shown');
  }

  /**
   * Hide cry window
   */
  hideWindow(): void {
    if (!this.windowVisible) return;

    this.windowVisible = false;
    this.emit('window_hidden');
  }

  /**
   * Toggle cry window
   */
  toggleWindow(): void {
    if (this.windowVisible) {
      this.hideWindow();
    } else {
      this.showWindow();
    }
  }

  /**
   * Pick a cry to handle
   */
  pickCry(cryId: string, goHelp: boolean = true): void {
    this.component?.sendCryPick(cryId, goHelp);
  }

  /**
   * Block a cry
   */
  blockCry(cryId: string): void {
    this.component?.sendBlockCFH(cryId);
  }

  /**
   * Reply to a cry
   */
  replyCry(cryId: string, message: string): void {
    this.component?.sendCFHReply(cryId, message);
  }

  /**
   * Change cry category
   */
  changeCryCategory(cryId: string, currentCategory: number): void {
    this.component?.sendChangeCFHType(cryId, currentCategory);
  }

  /**
   * Check if alert is visible
   */
  isAlertVisible(): boolean {
    return this.alertVisible;
  }

  /**
   * Check if window is visible
   */
  isWindowVisible(): boolean {
    return this.windowVisible;
  }
}
