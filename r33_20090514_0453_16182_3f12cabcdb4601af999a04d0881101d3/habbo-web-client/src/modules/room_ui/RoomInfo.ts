/**
 * Room Info Class - Room name, owner, ratings, events
 *
 * Ported from: hh_room_ui/Cast External ParentScript 4 - Room Info Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { RoomInfoData, RoomEventData, WindowIds } from './types';

/**
 * Room info - displays room name, owner, ratings, and event info
 */
export class RoomInfo extends BaseObject {
  private pWindowID: string = WindowIds.ROOM_INFO;
  private pEventInfoWindowID: string = WindowIds.EVENT_INFO;
  private pUseRatings: boolean = false;
  private pRoomData: RoomInfoData | null = null;
  private pEventData: RoomEventData | null = null;

  construct(): void {
    super.construct();

    this.pWindowID = 'RoomInfoWindow';
    this.pEventInfoWindowID = 'EventInfoWindow';
    this.pUseRatings = false;

    // Would check variable room.rating.enable
    // Would register for roomRatingChanged and roomEventInfoUpdated messages
  }

  deconstruct(): void {
    this.hideRoomInfo();
    super.deconstruct();
  }

  /**
   * Show room info panel
   */
  showRoomInfo(roomData?: RoomInfoData): void {
    if (roomData) {
      this.pRoomData = roomData;
    }

    if (!this.pRoomData) {
      return;
    }

    // Only show for private rooms
    if (this.pRoomData.type !== 'private') {
      this.hideRoomInfo();
      return;
    }

    // Would create info window and populate fields
    this.emit('room_info_shown', {
      roomName: this.pRoomData.name,
      owner: this.pRoomData.owner,
    });

    this.updateRatingData();
    this.updateRoomEventInfo();
  }

  /**
   * Hide room info panel
   */
  hideRoomInfo(): void {
    // Would remove info window and event info window
    this.emit('room_info_hidden');
  }

  /**
   * Send room rating
   */
  sendFlatRate(value: number): void {
    // Would send RATEFLAT command
    this.emit('rate_flat', { value });
  }

  /**
   * Update rating display
   */
  updateRatingData(rating?: number, hasRated?: boolean): void {
    if (!this.pUseRatings) {
      this.hideRatingElements();
      return;
    }

    if (rating !== undefined) {
      if (this.pRoomData) {
        this.pRoomData.rating = rating;
        this.pRoomData.hasRated = hasRated ?? false;
      }
    }

    const currentRating = this.pRoomData?.rating;
    const alreadyRated = this.pRoomData?.hasRated;

    if (currentRating === -1 || currentRating === undefined) {
      // Show rating buttons
      this.emit('rating_buttons_shown');
    } else {
      // Show rating value
      this.emit('rating_value_shown', { rating: currentRating });
    }
  }

  /**
   * Hide rating elements
   */
  hideRatingElements(): void {
    this.emit('rating_elements_hidden');
  }

  /**
   * Update room event info
   */
  updateRoomEventInfo(eventData?: RoomEventData): void {
    if (eventData) {
      this.pEventData = eventData;
    }

    if (!this.pEventData) {
      this.emit('event_link_hidden');
      return;
    }

    if (this.pEventData.hostID > 0) {
      this.emit('event_link_shown', { name: this.pEventData.name });
    } else {
      this.emit('event_link_hidden');
    }
  }

  /**
   * Show event info popup
   */
  showEventInfo(): void {
    if (!this.pEventData) return;

    // Would create event info window
    this.emit('event_info_shown', {
      name: this.pEventData.name,
      desc: this.pEventData.desc,
    });
  }

  /**
   * Remove event info popup
   */
  removeEventInfo(): void {
    // Would remove event info window
    this.emit('event_info_removed');
  }

  /**
   * Quit current room event
   */
  quitEvent(): void {
    // Would send QUIT_ROOMEVENT command
    this.emit('quit_event');
    this.removeEventInfo();
  }

  /**
   * Edit current room event
   */
  editEvent(): void {
    this.emit('edit_event');
    this.removeEventInfo();
  }

  /**
   * Handle UI event
   */
  handleEvent(event: string, spriteId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'room_info_rate_plus':
        this.sendFlatRate(1);
        break;
      case 'room_info_rate_minus':
        this.sendFlatRate(-1);
        break;
      case 'roominfo_event_link':
        this.showEventInfo();
        break;
      case 'room_info_event_details_close':
        this.removeEventInfo();
        break;
      case 'room_info_event_details_quit':
        this.quitEvent();
        break;
      case 'room_info_event_details_edit':
        this.editEvent();
        break;
    }
  }

  /**
   * Get current room data
   */
  getRoomData(): RoomInfoData | null {
    return this.pRoomData;
  }

  /**
   * Set room data
   */
  setRoomData(data: RoomInfoData): void {
    this.pRoomData = data;
  }

  /**
   * Set event data
   */
  setEventData(data: RoomEventData): void {
    this.pEventData = data;
    this.updateRoomEventInfo();
  }

  /**
   * Enable/disable ratings
   */
  setUseRatings(use: boolean): void {
    this.pUseRatings = use;
  }
}
