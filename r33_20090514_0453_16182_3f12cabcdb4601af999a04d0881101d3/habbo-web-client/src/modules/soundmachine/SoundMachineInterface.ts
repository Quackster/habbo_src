/**
 * Sound Machine Interface Class - UI handling
 *
 * Ported from: hh_soundmachine/Cast External ParentScript 3 - SoundMachine Interface Class.ls
 */

import { BaseObject } from '../../core/BaseObject';
import { EventEmitter } from '../../core/events';
import {
  registerMessage,
  unregisterMessage,
  executeMessage,
} from '../../core/MessageBus';
import { ConfirmAction } from './types';
import { SoundMachineComponent } from './SoundMachineComponent';

export class SoundMachineInterface extends BaseObject {
  private events: EventEmitter = new EventEmitter();

  // Window state
  private soundMachineWindowOpen: boolean = false;
  private playlistWindowOpen: boolean = false;
  private saveSongWindowOpen: boolean = false;
  private jukeboxWindowOpen: boolean = false;
  private jukeboxDiskWindowOpen: boolean = false;
  private confirmWindowOpen: boolean = false;
  private selectActionWindowOpen: boolean = false;

  // Playhead
  private playHeadDrag: boolean = false;

  construct(): void {
    super.construct();

    registerMessage('show_select_disk', this.id, 'showSelectDisk');
    registerMessage('get_jukebox_song_info', this.id, 'getJukeboxNowPlayingText');
    registerMessage('s_machine', this.id, 'showJukebox');
  }

  deconstruct(): void {
    unregisterMessage('show_select_disk', this.id);
    unregisterMessage('get_jukebox_song_info', this.id);
    unregisterMessage('s_machine', this.id);

    super.deconstruct();
  }

  /**
   * Show select action window
   */
  showSelectAction(isOn: boolean): void {
    this.selectActionWindowOpen = true;
    this.events.emit('showSelectAction', { isOn });
  }

  /**
   * Hide select action window
   */
  hideSelectAction(): void {
    this.selectActionWindowOpen = false;
    this.events.emit('hideSelectAction');
  }

  /**
   * Show playlist window
   */
  showPlaylist(): void {
    this.playlistWindowOpen = true;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getPlaylistManager().getSongListData();
    }

