/**
 * Photo Interface Class - UI for camera and photo viewing
 *
 * Ported from: hh_photo/Cast External ParentScript 2 - Photo Interface Class.ls
 */

import { BaseInterface } from '../../core/BaseInterface';
import { executeMessage } from '../../core/MessageBus';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';
import {
  CameraMode,
  CameraButtonId,
  CAMERA_HAND_ITEM_ID,
  PhotoCommands,
} from './types';
import { PhotoComponent } from './PhotoComponent';

export class PhotoInterface extends BaseInterface {
  private pCameraWindowId: string = 'camera_window';
  private pPhotoViewerWindowId: string = 'photo_viewer_window';
  private pCameraDialogId: string = 'camera_dialog_window';

  private pMode: CameraMode = CameraMode.CLOSED;
  private pZoomLevel: number = 1;
  private pMaxZoom: number = 11;

  // Noise animation state
  private pNoiseDirH: number = 1;
  private pNoiseDirV: number = 1;

  // Camera state
  private pCapturedImage: ImageData | null = null;
  private pDisplayCanvas: HTMLCanvasElement | null = null;

  // Hand item data for placement
  private pHandItemData: unknown = null;

  construct(): void {
    super.construct();
  }

  deconstruct(): void {
    this.close();
    super.deconstruct();
  }

  /**
   * Open camera window
   *
   * Lingo: createWindow(pCameraWindowID, "camera.window")
   */
  async open(): Promise<void> {
    this.pMode = CameraMode.LIVE;

    this.registerMsg('leaveRoom', 'close');
    this.registerMsg('changeRoom', 'close');

    // Send carry object message
    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send(PhotoCommands.CARRY_OBJECT, { integer: CAMERA_HAND_ITEM_ID });
    }

    await this.createWindow(this.pCameraWindowId, 'camera.window');
    this.registerWindowProcedure(this.pCameraWindowId, 'cameraEventProc');

