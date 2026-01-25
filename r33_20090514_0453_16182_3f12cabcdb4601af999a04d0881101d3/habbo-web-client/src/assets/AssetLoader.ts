/**
 * Asset Loader - Load assets from DCR-like resource packs
 *
 * This system handles loading of assets that were originally in Director Cast (DCR) files.
 * Assets can be loaded from:
 * 1. JSON manifest files with base64-encoded images
 * 2. Sprite sheets with JSON metadata
 * 3. Individual image/text files
 *
 * Original DCR structure had "casts" containing:
 * - Bitmap members (images)
 * - Text/Field members (text content, layouts)
 * - Script members (code - already ported)
 * - Sound members (audio)
 */

export interface AssetManifest {
  version: string;
  name: string;
  members: MemberEntry[];
}

export interface MemberEntry {
  name: string;
  type: 'bitmap' | 'text' | 'field' | 'sound' | 'script' | 'palette';
  data?: string; // Base64 for images, plain text for text
  url?: string; // URL to load from
  width?: number;
  height?: number;
  regPoint?: [number, number];
  palette?: string;
}

export interface LoadedAsset {
  name: string;
  type: string;
  image?: HTMLImageElement | ImageData;
  canvas?: HTMLCanvasElement;
  text?: string;
  audio?: AudioBuffer;
  palette?: Uint8Array;
}

class AssetLoader {
  private loadedCasts: Map<string, AssetManifest> = new Map();
  private assets: Map<string, LoadedAsset> = new Map();
  private loading: Map<string, Promise<LoadedAsset | null>> = new Map();
  private baseUrl: string = '/assets/';

  constructor() {
    // Base URL can be configured
  }

  /**
   * Set the base URL for asset loading
   */
  setBaseUrl(url: string): void {
    this.baseUrl = url.endsWith('/') ? url : url + '/';
  }

  /**
   * Load a cast (asset pack) from a manifest file
   */
  async loadCast(castName: string): Promise<boolean> {
    if (this.loadedCasts.has(castName)) {
      return true; // Already loaded
    }

    try {
      const manifestUrl = `${this.baseUrl}${castName}/manifest.json`;
      const response = await fetch(manifestUrl);

      if (!response.ok) {
        console.warn(`AssetLoader: Cast manifest not found: ${castName}`);
        return false;
      }

      const manifest: AssetManifest = await response.json();
      this.loadedCasts.set(castName, manifest);

      console.log(`AssetLoader: Loaded cast ${castName} with ${manifest.members.length} members`);
      return true;
    } catch (error) {
      console.error(`AssetLoader: Failed to load cast ${castName}:`, error);
      return false;
    }
  }

  /**
   * Preload all members from a cast
   */
  async preloadCast(castName: string): Promise<number> {
    const manifest = this.loadedCasts.get(castName);
    if (!manifest) {
      if (!await this.loadCast(castName)) {
        return 0;
      }
    }

    const loadedManifest = this.loadedCasts.get(castName)!;
    let loaded = 0;

    for (const member of loadedManifest.members) {
      const asset = await this.loadMember(castName, member.name);
      if (asset) loaded++;
    }

    return loaded;
  }

  /**
   * Load a specific member from a cast
   */
  async loadMember(castName: string, memberName: string): Promise<LoadedAsset | null> {
    const key = `${castName}:${memberName}`;

    // Check if already loaded
    if (this.assets.has(key)) {
      return this.assets.get(key)!;
    }

    // Check if currently loading
    if (this.loading.has(key)) {
      return this.loading.get(key)!;
    }

    // Start loading
    const loadPromise = this.doLoadMember(castName, memberName);
    this.loading.set(key, loadPromise);

    const result = await loadPromise;
    this.loading.delete(key);

    if (result) {
      this.assets.set(key, result);
    }

    return result;
  }

