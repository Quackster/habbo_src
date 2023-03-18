property pSprite, pCurCount, pAnimFrm, pLocation, pTime

on construct me
  pCurCount = 3
  pAnimFrm = 1
  tlocation = getVariableValue("paalu.counter.loc", [370, 320])
  pLocation = point(tlocation[1], tlocation[2])
  pSprite = sprite(reserveSprite(me.getID()))
  pSprite.member = member(getmemnum("startcount" && pCurCount && pAnimFrm))
  pSprite.ink = 8
  pSprite.visible = 0
  pTime = 0
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if not voidp(pSprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  pSprite = VOID
  return 1
end

on start me
  pCurCount = 3
  pAnimFrm = 1
  pSprite.member = member(getmemnum("startcount" && pCurCount && pAnimFrm))
  pSprite.loc = pLocation
  pSprite.locZ = -10
  pSprite.visible = 1
  pTime = the milliSeconds
  receiveUpdate(me.getID())
end

on update me
  if (the milliSeconds - pTime) >= 1000 then
    pCurCount = pCurCount - 1
    pAnimFrm = 1
    if pCurCount = 0 then
      removeUpdate(me.getID())
      pSprite.visible = 0
      pCurCount = 3
      pAnimFrm = 1
      return 
    end if
    pTime = the milliSeconds
  end if
  if pAnimFrm > 20 then
    pSprite.member = member(0)
  else
    if pAnimFrm < 4 then
      pSprite.member = member(getmemnum("startcount" && pCurCount && pAnimFrm))
    end if
  end if
  pAnimFrm = pAnimFrm + 1
end
