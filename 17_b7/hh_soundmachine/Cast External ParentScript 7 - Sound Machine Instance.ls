property pLoopPlaylist, pPlayStackIndex, pPlaylistManager, pSongList, pTimelineList, pFurniOn, pInitialized, pSongControllerID, pProcessSongTimer, pBubbleTimer, pFurniID, pBubbleSongName

on construct me
  pPlaylistManager = createObject(#temp, getClassVariable("soundmachine.songlist.manager"))
  pSongControllerID = "song controller"
  pProcessSongTimer = "sound machine instance timer"
  pLoopPlaylist = 0
  pSongList = []
  pTimelineList = [:]
  pInitialized = 0
  pPlayStackIndex = VOID
  pBubbleTimer = VOID
  pFurniID = VOID
  pBubbleSongName = EMPTY
  return 1
end

on deconstruct me
  pPlaylistManager.deconstruct()
  repeat with tTimeline in pTimelineList
    tTimeline.deconstruct()
  end repeat
  if not voidp(pBubbleTimer) then
    if timeoutExists(pBubbleTimer) then
      removeTimeout(pBubbleTimer)
    end if
  end if
  return 1
end

on Initialize me, tID
  if pInitialized then
    return 0
  end if
  pInitialized = 1
  pBubbleTimer = "jukebox_timer_" & tID
  if not timeoutExists(pBubbleTimer) then
    createTimeout(pBubbleTimer, 1000, #bubbleCheck, me.getID(), VOID, 0)
  end if
  pFurniID = tID
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
    tID = pTimelineList.getPropAt(tIndex)
    if tDownloadList.findPos(tID) = 0 then
      tDownloadList.add(tID)
      pPlaylistManager.downloadSong(tID)
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

on insertPlaylistSong me, tID, tLength, tName, tAuthor
  if voidp(pPlayStackIndex) then
    return 0
  end if
  if pLoopPlaylist then
    return 0
  end if
  me.updatePlaylist()
  if not pPlaylistManager.insertPlaylistSong(tID, tLength, tName, tAuthor) then
    return 0
  end if
  me.createTimelineInstance([#id: tID, #length: tLength])
  if pTimelineList.count = 0 then
    return 0
  end if
  tTimeline = pTimelineList[1]
  pPlaylistManager.downloadSong(tID)
  tSongController = getObject(pSongControllerID)
  if tSongController <> 0 then
    return tSongController.addPlaylistSong(pPlayStackIndex, tID, tLength * tTimeline.getSlotDuration())
  end if
  return 0
end

on parseSongData me, tdata, tSongID, tSongName
  repeat with i = 1 to pTimelineList.count
    tID = pTimelineList.getPropAt(i)
    if tSongID = tID then
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
        tID = pTimelineList[i].getSongID()
        if tSongData <> 0 then
          tSongController.updatePlaylistSong(tID, tSongData)
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

on bubbleCheck me
  if pLoopPlaylist then
    return 0
  end if
  tArray = [:]
  tArray[#id] = pFurniID
  executeMessage(#get_jukebox_song_info, tArray)
  tNewName = EMPTY
  if not voidp(tArray[#songName]) then
    tNewName = tArray[#songName] & " "
  end if
  if not voidp(tArray[#author]) then
    tNewName = tNewName & tArray[#author]
  end if
  if tNewName <> pBubbleSongName then
    if tNewName <> EMPTY then
      tMsg = [#command: "SHOUT", #id: pFurniID, #message: tNewName, #furni: 1]
      executeMessage(#show_balloon, tMsg)
    end if
    pBubbleSongName = tNewName
  end if
  return 1
end
