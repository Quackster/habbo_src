on define(me, tsprite, tCounter)
  pIndex = tCounter - 1
  if tCounter mod 2 = 1 then
    tDirection = #left
  else
    tDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 535
  pDirection = tDirection
  me.reset()
  return(1)
  exit
end

on reset(me)
  tmodel = ["car1", "car1", "bus1"].getAt(random(3))
  if pDirection = #left then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(893, 500)
    pOffset = [-2, -1]
    pTurnPnt = 535
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(207, 500)
    pOffset = [2, -1]
    pTurnPnt = 535
  end if
  pSprite.width = member.width
  pSprite.height = member.height
  pInitDelay = pIndex * 50 + random(70)
  exit
end

on update(me)
  pInitDelay = pInitDelay - 1
  if pInitDelay > 0 then
    return(0)
  end if
  pSprite.loc = pSprite.loc + pOffset
  if pSprite.locH = pTurnPnt then
    pOffset.setAt(2, -pOffset.getAt(2))
    tMemName = member.name
    tDirNum = integer(tMemName.getProp(#char, length(tMemName)))
    tDirNum = not tDirNum - 1 + 1
    tMemName = tMemName.getProp(#char, 1, length(tMemName) - 1) & tDirNum
    pSprite.castNum = getmemnum(tMemName)
  end if
  if pSprite.locV > 500 then
    if random(2) = 1 then
      pDirection = #left
    else
      pDirection = #right
    end if
    return(me.reset())
  end if
  exit
end