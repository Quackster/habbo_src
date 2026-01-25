/**
 * Photo Component Class - Business logic for photo system
 *
 * Ported from: hh_photo/Cast External ParentScript 3 - Photo Component Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import {
  registerMessage,
  unregisterMessage,
  executeMessage,
} from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import {
  PhotoData,
  PhotoItemData,
  calculateChecksum,
  decodeScandinavian,
  PhotoCommands,
} from './types';
import { PhotoInterface } from './PhotoInterface';

export class PhotoComponent extends BaseObject {
  private photoCache: Map<string, PhotoData> = new Map();
  private photoMember: HTMLCanvasElement | null = null;
  private film: number = 0;
  private lastPhotoData: PhotoData | null = null;

  // Current photo viewing state
  private itemId: string = '';
  private photoId: string = '';
  private photoTime: string = '';
  private photoText: string = '';
  private locX: number = 0;
  private locY: number = 0;

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.photoMember = null;
    this.photoCache.clear();
    super.deconstruct();
  }

  /**
   * Store a picture from camera
   */
  storePicture(canvas: HTMLCanvasElement, text: string): void {
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const checksum = calculateChecksum(imageData);

    const photoData: PhotoData = {
      image: imageData,
      time: new Date().toLocaleString(),
      checksum,
    };

    // Send photo text to server
    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send(`${PhotoCommands.PHOTO_TEXT} /${text}`);
    }

    // Store binary data (in browser, this would be sent to server)
    this.lastPhotoData = photoData;

    // Simulate async storage completion
    setTimeout(() => {
      this.binaryDataStored(this.generatePhotoId());
    }, 100);
  }

  /**
   * Called when binary data has been stored on server
   */
  binaryDataStored(photoId: string): void {
    const iface = this.getInterface() as PhotoInterface | null;
    if (iface) {
      iface.saveOk();
    }

    if (this.lastPhotoData) {
      this.photoCache.set(photoId, this.lastPhotoData);
      this.lastPhotoData = null;
    }
  }

  /**
   * Called when binary data is received from server
   */
  binaryDataReceived(data: PhotoData, photoId: string): void {
    if (!data || !data.image) return;

    this.photoCache.set(photoId, data);

    const iface = this.getInterface() as PhotoInterface | null;
    if (!iface) return;

    // Create canvas for photo
    if (!this.photoMember) {
      this.photoMember = document.createElement('canvas');
    }

    const canvas = this.photoMember;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Draw image data to canvas
    if (data.image instanceof ImageData) {
      canvas.width = data.image.width;
      canvas.height = data.image.height;
      ctx.putImageData(data.image, 0, 0);
    }

    // Validate checksum
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const checksumOk =
      data.checksum !== undefined &&
      calculateChecksum(imageData) === data.checksum;

    if (!checksumOk) {
      // Draw invalid photo indicator
      ctx.fillStyle = '#888888';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = '#ff0000';
      ctx.font = '12px Arial';
      ctx.fillText('Invalid Photo', 10, canvas.height / 2);
    } else if (this.photoTime && this.photoTime.length > 5) {
      // Draw timestamp on photo
      this.drawTimestamp(ctx, canvas.width, canvas.height, this.photoTime);
    }

    // Update interface with photo
    iface.setPhotoCanvas(canvas);
    iface.setPhotoText(this.photoText);
  }

  /**
   * Draw timestamp on photo
   */
  private drawTimestamp(
    ctx: CanvasRenderingContext2D,
    width: number,
    height: number,
    timestamp: string
  ): void {
    ctx.font = '10px monospace';
    const metrics = ctx.measureText(timestamp);
    const x = width - 3 - metrics.width;
    const y = height - 5;

    // Draw black outline
    ctx.fillStyle = '#000000';
    ctx.fillText(timestamp, x - 1, y);
    ctx.fillText(timestamp, x + 1, y);
    ctx.fillText(timestamp, x, y - 1);
    ctx.fillText(timestamp, x, y + 1);

    // Draw white text
    ctx.fillStyle = '#fffff0';
    ctx.fillText(timestamp, x, y);
  }

  /**
   * Open photo viewer for an item
   */
  openPhoto(itemId: string, locX: number, locY: number): void {
    this.locX = Math.min(locX, 500);
    this.locY = Math.max(locY, 100);

    registerMessage(
      `itemdata_received${itemId}`,
      this.id,
      'setItemData'
    );

    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send(PhotoCommands.GET_ITEM_DATA, { integer: parseInt(itemId) });
    }
  }

  /**
   * Set item data from server
   */
  setItemData(msg: { id: string; text: string }): void {
    this.itemId = msg.id;

    const lines = msg.text.split('\n');
    const firstLine = lines[0] || '';
    const words = firstLine.split(' ');

    const authorId = words[0] || '';
    this.photoTime = words.slice(1).join(' ');
    this.photoText = decodeScandinavian(lines.slice(1).join('\n'));

    unregisterMessage(`itemdata_received${this.itemId}`, this.id);

    // Check cache first
    const cachedPhoto = this.photoCache.get(this.photoId);
    if (cachedPhoto) {
      this.binaryDataReceived(cachedPhoto, this.photoId);
    } else {
      // Request photo from server
      this.retrieveBinaryData(this.itemId, authorId);
    }

    const iface = this.getInterface() as PhotoInterface | null;
    if (iface) {
      iface.openPhotoWindow(this.locX, this.locY, this.canRemovePhoto());
    }
  }

  /**
   * Retrieve binary photo data from server
   */
  private retrieveBinaryData(itemId: string, authorId: string): void {
    // This would make a server request to get the actual photo data
    // For now, emit an event that can be handled by the application
    executeMessage('retrievePhotoData', { itemId, authorId });
  }

  /**
   * Check if current user can remove photos
   */
  private canRemovePhoto(): boolean {
    // Would check session for room_owner or fuse_remove_photos right
    return false;
  }

  /**
   * Generate a unique photo ID
   */
  private generatePhotoId(): string {
    return `photo_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Set film count
   */
  setFilm(count: number): void {
    this.film = count;

    const iface = this.getInterface() as PhotoInterface | null;
    if (iface) {
      iface.setButtonHilites();
      iface.updateFilm();
    }
  }

  /**
   * Get remaining film count
   */
  getFilm(): number {
    return this.film;
  }

  /**
   * Remove photo from room
   */
  removePhoto(itemId: string): boolean {
    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (!conn) return false;

    conn.send(PhotoCommands.REMOVE_ITEM, { integer: parseInt(itemId) });
    return true;
  }

  /**
   * Get current item ID
   */
  getItemId(): string {
    return this.itemId;
  }
}
