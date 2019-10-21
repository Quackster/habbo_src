on construct(me)
  pJukeboxSongStr = getText("jukebox_song_name")
  pJukeboxAuthorStr = getText("jukebox_song_author")
  pJukeboxLengthStr = getText("jukebox_song_length")
  pJukeboxRemainingStr = getText("jukebox_song_remaining")
  pSoundSetIconUpdateTimer = "sound_machine_icon_timer"
  pPlayHeadUpdateTimer = "sound_machine_playhead_timer"
  pJukeboxListUpdateTimer = "jukebox_list_timer"
  pSoundMachineWindowID = getText("sound_machine_window")
  pPlaylistWindowID = getText("sound_machine_playlist_window")
  pSoundMachineConfirmWindowID = getText("sound_machine_confirm_window")
  pSaveSongWindowID = getText("sound_machine_save_window")
  pJukeboxWindowID = getText("sound_machine_jukebox_window")
  pJukeboxDiskWindowID = getText("sound_machine_jukebox_disk_window")
  registerMessage(#show_select_disk, me.getID(), #showSelectDisk)
  registerMessage(#get_jukebox_song_info, me.getID(), #getJukeboxNowPlayingText)
  registerMessage(#s_machine, me.getID(), #showJukebox)
  pSoundSetSlotWd = 25
  pSoundSetSlotHt = 25
  pSoundSetSlotMarginWd = -1
  pSoundSetSlotMarginHt = -1
  pTimeLineScrollStep = 10
  pSoundSetSampleMemberList = ["sound_system_ui_sample_g_", "sound_system_ui_sample_y_", "sound_system_ui_sample_p_", "sound_system_ui_sample_b_"]
  pSoundSetSampleMemberName = "sound_system_ui_sample_"
  pTimeLineSlotWd = 23
  pTimeLineSlotHt = 25
  pTimeLineSlotMarginWd = -1
  pTimeLineSlotMarginHt = 1
  pPlayHeadEventAgentID = me.getID() && the milliSeconds
  createObject(pPlayHeadEventAgentID, getClassVariable("event.agent.class"))
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#show_select_disk, me.getID())
  unregisterMessage(#get_jukebox_song_info, me.getID())
  unregisterMessage(#s_machine, me.getID())
  if timeoutExists(pSoundSetIconUpdateTimer) then
    removeTimeout(pSoundSetIconUpdateTimer)
  end if
  if timeoutExists(pPlayHeadUpdateTimer) then
    removeTimeout(pPlayHeadUpdateTimer)
  end if
  if timeoutExists(pJukeboxListUpdateTimer) then
    removeTimeout(pJukeboxListUpdateTimer)
  end if
  removeObject(pPlayHeadEventAgentID)
  return(1)
  exit
end

on showSelectAction(me, tIsOn)
  if not windowExists(pSoundMachineWindowID) then
    if not createWindow(pSoundMachineWindowID, "habbo_full.window") then
      return(error(me, "Failed to open Sound Machine window!!!", #showSelectAction, #major))
    else
      tWndObj = getWindow(pSoundMachineWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSelectAction, me.getID(), #mouseUp)
      if not tWndObj.merge("sound_machine_action.window") then
        return(tWndObj.close())
      end if
      tElem = tWndObj.getElement("sound_machine_onoff")
      if tElem <> 0 then
        if tIsOn then
          tText = getText("sound_machine_turn_off")
        else
          tText = getText("sound_machine_turn_on")
        end if
        tElem.setText(tText)
      end if
      tWndObj.center()
      tWndObj.moveBy(0, -30)
    end if
  else
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem <> 0 then
      if tIsOn then
        tText = getText("sound_machine_turn_off")
      else
        tText = getText("sound_machine_turn_on")
      end if
      tElem.setText(tText)
    end if
  end if
  return(1)
  exit
end

on showPlaylist(me)
  if not windowExists(pPlaylistWindowID) then
    if not createWindow(pPlaylistWindowID, "sound_machine_window.window", void(), void(), #modal) then
      return(error(me, "Failed to open Sound Machine window!!!", #showPlaylist, #major))
    else
      tWndObj = getWindow(pPlaylistWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcPlaylist, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcPlaylist, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcPlaylist, me.getID(), #mouseLeave)
      if not tWndObj.merge("sound_machine_playlist.window") then
        return(tWndObj.close())
      end if
      tElemList = ["sound_machine_edit_text", "sound_machine_new_text", "sound_machine_list_save_text", "sound_machine_burn_text"]
      repeat while me <= undefined
        tElemName = getAt(undefined, undefined)
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
      tWndObj.center()
      tWndObj.moveBy(0, -30)
      tPlaylistManager = me.getComponent().getPlaylistManager()
      if tPlaylistManager <> 0 then
        tPlaylistManager.getSongListData()
      end if
      me.updatePlaylists()
    end if
  end if
  return(1)
  exit
end

on showSoundMachine(me)
  if not windowExists(pSoundMachineWindowID) then
    if not createWindow(pSoundMachineWindowID, "sound_machine_window.window", void(), void(), #modal) then
      return(error(me, "Failed to open Sound Machine window!!!", #showSoundMachine, #major))
    else
      tWndObj = getWindow(pSoundMachineWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcSoundMachine, me.getID(), #mouseLeave)
      if not tWndObj.merge("sound_machine_ui.window") then
        return(tWndObj.close())
      end if
      me.getComponent().initializeEdit()
      me.updateSoundSetVisualizations()
      me.renderTimeLine()
      me.updatePlayHead()
      me.updatePlayButton()
      tElem = tWndObj.getElement("sound_timeline_playhead")
      if tElem <> 0 then
        tsprite = tElem.getProperty(#sprite)
        if ilk(tsprite) = #sprite then
          removeEventBroker(tsprite.spriteNum)
        end if
      end if
      pPlayHeadDrag = 0
      tWndObj.center()
      tWndObj.moveBy(0, -30)
    end if
  end if
  return(1)
  exit
end

on showSaveSong(me)
  if not windowExists(pSaveSongWindowID) then
    if not me.getComponent().getCanSaveSong() then
      me.ShowAlert("song_not_ready")
      return(1)
    end if
    if not createWindow(pSaveSongWindowID, "sound_machine_window.window", void(), void(), #modal) then
      return(error(me, "Failed to open song save window!!!", #showPlaylist, #major))
    else
      tWndObj = getWindow(pSaveSongWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcSaveSong, me.getID(), #mouseUp)
      if not tWndObj.merge("sound_machine_save.window") then
        return(tWndObj.close())
      end if
      tElemList = ["sound_machine_edit_text", "sound_machine_song_save_text", "sound_machine_save_cancel_text"]
      repeat while me <= undefined
        tElemName = getAt(undefined, undefined)
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
      tElem = tWndObj.getElement("sound_machine_song_name")
      if tElem <> 0 then
        tSongName = me.getComponent().getEditorSongName()
        if tSongName <> "" then
          tElem.setText(tSongName)
        else
          tElem.setText(getText("sound_machine_song_name"))
        end if
      end if
      tWndObj.center()
      tWndObj.moveBy(0, -30)
      me.updatePlaylists()
    end if
  end if
  return(1)
  exit
end

on showJukebox(me)
  if not windowExists(pJukeboxWindowID) then
    if not createWindow(pJukeboxWindowID, "sound_machine_jukebox.window", void(), void(), #modal) then
      return(error(me, "Failed to open jukebox window!!!", #showJukebox, #major))
    else
      me.renderJukebox()
      tWndObj = getWindow(pJukeboxWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcJukebox, me.getID(), #mouseLeave)
      if not timeoutExists(pJukeboxListUpdateTimer) then
        createTimeout(pJukeboxListUpdateTimer, 500, #renderJukeboxPlaylist, me.getID(), void(), 0)
      end if
      tElemList = ["jukebox_reset_text"]
      repeat while me <= undefined
        tElemName = getAt(undefined, undefined)
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
      tJukeBoxManager = me.getComponent().getJukeBoxManager()
      if tJukeBoxManager <> 0 then
        if not tJukeBoxManager.getOwner() then
          tElemList = ["jukebox_reset_button", "jukebox_reset_text"]
          repeat while me <= undefined
            tElemName = getAt(undefined, undefined)
            tElem = tWndObj.getElement(tElemName)
            if tElem <> 0 then
              tElem.setProperty(#visible, 0)
            end if
          end repeat
        end if
      end if
      me.getComponent().getUserDisks()
    end if
  end if
  return(1)
  exit
end

on showSelectDisk(me)
  if not windowExists(pJukeboxDiskWindowID) then
    if not me.getComponent().getCanInsertDisk() then
      me.ShowAlert("no_disks")
      return(1)
    end if
    if not createWindow(pJukeboxDiskWindowID, "sound_machine_jukebox_disklist.window", void(), void(), #modal) then
      return(error(me, "Failed to open select disk window!!!", #showSelectDisk, #major))
    else
      me.renderUserDiskList(1)
      tWndObj = getWindow(pJukeboxDiskWindowID)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcJukeboxDisk, me.getID(), #mouseUp)
      tElemList = ["jukebox_disk_add_text", "jukebox_disk_cancel_text"]
      repeat while me <= undefined
        tElemName = getAt(undefined, undefined)
        tElem = tWndObj.getElement(tElemName)
        if tElem <> 0 then
          tsprite = tElem.getProperty(#sprite)
          if ilk(tsprite) = #sprite then
            removeEventBroker(tsprite.spriteNum)
          end if
        end if
      end repeat
    end if
  end if
  return(1)
  exit
end

on getJukeboxNowPlayingText(me, tArray)
  if ilk(tArray) <> #propList then
    return(0)
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  if tPlaylistManager = 0 then
    return(0)
  end if
  if tPlaylistManager.getPlaylistCount() = 0 then
    return(0)
  end if
  tSongName = tPlaylistManager.getPlaylistSongName(1)
  tAuthor = tPlaylistManager.getPlaylistSongAuthor(1)
  tSongStr = pJukeboxSongStr
  tAuthorStr = pJukeboxAuthorStr
  tSongStr = replaceChunks(tSongStr, "%name%", tSongName)
  tAuthorStr = replaceChunks(tAuthorStr, "%author%", tAuthor)
  tArray.setAt(#songName, tSongStr)
  tArray.setAt(#author, tAuthorStr)
  return(tArray)
  exit
end

on hideWindows(me)
  me.hideSelectAction()
  me.hidePlaylist()
  me.hideSoundMachine()
  me.hideSaveSong()
  me.hideJukebox()
  me.hideJukeboxDisk()
  me.hideConfirm()
  exit
end

on hideSelectAction(me)
  if windowExists(pSoundMachineWindowID) then
    return(removeWindow(pSoundMachineWindowID))
  else
    return(0)
  end if
  exit
end

on hidePlaylist(me)
  if windowExists(pPlaylistWindowID) then
    return(removeWindow(pPlaylistWindowID))
  else
    return(0)
  end if
  exit
end

on hideSoundMachine(me)
  if windowExists(pSoundMachineWindowID) then
    me.getComponent().closeEdit()
    return(removeWindow(pSoundMachineWindowID))
  else
    return(0)
  end if
  exit
end

on hideSaveSong(me)
  if windowExists(pSaveSongWindowID) then
    return(removeWindow(pSaveSongWindowID))
  else
    return(0)
  end if
  exit
end

on hideJukebox(me)
  if timeoutExists(pJukeboxListUpdateTimer) then
    removeTimeout(pJukeboxListUpdateTimer)
  end if
  if windowExists(pJukeboxWindowID) then
    return(removeWindow(pJukeboxWindowID))
  else
    return(0)
  end if
  exit
end

on hideJukeboxDisk(me)
  if windowExists(pJukeboxDiskWindowID) then
    return(removeWindow(pJukeboxDiskWindowID))
  else
    return(0)
  end if
  exit
end

on confirmAction(me, tAction, tParameter)
  tResult = me.getComponent().confirmAction(tAction, tParameter)
  if tResult then
    if not windowExists(pSoundMachineConfirmWindowID) then
      if not createWindow(pSoundMachineConfirmWindowID, "habbo_full.window", void(), void(), #modal) then
        return(error(me, "Failed to open Sound Machine confirm window!!!", #confirmAction, #major))
      else
        tWndObj = getWindow(pSoundMachineConfirmWindowID)
        tWndObj.registerClient(me.getID())
        tWndObj.registerProcedure(#eventProcConfirm, me.getID(), #mouseUp)
        if not tWndObj.merge("habbo_decision_dialog.window") then
          return(tWndObj.close())
        end if
        tElem = tWndObj.getElement("habbo_decision_text_a")
        if tElem <> 0 then
          tText = getText("sound_machine_confirm_" & tAction)
          tElem.setText(tText)
        end if
        tElem = tWndObj.getElement("habbo_decision_text_b")
        if tElem <> 0 then
          tText = getText("sound_machine_confirm_" & tAction & "_long")
          tElem.setText(tText)
        end if
        tWndObj.center()
        tWndObj.moveBy(0, -30)
      end if
    end if
  end if
  return(tResult)
  exit
end

on hideConfirm(me)
  if windowExists(pSoundMachineConfirmWindowID) then
    return(removeWindow(pSoundMachineConfirmWindowID))
  else
    return(0)
  end if
  exit
end

on ShowAlert(me, ttype, tExtra)
  if voidp(tExtra) then
    tExtra = ""
  end if
  tText = getText("sound_machine_alert_" & ttype)
  executeMessage(#alert, [#Msg:tText & tExtra, #modal:1])
  exit
end

on showAlertWithCount(me, ttype, tCount)
  tText = getText("sound_machine_alert_" & ttype)
  tText = replaceChunks(tText, "%count%", tCount)
  executeMessage(#alert, [#Msg:tText, #modal:1])
  exit
end

on showSongSaved(me, tName)
  tText = getText("sound_machine_alert_song_saved")
  tText = replaceChunks(tText, "%name%", tName)
  executeMessage(#alert, [#Msg:tText, #modal:1])
  exit
end

on renderSoundSets(me)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tIndex = me.getComponent().getSoundSetLimit()
  repeat while tIndex >= 1
    if pSoundSetSampleMemberList.count >= tIndex then
      tNameBase = pSoundSetSampleMemberList.getAt(tIndex)
    else
      tNameBase = pSoundSetSampleMemberList.getAt(1)
    end if
    tElem = tWndObj.getElement("sound_set_samples_" & tIndex)
    if tElem <> 0 then
      tImg = me.getComponent().renderSoundSet(tIndex, pSoundSetSlotWd, pSoundSetSlotHt, pSoundSetSlotMarginWd, pSoundSetSlotMarginHt, tNameBase, pSoundSetSampleMemberName)
      if tImg <> 0 then
        tElem.feedImage(tImg)
      else
        tElem.feedImage(image(0, 0, 32))
      end if
    end if
    tIndex = 255 + tIndex
  end repeat
  return(1)
  exit
end

on renderSongList(me)
  tWndObj = getWindow(pPlaylistWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  if tPlaylistManager <> 0 then
    tElem = tWndObj.getElement("song_list")
    if tElem <> 0 then
      tImg = tPlaylistManager.renderSongList()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
    tElem = tWndObj.getElement("song_name_text")
    if tElem <> 0 then
      tElem.setText(tPlaylistManager.getSongName())
    end if
    tElem = tWndObj.getElement("song_length_text")
    if tElem <> 0 then
      tLength = tPlaylistManager.getSongLength()
      if tLength < 0 then
        tLength = 0
      end if
      tLength = tLength * me.getComponent().getTimeLineSlotLength() / 1000
      tStr = me.getComponent().getTimeString(tLength)
      tElem.setText(string(tStr))
    end if
  end if
  tElem = tWndObj.getElement("song_date_text")
  if tElem <> 0 then
  end if
  exit
end

on renderPlaylist(me)
  tWndObj = getWindow(pPlaylistWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  if tPlaylistManager <> 0 then
    tElem = tWndObj.getElement("playlist")
    if tElem <> 0 then
      tImg = tPlaylistManager.renderPlaylist()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
    tElem = tWndObj.getElement("playlist_arrows")
    if tElem <> 0 then
      tImg = tPlaylistManager.renderPlaylistArrows()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
  end if
  exit
end

on renderJukebox(me)
  me.renderJukeboxDiskList()
  me.renderJukeboxPlaylist()
  exit
end

on renderJukeboxPlaylist(me)
  tWndObj = getWindow(pJukeboxWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tPlaylistManager = me.getComponent().getPlaylistManager()
  tJukeBoxManager = me.getComponent().getJukeBoxManager()
  if tPlaylistManager <> 0 and tJukeBoxManager <> 0 then
    tSongName = tPlaylistManager.getPlaylistSongName(1)
    tAuthor = tPlaylistManager.getPlaylistSongAuthor(1)
    tPlayTime = tPlaylistManager.getPlayTime() / 10
    tSongLength = tPlaylistManager.getPlaylistSongLength(1) * me.getComponent().getTimeLineSlotLength() / 1000
    tSongStr = pJukeboxSongStr
    tAuthorStr = pJukeboxAuthorStr
    tLengthStr = pJukeboxLengthStr
    tRemainStr = pJukeboxRemainingStr
    tSongStr = replaceChunks(tSongStr, "%name%", tSongName)
    tAuthorStr = replaceChunks(tAuthorStr, "%author%", tAuthor)
    tLengthStr = replaceChunks(tLengthStr, "%time%", me.getComponent().getTimeStringBasic(tSongLength))
    tRemainStr = replaceChunks(tRemainStr, "%time%", me.getComponent().getTimeStringBasic(tSongLength - tPlayTime))
    if tPlaylistManager.getPlaylistCount() = 0 then
      tSongStr = ""
      tAuthorStr = ""
      tLengthStr = ""
      tRemainStr = ""
    end if
    tTextList = [tSongStr, tAuthorStr, tLengthStr, tRemainStr]
    tElemList = ["now_playing_name", "now_playing_author", "now_playing_length", "now_playing_remaining"]
    i = min(tTextList.count, tElemList.count)
    repeat while i >= 1
      tTextElem = tWndObj.getElement(tElemList.getAt(i))
      if tTextElem <> 0 then
        tTextElem.setText(tTextList.getAt(i))
      end if
      i = 255 + i
    end repeat
    tElem = tWndObj.getElement("next_up_panel")
    if tElem <> 0 then
      tSongList = []
      i = 2
      repeat while i <= tPlaylistManager.getPlaylistCount()
        tSongName = tPlaylistManager.getPlaylistSongName(i)
        tSongList.add(tSongName)
        i = 1 + i
      end repeat
      tImg = tJukeBoxManager.renderPlaylist(tSongList)
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
  end if
  return(1)
  exit
end

on renderJukeboxDiskList(me)
  tWndObj = getWindow(pJukeboxWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tJukeBoxManager = me.getComponent().getJukeBoxManager()
  if tJukeBoxManager <> 0 then
    tElem = tWndObj.getElement("disk_list")
    if tElem <> 0 then
      tImg = tJukeBoxManager.renderDiskList()
      if tImg <> 0 then
        tElem.feedImage(tImg)
      end if
    end if
  end if
  return(1)
  exit
end

on renderUserDiskList(me, tInitialRender)
  tWndObj = getWindow(pJukeboxDiskWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("disk_list")
  if tElem <> 0 then
    tImg = me.getComponent().renderUserDiskList(tInitialRender)
    if tImg <> 0 then
      tElem.feedImage(tImg)
    end if
  end if
  return(1)
  exit
end

on renderTimeLine(me)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("sound_timeline")
  if tElem <> 0 then
    tImg = me.getComponent().renderTimeLine(pTimeLineSlotWd, pTimeLineSlotHt, pTimeLineSlotMarginWd, pTimeLineSlotMarginHt, pSoundSetSampleMemberList, pSoundSetSampleMemberName, "sound_system_ui_timeline_bg2")
    if tImg <> 0 then
      tElem.feedImage(tImg)
    else
      tElem.feedImage(image(0, 0, 32))
    end if
  end if
  tElem = tWndObj.getElement("sound_timeline_stamps")
  if tElem <> 0 then
    tBarHt = 15
    tImg = me.getComponent().renderTimeLineBar(pTimeLineSlotWd, tBarHt, pTimeLineSlotMarginWd, pSoundSetSampleMemberList, pSoundSetSampleMemberName, "sound_system_ui_timeline_bg2")
    if tImg <> 0 then
      tElem.feedImage(tImg)
    else
      tElem.feedImage(image(0, 0, 32))
    end if
  end if
  me.updatePlayHead(1)
  tElem = tWndObj.getElement("sound_left_button")
  if tElem <> 0 then
    tVisible = me.getComponent().getScrollPossible(-1)
    tElem.setProperty(#visible, tVisible)
  end if
  tElem = tWndObj.getElement("sound_right_button")
  if tElem <> 0 then
    tVisible = me.getComponent().getScrollPossible(1)
    tElem.setProperty(#visible, tVisible)
  end if
  return(1)
  exit
end

on updateSoundSetTabs(me)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tHooveredTab = me.getComponent().getSoundSetHooveredTab()
  tIndex = me.getComponent().getSoundSetLimit()
  repeat while tIndex >= 1
    tVisible = 1
    tID = me.getComponent().getSoundSetID(tIndex)
    if tID <> 0 then
      tElem = tWndObj.getElement("sound_set_tab_text_" & tIndex)
      if tElem <> 0 then
        tElem.setProperty(#visible, 1)
        if tIndex <> tHooveredTab then
          tText = me.getComponent().getSoundSetName(tID)
        else
          tText = getText("sound_machine_eject")
        end if
        tElem.setText(tText)
      end if
    else
      tVisible = 0
    end if
    tElemList = ["sound_set_tab_" & tIndex, "sound_set_tab_text_" & tIndex]
    repeat while me <= undefined
      tElemName = getAt(undefined, undefined)
      tElem = tWndObj.getElement(tElemName)
      if tElem <> 0 then
        tElem.setProperty(#visible, tVisible)
      end if
    end repeat
    tIndex = 255 + tIndex
  end repeat
  return(1)
  exit
end

on updateSoundSetSlots(me)
  me.updateSoundSetTabs()
  me.renderSoundSets()
  me.renderTimeLine()
  exit
end

on updateSoundSetList(me)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tSetsReady = 1
  tIndex = me.getComponent().getSoundSetListPageSize()
  repeat while tIndex >= 1
    tID = me.getComponent().getSoundSetListID(tIndex)
    if tID <> 0 then
      tElem = tWndObj.getElement("set_list_text_" & tIndex)
      if tElem <> 0 then
        tText = me.getComponent().getSoundSetName(tID)
        tElem.setText(tText)
      end if
      tElem = tWndObj.getElement("set_list_icon_" & tIndex)
      if tElem <> 0 then
        if objectExists("Preview_renderer") then
          tSoundSetName = "sound_set_" & tID
          tdata = [#class:tSoundSetName, #type:#Active]
          executeMessage(#downloadObject, tdata)
          if tdata.getAt(#ready) = 0 then
            tSetsReady = 0
          end if
          tIcon = getObject("Preview_renderer").renderPreviewImage(void(), void(), void(), tSoundSetName)
          tIcon = tIcon.trimWhiteSpace()
        else
          tIcon = image(0, 0, 32)
        end if
        tWd = tElem.getProperty(#width)
        tHt = tElem.getProperty(#height)
        tCenteredImage = image(tWd, tHt, 32)
        tMatte = tIcon.createMatte()
        tXchange = tCenteredImage.width - tIcon.width / 2
        tYchange = tCenteredImage.height - tIcon.height / 2
        tRect1 = tIcon.rect + rect(tXchange, tYchange, tXchange, tYchange)
        tCenteredImage.copyPixels(tIcon, tRect1, tIcon.rect, [#maskImage:tMatte, #ink:41])
        tElem.feedImage(tCenteredImage)
      end if
    else
      tElem = tWndObj.getElement("set_list_text_" & tIndex)
      if tElem <> 0 then
        tElem.setText("")
      end if
      tElem = tWndObj.getElement("set_list_icon_" & tIndex)
      if tElem <> 0 then
        tIcon = image(0, 0, 32)
        tElem.feedImage(tIcon)
      end if
    end if
    tElem = tWndObj.getElement("set_list_text2_" & tIndex)
    if tElem <> 0 then
      tElem.setText("")
    end if
    tIndex = 255 + tIndex
  end repeat
  tElem = tWndObj.getElement("set_list_index")
  if tElem <> 0 then
    tText = me.getComponent().getSoundListPage() & "/" & me.getComponent().getSoundListPageCount()
    tElem.setText(tText)
  end if
  if not tSetsReady then
    if not timeoutExists(pSoundSetIconUpdateTimer) then
      createTimeout(pSoundSetIconUpdateTimer, 500, #updateSoundSetList, me.getID(), void(), 1)
    end if
  end if
  if me.getComponent().getSoundListPageCount() = 1 then
    tVisible = 0
  else
    tVisible = 1
  end if
  tElemList = ["set_list_left", "set_list_right"]
  repeat while me <= undefined
    tName = getAt(undefined, undefined)
    tElem = tWndObj.getElement(tName)
    if tElem <> 0 then
      tElem.setProperty(#visible, tVisible)
    end if
  end repeat
  exit
end

on updateSoundSetVisualizations(me)
  me.updateSoundSetList()
  me.updateSoundSetSlots()
  exit
end

on scrollTimeLine(me, tDX)
  if me.getComponent().scrollTimeLine(tDX) then
    me.renderTimeLine()
  end if
  exit
end

on scrollTimeLineTo(me, tX)
  if me.getComponent().scrollTimeLineTo(tX) then
    me.renderTimeLine()
  end if
  exit
end

on updatePlaylists(me)
  me.renderSongList()
  me.renderPlaylist()
  exit
end

on soundSetEvent(me, tSetID, tPos, tEvent)
  if tEvent <> #mouseLeave then
    if tPos.locH < 0 or tPos.locV < 0 then
      return(0)
    end if
    tX = 1 + tPos.locH / pSoundSetSlotWd + pSoundSetSlotMarginWd
    tY = 1 + tPos.locV / pSoundSetSlotHt + pSoundSetSlotMarginHt
  else
    tX = 1
    tY = 1
  end if
  if me.getComponent().soundSetEvent(tSetID, tX, tY, tEvent) then
    me.renderSoundSets()
    return(1)
  end if
  return(0)
  exit
end

on soundSetTabEvent(me, tSetID, tEvent)
  if me.getComponent().soundSetTabEvent(tSetID, tEvent) then
    me.updateSoundSetVisualizations()
  end if
  return(1)
  exit
end

on timeLineEvent(me, tPos, tRect, tEvent)
  if pPlayHeadDrag then
    return(1)
  end if
  tX = 1 + tPos.locH / pTimeLineSlotWd + pTimeLineSlotMarginWd
  tY = 1 + tPos.locV / pTimeLineSlotHt + pTimeLineSlotMarginHt
  if tEvent = #mouseLeave or tEvent = #mouseWithin then
    if tEvent = #mouseLeave then
      tX = -1
      tY = -1
    end if
    if tPos.locH < 0 or tPos.locV < 0 or tPos.locH > tRect.getAt(3) - tRect.getAt(1) or tPos.locV > tRect.getAt(4) - tRect.getAt(2) then
      tX = -1
      tY = -1
      tEvent = #mouseLeave
    end if
  end if
  if me.getComponent().timeLineEvent(tX, tY, tEvent) then
    me.renderTimeLine()
  end if
  return(1)
  exit
end

on updatePlayHead(me, tManualUpdate)
  if voidp(tManualUpdate) then
    tManualUpdate = 0
  end if
  tPlayTime = me.getComponent().getEditorPlayTime()
  tSlotLength = me.getComponent().getTimeLineSlotLength()
  tBehind = tPlayTime mod tSlotLength
  if tPlayTime then
    if not timeoutExists(pPlayHeadUpdateTimer) then
      createTimeout(pPlayHeadUpdateTimer, tSlotLength - tBehind, #updatePlayHead, me.getID(), void(), 1)
    end if
  end if
  tPos = me.getComponent().getPlayHeadPosition()
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if tPos > 0 then
    tPos = tPos - 1
    tElem = tWndObj.getElement("sound_timeline")
    if tElem <> 0 then
      tLocX = tElem.getProperty(#locX)
      tNameList = ["sound_timeline_playhead", "sound_timeline_playhead_drag"]
      repeat while me <= undefined
        tName = getAt(undefined, tManualUpdate)
        tElem = tWndObj.getElement(tName)
        if tElem <> 0 then
          tElem.setProperty(#visible, 1)
          tWd = tElem.getProperty(#width)
          tElem.setProperty(#locX, tLocX + pTimeLineSlotWd - tWd / 2 + pTimeLineSlotWd * tPos + pTimeLineSlotMarginWd * tPos)
        end if
      end repeat
    end if
    return(1)
  else
    tWndObj = getWindow(pSoundMachineWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tNameList = ["sound_timeline_playhead", "sound_timeline_playhead_drag"]
    repeat while me <= undefined
      tName = getAt(undefined, tManualUpdate)
      tElem = tWndObj.getElement(tName)
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
    end repeat
    if not tManualUpdate then
      me.scrollTimeLineTo(-tPos - 1)
    end if
  end if
  return(0)
  exit
end

on initPlayHeadEventAgent(me, tBoolean)
  tAgent = getObject(pPlayHeadEventAgentID)
  if tBoolean then
    tAgent.registerEvent(me, #mouseUp, #playHeadMouseUp)
    tAgent.registerEvent(me, #mouseWithin, #playHeadMouseWithin)
  else
    tAgent.unregisterEvent(#mouseUp)
    tAgent.unregisterEvent(#mouseWithin)
  end if
  pPlayHeadDrag = tBoolean
  exit
end

on playHeadMouseUp(me)
  me.initPlayHeadEventAgent(0)
  exit
end

on playHeadMouseWithin(me)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("sound_timeline")
  if tElem <> 0 then
    tRect = tElem.getProperty(#rect)
    tPos = point(the mouseH - tRect.getAt(1), the mouseV - tRect.getAt(2))
    tX = 1 + tPos.locH / pTimeLineSlotWd + pTimeLineSlotMarginWd
    if tPos < 0 then
      tX = 0
    end if
    if me.getComponent().movePlayHead(tX) then
      me.renderTimeLine()
    end if
  end if
  exit
end

on soundMachineSelected(me, tIsOn)
  if windowExists(pSoundMachineWindowID) then
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem = 0 then
      return(0)
    end if
  end if
  return(me.showSelectAction(tIsOn))
  exit
end

on updatePlayButton(me)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if me.getComponent().getEditorPlayTime() = 0 then
    tElem = tWndObj.getElement("sound_play_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
    end if
    tElem = tWndObj.getElement("sound_stop_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
  else
    tElem = tWndObj.getElement("sound_play_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
    tElem = tWndObj.getElement("sound_stop_button")
    if tElem <> 0 then
      tElem.setProperty(#visible, 1)
    end if
  end if
  exit
end

on getEditorWindowExists(me)
  if windowExists(pSoundMachineWindowID) then
    tWndObj = getWindow(pSoundMachineWindowID)
    tElem = tWndObj.getElement("sound_machine_onoff")
    if tElem = 0 then
      return(1)
    end if
  end if
  return(0)
  exit
end

on eventProcSoundMachine(me, tEvent, tSprID, tParam, tWndID)
  tWndObj = getWindow(pSoundMachineWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if offset("sound_set_samples_", tSprID) = 1 then
    tSoundSetID = value(tSprID.getProp(#char, "sound_set_samples_".length + 1, tSprID.length))
    tElem = tWndObj.getElement(tSprID)
    tRect = tElem.getProperty(#rect)
    me.soundSetEvent(tSoundSetID, point(the mouseH - tRect.getAt(1), the mouseV - tRect.getAt(2)), tEvent)
    if not me.getComponent().getHooveredSampleReady() then
      tElem.setProperty(#cursor, 4)
    else
      tElem.setProperty(#cursor, "cursor.finger")
    end if
  else
    if offset("sound_set_tab_text_", tSprID) = 1 then
      tSoundSetID = value(tSprID.getProp(#char, "sound_set_tab_text_".length + 1, tSprID.length))
      me.soundSetTabEvent(tSoundSetID, tEvent)
    else
      if tSprID = "sound_timeline" or tSprID = "sound_timeline_bg" then
        tElem = tWndObj.getElement("sound_timeline")
        if tElem <> 0 then
          tRect = tElem.getProperty(#rect)
          me.timeLineEvent(point(the mouseH - tRect.getAt(1), the mouseV - tRect.getAt(2)), tRect, tEvent)
        end if
      end if
    end if
  end if
  if offset("set_list_icon_", tSprID) = 1 then
    if tEvent = #mouseEnter then
      tIndex = value(tSprID.getProp(#char, "set_list_icon_".length + 1, tSprID.length))
      tElem = tWndObj.getElement("set_list_text2_" & tIndex)
      if tElem <> 0 then
        tText = getText("sound_machine_insert")
        tElem.setText(tText)
      end if
    else
      if tEvent = #mouseLeave then
        me.updateSoundSetVisualizations()
      end if
    end if
  end if
  if tEvent = #mouseDown then
    if tSprID = "sound_timeline_playhead_drag" then
      me.initPlayHeadEventAgent(1)
    end if
  end if
  if tEvent = #mouseUp then
    if tSprID = "set_list_left" then
      if me.getComponent().changeSetListPage(-1) then
        me.updateSoundSetList()
      end if
    else
      if tSprID = "set_list_right" then
        if me.getComponent().changeSetListPage(1) then
          me.updateSoundSetList()
        end if
      else
        if offset("set_list_icon_", tSprID) = 1 then
          if me.getComponent().getFreeSoundSetCount() > 0 then
            tIndex = value(tSprID.getProp(#char, "set_list_icon_".length + 1, tSprID.length))
            if me.getComponent().loadSoundSet(tIndex) then
              me.updateSoundSetVisualizations()
            end if
          else
            me.ShowAlert("machine_full")
          end if
        else
          if tSprID = "sound_play_button" then
            me.getComponent().playEditorSong()
            me.updatePlayHead()
          else
            if tSprID = "sound_stop_button" then
              me.getComponent().stopEditorSong()
            else
              if tSprID = "sound_save_button" then
                me.showSaveSong()
              else
                if tSprID = "sound_trash_button" then
                  me.confirmAction("clear", "")
                else
                  if tSprID = "sound_left_button" then
                    me.scrollTimeLine(-pTimeLineScrollStep)
                  else
                    if tSprID = "sound_right_button" then
                      me.scrollTimeLine(pTimeLineScrollStep)
                    else
                      if tSprID = "close" then
                        me.confirmAction("close", "")
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on eventProcSelectAction(me, tEvent, tSprID, tParam, tWndID)
  if tEvent = #mouseUp then
    if me = "close" then
      me.hideSelectAction()
      me.getComponent().closeSelectAction()
    else
      if me = "sound_machine_edit" then
        me.hideSelectAction()
        me.showPlaylist()
      else
        if me = "sound_machine_onoff" then
          me.getComponent().changeFurniState()
          me.hideSelectAction()
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on eventProcPlaylist(me, tEvent, tSprID, tParam, tWndID)
  if tEvent = #mouseUp then
    if me = "close" then
      me.confirmAction("close_list")
    else
      if me = "song_list" then
        tX = tParam.locH
        tY = tParam.locV
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.songListMouseClick(tX, tY) then
            me.renderSongList()
          end if
        end if
      else
        if me = "playlist" then
          tX = tParam.locH
          tY = tParam.locV
          tPlaylistManager = me.getComponent().getPlaylistManager()
          if tPlaylistManager <> 0 then
            if tPlaylistManager.playlistMouseClick(tX, tY) then
              me.renderPlaylist()
            end if
          end if
        else
          if me = "playlist_arrows" then
            tX = tParam.locH
            tY = tParam.locV
            tPlaylistManager = me.getComponent().getPlaylistManager()
            if tPlaylistManager <> 0 then
              if tPlaylistManager.playlistArrowMouseClick(tX, tY) then
                me.renderPlaylist()
              end if
            end if
          else
            if me = "sound_machine_add_button" then
              tPlaylistManager = me.getComponent().getPlaylistManager()
              if tPlaylistManager <> 0 then
                if tPlaylistManager.addPlaylistSong() then
                  me.renderPlaylist()
                end if
              end if
            else
              if me = "sound_machine_edit_button" then
                if me.getComponent().openEditorSong() then
                  me.showSoundMachine()
                end if
              else
                if me = "sound_machine_new_button" then
                  if me.getComponent().newEditorSong() then
                    me.showSoundMachine()
                  end if
                else
                  if me = "sound_machine_burn_button" then
                    me.confirmAction("burn", "")
                  else
                    if me = "sound_machine_delete_button" then
                      me.confirmAction("delete", "")
                    else
                      if me = "sound_machine_list_save_button" then
                        me.confirmAction("save_list", "")
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  else
    if tEvent = #mouseWithin then
      if me = "playlist" then
        tX = tParam.locH
        tY = tParam.locV
        tPlaylistManager = me.getComponent().getPlaylistManager()
        if tPlaylistManager <> 0 then
          if tPlaylistManager.playlistMouseOver(tX, tY) then
            me.renderPlaylist()
          end if
        end if
      end if
    else
      if tEvent = #mouseLeave then
        if me = "playlist" then
          tPlaylistManager = me.getComponent().getPlaylistManager()
          if tPlaylistManager <> 0 then
            if tPlaylistManager.playlistMouseOver(1, -1000) then
              me.renderPlaylist()
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on eventProcJukebox(me, tEvent, tSprID, tParam, tWndID)
  if tEvent = #mouseUp then
    if me = "close" then
      me.hideJukebox()
    else
      if me = "disk_list" then
        tJukeBoxManager = me.getComponent().getJukeBoxManager()
        if tJukeBoxManager <> 0 then
          tX = tParam.locH
          tY = tParam.locV
          if tJukeBoxManager.diskListMouseClick(tX, tY) then
            me.renderJukeboxDiskList()
          end if
        end if
      else
        if me = "jukebox_reset_button" then
          me.getComponent().resetJukebox()
        end if
      end if
    end if
  else
    if tEvent = #mouseWithin then
      if tSprID = "disk_list" then
        tJukeBoxManager = me.getComponent().getJukeBoxManager()
        if tJukeBoxManager <> 0 then
          tX = tParam.locH
          tY = tParam.locV
          if tJukeBoxManager.diskListMouseOver(tX, tY) then
            me.renderJukeboxDiskList()
          end if
        end if
      end if
    else
      if tEvent = #mouseLeave then
        if tSprID = "disk_list" then
          tJukeBoxManager = me.getComponent().getJukeBoxManager()
          if tJukeBoxManager <> 0 then
            if tJukeBoxManager.diskListMouseOver(-1, -1000) then
              me.renderJukeboxDiskList()
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on eventProcJukeboxDisk(me, tEvent, tSprID, tParam, tWndID)
  if tEvent = #mouseUp then
    if me <> "close" then
      if me = "jukebox_disk_cancel_button" then
        me.hideJukeboxDisk()
      else
        if me = "disk_list" then
          tX = tParam.locH
          tY = tParam.locV
          tPlaylistManager = me.getComponent().getPlaylistManager()
          if tPlaylistManager <> 0 then
            if tPlaylistManager.diskListMouseClick(tX, tY) then
              me.renderUserDiskList(0)
            end if
          end if
        else
          if me = "jukebox_disk_add_button" then
            me.getComponent().insertJukeboxDisk()
            me.hideJukeboxDisk()
          end if
        end if
      end if
      return(1)
      exit
    end if
  end if
end

on eventProcSaveSong(me, tEvent, tSprID, tParam, tWndID)
  tWndObj = getWindow(pSaveSongWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if tEvent = #mouseUp then
    if me = "close" then
      me.hideSaveSong()
    else
      if me = "sound_machine_song_save_button" then
        tElem = tWndObj.getElement("sound_machine_song_name")
        if tElem <> 0 then
          tSongName = tElem.getText()
          if tSongName = "" then
            me.ShowAlert("song_name_missing")
            return(0)
          end if
        end if
        me.confirmAction("save", tSongName)
      else
        if me = "sound_machine_song_cancel_button" then
          me.hideSaveSong()
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on eventProcConfirm(me, tEvent, tSprID, tParam, tWndID)
  if tEvent = #mouseUp then
    if me <> "close" then
      if me = "habbo_decision_cancel" then
        me.hideConfirm()
      else
        if me = "habbo_decision_ok" then
          me.getComponent().actionConfirmed()
          me.hideConfirm()
        end if
      end if
      return(1)
      exit
    end if
  end if
end