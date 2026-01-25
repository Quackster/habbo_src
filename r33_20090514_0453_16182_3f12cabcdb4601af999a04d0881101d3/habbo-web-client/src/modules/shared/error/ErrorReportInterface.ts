/**
 * Error Report Interface Class - Error display UI
 *
 * Ported from: hh_shared/Cast External ParentScript 55 - Error Report Interface Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { ErrorReportComponent } from './ErrorReportComponent';
import { ErrorReportData } from '../types';

/**
 * Error report interface - displays error messages to user
 */
export class ErrorReportInterface extends BaseObject {
  private component: ErrorReportComponent | null = null;
  private windowVisible: boolean = false;

  construct(): void {
    super.construct();
    this.windowVisible = false;
  }

  deconstruct(): void {
    this.hideWindow();
    super.deconstruct();
  }

  /**
   * Set component reference
   */
  setComponent(component: ErrorReportComponent): void {
    this.component = component;
  }

  /**
   * Get component
   */
  getComponent(): ErrorReportComponent | null {
    return this.component;
  }

  /**
   * Show errors window
   */
  showErrors(): void {
    const errors = this.component?.getErrorLists() || [];

    if (errors.length === 0) {
      return;
    }

    this.windowVisible = true;
    this.emit('errors_shown', { errors });
  }

  /**
   * Hide errors window
   */
  hideWindow(): void {
    if (!this.windowVisible) return;

    this.windowVisible = false;
    this.emit('window_hidden');
  }

  /**
   * Show single error as alert
   */
  showErrorAlert(error: ErrorReportData): void {
    this.emit('error_alert', error);
  }

  /**
   * Dismiss error by index
   */
  dismissError(index: number): void {
    this.component?.clearErrorLists(index + 1);

    const remaining = this.component?.getErrorCount() || 0;
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
    this.component?.clearAllErrors();
    this.hideWindow();
  }

  /**
   * Check if window is visible
   */
  isWindowVisible(): boolean {
    return this.windowVisible;
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
}
