/**
 * Photo Interface Class - UI for camera and photo viewing
 *
 * Ported from: hh_photo/Cast External ParentScript 2 - Photo Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';
import {
  registerMessage,
  unregisterMessage,
  executeMessage,
} from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import {
  CameraMode,
  CameraButtonId,
  CAMERA_HAND_ITEM_ID,
  PhotoCommands,
} from './types';
import { PhotoComponent } from './PhotoComponent';

export class PhotoInterface extends BaseObject {
  private events: EventEmitter = new EventEmitter();
  private mode: CameraMode = CameraMode.CLOSED;
  private zoomLevel: number = 1;
  private maxZoom: number = 11;

  // Noise animation state
  private noiseDirH: number = 1;
  private noiseDirV: number = 1;
  private updateInterval: ReturnType<typeof setInterval> | null = null;

  // Camera state
  private capturedImage: ImageData | null = null;
  private displayCanvas: HTMLCanvasElement | null = null;

  // Hand item data for placement
  private handItemData: unknown = null;

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.close();
    super.deconstruct();
  }

  /**
   * Open camera window
   */
  open(): void {
    this.mode = CameraMode.LIVE;

    registerMessage('leaveRoom', this.id, 'close');
    registerMessage('changeRoom', this.id, 'close');

    // Send carry object message
    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send(PhotoCommands.CARRY_OBJECT, { integer: CAMERA_HAND_ITEM_ID });
    }

    this.setCameraToLiveMode();
    this.setButtonHilites();
    this.updateFilm();
    this.startUpdate();

    this.events.emit('cameraOpened');
  }

  /**
   * Close camera window
   */
  close(): void {
    // Send stop carrying
    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send(PhotoCommands.CARRY_OBJECT, { integer: 0 });
    }

    this.mode = CameraMode.CLOSED;
    this.stopUpdate();

    unregisterMessage('leaveRoom', this.id);
    unregisterMessage('changeRoom', this.id);

    this.events.emit('cameraClosed');
  }

  /**
   * Update film count display
   */
  updateFilm(): void {
    const component = this.getComponent() as PhotoComponent | null;
    const filmCount = component?.getFilm() ?? 0;
    this.events.emit('filmUpdated', filmCount);
  }

  /**
   * Update noise animation
   */
  private update(): void {
    if (this.mode !== CameraMode.LIVE) return;

    // Animate noise elements
    this.events.emit('noiseAnimationTick', {
      dirH: this.noiseDirH,
      dirV: this.noiseDirV,
    });

    // Bounce direction at edges (simplified)
    if (Math.random() < 0.05) this.noiseDirH *= -1;
    if (Math.random() < 0.05) this.noiseDirV *= -1;
  }

  /**
   * Set camera to live preview mode
   */
  setCameraToLiveMode(): void {
    this.events.emit('setLiveMode');
  }

  /**
   * Handle camera button press
   */
  handleButtonPress(buttonId: CameraButtonId): void {
    const component = this.getComponent() as PhotoComponent | null;

    switch (buttonId) {
      case 'cam_shoot':
        if (this.mode !== CameraMode.LIVE) return;
        this.takePhoto();
        break;

      case 'cam_release':
        if (this.mode === CameraMode.STILL) {
          this.setCameraToLiveMode();
          this.mode = CameraMode.LIVE;
        }
        break;

      case 'cam_save':
        if (this.mode === CameraMode.STILL && component) {
          if (component.getFilm() > 0) {
            this.mode = CameraMode.SAVE;
            this.events.emit('showSaveText');
            // Get text from UI and store picture
            this.events.emit('requestPhotoText', (text: string) => {
              if (this.displayCanvas) {
                component.storePicture(this.displayCanvas, text);
              }
            });
          } else {
            executeMessage('alert', { Msg: 'cam_save_nofilm' });
          }
        }
        break;

      case 'cam_zoom_in':
        if (this.mode === CameraMode.STILL) {
          if (this.zoomLevel < this.maxZoom) {
            this.zoomLevel++;
            this.applyZoom();
          }
        }
        break;

      case 'cam_zoom_out':
        if (this.mode === CameraMode.STILL) {
          if (this.zoomLevel > 1) {
            this.zoomLevel--;
            this.applyZoom();
          }
        }
        break;

      case 'cam_close':
        this.close();
        break;
    }

    this.setButtonHilites();
  }

  /**
   * Take a photo
   */
  private takePhoto(): void {
    this.zoomLevel = 1;

    // Notify room to hide UI elements
    executeMessage('takingPhoto');

    // Request screen capture from renderer
    this.events.emit('captureScreen', (imageData: ImageData) => {
      this.capturedImage = imageData;

      // Create display canvas
      this.displayCanvas = document.createElement('canvas');
      this.displayCanvas.width = imageData.width;
      this.displayCanvas.height = imageData.height;
      const ctx = this.displayCanvas.getContext('2d');
      if (ctx) {
        ctx.putImageData(imageData, 0, 0);
        // Draw border
        ctx.strokeStyle = '#000000';
        ctx.strokeRect(0, 0, imageData.width, imageData.height);
      }

      // Apply sepia-like coloring effect
      this.applyPhotoEffect();

      this.mode = CameraMode.STILL;
      this.setButtonHilites();

      executeMessage('photoTaken');
      this.events.emit('photoCapture', this.displayCanvas);
    });
  }

  /**
   * Apply vintage photo effect
   */
  private applyPhotoEffect(): void {
    if (!this.displayCanvas) return;
    const ctx = this.displayCanvas.getContext('2d');
    if (!ctx) return;

    // Apply sepia/vintage coloring (color: 681F10, bgColor: FFCC66)
    const imageData = ctx.getImageData(
      0,
      0,
      this.displayCanvas.width,
      this.displayCanvas.height
    );
    const data = imageData.data;

    for (let i = 0; i < data.length; i += 4) {
      // Convert to grayscale
      const gray = data[i] * 0.299 + data[i + 1] * 0.587 + data[i + 2] * 0.114;

      // Apply sepia toning
      data[i] = Math.min(255, gray + 40); // Red
      data[i + 1] = Math.min(255, gray + 20); // Green
      data[i + 2] = gray; // Blue
    }

    ctx.putImageData(imageData, 0, 0);
  }

  /**
   * Apply zoom to captured image
   */
  private applyZoom(): void {
    if (!this.capturedImage || !this.displayCanvas) return;

    const ctx = this.displayCanvas.getContext('2d');
    if (!ctx) return;

    const width = this.capturedImage.width;
    const height = this.capturedImage.height;

    const zoomedWidth = width / this.zoomLevel;
    const zoomedHeight = height / this.zoomLevel;

    const srcX = (width - zoomedWidth) / 2;
    const srcY = (height - zoomedHeight) / 2;

    // Create temp canvas with original image
    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = width;
    tempCanvas.height = height;
    const tempCtx = tempCanvas.getContext('2d');
    if (tempCtx) {
      tempCtx.putImageData(this.capturedImage, 0, 0);

      // Draw zoomed portion
      ctx.fillStyle = '#eeeeee';
      ctx.fillRect(0, 0, width, height);
      ctx.drawImage(
        tempCanvas,
        srcX,
        srcY,
        zoomedWidth,
        zoomedHeight,
        0,
        0,
        width,
        height
      );
    }

    this.applyPhotoEffect();
    this.events.emit('photoZoomed', this.displayCanvas);
  }

  /**
   * Set button highlight states based on mode
   */
  setButtonHilites(): void {
    const component = this.getComponent() as PhotoComponent | null;
    const hasFilm = (component?.getFilm() ?? 0) > 0;

    const hilited: CameraButtonId[] = [];
    const unhilited: CameraButtonId[] = [];

    switch (this.mode) {
      case CameraMode.LIVE:
        hilited.push('cam_shoot');
        unhilited.push(
          'cam_release',
          'cam_save',
          'cam_zoom_in',
          'cam_zoom_out',
          'cam_txtscreen'
        );
        break;

      case CameraMode.STILL:
        hilited.push('cam_release', 'cam_txtscreen');
        unhilited.push('cam_shoot');
        if (hasFilm) {
          hilited.push('cam_save', 'cam_zoom_in', 'cam_zoom_out');
        }
        break;

      case CameraMode.SAVE:
        unhilited.push(
          'cam_shoot',
          'cam_release',
          'cam_save',
          'cam_zoom_in',
          'cam_zoom_out',
          'cam_txtscreen'
        );
        break;
    }

    this.events.emit('buttonStatesChanged', { hilited, unhilited });
  }

  /**
   * Called when save is complete
   */
  saveOk(): void {
    this.mode = CameraMode.LIVE;
    this.setCameraToLiveMode();
    this.events.emit('hideSaveText');
    this.setButtonHilites();
    this.updateFilm();
  }

  /**
   * Start update loop
   */
  private startUpdate(): void {
    if (this.updateInterval) return;
    this.updateInterval = setInterval(() => this.update(), 50);
  }

  /**
   * Stop update loop
   */
  private stopUpdate(): void {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }

  /**
   * Show help line for element
   */
  showHelpLine(elementId: string): void {
    const helpTexts: Record<string, string> = {
      cam_shoot: 'Take a photo',
      cam_release: 'Discard photo',
      cam_save: 'Save photo',
      cam_zoom_in: 'Zoom in',
      cam_zoom_out: 'Zoom out',
      cam_txtscreen: 'Add text',
      photo_picnumber: 'Remaining film',
    };

    const text = helpTexts[elementId];
    if (text) {
      this.events.emit('helpTextChanged', text);
    }
  }

  /**
   * Hide help line
   */
  hideHelpLine(): void {
    this.events.emit('helpTextChanged', '');
  }

  /**
   * Handle hand item selection (camera from inventory)
   */
  handItemSelect(data: unknown, isPrivateRoom: boolean): void {
    if (!isPrivateRoom) {
      this.open();
    } else {
      this.handItemData = data;
      this.events.emit('showCameraDialog');
    }
  }

  /**
   * Handle camera dialog choice
   */
  handleDialogChoice(choice: 'open' | 'place'): void {
    if (choice === 'open') {
      this.open();
    } else if (choice === 'place') {
      // Start item placement in room
      executeMessage('startItemPlacing', this.handItemData);
    }
    this.events.emit('closeCameraDialog');
  }

  /**
   * Open photo viewer window
   */
  openPhotoWindow(x: number, y: number, canRemove: boolean): void {
    this.events.emit('photoWindowOpened', { x, y, canRemove });
  }

  /**
   * Set photo canvas for viewer
   */
  setPhotoCanvas(canvas: HTMLCanvasElement): void {
    this.events.emit('photoCanvasReady', canvas);
  }

  /**
   * Set photo text for viewer
   */
  setPhotoText(text: string): void {
    this.events.emit('photoTextReady', text);
  }

  /**
   * Close photo viewer
   */
  closePhotoViewer(): void {
    this.events.emit('photoWindowClosed');
  }

  /**
   * Handle photo viewer button press
   */
  handlePhotoViewerButton(buttonId: 'photo_close' | 'photo_remove'): void {
    const component = this.getComponent() as PhotoComponent | null;

    if (buttonId === 'photo_close') {
      this.closePhotoViewer();
    } else if (buttonId === 'photo_remove' && component) {
      if (component.removePhoto(component.getItemId())) {
        this.closePhotoViewer();
      }
    }
  }

  /**
   * Get current camera mode
   */
  getMode(): CameraMode {
    return this.mode;
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }
}
