property pMusicChannel

on construct me
  pMusicChannel = 0
  return 1
end

on deconstruct me
  me.setGameMusic(0)
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #soundeffect:
      return me.playGameSound(tdata)
    #musicstart, #gamestart:
      return me.setGameMusic(1)
    #gameend:
      return me.setGameMusic(0)
  end case
end

on playGameSound me, tdata
  return playSound(tdata)
end

on setGameMusic me, tstate
  if tstate then
    if me.getGameSystem().getGamestatus() <> #game_started then
      return 1
    end if
    if pMusicChannel > 0 then
      return 1
    end if
    pMusicChannel = playSound("BB2-musicloop", #cut, [#infiniteloop: 1])
  else
    if pMusicChannel > 0 then
      stopSoundChannel(pMusicChannel)
    end if
    pMusicChannel = 0
  end if
  return 1
end
