on construct(me)
  pGameFX = getSoundState()
  pGameMusic = getSoundState()
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
  if me = #setfx then
    return(me.setGameFxState(tdata))
  else
    if me = #setmusic then
      return(me.setGameMusicState(tdata))
    else
      if me = #soundeffect then
        return(me.playGameSound(tdata))
      else
        if me <> #musicstart then
          if me = #gamestart then
            return(me.setGameMusic(pGameMusic))
          else
            if me = #gameend then
              return(me.setGameMusic(0))
            end if
          end if
          exit
        end if
      end if
    end if
  end if
end

on setGameFxState(me, tstate)
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
  exit
end

on setGameMusicState(me, tstate)
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
  exit
end

on playGameSound(me, tdata)
  if not pGameFX then
    return(1)
  end if
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