property pSprite, pOffset, pTurnPnt, pDirection, ancestor, pID

on define me, tid, tSprite, tDirection, tAncestor
  pID = tid
  ancestor = tAncestor
  pSprite = tSprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  return 1
end

on reset me
  tmodel = ["car2", "car_b2", "car_c2"][random(3)]
  pSprite.castNum = getmemnum(tmodel)
  if (pDirection = #left) then
    pSprite.flipH = 1
    pSprite.loc = point(635, 478)
    pOffset = [-2, -1]
    pTurnPnt = 439
  else
    pSprite.flipH = 0
    pSprite.loc = point(146, 507)
    pOffset = [2, -1]
    pTurnPnt = 438
  end if
  pSprite.flipH = not pSprite.flipH
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if (random(10) < 6) then
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
    pSprite.width = pSprite.member.width
    pSprite.height = pSprite.member.height
  end if
  if (((pDirection = #left) and (pSprite.locV > 510)) or (((pDirection = #right) and (pSprite.locH > pTurnPnt)) and (pSprite.locV > 490))) then
    me.resetCarAfterDelay(pID)
  end if
end
