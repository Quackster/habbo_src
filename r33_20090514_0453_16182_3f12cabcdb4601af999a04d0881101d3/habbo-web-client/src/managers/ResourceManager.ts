/**
 * ResourceManager - Asset loading and caching
 *
 * Ported from: fuse_client/Cast External ParentScript 30 - Resource Manager Class.ls
 *
 * In Director, this managed cast members (sprites, sounds, scripts).
 * In the browser port, this manages loaded assets (images, audio, JSON data).
 *
 * Integrates with AssetLoader for DCR-style resource loading.
 */

import { ObjectId } from '../types';
import { assetLoader, LoadedAsset } from '../assets/AssetLoader';

export interface AssetEntry {
  name: string;
  type: 'image' | 'audio' | 'json' | 'text' | 'binary';
  url: string;
  data?: unknown;
  loaded: boolean;
  loading: boolean;
}

export class ResourceManager {
  // Asset registry by name
  private assets: Map<string, AssetEntry> = new Map();

  // Name to numeric ID mapping (for Lingo compatibility)
  private nameToId: Map<string, number> = new Map();
  private idToName: Map<number, string> = new Map();

  // Dynamic/created assets
  private dynamicAssets: Set<string> = new Set();

  // ID counter for new assets
  private nextId: number = 1;

  /**
   * Register an asset
   */
  register(name: string, type: AssetEntry['type'], url: string): number {
    if (this.assets.has(name)) {
      return this.nameToId.get(name) ?? 0;
    }

    const id = this.nextId++;
    this.assets.set(name, {
      name,
      type,
      url,
      loaded: false,
      loading: false,
    });
    this.nameToId.set(name, id);
    this.idToName.set(id, name);

    return id;
  }

  /**
   * Register member (alias matching original API)
   */
  registerMember(name: string, id?: number): number {
    if (id !== undefined) {
      this.nameToId.set(name, id);
      this.idToName.set(id, name);
      return id;
    }
    return this.nameToId.get(name) ?? 0;
  }

  /**
   * Unregister a member
   */
  unregisterMember(name: string): boolean {
    const id = this.nameToId.get(name);
    if (id !== undefined) {
      this.nameToId.delete(name);
      this.idToName.delete(id);
    }
    return this.assets.delete(name);
  }

  /**
   * Get member number by name
   *
   * Lingo: getResourceManager().getmemnum("sprite_name")
   */
  getmemnum(name: string): number {
    return this.nameToId.get(name) ?? 0;
  }

  /**
   * Check if member exists
   *
   * Lingo: memberExists("sprite_name")
   */
  exists(name: string): boolean {
    return this.assets.has(name) || this.nameToId.has(name);
  }

  /**
   * Get asset entry
   */
  getAsset(name: string): AssetEntry | undefined {
    return this.assets.get(name);
  }

  /**
   * Get member (returns the asset data)
   *
   * Lingo: member("sprite_name")
   */
  getMember(name: string): unknown {
    const asset = this.assets.get(name);
    return asset?.data;
  }

  /**
   * Load an asset
   */
  async load(name: string): Promise<unknown> {
    const asset = this.assets.get(name);
    if (!asset) {
      console.error(`ResourceManager: Asset not found: ${name}`);
      return null;
    }

    if (asset.loaded) {
      return asset.data;
    }

    if (asset.loading) {
      // Wait for existing load
      return new Promise((resolve) => {
        const check = () => {
          if (asset.loaded) {
            resolve(asset.data);
          } else if (!asset.loading) {
            resolve(null);
          } else {
            setTimeout(check, 50);
          }
        };
        check();
      });
    }

    asset.loading = true;

    try {
      switch (asset.type) {
        case 'image':
          asset.data = await this.loadImage(asset.url);
          break;
        case 'audio':
          asset.data = await this.loadAudio(asset.url);
          break;
        case 'json':
          asset.data = await this.loadJSON(asset.url);
          break;
        case 'text':
          asset.data = await this.loadText(asset.url);
          break;
        case 'binary':
          asset.data = await this.loadBinary(asset.url);
          break;
      }
      asset.loaded = true;
    } catch (error) {
      console.error(`ResourceManager: Failed to load ${name}:`, error);
      asset.data = null;
    } finally {
      asset.loading = false;
    }

    return asset.data;
  }

  /**
   * Load multiple assets
   */
  async loadAll(names: string[]): Promise<void> {
    await Promise.all(names.map((name) => this.load(name)));
  }

