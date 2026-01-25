/**
 * Error Report Component Class - Error collection and reporting
 *
 * Ported from: hh_shared/Cast External ParentScript 56 - Error Report Component Class.ls
 */

import { BaseObject } from '../../../core/BaseObject';
import { ErrorReportData } from '../types';
import { ErrorReportInterface } from './ErrorReportInterface';

/**
 * Error report component - collects and manages error reports
 */
export class ErrorReportComponent extends BaseObject {
  private pErrorLists: ErrorReportData[] = [];
  private iface: ErrorReportInterface | null = null;

  construct(): void {
    super.construct();
    this.pErrorLists = [];

    // Would register for showErrorMessage and crossDomainDownload messages
  }

  deconstruct(): void {
    // Would unregister messages
    this.pErrorLists = [];
    super.deconstruct();
  }

  /**
   * Set interface reference
   */
  setInterface(iface: ErrorReportInterface): void {
    this.iface = iface;
  }

  /**
   * Get interface
   */
  getInterface(): ErrorReportInterface | null {
    return this.iface;
  }

  /**
   * Register cross-domain download error
   */
  registerCrossDomainError(url: string): void {
    // Check if user has fuse_alert right
    let showAlert = true;

    // Would check session for user_rights
    // const rights = session.get('user_rights');
    // if (Array.isArray(rights) && !rights.includes('fuse_alert')) {
    //   showAlert = false;
    // }

    if (showAlert) {
      const message = `Cross-domain download blocked:\n${url}`;
      this.showErrorMessage('client', message);
    }
  }

  /**
   * Show error message
   */
  showErrorMessage(errorId: string, errorMessage: string): void {
    const errorData: ErrorReportData = {
      errorId,
      errorMsg: errorMessage,
      timestamp: Date.now(),
    };

    this.storeErrorReport(errorData);
    this.iface?.showErrors();
  }

  /**
   * Store error report
   */
  storeErrorReport(errorData: ErrorReportData): void {
    this.pErrorLists.push(errorData);
    this.emit('error_stored', errorData);
  }

  /**
   * Get error lists
   */
  getErrorLists(): ErrorReportData[] {
    return [...this.pErrorLists];
  }

  /**
   * Get error count
   */
  getErrorCount(): number {
    return this.pErrorLists.length;
  }

  /**
   * Clear error lists (up to index)
   */
  clearErrorLists(count?: number): void {
    const clearCount = Math.min(count ?? this.pErrorLists.length, this.pErrorLists.length);

    for (let i = 0; i < clearCount; i++) {
      this.pErrorLists.shift();
    }

    this.emit('errors_cleared', clearCount);
  }

  /**
   * Clear all errors
   */
  clearAllErrors(): void {
    this.pErrorLists = [];
    this.emit('all_errors_cleared');
  }

  /**
   * Report error to server
   */
  reportError(errorId: string, errorMessage: string, stackTrace?: string): void {
    const report = {
      errorId,
      errorMsg: errorMessage,
      stackTrace,
      timestamp: Date.now(),
      userAgent: navigator.userAgent,
    };

    // Would send to server
    this.emit('error_reported', report);
  }
}