  /**
   * Internal load member implementation
   */
  private async doLoadMember(castName: string, memberName: string): Promise<LoadedAsset | null> {
    // First, ensure cast manifest is loaded
    if (!this.loadedCasts.has(castName)) {
      await this.loadCast(castName);
    }

    const manifest = this.loadedCasts.get(castName);
    if (!manifest) {
      // Try to load as standalone file
      return this.loadStandaloneAsset(castName, memberName);
    }

    // Find member in manifest
    const member = manifest.members.find(m => m.name === memberName);
    if (!member) {
      // Try to load as standalone
      return this.loadStandaloneAsset(castName, memberName);
    }

    return this.loadMemberEntry(castName, member);
  }

  /**
   * Load a member from its manifest entry
   */
  private async loadMemberEntry(castName: string, member: MemberEntry): Promise<LoadedAsset | null> {
    switch (member.type) {
      case 'bitmap':
        return this.loadBitmap(castName, member);
      case 'text':
      case 'field':
        return this.loadText(castName, member);
      case 'sound':
        return this.loadSound(castName, member);
      case 'palette':
        return this.loadPalette(castName, member);
      default:
        console.warn(`AssetLoader: Unknown member type: ${member.type}`);
        return null;
    }
  }

  /**
   * Load a bitmap member
   */
  private async loadBitmap(castName: string, member: MemberEntry): Promise<LoadedAsset> {
    const asset: LoadedAsset = {
      name: member.name,
      type: 'bitmap',
    };

    if (member.data) {
      // Base64 encoded image data
      const img = new Image();
      await new Promise<void>((resolve, reject) => {
        img.onload = () => resolve();
        img.onerror = reject;
        img.src = `data:image/png;base64,${member.data}`;
      });
      asset.image = img;

      // Create canvas for manipulation
      const canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      const ctx = canvas.getContext('2d')!;
      ctx.drawImage(img, 0, 0);
      asset.canvas = canvas;
    } else if (member.url) {
      // Load from URL
      const url = member.url.startsWith('http')
        ? member.url
        : `${this.baseUrl}${castName}/${member.url}`;

      const img = new Image();
      img.crossOrigin = 'anonymous';
      await new Promise<void>((resolve, reject) => {
        img.onload = () => resolve();
        img.onerror = reject;
        img.src = url;
      });
      asset.image = img;

      const canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      const ctx = canvas.getContext('2d')!;
      ctx.drawImage(img, 0, 0);
      asset.canvas = canvas;
    } else {
      // Try default URL pattern
      const url = `${this.baseUrl}${castName}/images/${member.name}.png`;
      try {
        const img = new Image();
        img.crossOrigin = 'anonymous';
        await new Promise<void>((resolve, reject) => {
          img.onload = () => resolve();
          img.onerror = reject;
          img.src = url;
        });
        asset.image = img;

        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d')!;
        ctx.drawImage(img, 0, 0);
        asset.canvas = canvas;
      } catch {
        console.warn(`AssetLoader: Failed to load bitmap ${member.name}`);
      }
    }

    return asset;
  }

  /**
   * Load a text member
   */
  private async loadText(castName: string, member: MemberEntry): Promise<LoadedAsset> {
    const asset: LoadedAsset = {
      name: member.name,
      type: 'text',
    };

    if (member.data) {
      // Direct text content
      asset.text = member.data;
    } else if (member.url) {
      // Load from URL
      const url = member.url.startsWith('http')
        ? member.url
        : `${this.baseUrl}${castName}/${member.url}`;

      const response = await fetch(url);
      asset.text = await response.text();
    } else {
      // Try default URL pattern
      const url = `${this.baseUrl}${castName}/text/${member.name}.txt`;
      try {
        const response = await fetch(url);
        if (response.ok) {
          asset.text = await response.text();
        }
      } catch {
        console.warn(`AssetLoader: Failed to load text ${member.name}`);
      }
    }

    return asset;
  }

  /**
   * Load a sound member
   */
  private async loadSound(castName: string, member: MemberEntry): Promise<LoadedAsset | null> {
    const asset: LoadedAsset = {
      name: member.name,
      type: 'sound',
    };

    // Audio loading would be implemented here
    // For now, return null as we need AudioContext

    return asset;
  }

