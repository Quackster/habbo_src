/**
 * Statistics Broker Class - Analytics tracking
 *
 * Ported from: hh_shared/Cast External ParentScript 63 - Statistics Broker Class.ls
 */

import { BaseObject } from '../../core/BaseObject';

/**
 * Statistics broker - sends analytics/tracking data
 */
export class StatisticsBroker extends BaseObject {
  private pTrackingURL: string = '';

  construct(): void {
    super.construct();

    // Would get from variable
    // pTrackingURL = getVariable('stats.tracking.url');
    this.pTrackingURL = '';

    // Would register listener for message 166
  }

  deconstruct(): void {
    // Would unregister listener
    super.deconstruct();
  }

  /**
   * Set tracking URL
   */
  setTrackingURL(url: string): void {
    this.pTrackingURL = url;
  }

  /**
   * Get tracking URL
   */
  getTrackingURL(): string {
    return this.pTrackingURL;
  }

  /**
   * Update stats - send tracking code
   */
  updateStats(trackingCode: string): void {
    if (!this.pTrackingURL || typeof this.pTrackingURL !== 'string') {
      return;
    }

    // Replace placeholder with tracking code
    const trackingUrl = this.pTrackingURL.replace('\\TCODE', trackingCode);

    // Send tracking request (fire and forget)
    this.sendTrackingRequest(trackingUrl);
  }

  /**
   * Send tracking request
   */
  private sendTrackingRequest(url: string): void {
    // Use Image for simple fire-and-forget request
    const img = new Image();
    img.src = url;

    // Alternative: use fetch
    // fetch(url, { mode: 'no-cors' }).catch(() => {});
  }

  /**
   * Track event
   */
  trackEvent(category: string, action: string, label?: string, value?: number): void {
    // Build tracking code
    const parts = [category, action];
    if (label) parts.push(label);
    if (value !== undefined) parts.push(String(value));

    const trackingCode = parts.join('|');
    this.updateStats(trackingCode);

    // Also emit event for custom handlers
    this.emit('track_event', { category, action, label, value });
  }

  /**
   * Track page view
   */
  trackPageView(pageName: string): void {
    this.trackEvent('pageview', pageName);
  }

  /**
   * Track room entry
   */
  trackRoomEntry(roomId: string, roomName: string): void {
    this.trackEvent('room', 'enter', `${roomId}:${roomName}`);
  }

  /**
   * Track purchase
   */
  trackPurchase(itemName: string, price: number): void {
    this.trackEvent('purchase', itemName, undefined, price);
  }
}
