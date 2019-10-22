property pAreaWidth, pAreaHeight, pSprite, pMiddle, pMuutos, pFromLeft, pMaksimi, pDivPi, pMuutos2, pLocV, pOffV

on define me, tsprite, tLocH 
  pSprite = tsprite
  pAreaWidth = 185
  pAreaHeight = 234
  pFromLeft = (tLocH - (pAreaWidth / 2))
  pDivPi = (pi() / 180)
  me.replace()
  return TRUE
end

on replace me 
  pLocV = pAreaHeight
  pOffV = random(3)
  pMiddle = (pSprite.width + (random(pAreaWidth) - pSprite.width))
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = ((pAreaWidth - (pAreaWidth - pMiddle)) / 2)
end

on update me 
  pMuutos = (pMuutos + 7)
  pSprite.locH = ((pFromLeft + pMiddle) - ((pMaksimi * sin((pMuutos * pDivPi))) * sin((pMuutos2 * pDivPi))))
  pSprite.locV = pLocV
  pLocV = (pLocV - pOffV)
  if pLocV <= 80 then
    me.replace()
  end if
end
