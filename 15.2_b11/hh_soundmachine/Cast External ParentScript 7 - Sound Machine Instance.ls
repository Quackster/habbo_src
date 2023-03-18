property pLoopPlaylist, pPlayStackIndex, pPlaylistManager, pSongList, pTimelineList, pFurniOn, pInitialized, pSongControllerID, pProcessSongTimer

on construct me
  pPlaylistManager = createObject(#temp, getClassVariable("soundmachine.songlist.manager"))
  pSongControllerID = "song controller"
  pProcessSongTimer = "sound machine instance timer"
  pLoopPlaylist = 0
  pSongList = []
  pTimelineList = [:]
  pInitialized = 0
  pPlayStackIndex = VOID
  return 1
end

on deconstruct me
  pPlaylistManager.deconstruct()
  repeat with tTimeline in pTimelineList
    tTimeline.deconstruct()
  end repeat
  return 1
end

on Initialize me
  if pInitialized then
    return 0
  end if
  pInitialized = 1
  return 1
end

on playSong me
  tSongController = getObject(pSongControllerID)
  if pFurniOn then
    if (tSongController <> 0) and not voidp(pPlayStackIndex) then
      me.updatePlaylist()
      tSongController.initPlaylist(pPlayStackIndex, pSongList.duplicate(), pPlaylistManager.getPlayTime(), pLoopPlaylist)
      me.processSongData()
      return 1
    end if
  end if
  return 0
end

on stopSong me
  if voidp(pPlayStackIndex) then
    return 0
  end if
  if not pLoopPlaylist then
    repeat with tTimeline in pTimelineList
      tTimeline.deconstruct()
    end repeat
    pTimelineList = [:]
    pSongList = []
  end if
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.stopSong(pPlayStackIndex)
  end if
  return 1
end

on setState me, tFurniOn
  if tFurniOn = pFurniOn then
    return 0
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
  return 1
end

on getState me
  return pFurniOn
end

on setLooping me, tLoop
  pLoopPlaylist = tLoop
end

on getLooping me
  return pLoopPlaylist
end

on setPlayStackIndex me, tStackIndex
  pPlayStackIndex = tStackIndex
end

on getPlaylistManager me
  me.updatePlaylist()
  return pPlaylistManager
end

on parsePlaylist me, tMsg
  if voidp(pPlayStackIndex) then
    return 0
  end if
  tRetVal = pPlaylistManager.parsePlaylist(tMsg)
  tCount = pPlaylistManager.getPlaylistCount()
  repeat with tTimeline in pTimelineList
    tTimeline.deconstruct()
  end repeat
  pTimelineList = [:]
  pSongList = []
  repeat with i = 1 to tCount
    tSong = pPlaylistManager.getPlaylistSong(i)
    if tSong <> 0 then
      if not me.createTimelineInstance(tSong) then
        return error(me, "Problems with playlist", #parsePlaylist, #major)
      end if
    end if
  end repeat
  if pTimelineList.count = 0 then
    return 0
  end if
  tTimeline = pTimelineList[1]
  tstart = 1
  tTotalLength = pPlaylistManager.getPlaylistLength() * tTimeline.getSlotDuration() / 100
  if tTotalLength > 0 then
    tOffset = pPlaylistManager.getPlayTime() mod tTotalLength
    tPos = 0
    repeat with i = 1 to pSongList.count
      tPos = tPos + (pSongList[i][#length] / 100)
      if tPos > (tOffset + 50) then
        tstart = i
        exit repeat
      end if
    end repeat
  end if
  tDownloadList = []
  repeat with i = 0 to pTimelineList.count - 1
    tIndex = (tstart + i) mod tCount
    if tIndex = 0 then
      tIndex = tCount
    end if
    tid = pTimelineList.getPropAt(tIndex)
    if tDownloadList.findPos(tid) = 0 then
      tDownloadList.add(tid)
      pPlaylistManager.downloadSong(tid)
    end if
  end repeat
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    tSongController.initPlaylist(pPlayStackIndex, pSongList.duplicate(), pPlaylistManager.getPlayTime(), pLoopPlaylist)
  end if
  return tRetVal
end

on updatePlaylist me
  if not pLoopPlaylist and pFurniOn then
    tPlayTime = pPlaylistManager.getPlayTime()
    tEndTime = 0
    tRemove = 0
    repeat with i = 1 to pSongList.count
      tEndTime = tEndTime + (pSongList[i][#length] / 100)
      if tEndTime <= tPlayTime then
        tRemove = i
        next repeat
      end if
      exit repeat
    end repeat
    repeat with i = 1 to tRemove
      tLength = pSongList[1][#length] / 100
      pSongList.deleteAt(1)
      pTimelineList[1].deconstruct()
      pTimelineList.deleteAt(1)
      pPlaylistManager.changePlayTime(-tLength)
      pPlaylistManager.removePlaylistSong(1)
    end repeat
  end if
end

on insertPlaylistSong me, tid, tLength, tName, tAuthor
  if voidp(pPlayStackIndex) then
    return 0
  end if
  if pLoopPlaylist then
    return 0
  end if
  me.updatePlaylist()
  if not pPlaylistManager.insertPlaylistSong(tid, tLength, tName, tAuthor) then
    return 0
  end if
  me.createTimelineInstance([#id: tid, #length: tLength])
  if pTimelineList.count = 0 then
    return 0
  end if
  tTimeline = pTimelineList[1]
  pPlaylistManager.downloadSong(tid)
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    return tSongController.addPlaylistSong(pPlayStackIndex, tid, tLength * tTimeline.getSlotDuration())
  end if
  return 0
end

on parseSongData me, tdata, tSongID, tSongName
  repeat with i = 1 to pTimelineList.count
    tid = pTimelineList.getPropAt(i)
    if tSongID = tid then
      tTimeline = pTimelineList[i]
      tTimeline.parseSongData(tdata, tSongID, tSongName)
    end if
  end repeat
end

on processSongData me
  tReady = 1
  tSongController = getObject(pSongControllerID)
  me.updatePlaylist()
  repeat with i = 1 to pTimelineList.count
    if not pTimelineList[i].processSongData() then
      tReady = 0
      next repeat
    end if
    if pFurniOn then
      if tSongController <> 0 then
        tSongData = pTimelineList[i].getSongData()
        tid = pTimelineList[i].getSongID()
        if tSongData <> 0 then
          tSongController.updatePlaylistSong(tid, tSongData)
        end if
      end if
    end if
  end repeat
  if not tReady then
    if not timeoutExists(pProcessSongTimer) then
      createTimeout(pProcessSongTimer, 500, #processSongData, me.getID(), VOID, 1)
    end if
  end if
end

on createTimelineInstance me, tSong
  if ilk(tSong) <> #propList then
    return error(me, "Problems with playlist", #createTimelineInstance, #major)
  end if
  if voidp(tSong[#id]) or voidp(tSong[#length]) then
    return error(me, "Problems with playlist", #createTimelineInstance, #major)
  end if
  tTimeline = createObject("timeline instance", getClassVariable("soundmachine.song.timeline"))
  if tTimeline = 0 then
    return error(me, "Couldn't create timeline instance", #createTimelineInstance, #major)
  end if
  unregisterObject("timeline instance")
  tTimeline.reset(1)
  pTimelineList.addProp(tSong[#id], tTimeline)
  tSongLength = tSong[#length] * tTimeline.getSlotDuration()
  if tSongLength < 0 then
    error(me, "Invalid song length - sync will not work", #createTimelineInstance, #minor)
    tSongLength = tTimeline.getSlotDuration()
  end if
  pSongList.add([#length: tSongLength, #id: tSong[#id]])
  return 1
end