  /**
   * Load an image
   */
  private loadImage(url: string): Promise<HTMLImageElement> {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = reject;
      img.src = url;
    });
  }

  /**
   * Load audio
   */
  private async loadAudio(url: string): Promise<AudioBuffer> {
    const response = await fetch(url);
    const arrayBuffer = await response.arrayBuffer();
    const audioContext = new AudioContext();
    return audioContext.decodeAudioData(arrayBuffer);
  }

  /**
   * Load JSON
   */
  private async loadJSON(url: string): Promise<unknown> {
    const response = await fetch(url);
    return response.json();
  }

  /**
   * Load text
   */
  private async loadText(url: string): Promise<string> {
    const response = await fetch(url);
    return response.text();
  }

  /**
   * Load binary
   */
  private async loadBinary(url: string): Promise<ArrayBuffer> {
    const response = await fetch(url);
    return response.arrayBuffer();
  }

  /**
   * Create a dynamic member
   *
   * Lingo: getResourceManager().createMember("new_sprite", #bitmap)
   */
  createMember(name: string, type: AssetEntry['type']): number {
    if (this.exists(name)) {
      console.warn(`ResourceManager: Member already exists: ${name}`);
      return this.getmemnum(name);
    }

    const id = this.nextId++;
    this.assets.set(name, {
      name,
      type,
      url: '',
      data: null,
      loaded: false,
      loading: false,
    });
    this.nameToId.set(name, id);
    this.idToName.set(id, name);
    this.dynamicAssets.add(name);

    return id;
  }

  /**
   * Remove a dynamic member
   *
   * Lingo: getResourceManager().removeMember("sprite_name")
   */
  removeMember(name: string): boolean {
    if (!this.dynamicAssets.has(name)) {
      console.warn(`ResourceManager: Cannot remove non-dynamic member: ${name}`);
      return false;
    }

    const id = this.nameToId.get(name);
    if (id !== undefined) {
      this.idToName.delete(id);
    }
    this.nameToId.delete(name);
    this.assets.delete(name);
    this.dynamicAssets.delete(name);

    return true;
  }

  /**
   * Update member data
   */
  updateMember(name: string, data: unknown): boolean {
    const asset = this.assets.get(name);
    if (!asset) {
      return false;
    }
    asset.data = data;
    asset.loaded = true;
    return true;
  }

  /**
   * Get property
   */
  getProperty(propId: string): unknown {
    switch (propId) {
      case 'memberCount':
        return this.assets.size;
      case 'dynMemCount':
        return this.dynamicAssets.size;
      default:
        return 0;
    }
  }

  /**
   * Pre-index all members from a manifest
   */
  preIndexMembers(manifest: Array<{ name: string; type: AssetEntry['type']; url: string }>): void {
    for (const entry of manifest) {
      this.register(entry.name, entry.type, entry.url);
    }
  }

  /**
   * Clear all assets
   */
  clear(): void {
    this.assets.clear();
    this.nameToId.clear();
    this.idToName.clear();
    this.dynamicAssets.clear();
    this.nextId = 1;
  }

  /**
   * Debug: print all assets
   */
  print(): void {
    console.log('=== ResourceManager ===');
    for (const [name, asset] of this.assets) {
      const status = asset.loaded ? 'loaded' : asset.loading ? 'loading' : 'pending';
      console.log(`  ${name} (${asset.type}): ${status}`);
    }
  }

  // === AssetLoader Integration ===

  /**
   * Load a cast (asset pack) for use
   */
  async loadCast(castName: string): Promise<boolean> {
    return assetLoader.loadCast(castName);
  }

  /**
   * Get an image from the asset system
   * Used by UI elements to load member images
   */
  async getImage(memberName: string): Promise<HTMLImageElement | ImageData | null> {
    // First check local assets
    const localAsset = this.assets.get(memberName);
    if (localAsset?.loaded && localAsset.type === 'image') {
      return localAsset.data as HTMLImageElement;
    }

    // Try to load from local registry
    if (localAsset && !localAsset.loaded) {
      await this.load(memberName);
      if (localAsset.loaded) {
        return localAsset.data as HTMLImageElement;
      }
    }

    // Try asset loader (searches all loaded casts)
    const asset = assetLoader.getByPath(memberName);
    if (asset?.image) {
      return asset.image;
    }

    // Try to load from common cast locations
    const castNames = ['fuse_client', 'hh_entry', 'hh_room', 'hh_human'];
    for (const cast of castNames) {
      const loaded = await assetLoader.loadMember(cast, memberName);
      if (loaded?.image) {
        return loaded.image;
      }
    }

    return null;
  }

  /**
   * Get text content from the asset system
   * Used by Layout Parser and other systems
   */
  async getText(memberName: string): Promise<string | null> {
    // First check local assets
    const localAsset = this.assets.get(memberName);
    if (localAsset?.loaded && localAsset.type === 'text') {
      return localAsset.data as string;
    }

    // Try to load from local registry
    if (localAsset && !localAsset.loaded) {
      await this.load(memberName);
      if (localAsset.loaded) {
        return localAsset.data as string;
      }
    }

    // Try asset loader
    const asset = assetLoader.getByPath(memberName);
    if (asset?.text) {
      return asset.text;
    }

    // Try to load from common cast locations
    const castNames = ['fuse_client', 'hh_entry', 'hh_room'];
    for (const cast of castNames) {
      const loaded = await assetLoader.loadMember(cast, memberName);
      if (loaded?.text) {
        return loaded.text;
      }
    }

    // Try direct URL load for layout files
    if (memberName.includes('.window') || memberName.includes('.element') || memberName.includes('.visual')) {
      try {
        const response = await fetch(`/assets/layouts/${memberName}.txt`);
        if (response.ok) {
          const text = await response.text();
          // Cache it
          this.register(memberName, 'text', '');
          this.updateMember(memberName, text);
          return text;
        }
      } catch {
        // Fall through
      }
    }

    return null;
  }

  /**
   * Get a canvas for a loaded image member
   */
  getCanvas(memberName: string): HTMLCanvasElement | null {
    const asset = assetLoader.getByPath(memberName);
    return asset?.canvas ?? null;
  }
}

// Global singleton
export const resourceManager = new ResourceManager();

// Convenience functions matching Lingo API
export function getResourceManager(): ResourceManager {
  return resourceManager;
}

export function memberExists(name: string): boolean {
  return resourceManager.exists(name);
}

export function getmemnum(name: string): number {
  return resourceManager.getmemnum(name);
}

export function createMember(name: string, type: AssetEntry['type']): number {
  return resourceManager.createMember(name, type);
}
