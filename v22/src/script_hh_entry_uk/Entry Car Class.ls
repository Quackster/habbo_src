property pSprite, pOffset, pTurnPnt, pDirection

on define me, tsprite, tCount
  if (tCount mod 2) then
    tdir = #right
  else
    tdir = #left
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tdir
  me.reset()
  return 1
end

on reset me
  tmodel = ["car1", "car1", "bus1", "cab1"][random(4)]
  if (pDirection = #left) then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(740, 498)
    pOffset = [-2, -1]
    pTurnPnt = 488
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(184, 505)
    pOffset = [2, -1]
    pTurnPnt = 490
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if (tmodel = "car1") then
    pSprite.ink = 41
    pSprite.backColor = (random(150) + 20)
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
end

on update me
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