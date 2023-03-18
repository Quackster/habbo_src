property pSprite, pOffset, pTurnPnt, pDirection, pWaitTime

on define me, tsprite, tCount
  tDirection = #left
  if (tCount mod 2) = 1 then
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
  tmodel = ["car2", "car_b2", "car_c2"][random(3)]
  pSprite.castNum = getmemnum(tmodel)
  if pDirection = #left then
    pSprite.flipH = 1
    pSprite.loc = point(490, 415)
    pOffset = [-2, -1]
    pTurnPnt = 180
  else
    pSprite.flipH = 0
    pSprite.loc = point(-20, 380)
    pOffset = [2, -1]
    pTurnPnt = 178
  end if
  pSprite.flipH = not pSprite.flipH
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if random(10) < 6 then
    pSprite.ink = 41
    pSprite.backColor = random(150) + 20
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pWaitTime = random(250)
end

on update me
  pWaitTime = pWaitTime - 1
  if pWaitTime > 0 then
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
    pSprite.width = pSprite.member.width
    pSprite.height = pSprite.member.height
  end if
  if ((pDirection = #left) and (pSprite.locH < -20)) or ((pDirection = #right) and (pSprite.locH > 550)) then
    me.reset()
  end if
end