  /**
   * Load a palette member
   */
  private async loadPalette(castName: string, member: MemberEntry): Promise<LoadedAsset> {
    const asset: LoadedAsset = {
      name: member.name,
      type: 'palette',
    };

    if (member.data) {
      // Base64 encoded palette data (256 * 3 bytes for RGB)
      const binary = atob(member.data);
      const palette = new Uint8Array(binary.length);
      for (let i = 0; i < binary.length; i++) {
        palette[i] = binary.charCodeAt(i);
      }
      asset.palette = palette;
    }

    return asset;
  }

  /**
   * Load a standalone asset (not in a manifest)
   */
  private async loadStandaloneAsset(path: string, name: string): Promise<LoadedAsset | null> {
    // Try common file extensions
    const extensions = ['.png', '.gif', '.jpg', '.txt', '.window', '.element', '.visual'];

    for (const ext of extensions) {
      const url = `${this.baseUrl}${path}/${name}${ext}`;
      try {
        const response = await fetch(url, { method: 'HEAD' });
        if (response.ok) {
          if (ext === '.txt' || ext === '.window' || ext === '.element' || ext === '.visual') {
            const textResponse = await fetch(url);
            return {
              name,
              type: 'text',
              text: await textResponse.text(),
            };
          } else {
            const img = new Image();
            img.crossOrigin = 'anonymous';
            await new Promise<void>((resolve, reject) => {
              img.onload = () => resolve();
              img.onerror = reject;
              img.src = url;
            });

            const canvas = document.createElement('canvas');
            canvas.width = img.width;
            canvas.height = img.height;
            const ctx = canvas.getContext('2d')!;
            ctx.drawImage(img, 0, 0);

            return {
              name,
              type: 'bitmap',
              image: img,
              canvas,
            };
          }
        }
      } catch {
        // Continue trying other extensions
      }
    }

    return null;
  }

  /**
   * Get a loaded asset by name
   */
  get(castName: string, memberName: string): LoadedAsset | null {
    return this.assets.get(`${castName}:${memberName}`) ?? null;
  }

  /**
   * Get a loaded asset by full path (cast:member or just member)
   */
  getByPath(path: string): LoadedAsset | null {
    if (path.includes(':')) {
      return this.assets.get(path) ?? null;
    }

    // Search all casts
    for (const [key, asset] of this.assets) {
      if (key.endsWith(`:${path}`)) {
        return asset;
      }
    }

    return null;
  }

  /**
   * Check if an asset exists
   */
  exists(castName: string, memberName: string): boolean {
    return this.assets.has(`${castName}:${memberName}`);
  }

  /**
   * Get image data from a loaded bitmap
   */
  getImageData(castName: string, memberName: string): ImageData | null {
    const asset = this.get(castName, memberName);
    if (!asset || asset.type !== 'bitmap' || !asset.canvas) {
      return null;
    }

    const ctx = asset.canvas.getContext('2d');
    if (!ctx) return null;

    return ctx.getImageData(0, 0, asset.canvas.width, asset.canvas.height);
  }

  /**
   * Get text content from a loaded text member
   */
  getText(castName: string, memberName: string): string | null {
    const asset = this.get(castName, memberName);
    if (!asset || (asset.type !== 'text' && asset.type !== 'field')) {
      return null;
    }
    return asset.text ?? null;
  }

  /**
   * Clear all loaded assets
   */
  clear(): void {
    this.assets.clear();
    this.loadedCasts.clear();
    this.loading.clear();
  }

  /**
   * Get memory usage estimate
   */
  getMemoryUsage(): { assets: number; bytes: number } {
    let bytes = 0;

    for (const asset of this.assets.values()) {
      if (asset.canvas) {
        bytes += asset.canvas.width * asset.canvas.height * 4;
      }
      if (asset.text) {
        bytes += asset.text.length * 2;
      }
      if (asset.palette) {
        bytes += asset.palette.length;
      }
    }

    return { assets: this.assets.size, bytes };
  }
}

// Singleton instance
export const assetLoader = new AssetLoader();

export function getAssetLoader(): AssetLoader {
  return assetLoader;
}
