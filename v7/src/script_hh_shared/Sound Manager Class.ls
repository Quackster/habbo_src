property pChannelCount, pChannelList, pMuted



on construct me 

  pMuted = 0

  pChannelCount = 5

  pChannelList = []

  pUpdateInterval = 0

  i = 1

  repeat while i <= pChannelCount

    tObject = createObject(#temp, "Sound Channel Class")

    if tObject.define(i) then

      pChannelList.add(tObject)

    end if

    i = (1 + i)

  end repeat

  registerMessage(#set_all_sounds, me.getID(), #setSoundState)

end



on deconstruct me 

  unregisterMessage(#set_all_sounds, me.getID())

  i = 1

  repeat while i <= pChannelCount

    tObject = me.getChannel(i)

    if tObject <> 0 then

      tObject.reset()

    end if

    i = (1 + i)

  end repeat

  pChannelList = void()

  pChannelCount = void()

  return TRUE

end



on getProperty me, tPropID 

  if (tPropID = #channelCount) then

    return(pChannelList.count)

  else

    return FALSE

  end if

end



on setProperty me, tPropID, tValue 

  return FALSE

end



on getChannel me, tNum 

  if tNum < 0 or tNum > pChannelList.count then

    return FALSE

  end if

  return(pChannelList.getAt(tNum))

end



on print me, tCount 

  if integerp(tCount) then

  end if

end



on play me, tMemName, tPriority, tProps 

  tObject = me.createSoundInstance(tMemName, tPriority, tProps)

  if tPriority <> #pass then

    if (tPriority = void()) then

      i = 1

      repeat while i <= pChannelCount

        tStatus = pChannelList.getAt(i).getTimeRemaining()

        if (tStatus = 0) then

          return(pChannelList.getAt(i).play(tObject))

        end if

        i = (1 + i)

      end repeat

      return FALSE

    else

      if (tPriority = #cut) then

        tStatusList = [:]

        i = 1

        repeat while i <= pChannelCount

          tStatus = pChannelList.getAt(i).getTimeRemaining()

          if (tStatus = 0) then

            return(pChannelList.getAt(i).play(tObject))

          end if

          if not pChannelList.getAt(i).getIsReserved() then

            tStatusList.addProp(tStatus, i)

          end if

          i = (1 + i)

        end repeat

        if (tStatusList.count = 0) then

          return FALSE

        end if

        tStatusList.sort()

        return(pChannelList.getAt(tStatusList.getAt(1)).play(tObject))

      else

        if (tPriority = #queue) then

          tStatusList = [:]

          i = 1

          repeat while i <= pChannelCount

            tStatus = pChannelList.getAt(i).getTimeRemaining()

            if (tStatus = 0) then

              return(pChannelList.getAt(i).play(tObject))

            end if

            if not pChannelList.getAt(i).getIsReserved() then

              tStatusList.addProp(tStatus, i)

            end if

            i = (1 + i)

          end repeat

          if (tStatusList.count = 0) then

            return FALSE

          end if

          tStatusList.sort()

          return(pChannelList.getAt(tStatusList.getAt(1)).queue(tObject))

        end if

      end if

    end if

    tObject = void()

    return FALSE

  end if

end



on playInChannel me, tMemName, tChannelNum 

  tChannel = me.getChannel(tChannelNum)

  if (tChannel = 0) then

    return(error(void(), "Invalid sound channel:" && tChannelNum, #playInChannel, #minor))

  end if

  tObject = me.createSoundInstance(tMemName, void(), void())

  tChannel.reset()

  return(tChannel.play(tObject))

end



on queue me, tMemName, tChannelNum, tProps 

  tChannel = me.getChannel(tChannelNum)

  if (tChannel = 0) then

    return(error(void(), "Invalid sound channel:" && tChannelNum, #queue, #minor))

  end if

  tObject = me.createSoundInstance(tMemName, void(), tProps)

  tRetVal = tChannel.queue(tObject)

  if tRetVal then

    tChannel.setReserved()

  end if

end



on stopChannel me, tNum 

  if (tNum = void()) then

    return FALSE

  end if

  if tNum < 1 or tNum > pChannelList.count then

    return FALSE

  end if

  return(pChannelList.getAt(tNum).reset())

end



on playChannel me, tNum 

  if (tNum = void()) then

    return FALSE

  end if

  if tNum < 1 or tNum > pChannelList.count then

    return FALSE

  end if

  return(pChannelList.getAt(tNum).startPlaying())

end



on stopAllSounds me 

  i = 1

  repeat while i <= pChannelCount

    pChannelList.getAt(i).reset()

    i = (1 + i)

  end repeat

  return TRUE

end



on setSoundState me, tValue 

  if tValue then

    pMuted = 0

  else

    pMuted = 1

  end if

  i = 1

  repeat while i <= pChannelCount

    pChannelList.getAt(i).setSoundState(tValue)

    i = (1 + i)

  end repeat

  return TRUE

end



on getSoundState me 

  return(not pMuted)

end



on createSoundInstance me, tMemName, tPriority, tProps 

  tObject = createObject(#temp, "Sound Instance Class")

  if (tObject = 0) then

    return FALSE

  end if

  tObject.define(tMemName, tPriority, tProps)

  return(tObject)

end

