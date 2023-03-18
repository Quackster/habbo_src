property pSprite, pOffset, pTurnPnt, pDirection, pmodel, pDelayCounter

on define me, tsprite, tDirection
  pSprite = tsprite
  pOffset = [0, 0]
  pDirection = tDirection
  me.reset()
  return 1
end

on reset me
  pDelayCounter = random(200)
  pmodel = ["car1", "car2", "bus1"][random(3)]
  pSprite.castNum = getmemnum(pmodel & "_1")
  pTurnPnt = 464
  if pDirection = #left then
    pSprite.flipH = 0
    pSprite.loc = point(734, 466)
    pOffset = [-2, -1]
  else
    pSprite.flipH = 1
    pSprite.loc = point(160, 500)
    pOffset = [2, -1]
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  pSprite.ink = 41
  pSprite.backColor = random(150) + 20
end

on update me
  if pDelayCounter > 0 then
    pDelayCounter = pDelayCounter - 1
    return 1
  end if
  pSprite.loc = pSprite.loc + pOffset
  if pSprite.locH = pTurnPnt then
    pOffset[2] = -pOffset[2]
    pSprite.castNum = getmemnum(pmodel & "_2")
  end if
  if pSprite.locV > 510 then
    return me.reset()
  end if
end
