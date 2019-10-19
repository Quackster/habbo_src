property pSprite, pTimer, pVertDir, pTurnPnt

on define me, tSprite, tDirection 
  pSprite = tSprite
  pOffset = [0, 0]
  pTurnPnt = 545
  pDirection = tDirection
  pVertDir = -1
  me.reset()
  return(1)
end

on reset me 
  pSprite.flipH = 0
  pSprite.loc = point(714, 488) + point(random(30), 0)
  pOffset = [-2, -1]
  pTurnPnt = 548
  pSprite.castNum = getmemnum("boat1")
  pVertDir = -1
  pFrameCount = 0
  pTimer = the milliSeconds + 5000 + random(8000)
end

on update me 
  if pTimer > the milliSeconds then
    return()
  end if
  pSprite.locH = pSprite.locH - 1
  if (pSprite.locH mod 2) = 0 then
    pSprite.locV = pSprite.locV + pVertDir
  end if
  if pSprite.locH = pTurnPnt then
    pVertDir = (pVertDir * -1)
    tMemName = member.name
    tDirNum = integer(tMemName.getProp(#char, length(tMemName)))
    tDirNum = not tDirNum - 1 + 1
    tMemName = tMemName.getProp(#char, 1, length(tMemName) - 1) & tDirNum
    pSprite.castNum = getmemnum(tMemName)
  end if
  if pSprite.locV > 500 then
    return(me.reset())
  end if
  pFrameCount = 0
end
