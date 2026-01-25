/**
 * Jukebox Manager Class - Manages jukebox disk list
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 10 - Jukebox Manager Class.ls
 */

import { Disk } from './types';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';

export class JukeboxManager {
  private connectionId: string = '';
  private diskList: Disk[] = [];
  private selectedDisk: number = 0;
  private hoveredDisk: number = 0;
  private isOwner: boolean = false;

  construct(): void {
    this.connectionId = getVariable('connection.info.id', 'Info') as string;
    this.diskList = [];
    this.selectedDisk = 0;
    this.hoveredDisk = 0;
    this.isOwner = false;
  }

  deconstruct(): void {
    this.diskList = [];
  }

  /**
   * Set owner status
   */
  setOwner(isOwner: boolean): void {
    this.isOwner = isOwner;
  }

  /**
   * Get owner status
   */
  getOwner(): boolean {
    return this.isOwner;
  }

  /**
   * Get jukebox disks from server
   */
  getJukeboxDisks(): boolean {
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    conn.send('GET_JUKEBOX_DISCS');
    return true;
  }

  /**
   * Parse disk list from server
   */
  parseDiskList(disks: Array<{ id: number; name: string }>): void {
    this.diskList = disks.map((d) => ({
      id: d.id,
      name: d.name,
    }));
    this.selectedDisk = this.diskList.length > 0 ? 1 : 0;
  }

  /**
   * Insert disk into jukebox
   */
  insertDisk(diskId: number): boolean {
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    conn.send('ADD_JUKEBOX_DISC', { integer: diskId });
    return true;
  }

  /**
   * Remove disk from jukebox
   */
  removeDisk(slot: number): boolean {
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    conn.send('REMOVE_JUKEBOX_DISC', { integer: slot });
    return true;
  }

  /**
   * Handle disk list click
   */
  diskListMouseClick(x: number, y: number): boolean {
    const itemHeight = 30;
    const item = Math.floor(y / itemHeight);

    if (item >= 0 && item < this.diskList.length) {
      // Check if clicked on remove button area
      const removeButtonX = 120;
      if (x >= removeButtonX && this.isOwner) {
        return this.removeDisk(item + 1);
      }

      this.selectedDisk = item + 1;
      return true;
    }
    return false;
  }

  /**
   * Handle disk list mouse over
   */
  diskListMouseOver(x: number, y: number): boolean {
    const itemHeight = 30;
    const item = Math.floor(y / itemHeight);

    if (item !== this.hoveredDisk - 1) {
      this.hoveredDisk = item >= 0 && item < this.diskList.length ? item + 1 : 0;
      return true;
    }
    return false;
  }

  /**
   * Get disk list
   */
  getDiskList(): Disk[] {
    return [...this.diskList];
  }

  /**
   * Get selected disk
   */
  getSelectedDisk(): number {
    return this.selectedDisk;
  }

  /**
   * Get hovered disk
   */
  getHoveredDisk(): number {
    return this.hoveredDisk;
  }

  /**
   * Get disk count
   */
  getDiskCount(): number {
    return this.diskList.length;
  }
}
