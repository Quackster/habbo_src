/**
 * Figure System Class
 *
 * Main avatar/figure rendering system.
 * Manages figure data loading, parsing, and avatar construction.
 * Ported from hh_human Cast External ParentScript 11.
 */

import {
  ParsedFigure,
  FigurePart,
  PartSetDefinition,
  AnimationDefinition,
  DrawOrder,
} from './types';
import { FigureData } from './FigureData';

export class FigureSystem {
  private figureData: FigureData;
  private partSets: PartSetDefinition | null = null;
  private animations: Map<string, AnimationDefinition> = new Map();
  private drawOrders: Map<string, DrawOrder[]> = new Map();
  private loaded: boolean = false;
  private eventCallback: ((event: string, data: unknown) => void) | null = null;

  constructor() {
    this.figureData = new FigureData();
  }

  /**
   * Set event callback
   */
  setEventCallback(callback: (event: string, data: unknown) => void): void {
    this.eventCallback = callback;
  }

  /**
   * Emit event
   */
  private emit(event: string, data: unknown): void {
    if (this.eventCallback) {
      this.eventCallback(event, data);
    }
  }

  /**
   * Check if system is fully loaded
   */
  isLoaded(): boolean {
    return this.loaded;
  }

  /**
   * Load figure part list from URL or data
   */
  async loadFigurePartList(url: string): Promise<boolean> {
    try {
      const response = await fetch(url);
      const content = await response.text();

      if (!this.figureData.parseData(content)) {
        console.error('Failed to parse figure part list');
        return false;
      }

      this.emit('figure_data_loaded', null);
      this.checkDataLoaded();
      return true;
    } catch (error) {
      console.error('Failed to load figure part list:', error);
      return false;
    }
  }

  /**
   * Load part sets XML
   */
  async loadPartSetXML(url: string): Promise<boolean> {
    try {
      const response = await fetch(url);
      const content = await response.text();

      const parser = new DOMParser();
      const doc = parser.parseFromString(content, 'text/xml');

      if (doc.querySelector('parsererror')) {
        console.error('Failed to parse part sets XML');
        return false;
      }

      this.partSets = {
        full: [],
        swim: [],
        small: [],
        swimSmall: [],
        flipList: new Map(),
        removeList: new Map(),
      };

      // Parse part sets
      const partSetElems = doc.querySelectorAll('partSet part');
      for (const part of partSetElems) {
        const setType = part.getAttribute('set-type');
        if (!setType) continue;

        this.partSets.full.push(setType);

        const swim = part.getAttribute('swim');
        const small = part.getAttribute('small');

        if (swim !== '0') {
          this.partSets.swim.push(setType);
          if (small !== '0') {
            this.partSets.swimSmall.push(setType);
          }
        }

        if (small !== '0') {
          this.partSets.small.push(setType);
        }

        const flipped = part.getAttribute('flipped-set-type');
        if (flipped) {
          this.partSets.flipList.set(setType, flipped);
        }

        const remove = part.getAttribute('remove-set-type');
        if (remove) {
          this.partSets.removeList.set(setType, remove);
        }
      }

      this.emit('part_sets_loaded', null);
      this.checkDataLoaded();
      return true;
    } catch (error) {
      console.error('Failed to load part sets XML:', error);
      return false;
    }
  }

  /**
   * Load draw order XML
   */
  async loadDrawOrderXML(url: string): Promise<boolean> {
    try {
      const response = await fetch(url);
      const content = await response.text();

      const parser = new DOMParser();
      const doc = parser.parseFromString(content, 'text/xml');

      if (doc.querySelector('parsererror')) {
        console.error('Failed to parse draw order XML');
        return false;
      }

      // Parse action sets
      const actions = doc.querySelectorAll('action');
      for (const action of actions) {
        const actionId = action.getAttribute('id') || 'std';
        const directions = action.querySelectorAll('direction');

        const orders: DrawOrder[] = [];
        for (const direction of directions) {
          const dirId = parseInt(direction.getAttribute('id') || '0', 10);
          const parts: string[] = [];

          const partElems = direction.querySelectorAll('partList part');
          for (const part of partElems) {
            const setType = part.getAttribute('set-type');
            if (setType) {
              parts.push(setType);
            }
          }

          orders.push({ direction: dirId, parts });
        }

        this.drawOrders.set(actionId, orders);
      }

      this.emit('draw_orders_loaded', null);
      this.checkDataLoaded();
      return true;
    } catch (error) {
      console.error('Failed to load draw order XML:', error);
      return false;
    }
  }

  /**
   * Load animation XML
   */
  async loadAnimationXML(url: string): Promise<boolean> {
    try {
      const response = await fetch(url);
      const content = await response.text();

      const parser = new DOMParser();
      const doc = parser.parseFromString(content, 'text/xml');

      if (doc.querySelector('parsererror')) {
        console.error('Failed to parse animation XML');
        return false;
      }

      // Parse animations
      const actions = doc.querySelectorAll('action');
      for (const action of actions) {
        const actionId = action.getAttribute('id');
        if (!actionId) continue;

        const anim: AnimationDefinition = {
          id: actionId,
          parts: {},
        };

        const parts = action.querySelectorAll('part');
        for (const part of parts) {
          const setType = part.getAttribute('set-type');
          if (!setType) continue;

          const frames = part.querySelectorAll('frame');
          anim.parts[setType] = [];

          for (const frame of frames) {
            anim.parts[setType].push({
              number: parseInt(frame.getAttribute('number') || '0', 10),
              assetPartDefinition: frame.getAttribute('assetpartdefinition') || undefined,
              repeats: parseInt(frame.getAttribute('repeats') || '1', 10),
            });
          }
        }

        this.animations.set(actionId, anim);
      }

      this.emit('animations_loaded', null);
      this.checkDataLoaded();
      return true;
    } catch (error) {
      console.error('Failed to load animation XML:', error);
      return false;
    }
  }

