property pSampleList, pSongPlayer

on construct me
  pSampleList = [:]
  pSongPlayer = "song player"
  createObject(pSongPlayer, "Song Player Class")
  return 
end

on deconstruct me
  if objectExists(pSongPlayer) then
    removeObject(pSongPlayer)
  end if
  return 
end

on preloadSounds me, tSampleList
  repeat with i = 1 to tSampleList.count
    tItem = tSampleList[i]
    if ilk(tItem) = #propList then
      me.startSampleDownload(tItem[#sound], tItem[#parent])
      next repeat
    end if
    if ilk(tItem) = #string then
      me.startSampleDownload(tItem)
    end if
  end repeat
end

on getSampleLoadingStatus me, tMemName
  if memberExists(tMemName) then
    return 1
  end if
  return 0
end

on getSampleLength me, tMemName
  if getMember(tMemName) = VOID then
    return 0
  end if
  if getMember(tMemName).type <> #sound then
    return 0
  end if
  tLength = getMember(tMemName).duration
  return tLength
end

on startSamplePreview me, tMemberName
  return getObject(pSongPlayer).startSamplePreview([#name: tMemberName])
end

on stopSamplePreview me
  return getObject(pSongPlayer).stopSamplePreview()
end

on playSong me, tSongData
  return getObject(pSongPlayer).startSong(tSongData)
end

on stopSong me
  return getObject(pSongPlayer).stopSong()
end

on startSampleDownload me, tMemberName, tParentId
  if memberExists(tMemberName) then
    if pSampleList.getaProp(tMemberName) = VOID then
      tSample = [#status: "ready"]
      pSampleList.addProp(tMemberName, tSample)
    else
    end if
  else
    if pSampleList.getaProp(tMemberName) = VOID then
      if threadExists(#dynamicdownloader) then
        getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tMemberName, #sound, me.getID(), #soundDownloadCompleted, VOID, VOID, tParentId)
        tSample = [#status: "loading"]
        pSampleList.addProp(tMemberName, tSample)
      else
        return error(me, "Dynamic downloader does not exist, cannot download sound.", #startSampleDownload, #major)
      end if
    end if
  end if
  return 1
end

on soundDownloadCompleted me, tName, tParam2
  tSample = pSampleList.getaProp(tName)
  if not voidp(tSample) then
    tSample.status = "ready"
  end if
end
