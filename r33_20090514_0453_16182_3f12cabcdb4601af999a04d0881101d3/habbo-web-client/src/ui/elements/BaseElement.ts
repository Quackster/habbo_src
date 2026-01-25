/**
 * Base Element Class
 *
 * Base class for all UI elements in the window system.
 */

import { ElementProps, ScaleMode, SpriteData } from '../types';

export abstract class BaseElement {
  protected id: string = '';
  protected motherId: string = '';
  protected type: string = '';
  protected buffer: HTMLCanvasElement | null = null;
  protected bufferCtx: CanvasRenderingContext2D | null = null;
  protected sprite: SpriteData | null = null;
  protected scaleH: ScaleMode = 'fixed';
  protected scaleV: ScaleMode = 'fixed';
  protected locX: number = 0;
  protected locY: number = 0;
  protected _width: number = 0;
  protected _height: number = 0;
  protected visible: boolean = true;
  protected palette: string = '';
  protected props: ElementProps | null = null;

  /**
   * Define the element with properties
   */
  define(props: ElementProps): boolean {
    this.id = props.id;
    this.type = props.type;
    this.scaleH = props.scaleH ?? 'fixed';
    this.scaleV = props.scaleV ?? 'fixed';
    this.locX = props.locH;
    this.locY = props.locV;
    this._width = props.width;
    this._height = props.height;
    this.palette = props.palette ?? '';
    this.props = props;
    return true;
  }

  /**
   * Prepare the element (called before render)
   */
  prepare(): void {
    // Override in subclasses
  }

  /**
   * Render the element
   */
  abstract render(): void;

  /**
   * Deconstruct/cleanup the element
   */
  deconstruct(): void {
    this.buffer = null;
    this.bufferCtx = null;
    this.sprite = null;
  }

  /**
   * Show the element
   */
  show(): boolean {
    this.visible = true;
    if (this.sprite) {
      this.sprite.visible = true;
    }
    return true;
  }

  /**
   * Hide the element
   */
  hide(): boolean {
    this.visible = false;
    if (this.sprite) {
      this.sprite.visible = false;
    }
    return true;
  }

  /**
   * Move to absolute position
   */
  moveTo(x: number, y: number): void {
    const offX = x - this.locX;
    const offY = y - this.locY;
    this.moveBy(offX, offY);
  }

  /**
   * Move by offset
   */
  moveBy(offX: number, offY: number): void {
    this.locX += offX;
    this.locY += offY;
    if (this.sprite) {
      this.sprite.x += offX;
      this.sprite.y += offY;
    }
  }

  /**
   * Resize to absolute size
   */
  resizeTo(width: number, height: number, forced?: boolean): void {
    const offW = width - this._width;
    const offH = height - this._height;
    this.resizeBy(offW, offH, forced);
  }

  /**
   * Resize by offset
   */
  resizeBy(offW: number, offH: number, forced?: boolean): void {
    if (offW === 0 && offH === 0) return;

    // Handle horizontal scaling
    switch (this.scaleH) {
      case 'move':
        this.moveBy(offW, 0);
        break;
      case 'scale':
        this._width += offW;
        break;
      case 'center':
        this.moveBy(offW / 2, 0);
        break;
      case 'fixed':
        if (forced) {
          this._width += offW;
        }
        break;
    }

    // Handle vertical scaling
    switch (this.scaleV) {
      case 'move':
        this.moveBy(0, offH);
        break;
      case 'scale':
        this._height += offH;
        break;
      case 'center':
        this.moveBy(0, offH / 2);
        break;
      case 'fixed':
        if (forced) {
          this._height += offH;
        }
        break;
    }

    // Ensure minimum size
    if (this._width < 1) this._width = 1;
    if (this._height < 1) this._height = 1;

    // Update sprite dimensions
    if (this.sprite) {
      this.sprite.width = this._width;
      this.sprite.height = this._height;
    }
  }

  /**
   * Draw debug outline
   */
  draw(color: string = '#FF0000'): void {
    if (!this.bufferCtx) return;
    this.bufferCtx.strokeStyle = color;
    this.bufferCtx.strokeRect(0, 0, this._width - 1, this._height - 1);
  }

  /**
   * Get a property value
   */
  getProperty(prop: string): unknown {
    switch (prop) {
      case 'id':
        return this.id;
      case 'type':
        return this.type;
      case 'scaleH':
        return this.scaleH;
      case 'scaleV':
        return this.scaleV;
      case 'locX':
      case 'locH':
        return this.locX;
      case 'locY':
      case 'locV':
        return this.locY;
      case 'width':
        return this._width;
      case 'height':
        return this._height;
      case 'visible':
        return this.visible;
      case 'buffer':
      case 'member':
        return this.buffer;
      case 'sprite':
        return this.sprite;
      case 'blend':
        return this.sprite?.blend ?? 100;
      case 'ink':
        return this.sprite?.ink ?? 0;
      case 'color':
        return this.sprite?.color ?? '#000000';
      case 'bgColor':
        return this.sprite?.bgColor ?? '#FFFFFF';
      case 'cursor':
        return this.sprite?.cursor ?? 'default';
      default:
        return null;
    }
  }

  /**
   * Set a property value
   */
  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'scaleH':
        this.scaleH = value as ScaleMode;
        break;
      case 'scaleV':
        this.scaleV = value as ScaleMode;
        break;
      case 'locX':
      case 'locH':
        this.moveTo(value as number, this.locY);
        break;
      case 'locY':
      case 'locV':
        this.moveTo(this.locX, value as number);
        break;
      case 'width':
        this.resizeTo(value as number, this._height);
        break;
      case 'height':
        this.resizeTo(this._width, value as number);
        break;
      case 'visible':
        if (value) this.show();
        else this.hide();
        break;
      case 'blend':
        if (this.sprite) this.sprite.blend = value as number;
        break;
      case 'ink':
        if (this.sprite) this.sprite.ink = value as number;
        break;
      case 'color':
        if (this.sprite) this.sprite.color = value as string;
        break;
      case 'bgColor':
        if (this.sprite) this.sprite.bgColor = value as string;
        break;
      case 'cursor':
        if (this.sprite) this.sprite.cursor = value as string;
        break;
      default:
        return false;
    }
    return true;
  }

  /**
   * Get the element ID
   */
  getId(): string {
    return this.id;
  }

  /**
   * Set the element ID
   */
  setId(id: string): void {
    this.id = id;
  }

  // Event handlers (override in subclasses)
  mouseEnter(_spriteId: string): unknown {
    return null;
  }
  mouseLeave(_spriteId: string): unknown {
    return null;
  }
  mouseWithin(_spriteId: string): unknown {
    return null;
  }
  mouseDown(_spriteId: string): unknown {
    return null;
  }
  mouseUp(_spriteId: string): unknown {
    return null;
  }
  mouseUpOutside(_spriteId: string): unknown {
    return null;
  }
  keyDown(_spriteId: string): unknown {
    return null;
  }
  keyUp(_spriteId: string): unknown {
    return null;
  }
}
