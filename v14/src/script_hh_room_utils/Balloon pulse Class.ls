property pSprite, pStartloc, pMember, pPulseState, pStopLoc, pProps

on construct me 
  pMember = member(getmemnum("balloon.pulse"))
  pProps = [:]
  return TRUE
end

on deconstruct me 
  pProps = [:]
  return TRUE
end

on definePulse me 
  pPulseState = #Opening
  pSprite = sprite(me.GET(#sprite))
  pStartloc = (me.GET(#humanLoc) + point(0, -20))
  pStopLoc = me.GET(#stoploc)
  pSprite.loc = pStartloc
  pSprite.member = pMember
  pSprite.color = me.GET(#balloonColor)
  return TRUE
end

on removePulse me 
  if voidp(pSprite) then
    return FALSE
  end if
  pSprite.locV = -1000
  pPulseState = #hide
  return TRUE
end

on OpeningBalloon me, tLocV 
  if pPulseState <> #Opening then
    return FALSE
  end if
  if (pStartloc.locV + tLocV) <= pStopLoc.locV then
    pPulseState = #ready
    pSprite.locV = -1000
  else
    pStartloc = (pStartloc + point(0, tLocV))
    pSprite.loc = pStartloc
  end if
end

on set me, tKey, tValue 
  pProps.setAt(tKey, tValue)
  return TRUE
end

on GET me, tKey 
  tValue = pProps.getAt(tKey)
  if voidp(tValue) then
    tValue = 0
  end if
  return(tValue)
end
