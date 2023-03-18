property pChannelCount, pChannelList, pMuted, pUpdateInterval

on construct me
  pMuted = 0
  pChannelCount = 5
  pChannelList = []
  pUpdateInterval = 0
  repeat with i = 1 to pChannelCount
    tObject = createObject(#temp, "Sound Channel Class")
    if tObject.define(i) then
      pChannelList.add(tObject)
    end if
  end repeat
  registerMessage(#set_all_sounds, me.getID(), #setSoundState)
end

on deconstruct me
  unregisterMessage(#set_all_sounds, me.getID())
  repeat with i = 1 to pChannelCount
    tObject = me.getChannel(i)
    if tObject <> 0 then
      tObject.reset()
    end if
  end repeat
  pChannelList = VOID
  pChannelCount = VOID
  return 1
end

on getProperty me, tPropID
  case tPropID of
    #channelCount:
      return pChannelList.count
    otherwise:
      return 0
  end case
end

on setProperty me, tPropID, tValue
  case tPropID of
    otherwise:
      return 0
  end case
end

on getChannel me, tNum
  if (tNum < 0) or (tNum > pChannelList.count) then
    return 0
  end if
  return pChannelList[tNum]
end

on print me, tCount
  if integerp(tCount) then
  end if
end

on play me, tMemName, tPriority, tProps
  tObject = me.createSoundInstance(tMemName, tPriority, tProps)
  case tPriority of
    #pass, VOID:
      repeat with i = 1 to pChannelCount
        tStatus = pChannelList[i].getTimeRemaining()
        if tStatus = 0 then
          return pChannelList[i].play(tObject)
        end if
      end repeat
      return 0
    #cut:
      tStatusList = [:]
      repeat with i = 1 to pChannelCount
        tStatus = pChannelList[i].getTimeRemaining()
        if tStatus = 0 then
          return pChannelList[i].play(tObject)
        end if
        if not pChannelList[i].getIsReserved() then
          tStatusList.addProp(tStatus, i)
        end if
      end repeat
      if tStatusList.count = 0 then
        return 0
      end if
      tStatusList.sort()
      return pChannelList[tStatusList[1]].play(tObject)
    #queue:
      tStatusList = [:]
      repeat with i = 1 to pChannelCount
        tStatus = pChannelList[i].getTimeRemaining()
        if tStatus = 0 then
          return pChannelList[i].play(tObject)
        end if
        if not pChannelList[i].getIsReserved() then
          tStatusList.addProp(tStatus, i)
        end if
      end repeat
      if tStatusList.count = 0 then
        return 0
      end if
      tStatusList.sort()
      return pChannelList[tStatusList[1]].queue(tObject)
  end case
  tObject = VOID
  return 0
end

on playInChannel me, tMemName, tChannelNum
  tChannel = me.getChannel(tChannelNum)
  if tChannel = 0 then
    return error(VOID, "Invalid sound channel:" && tChannelNum, #playInChannel, #minor)
  end if
  tObject = me.createSoundInstance(tMemName, VOID, VOID)
  tChannel.reset()
  return tChannel.play(tObject)
end

on queue me, tMemName, tChannelNum, tProps
  tChannel = me.getChannel(tChannelNum)
  if tChannel = 0 then
    return error(VOID, "Invalid sound channel:" && tChannelNum, #queue, #minor)
  end if
  tObject = me.createSoundInstance(tMemName, VOID, tProps)
  tRetVal = tChannel.queue(tObject)
  if tRetVal then
    tChannel.setReserved()
  end if
end

on stopChannel me, tNum
  if tNum = VOID then
    return 0
  end if
  if (tNum < 1) or (tNum > pChannelList.count) then
    return 0
  end if
  return pChannelList[tNum].reset()
end

on playChannel me, tNum
  if tNum = VOID then
    return 0
  end if
  if (tNum < 1) or (tNum > pChannelList.count) then
    return 0
  end if
  return pChannelList[tNum].startPlaying()
end

on stopAllSounds me
  repeat with i = 1 to pChannelCount
    pChannelList[i].reset()
  end repeat
  return 1
end

on setSoundState me, tValue
  if tValue then
    pMuted = 0
  else
    pMuted = 1
  end if
  repeat with i = 1 to pChannelCount
    pChannelList[i].setSoundState(tValue)
  end repeat
  return 1
end

on getSoundState me
  return not pMuted
end

on createSoundInstance me, tMemName, tPriority, tProps
  tObject = createObject(#temp, "Sound Instance Class")
  if tObject = 0 then
    return 0
  end if
  tObject.define(tMemName, tPriority, tProps)
  return tObject
end
