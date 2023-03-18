property pSprite, pAreaWidth, pAreaHeight, pLocV, pOffV, pMuutos, pMuutos2, pMiddle, pMaksimi, pFromLeft, pDivPi

on define me, tSprite
  pSprite = tSprite
  pAreaWidth = 185
  pAreaHeight = 234
  pFromLeft = 326
  pDivPi = PI / 180
  me.replace()
  return 1
end

on replace me
  pLocV = pAreaHeight
  pOffV = random(3)
  pMiddle = pSprite.width + (random(pAreaWidth) - pSprite.width)
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = (pAreaWidth - (pAreaWidth - pMiddle)) / 2
end

on update me
  pMuutos = pMuutos + 7
  pSprite.locH = pFromLeft + pMiddle - (pMaksimi * sin(pMuutos * pDivPi) * sin(pMuutos2 * pDivPi))
  pSprite.locV = pLocV
  pLocV = pLocV - pOffV
  if pLocV <= 80 then
    me.replace()
  end if
end
