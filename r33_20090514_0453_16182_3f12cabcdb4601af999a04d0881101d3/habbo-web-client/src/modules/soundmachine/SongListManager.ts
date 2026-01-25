/**
 * Song List Manager Class - Manages playlists and song lists
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 9 - SongList Manager Class.ls
 */

import { Song, Disk, PlaylistSong } from './types';
import { getConnection } from '../../managers/ConnectionManager';
import { getVariable } from '../../core/VariableContainer';

export class SongListManager {
  private connectionId: string = '';
  private songList: Song[] = [];
  private playlist: PlaylistSong[] = [];
  private diskList: Disk[] = [];

  private selectedSong: number = 1;
  private selectedPlaylistSong: number = 0;
  private selectedDisk: number = 1;
  private editorSongId: number = 0;
  private playlistChanged: boolean = false;

  private playTime: number = 0;
  private initialPlaylistTime: number = 0;

  private readonly playlistLimit = 5;

  construct(): void {
    this.connectionId = getVariable('connection.info.id', 'Info') as string;
    this.songList = [];
    this.playlist = [];
    this.diskList = [];
    this.playTime = 0;
    this.initialPlaylistTime = 0;
    this.selectedSong = 1;
    this.selectedPlaylistSong = 0;
    this.selectedDisk = 1;
    this.playlistChanged = false;
    this.editorSongId = 0;
  }

  deconstruct(): void {
    this.songList = [];
    this.playlist = [];
    this.diskList = [];
  }

  /**
   * Add song to playlist from song list
   */
  addPlaylistSong(): boolean {
    if (this.playlist.length >= this.playlistLimit) return false;
    if (this.selectedSong < 1 || this.selectedSong > this.songList.length) return false;

    const song = this.songList[this.selectedSong - 1];
    this.playlist.push({
      id: song.id,
      length: song.length,
      name: song.name,
      author: song.author || '',
    });
    this.playlistChanged = true;
    return true;
  }

  /**
   * Insert song into playlist
   */
  insertPlaylistSong(id: number, length: number, name: string, author: string): boolean {
    this.playlist.push({ id, length, name, author });
    if (this.playlist.length === 1) {
      this.resetPlayTime();
    }
    return true;
  }

  /**
   * Remove song from playlist
   */
  removePlaylistSong(index: number): boolean {
    if (index < 1 || index > this.playlist.length) return false;
    this.playlist.splice(index - 1, 1);
    this.playlistChanged = true;
    return true;
  }

  /**
   * Get playlist count
   */
  getPlaylistCount(): number {
    return this.playlist.length;
  }

  /**
   * Get playlist song
   */
  getPlaylistSong(index: number): PlaylistSong | null {
    if (index < 1 || index > this.playlist.length) return null;
    return { ...this.playlist[index - 1] };
  }

  /**
   * Get playlist song name
   */
  getPlaylistSongName(index: number): string {
    if (index < 1 || index > this.playlist.length) return '';
    return this.playlist[index - 1].name || '';
  }

  /**
   * Get playlist song author
   */
  getPlaylistSongAuthor(index: number): string {
    if (index < 1 || index > this.playlist.length) return '';
    return this.playlist[index - 1].author || '';
  }

  /**
   * Get selected song name
   */
  getSongName(): string {
    if (this.selectedSong < 1 || this.selectedSong > this.songList.length) return '';
    return this.songList[this.selectedSong - 1].name || '';
  }

  /**
   * Get selected song length
   */
  getSongLength(): number {
    if (this.selectedSong < 1 || this.selectedSong > this.songList.length) return -1;
    return this.songList[this.selectedSong - 1].length;
  }

  /**
   * Get total playlist length
   */
  getPlaylistLength(): number {
    let length = 0;
    for (const song of this.playlist) {
      if (song.length === -1) return -1;
      length += song.length;
    }
    return length;
  }

  /**
   * Get playlist song length
   */
  getPlaylistSongLength(index: number): number {
    if (index < 1 || index > this.playlist.length) return -1;
    return this.playlist[index - 1].length;
  }

  /**
   * Get editor song ID
   */
  getEditorSongId(): number {
    return this.editorSongId;
  }

  /**
   * Get playlist changed flag
   */
  getPlaylistChanged(): boolean {
    return this.playlistChanged;
  }

  /**
   * Get selected disk index
   */
  getSelectedDiskIndex(): number {
    return this.selectedDisk;
  }

  /**
   * Get current play time
   */
  getPlayTime(): number {
    return this.playTime + (Date.now() - this.initialPlaylistTime) / 100;
  }

  /**
   * Change play time
   */
  changePlayTime(delta: number): void {
    this.playTime += delta;
  }

  /**
   * Reset play time
   */
  resetPlayTime(): void {
    this.playTime = 0;
    this.initialPlaylistTime = Date.now();
  }

  /**
   * Handle disk list click
   */
  diskListMouseClick(x: number, y: number): boolean {
    const itemHeight = 18;
    const item = 1 + Math.floor(y / itemHeight);
    if (item >= 1 && item <= this.diskList.length) {
      this.selectedDisk = item;
      return true;
    }
    return false;
  }

  /**
   * Handle song list click
   */
  songListMouseClick(x: number, y: number): boolean {
    const itemHeight = 18;
    const item = 1 + Math.floor(y / itemHeight);
    if (item >= 1 && item <= this.songList.length) {
      this.selectedSong = item;
      return true;
    }
    return false;
  }

