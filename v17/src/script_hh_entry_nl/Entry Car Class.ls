property pDirection, pSprite, pInitDelay, pOffset, pTurnPnt

on define me, tsprite, tCount 
  tDirection = #right
  if tCount mod 2 = 1 then
    tDirection = #left
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  me.reset()
  return(1)
end

on reset me 
  tmodel = "car2"
  if pDirection = #left then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(744, 479)
    pOffset = [-2, -1]
    pTurnPnt = 488
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(215, 507)
    pOffset = [2, -1]
    pTurnPnt = 487
  end if
  pSprite.width = member.width
  pSprite.height = member.height
  if tmodel = "car2" then
    pSprite.ink = 41
    pSprite.backColor = random(150) + 20
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pInitDelay = random(120)
end

on update me 
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
  if pSprite.locV > 510 then
    return(me.reset())
  end if
end
