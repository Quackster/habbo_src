/**
 * UI System Types
 *
 * Type definitions for the window/element/visualizer system
 */

export interface Rect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface Point {
  x: number;
  y: number;
}

export type ScaleMode = 'fixed' | 'scale' | 'move' | 'center';

export type ElementType =
  | 'image'
  | 'text'
  | 'button'
  | 'field'
  | 'list'
  | 'scrollbar'
  | 'checkbox'
  | 'dropdown';

export type ElementStyle = 'unique' | 'grouped' | 'wrapper';

export interface ElementProps {
  id: string;
  type: ElementType;
  style?: ElementStyle;
  locH: number;
  locV: number;
  width: number;
  height: number;
  member?: string;
  blend?: number;
  ink?: number;
  color?: string;
  bgColor?: string;
  palette?: string;
  flipH?: boolean;
  flipV?: boolean;
  scaleH?: ScaleMode;
  scaleV?: ScaleMode;
  cursor?: string;
  // Text-specific
  text?: string;
  font?: string;
  fontSize?: number;
  fontStyle?: string;
  txtColor?: string;
  txtBgColor?: string;
  alignment?: 'left' | 'center' | 'right';
  wordWrap?: boolean;
  fixedLineSpace?: number;
  // Button-specific
  states?: Record<string, ElementProps>;
  active?: boolean;
  // Model for custom element types
  model?: string;
}

export interface WindowLayout {
  elements: Map<string, ElementProps[]>;
  rect: Rect;
  border: [number, number, number, number];
  clientRect?: [number, number, number, number];
}

export interface VisualLayout {
  name?: string;
  roomdata?: unknown[];
  rect?: Rect;
  elements?: ElementProps[];
}

export interface WindowProps {
  locX: number;
  locY: number;
  locZ: number;
  boundary: Rect;
  elements?: Record<string, unknown>;
  manager?: unknown;
}

export type WindowEvent =
  | 'mouseEnter'
  | 'mouseLeave'
  | 'mouseWithin'
  | 'mouseDown'
  | 'mouseUp'
  | 'mouseUpOutside'
  | 'keyDown'
  | 'keyUp';

export interface EventData {
  title: string;
  sprite: string;
  event: WindowEvent;
  time: number;
}

export interface SpriteData {
  id: string;
  canvas: HTMLCanvasElement;
  ctx: CanvasRenderingContext2D;
  x: number;
  y: number;
  z: number;
  width: number;
  height: number;
  visible: boolean;
  blend: number;
  ink: number;
  color: string;
  bgColor: string;
  cursor: string;
}
