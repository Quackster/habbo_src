property pSprite, pOffset, pTurnPnt, pDirection, pWaitTime

on define me, tsprite, tCount
  tDirection = #left
  if ((tCount mod 2) = 1) then
    tDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  me.reset()
  return 1
end

on reset me
  tmodel = "car2"
  if (pDirection = #left) then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(772, 497)
    pOffset = [-2, -1]
    pTurnPnt = 488
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(213, 505)
    pOffset = [2, -1]
    pTurnPnt = 487
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if (tmodel = "car2") then
    pSprite.ink = 41
    pSprite.backColor = (random(150) + 20)
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pWaitTime = random(150)
end

on update me
  pWaitTime = (pWaitTime - 1)
  if (pWaitTime > 0) then
    return 0
  end if
  pSprite.loc = (pSprite.loc + pOffset)
  if (pSprite.locH = pTurnPnt) then
    pOffset[2] = -pOffset[2]
    tMemName = pSprite.member.name
    tDirNum = integer(tMemName.char[length(tMemName)])
    tDirNum = (not (tDirNum - 1) + 1)
    tMemName = (tMemName.char[1] & tDirNum)
    pSprite.castNum = getmemnum(tMemName)
  end if
  if (pSprite.locV > 510) then
    return me.reset()
  end if
end
