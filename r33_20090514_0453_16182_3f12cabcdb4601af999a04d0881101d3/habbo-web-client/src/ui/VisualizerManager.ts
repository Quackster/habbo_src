/**
 * Visualizer Manager Class
 *
 * Ported from: fuse_client/Cast External ParentScript 38 - Visualizer Manager Class.ls
 *
 * Manages visualizers for room rendering and other non-window UI elements.
 * Similar to WindowManager but for room/game visualizations.
 */

import { Rect, VisualLayout } from './types';
import { layoutParser } from './LayoutParser';
import { objectManager } from '../core/ObjectManager';
import { getVariable } from '../core/VariableContainer';

export interface VisualizerInstance {
  id: string;
  layout: VisualLayout | null;
  locX: number;
  locY: number;
  locZ: number;
  width: number;
  height: number;
  visible: boolean;
  active: boolean;
  canvas: HTMLCanvasElement;
  ctx: CanvasRenderingContext2D;

  define(props: Record<string, unknown>): boolean;
  show(): boolean;
  hide(): boolean;
  moveTo(x: number, y: number): void;
  moveBy(offX: number, offY: number): void;
  moveZ(z: number): void;
  resizeTo(width: number, height: number): void;
  resizeBy(offW: number, offH: number): void;
  setActive(): boolean;
  setDeactive(): boolean;
  getProperty(prop: string): unknown;
  setProperty(prop: string, value: unknown): boolean;
  render(): void;
  deconstruct(): void;
}

class VisualizerManagerClass {
  private instanceClass: string = 'VisualizerInstance';
  private activeItem: string = '';
  private posCache: Map<string, [number, number]> = new Map();
  private hideList: string[] = [];
  private defaultLocZ: number = -20000000;
  private availableLocZ: number = -20000000;
  private boundary: Rect = { x: 0, y: 0, width: 800, height: 600 };
  private itemList: string[] = [];

  constructor() {
    this.defaultLocZ = getVariable('visualizer.default.locz', -20000000) as number;
    this.availableLocZ = this.defaultLocZ;

    const boundaryLimit = getVariable('visualizer.boundary.limit', [0, 0, 0, 0]) as number[];
    const stageWidth = 800;
    const stageHeight = 600;
    this.boundary = {
      x: boundaryLimit[0],
      y: boundaryLimit[1],
      width: stageWidth + boundaryLimit[2],
      height: stageHeight + boundaryLimit[3],
    };
  }

  /**
   * Create a new visualizer
   */
  async create(
    id: string,
    layout: string,
    locX: number = 0,
    locY: number = 0
  ): Promise<boolean> {
    if (this.exists(id)) {
      this.remove(id);
    }

    // Parse layout
    const layoutData = await layoutParser.parse(layout) as VisualLayout;

    // Create visualizer instance
    const canvas = document.createElement('canvas');
    canvas.width = layoutData?.rect?.width ?? 800;
    canvas.height = layoutData?.rect?.height ?? 600;
    const ctx = canvas.getContext('2d')!;

    const visualizer: VisualizerInstance = {
      id,
      layout: layoutData,
      locX,
      locY,
      locZ: this.availableLocZ,
      width: canvas.width,
      height: canvas.height,
      visible: true,
      active: false,
      canvas,
      ctx,

      define(props) {
        this.locX = props.locX as number ?? 0;
        this.locY = props.locY as number ?? 0;
        this.locZ = props.locZ as number ?? 0;
        return true;
      },

      show() {
        this.visible = true;
        return true;
      },

      hide() {
        this.visible = false;
        return true;
      },

      moveTo(x, y) {
        this.locX = x;
        this.locY = y;
      },

      moveBy(offX, offY) {
        this.locX += offX;
        this.locY += offY;
      },

      moveZ(z) {
        this.locZ = z;
      },

      resizeTo(width, height) {
        this.width = width;
        this.height = height;
        this.canvas.width = width;
        this.canvas.height = height;
      },

      resizeBy(offW, offH) {
        this.resizeTo(this.width + offW, this.height + offH);
      },

      setActive() {
        this.active = true;
        return true;
      },

      setDeactive() {
        this.active = false;
        return true;
      },

      getProperty(prop) {
        switch (prop) {
          case 'locX': return this.locX;
          case 'locY': return this.locY;
          case 'locZ': return this.locZ;
          case 'width': return this.width;
          case 'height': return this.height;
          case 'visible': return this.visible;
          case 'active': return this.active;
          case 'sprCount': return 1;
          default: return null;
        }
      },

      setProperty(prop, value) {
        switch (prop) {
          case 'locX': this.locX = value as number; break;
          case 'locY': this.locY = value as number; break;
          case 'locZ': this.locZ = value as number; break;
          case 'visible': value ? this.show() : this.hide(); break;
          default: return false;
        }
        return true;
      },

      render() {
        // Clear and render based on layout
        this.ctx.clearRect(0, 0, this.width, this.height);
        // Layout-specific rendering would go here
      },

      deconstruct() {
        // Cleanup
      },
    };

    // Define properties
    visualizer.define({
      locX,
      locY,
      locZ: this.availableLocZ,
      layout,
      boundary: this.boundary,
    });

    // Register with object manager
    objectManager.register(id, visualizer);

    this.itemList.push(id);
    this.availableLocZ += 1;

    return true;
  }

