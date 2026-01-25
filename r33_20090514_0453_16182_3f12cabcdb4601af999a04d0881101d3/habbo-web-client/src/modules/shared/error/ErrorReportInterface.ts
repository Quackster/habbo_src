/**
 * Error Report Interface Class - Error display UI
 *
 * Ported from: hh_shared/Cast External ParentScript 55 - Error Report Interface Class.ls
 */

import { BaseInterface } from '../../../core/BaseInterface';
import { ErrorReportComponent } from './ErrorReportComponent';
import { ErrorReportData } from '../types';

/**
 * Error report interface - displays error messages to user
 */
export class ErrorReportInterface extends BaseInterface {
  private pWindowId: string = 'error_report_window';

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.hideWindow();
    super.deconstruct();
  }

  /**
   * Show errors window
   *
   * Lingo: showErrors()
   */
  async showErrors(): Promise<void> {
    const component = this.getComponent() as ErrorReportComponent | null;
    const errors = component?.getErrorLists() || [];

    if (errors.length === 0) {
      return;
    }

    if (!this.windowExists(this.pWindowId)) {
      await this.createWindow(this.pWindowId, 'error_report.window');

      if (this.windowExists(this.pWindowId)) {
        this.registerWindowProcedure(this.pWindowId, 'eventProcError', 'mouseUp');
        this.centerWindow(this.pWindowId);
      }
    }

    // Update error list
    if (this.elementExists(this.pWindowId, 'error_list')) {
      const formattedErrors = errors.map((e) => this.formatError(e));
      this.setElementProperty(this.pWindowId, 'error_list', 'data', formattedErrors);
    }

    // Update count
    if (this.elementExists(this.pWindowId, 'error_count')) {
      this.setText(this.pWindowId, 'error_count', `${errors.length} error(s)`);
    }
  }

  /**
   * Hide errors window
   *
   * Lingo: hideWindow()
   */
  hideWindow(): void {
    if (this.windowExists(this.pWindowId)) {
      this.removeWindow(this.pWindowId);
    }
  }

  /**
   * Show single error as alert
   *
   * Lingo: showErrorAlert()
   */
  async showErrorAlert(error: ErrorReportData): Promise<void> {
    // Would show modal alert with error message
    if (this.elementExists(this.pWindowId, 'error_text')) {
      this.setText(this.pWindowId, 'error_text', this.formatError(error));
    }
  }

  /**
   * Dismiss error by index
   */
  dismissError(index: number): void {
    const component = this.getComponent() as ErrorReportComponent | null;
    component?.clearErrorLists(index + 1);

    const remaining = component?.getErrorCount() || 0;
    if (remaining === 0) {
      this.hideWindow();
    } else {
      this.showErrors();
    }
  }

  /**
   * Dismiss all errors
   */
  dismissAllErrors(): void {
    const component = this.getComponent() as ErrorReportComponent | null;
    component?.clearAllErrors();
    this.hideWindow();
  }

  /**
   * Error window event procedure
   *
   * Lingo: eventProcError(tEvent, tSprID, tParam, tWindowID)
   */
  eventProcError(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'close':
        this.hideWindow();
        break;
      case 'dismiss_button':
        // Would get selected error index
        this.dismissError(0);
        break;
      case 'dismiss_all_button':
        this.dismissAllErrors();
        break;
    }
  }

  /**
   * Check if window is visible
   */
  isWindowVisible(): boolean {
    return this.windowExists(this.pWindowId);
  }

  /**
   * Format error for display
   */
  formatError(error: ErrorReportData): string {
    const timestamp = error.timestamp
      ? new Date(error.timestamp).toLocaleTimeString()
      : '';

    return `[${error.errorId}] ${timestamp}\n${error.errorMsg}`;
  }

  /**
   * Get window ID
   */
  getWindowId(): string {
    return this.pWindowId;
  }
}
