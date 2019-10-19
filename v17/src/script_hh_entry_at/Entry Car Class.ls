property pMaxStartDelay, pMinStartDelay, pSprite, pModelType, pStartDelay, pHAdv, pVAdv, pTurningPoints

on define me, tsprite, tCarNo 
  pTurningPoints = [434, 534]
  pMinStartDelay = 150
  pMaxStartDelay = 400
  pSprite = tsprite
  me.reset()
  if tCarNo = 1 then
    pStartDelay = 0
  end if
  return(1)
end

on reset me 
  tPos = random(2)
  pModelType = random(2)
  pStartDelay = random(pMaxStartDelay - pMinStartDelay) + pMinStartDelay
  if tPos = 1 then
    pSprite.member = "car" & pModelType & "_up"
    pSprite.flipH = 1
    pHAdv = 2
    pVAdv = -1
    pSprite.locV = 493
    pSprite.locH = 236
  else
    pSprite.member = "car" & pModelType & "_down"
    pSprite.flipH = 0
    pHAdv = -2
    pVAdv = 1
    pSprite.locV = 327
    pSprite.locH = 730
  end if
  pSprite.ink = 41
  pSprite.backColor = random(150) + 20
end

on update me 
  pStartDelay = pStartDelay - 1
  if pStartDelay > 0 then
    return(1)
  end if
  pSprite.locH = pSprite.locH + pHAdv
  pSprite.locV = pSprite.locV + pVAdv
  if pTurningPoints.getPos(pSprite.locH) > 0 then
    if pVAdv > 0 then
      pSprite.member = "car" & pModelType & "_up"
    else
      pSprite.member = "car" & pModelType & "_down"
    end if
    if pHAdv > 0 then
      pSprite.flipH = 1
    else
      pSprite.flipH = 0
    end if
    pVAdv = (pVAdv * -1)
  end if
  if pSprite.locH > 748 or pSprite.locH < 140 then
    me.reset()
  end if
end