  /**
   * Remove a visualizer
   */
  remove(id: string): boolean {
    if (!this.exists(id)) return false;

    const vis = this.get(id);
    if (vis) {
      this.availableLocZ -= vis.getProperty('sprCount') as number;
      this.posCache.set(id, [
        vis.getProperty('locX') as number,
        vis.getProperty('locY') as number,
      ]);
      vis.deconstruct();
    }

    const idx = this.itemList.indexOf(id);
    if (idx !== -1) {
      this.itemList.splice(idx, 1);
    }

    if (this.activeItem === id) {
      this.activeItem = this.itemList[this.itemList.length - 1] ?? '';
    }

    objectManager.remove(id);
    this.activate(this.itemList[this.itemList.length - 1]);

    return true;
  }

  /**
   * Activate a visualizer
   */
  activate(id?: string): boolean {
    if (id && this.exists(id)) {
      this.activeItem = id;
      this.get(id)?.setActive();
      return true;
    }
    return false;
  }

  /**
   * Deactivate a visualizer
   */
  deactivate(id: string): boolean {
    if (this.exists(id)) {
      this.get(id)?.setDeactive();
      return true;
    }
    return false;
  }

  /**
   * Hide all visualizers
   */
  hideAll(): boolean {
    for (const id of this.itemList) {
      const vis = this.get(id);
      if (vis?.getProperty('visible')) {
        vis.hide();
        this.hideList.push(id);
      }
    }
    return true;
  }

  /**
   * Show all previously hidden visualizers
   */
  showAll(): boolean {
    for (const id of this.hideList) {
      this.get(id)?.show();
    }
    this.hideList = [];
    return true;
  }

  /**
   * Get a visualizer by ID
   */
  get(id: string): VisualizerInstance | null {
    return objectManager.get<VisualizerInstance>(id);
  }

  /**
   * Check if visualizer exists
   */
  exists(id: string): boolean {
    return this.itemList.includes(id);
  }

  /**
   * Get all visualizer IDs
   */
  getIdList(): string[] {
    return [...this.itemList];
  }

  /**
   * Get property
   */
  getProperty(prop: string): unknown {
    switch (prop) {
      case 'defaultLocZ': return this.defaultLocZ;
      case 'boundary': return this.boundary;
      case 'count': return this.itemList.length;
      default: return null;
    }
  }

  /**
   * Set property
   */
  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'defaultLocZ':
        this.defaultLocZ = value as number;
        this.activate();
        return true;
      case 'boundary':
        const rect = value as number[] | Rect;
        if (Array.isArray(rect)) {
          this.boundary = { x: rect[0], y: rect[1], width: rect[2], height: rect[3] };
        } else {
          this.boundary = rect;
        }
        return true;
      default:
        return false;
    }
  }

  /**
   * Render all visible visualizers to a target context
   */
  renderTo(ctx: CanvasRenderingContext2D): void {
    // Sort by z-order
    const sorted = this.itemList
      .map(id => this.get(id))
      .filter((v): v is VisualizerInstance => v !== null && v.visible)
      .sort((a, b) => a.locZ - b.locZ);

    for (const vis of sorted) {
      vis.render();
      ctx.drawImage(vis.canvas, vis.locX, vis.locY);
    }
  }
}

// Singleton instance
let visualizerManagerInstance: VisualizerManagerClass | null = null;

export function getVisualizerManager(): VisualizerManagerClass {
  if (!visualizerManagerInstance) {
    visualizerManagerInstance = new VisualizerManagerClass();
  }
  return visualizerManagerInstance;
}

// API functions (matching original Lingo API)
export async function createVisualizer(
  id: string,
  layout: string,
  locX?: number,
  locY?: number
): Promise<boolean> {
  return getVisualizerManager().create(id, layout, locX, locY);
}

export function removeVisualizer(id: string): boolean {
  return getVisualizerManager().remove(id);
}

export function getVisualizer(id: string): VisualizerInstance | null {
  return getVisualizerManager().get(id);
}

export function visualizerExists(id: string): boolean {
  return getVisualizerManager().exists(id);
}

export function hideVisualizers(): boolean {
  return getVisualizerManager().hideAll();
}

export function showVisualizers(): boolean {
  return getVisualizerManager().showAll();
}
