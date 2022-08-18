property pSprite, pOffset, pTurnPnt, pDirection, pType, pAnimFrame

on define me, tSprite, tDirection
  pSprite = tSprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  pType = "car"
  pAnimFrame = 1
  me.reset()
  return 1
end

on reset me
  if (pDirection = #left) then
    if (random(2) = 1) then
      tmodel = "car2"
      pType = "car"
    else
      tmodel = "crt2"
      pType = "cart"
    end if
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(584, 283)
    pOffset = [-2, 1]
    pTurnPnt = -1000
  else
    tmodel = "car1"
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(205, 493)
    pOffset = [2, -1]
    pTurnPnt = 333
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if ((tmodel = "car1") or (tmodel = "car2")) then
    pSprite.ink = 41
    pSprite.backColor = (random(150) + 20)
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
end

on update me
  pSprite.loc = (pSprite.loc + pOffset)
  if ((pSprite.locV = pTurnPnt) and (random(2) = 2)) then
    pOffset[2] = -pOffset[2]
    tmodel = "car2"
    pSprite.castNum = getmemnum(tmodel)
  end if
  if (pType = "cart") then
    pAnimFrame = (pAnimFrame + 1)
    if (pAnimFrame > 9) then
      pAnimFrame = 2
    end if
    tFrameNum = (pAnimFrame / 2)
    pSprite.castNum = getmemnum(("crt" & tFrameNum))
    pSprite.width = pSprite.member.width
    pSprite.height = pSprite.member.height
  end if
  if (((pSprite.locV < 283) or (pSprite.locV > 499)) or (pSprite.locH > 730)) then
    return me.reset()
  end if
end
