on construct(me)
  pMember = member(getmemnum("bb2_pwrupbubble.pulse"))
  pProps = []
  return(1)
  exit
end

on deconstruct(me)
  pProps = []
  return(1)
  exit
end

on definePulse(me)
  pPulseState = #Opening
  pSprite = sprite(me.GET(#sprite))
  pStartloc = me.GET(#humanLoc) + point(0, -20)
  pStopLoc = me.GET(#stoploc)
  pSprite.loc = pStartloc
  pSprite.member = pMember
  pSprite.color = me.GET(#balloonColor)
  return(1)
  exit
end

on removePulse(me)
  if voidp(pSprite) then
    return(0)
  end if
  pSprite.locV = -1000
  pPulseState = #hide
  return(1)
  exit
end

on OpeningBalloon(me, tLocV)
  if pPulseState <> #Opening then
    return(0)
  end if
  if pStartloc.locV + tLocV <= pStopLoc.locV then
    pPulseState = #ready
    pSprite.locV = -1000
  else
    pStartloc = pStartloc + point(0, tLocV)
    pSprite.loc = pStartloc
  end if
  exit
end

on set(me, tKey, tValue)
  pProps.setAt(tKey, tValue)
  return(1)
  exit
end

on GET(me, tKey)
  tValue = pProps.getAt(tKey)
  if voidp(tValue) then
    tValue = 0
  end if
  return(tValue)
  exit
end