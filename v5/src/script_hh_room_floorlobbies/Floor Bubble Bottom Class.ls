on define(me, tSprite)
  pSprite = tSprite
  pAreaWidth = 20
  pAreaHeight = 500
  pFromLeft = 114
  pDivPi = pi() / 180
  me.replace()
  return(1)
  exit
end

on replace(me)
  pLocV = random(pAreaHeight - 235) + 235
  pOffV = random(3)
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMiddle = pSprite.width + random(pAreaWidth) - pSprite.width
  pMaksimi = pAreaWidth - pAreaWidth - pMiddle / 2
  exit
end

on update(me)
  pMuutos = pMuutos + 7
  pSprite.locV = pLocV
  if pSprite.locV > 354 or pSprite.locV < 244 then
    pSprite.locH = pFromLeft + pMiddle - pMaksimi * sin(pMuutos * pDivPi) * sin(pMuutos2 * pDivPi)
  else
    pSprite.locH = -20
  end if
  pLocV = pLocV - pOffV
  if pLocV <= 235 and random(20) > 14 then
    me.replace()
  end if
  exit
end