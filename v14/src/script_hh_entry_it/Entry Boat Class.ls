property pSprite, pOffset, pTurnPnt, pDirection, pVertDir, pFrameCount, pTimer

on define me, tSprite
  pSprite = tSprite
  pOffset = [0, 0]
  pTurnPnt = 545
  pDirection = #left
  pVertDir = -1
  me.reset()
  return 1
end

on reset me
  pSprite.flipH = 0
  pSprite.loc = (point(724, 498) + point(random(30), 0))
  pOffset = [-2, -1]
  pTurnPnt = 548
  pSprite.castNum = getmemnum("boat1")
  pVertDir = -1
  pFrameCount = 0
  pTimer = ((the milliSeconds + 5000) + random(8000))
end

on update me
  if (pTimer > the milliSeconds) then
    return 
  end if
  pSprite.locH = (pSprite.locH - 1)
  if ((pSprite.locH mod 2) = 0) then
    pSprite.locV = (pSprite.locV + pVertDir)
  end if
  if (pSprite.locH = pTurnPnt) then
    pVertDir = (pVertDir * -1)
    tMemName = pSprite.member.name
    tDirNum = integer(tMemName.char[length(tMemName)])
    tDirNum = (not (tDirNum - 1) + 1)
    tMemName = (tMemName.char[1] & tDirNum)
    pSprite.castNum = getmemnum(tMemName)
    pSprite.width = pSprite.member.width
    pSprite.height = pSprite.member.height
  end if
  if (pSprite.locV > 500) then
    return me.reset()
  end if
  pFrameCount = 0
end