    this.updatePlaylists();
    this.events.emit('showPlaylist');
  }

  /**
   * Hide playlist window
   */
  hidePlaylist(): void {
    this.playlistWindowOpen = false;
    this.events.emit('hidePlaylist');
  }

  /**
   * Show sound machine editor
   */
  showSoundMachine(): void {
    this.soundMachineWindowOpen = true;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.initializeEdit();
    }

    this.updateSoundSetVisualizations();
    this.renderTimeLine();
    this.updatePlayHead();
    this.updatePlayButton();
    this.playHeadDrag = false;

    this.events.emit('showSoundMachine');
  }

  /**
   * Hide sound machine editor
   */
  hideSoundMachine(): void {
    this.soundMachineWindowOpen = false;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.closeEdit();
    }

    this.events.emit('hideSoundMachine');
  }

  /**
   * Show save song window
   */
  showSaveSong(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component?.getCanSaveSong()) {
      this.showAlert('song_not_ready');
      return;
    }

    this.saveSongWindowOpen = true;
    this.events.emit('showSaveSong', {
      songName: component.getEditorSongName(),
    });
  }

  /**
   * Hide save song window
   */
  hideSaveSong(): void {
    this.saveSongWindowOpen = false;
    this.events.emit('hideSaveSong');
  }

  /**
   * Show jukebox window
   */
  showJukebox(): void {
    this.jukeboxWindowOpen = true;

    const component = this.getComponent() as SoundMachineComponent | null;
    if (component) {
      component.getUserDisks();
    }

    this.renderJukebox();
    this.events.emit('showJukebox');
  }

  /**
   * Hide jukebox window
   */
  hideJukebox(): void {
    this.jukeboxWindowOpen = false;
    this.events.emit('hideJukebox');
  }

  /**
   * Show select disk window
   */
  showSelectDisk(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component?.getCanInsertDisk()) {
      this.showAlert('no_disks');
      return;
    }

    this.jukeboxDiskWindowOpen = true;
    this.renderUserDiskList(true);
    this.events.emit('showSelectDisk');
  }

  /**
   * Hide select disk window
   */
  hideJukeboxDisk(): void {
    this.jukeboxDiskWindowOpen = false;
    this.events.emit('hideSelectDisk');
  }

  /**
   * Confirm action dialog
   */
  confirmAction(action: ConfirmAction, parameter?: string | number): boolean {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return false;

    const needsConfirm = component.confirmAction(action, parameter ?? '');
    if (needsConfirm) {
      this.confirmWindowOpen = true;
      this.events.emit('showConfirm', { action, parameter });
    }
    return needsConfirm;
  }

  /**
   * Hide confirm window
   */
  hideConfirm(): void {
    this.confirmWindowOpen = false;
    this.events.emit('hideConfirm');
  }

  /**
   * Hide all windows
   */
  hideWindows(): void {
    this.hideSelectAction();
    this.hidePlaylist();
    this.hideSoundMachine();
    this.hideSaveSong();
    this.hideJukebox();
    this.hideJukeboxDisk();
    this.hideConfirm();
  }

  /**
   * Show alert message
   */
  showAlert(type: string, extra?: string): void {
    executeMessage('alert', {
      Msg: `sound_machine_alert_${type}${extra ? ': ' + extra : ''}`,
      modal: true,
    });
  }

  /**
   * Show alert with count
   */
  showAlertWithCount(type: string, count: number): void {
    executeMessage('alert', {
      Msg: `sound_machine_alert_${type}`.replace('%count%', count.toString()),
      modal: true,
    });
  }

  /**
   * Show song saved alert
   */
  showSongSaved(name: string): void {
    executeMessage('alert', {
      Msg: `Song "${name}" saved successfully`,
      modal: true,
    });
  }

  /**
   * Get jukebox now playing text
   */
  getJukeboxNowPlayingText(): {
    songName: string;
    author: string;
  } | null {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return null;

    const manager = component.getPlaylistManager();
    if (manager.getPlaylistCount() === 0) return null;

    return {
      songName: manager.getPlaylistSongName(1),
      author: manager.getPlaylistSongAuthor(1),
    };
  }

  /**
   * Render sound sets
   */
  renderSoundSets(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    this.events.emit('renderSoundSets', {
      soundSets: component.getSoundSetList(),
      selected: {
        set: component.getSelectedSoundSet(),
        sample: component.getSelectedSoundSetSample(),
      },
      hovered: {
        set: component.getHoveredSoundSet(),
        sample: component.getHoveredSoundSetSample(),
      },
    });
  }

  /**
   * Render song list
   */
  renderSongList(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();
    this.events.emit('renderSongList', {
      songs: manager.getSongList(),
      selected: manager.getSelectedSong(),
      songName: manager.getSongName(),
      songLength: manager.getSongLength(),
    });
  }

  /**
   * Render playlist
   */
  renderPlaylist(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();
    this.events.emit('renderPlaylist', {
      playlist: manager.getPlaylist(),
      selected: manager.getSelectedPlaylistSong(),
    });
  }

  /**
   * Render jukebox
   */
  renderJukebox(): void {
    this.renderJukeboxDiskList();
    this.renderJukeboxPlaylist();
  }

  /**
   * Render jukebox playlist
   */
  renderJukeboxPlaylist(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();
    const jukeboxManager = component.getJukeBoxManager();

    const playTime = manager.getPlayTime() / 10;
    const songLength =
      (manager.getPlaylistSongLength(1) *
        component.getTimeLineSlotLength()) /
      1000;

    this.events.emit('renderJukeboxPlaylist', {
      songName: manager.getPlaylistSongName(1),
      author: manager.getPlaylistSongAuthor(1),
      songLength: component.getTimeStringBasic(songLength),
      remaining: component.getTimeStringBasic(songLength - playTime),
      nextUp: Array.from({ length: manager.getPlaylistCount() - 1 }, (_, i) =>
        manager.getPlaylistSongName(i + 2)
      ),
    });
  }

  /**
   * Render jukebox disk list
   */
  renderJukeboxDiskList(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const jukeboxManager = component.getJukeBoxManager();
    this.events.emit('renderJukeboxDiskList', {
      disks: jukeboxManager.getDiskList(),
      selected: jukeboxManager.getSelectedDisk(),
      hovered: jukeboxManager.getHoveredDisk(),
    });
  }

  /**
   * Render user disk list
   */
  renderUserDiskList(initialRender: boolean): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const manager = component.getPlaylistManager();
    this.events.emit('renderUserDiskList', {
      disks: manager.getDiskList(),
      selected: manager.getSelectedDiskIndex(),
      initial: initialRender,
    });
  }

  /**
   * Render timeline
   */
  renderTimeLine(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const cursor = component.getTimelineCursor();

    this.events.emit('renderTimeLine', {
      timelineData: component.getTimelineData(),
      scrollX: component.getTimelineScrollX(),
      cursor,
      canScrollLeft: component.getScrollPossible(-1),
      canScrollRight: component.getScrollPossible(1),
    });

    this.updatePlayHead(true);
  }

  /**
   * Update sound set tabs
   */
  updateSoundSetTabs(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    this.events.emit('updateSoundSetTabs', {
      soundSets: component.getSoundSetList(),
      hoveredTab: component.getSoundSetHoveredTab(),
    });
  }

  /**
   * Update sound set slots
   */
  updateSoundSetSlots(): void {
    this.updateSoundSetTabs();
    this.renderSoundSets();
    this.renderTimeLine();
  }

  /**
   * Update sound set list
   */
  updateSoundSetList(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    this.events.emit('updateSoundSetList', {
      page: component.getSoundListPage(),
      pageCount: component.getSoundListPageCount(),
    });
  }

  /**
   * Update sound set visualizations
   */
  updateSoundSetVisualizations(): void {
    this.updateSoundSetList();
    this.updateSoundSetSlots();
  }

  /**
   * Scroll timeline
   */
  scrollTimeLine(dx: number): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component?.scrollTimeLine(dx)) {
      this.renderTimeLine();
    }
  }

  /**
   * Scroll timeline to position
   */
  scrollTimeLineTo(x: number): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (component?.scrollTimeLineTo(x)) {
      this.renderTimeLine();
    }
  }

  /**
   * Update playlists
   */
  updatePlaylists(): void {
    this.renderSongList();
    this.renderPlaylist();
  }

  /**
   * Update playhead
   */
  updatePlayHead(manualUpdate: boolean = false): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const pos = component.getPlayHeadPosition();
    this.events.emit('updatePlayHead', { position: pos, visible: pos > 0 });

    if (pos <= 0 && !manualUpdate) {
      this.scrollTimeLineTo(-pos - 1);
    }
  }

  /**
   * Update play button
   */
  updatePlayButton(): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    const isPlaying = component.getEditorPlayTime() > 0;
    this.events.emit('updatePlayButton', { isPlaying });
  }

  /**
   * Sound machine selected callback
   */
  soundMachineSelected(isOn: boolean): void {
    this.showSelectAction(isOn);
  }

  /**
   * Get editor window exists
   */
  getEditorWindowExists(): boolean {
    return this.soundMachineWindowOpen;
  }

  /**
   * Get events emitter
   */
  getEvents(): EventEmitter {
    return this.events;
  }

  /**
   * Handle UI event
   */
  handleEvent(event: string, data: unknown): void {
    const component = this.getComponent() as SoundMachineComponent | null;
    if (!component) return;

    switch (event) {
      case 'soundSetClick':
        const ssClick = data as { setId: number; x: number; y: number };
        if (component.soundSetEvent(ssClick.setId, ssClick.x, ssClick.y, 'mouseDown')) {
          this.renderSoundSets();
        }
        break;

      case 'soundSetHover':
        const ssHover = data as { setId: number; x: number; y: number };
        if (component.soundSetEvent(ssHover.setId, ssHover.x, ssHover.y, 'mouseWithin')) {
          this.renderSoundSets();
        }
        break;

      case 'soundSetLeave':
        const ssLeave = data as { setId: number };
        if (component.soundSetEvent(ssLeave.setId, 0, 0, 'mouseLeave')) {
          this.renderSoundSets();
        }
        break;

      case 'timelineClick':
        const tlClick = data as { x: number; y: number };
        if (component.timeLineEvent(tlClick.x, tlClick.y, 'mouseDown')) {
          this.renderTimeLine();
        }
        break;

      case 'timelineHover':
        const tlHover = data as { x: number; y: number };
        if (component.timeLineEvent(tlHover.x, tlHover.y, 'mouseWithin')) {
          this.renderTimeLine();
        }
        break;

      case 'timelineLeave':
        if (component.timeLineEvent(0, 0, 'mouseLeave')) {
          this.renderTimeLine();
        }
        break;

      case 'play':
        component.playEditorSong();
        this.updatePlayHead();
        break;

      case 'stop':
        component.stopEditorSong();
        break;

      case 'save':
        this.showSaveSong();
        break;

      case 'clear':
        this.confirmAction('clear');
        break;

      case 'scrollLeft':
        this.scrollTimeLine(-10);
        break;

      case 'scrollRight':
        this.scrollTimeLine(10);
        break;

      case 'confirmOk':
        component.actionConfirmed();
        this.hideConfirm();
        break;

      case 'confirmCancel':
        this.hideConfirm();
        break;
    }
  }
}
