property pGameMusic, pGameFX, pMusicChannel

on construct me 
  pGameFX = getSoundState()
  pGameMusic = getSoundState()
  pMusicChannel = 0
  return(1)
end

on deconstruct me 
  me.setGameMusic(0)
  return(1)
end

on Refresh me, tTopic, tdata 
  if tTopic = #setfx then
    return(me.setGameFxState(tdata))
  else
    if tTopic = #setmusic then
      return(me.setGameMusicState(tdata))
    else
      if tTopic = #soundeffect then
        return(me.playGameSound(tdata))
      else
        if tTopic <> #musicstart then
          if tTopic = #gamestart then
            return(me.setGameMusic(pGameMusic))
          else
            if tTopic = #gameend then
              return(me.setGameMusic(0))
            end if
          end if
        end if
      end if
    end if
  end if
end

on setGameFxState me, tstate 
  if not integerp(tstate) then
    tstate = not pGameFX
  end if
  pGameFX = tstate
  if pGameFX = 0 and pGameMusic = 0 then
    setSoundState(0)
  else
    setSoundState(1)
  end if
  return(me.sendGameSystemEvent(#setfxicon, pGameFX))
end

on setGameMusicState me, tstate 
  if not integerp(tstate) then
    tstate = not pGameMusic
  end if
  pGameMusic = tstate
  me.setGameMusic(pGameMusic)
  if pGameFX = 0 and pGameMusic = 0 then
    setSoundState(0)
  else
    setSoundState(1)
  end if
  return(me.sendGameSystemEvent(#setmusicicon, pGameMusic))
end

on playGameSound me, tdata 
  if not pGameFX then
    return(1)
  end if
  return(playSound(tdata))
end

on setGameMusic me, tstate 
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
end