    this.setCameraToLiveMode();
    this.setButtonHilites();
    this.updateFilm();
    this.startNoiseAnimation();
  }

  /**
   * Close camera window
   *
   * Lingo: removeWindow(pCameraWindowID)
   */
  close(): void {
    // Send stop carrying
    const connId = getVariable('connection.room.id', '') as string;
    const conn = getConnection(connId);
    if (conn) {
      conn.send(PhotoCommands.CARRY_OBJECT, { integer: 0 });
    }

    this.pMode = CameraMode.CLOSED;
    this.removeTimeout('noise_animation');

    this.unregisterMsg('leaveRoom');
    this.unregisterMsg('changeRoom');

    this.removeWindow(this.pCameraWindowId);
  }

  /**
   * Update film count display
   *
   * Lingo: updateFilm()
   */
  updateFilm(): void {
    if (!this.windowExists(this.pCameraWindowId)) return;

    const component = this.getComponent() as PhotoComponent | null;
    const filmCount = component?.getFilm() ?? 0;

    if (this.elementExists(this.pCameraWindowId, 'film_count')) {
      this.setText(this.pCameraWindowId, 'film_count', String(filmCount));
    }
  }

  /**
   * Start noise animation loop
   */
  private startNoiseAnimation(): void {
    this.animateNoise();
  }

  /**
   * Animate noise
   */
  private animateNoise(): void {
    if (this.pMode !== CameraMode.LIVE) return;
    if (!this.windowExists(this.pCameraWindowId)) return;

    // Update noise element position
    if (this.elementExists(this.pCameraWindowId, 'noise_overlay')) {
      const currentH = this.getElementProperty(this.pCameraWindowId, 'noise_overlay', 'locH') as number ?? 0;
      const currentV = this.getElementProperty(this.pCameraWindowId, 'noise_overlay', 'locV') as number ?? 0;

      // Move noise
      const newH = currentH + this.pNoiseDirH;
      const newV = currentV + this.pNoiseDirV;

      this.setElementProperty(this.pCameraWindowId, 'noise_overlay', 'locH', newH);
      this.setElementProperty(this.pCameraWindowId, 'noise_overlay', 'locV', newV);

      // Bounce direction at edges
      if (Math.random() < 0.05) this.pNoiseDirH *= -1;
      if (Math.random() < 0.05) this.pNoiseDirV *= -1;
    }

    this.createTimeout('noise_animation', 50, 'animateNoise');
  }

  /**
   * Set camera to live preview mode
   *
   * Lingo: setCameraToLiveMode()
   */
  setCameraToLiveMode(): void {
    if (!this.windowExists(this.pCameraWindowId)) return;

    // Show live preview element
    if (this.elementExists(this.pCameraWindowId, 'live_preview')) {
      this.showElement(this.pCameraWindowId, 'live_preview');
    }

    // Hide captured image
    if (this.elementExists(this.pCameraWindowId, 'captured_image')) {
      this.hideElement(this.pCameraWindowId, 'captured_image');
    }

    // Show noise overlay
    if (this.elementExists(this.pCameraWindowId, 'noise_overlay')) {
      this.showElement(this.pCameraWindowId, 'noise_overlay');
    }

    // Hide text input
    if (this.elementExists(this.pCameraWindowId, 'photo_text')) {
      this.hideElement(this.pCameraWindowId, 'photo_text');
    }
  }

  /**
   * Handle camera button press
   *
   * Lingo: handleButtonPress(buttonId)
   */
  handleButtonPress(buttonId: CameraButtonId): void {
    const component = this.getComponent() as PhotoComponent | null;

    switch (buttonId) {
      case 'cam_shoot':
        if (this.pMode !== CameraMode.LIVE) return;
        this.takePhoto();
        break;

      case 'cam_release':
        if (this.pMode === CameraMode.STILL) {
          this.setCameraToLiveMode();
          this.pMode = CameraMode.LIVE;
          this.startNoiseAnimation();
        }
        break;

      case 'cam_save':
        if (this.pMode === CameraMode.STILL && component) {
          if (component.getFilm() > 0) {
            this.pMode = CameraMode.SAVE;
            // Show text input
            if (this.elementExists(this.pCameraWindowId, 'photo_text')) {
              this.showElement(this.pCameraWindowId, 'photo_text');
              this.setText(this.pCameraWindowId, 'photo_text', '');
            }
          } else {
            executeMessage('alert', { Msg: 'cam_save_nofilm' });
          }
        }
        break;

      case 'cam_zoom_in':
        if (this.pMode === CameraMode.STILL) {
          if (this.pZoomLevel < this.pMaxZoom) {
            this.pZoomLevel++;
            this.applyZoom();
          }
        }
        break;

      case 'cam_zoom_out':
        if (this.pMode === CameraMode.STILL) {
          if (this.pZoomLevel > 1) {
            this.pZoomLevel--;
            this.applyZoom();
          }
        }
        break;

      case 'cam_close':
        this.close();
        break;

      case 'cam_txtscreen':
        // Save with text
        if (this.pMode === CameraMode.SAVE && component) {
          const text = this.getText(this.pCameraWindowId, 'photo_text');
          if (this.pDisplayCanvas) {
            component.storePicture(this.pDisplayCanvas, text);
          }
        }
        break;
    }

    this.setButtonHilites();
  }

  /**
   * Take a photo
   *
   * Lingo: takePhoto()
   */
  private takePhoto(): void {
    this.pZoomLevel = 1;

    // Notify room to hide UI elements
    executeMessage('takingPhoto');

    // In actual implementation, this would capture from the room renderer
    // For now, create a placeholder
    const width = 320;
    const height = 240;

    this.pCapturedImage = new ImageData(width, height);
    this.pDisplayCanvas = document.createElement('canvas');
    this.pDisplayCanvas.width = width;
    this.pDisplayCanvas.height = height;

    const ctx = this.pDisplayCanvas.getContext('2d');
    if (ctx) {
      // Apply sepia effect (placeholder)
      ctx.fillStyle = '#d4c4a0';
      ctx.fillRect(0, 0, width, height);
      ctx.strokeStyle = '#000000';
      ctx.strokeRect(0, 0, width, height);
    }

    this.pMode = CameraMode.STILL;
    this.removeTimeout('noise_animation');

    // Show captured image
    if (this.elementExists(this.pCameraWindowId, 'captured_image')) {
      this.feedImage(this.pCameraWindowId, 'captured_image', this.pDisplayCanvas);
      this.showElement(this.pCameraWindowId, 'captured_image');
    }

    // Hide live preview and noise
    if (this.elementExists(this.pCameraWindowId, 'live_preview')) {
      this.hideElement(this.pCameraWindowId, 'live_preview');
    }
    if (this.elementExists(this.pCameraWindowId, 'noise_overlay')) {
      this.hideElement(this.pCameraWindowId, 'noise_overlay');
    }

    this.setButtonHilites();
    executeMessage('photoTaken');
  }

  /**
   * Apply zoom to captured image
   *
   * Lingo: applyZoom()
   */
  private applyZoom(): void {
    if (!this.pCapturedImage || !this.pDisplayCanvas) return;

    const ctx = this.pDisplayCanvas.getContext('2d');
    if (!ctx) return;

    // Zoom logic would be implemented here
    // For now, just update the display

    if (this.elementExists(this.pCameraWindowId, 'captured_image')) {
      this.feedImage(this.pCameraWindowId, 'captured_image', this.pDisplayCanvas);
    }
  }

  /**
   * Set button highlight states based on mode
   *
   * Lingo: setButtonHilites()
   */
  setButtonHilites(): void {
    if (!this.windowExists(this.pCameraWindowId)) return;

    const component = this.getComponent() as PhotoComponent | null;
    const hasFilm = (component?.getFilm() ?? 0) > 0;

    const buttonStates: Record<CameraButtonId, boolean> = {
      'cam_shoot': this.pMode === CameraMode.LIVE,
      'cam_release': this.pMode === CameraMode.STILL,
      'cam_save': this.pMode === CameraMode.STILL && hasFilm,
      'cam_zoom_in': this.pMode === CameraMode.STILL && hasFilm,
      'cam_zoom_out': this.pMode === CameraMode.STILL && hasFilm,
      'cam_txtscreen': this.pMode === CameraMode.SAVE,
      'cam_close': true,
    };

    for (const [buttonId, enabled] of Object.entries(buttonStates)) {
      if (this.elementExists(this.pCameraWindowId, buttonId)) {
        this.setElementProperty(this.pCameraWindowId, buttonId, 'enabled', enabled);
        this.setElementProperty(this.pCameraWindowId, buttonId, 'highlighted', enabled);
      }
    }
  }

  /**
   * Called when save is complete
   *
   * Lingo: saveOk()
   */
  saveOk(): void {
    this.pMode = CameraMode.LIVE;
    this.setCameraToLiveMode();
    this.setButtonHilites();
    this.updateFilm();
    this.startNoiseAnimation();
  }

  /**
   * Show help line for element
   *
   * Lingo: showHelpLine(elementId)
   */
  showHelpLine(elementId: string): void {
    if (!this.windowExists(this.pCameraWindowId)) return;

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
    if (text && this.elementExists(this.pCameraWindowId, 'help_text')) {
      this.setText(this.pCameraWindowId, 'help_text', text);
    }
  }

  /**
   * Hide help line
   *
   * Lingo: hideHelpLine()
   */
  hideHelpLine(): void {
    if (this.windowExists(this.pCameraWindowId) && this.elementExists(this.pCameraWindowId, 'help_text')) {
      this.setText(this.pCameraWindowId, 'help_text', '');
    }
  }

  /**
   * Handle hand item selection (camera from inventory)
   *
   * Lingo: handItemSelect(data, isPrivateRoom)
   */
  async handItemSelect(data: unknown, isPrivateRoom: boolean): Promise<void> {
    if (!isPrivateRoom) {
      await this.open();
    } else {
      this.pHandItemData = data;
      await this.showCameraDialog();
    }
  }

  /**
   * Show camera dialog
   *
   * Lingo: createWindow(pCameraDialogID, "camera_dialog.window", VOID, VOID, #modal)
   */
  private async showCameraDialog(): Promise<void> {
    await this.createModalWindow(this.pCameraDialogId, 'camera_dialog.window');
    this.registerWindowProcedure(this.pCameraDialogId, 'dialogEventProc');
  }

  /**
   * Camera dialog event procedure
   */
  dialogEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    switch (spriteId) {
      case 'button_open':
        this.removeWindow(this.pCameraDialogId);
        this.open();
        break;
      case 'button_place':
        this.removeWindow(this.pCameraDialogId);
        executeMessage('startItemPlacing', this.pHandItemData);
        break;
      case 'close':
      case 'button_cancel':
        this.removeWindow(this.pCameraDialogId);
        break;
    }
  }

  /**
   * Open photo viewer window
   *
   * Lingo: createWindow(pPhotoViewerWindowID, "photo_viewer.window")
   */
  async openPhotoWindow(x: number, y: number, canRemove: boolean): Promise<void> {
    await this.createWindow(this.pPhotoViewerWindowId, 'photo_viewer.window', x, y);
    this.registerWindowProcedure(this.pPhotoViewerWindowId, 'viewerEventProc');

    // Show/hide remove button
    if (this.elementExists(this.pPhotoViewerWindowId, 'button_remove')) {
      if (canRemove) {
        this.showElement(this.pPhotoViewerWindowId, 'button_remove');
      } else {
        this.hideElement(this.pPhotoViewerWindowId, 'button_remove');
      }
    }
  }

  /**
   * Set photo canvas for viewer
   *
   * Lingo: setPhotoCanvas(canvas)
   */
  setPhotoCanvas(canvas: HTMLCanvasElement): void {
    if (this.windowExists(this.pPhotoViewerWindowId) && this.elementExists(this.pPhotoViewerWindowId, 'photo_image')) {
      this.feedImage(this.pPhotoViewerWindowId, 'photo_image', canvas);
    }
  }

  /**
   * Set photo text for viewer
   *
   * Lingo: setPhotoText(text)
   */
  setPhotoText(text: string): void {
    if (this.windowExists(this.pPhotoViewerWindowId) && this.elementExists(this.pPhotoViewerWindowId, 'photo_text')) {
      this.setText(this.pPhotoViewerWindowId, 'photo_text', text);
    }
  }

  /**
   * Close photo viewer
   *
   * Lingo: removeWindow(pPhotoViewerWindowID)
   */
  closePhotoViewer(): void {
    this.removeWindow(this.pPhotoViewerWindowId);
  }

  /**
   * Photo viewer event procedure
   */
  viewerEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event !== 'mouseUp') return;

    const component = this.getComponent() as PhotoComponent | null;

    switch (spriteId) {
      case 'close':
      case 'button_close':
        this.closePhotoViewer();
        break;
      case 'button_remove':
        if (component && component.removePhoto(component.getItemId())) {
          this.closePhotoViewer();
        }
        break;
    }
  }

  /**
   * Camera window event procedure
   *
   * Lingo: cameraEventProc(tEvent, tSpriteID, tParam, tWindowID)
   */
  cameraEventProc(event: string, spriteId: string, param: unknown, windowId: string): void {
    if (event === 'mouseUp') {
      this.handleButtonPress(spriteId as CameraButtonId);
    } else if (event === 'mouseEnter') {
      this.showHelpLine(spriteId);
    } else if (event === 'mouseLeave') {
      this.hideHelpLine();
    }
  }

  /**
   * Get current camera mode
   */
  getMode(): CameraMode {
    return this.pMode;
  }

  /**
   * Get camera window ID
   */
  getCameraWindowId(): string {
    return this.pCameraWindowId;
  }

  /**
   * Get photo viewer window ID
   */
  getPhotoViewerWindowId(): string {
    return this.pPhotoViewerWindowId;
  }
}
