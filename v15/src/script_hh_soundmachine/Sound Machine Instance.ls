property pPlaylistManager, pTimelineList, pInitialized, pSongControllerID, pFurniOn, pPlayStackIndex, pSongList, pLoopPlaylist, pProcessSongTimer

on construct me 
  pPlaylistManager = createObject(#temp, getClassVariable("soundmachine.songlist.manager"))
  pSongControllerID = "song controller"
  pProcessSongTimer = "sound machine instance timer"
  pLoopPlaylist = 0
  pSongList = []
  pTimelineList = [:]
  pInitialized = 0
  pPlayStackIndex = void()
  return(1)
end

on deconstruct me 
  pPlaylistManager.deconstruct()
  repeat while pTimelineList <= undefined
    tTimeline = getAt(undefined, undefined)
    tTimeline.deconstruct()
  end repeat
  return(1)
end

on Initialize me 
  if pInitialized then
    return(0)
  end if
  pInitialized = 1
  return(1)
end

on playSong me 
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
end

on stopSong me 
  if voidp(pPlayStackIndex) then
    return(0)
  end if
  if not pLoopPlaylist then
    repeat while pTimelineList <= undefined
      tTimeline = getAt(undefined, undefined)
      tTimeline.deconstruct()
    end repeat
    pTimelineList = [:]
    pSongList = []
  end if
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.stopSong(pPlayStackIndex)
  end if
  return(1)
end

on setState me, tFurniOn 
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
end

on getState me 
  return(pFurniOn)
end

on setLooping me, tLoop 
  pLoopPlaylist = tLoop
end

on getLooping me 
  return(pLoopPlaylist)
end

on setPlayStackIndex me, tStackIndex 
  pPlayStackIndex = tStackIndex
end

on getPlaylistManager me 
  me.updatePlaylist()
  return(pPlaylistManager)
end

on parsePlaylist me, tMsg 
  if voidp(pPlayStackIndex) then
    return(0)
  end if
  tRetVal = pPlaylistManager.parsePlaylist(tMsg)
  tCount = pPlaylistManager.getPlaylistCount()
  repeat while pTimelineList <= undefined
    tTimeline = getAt(undefined, tMsg)
    tTimeline.deconstruct()
  end repeat
  pTimelineList = [:]
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
  tTotalLength = ((pPlaylistManager.getPlaylistLength() * tTimeline.getSlotDuration()) / 100)
  if tTotalLength > 0 then
    tOffset = (pPlaylistManager.getPlayTime() mod tTotalLength)
    tPos = 0
    i = 1
    repeat while i <= pSongList.count
      tPos = tPos + (pSongList.getAt(i).getAt(#length) / 100)
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
    tIndex = (tstart + i mod tCount)
    if tIndex = 0 then
      tIndex = tCount
    end if
    tid = pTimelineList.getPropAt(tIndex)
    if tDownloadList.findPos(tid) = 0 then
      tDownloadList.add(tid)
      pPlaylistManager.downloadSong(tid)
    end if
    i = 1 + i
  end repeat
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.initPlaylist(pPlayStackIndex, pSongList.duplicate(), pPlaylistManager.getPlayTime(), pLoopPlaylist)
  end if
  return(tRetVal)
end

on updatePlaylist me 
  if not pLoopPlaylist and pFurniOn then
    tPlayTime = pPlaylistManager.getPlayTime()
    tEndTime = 0
    tRemove = 0
    i = 1
    repeat while i <= pSongList.count
      tEndTime = tEndTime + (pSongList.getAt(i).getAt(#length) / 100)
      if tEndTime <= tPlayTime then
        tRemove = i
      else
      end if
      i = 1 + i
    end repeat
    i = 1
    repeat while i <= tRemove
      tLength = (pSongList.getAt(1).getAt(#length) / 100)
      pSongList.deleteAt(1)
      pTimelineList.getAt(1).deconstruct()
      pTimelineList.deleteAt(1)
      pPlaylistManager.changePlayTime(-tLength)
      pPlaylistManager.removePlaylistSong(1)
      i = 1 + i
    end repeat
  end if
end

on insertPlaylistSong me, tid, tLength, tName, tAuthor 
  if voidp(pPlayStackIndex) then
    return(0)
  end if
  if pLoopPlaylist then
    return(0)
  end if
  me.updatePlaylist()
  if not pPlaylistManager.insertPlaylistSong(tid, tLength, tName, tAuthor) then
    return(0)
  end if
  me.createTimelineInstance([#id:tid, #length:tLength])
  if pTimelineList.count = 0 then
    return(0)
  end if
  tTimeline = pTimelineList.getAt(1)
  pPlaylistManager.downloadSong(tid)
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    return(tSongController.addPlaylistSong(pPlayStackIndex, tid, (tLength * tTimeline.getSlotDuration())))
  end if
  return(0)
end

on parseSongData me, tdata, tSongID, tSongName 
  i = 1
  repeat while i <= pTimelineList.count
    tid = pTimelineList.getPropAt(i)
    if tSongID = tid then
      tTimeline = pTimelineList.getAt(i)
      tTimeline.parseSongData(tdata, tSongID, tSongName)
    end if
    i = 1 + i
  end repeat
end

on processSongData me 
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
          tid = pTimelineList.getAt(i).getSongID()
          if tSongData <> 0 then
            tSongController.updatePlaylistSong(tid, tSongData)
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
end

on createTimelineInstance me, tSong 
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
  tSongLength = (tSong.getAt(#length) * tTimeline.getSlotDuration())
  if tSongLength < 0 then
    error(me, "Invalid song length - sync will not work", #createTimelineInstance, #minor)
    tSongLength = tTimeline.getSlotDuration()
  end if
  pSongList.add([#length:tSongLength, #id:tSong.getAt(#id)])
  return(1)
end
