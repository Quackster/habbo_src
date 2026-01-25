/**
 * Figure Data Class
 *
 * Manages figure/avatar data including sets, colors, and parts.
 * Ported from hh_human Cast External ParentScript 9.
 */

import {
  FigureSetData,
  FigureSetPart,
  FigureColor,
} from './types';

export class FigureData {
  private sets: Map<string, FigureSetData> = new Map();
  private colors: Map<number, FigureColor> = new Map();
  private setTypes: Map<string, string> = new Map();
  private palettes: Map<number, FigureColor[]> = new Map();

  constructor() {}

  /**
   * Parse figure data from XML/text content
   */
  parseData(content: string): boolean {
    try {
      // Parse the figure data XML
      const parser = new DOMParser();
      const doc = parser.parseFromString(content, 'text/xml');

      if (doc.querySelector('parsererror')) {
        console.error('Failed to parse figure data XML');
        return false;
      }

      // Parse colors/palettes
      const palettes = doc.querySelectorAll('palette');
      for (const palette of palettes) {
        const paletteId = parseInt(palette.getAttribute('id') || '0', 10);
        const colors: FigureColor[] = [];

        const colorElems = palette.querySelectorAll('color');
        for (const colorElem of colorElems) {
          const color: FigureColor = {
            id: parseInt(colorElem.getAttribute('id') || '0', 10),
            index: parseInt(colorElem.getAttribute('index') || '0', 10),
            club: parseInt(colorElem.getAttribute('club') || '0', 10),
            selectable: colorElem.getAttribute('selectable') === '1',
            hexColor: colorElem.textContent || 'EEEEEE',
          };
          colors.push(color);
          this.colors.set(color.id, color);
        }

        this.palettes.set(paletteId, colors);
      }

      // Parse figure sets
      const setTypes = doc.querySelectorAll('settype');
      for (const setType of setTypes) {
        const typeId = setType.getAttribute('type') || '';

        const sets = setType.querySelectorAll('set');
        for (const set of sets) {
          const setId = set.getAttribute('id') || '';
          const setData: FigureSetData = {
            id: setId,
            type: typeId,
            gender: (set.getAttribute('gender') || 'U') as 'M' | 'F' | 'U',
            club: parseInt(set.getAttribute('club') || '0', 10),
            colorable: set.getAttribute('colorable') === '1',
            selectable: set.getAttribute('selectable') === '1',
            previewable: set.getAttribute('previewable') === '1',
            parts: [],
            hiddenLayers: [],
          };

          // Parse parts
          const parts = set.querySelectorAll('part');
          for (const part of parts) {
            setData.parts.push({
              id: part.getAttribute('id') || '',
              type: part.getAttribute('type') || '',
              colorable: part.getAttribute('colorable') === '1',
              colorIndex: parseInt(part.getAttribute('colorindex') || '0', 10),
            });
          }

          // Parse hidden layers
          const hiddenLayers = set.querySelectorAll('hiddenlayers layer');
          for (const layer of hiddenLayers) {
            setData.hiddenLayers?.push(layer.getAttribute('parttype') || '');
          }

          this.sets.set(setId, setData);
          this.setTypes.set(setId, typeId);
        }
      }

      return true;
    } catch (error) {
      console.error('Error parsing figure data:', error);
      return false;
    }
  }

  /**
   * Get color by ID
   */
  getColor(colorId: number): string {
    const color = this.colors.get(colorId);
    return color ? `#${color.hexColor}` : '#EEEEEE';
  }

  /**
   * Get set by ID
   */
  getSet(setId: string): FigureSetData | undefined {
    return this.sets.get(setId);
  }

  /**
   * Get set type by set ID
   */
  getSetType(setId: string): string | undefined {
    return this.setTypes.get(setId);
  }

  /**
   * Get part count for a set
   */
  getSetPartCount(setId: string): number {
    const set = this.sets.get(setId);
    return set ? set.parts.length : 0;
  }

  /**
   * Get part data from a set
   */
  getSetPartData(setId: string, index: number): FigureSetPart | null {
    const set = this.sets.get(setId);
    if (!set || index < 1 || index > set.parts.length) {
      return null;
    }
    return set.parts[index - 1];
  }

  /**
   * Get hidden layers for a set
   */
  getSetHiddenLayers(setId: string): string[] | null {
    const set = this.sets.get(setId);
    return set?.hiddenLayers || null;
  }

  /**
   * Get all colors for a palette
   */
  getPaletteColors(paletteId: number): FigureColor[] {
    return this.palettes.get(paletteId) || [];
  }

  /**
   * Check if set requires club membership
   */
  isClubSet(setId: string): boolean {
    const set = this.sets.get(setId);
    return set ? set.club > 0 : false;
  }

  /**
   * Get sets by type
   */
  getSetsByType(type: string): FigureSetData[] {
    const result: FigureSetData[] = [];
    for (const set of this.sets.values()) {
      if (set.type === type) {
        result.push(set);
      }
    }
    return result;
  }

  /**
   * Get sets by gender
   */
  getSetsByGender(gender: 'M' | 'F' | 'U'): FigureSetData[] {
    const result: FigureSetData[] = [];
    for (const set of this.sets.values()) {
      if (set.gender === gender || set.gender === 'U') {
        result.push(set);
      }
    }
    return result;
  }
}
