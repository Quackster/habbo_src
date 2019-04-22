on constructSoundManager()
  return(createManager(#sound_manager, getClassVariable("sound.manager.class", "Sound Manager Class")))
  exit
end

on deconstructSoundManager()
  return(removeManager(#sound_manager))
  exit
end

on getSoundManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#sound_manager) then
    return(constructSoundManager())
  end if
  return(tMgr.getManager(#sound_manager))
  exit
end

on setSoundState(tValue)
  return(getSoundManager().setSoundState(tValue))
  exit
end

on getSoundState()
  return(getSoundManager().getSoundState())
  exit
end

on playSound(tMemName, tPriority, tProps)
  return(getSoundManager().play(tMemName, tPriority, tProps))
  exit
end

on playSoundInChannel(tMemName, tChannelNum)
  return(getSoundManager().playInChannel(tMemName, tChannelNum))
  exit
end

on queueSound(tMemName, tChannelNum, tProps)
  return(getSoundManager().queue(tMemName, tChannelNum, tProps))
  exit
end

on stopAllSounds(tid)
  if not managerExists(#sound_manager) then
    return(0)
  end if
  return(getSoundManager().stopAllSounds(tid))
  exit
end

on startSoundChannel(tNum)
  return(getSoundManager().playChannel(tNum))
  exit
end

on stopSoundChannel(tNum)
  return(getSoundManager().stopChannel(tNum))
  exit
end