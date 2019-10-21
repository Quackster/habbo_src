on construct(me)
  pSampleList = []
  pSongPlayer = "song player"
  createObject(pSongPlayer, "Song Player Class")
  pLengthCache = []
  exit
end

on deconstruct(me)
  if objectExists(pSongPlayer) then
    removeObject(pSongPlayer)
  end if
  exit
end

on preloadSounds(me, tSampleList)
  i = 1
  repeat while i <= tSampleList.count
    tItem = tSampleList.getAt(i)
    if ilk(tItem) = #propList then
      me.startSampleDownload(tItem.getAt(#sound), tItem.getAt(#parent))
    else
      if ilk(tItem) = #string then
        me.startSampleDownload(tItem)
      end if
    end if
    i = 1 + i
  end repeat
  exit
end

on getSampleLoadingStatus(me, tMemName)
  if memberExists(tMemName) then
    return(1)
  end if
  return(0)
  exit
end

on getSampleLength(me, tMemName)
  tLength = pLengthCache.getAt(tMemName)
  if not voidp(tLength) then
    return(tLength)
  end if
  tmember = getMember(tMemName)
  if tmember = 0 then
    return(0)
  end if
  if tmember.type <> #sound then
    return(0)
  end if
  tLength = tmember.duration
  pLengthCache.setAt(tMemName, tLength)
  return(tLength)
  exit
end

on startSamplePreview(me, tMemberName)
  return(getObject(pSongPlayer).startSamplePreview([#name:tMemberName]))
  exit
end

on stopSamplePreview(me)
  return(getObject(pSongPlayer).stopSamplePreview())
  exit
end

on playSong(me, tStackIndex, tSongData, tLoop)
  return(getObject(pSongPlayer).startSong(tStackIndex, tSongData, tLoop))
  exit
end

on stopSong(me, tStackIndex)
  return(getObject(pSongPlayer).stopSong(tStackIndex, 1))
  exit
end

on initPlaylist(me, tStackIndex, tSongList, tPlayTime, tLoop)
  return(getObject(pSongPlayer).initPlaylist(tStackIndex, tSongList, tPlayTime, tLoop))
  exit
end

on addPlaylistSong(me, tStackIndex, tID, tLength)
  return(getObject(pSongPlayer).addPlaylistSong(tStackIndex, tID, tLength))
  exit
end

on updatePlaylistSong(me, tID, tSongData)
  return(getObject(pSongPlayer).updatePlaylistSong(tID, tSongData))
  exit
end

on startSampleDownload(me, tMemberName, tParentId)
  if memberExists(tMemberName) then
    if pSampleList.getaProp(tMemberName) = void() then
      tSample = [#status:"ready"]
      pSampleList.addProp(tMemberName, tSample)
    else
    end if
  else
    if pSampleList.getaProp(tMemberName) = void() then
      if threadExists(#dynamicdownloader) then
        getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tMemberName, #sound, me.getID(), #soundDownloadCompleted, void(), void(), tParentId)
        tSample = [#status:"loading"]
        pSampleList.addProp(tMemberName, tSample)
      else
        return(error(me, "Dynamic downloader does not exist, cannot download sound.", #startSampleDownload, #major))
      end if
    end if
  end if
  return(1)
  exit
end

on soundDownloadCompleted(me, tName, tParam2)
  tSample = pSampleList.getaProp(tName)
  if not voidp(tSample) then
    tSample.status = "ready"
  end if
  exit
end