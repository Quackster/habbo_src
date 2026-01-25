/**
 * Hobba Interface Class - Moderation UI
 *
 * Ported from: hh_shared/Cast External ParentScript 3 - Hobba Interface Class.ls
 */

import { BaseInterface } from '../../../core/BaseInterface';
import { HobbaComponent } from './HobbaComponent';
import { CFHData } from '../types';

/**
 * Hobba interface - UI for Call For Help moderation
 */
export class HobbaInterface extends BaseInterface {
  private pWindowId: string = 'hobba_cfh_window';
  private pAlertWindowId: string = 'hobba_alert_window';

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.hideWindow();
    this.hideAlert();
    super.deconstruct();
  }

  /**
   * Show alert indicator
   *
   * Lingo: showAlert()
   */
  async showAlert(): Promise<void> {
    if (this.windowExists(this.pAlertWindowId)) return;

    await this.createWindow(this.pAlertWindowId, 'hobba_alert.window');

    if (this.windowExists(this.pAlertWindowId)) {
      this.registerWindowProcedure(this.pAlertWindowId, 'eventProcAlert', 'mouseUp');
    }
  }

  /**
   * Hide alert indicator
   *
   * Lingo: hideAlert()
   */
  hideAlert(): void {
    if (this.windowExists(this.pAlertWindowId)) {
      this.removeWindow(this.pAlertWindowId);
    }
  }

  /**
   * Update cry window with current data
   *
   * Lingo: updateCryWindow()
   */
  updateCryWindow(): void {
    if (!this.windowExists(this.pWindowId)) return;

    const component = this.getComponent() as HobbaComponent | null;
    const cryData = component?.getCryDataBase();
    if (!cryData) return;

    // Convert to array and populate list
    const cries: CFHData[] = Array.from(cryData.values());

    // Would update list element with cries
    if (this.elementExists(this.pWindowId, 'cry_list')) {
      this.setElementProperty(this.pWindowId, 'cry_list', 'data', cries);
    }

    // Update count
    if (this.elementExists(this.pWindowId, 'cry_count')) {
      this.setText(this.pWindowId, 'cry_count', `${cries.length} calls`);
    }
  }

  /**
   * Show cry window
   *
   * Lingo: showWindow()
   */
  async showWindow(): Promise<void> {
    if (this.windowExists(this.pWindowId)) return;

    await this.createWindow(this.pWindowId, 'hobba_cfh.window');

    if (this.windowExists(this.pWindowId)) {
      this.registerWindowProcedure(this.pWindowId, 'eventProcCry', 'mouseUp');
      this.centerWindow(this.pWindowId);
      this.updateCryWindow();
    }
  }

  /**
   * Hide cry window
   *
   * Lingo: hideWindow()
   */
  hideWindow(): void {
    if (this.windowExists(this.pWindowId)) {
      this.removeWindow(this.pWindowId);
    }
  }

  /**
   * Toggle cry window
   */
  toggleWindow(): void {
    if (this.windowExists(this.pWindowId)) {
      this.hideWindow();
    } else {
      this.showWindow();
    }
  }

  /**
   * Pick a cry to handle
   */
  pickCry(cryId: string, goHelp: boolean = true): void {
    const component = this.getComponent() as HobbaComponent | null;
    component?.sendCryPick(cryId, goHelp);
  }

  /**
   * Block a cry
   */
  blockCry(cryId: string): void {
    const component = this.getComponent() as HobbaComponent | null;
    component?.sendBlockCFH(cryId);
  }

  /**
   * Reply to a cry
   */
  replyCry(cryId: string, message: string): void {
    const component = this.getComponent() as HobbaComponent | null;
    component?.sendCFHReply(cryId, message);
  }

  /**
   * Change cry category
   */
  changeCryCategory(cryId: string, currentCategory: number): void {
    const component = this.getComponent() as HobbaComponent | null;
    component?.sendChangeCFHType(cryId, currentCategory);
  }

  /**
   * Alert window event procedure
   *
   * Lingo: eventProcAlert(tEvent, tSprID, tParam, tWindowID)
   */
  eventProcAlert(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'close':
        this.hideAlert();
        break;
      case 'alert_button':
        this.hideAlert();
        this.showWindow();
        break;
    }
  }

  /**
   * Cry window event procedure
   *
   * Lingo: eventProcCry(tEvent, tSprID, tParam, tWindowID)
   */
  eventProcCry(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'close':
        this.hideWindow();
        break;
      case 'pick_button':
        // Would get selected cry ID
        break;
      case 'pick_go_button':
        // Would get selected cry ID and go help
        break;
      case 'block_button':
        // Would get selected cry ID
        break;
    }
  }

  /**
   * Check if alert is visible
   */
  isAlertVisible(): boolean {
    return this.windowExists(this.pAlertWindowId);
  }

  /**
   * Check if window is visible
   */
  isWindowVisible(): boolean {
    return this.windowExists(this.pWindowId);
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }

  /**
   * Get alert window ID
   */
  getAlertWindowId(): string {
    return this.pAlertWindowId;
  }
}
