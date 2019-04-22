property pDirection, pSprite, pPauseTime, pOffset, pTurnPnt

on define me, tsprite, tID 
  pID = tID
  if tID mod 2 then
    tdir = #right
  else
    tdir = #left
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tdir
  me.reset()
  return(1)
end

on reset me 
  tmodel = ["car2", "car_b2", "car_c2"].getAt(random(3))
  if pDirection = #left then
    pSprite.flipH = 0
    pSprite.loc = point(675, 498)
    pOffset = [-2, -1]
    pTurnPnt = 439
  else
    pSprite.flipH = 1
    pSprite.loc = point(146, 507)
    pOffset = [2, -1]
    pTurnPnt = 438
  end if
  pSprite.castNum = getmemnum(tmodel)
  pSprite.width = member.width
  pSprite.height = member.height
  if random(10) < 6 then
    pSprite.ink = 41
    pSprite.backColor = random(150) + 20
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pPauseTime = random(150)
end

on update me 
  if pPauseTime > 0 then
    pPauseTime = pPauseTime - 1
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
