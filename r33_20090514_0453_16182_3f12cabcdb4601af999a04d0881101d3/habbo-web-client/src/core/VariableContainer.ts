/**
 * VariableContainer - Configuration/variable storage
 *
 * Ported from: fuse_client/Cast External ParentScript 47 - Variable Container Class.ls
 *
 * Used for storing configuration variables loaded from external files.
 * The original loads variables from Director field members with key=value format.
 */

import { PropList } from '../types';

export class VariableContainer {
  private items: Map<string, unknown> = new Map();

  constructor() {
    this.items = new Map();
  }

  /**
   * Create/set a variable
   *
   * Lingo: getVariableManager().create("var.name", value)
   */
  create(variable: string, value: unknown): boolean {
    this.items.set(variable, value);
    return true;
  }

  /**
   * Set a variable (alias for create)
   *
   * Lingo: getVariableManager().set("var.name", value)
   */
  set(variable: string, value: unknown): boolean {
    return this.create(variable, value);
  }

  /**
   * Get a variable value
   *
   * Lingo: getVariable("var.name")
   *        getVariable("var.name", defaultValue)
   */
  GET(variable: string, defaultValue?: unknown): unknown {
    const value = this.items.get(variable);
    if (value === undefined) {
      if (defaultValue !== undefined) {
        return defaultValue;
      }
      console.warn(`VariableContainer: Variable not found: "${variable}"`);
      return 0;
    }
    return value;
  }

  /**
   * Get variable as integer
   *
   * Lingo: getIntVariable("var.name", defaultValue)
   */
  getInt(variable: string, defaultValue?: number): number {
    const value = this.items.get(variable);
    if (value === undefined) {
      if (defaultValue !== undefined) {
        return defaultValue;
      }
      console.warn(`VariableContainer: Variable not found: "${variable}"`);
      return 0;
    }
    return parseInt(String(value), 10) || 0;
  }

  /**
   * Get variable as string
   *
   * Lingo: getVariable("var.name") with string context
   */
  getString(variable: string, defaultValue?: string): string {
    const value = this.items.get(variable);
    if (value === undefined) {
      if (defaultValue !== undefined) {
        return defaultValue;
      }
      console.warn(`VariableContainer: Variable not found: "${variable}"`);
      return '';
    }
    return String(value);
  }

  /**
   * Get variable as evaluated value (for lists/objects stored as strings)
   *
   * Lingo: getVariableManager().GetValue("var.name")
   */
  GetValue(variable: string, defaultValue?: unknown): unknown {
    const value = this.items.get(variable);
    if (value === undefined) {
      return defaultValue;
    }

    // If it's a string that looks like JSON, try to parse it
    if (typeof value === 'string') {
      try {
        // Convert Lingo-style list syntax to JSON
        const jsonStr = value
          .replace(/\[:/g, '{')
          .replace(/:\]/g, '}')
          .replace(/#(\w+)/g, '"$1"');
        return JSON.parse(jsonStr);
      } catch {
        return value;
      }
    }

    return value;
  }

  /**
   * Remove a variable
   *
   * Lingo: getVariableManager().Remove("var.name")
   */
  Remove(variable: string): boolean {
    return this.items.delete(variable);
  }

  /**
   * Check if variable exists
   *
   * Lingo: variableExists("var.name")
   */
  exists(variable: string): boolean {
    return this.items.has(variable);
  }

  /**
   * Load variables from a key=value string (like Director fields)
   *
   * Lingo: getVariableManager().dump(member(tField).number, RETURN, 0)
   *
   * @param content - String content with key=value pairs
   * @param delimiter - Line delimiter (default: newline)
   * @param override - Whether to override existing values (default: true)
   */
  dump(content: string, delimiter: string = '\n', override: boolean = true): boolean {
    const lines = content.split(delimiter);

    for (const line of lines) {
      const trimmed = line.trim();

      // Skip comments and empty lines
      if (!trimmed || trimmed.startsWith('#')) {
        continue;
      }

      const eqIndex = trimmed.indexOf('=');
      if (eqIndex === -1) {
        continue;
      }

      const prop = trimmed.slice(0, eqIndex).trim();
      let value: unknown = trimmed.slice(eqIndex + 1).trim();

      // Type conversion
      if (typeof value === 'string') {
        // Check for symbol (#name)
        if (value.startsWith('#')) {
          value = value.slice(1); // Remove # prefix
        }
        // Check for integer
        else if (/^-?\d+$/.test(value)) {
          value = parseInt(value, 10);
        }
        // Check for float
        else if (/^-?\d+\.\d+$/.test(value)) {
          value = parseFloat(value);
        }
        // Check for boolean
        else if (value.toLowerCase() === 'true') {
          value = true;
        } else if (value.toLowerCase() === 'false') {
          value = false;
        }
      }

      // Set value if override is true or key doesn't exist
      if (override || !this.items.has(prop)) {
        this.items.set(prop, value);
      }
    }

    return true;
  }

  /**
   * Clear all variables
   */
  clear(): void {
    this.items.clear();
  }

  /**
   * Get all variables as object
   */
  toObject(): PropList {
    const obj: PropList = {};
    for (const [key, value] of this.items) {
      obj[key] = value;
    }
    return obj;
  }

  /**
   * Debug: print all variables
   */
  print(): void {
    console.log('=== Variables ===');
    for (const [key, value] of this.items) {
      console.log(`  ${key} = ${JSON.stringify(value)}`);
    }
  }
}

// Global singleton for the main variable manager
export const variableManager = new VariableContainer();

// Convenience functions matching Lingo API
export function getVariable(name: string, defaultValue?: unknown): unknown {
  return variableManager.GET(name, defaultValue);
}

export function getIntVariable(name: string, defaultValue?: number): number {
  return variableManager.getInt(name, defaultValue);
}

export function variableExists(name: string): boolean {
  return variableManager.exists(name);
}

export function getVariableManager(): VariableContainer {
  return variableManager;
}

export function getClassVariable(name: string): string {
  return variableManager.getString(name, name);
}
