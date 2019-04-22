property pMusicIndexRoom, pMusicIndexEditor, pWriterID, pSongControllerID, pTimeLineUpdateTimer, pRoomActivityUpdateTimer, pExternalSongTimer, pTimelineInstance, pTimelineInstanceExternal, pJukeboxManager, pConnectionId, pEditFailure, pSoundMachineFurniID, pConfirmedAction, pConfirmedActionParameter, pSoundSetLimit, pSoundSetListPageSize, pSoundSetList, pSoundSetListPage, pSoundSetInventoryList, pHooveredSoundSetTab, pHooveredSampleReady, pTimeLineViewSlotCount, pDiskList, pEditorSongPlaying, pEditorSongStartTime, pEditorSongLength, pPlayHeadPosX, pTimeLineScrollX, pEditorOpen, pSoundMachineInstanceList, pSampleHorCount, pSampleVerCount, pSelectedSoundSet, pSelectedSoundSetSample, pHooveredSoundSet, pHooveredSoundSetSample, pTimeLineCursorX, pTimeLineCursorY, pSoundSetCount, pSoundSetInsertLocked, pMusicIndexTop, pExternalSongID, pEditorSongID

on construct me 
  pSoundMachineInstanceList = [:]
  pTimelineInstance = createObject("timeline instance", getClassVariable("soundmachine.song.timeline"))
  unregisterObject("timeline instance")
  pTimelineInstanceExternal = createObject("timeline instance external", getClassVariable("soundmachine.song.timeline"))
  unregisterObject("timeline instance external")
  pJukeboxManager = createObject("jukebox manager", getClassVariable("soundmachine.jukebox.manager"))
  unregisterObject("jukebox manager")
  pMusicIndexRoom = 1
  pMusicIndexEditor = pMusicIndexRoom + 10
  pMusicIndexTop = pMusicIndexEditor + 10
  pWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.plain")
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#B6DCDF")]
  createWriter(pWriterID, tMetrics)
  pTimeLineUpdateTimer = "sound_machine_timeline_timer"
  pRoomActivityUpdateTimer = "sound_machine_room_activity_timer"
  pExternalSongTimer = "sound_machine_external_song_timer"
  pDiskList = []
  pConnectionId = getVariableValue("connection.info.id", #info)
  pSampleHorCount = 3
  pSampleVerCount = 3
  pSoundSetLimit = 4
  pSoundSetListPageSize = 3
  pTimeLineViewSlotCount = 24
  pSongControllerID = "song controller"
  createObject(pSongControllerID, "Song Controller Class")
  me.reset(1)
  registerMessage(#sound_machine_selected, me.getID(), #soundMachineSelected)
  registerMessage(#jukebox_selected, me.getID(), #jukeBoxSelected)
  registerMessage(#sound_machine_set_state, me.getID(), #soundMachineSetState)
  registerMessage(#sound_machine_removed, me.getID(), #soundMachineRemoved)
  registerMessage(#sound_machine_created, me.getID(), #soundMachineCreated)
  registerMessage(#sound_machine_defined, me.getID(), #soundMachineDefined)
  registerMessage(#jukebox_defined, me.getID(), #jukeBoxDefined)
  registerMessage(#listen_song, me.getID(), #listenSong)
  registerMessage(#do_not_listen_song, me.getID(), #stopListenSong)
  registerMessage(#get_disk_data, me.getID(), #getDiskData)
  return(1)
end

on deconstruct me 
  if writerExists(pWriterID) then
    removeWriter(pWriterID)
  end if
  if timeoutExists(pTimeLineUpdateTimer) then
    removeTimeout(pTimeLineUpdateTimer)
  end if
  if timeoutExists(pRoomActivityUpdateTimer) then
    removeTimeout(pRoomActivityUpdateTimer)
  end if
  if timeoutExists(pExternalSongTimer) then
    removeTimeout(pExternalSongTimer)
  end if
  pTimelineInstance.deconstruct()
  pTimelineInstanceExternal.deconstruct()
  pJukeboxManager.deconstruct()
  unregisterMessage(#sound_machine_selected, me.getID())
  unregisterMessage(#jukebox_selected, me.getID())
  unregisterMessage(#sound_machine_set_state, me.getID())
  unregisterMessage(#sound_machine_removed, me.getID())
  unregisterMessage(#sound_machine_created, me.getID())
  unregisterMessage(#sound_machine_defined, me.getID())
  unregisterMessage(#jukebox_defined, me.getID())
  unregisterMessage(#listen_song, me.getID())
  unregisterMessage(#do_not_listen_song, me.getID())
  unregisterMessage(#get_disk_data, me.getID())
  return(1)
end

on reset me, tInitialReset 
  pEditFailure = 0
  pExternalSongID = void()
  pSoundSetCount = void()
  me.closeEdit(tInitialReset)
end

on resetJukebox me 
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("RESET_JUKEBOX"))
  end if
end

on initializeEdit me 
  me.clearTimeLine()
  me.roomActivityUpdate(1)
  pEditorOpen = 1
  pSoundSetCount = void()
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongData = pTimelineInstance.getSilentSongData()
    tSongController.playSong(pMusicIndexEditor - 1, tSongData, 1)
  end if
end

on closeEdit me, tInitialReset 
  me.stopEditorSong()
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.stopSong(pMusicIndexEditor - 1)
  end if
  pEditorSongID = 0
  pEditorOpen = 0
  pHooveredSampleReady = 1
  pSelectedSoundSet = 0
  pSelectedSoundSetSample = 0
  pHooveredSoundSet = 0
  pHooveredSoundSetSample = 0
  pHooveredSoundSetTab = 0
  pSoundSetListPage = 1
  pTimeLineCursorX = 0
  pTimeLineCursorY = 0
  pTimeLineScrollX = 0
  pPlayHeadPosX = 0
  pConfirmedAction = ""
  pConfirmedActionParameter = ""
  pSoundSetInsertLocked = 0
  pEditorSongLength = 0
  me.clearTimeLine()
  me.clearSoundSets()
  pSoundSetInventoryList = []
  if not tInitialReset and not pEditFailure then
    if getConnection(pConnectionId) <> 0 then
      return(getConnection(pConnectionId).send("SONG_EDIT_CLOSE"))
    end if
  end if
  return(1)
end

on closeSelectAction me 
  pSoundMachineFurniID = 0
end

on confirmAction me, tAction, tParameter 
  pConfirmedAction = tAction
  pConfirmedActionParameter = tParameter
  if tAction = "eject" then
    tReferences = me.checkSoundSetReferences(tParameter)
    if tReferences then
      return(1)
    end if
  else
    if tAction = "close" then
      if pTimelineInstance.getChanged() then
        return(1)
      end if
    else
      if tAction = "clear" then
        return(1)
      else
        if tAction = "save" then
          if tParameter = pTimelineInstance.getSongName() then
            return(1)
          end if
        else
          if tAction = "delete" then
            return(1)
          else
            if tAction = "burn" then
              return(1)
            else
              if tAction = "save_list" then
                return(1)
              else
                if tAction = "close_list" then
                  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
                  if tPlaylistManager = 0 then
                    return(0)
                  end if
                  if tPlaylistManager.getPlaylistChanged() then
                    return(1)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  me.actionConfirmed()
  return(0)
end

on actionConfirmed me 
  tRetVal = 0
  if pConfirmedAction = "eject" then
    if me.checkSoundSetReferences(pConfirmedActionParameter) then
      me.stopEditorSong()
    end if
    tRetVal = me.removeSoundSet(pConfirmedActionParameter)
    if tRetVal then
      me.getInterface().renderTimeLine()
    end if
  else
    if pConfirmedAction = "close" then
      if me.getInterface().hideSoundMachine() then
        me.getInterface().showPlaylist()
      end if
    else
      if pConfirmedAction = "clear" then
        me.clearTimeLine()
        me.stopEditorSong()
        me.getInterface().renderTimeLine()
      else
        if pConfirmedAction = "save" then
          me.saveEditorSong(pConfirmedActionParameter)
          me.getInterface().hideSaveSong()
        else
          if pConfirmedAction = "delete" then
            tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
            if tPlaylistManager = 0 then
              tRetVal = 0
            else
              if tPlaylistManager.deleteSong() then
                me.getInterface().renderSongList()
              end if
            end if
          else
            if pConfirmedAction = "burn" then
              tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
              if tPlaylistManager = 0 then
                tRetVal = 0
              else
                tPlaylistManager.burnSong()
              end if
            else
              if pConfirmedAction = "save_list" then
                tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
                if tPlaylistManager = 0 then
                  tRetVal = 0
                else
                  tPlaylistManager.savePlaylist()
                end if
              else
                if pConfirmedAction = "close_list" then
                  me.getInterface().hidePlaylist()
                  me.closeSelectAction()
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  pConfirmedAction = ""
  pConfirmedActionParameter = ""
  return(tRetVal)
end

on getSoundSetLimit me 
  return(pSoundSetLimit)
end

on getSoundSetListPageSize me 
  return(pSoundSetListPageSize)
end

on getSoundSetID me, tIndex 
  if tIndex < 1 or tIndex > pSoundSetList.count then
    return(0)
  end if
  if voidp(pSoundSetList.getAt(tIndex)) then
    return(0)
  end if
  return(pSoundSetList.getAt(tIndex).getAt(#id))
end

on getSoundSetListID me, tIndex 
  tIndex = tIndex + pSoundSetListPage - 1 * pSoundSetListPageSize
  if tIndex < 1 or tIndex > pSoundSetInventoryList.count then
    return(0)
  end if
  return(pSoundSetInventoryList.getAt(tIndex).getAt(#id))
end

on getSoundSetHooveredTab me 
  return(pHooveredSoundSetTab)
end

on getSoundListPage me 
  return(pSoundSetListPage)
end

on getSoundListPageCount me 
  return(1 + pSoundSetInventoryList.count() - 1 / pSoundSetListPageSize)
end

on getHooveredSampleReady me 
  return(pHooveredSampleReady)
end

on getTimeLineSlotLength me 
  return(pTimelineInstance.getSlotDuration())
end

on getTimeLineViewSlotCount me 
  return(pTimeLineViewSlotCount)
end

on getTimeString me, tSeconds 
  if tSeconds < 60 then
    tStr = getText("sound_machine_time_1")
  else
    tStr = getText("sound_machine_time_2")
  end if
  tMinStr = string(tSeconds / 60)
  if tSeconds mod 60 <> 0 then
    tSecStr = string(tSeconds mod 60)
    if tSecStr.length = 1 then
      tSecStr = "0" & tSecStr
    end if
  else
    tSecStr = "00"
  end if
  tStr = replaceChunks(tStr, "%min%", tMinStr)
  tStr = replaceChunks(tStr, "%sec%", tSecStr)
  return(tStr)
end

on getTimeStringBasic me, tSeconds 
  tMinStr = string(tSeconds / 60)
  if tSeconds mod 60 <> 0 then
    tSecStr = string(tSeconds mod 60)
    if tSecStr.length = 1 then
      tSecStr = "0" & tSecStr
    end if
  else
    tSecStr = "00"
  end if
  return(tMinStr & ":" & tSecStr)
end

on getSoundSetName me, tID 
  return(getText("furni_sound_set_" & tID & "_name"))
end

on getEditorSongName me 
  return(pTimelineInstance.getSongName())
end

on getCanSaveSong me 
  if pTimelineInstance.encodeTimeLineData() <> 0 then
    return(1)
  end if
  return(0)
end

on getCanInsertDisk me 
  if pDiskList.count > 0 then
    return(1)
  end if
  return(0)
end

on getEditorPlayTime me 
  if not pEditorSongPlaying then
    return(0)
  end if
  tTime = the milliSeconds + 30 - pEditorSongStartTime mod me.getTimeLineSlotLength() * pEditorSongLength
  if tTime = 0 then
    tTime = 1
  end if
  return(tTime)
end

on getPlayHeadPosition me 
  tPlayTime = me.getEditorPlayTime()
  tSlotLength = me.getTimeLineSlotLength()
  if pEditorSongPlaying then
    tPos = tPlayTime / tSlotLength + pPlayHeadPosX mod pEditorSongLength
  else
    tPos = tPlayTime / tSlotLength + pPlayHeadPosX mod pTimelineInstance.getSlotCount()
  end if
  tPos = 1 + tPos - pTimeLineScrollX
  if tPos < 1 or tPos > pTimeLineViewSlotCount then
    return(-tPos + pTimeLineScrollX)
  end if
  return(tPos)
end

on movePlayHead me, tPos 
  if pEditorSongPlaying then
    return(0)
  end if
  tPos = tPos - 1
  if tPos <> pPlayHeadPosX - pTimeLineScrollX then
    if tPos >= 0 and tPos < pTimeLineViewSlotCount then
      pPlayHeadPosX = tPos + pTimeLineScrollX
      return(1)
    else
      if tPos < 0 then
        me.scrollTimeLine(-1)
        if pPlayHeadPosX <> pTimeLineScrollX then
          pPlayHeadPosX = pTimeLineScrollX
          return(1)
        end if
      else
        me.scrollTimeLine(1)
        if pPlayHeadPosX <> pTimeLineScrollX + pTimeLineViewSlotCount - 1 then
          pPlayHeadPosX = pTimeLineScrollX + pTimeLineViewSlotCount - 1
          return(1)
        end if
      end if
    end if
  end if
  return(0)
end

on scrollTimeLine me, tDX 
  tScrollX = max(0, min(pTimeLineScrollX + tDX, pTimelineInstance.getSlotCount() - pTimeLineViewSlotCount))
  if tScrollX <> pTimeLineScrollX then
    pTimeLineScrollX = tScrollX
    return(1)
  end if
  return(0)
end

on scrollTimeLineTo me, tX 
  tScrollX = max(0, min(tX, pTimelineInstance.getSlotCount() - pTimeLineViewSlotCount))
  if tScrollX <> pTimeLineScrollX then
    pTimeLineScrollX = tScrollX
    return(1)
  end if
  return(0)
end

on getScrollPossible me, tDX 
  if tDX < 0 then
    if pTimeLineScrollX > 0 then
      return(1)
    end if
  end if
  if tDX > 0 then
    if pTimeLineScrollX < pTimelineInstance.getSlotCount() - pTimeLineViewSlotCount then
      return(1)
    end if
  end if
  return(0)
end

on soundMachineSelected me, tdata 
  tFurniID = tdata.getAt(#id)
  tFurniOn = tdata.getAt(#furniOn)
  tResult = me.getInterface().soundMachineSelected(tFurniOn)
  if tResult then
    pSoundMachineFurniID = tFurniID
  end if
end

on jukeBoxSelected me, tdata 
  tFurniID = tdata.getAt(#id)
  towner = tdata.getAt(#owner)
  tJukeBoxManager = me.getJukeBoxManager(tFurniID)
  if tJukeBoxManager <> 0 then
    tJukeBoxManager.setOwner(towner)
  end if
  tResult = me.getInterface().showJukebox()
  if tResult then
    pSoundMachineFurniID = tFurniID
  end if
end

on soundMachineSetState me, tdata 
  tFurniID = tdata.getAt(#id)
  tFurniOn = tdata.getAt(#furniOn)
  if pEditorOpen then
    me.soundMachineSelected([#id:tFurniID, #furniOn:tFurniOn])
  end if
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return(error(me, "Instance not found", #soundMachineSetState, #major))
  end if
  tSoundMachine.setState(tFurniOn)
  return(1)
end

on soundMachineRemoved me, tFurniID 
  tSoundMachine = pSoundMachineInstanceList.getaProp(tFurniID)
  if not voidp(tSoundMachine) then
    me.stopSong()
    removeObject("sound machine" && tFurniID)
    pSoundMachineInstanceList.deleteProp(tFurniID)
    pSoundMachineFurniID = 0
    me.getInterface().hideWindows()
  end if
end

on soundMachineCreated me, tFurniID, tLooping 
  if pSoundMachineInstanceList.count > 0 then
    return(0)
  end if
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    tSoundMachine = createObject("sound machine" && tFurniID, getClassVariable("soundmachine.instance"))
    if tSoundMachine = 0 then
      return(0)
    end if
    tSoundMachine.setLooping(tLooping)
    tSoundMachine.setPlayStackIndex(pMusicIndexRoom)
    pSoundMachineInstanceList.addProp(tFurniID, tSoundMachine)
  end if
  return(1)
end

on soundMachineDefined me, tFurniID 
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return(error(me, "Instance not found", #soundMachineDefined, #major))
  end if
  if not tSoundMachine.Initialize(tFurniID) then
    return(0)
  end if
  tPlaylistManager = tSoundMachine.getPlaylistManager()
  if tPlaylistManager = 0 then
    return(0)
  end if
  return(tPlaylistManager.getPlaylistData())
end

on jukeBoxDefined me, tFurniID 
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return(error(me, "Instance not found", #soundMachineDefined, #major))
  end if
  if not tSoundMachine.Initialize(tFurniID) then
    return(0)
  end if
  tPlaylistManager = tSoundMachine.getPlaylistManager()
  tJukeBoxManager = me.getJukeBoxManager()
  if tPlaylistManager = 0 or tJukeBoxManager = 0 then
    return(0)
  end if
  tPlaylistManager.getPlaylistData()
  tJukeBoxManager.getJukeboxDisks()
end

on changeFurniState me 
  tSoundMachine = me.getSoundMachine(pSoundMachineFurniID)
  if tSoundMachine = 0 then
    return(0)
  end if
  tNewState = not tSoundMachine.getState()
  tObj = getThread(#room).getComponent().getActiveObject(pSoundMachineFurniID)
  if tObj <> 0 then
    call(#changeState, [tObj], tNewState)
  end if
  pSoundMachineFurniID = 0
end

on getSoundMachine me, tFurniID 
  if pSoundMachineInstanceList.count = 0 then
    return(0)
  end if
  return(pSoundMachineInstanceList.getAt(1))
end

on getPlaylistManager me, tFurniID 
  tSoundMachine = me.getSoundMachine(tFurniID)
  if tSoundMachine = 0 then
    return(0)
  end if
  return(tSoundMachine.getPlaylistManager())
end

on getJukeBoxManager me, tFurniID 
  return(pJukeboxManager)
end

on soundSetEvent me, tSetID, tX, tY, tEvent 
  if tX >= 1 and tX <= pSampleHorCount and tY >= 1 and tY <= pSampleVerCount and tSetID >= 1 and tSetID <= pSoundSetLimit then
    if tEvent = #mouseDown then
      tSampleIndex = tX + tY - 1 * pSampleHorCount
      if not me.getSampleReady(tSampleIndex, tSetID) then
        return(0)
      end if
      if pSelectedSoundSet = tSetID and pSelectedSoundSetSample = tSampleIndex then
        pSelectedSoundSet = 0
        pSelectedSoundSetSample = 0
      else
        pSelectedSoundSet = tSetID
        pSelectedSoundSetSample = tSampleIndex
      end if
    else
      if tEvent = #mouseWithin then
        tSample = tX + tY - 1 * pSampleHorCount
        if pHooveredSoundSet = tSetID and pHooveredSoundSetSample = tSample then
          return(0)
        end if
        pHooveredSoundSet = tSetID
        pHooveredSoundSetSample = tX + tY - 1 * pSampleHorCount
        pHooveredSampleReady = me.getSampleReady(pHooveredSoundSetSample, pHooveredSoundSet)
        if pHooveredSampleReady then
          me.playSample(pHooveredSoundSetSample, pHooveredSoundSet)
        end if
      else
        if tEvent = #mouseLeave then
          pHooveredSoundSet = 0
          pHooveredSoundSetSample = 0
          pHooveredSampleReady = 1
          me.stopSample()
        end if
      end if
    end if
    return(1)
  end if
  return(0)
end

on soundSetTabEvent me, tSetID, tEvent 
  if tSetID >= 1 and tSetID <= pSoundSetLimit then
    if tEvent = #mouseDown then
      tConfirm = me.getInterface().confirmAction("eject", tSetID)
      return(not tConfirm)
    else
      if tEvent = #mouseWithin then
        if tSetID = pHooveredSoundSetTab then
          return(0)
        end if
        pHooveredSoundSetTab = tSetID
      else
        if tEvent = #mouseLeave then
          pHooveredSoundSetTab = 0
        end if
      end if
    end if
    return(1)
  end if
  return(0)
end

on timeLineEvent me, tX, tY, tEvent 
  tX = tX + pTimeLineScrollX
  if tEvent = #mouseDown then
    tInsert = me.insertSample(tX, tY)
    if tInsert then
      pTimeLineCursorX = 0
      pTimeLineCursorY = 0
      return(1)
    else
      return(me.removeSample(tX, tY))
    end if
  else
    if tEvent = #mouseWithin then
      if tX <> pTimeLineCursorX or tY <> pTimeLineCursorY then
        tID = 0
        tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
        if tSample <> 0 then
          tID = tSample.getAt(#id)
        end if
        tInsert = me.getCanInsertSample(tX, tY, tID)
        if tInsert and pTimeLineCursorX <> tX or pTimeLineCursorY <> tY then
          pTimeLineCursorX = tX
          pTimeLineCursorY = tY
          return(1)
        else
          if pTimeLineCursorX <> 0 and pTimeLineCursorY <> 0 then
            pTimeLineCursorX = 0
            pTimeLineCursorY = 0
            return(1)
          end if
        end if
      end if
    else
      if tEvent = #mouseLeave then
        if tX < 1 or tX > pTimelineInstance.getSlotCount() or tY < 1 or tY > pTimelineInstance.getChannelCount() then
          pTimeLineCursorX = 0
          pTimeLineCursorY = 0
          return(1)
        end if
      end if
    end if
  end if
  return(0)
end

on renderUserDiskList me, tInitialRender 
  tPlaylistManager = me.getPlaylistManager()
  if tPlaylistManager <> 0 then
    if tInitialRender then
      tPlaylistManager.setDiskList(pDiskList.duplicate())
    end if
    return(tPlaylistManager.renderDiskList())
  end if
  return(0)
end

on renderSoundSet me, tIndex, tWd, tHt, tMarginWd, tMarginHt, tNameBase, tSampleNameBase 
  if tIndex < 0 or tIndex > pSoundSetList.count then
    return(0)
  end if
  if voidp(pSoundSetList.getAt(tIndex)) then
    return(0)
  end if
  tImg = image(pSampleHorCount * tWd + tMarginWd * pSampleHorCount - 1, pSampleVerCount * tHt + tMarginHt * pSampleVerCount - 1, 32)
  tSampleList = pSoundSetList.getAt(tIndex).getAt(#samples)
  if voidp(tSampleList) then
    return(0)
  end if
  tSample = 1
  repeat while tSample <= tSampleList.count
    tX = 1 + tSample - 1 mod pSampleHorCount
    tY = 1 + tSample - 1 / pSampleVerCount
    if tY > pSampleVerCount then
    else
      ttype = 1
      if tIndex = pSelectedSoundSet and tSample = pSelectedSoundSetSample then
        ttype = 3
      else
        if tIndex = pHooveredSoundSet and tSample = pHooveredSoundSetSample then
          ttype = 2
        end if
      end if
      tName = [tNameBase & ttype, tSampleNameBase & tSample]
      tPart = 1
      repeat while tPart <= tName.count
        tmember = getMember(tName.getAt(tPart))
        if tmember <> 0 then
          tSourceImg = tmember.image
          tRect = tSourceImg.rect
          tImgWd = tRect.getAt(3) - tRect.getAt(1)
          tImgHt = tRect.getAt(4) - tRect.getAt(2)
          tRect.setAt(1, tRect.getAt(1) + tX - 1 * tWd + tMarginWd + tWd - tImgWd / 2)
          tRect.setAt(2, tRect.getAt(2) + tY - 1 * tHt + tMarginHt + tHt - tImgHt / 2)
          tRect.setAt(3, tRect.getAt(3) + tX - 1 * tWd + tMarginWd + tWd - tImgWd / 2)
          tRect.setAt(4, tRect.getAt(4) + tY - 1 * tHt + tMarginHt + tHt - tImgHt / 2)
          tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink:8, #maskImage:tSourceImg.createMatte()])
        end if
        tPart = 1 + tPart
      end repeat
      tSample = 1 + tSample
    end if
  end repeat
  return(tImg)
end

on renderTimeLine me, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tBgImage 
  tImg = image(pTimeLineViewSlotCount * tWd + tMarginWd * pTimeLineViewSlotCount - 1, pTimelineInstance.getChannelCount() * tHt + tMarginHt - tMarginHt, 32)
  tmember = getMember(tBgImage)
  if tmember <> 0 then
    tmember.image.copyPixels(tImg.rect, tmember, image.rect)
  end if
  tTimeLineData = pTimelineInstance.getTimeLineData()
  tChannel = 1
  repeat while tChannel <= tTimeLineData.count
    tChannelData = tTimeLineData.getAt(tChannel)
    tSlot = max(1, pTimeLineScrollX - 10)
    repeat while tSlot <= min(pTimeLineScrollX + pTimeLineViewSlotCount, tChannelData.count)
      if not voidp(tChannelData.getAt(tSlot)) then
        tSampleNumber = tChannelData.getAt(tSlot)
        if not me.renderSample(tSampleNumber, tSlot - pTimeLineScrollX, tChannel, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg) then
        end if
      end if
      tSlot = 1 + tSlot
    end repeat
    tChannel = 1 + tChannel
  end repeat
  if pTimeLineCursorX <> 0 and pTimeLineCursorY <> 0 then
    tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
    if tSample <> 0 then
      tCursorX = pTimeLineCursorX - pTimeLineScrollX
      tCursorY = pTimeLineCursorY
      if not me.renderSample(tSample.getAt(#id), tCursorX, tCursorY, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg, 50) then
      end if
    end if
  end if
  return(tImg)
end

on renderSample me, tSampleNumber, tSlot, tChannel, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg, tBlend 
  tLength = pTimelineInstance.getSampleLength(tSampleNumber)
  if tSampleNumber < 0 then
    tBlend = 20
    tSampleNumber = -tSampleNumber
  end if
  tSampleSet = me.getSampleSetNumber(tSampleNumber)
  tSampleIndex = me.getSampleIndex(tSampleNumber)
  tSample = me.getSample(tSampleIndex, tSampleSet)
  if tSample = 0 then
    return(0)
  end if
  if voidp(tBlend) then
    tBlend = 100
  end if
  if tSampleSet < 1 or tSampleSet > tNameBaseList.count then
    return(0)
  end if
  tNameBase = tNameBaseList.getAt(tSampleSet)
  tName = [tNameBase & "1", tSampleNameBase & tSampleIndex]
  tstart = max(1, tSlot)
  tEnd = min(pTimeLineViewSlotCount, tSlot + tLength - 1)
  tPart = 1
  repeat while tPart <= tName.count
    tmember = getMember(tName.getAt(tPart))
    if tmember <> 0 then
      tSourceImg = tmember.image
      tRectOrig = tSourceImg.rect
      tImgWd = tRectOrig.getAt(3) - tRectOrig.getAt(1)
      tImgHt = tRectOrig.getAt(4) - tRectOrig.getAt(2)
      tRectOrig.setAt(2, tRectOrig.getAt(2) + tChannel - 1 * tHt + tMarginHt + tHt - tImgHt / 2)
      tRectOrig.setAt(4, tRectOrig.getAt(4) + tChannel - 1 * tHt + tMarginHt + tHt - tImgHt / 2)
      tProps = [#ink:8, #maskImage:tSourceImg.createMatte(), #blend:tBlend]
      tPos = tstart
      repeat while tPos <= tEnd
        tRect = tRectOrig.duplicate()
        tRect.setAt(1, tRect.getAt(1) + tPos - 1 * tWd + tMarginWd + tWd - tImgWd / 2)
        tRect.setAt(3, tRect.getAt(3) + tPos - 1 * tWd + tMarginWd + tWd - tImgWd / 2)
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, tProps)
        tPos = 1 + tPos
      end repeat
      exit repeat
    end if
    return(0)
    tPart = 1 + tPart
  end repeat
  tName = tNameBase & "sp"
  tmember = getMember(tName)
  if tmember <> 0 then
    tSourceImg = tmember.image
    tRectOrig = tSourceImg.rect
    tImgWd = tRectOrig.getAt(3) - tRectOrig.getAt(1)
    tImgHt = tRectOrig.getAt(4) - tRectOrig.getAt(2)
    tRectOrig.setAt(2, tRectOrig.getAt(2) + tChannel - 1 * tHt + tMarginHt + tHt - tImgHt / 2)
    tRectOrig.setAt(4, tRectOrig.getAt(4) + tChannel - 1 * tHt + tMarginHt + tHt - tImgHt / 2)
    tProps = [#ink:8, #maskImage:tSourceImg.createMatte(), #blend:tBlend]
    tPos = max(0, tSlot)
    repeat while tPos <= min(pTimeLineViewSlotCount, tSlot + tLength - 2)
      tRect = tRectOrig.duplicate()
      tRect.setAt(1, tRect.getAt(1) + tPos * tWd + tMarginWd - tImgWd / 2)
      tRect.setAt(3, tRect.getAt(3) + tPos * tWd + tMarginWd - tImgWd / 2)
      tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, tProps)
      tPos = 1 + tPos
    end repeat
    exit repeat
  end if
  return(0)
  return(1)
end

on renderTimeLineBar me, tWd, tHt, tMarginWd, tNameBaseList, tSampleNameBase, tBgImage 
  tImg = image(pTimeLineViewSlotCount * tWd + tMarginWd * pTimeLineViewSlotCount - 1, tHt, 32)
  tImgHt = tImg.getProp(#rect, 4) - tImg.getProp(#rect, 2)
  tWriterObj = getWriter(pWriterID)
  if tWriterObj = 0 then
    return(tImg)
  end if
  tstart = max(0, pTimeLineScrollX + 1)
  tEnd = min(pTimeLineScrollX + pTimeLineViewSlotCount - 1, pTimelineInstance.getSlotCount())
  tTimeLineSlotLength = me.getTimeLineSlotLength()
  tSlot = tstart
  repeat while tSlot <= tEnd
    if tSlot * tTimeLineSlotLength mod 10000 = 0 then
      tOffset = rect(tWd + tMarginWd * tSlot - pTimeLineScrollX, 0, tWd + tMarginWd * tSlot - pTimeLineScrollX, 0)
      tSeconds = tSlot * tTimeLineSlotLength / 1000
      tStr = me.getTimeString(tSeconds)
      tStampImg = tWriterObj.render(tStr).duplicate()
      tStampImgTrimmed = image(tStampImg.getProp(#rect, 3), tStampImg.getProp(#rect, 4), 32)
      tStampImgTrimmed.copyPixels(tStampImg, tStampImg.rect, tStampImg.rect, [#ink:8, #maskImage:tStampImg.createMatte()])
      tStampImg = tStampImgTrimmed.trimWhiteSpace()
      tOffset.setAt(1, tOffset.getAt(1) - tStampImg.getProp(#rect, 3) - tStampImg.getProp(#rect, 1) / 2)
      tOffset.setAt(3, tOffset.getAt(1))
      tOffset.setAt(2, tImgHt - tStampImg.getProp(#rect, 4) - tStampImg.getProp(#rect, 2) / 2)
      tOffset.setAt(4, tOffset.getAt(2))
      tImg.copyPixels(tStampImg, tStampImg.rect + tOffset, tStampImg.rect, [#ink:8, #maskImage:tStampImg.createMatte()])
    end if
    tSlot = 1 + tSlot
  end repeat
  return(tImg)
end

on parseSongList me, tMsg 
  tID = 1
  tPlaylistManager = me.getPlaylistManager(tID)
  if tPlaylistManager = 0 then
    return(0)
  end if
  tRetVal = tPlaylistManager.parseSongList(tMsg)
  me.getInterface().updatePlaylists()
  return(tRetVal)
end

on parsePlaylist me, tMsg 
  me.stopSong()
  tID = 1
  tSoundMachine = me.getSoundMachine(tID)
  if tSoundMachine = 0 then
    return(0)
  end if
  tRetVal = tSoundMachine.parsePlaylist(tMsg)
  me.getInterface().updatePlaylists()
  return(tRetVal)
end

on getUserDisks me 
  pDiskList = []
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("GET_USER_SONG_DISCS"))
  end if
  return(0)
end

on parseUserDisks me, tMsg 
  pDiskList = []
  tCount = tMsg.GetIntFrom()
  i = 1
  repeat while i <= tCount
    tID = tMsg.GetIntFrom()
    tName = tMsg.GetStrFrom()
    tName = convertSpecialChars(tName, 0)
    tDisk = [#id:tID, #name:tName]
    pDiskList.add(tDisk)
    i = 1 + i
  end repeat
  return(1)
end

on parseJukeboxDisks me, tMsg 
  tID = 1
  tJukeBoxManager = me.getJukeBoxManager(tID)
  if tJukeBoxManager = 0 then
    return(0)
  end if
  tRetVal = tJukeBoxManager.parseDiskList(tMsg)
  me.getInterface().renderJukeboxDiskList()
  return(tRetVal)
end

on insertPlaylistSong me, tSongID, tLength, tName, tAuthor 
  tID = 1
  tSoundMachine = me.getSoundMachine(tID)
  if tSoundMachine = 0 then
    return(0)
  end if
  return(tSoundMachine.insertPlaylistSong(tSongID, tLength, tName, tAuthor))
end

on insertJukeboxDisk me 
  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
  if tPlaylistManager = 0 then
    return(0)
  end if
  tIndex = tPlaylistManager.getSelectedDiskIndex()
  if tIndex < 1 or tIndex > pDiskList.count then
    return(0)
  end if
  tDiskID = pDiskList.getAt(tIndex).getAt(#id)
  pDiskList.deleteAt(tIndex)
  tID = 1
  tJukeBoxManager = me.getJukeBoxManager(tID)
  if tJukeBoxManager = 0 then
    return(0)
  end if
  return(tJukeBoxManager.insertDisk(tDiskID))
end

on handleMissingPackages me, tList 
  pEditFailure = 1
  me.getInterface().hideSoundMachine()
  pEditFailure = 0
  tStr = "\r"
  i = 1
  repeat while i <= tList.count
    tStr = tStr & "\r" && me.getSoundSetName(tList.getAt(i))
    i = 1 + i
  end repeat
  me.getInterface().ShowAlert("missing_packages", tStr)
end

on handleListFull me, tCount, tListType 
  if tListType = "songlist" then
    tID = pTimelineInstance.getSongID()
    if tID = 0 then
      pEditFailure = 1
      me.getInterface().hideSoundMachine()
      pEditFailure = 0
    end if
    me.getInterface().showAlertWithCount("no_more_songs", tCount)
  else
    if tListType = "playlist" then
      me.getInterface().showAlertWithCount("playlist_full", tCount)
    end if
  end if
end

on handleInvalidSongName me 
  me.getInterface().ShowAlert("invalid_song_name")
end

on handleSongLocked me 
  me.getInterface().ShowAlert("song_locked")
end

on handleJukeBoxPlaylistFull me 
  me.getInterface().ShowAlert("jukebox_list_full")
end

on handleInvalidSongLength me 
  me.getInterface().ShowAlert("invalid_song_length")
end

on updateSetList me, tList 
  pSoundSetInventoryList = []
  repeat while tList <= undefined
    tID = getAt(undefined, tList)
    tItem = [#id:tID]
    pSoundSetInventoryList.add(tItem)
  end repeat
  me.changeSetListPage(0)
  me.getInterface().updateSoundSetList()
  if not voidp(pSoundSetCount) then
    pSoundSetCount = pSoundSetCount + tList.count
    if pSoundSetCount = 0 then
      me.getInterface().ShowAlert("no_sound_sets")
    end if
  else
    pSoundSetCount = tList.count
  end if
end

on changeSetListPage me, tChange 
  tIndex = pSoundSetListPage + tChange
  if tIndex < 1 then
    tIndex = me.getSoundListPageCount()
  else
    if tIndex > me.getSoundListPageCount() then
      tIndex = 1
    end if
  end if
  if tIndex = pSoundSetListPage then
    return(0)
  end if
  pSoundSetListPage = tIndex
  return(1)
end

on loadSoundSet me, tIndex 
  tIndex = tIndex + pSoundSetListPage - 1 * pSoundSetListPageSize
  if tIndex < 1 or tIndex > pSoundSetInventoryList.count then
    return(0)
  end if
  if pSoundSetInsertLocked then
    return(0)
  end if
  tFreeSlot = 0
  i = 1
  repeat while i <= pSoundSetList.count
    if pSoundSetList.getAt(i) = void() then
      tFreeSlot = i
    else
      i = 1 + i
    end if
  end repeat
  if tFreeSlot = 0 then
    return(0)
  end if
  tSoundSet = pSoundSetInventoryList.getAt(tIndex)
  tSetID = tSoundSet.getAt(#id)
  if getConnection(pConnectionId) <> 0 then
    pSoundSetInventoryList.deleteAt(tIndex)
    pSoundSetInsertLocked = 1
    return(getConnection(pConnectionId).send("INSERT_SOUND_PACKAGE", [#integer:tSetID, #integer:tFreeSlot]))
  else
    return(0)
  end if
end

on removeSoundSet me, tIndex 
  tID = me.getSoundSetID(tIndex)
  if tID = 0 then
    return(0)
  end if
  pTimelineInstance.soundSetRemoved(tID)
  if pSelectedSoundSet = tIndex then
    pSelectedSoundSet = 0
    pSelectedSoundSetSample = 0
  end if
  if getConnection(pConnectionId) <> 0 then
    pSoundSetList.setAt(tIndex, void())
    return(getConnection(pConnectionId).send("EJECT_SOUND_PACKAGE", [#integer:tIndex]))
  else
    return(1)
  end if
end

on updateSoundSet me, tIndex, tID, tSampleList 
  if tIndex >= 1 and tIndex <= pSoundSetLimit then
    tSoundSet = [#id:tID]
    tMachineSampleList = []
    repeat while tSampleList <= tID
      tSampleID = getAt(tID, tIndex)
      tMachineSampleList.add([#id:tSampleID, #length:0])
    end repeat
    tSoundSet.setAt(#samples, tMachineSampleList)
    pSoundSetList.setAt(tIndex, tSoundSet)
    tSampleIndex = 1
    repeat while tSampleIndex <= tMachineSampleList.count
      me.getSampleReady(tSampleIndex, tIndex)
      tSampleIndex = 1 + tSampleIndex
    end repeat
    me.getInterface().updateSoundSetSlots()
  end if
end

on clearSoundSets me 
  pSoundSetList = []
  i = 1
  repeat while i <= pSoundSetLimit
    pSoundSetList.setAt(i, void())
    i = 1 + i
  end repeat
  me.getInterface().updateSoundSetSlots()
end

on setSoundSetCount me, tCount 
  if not voidp(pSoundSetCount) then
    pSoundSetCount = pSoundSetCount + tCount
    if pSoundSetCount = 0 then
      me.getInterface().ShowAlert("no_sound_sets")
    end if
  else
    pSoundSetCount = tCount
  end if
end

on getFreeSoundSetCount me 
  tCount = 0
  i = 1
  repeat while i <= pSoundSetList.count
    if pSoundSetList.getAt(i) = void() then
      tCount = tCount + 1
    end if
    i = 1 + i
  end repeat
  return(tCount)
end

on removeSoundSetInsertLock me 
  pSoundSetInsertLocked = 0
end

on resolveSamplePosition me, tSampleID 
  i = 1
  repeat while i <= pSoundSetList.count
    tSoundSet = pSoundSetList.getAt(i)
    if not voidp(tSoundSet) then
      tSampleList = tSoundSet.getAt(#samples)
      j = 1
      repeat while j <= tSampleList.count
        tSample = tSampleList.getAt(j)
        if tSample.getAt(#id) = tSampleID then
          return([#sample:j, #soundset:i])
        end if
        j = 1 + j
      end repeat
    end if
    i = 1 + i
  end repeat
  return(0)
end

on insertSample me, tSlot, tChannel 
  tID = 0
  tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
  if tSample <> 0 then
    tID = tSample.getAt(#id)
  else
    return(0)
  end if
  if pTimelineInstance.insertSample(tSlot, tChannel, tID) then
    me.stopEditorSong()
    return(1)
  end if
  return(0)
end

on removeSample me, tSlot, tChannel 
  if pTimelineInstance.removeSample(tSlot, tChannel) then
    me.stopEditorSong()
  end if
end

on checkSoundSetReferences me, tIndex 
  tID = me.getSoundSetID(tIndex)
  if tID = 0 then
    return(0)
  end if
  tID = pSoundSetList.getAt(tIndex).getAt(#id)
  return(pTimelineInstance.checkSoundSetReferences(tID))
end

on getCanInsertSample me, tX, tY, tID 
  return(pTimelineInstance.getCanInsertSample(tX, tY, tID))
end

on clearTimeLine me 
  pTimelineInstance.clearTimeLine()
  pPlayHeadPosX = 0
end

on updateEditorSong me, tID, tName 
  if not voidp(tID) then
    pTimelineInstance.updateSongID(tID)
  end if
  if not voidp(tName) then
    pTimelineInstance.updateSongName(tName)
  end if
  tName = pTimelineInstance.getSongName()
  pTimelineInstance.resetChanged()
  me.getInterface().showSongSaved(tName)
end

on playSample me, tSampleIndex, tSoundSet 
  if pEditorSongPlaying then
    return(1)
  end if
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    tReady = 1
    tSampleName = pTimelineInstance.getSampleName(tSample.getAt(#id))
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tReady = tSongController.startSamplePreview(tSampleName)
    end if
    return(tReady)
  end if
  return(0)
end

on stopSample me 
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    return(tSongController.stopSamplePreview())
  end if
  return(0)
end

on getSampleReady me, tSampleIndex, tSoundSet 
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    if tSample.getAt(#length) = 0 then
      tReady = 0
      tLength = pTimelineInstance.getSampleLength(tSample.getAt(#id))
      if tLength then
        tSample.setAt(#length, tLength)
        tReady = 1
      end if
      return(tReady)
    else
      return(1)
    end if
  end if
  return(0)
end

on getSample me, tSampleIndex, tSampleSet 
  if tSampleSet >= 1 and tSampleSet <= pSoundSetLimit then
    if not voidp(pSoundSetList.getAt(tSampleSet)) then
      if pSoundSetList.getAt(tSampleSet).getAt(#samples).count >= tSampleIndex then
        return(pSoundSetList.getAt(tSampleSet).getAt(#samples).getAt(tSampleIndex))
      end if
    end if
  end if
  return(0)
end

on getSampleSetNumber me, tSampleID 
  tSamplePos = me.resolveSamplePosition(tSampleID)
  if tSamplePos <> 0 then
    return(tSamplePos.getAt(#soundset))
  end if
  return(0)
end

on getSampleIndex me, tSampleID 
  tSamplePos = me.resolveSamplePosition(tSampleID)
  if tSamplePos <> 0 then
    return(tSamplePos.getAt(#sample))
  end if
  return(0)
end

on playEditorSong me 
  if pEditorOpen then
    if pEditorSongPlaying then
      return(1)
    end if
    pEditorSongLength = pTimelineInstance.resolveSongLength()
    if pEditorSongLength = 0 then
      return(0)
    end if
    if pPlayHeadPosX > pEditorSongLength then
      pPlayHeadPosX = 0
      me.getInterface().updatePlayHead()
    end if
    tPosition = me.getTimeLineSlotLength() * pPlayHeadPosX
    tSongData = pTimelineInstance.getSongData()
    if tSongData = 0 then
      return(0)
    end if
    tReady = 0
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tSongData.setAt(#offset, tPosition)
      tReady = tSongController.playSong(pMusicIndexEditor, tSongData, 1)
      if tReady then
        pEditorSongPlaying = 1
        pEditorSongStartTime = the milliSeconds
        me.getInterface().updatePlayButton()
      end if
    end if
    return(tReady)
  end if
  return(0)
end

on stopSong me 
  tID = 1
  tSoundMachine = me.getSoundMachine(tID)
  if tSoundMachine = 0 then
    return(0)
  end if
  tSoundMachine.stopSong()
  return(1)
end

on stopEditorSong me 
  if pEditorSongPlaying then
    tPlayTime = me.getEditorPlayTime()
    tSlotLength = me.getTimeLineSlotLength()
    tPos = tPlayTime / tSlotLength + pPlayHeadPosX mod pEditorSongLength
    pPlayHeadPosX = tPos
    pEditorSongPlaying = 0
    pEditorSongLength = 0
    me.getInterface().updatePlayHead()
    me.getInterface().updatePlayButton()
    pEditorSongStartTime = 0
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tSongController.stopSong(pMusicIndexEditor)
    end if
  end if
end

on stopListenSong me 
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.stopSong(pMusicIndexTop)
  end if
end

on listenSong me, tSongID 
  if tSongID = pExternalSongID then
  end if
  pExternalSongID = tSongID
  if getConnection(pConnectionId) <> 0 then
    return(getConnection(pConnectionId).send("GET_SONG_INFO", [#integer:tSongID]))
  end if
  return(0)
end

on parseSongData me, tdata, tSongID, tSongName 
  tID = 1
  tSoundMachine = me.getSoundMachine(tID)
  if tSoundMachine <> 0 then
    tSoundMachine.parseSongData(tdata, tSongID, tSongName)
    tSoundMachine.processSongData()
  end if
  if pEditorSongID = tSongID then
    pTimelineInstance.parseSongData(tdata, tSongID, tSongName)
    me.processEditorSongData()
  end if
  if pExternalSongID = tSongID then
    pExternalSongID = void()
    pTimelineInstanceExternal.parseSongData(tdata, tSongID, tSongName)
    me.processExternalSongData()
  end if
end

on openEditorSong me 
  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
  if tPlaylistManager = 0 then
    return(0)
  end if
  tRetVal = tPlaylistManager.editSong()
  if tRetVal then
    pEditorSongID = tPlaylistManager.getEditorSongID()
    pTimelineInstance.reset(1)
  end if
  return(tRetVal)
end

on newEditorSong me 
  tPlaylistManager = me.getPlaylistManager(pSoundMachineFurniID)
  if tPlaylistManager = 0 then
    return(0)
  end if
  tRetVal = tPlaylistManager.newSong()
  if tRetVal then
    pTimelineInstance.reset(0)
  end if
  return(tRetVal)
end

on saveEditorSong me, tNewName 
  tNewSong = pTimelineInstance.encodeTimeLineData()
  if tNewSong <> 0 then
    if getConnection(pConnectionId) <> 0 then
      tID = pTimelineInstance.getSongID()
      tName = tNewName
      tName = convertSpecialChars(tName, 1)
      if tID = 0 then
        return(getConnection(pConnectionId).send("SAVE_SONG_NEW", [#string:tName, #string:tNewSong]))
      else
        return(getConnection(pConnectionId).send("SAVE_SONG_EDIT", [#integer:tID, #string:tName, #string:tNewSong]))
      end if
    else
      return(1)
    end if
  else
    return(0)
  end if
end

on processEditorSongData me 
  tReady = 1
  if not pTimelineInstance.processSongData() then
    tReady = 0
  end if
  if not tReady then
    if not timeoutExists(pTimeLineUpdateTimer) then
      createTimeout(pTimeLineUpdateTimer, 500, #processEditorSongData, me.getID(), void(), 1)
    end if
  end if
  if pEditorOpen then
    me.getInterface().renderTimeLine()
  end if
end

on processExternalSongData me 
  tReady = 1
  if not pTimelineInstanceExternal.processSongData() then
    tReady = 0
  end if
  if not tReady then
    if not timeoutExists(pExternalSongTimer) then
      createTimeout(pExternalSongTimer, 500, #processExternalSongData, me.getID(), void(), 1)
    end if
  else
    tSongData = pTimelineInstanceExternal.getSongData()
    if tSongData = 0 then
      return(0)
    end if
    tReady = 0
    tSongController = getObject(pSongControllerID)
    if tSongController <> 0 then
      tSongData.setAt(#offset, 0)
      tReady = tSongController.playSong(pMusicIndexTop, tSongData, 0)
    end if
  end if
  return(tReady)
end

on roomActivityUpdate me, tInitialUpdate 
  tUpdate = me.getInterface().getEditorWindowExists()
  if tUpdate then
    if not tInitialUpdate then
      getConnection(pConnectionId).send("MOVE", [#short:1000, #short:1000])
    end if
    if not timeoutExists(pRoomActivityUpdateTimer) then
      createTimeout(pRoomActivityUpdateTimer, 30 * 1000, #roomActivityUpdate, me.getID(), void(), 1)
    end if
  end if
end

on getDiskData me, tArray 
  if ilk(tArray) = #propList then
    if not voidp(tArray.getAt(#source)) then
      tStuffData = tArray.getAt(#source)
      tDelim = the itemDelimiter
      the itemDelimiter = numToChar(10)
      if tStuffData.count(#item) >= 6 then
        tArray.setAt(#author, tStuffData.getProp(#item, 1))
        tArray.setAt(#burnDay, tStuffData.getProp(#item, 2))
        tArray.setAt(#burnMonth, tStuffData.getProp(#item, 3))
        tArray.setAt(#burnYear, tStuffData.getProp(#item, 4))
        tArray.setAt(#songLength, tStuffData.getProp(#item, 5))
        tArray.setAt(#songName, tStuffData.getProp(#item, 6, tStuffData.count(#item)))
        tmember = getMember("song_disk_play_icon")
        if tmember <> 0 then
          if tmember.type = #bitmap then
            tArray.setAt(#playIcon, tmember.image)
          end if
        end if
      end if
      the itemDelimiter = tDelim
    end if
  end if
  return(tArray)
end
