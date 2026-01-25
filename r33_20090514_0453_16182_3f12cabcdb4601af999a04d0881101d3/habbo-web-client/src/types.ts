/**
 * Habbo Web Client - Core Type Definitions
 *
 * These types map Lingo concepts to TypeScript equivalents.
 */

/** Object identifier - string equivalent of Lingo symbols (#symbol) */
export type ObjectId = string;

/** Lingo property list equivalent [#key: value, ...] */
export type PropList = Record<string, unknown>;

/** Lingo linear list equivalent [item1, item2, ...] */
export type LinearList = unknown[];

/** Message handler function signature */
export type MessageHandler = (data?: unknown) => void;

/** Update/prepare callback for frame loop */
export type FrameCallback = () => void;

/** Base interface for all managed objects */
export interface IManagedObject {
  readonly id: ObjectId;
  construct?(): void;
  deconstruct?(): void;
  prepare?(): void;
  update?(): void;
}

/** Object class constructor type */
export interface ObjectClass<T extends IManagedObject = IManagedObject> {
  new (): T;
}

/** Timeout entry for delayed execution */
export interface TimeoutEntry {
  id: ObjectId;
  callback: () => void;
  targetTime: number;
  repeat: boolean;
  interval: number;
}

/** Connection parameters for WebSocket */
export interface ConnectionParams {
  host: string;
  port: number;
  secure?: boolean;
}

/** Message parameters for protocol encoding */
export interface MessageParams {
  string?: string;
  integer?: number;
  boolean?: boolean;
  short?: number;
}

/** Thread (module) structure with Interface/Component/Handler triad */
export interface IThread {
  id: ObjectId;
  interface: IManagedObject | null;
  component: IManagedObject | null;
  handler: IManagedObject | null;
}

/** Thread configuration loaded from module definition */
export interface ThreadConfig {
  'thread.id': string;
  'interface.class'?: string | string[];
  'component.class'?: string | string[];
  'handler.class'?: string | string[];
}

/** Message callback registration [objectId, methodName] */
export type MessageCallback = [objectId: ObjectId, methodName: string];

/** Habbo message structure passed to handlers */
export interface HabboMessage {
  connection: unknown; // HabboConnection reference
  subject: number;
  content: string;
}

/** Sprite properties for rendering */
export interface SpriteProps {
  x: number;
  y: number;
  z: number;
  width?: number;
  height?: number;
  alpha?: number;
  visible?: boolean;
  texture?: string;
}

/** Room geometry configuration */
export interface RoomGeometryConfig {
  offsetX: number;
  offsetY: number;
  offsetZ: number;
  factorX: number;
  factorY: number;
  factorH: number;
}

/** Screen coordinate result from isometric conversion */
export interface ScreenCoordinate {
  x: number;
  y: number;
  z: number;
}

/** World coordinate (tile position) */
export interface WorldCoordinate {
  tileX: number;
  tileY: number;
  height: number;
}
