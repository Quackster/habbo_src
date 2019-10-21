on construct(me)
  pPlaylistManager = createObject(#temp, getClassVariable("soundmachine.songlist.manager"))
  pSongControllerID = "song controller"
  pProcessSongTimer = "sound machine instance timer"
  pLoopPlaylist = 0
  pSongList = []
  pTimelineList = []
  pInitialized = 0
  pPlayStackIndex = void()
  pBubbleTimer = void()
  pFurniID = void()
  pBubbleSongName = ""
  return(1)
  exit
end

on deconstruct(me)
  pPlaylistManager.deconstruct()
  repeat while me <= undefined
    tTimeline = getAt(undefined, undefined)
    tTimeline.deconstruct()
  end repeat
  if not voidp(pBubbleTimer) then
    if timeoutExists(pBubbleTimer) then
      removeTimeout(pBubbleTimer)
    end if
  end if
  return(1)
  exit
end

on Initialize(me, tID)
  if pInitialized then
    return(0)
  end if
  pInitialized = 1
  pBubbleTimer = "jukebox_timer_" & tID
  if not timeoutExists(pBubbleTimer) then
    createTimeout(pBubbleTimer, 1000, #bubbleCheck, me.getID(), void(), 0)
  end if
  pFurniID = tID
  return(1)
  exit
end

on playSong(me)
  tSongController = getObject(pSongControllerID)
  if pFurniOn then
    if tSongController <> 0 and not voidp(pPlayStackIndex) then
      me.updatePlaylist()
      tSongController.initPlaylist(pPlayStackIndex, pSongList.duplicate(), pPlaylistManager.getPlayTime(), pLoopPlaylist)
      me.processSongData()
      return(1)
    end if
  end if
  return(0)
  exit
end

on stopSong(me)
  if voidp(pPlayStackIndex) then
    return(0)
  end if
  if not pLoopPlaylist then
    repeat while me <= undefined
      tTimeline = getAt(undefined, undefined)
      tTimeline.deconstruct()
    end repeat
    pTimelineList = []
    pSongList = []
  end if
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.stopSong(pPlayStackIndex)
  end if
  return(1)
  exit
end

on setState(me, tFurniOn)
  if tFurniOn = pFurniOn then
    return(0)
  end if
  pFurniOn = tFurniOn
  pPlaylistManager.resetPlayTime()
  if pFurniOn then
    if pLoopPlaylist then
      me.playSong()
    else
      pPlaylistManager.getPlaylistData()
    end if
  else
    me.stopSong()
  end if
  return(1)
  exit
end

on getState(me)
  return(pFurniOn)
  exit
end

on setLooping(me, tLoop)
  pLoopPlaylist = tLoop
  exit
end

on getLooping(me)
  return(pLoopPlaylist)
  exit
end

on setPlayStackIndex(me, tStackIndex)
  pPlayStackIndex = tStackIndex
  exit
end

on getPlaylistManager(me)
  me.updatePlaylist()
  return(pPlaylistManager)
  exit
end

on parsePlaylist(me, tMsg)
  if voidp(pPlayStackIndex) then
    return(0)
  end if
  tRetVal = pPlaylistManager.parsePlaylist(tMsg)
  tCount = pPlaylistManager.getPlaylistCount()
  repeat while me <= undefined
    tTimeline = getAt(undefined, tMsg)
    tTimeline.deconstruct()
  end repeat
  pTimelineList = []
  pSongList = []
  i = 1
  repeat while i <= tCount
    tSong = pPlaylistManager.getPlaylistSong(i)
    if tSong <> 0 then
      if not me.createTimelineInstance(tSong) then
        return(error(me, "Problems with playlist", #parsePlaylist, #major))
      end if
    end if
    i = 1 + i
  end repeat
  if pTimelineList.count = 0 then
    return(0)
  end if
  tTimeline = pTimelineList.getAt(1)
  tstart = 1
  tTotalLength = pPlaylistManager.getPlaylistLength() * tTimeline.getSlotDuration() / 100
  if tTotalLength > 0 then
    tOffset = pPlaylistManager.getPlayTime() mod tTotalLength
    tPos = 0
    i = 1
    repeat while i <= pSongList.count
      tPos = tPos + pSongList.getAt(i).getAt(#length) / 100
      if tPos > tOffset + 50 then
        tstart = i
      else
        i = 1 + i
      end if
    end repeat
  end if
  tDownloadList = []
  i = 0
  repeat while i <= pTimelineList.count - 1
    tIndex = tstart + i mod tCount
    if tIndex = 0 then
      tIndex = tCount
    end if
    tID = pTimelineList.getPropAt(tIndex)
    if tDownloadList.findPos(tID) = 0 then
      tDownloadList.add(tID)
      pPlaylistManager.downloadSong(tID)
    end if
    i = 1 + i
  end repeat
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.initPlaylist(pPlayStackIndex, pSongList.duplicate(), pPlaylistManager.getPlayTime(), pLoopPlaylist)
  end if
  return(tRetVal)
  exit
end

on updatePlaylist(me)
  if not pLoopPlaylist and pFurniOn then
    tPlayTime = pPlaylistManager.getPlayTime()
    tEndTime = 0
    tRemove = 0
    i = 1
    repeat while i <= pSongList.count
      tEndTime = tEndTime + pSongList.getAt(i).getAt(#length) / 100
      if tEndTime <= tPlayTime then
        tRemove = i
      else
      end if
      i = 1 + i
    end repeat
    i = 1
    repeat while i <= tRemove
      tLength = pSongList.getAt(1).getAt(#length) / 100
      pSongList.deleteAt(1)
      pTimelineList.getAt(1).deconstruct()
      pTimelineList.deleteAt(1)
      pPlaylistManager.changePlayTime(-tLength)
      pPlaylistManager.removePlaylistSong(1)
      i = 1 + i
    end repeat
  end if
  exit
end

on insertPlaylistSong(me, tID, tLength, tName, tAuthor)
  if voidp(pPlayStackIndex) then
    return(0)
  end if
  if pLoopPlaylist then
    return(0)
  end if
  me.updatePlaylist()
  if not pPlaylistManager.insertPlaylistSong(tID, tLength, tName, tAuthor) then
    return(0)
  end if
  me.createTimelineInstance([#id:tID, #length:tLength])
  if pTimelineList.count = 0 then
    return(0)
  end if
  tTimeline = pTimelineList.getAt(1)
  pPlaylistManager.downloadSong(tID)
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    return(tSongController.addPlaylistSong(pPlayStackIndex, tID, tLength * tTimeline.getSlotDuration()))
  end if
  return(0)
  exit
end

on parseSongData(me, tdata, tSongID, tSongName)
  i = 1
  repeat while i <= pTimelineList.count
    tID = pTimelineList.getPropAt(i)
    if tSongID = tID then
      tTimeline = pTimelineList.getAt(i)
      tTimeline.parseSongData(tdata, tSongID, tSongName)
    end if
    i = 1 + i
  end repeat
  exit
end

on processSongData(me)
  tReady = 1
  tSongController = getObject(pSongControllerID)
  me.updatePlaylist()
  i = 1
  repeat while i <= pTimelineList.count
    if not pTimelineList.getAt(i).processSongData() then
      tReady = 0
    else
      if pFurniOn then
        if tSongController <> 0 then
          tSongData = pTimelineList.getAt(i).getSongData()
          tID = pTimelineList.getAt(i).getSongID()
          if tSongData <> 0 then
            tSongController.updatePlaylistSong(tID, tSongData)
          end if
        end if
      end if
    end if
    i = 1 + i
  end repeat
  if not tReady then
    if not timeoutExists(pProcessSongTimer) then
      createTimeout(pProcessSongTimer, 500, #processSongData, me.getID(), void(), 1)
    end if
  end if
  exit
end

on createTimelineInstance(me, tSong)
  if ilk(tSong) <> #propList then
    return(error(me, "Problems with playlist", #createTimelineInstance, #major))
  end if
  if voidp(tSong.getAt(#id)) or voidp(tSong.getAt(#length)) then
    return(error(me, "Problems with playlist", #createTimelineInstance, #major))
  end if
  tTimeline = createObject("timeline instance", getClassVariable("soundmachine.song.timeline"))
  if tTimeline = 0 then
    return(error(me, "Couldn't create timeline instance", #createTimelineInstance, #major))
  end if
  unregisterObject("timeline instance")
  tTimeline.reset(1)
  pTimelineList.addProp(tSong.getAt(#id), tTimeline)
  tSongLength = tSong.getAt(#length) * tTimeline.getSlotDuration()
  if tSongLength < 0 then
    error(me, "Invalid song length - sync will not work", #createTimelineInstance, #minor)
    tSongLength = tTimeline.getSlotDuration()
  end if
  pSongList.add([#length:tSongLength, #id:tSong.getAt(#id)])
  return(1)
  exit
end

on bubbleCheck(me)
  if pLoopPlaylist then
    return(0)
  end if
  tArray = []
  tArray.setAt(#id, pFurniID)
  executeMessage(#get_jukebox_song_info, tArray)
  tNewName = ""
  if not voidp(tArray.getAt(#songName)) then
    tNewName = tArray.getAt(#songName) & " "
  end if
  if not voidp(tArray.getAt(#author)) then
    tNewName = tNewName & tArray.getAt(#author)
  end if
  if tNewName <> pBubbleSongName then
    if tNewName <> "" then
      tMsg = [#command:"OBJECT", #id:pFurniID, #message:tNewName]
      executeMessage(#showObjectMessage, tMsg)
    end if
    pBubbleSongName = tNewName
  end if
  return(1)
  exit
end