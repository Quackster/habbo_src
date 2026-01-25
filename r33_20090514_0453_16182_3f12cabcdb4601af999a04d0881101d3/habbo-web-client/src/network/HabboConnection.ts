/**
 * HabboConnection - Single WebSocket connection with Habbo protocol
 *
 * Ported from: fuse_client/Cast External ParentScript 51 - Connection Instance Class.ls
 *
 * Protocol format:
 * - Outgoing: [3-byte length header][2-byte command ID][content]
 * - Incoming: [2-byte message type][content][0x01 terminator]
 *
 * Length/command encoding uses Base64-like scheme:
 * - Each byte = (value & 63) | 64
 */

import { ObjectId, MessageCallback, HabboMessage, MessageParams } from '../types';
import { RC4Cipher } from './RC4Cipher';

type MessageDispatcher = (objectId: ObjectId, methodName: string, message: HabboMessage) => void;

export class HabboConnection {
  private socket: WebSocket | null = null;
  private connectionOk: boolean = false;
  private connectionSecured: boolean = false;
  private messageBuffer: string = '';

  // Encryption
  private encryptionEnabled: boolean = false;
  private decipherEnabled: boolean = false;
  private encoder: RC4Cipher | null = null;
  private decoder: RC4Cipher | null = null;
  private headerEncoder: RC4Cipher | null = null;
  private headerDecoder: RC4Cipher | null = null;

  // Random seeds for padding
  private txSeed: number = 0;
  private rxSeed: number = 0;

  // Logging
  private logMode: number = 0;

  constructor(
    public readonly id: ObjectId,
    private host: string,
    private port: number,
    private listeners: Map<number, MessageCallback[]>,
    private commands: Map<string, string>,
    private dispatcher: MessageDispatcher
  ) {}

