/**
 * Help Tooltip Manager Class - Tooltip display
 *
 * Ported from: hh_shared/Cast External ParentScript 19 - Help Tooltip Manager Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { TooltipParams } from './types';

/**
 * Help tooltip manager - shows contextual help tooltips
 */
export class HelpTooltipManager extends BaseObject {
  private pTipID: string = 'help_tooltip';
  private pTipWidth: number = 150;
  private tooltipElement: HTMLElement | null = null;
  private hideTimeout: ReturnType<typeof setTimeout> | null = null;

  construct(): void {
    super.construct();

    this.pTipID = 'help_tooltip';
    this.pTipWidth = 150;

    // Would register for helptooltip message
  }

  deconstruct(): void {
    this.removeTip();
    super.deconstruct();
  }

  /**
   * Create help tooltip
   */
  createHelpTooltip(params: TooltipParams): boolean {
    if (!params || !params.msg || !params.pos) {
      console.error('Wrong param format for tooltip');
      return false;
    }

    const msg = params.msg;
    const pos = params.pos;

    // Check if pos is a point or rect
    if ('x' in pos && 'y' in pos) {
      return this.createTooltipToPoint(msg, pos);
    } else if ('left' in pos) {
      return this.createTooltipToRect(msg, pos);
    }

    return false;
  }

  /**
   * Create tooltip positioned at a rectangle
   */
  createTooltipToRect(
    msg: string,
    rect: { left: number; top: number; right: number; bottom: number }
  ): boolean {
    const spacing = 7;
    const stageWidth = window.innerWidth;

    // Create tooltip first to get dimensions
    if (!this.createTooltipToPoint(msg, { x: 0, y: 0 })) {
      return false;
    }

    if (!this.tooltipElement) return false;

    const tipHeight = this.tooltipElement.offsetHeight;
    const tipWidth = this.tooltipElement.offsetWidth;

    // Position above rect if space, otherwise below
    let x: number, y: number;

    if (rect.top - tipHeight - spacing > 0) {
      x = rect.left + spacing;
      y = rect.top - tipHeight - spacing;
    } else {
      x = rect.left + spacing;
      y = rect.bottom + spacing;
    }

    // Keep within screen bounds
    if (x + tipWidth > stageWidth) {
      x = stageWidth - tipWidth;
    }

    this.tooltipElement.style.left = `${x}px`;
    this.tooltipElement.style.top = `${y}px`;

    return true;
  }

  /**
   * Create tooltip at a point
   */
  createTooltipToPoint(msg: string, loc: { x: number; y: number }): boolean {
    // Remove existing tooltip
    this.removeTip();

    // Calculate text dimensions
    const lineWidth = this.pTipWidth;
    const fontSize = 12;

    // Estimate line count
    const avgCharsPerLine = Math.floor(lineWidth / (fontSize * 0.6));
    const lineCount = Math.ceil(msg.length / avgCharsPerLine);
    const helpHeight = Math.max(40, (2 * 11) + (lineCount * fontSize));

    // Create tooltip element
    this.tooltipElement = document.createElement('div');
    this.tooltipElement.id = this.pTipID;
    this.tooltipElement.className = 'help-tooltip';
    this.tooltipElement.style.cssText = `
      position: fixed;
      left: ${loc.x}px;
      top: ${loc.y}px;
      width: ${lineWidth + 30}px;
      min-height: ${helpHeight}px;
      background: #333;
      color: #fff;
      padding: 8px 12px;
      border-radius: 4px;
      font-size: ${fontSize}px;
      font-family: sans-serif;
      z-index: 10000;
      word-wrap: break-word;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    `;
    this.tooltipElement.textContent = msg;

    document.body.appendChild(this.tooltipElement);

    // Calculate timeout based on message length
    const timeoutList = [2500, msg.length * 100, 10000];
    timeoutList.sort((a, b) => a - b);
    const timeout = timeoutList[1]; // Middle value

    this.createTipTimeout(timeout);

    return true;
  }

  /**
   * Remove tooltip
   */
  removeTip(): void {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
    }

    if (this.tooltipElement) {
      this.tooltipElement.remove();
      this.tooltipElement = null;
    }
  }

  /**
   * Create auto-hide timeout
   */
  private createTipTimeout(time: number): void {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
    }

    this.hideTimeout = setTimeout(() => {
      this.removeTip();
    }, time);
  }

  /**
   * Show tooltip with message at position
   */
  showTooltip(msg: string, x: number, y: number): void {
    this.createHelpTooltip({ msg, pos: { x, y } });
  }

  /**
   * Show tooltip near element
   */
  showTooltipNearElement(msg: string, element: HTMLElement): void {
    const rect = element.getBoundingClientRect();
    this.createHelpTooltip({
      msg,
      pos: {
        left: rect.left,
        top: rect.top,
        right: rect.right,
        bottom: rect.bottom,
      },
    });
  }
}