  /**
   * Handle playlist click
   */
  playlistMouseClick(x: number, y: number): boolean {
    const itemHeight = 18;
    const item = 1 + Math.floor(y / itemHeight);
    if (item >= 1 && item <= this.playlist.length) {
      return this.removePlaylistSong(item);
    }
    return false;
  }

  /**
   * Handle playlist mouse over
   */
  playlistMouseOver(x: number, y: number): boolean {
    const itemHeight = 18;
    const item = 1 + Math.floor(y / itemHeight);
    if (item !== this.selectedPlaylistSong) {
      this.selectedPlaylistSong = item;
      return true;
    }
    return false;
  }

  /**
   * Handle playlist arrow click
   */
  playlistArrowMouseClick(x: number, y: number): boolean {
    const itemHeight = 18;
    const arrowListWidth = 40;
    const item = 1 + Math.floor(y / itemHeight);

    if (item < 1 || item > this.playlist.length) return false;

    let item2: number;
    if (x < arrowListWidth / 2) {
      if (item === 1) return false;
      item2 = item - 1;
    } else {
      if (item === this.playlist.length) return false;
      item2 = item + 1;
    }

    // Swap songs
    const temp = this.playlist[item - 1];
    this.playlist[item - 1] = this.playlist[item2 - 1];
    this.playlist[item2 - 1] = temp;
    this.playlistChanged = true;
    return true;
  }

  /**
   * Get playlist data from server
   */
  getPlaylistData(): boolean {
    this.playlist = [];
    this.selectedPlaylistSong = 0;
    this.playTime = 0;
    this.initialPlaylistTime = 0;

    const conn = getConnection(this.connectionId);
    if (conn) {
      conn.send('GET_PLAY_LIST');
      return true;
    }
    return false;
  }

  /**
   * Get song list data from server
   */
  getSongListData(): boolean {
    this.songList = [];
    this.selectedSong = 1;

    const conn = getConnection(this.connectionId);
    if (conn) {
      conn.send('GET_SONG_LIST');
      return true;
    }
    return false;
  }

  /**
   * Save playlist to server
   */
  savePlaylist(): boolean {
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    const ids = this.playlist.map((song) => song.id);
    conn.send('UPDATE_PLAY_LIST', { count: ids.length, ids });
    return true;
  }

  /**
   * Edit selected song
   */
  editSong(): boolean {
    if (this.selectedSong < 1 || this.selectedSong > this.songList.length) return false;

    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    const song = this.songList[this.selectedSong - 1];
    this.editorSongId = song.id;
    conn.send('EDIT_SONG', { integer: this.editorSongId });
    return true;
  }

  /**
   * Create new song
   */
  newSong(): boolean {
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    conn.send('NEW_SONG');
    return true;
  }

  /**
   * Delete selected song
   */
  deleteSong(): boolean {
    if (this.selectedSong < 1 || this.selectedSong > this.songList.length) return false;

    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    const song = this.songList[this.selectedSong - 1];
    this.songList.splice(this.selectedSong - 1, 1);
    if (this.selectedSong > this.songList.length) {
      this.selectedSong = this.songList.length;
    }

    conn.send('DELETE_SONG', { integer: song.id });
    return true;
  }

  /**
   * Download song data
   */
  downloadSong(id: number): boolean {
    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    conn.send('GET_SONG_INFO', { integer: id });
    return true;
  }

  /**
   * Burn song to disk
   */
  burnSong(): boolean {
    if (this.selectedSong < 1 || this.selectedSong > this.songList.length) return false;

    const conn = getConnection(this.connectionId);
    if (!conn) return false;

    const song = this.songList[this.selectedSong - 1];
    conn.send('BURN_SONG', { integer: song.id });
    return true;
  }

  /**
   * Set disk list
   */
  setDiskList(diskList: Disk[]): void {
    this.diskList = diskList;
    this.selectedDisk = 1;
  }

  /**
   * Parse song list from server
   */
  parseSongList(songs: Array<{ id: number; length: number; name: string; locked: boolean }>): void {
    this.songList = songs.map((s) => ({
      id: s.id,
      length: s.length,
      name: s.name,
      locked: s.locked,
      author: '',
    }));
    this.selectedSong = 1;

    // Remove playlist songs that no longer exist
    if (this.playlistChanged) {
      this.playlist = this.playlist.filter((p) =>
        this.songList.some((s) => s.id === p.id)
      );
    }
  }

  /**
   * Parse playlist from server
   */
  parsePlaylist(
    playTime: number,
    songs: Array<{ id: number; length: number; name: string; author: string }>
  ): void {
    this.playlist = songs.map((s) => ({
      id: s.id,
      length: s.length,
      name: s.name,
      author: s.author,
    }));
    this.selectedPlaylistSong = 0;
    this.playTime = playTime;
    this.initialPlaylistTime = Date.now();
    this.playlistChanged = false;
  }

  /**
   * Get song list
   */
  getSongList(): Song[] {
    return [...this.songList];
  }

  /**
   * Get playlist
   */
  getPlaylist(): PlaylistSong[] {
    return [...this.playlist];
  }

  /**
   * Get disk list
   */
  getDiskList(): Disk[] {
    return [...this.diskList];
  }

  /**
   * Get selected song index
   */
  getSelectedSong(): number {
    return this.selectedSong;
  }

  /**
   * Get selected playlist song index
   */
  getSelectedPlaylistSong(): number {
    return this.selectedPlaylistSong;
  }
}
