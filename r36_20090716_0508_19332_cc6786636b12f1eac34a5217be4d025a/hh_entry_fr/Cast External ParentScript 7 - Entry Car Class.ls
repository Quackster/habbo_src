property pSprite, pOffset, pTurnPnt, pDirection, pInitDelay

on define me, tsprite, tCount
  pDirection = #left
  if (tCount mod 2) = 1 then
    pDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  me.reset()
  return 1
end

on reset me
  tmodel = ["car2", "car_b2", "car_c2"][random(3)]
  pSprite.castNum = getmemnum(tmodel)
  if pDirection = #left then
    pSprite.flipH = 1
    pSprite.loc = point(772, 495)
    pOffset = [-2, -1]
    pTurnPnt = 492
  else
    pSprite.flipH = 0
    pSprite.loc = point(228, 507)
    pOffset = [2, -1]
    pTurnPnt = 488
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
  pInitDelay = random(220)
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
    pSprite.width = pSprite.member.width
    pSprite.height = pSprite.member.height
  end if
  if ((pDirection = #left) and (pSprite.locV > 510)) or ((pDirection = #right) and (pSprite.locH > 740)) then
    me.reset()
  end if
end
