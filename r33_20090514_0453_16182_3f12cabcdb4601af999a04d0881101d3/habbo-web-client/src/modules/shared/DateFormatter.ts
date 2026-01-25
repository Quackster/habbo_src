/**
 * Date Formatter Class - Date formatting utilities
 *
 * Ported from: hh_shared/Cast External ParentScript 22 - Date Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { DateFormatType } from './types';

/**
 * Date formatter - formats dates according to locale
 */
export class DateFormatter extends BaseObject {
  private pDateFormat: DateFormatType = 'dd-mm-yyyy';

  construct(): void {
    super.construct();
    this.pDateFormat = 'dd-mm-yyyy';
  }

  /**
   * Define date format
   */
  define(dateFormat?: DateFormatType): void {
    this.pDateFormat = dateFormat || 'dd-mm-yyyy';
  }

  /**
   * Get local date from string
   */
  getLocalDateFromStr(dateStr: string): string {
    if (!dateStr || typeof dateStr !== 'string') {
      return this.pDateFormat;
    }

    // Try different delimiters
    let delimiter = '-';
    if (!dateStr.includes('-')) {
      delimiter = '.';
    }

    const parts = dateStr.split(delimiter);
    if (parts.length < 3) {
      return dateStr;
    }

    return this.getLocalDate(parts[0], parts[1], parts[2]);
  }

  /**
   * Get local date from day, month, year
   */
  getLocalDate(day: string | number, month: string | number, year: string | number): string {
    if (!day || !month || !year) {
      return this.pDateFormat;
    }

    let date = this.pDateFormat;

    const dayNum = parseInt(String(day), 10);
    const monthNum = parseInt(String(month), 10);
    const yearNum = parseInt(String(year), 10);

    // Replace placeholders
    date = date.replace('dd', String(dayNum).padStart(2, '0'));
    date = date.replace('mm', String(monthNum).padStart(2, '0'));
    date = date.replace('yyyy', String(yearNum));
    date = date.replace('yy', String(yearNum).slice(-2));

    return date;
  }

  /**
   * Parse date string to components
   */
  parseDateString(dateStr: string): { day: number; month: number; year: number } | null {
    if (!dateStr) return null;

    let delimiter = '-';
    if (!dateStr.includes('-')) {
      delimiter = '.';
    }
    if (!dateStr.includes(delimiter)) {
      delimiter = '/';
    }

    const parts = dateStr.split(delimiter);
    if (parts.length < 3) return null;

    // Determine order based on format
    let day: number, month: number, year: number;

    if (this.pDateFormat.startsWith('yyyy')) {
      // yyyy-mm-dd
      year = parseInt(parts[0], 10);
      month = parseInt(parts[1], 10);
      day = parseInt(parts[2], 10);
    } else if (this.pDateFormat.startsWith('mm')) {
      // mm-dd-yyyy
      month = parseInt(parts[0], 10);
      day = parseInt(parts[1], 10);
      year = parseInt(parts[2], 10);
    } else {
      // dd-mm-yyyy (default)
      day = parseInt(parts[0], 10);
      month = parseInt(parts[1], 10);
      year = parseInt(parts[2], 10);
    }

    return { day, month, year };
  }

  /**
   * Format date as ISO string (yyyy-mm-dd)
   */
  toISOFormat(day: number, month: number, year: number): string {
    return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  }

  /**
   * Get current date formatted
   */
  getCurrentDate(): string {
    const now = new Date();
    return this.getLocalDate(now.getDate(), now.getMonth() + 1, now.getFullYear());
  }

  /**
   * Get format string
   */
  getFormat(): DateFormatType {
    return this.pDateFormat;
  }

  /**
   * Set format string
   */
  setFormat(format: DateFormatType): void {
    this.pDateFormat = format;
  }
}
