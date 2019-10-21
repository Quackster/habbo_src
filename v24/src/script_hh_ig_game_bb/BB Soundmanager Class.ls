on construct(me)
  pMusicChannel = 0
  return(1)
  exit
end

on deconstruct(me)
  me.setGameMusic(0)
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if me = #soundeffect then
    return(me.playGameSound(tdata))
  else
    if me <> #musicstart then
      if me = #gamestart then
        return(me.setGameMusic(1))
      else
        if me = #gameend then
          return(me.setGameMusic(0))
        end if
      end if
      exit
    end if
  end if
end

on playGameSound(me, tdata)
  return(playSound(tdata))
  exit
end

on setGameMusic(me, tstate)
  if tstate then
    if me.getGameSystem().getGamestatus() <> #game_started then
      return(1)
    end if
    if pMusicChannel > 0 then
      return(1)
    end if
    pMusicChannel = playSound("BB2-musicloop", #cut, [#infiniteloop:1])
  else
    if pMusicChannel > 0 then
      stopSoundChannel(pMusicChannel)
    end if
    pMusicChannel = 0
  end if
  return(1)
  exit
end