  /**
   * Check if all data is loaded
   */
  private checkDataLoaded(): void {
    if (
      this.figureData &&
      this.partSets &&
      this.drawOrders.size > 0 &&
      this.animations.size > 0
    ) {
      this.loaded = true;
      this.emit('system_ready', null);
    }
  }

  /**
   * Parse a figure string into structured data
   */
  parseFigure(
    figureData: string,
    sex: 'M' | 'F',
    figureClass: string = 'user'
  ): ParsedFigure {
    const figure: ParsedFigure = {};

    if (figureClass === 'user' || figureClass === 'pelle') {
      // New format: hd-180-1.ch-255-92.lg-285-82.sh-300-64.hr-100
      if (figureData.includes('.') || figureData.includes('-')) {
        const parts = figureData.split('.');
        for (const partData of parts) {
          const items = partData.split('-');
          if (items.length >= 3) {
            const setType = items[0];
            const setId = items[1];
            const colorId = items[2];

            const parsedParts = this.parseNewTypeFigure(setId, colorId, sex);
            Object.assign(figure, parsedParts);
          }
        }
      } else {
        // Old format: numeric only (5 chars per part)
        const partCount = Math.floor(figureData.length / 5);
        for (let i = 0; i < partCount; i++) {
          const part = figureData.substring(i * 5, (i + 1) * 5);
          const setId = part.substring(0, 3);
          const colorId = part.substring(3, 5);

          const parsedParts = this.parseNewTypeFigure(setId, colorId, sex);
          Object.assign(figure, parsedParts);
        }
      }
    } else if (figureClass === 'bot') {
      // Bot format: part=model/color&part=model/color
      const parts = figureData.split('&');
      for (const partStr of parts) {
        const [prop, desc] = partStr.split('=');
        if (!desc) continue;

        const [model, colorStr] = desc.split('/');
        let color = '#EEEEEE';

        if (colorStr) {
          if (colorStr.includes(',')) {
            // RGB format
            const [r, g, b] = colorStr.split(',').map((c) => parseInt(c, 10));
            color = `rgb(${r},${g},${b})`;
          } else {
            // Palette index
            const paletteIdx = parseInt(colorStr, 10);
            if (paletteIdx > 0) {
              color = this.figureData.getColor(paletteIdx);
            }
          }
        }

        figure[prop] = {
          model: model.replace(/^0+/, ''),
          color,
        };
      }
    }

    return figure;
  }

  /**
   * Parse new type figure format
   */
  private parseNewTypeFigure(
    setId: string,
    colorId: string,
    _sex: 'M' | 'F'
  ): ParsedFigure {
    const figure: ParsedFigure = {};
    const color = this.figureData.getColor(parseInt(colorId, 10) || 1);
    const partCount = this.figureData.getSetPartCount(setId);

    for (let i = 1; i <= partCount; i++) {
      const partData = this.figureData.getSetPartData(setId, i);
      if (partData) {
        const part: FigurePart = {
          model: partData.id,
          color: partData.colorable ? color : '#EEEEEE',
          setId,
          colorId,
        };
        figure[partData.type] = part;
      }
    }

    // Handle hidden layers
    const hiddenLayers = this.figureData.getSetHiddenLayers(setId);
    if (hiddenLayers) {
      for (const layer of hiddenLayers) {
        delete figure[layer];
      }
    }

    return figure;
  }

  /**
   * Get draw order for action and direction
   */
  getDrawOrder(action: string, direction: number): string[] {
    const orders = this.drawOrders.get(action) || this.drawOrders.get('std');
    if (!orders) {
      return this.partSets?.full || [];
    }

    const order = orders.find((o) => o.direction === direction);
    return order?.parts || orders[0]?.parts || this.partSets?.full || [];
  }

  /**
   * Get animation for action
   */
  getAnimation(action: string): AnimationDefinition | undefined {
    return this.animations.get(action);
  }

  /**
   * Get animation frame for part
   */
  getAnimationFrame(
    action: string,
    partType: string,
    frameIndex: number
  ): number {
    const anim = this.animations.get(action);
    if (!anim || !anim.parts[partType]) {
      return 0;
    }

    const frames = anim.parts[partType];
    if (frames.length === 0) {
      return 0;
    }

    const frame = frames[frameIndex % frames.length];
    return frame.number;
  }

  /**
   * Get figure data instance
   */
  getFigureData(): FigureData {
    return this.figureData;
  }

  /**
   * Get part sets definition
   */
  getPartSets(): PartSetDefinition | null {
    return this.partSets;
  }
}

// Singleton instance
let figureSystem: FigureSystem | null = null;

export function getFigureSystem(): FigureSystem {
  if (!figureSystem) {
    figureSystem = new FigureSystem();
  }
  return figureSystem;
}

export function resetFigureSystem(): void {
  figureSystem = null;
}
