property pSprite, pOffset, pTurnPnt, pDirection, pInitDelay

on define me, tsprite, tDirection
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 535
  pDirection = tDirection
  me.reset()
  return 1
end

on reset me
  tmodel = ["car1", "car1", "bus1"][random(3)]
  if pDirection = #left then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(735, 421)
    pOffset = [-2, -1]
    pTurnPnt = 535
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(211, 498)
    pOffset = [2, -1]
    pTurnPnt = 535
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  pInitDelay = random(120)
end

on update me
  pInitDelay = pInitDelay - 1
  if pInitDelay > 0 then
    return 0
  end if
  pSprite.loc = pSprite.loc + pOffset
  if pSprite.locH = pTurnPnt then
    pOffset[2] = -pOffset[2]
    tMemName = pSprite.member.name
    tDirNum = integer(tMemName.char[length(tMemName)])
    tDirNum = not (tDirNum - 1) + 1
    tMemName = tMemName.char[1..length(tMemName) - 1] & tDirNum
    pSprite.castNum = getmemnum(tMemName)
  end if
  if pSprite.locV > 500 then
    return me.reset()
  end if
end
