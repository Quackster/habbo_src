property pAreaHeight, pSprite, pAreaWidth, pMiddle, pMuutos, pLocV, pFromLeft, pMaksimi, pDivPi, pMuutos2, pOffV

on define me, tSprite 
  pSprite = tSprite
  pAreaWidth = 20
  pAreaHeight = 500
  pFromLeft = 114
  pDivPi = pi() / 180
  me.replace()
  return(1)
end

on replace me 
  pLocV = random(pAreaHeight)
  pOffV = random(3)
  pMiddle = pSprite.width + random(pAreaWidth) - pSprite.width
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = pAreaWidth - pAreaWidth - pMiddle / 2
end

on update me 
  pMuutos = pMuutos + 7
  pSprite.locV = pLocV
  if pSprite.locV > 354 or pSprite.locV < 244 then
    pSprite.locH = pFromLeft + pMiddle - pMaksimi * sin(pMuutos * pDivPi) * sin(pMuutos2 * pDivPi)
  else
    pSprite.locH = -20
  end if
  pLocV = pLocV - pOffV
  if pLocV <= -pSprite.height then
    me.replace()
  end if
end
