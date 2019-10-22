property pMusicChannel

on construct me 
  pMusicChannel = 0
  return TRUE
end

on deconstruct me 
  me.setGameMusic(0)
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #soundeffect) then
    return(me.playGameSound(tdata))
  else
    if tTopic <> #musicstart then
      if (tTopic = #gamestart) then
        return(me.setGameMusic(1))
      else
        if (tTopic = #gameend) then
          return(me.setGameMusic(0))
        end if
      end if
    end if
  end if
end

on playGameSound me, tdata 
  return(playSound(tdata))
end

on setGameMusic me, tstate 
  if tstate then
    if me.getGameSystem().getGamestatus() <> #game_started then
      return TRUE
    end if
    if pMusicChannel > 0 then
      return TRUE
    end if
    pMusicChannel = playSound("BB2-musicloop", #cut, [#infiniteloop:1])
  else
    if pMusicChannel > 0 then
      stopSoundChannel(pMusicChannel)
    end if
    pMusicChannel = 0
  end if
  return TRUE
end
