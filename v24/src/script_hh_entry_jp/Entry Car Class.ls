property pDirection, pSprite, pOffset, pTurnPnt

on define me, tsprite, tCount 
  tDirection = #left
  if tCount mod 2 = 1 then
    tDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  me.reset()
  return(1)
end

on reset me 
  tmodel = ["car1", "taxia1", "taxib1", "taxic1", "bus1", "car1"].getAt(random(6))
  if pDirection = #left then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(766, 501)
    pOffset = [-2, -1]
    pTurnPnt = 496
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(180, 501)
    pOffset = [2, -1]
    pTurnPnt = 494
  end if
  pSprite.width = member.width
  pSprite.height = member.height
  if tmodel = "car1" then
    pSprite.ink = 41
    pSprite.backColor = random(150) + 20
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
end

on update me 
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
    return(me.reset())
  end if
end
