/**
 * Layout Parser Class
 *
 * Ported from: fuse_client/Cast External ParentScript 53 - Layout Parser Class.ls
 *
 * Parses text-based layout definitions for windows and visualizers.
 * Layout files use an XML-like format with property lists.
 */

import { WindowLayout, VisualLayout, ElementProps, Rect } from './types';
import { resourceManager } from '../managers/ResourceManager';

class LayoutParser {
  private cache: Map<string, WindowLayout | VisualLayout> = new Map();

  /**
   * Parse a layout definition
   */
  async parse(fieldName: string): Promise<WindowLayout | VisualLayout | null> {
    // Check cache first
    if (this.cache.has(fieldName)) {
      return this.deepClone(this.cache.get(fieldName)!);
    }

    // Determine layout type and parse
    let result: WindowLayout | VisualLayout | null = null;

    if (fieldName.includes('.window')) {
      result = await this.parseWindow(fieldName);
    } else if (fieldName.includes('.element')) {
      result = await this.parseElement(fieldName);
    } else if (fieldName.includes('.room') || fieldName.includes('.visual')) {
      result = await this.parseVisual(fieldName);
    }

    if (result) {
      this.cache.set(fieldName, result);
      return this.deepClone(result);
    }

    return null;
  }

  /**
   * Parse a window layout definition
   */
  private async parseWindow(fieldName: string): Promise<WindowLayout | null> {
    const data = await this.loadLayoutText(fieldName);
    if (!data) return null;

    const supportedTags = {
      elements: { open: '<elements>', close: '</elements>' },
      rect: { open: '<rect>', close: '</rect>' },
      border: { open: '<border>', close: '</border>' },
      clientrect: { open: '<clientrect>', close: '</clientrect>' },
    };

    const layDefinition: Record<string, unknown[]> = {
      elements: [],
      rect: [],
      border: [],
      clientrect: [],
    };

    // Parse each tag section
    const lines = data.split('\n');
    for (const tag of Object.keys(supportedTags) as Array<keyof typeof supportedTags>) {
      const { open, close } = supportedTags[tag];
      let inSection = false;
      const items: unknown[] = [];

      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed === open) {
          inSection = true;
          continue;
        }
        if (trimmed === close) {
          inSection = false;
          continue;
        }
        if (inSection && trimmed) {
          const parsed = this.parsePropertyList(trimmed);
          if (parsed) {
            items.push(parsed);
          }
        }
      }

