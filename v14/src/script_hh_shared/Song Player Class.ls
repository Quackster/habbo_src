property pUpdateTimeout, pQueueTimeout, pPlayTimeout, pSongData, pSongChannels, pPreviewChannel

on construct me 
  pSongData = [:]
  pUpdateTimeout = "song player loop update"
  pQueueTimeout = "song queue timeout"
  pPlayTimeout = "song play timeout"
  pPreviewChannel = 5
  pSongChannels = [1, 2, 3, 4]
end

on deconstruct me 
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
end

on startSong me, tSongData 
  me.stopSong()
  pSongData = tSongData.duplicate()
  me.processSongData()
  me.reserveSongChannels()
  createTimeout(pQueueTimeout, 50, #queueChannels, me.getID(), void(), 1)
  if not timeoutExists(pUpdateTimeout) then
    createTimeout(pUpdateTimeout, 1500, #checkLoopData, me.getID(), void(), 0)
  end if
  return(1)
end

on stopSong me 
  if timeoutExists(pQueueTimeout) then
    removeTimeout(pQueueTimeout)
  end if
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  if voidp(pSongData) then
    return(1)
  end if
  tChannelList = pSongData.getAt(#channelList)
  if voidp(tChannelList) then
    return(1)
  end if
  repeat while tChannelList <= undefined
    tChannel = getAt(undefined, undefined)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      stopSoundChannel(pSongChannels.getAt(tChannel))
    end if
  end repeat
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
  return(1)
end

on processSongData me 
  if voidp(pSongData.getaProp(#sounds)) then
    return(1)
  end if
  tSounds = pSongData.getaProp(#sounds)
  tChannels = []
  i = 1
  repeat while i <= tSounds.count
    tSound = tSounds.getAt(i)
    tChannel = tSound.channel
    if not tChannels.findPos(tChannel) then
      tChannels.add(tChannel)
    end if
    i = 1 + i
  end repeat
  tChannels.sort()
  i = 1
  repeat while i <= tSounds.count
    tSound = tSounds.getAt(i)
    tChannel = tSound.channel
    tSound.channel = tChannels.findPos(tChannel)
    i = 1 + i
  end repeat
  tChannelsFinal = []
  i = 1
  repeat while i <= tChannels.count
    tChannelsFinal.add(i)
    i = 1 + i
  end repeat
  pSongData.setAt(#channelList, tChannelsFinal)
end

on reserveSongChannels me 
  if voidp(pSongData) then
    return(1)
  end if
  tChannelList = pSongData.getAt(#channelList)
  if voidp(tChannelList) then
    return(1)
  end if
  repeat while tChannelList <= undefined
    tChannel = getAt(undefined, undefined)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      queueSound("sound_machine_sample_0", pSongChannels.getAt(tChannel))
      startSoundChannel(pSongChannels.getAt(tChannel))
    end if
  end repeat
end

on queueChannels me 
  if voidp(pSongData) then
    return(1)
  end if
  tChannelList = pSongData.getAt(#channelList)
  if voidp(tChannelList) then
    return(1)
  end if
  repeat while tChannelList <= undefined
    tChannel = getAt(undefined, undefined)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      stopSoundChannel(pSongChannels.getAt(tChannel))
    end if
  end repeat
  tPlayRoundsOnQueue = 2
  i = 1
  repeat while i <= tPlayRoundsOnQueue
    me.addPlayRound()
    i = 1 + i
  end repeat
  if timeoutExists(pPlayTimeout) then
    removeTimeout(pPlayTimeout)
  end if
  createTimeout(pPlayTimeout, 50, #startChannels, me.getID(), void(), 1)
end

on startChannels me 
  if voidp(pSongData) then
    return(1)
  end if
  tChannelList = pSongData.getAt(#channelList)
  if voidp(tChannelList) then
    return(1)
  end if
  i = tChannelList.count
  repeat while i >= 1
    tChannel = tChannelList.getAt(i)
    if tChannel >= 1 and tChannel <= pSongChannels.count then
      startSoundChannel(pSongChannels.getAt(tChannel))
    end if
    i = 255 + i
  end repeat
end

on addPlayRound me 
  if pSongData.getaProp(#sounds) = void() then
    return(1)
  end if
  tOffset = 0
  if not voidp(pSongData.getAt(#offset)) then
    tOffset = pSongData.getAt(#offset)
  end if
  tOffsetList = []
  i = 1
  repeat while i <= pSongChannels.count
    tOffsetList.add(tOffset)
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= pSongData.count(#sounds)
    tSound = pSongData.getProp(#sounds, i)
    j = 1
    repeat while j <= tSound.loops
      tChannel = tSound.channel
      if tChannel >= 1 and tChannel <= pSongChannels.count then
        if getMember(tSound.name) <> void() then
          if getMember(tSound.name).type = #sound then
            if tOffsetList.getAt(tChannel) > 0 then
              tLength = getMember(tSound.name).duration
              if tLength > tOffsetList.getAt(tChannel) then
                queueSound(tSound.name, pSongChannels.getAt(tChannel), [#startTime:tOffsetList.getAt(tChannel)])
              end if
              tOffsetList.setAt(tChannel, max(0, tOffsetList.getAt(tChannel) - tLength))
            else
              queueSound(tSound.name, pSongChannels.getAt(tChannel))
            end if
          end if
        end if
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  if not voidp(pSongData.getAt(#offset)) then
    tOffset = tOffsetList.getAt(1)
    i = 2
    repeat while i <= tOffsetList.count
      if tOffsetList.getAt(i) < tOffset then
        tOffset = tOffsetList.getAt(i)
      end if
      i = 1 + i
    end repeat
    pSongData.setAt(#offset, tOffset)
  end if
  return(1)
end

on checkLoopData me 
  if voidp(pSongData) then
    return(1)
  end if
  tChannelList = pSongData.getAt(#channelList)
  if voidp(tChannelList) then
    return(1)
  end if
  if tChannelList.count = 0 then
    return(1)
  end if
  tChannel = tChannelList.getAt(1)
  if tChannel < 1 or tChannel > pSongChannels.count then
    return(1)
  end if
  tSoundChannel = sound(pSongChannels.getAt(tChannel))
  if ilk(tSoundChannel) <> #instance then
    return(error(me, "Sound channel bug:" && pSongChannels.getAt(tChannel), #checkLoopData, #major))
  end if
  tPlayList = tSoundChannel.getPlaylist()
  tLength = 0
  i = 1
  repeat while i <= tPlayList.count
    tLength = tPlayList.getAt(i) + member.duration
    i = 1 + i
  end repeat
  if tLength < 60000 then
    me.addPlayRound()
  end if
  return(1)
end

on startSamplePreview me, tParams 
  tSuccess = playSoundInChannel(tParams.name, pPreviewChannel)
  if not tSuccess then
    return(error(me, "Sound could not be started", #startSamplePreview, #minor))
  end if
  return(1)
end

on stopSamplePreview me 
  tSuccess = stopSoundChannel(pPreviewChannel)
  if not tSuccess then
    return(error(me, "Sound could not be stopped", #stopSamplePreview, #minor))
  end if
  return(1)
end