  /**
   * Connect to server
   */
  connect(): void {
    const protocol = this.port === 443 || this.host.includes('wss://') ? 'wss' : 'ws';
    const cleanHost = this.host.replace(/^wss?:\/\//, '');
    const url = `${protocol}://${cleanHost}:${this.port}`;

    console.log(`HabboConnection ${this.id}: Connecting to ${url}`);

    try {
      this.socket = new WebSocket(url);
      this.socket.binaryType = 'arraybuffer';

      this.socket.onopen = () => {
        console.log(`HabboConnection ${this.id}: Connected`);
        this.connectionOk = true;
        // Forward "hello" message (type 0)
        this.forwardMessage(0, '');
      };

      this.socket.onmessage = (event) => {
        this.handleIncoming(event.data);
      };

      this.socket.onerror = (error) => {
        console.error(`HabboConnection ${this.id}: Error`, error);
      };

      this.socket.onclose = () => {
        console.log(`HabboConnection ${this.id}: Disconnected`);
        this.connectionOk = false;
        // Forward disconnect message (type -1)
        this.forwardMessage(-1, '');
      };
    } catch (error) {
      console.error(`HabboConnection ${this.id}: Failed to connect`, error);
    }
  }

  /**
   * Disconnect from server
   */
  disconnect(controlled: boolean = false): void {
    if (!controlled) {
      this.forwardMessage(-1, '');
    }

    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
    this.connectionOk = false;
    this.connectionSecured = false;
  }

  /**
   * Check if connection is ready
   */
  isReady(): boolean {
    return this.connectionOk && this.socket?.readyState === WebSocket.OPEN;
  }

  /**
   * Check if connection is ready and secured
   */
  connectionReady(): boolean {
    return this.connectionOk && this.connectionSecured;
  }

  /**
   * Send a message to the server
   *
   * Lingo: tConn.send("TRY_LOGIN", [#string: name, #string: pass])
   */
  send(commandName: string, params?: MessageParams | string): boolean {
    if (!this.isReady()) {
      console.error(`HabboConnection ${this.id}: Not ready`);
      return false;
    }

    // Get encoded command ID
    const commandId = this.commands.get(commandName);
    if (!commandId) {
      console.error(`HabboConnection ${this.id}: Unknown command: ${commandName}`);
      return false;
    }

    // Encode parameters
    let content = '';
    if (typeof params === 'string') {
      content = this.encodeUTF8(params);
    } else if (params) {
      content = this.encodeParams(params);
    }

    // Build message: commandId + content
    let message = commandId + content;
    let length = this.calculateLength(message);

    // Encode header
    let header = this.encodeLength(length);

    // Apply encryption if enabled
    if (this.encryptionEnabled && this.encoder) {
      // Add random padding
      this.txSeed = this.iterateRandom(this.txSeed);
      const padAmount = this.txSeed % 5;
      message = this.addPadding(message, padAmount);

      // Encrypt message
      message = this.encoder.encrypt(message);
      length = message.length;

      // Rebuild header with random byte prefix
      const randomByte = String.fromCharCode(Math.floor(Math.random() * 128));
      header = randomByte + this.encodeLength(length);

      // Encrypt header if header encoder exists
      if (this.headerEncoder) {
        header = this.headerEncoder.encrypt(header);
      }
    }

    if (this.logMode > 0) {
      console.log(`<-- ${commandName} (${commandId.charCodeAt(0)},${commandId.charCodeAt(1)})`, params);
    }

    // Send
    this.socket!.send(header + message);
    return true;
  }

  /**
   * Calculate message length (accounting for potential multi-byte chars)
   */
  private calculateLength(message: string): number {
    let length = 0;
    for (let i = 0; i < message.length; i++) {
      const charCode = message.charCodeAt(i);
      length += 1 + (charCode > 255 && charCode % 256 ? 1 : 0);
    }
    return length;
  }

  /**
   * Encode message length as 3-byte Base64-like header
   */
  private encodeLength(length: number): string {
    const b1 = String.fromCharCode(((length >> 12) & 63) | 64);
    const b2 = String.fromCharCode(((length >> 6) & 63) | 64);
    const b3 = String.fromCharCode((length & 63) | 64);
    return b1 + b2 + b3;
  }

  /**
   * Encode parameters for sending
   */
  private encodeParams(params: MessageParams): string {
    let result = '';

    if (params.string !== undefined) {
      const str = this.encodeUTF8(String(params.string));
      const len = str.length;
      result += String.fromCharCode((len >> 6) | 64);
      result += String.fromCharCode((len & 63) | 64);
      result += str;
    }

    if (params.integer !== undefined) {
      result += this.encodeVL64(Number(params.integer));
    }

    if (params.boolean !== undefined) {
      result += this.encodeVL64(params.boolean ? 1 : 0);
    }

    if (params.short !== undefined) {
      const num = Number(params.short);
      result += String.fromCharCode((num >> 6) | 64);
      result += String.fromCharCode((num & 63) | 64);
    }

    return result;
  }

  /**
   * Encode integer as VL64 (variable-length Base64)
   */
  private encodeVL64(value: number): string {
    const negative = value < 0;
    if (negative) value = -value;

    let result = String.fromCharCode(64 + (value & 3));
    let bytes = 1;
    value = Math.floor(value / 4);

    while (value !== 0) {
      bytes++;
      result += String.fromCharCode(64 + (value & 63));
      value = Math.floor(value / 64);
    }

    // First byte includes length and sign
    const firstByte = result.charCodeAt(0);
    result =
      String.fromCharCode(firstByte | (bytes << 3) | (negative ? 4 : 0)) +
      result.slice(1);

    return result;
  }

  /**
   * Handle incoming data
   */
  private handleIncoming(data: ArrayBuffer | string): void {
    let content: string;

    if (data instanceof ArrayBuffer) {
      content = new TextDecoder('iso-8859-1').decode(data);
    } else {
      content = data;
    }

    // Handle encrypted messages
    if (this.encryptionEnabled && this.decipherEnabled) {
      this.handleEncryptedMessage(content);
    } else {
      this.messageBuffer += content;
      this.processBuffer();
    }
  }

  /**
   * Handle encrypted incoming messages
   */
  private handleEncryptedMessage(content: string): void {
    let offset = 0;

    while (offset < content.length) {
      // Decrypt header (6 bytes)
      let header = content.slice(offset, offset + 6);
      if (this.headerDecoder) {
        header = this.headerDecoder.decrypt(header);
      }

      // Decode message length from header (bytes 2-4)
      const b1 = header.charCodeAt(3) & 63;
      const b2 = header.charCodeAt(2) & 63;
      const b3 = header.charCodeAt(1) & 63;
      const msgSize = b1 | (b2 << 6) | (b3 << 12);

      // Extract and decrypt body
      let body = content.slice(offset + 6, offset + 6 + msgSize);
      if (this.decoder) {
        body = this.decoder.decrypt(body);
      }

      // Update random seed and remove padding
      this.rxSeed = this.iterateRandom(this.rxSeed);
      body = this.removePadding(body, this.rxSeed % 5);

      // Process the decrypted message
      this.processMessage(body);

      offset += 6 + msgSize;
    }
  }

  /**
   * Process message buffer (unencrypted)
   */
  private processBuffer(): void {
    while (this.messageBuffer.length > 0) {
      // Find message terminator (0x01)
      const terminator = this.messageBuffer.indexOf('\x01');
      if (terminator === -1) {
        break; // Incomplete message
      }

      const rawMessage = this.messageBuffer.slice(0, terminator);
      this.messageBuffer = this.messageBuffer.slice(terminator + 1);

      this.processMessage(rawMessage);
    }
  }

  /**
   * Process a single message
   */
  private processMessage(rawMessage: string): void {
    if (rawMessage.length < 2) return;

    // Decode message type (2 bytes, Base64-like)
    const byte1 = rawMessage.charCodeAt(0) & 63;
    const byte2 = rawMessage.charCodeAt(1) & 63;
    const messageType = (byte1 << 6) | byte2;

    // Extract content
    const content = rawMessage.slice(2);

    // Forward to listeners
    this.forwardMessage(messageType, content);
  }

  /**
   * Forward message to registered listeners
   */
  private forwardMessage(messageType: number, content: string): void {
    const callbacks = this.listeners.get(messageType);

    if (this.logMode > 0) {
      console.log(`--> ${messageType}`, content.slice(0, 100));
    }

    if (!callbacks || callbacks.length === 0) {
      if (messageType >= 0) {
        console.warn(`HabboConnection ${this.id}: No listener for message type ${messageType}`);
      }
      return;
    }

    // Create message object matching original structure
    const message: HabboMessage = {
      connection: this,
      subject: messageType,
      content: this.decodeUTF8(content),
    };

    // Add cursor for reading methods
    (message as Record<string, unknown>)._cursor = 0;

    for (const [objectId, methodName] of callbacks) {
      this.dispatcher(objectId, methodName, message);
    }
  }

  // === Message reading methods ===

  /**
   * Read VL64 integer from message
   */
  GetIntFrom(message: HabboMessage): number {
    const cursor = ((message as Record<string, unknown>)._cursor as number) || 0;
    const content = message.content;

    if (cursor >= content.length) return 0;

    const firstByte = content.charCodeAt(cursor) & 63;
    const byteCount = (firstByte >> 3) & 7;
    const negative = (firstByte & 4) !== 0;
    let value = firstByte & 3;

    const powTable = [4, 256, 16384, 1048576, 67108864];

    for (let i = 1; i < byteCount; i++) {
      const byte = content.charCodeAt(cursor + i) & 63;
      value |= byte * powTable[i - 1];
    }

    if (negative) value = -value;

    (message as Record<string, unknown>)._cursor = cursor + byteCount;
    return value;
  }

  /**
   * Read string from message (until 0x02 terminator)
   */
  GetStrFrom(message: HabboMessage): string {
    const cursor = ((message as Record<string, unknown>)._cursor as number) || 0;
    const content = message.content;

    const terminator = content.indexOf('\x02', cursor);
    if (terminator === -1) {
      (message as Record<string, unknown>)._cursor = content.length;
      return content.slice(cursor);
    }

    const str = content.slice(cursor, terminator);
    (message as Record<string, unknown>)._cursor = terminator + 1;
    return str;
  }

  /**
   * Read boolean from message
   */
  GetBoolFrom(message: HabboMessage): boolean {
    return this.GetIntFrom(message) !== 0;
  }

  /**
   * Read byte from message
   */
  GetByteFrom(message: HabboMessage): number {
    const cursor = ((message as Record<string, unknown>)._cursor as number) || 0;
    const content = message.content;

    if (cursor >= content.length) return 0;

    const byte = content.charCodeAt(cursor) & 63;
    (message as Record<string, unknown>)._cursor = cursor + 1;
    return byte;
  }

  // === Encryption setup ===

  /**
   * Set encryption key
   */
  setToken(token: string): void {
    // Extract TX seed from last 4 hex chars
    const txHex = token.slice(-4);
    this.txSeed = parseInt(txHex, 16) || 0;

    // Extract RX seed from first 4 hex chars
    const rxHex = token.slice(0, 4);
    this.rxSeed = parseInt(rxHex, 16) || 0;
  }

  /**
   * Set decoder cipher
   */
  setDecoder(decoder: RC4Cipher): void {
    this.decoder = decoder;
  }

  /**
   * Get decoder cipher
   */
  getDecoder(): RC4Cipher | null {
    return this.decoder;
  }

  /**
   * Set encoder cipher
   */
  setEncoder(encoder: RC4Cipher): void {
    this.encoder = encoder;
  }

  /**
   * Get encoder cipher
   */
  getEncoder(): RC4Cipher | null {
    return this.encoder;
  }

  /**
   * Set header decoder cipher
   */
  setHeaderDecoder(decoder: RC4Cipher): void {
    this.headerDecoder = decoder;
  }

  /**
   * Set header encoder cipher
   */
  setHeaderEncoder(encoder: RC4Cipher): void {
    this.headerEncoder = encoder;
  }

  /**
   * Enable/disable encryption
   */
  setEncryption(enabled: boolean): void {
    this.encryptionEnabled = enabled;
    this.connectionSecured = true;
  }

  /**
   * Enable/disable deciphering
   */
  setDeciphering(enabled: boolean): void {
    this.decipherEnabled = enabled;
  }

  /**
   * Set log mode
   */
  setLogMode(mode: number): void {
    this.logMode = mode;
  }

  // === Helper methods ===

  /**
   * Iterate random seed (matches original PRNG)
   */
  private iterateRandom(seed: number): number {
    return ((19979 * seed) + 5) % 65536;
  }

  /**
   * Add random padding to message
   */
  private addPadding(message: string, amount: number): string {
    let padded = message;
    for (let i = 0; i < amount; i++) {
      padded = String.fromCharCode(Math.floor(Math.random() * 256)) + padded;
    }
    return padded;
  }

  /**
   * Remove padding from message
   */
  private removePadding(message: string, amount: number): string {
    return message.slice(amount);
  }

  /**
   * Encode string as UTF-8
   */
  private encodeUTF8(str: string): string {
    try {
      return unescape(encodeURIComponent(str));
    } catch {
      return str;
    }
  }

  /**
   * Decode UTF-8 string
   */
  private decodeUTF8(str: string): string {
    try {
      return decodeURIComponent(escape(str));
    } catch {
      return str;
    }
  }

  // === Property access ===

  getProperty(prop: string): unknown {
    switch (prop) {
      case 'host':
        return this.host;
      case 'port':
        return this.port;
      case 'decoder':
        return this.decoder;
      case 'encoder':
        return this.encoder;
      case 'deciphering':
        return this.decipherEnabled;
      default:
        return null;
    }
  }

  setProperty(prop: string, value: unknown): boolean {
    switch (prop) {
      case 'deciphering':
        this.decipherEnabled = Boolean(value);
        return true;
      default:
        return false;
    }
  }

  getID(): ObjectId {
    return this.id;
  }
}