      layDefinition[tag] = items;
    }

    // Group elements by ID
    const elements = new Map<string, ElementProps[]>();
    for (const elem of layDefinition.elements as ElementProps[]) {
      const id = elem.id || 'null';
      if (!elements.has(id)) {
        elements.set(id, []);
      }
      elements.get(id)!.push(this.processElementProps(elem));
    }

    // Calculate rect if not specified
    let rect: Rect;
    if (layDefinition.rect.length === 0) {
      rect = this.calculateBoundingRect(elements);
      // Adjust element positions relative to rect
      for (const elemList of elements.values()) {
        for (const elem of elemList) {
          elem.locH -= rect.x;
          elem.locV -= rect.y;
        }
      }
      rect = { x: 0, y: 0, width: rect.width, height: rect.height };
    } else {
      const r = layDefinition.rect[0] as number[];
      rect = { x: r[0], y: r[1], width: r[2] - r[0], height: r[3] - r[1] };
    }

    // Calculate border
    let border: [number, number, number, number] = [0, 0, 0, 0];
    if (layDefinition.border.length > 0) {
      border = layDefinition.border[0] as [number, number, number, number];
    } else if (layDefinition.clientrect.length > 0) {
      const cr = layDefinition.clientrect[0] as number[];
      border = [cr[0], cr[1], rect.width - cr[2], rect.height - cr[3]];
    }

    return {
      elements,
      rect,
      border,
    };
  }

  /**
   * Parse an element definition (for buttons, etc.)
   */
  private async parseElement(fieldName: string): Promise<Record<string, ElementProps> | null> {
    const data = await this.loadLayoutText(fieldName);
    if (!data) return null;

    const props: Record<string, ElementProps> = {};
    const lines = data.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();
      if (trimmed.startsWith('#') || !trimmed) continue;

      const parsed = this.parsePropertyList(trimmed);
      if (parsed && parsed.state) {
        props[parsed.state as string] = parsed as ElementProps;
      }
    }

    return props;
  }

  /**
   * Parse a visual/room layout definition
   */
  private async parseVisual(fieldName: string): Promise<VisualLayout | null> {
    const data = await this.loadLayoutText(fieldName);
    if (!data) return null;

    const supportedTags = {
      roomdata: { open: '<roomdata>', close: '</roomdata>' },
      rect: { open: '<rect>', close: '</rect>' },
      version: { open: '<version>', close: '</version>' },
      elements: { open: '<elements>', close: '</elements>' },
    };

    const layDefinition: Record<string, unknown[]> = {};
    const lines = data.split('\n');

    for (const tag of Object.keys(supportedTags) as Array<keyof typeof supportedTags>) {
      const { open, close } = supportedTags[tag];
      let inSection = false;
      const items: unknown[] = [];

      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed === open) {
          inSection = true;
          continue;
        }
        if (trimmed === close) {
          inSection = false;
          continue;
        }
        if (inSection && trimmed) {
          const parsed = this.parsePropertyList(trimmed);
          if (parsed !== null) {
            items.push(parsed);
          }
        }
      }

      if (items.length > 0) {
        layDefinition[tag] = items;
      }
    }

    // Process elements
    const elements: ElementProps[] = [];
    if (layDefinition.elements) {
      for (const elem of layDefinition.elements) {
        elements.push(this.processElementProps(elem as ElementProps));
      }
    }

    return {
      name: layDefinition.name?.[0] as string | undefined,
      roomdata: layDefinition.roomdata,
      rect: layDefinition.rect?.[0] as Rect | undefined,
      elements,
    };
  }

  /**
   * Load layout text from resource
   */
  private async loadLayoutText(fieldName: string): Promise<string | null> {
    try {
      return await resourceManager.getText(fieldName);
    } catch (error) {
      console.error(`LayoutParser: Failed to load ${fieldName}:`, error);
      return null;
    }
  }

  /**
   * Parse a Lingo-style property list string
   * e.g., [#id: "button", #locH: 10, #locV: 20]
   */
  private parsePropertyList(str: string): Record<string, unknown> | null {
    const trimmed = str.trim();
    if (!trimmed.startsWith('[') || !trimmed.endsWith(']')) {
      return null;
    }

    const inner = trimmed.slice(1, -1);
    const result: Record<string, unknown> = {};

    // Parse key-value pairs
    // This is a simplified parser - real Lingo property lists are more complex
    const pairs = this.splitPropertyPairs(inner);

    for (const pair of pairs) {
      const colonIdx = pair.indexOf(':');
      if (colonIdx === -1) continue;

      let key = pair.slice(0, colonIdx).trim();
      const value = pair.slice(colonIdx + 1).trim();

      // Remove # prefix from key
      if (key.startsWith('#')) {
        key = key.slice(1);
      }

      result[key] = this.parseValue(value);
    }

    return result;
  }

  /**
   * Split property pairs, handling nested brackets and strings
   */
  private splitPropertyPairs(str: string): string[] {
    const pairs: string[] = [];
    let current = '';
    let depth = 0;
    let inString = false;
    let stringChar = '';

    for (let i = 0; i < str.length; i++) {
      const char = str[i];

      if (!inString && (char === '"' || char === "'")) {
        inString = true;
        stringChar = char;
        current += char;
      } else if (inString && char === stringChar) {
        inString = false;
        current += char;
      } else if (!inString && (char === '[' || char === '(')) {
        depth++;
        current += char;
      } else if (!inString && (char === ']' || char === ')')) {
        depth--;
        current += char;
      } else if (!inString && depth === 0 && char === ',') {
        if (current.trim()) {
          pairs.push(current.trim());
        }
        current = '';
      } else {
        current += char;
      }
    }

    if (current.trim()) {
      pairs.push(current.trim());
    }

    return pairs;
  }

  /**
   * Parse a value string into appropriate type
   */
  private parseValue(str: string): unknown {
    const trimmed = str.trim();

    // String
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      return trimmed.slice(1, -1);
    }

    // Symbol (convert to string)
    if (trimmed.startsWith('#')) {
      return trimmed.slice(1);
    }

    // Boolean
    if (trimmed === 'true' || trimmed === '1') return true;
    if (trimmed === 'false' || trimmed === '0') return false;

    // Number
    const num = parseFloat(trimmed);
    if (!isNaN(num)) return num;

    // List/Array
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      return this.parsePropertyList(trimmed);
    }

    // RGB color
    if (trimmed.startsWith('rgb(')) {
      return trimmed;
    }

    return trimmed;
  }

  /**
   * Process element properties (convert colors, etc.)
   */
  private processElementProps(elem: ElementProps): ElementProps {
    const result = { ...elem };

    // Convert string colors
    if (typeof result.color === 'string' && result.color.startsWith('#')) {
      // Keep as hex string
    } else if (result.color === undefined) {
      result.color = '#000000';
    }

    if (typeof result.bgColor === 'string' && result.bgColor.startsWith('#')) {
      // Keep as hex string
    } else if (result.bgColor === undefined) {
      result.bgColor = '#FFFFFF';
    }

    // Handle stretch property (legacy)
    const stretch = (elem as Record<string, unknown>).strech as string;
    if (stretch) {
      result.scaleH = 'fixed';
      result.scaleV = 'fixed';

      switch (stretch) {
        case 'moveH':
          result.scaleH = 'move';
          break;
        case 'moveV':
          result.scaleV = 'move';
          break;
        case 'strechH':
          result.scaleH = 'scale';
          break;
        case 'strechV':
          result.scaleV = 'scale';
          break;
        case 'centerH':
          result.scaleH = 'center';
          break;
        case 'centerV':
          result.scaleV = 'center';
          break;
        case 'moveHV':
          result.scaleH = 'move';
          result.scaleV = 'move';
          break;
        case 'strechHV':
          result.scaleH = 'scale';
          result.scaleV = 'scale';
          break;
        case 'centerHV':
          result.scaleH = 'center';
          result.scaleV = 'center';
          break;
      }
    }

    // Default text properties
    if (result.type === 'text') {
      if (result.wordWrap === undefined) result.wordWrap = true;
      if (result.alignment === undefined) result.alignment = 'left';
      if (result.font === undefined) result.font = 'Volter';
      if (result.fontSize === undefined) result.fontSize = 9;
    }

    return result;
  }

  /**
   * Calculate bounding rect for all elements
   */
  private calculateBoundingRect(elements: Map<string, ElementProps[]>): Rect {
    let minX = Infinity, minY = Infinity;
    let maxX = -Infinity, maxY = -Infinity;

    for (const elemList of elements.values()) {
      for (const elem of elemList) {
        if (elem.locH < minX) minX = elem.locH;
        if (elem.locV < minY) minY = elem.locV;
        if (elem.locH + elem.width > maxX) maxX = elem.locH + elem.width;
        if (elem.locV + elem.height > maxY) maxY = elem.locV + elem.height;
      }
    }

    return {
      x: minX === Infinity ? 0 : minX,
      y: minY === Infinity ? 0 : minY,
      width: maxX === -Infinity ? 0 : maxX - minX,
      height: maxY === -Infinity ? 0 : maxY - minY,
    };
  }

  /**
   * Deep clone a layout object
   */
  private deepClone<T>(obj: T): T {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Map) {
      return new Map(Array.from(obj.entries()).map(([k, v]) => [k, this.deepClone(v)])) as T;
    }
    if (Array.isArray(obj)) {
      return obj.map(item => this.deepClone(item)) as T;
    }
    const cloned: Record<string, unknown> = {};
    for (const key of Object.keys(obj)) {
      cloned[key] = this.deepClone((obj as Record<string, unknown>)[key]);
    }
    return cloned as T;
  }

  /**
   * Clear the cache
   */
  clearCache(): void {
    this.cache.clear();
  }
}

// Singleton instance
export const layoutParser = new LayoutParser();

export function getLayoutParser(): LayoutParser {
  return layoutParser;
}
