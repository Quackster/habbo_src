property pSprite, pDirection, pInitDelay, pOffset, pTurnPnt

on define me, tsprite, tCount 
  pDirection = #left
  if (tCount mod 2) = 1 then
    pDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  me.reset()
  return(1)
end

on reset me 
  tmodel = ["car2", "car_b2", "car_c2"].getAt(random(3))
  pSprite.castNum = getmemnum(tmodel)
  if pDirection = #left then
    pSprite.flipH = 1
    pSprite.loc = point(732, 475)
    pOffset = [-2, -1]
    pTurnPnt = 492
  else
    pSprite.flipH = 0
    pSprite.loc = point(228, 507)
    pOffset = [2, -1]
    pTurnPnt = 488
  end if
  pSprite.flipH = not pSprite.flipH
  pSprite.width = member.width
  pSprite.height = member.height
  if random(10) < 6 then
    pSprite.ink = 41
    pSprite.backColor = random(150) + 20
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pInitDelay = random(220)
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
    pSprite.width = member.width
    pSprite.height = member.height
  end if
  if pDirection = #left and pSprite.locV > 510 or pDirection = #right and pSprite.locH > 740 then
    me.reset()
  end if
end
