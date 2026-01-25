/**
 * RC4Cipher - RC4 stream cipher implementation
 *
 * Ported from: fuse_client/Cast External ParentScript 72 - RC4 Class.ls
 *
 * Used for encrypting/decrypting Habbo network traffic.
 */

export class RC4Cipher {
  private sbox: number[] = [];
  private i: number = 0;
  private j: number = 0;

  constructor() {
    this.reset();
  }

  /**
   * Reset the cipher state
   */
  reset(): void {
    this.sbox = [];
    for (let i = 0; i < 256; i++) {
      this.sbox[i] = i;
    }
    this.i = 0;
    this.j = 0;
  }

  /**
   * Initialize with a key
   *
   * Lingo: tDecoder.setKey(tSharedKeyString, #old)
   */
  setKey(key: string, _mode?: string): void {
    this.reset();

    const keyLength = key.length;
    if (keyLength === 0) return;

    let j = 0;
    for (let i = 0; i < 256; i++) {
      j = (j + this.sbox[i] + key.charCodeAt(i % keyLength)) & 255;
      // Swap
      const temp = this.sbox[i];
      this.sbox[i] = this.sbox[j];
      this.sbox[j] = temp;
    }

    this.i = 0;
    this.j = 0;
  }

  /**
   * Pre-mix the encode S-box (used for additional security)
   *
   * Lingo: tConnection.getDecoder().preMixEncodeSbox(tPremixChars, 17)
   */
  preMixEncodeSbox(chars: string, rounds: number): void {
    for (let r = 0; r < rounds; r++) {
      for (let i = 0; i < chars.length; i++) {
        this.getNextByte();
      }
    }
  }

  /**
   * Get next pseudo-random byte from the stream
   */
  private getNextByte(): number {
    this.i = (this.i + 1) & 255;
    this.j = (this.j + this.sbox[this.i]) & 255;

    // Swap
    const temp = this.sbox[this.i];
    this.sbox[this.i] = this.sbox[this.j];
    this.sbox[this.j] = temp;

    return this.sbox[(this.sbox[this.i] + this.sbox[this.j]) & 255];
  }

  /**
   * Encrypt data
   *
   * Lingo method name (obfuscated): AkwGx8bHG2kc1xGG4xbdHPCV0fqvK
   */
  encrypt(data: string): string {
    let result = '';
    for (let i = 0; i < data.length; i++) {
      const byte = data.charCodeAt(i);
      const keyByte = this.getNextByte();
      result += String.fromCharCode(byte ^ keyByte);
    }
    return result;
  }

  /**
   * Decrypt data (same as encrypt for RC4)
   *
   * Lingo method name (obfuscated): kg4R6Jo5xjlqtFGs1klMrK4ZTzb3R
   */
  decrypt(data: string): string {
    return this.encrypt(data); // RC4 is symmetric
  }

  /**
   * Create a new key (for key exchange)
   */
  createKey(): string {
    const length = 30;
    const hexChars = '0123456789ABCDEF';
    let key = '';

    for (let i = 0; i < length * 2; i++) {
      key += hexChars[Math.floor(Math.random() * 16)];
    }

    return key;
  }

  /**
   * Clone the cipher state
   */
  clone(): RC4Cipher {
    const copy = new RC4Cipher();
    copy.sbox = [...this.sbox];
    copy.i = this.i;
    copy.j = this.j;
    return copy;
  }
}
