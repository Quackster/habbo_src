property pSprite, pAreaWidth, pAreaHeight, v, vm, pMuutos, pMuutos2, pMiddle, pMaksimi, pFromLeft, pDivPi

on define me, tIndex
  pSprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("bubble" & tIndex)
  pAreaWidth = 20
  pAreaHeight = 220
  pFromLeft = 310
  pDivPi = PI / 180
  me.replace()
  return 1
end

on replace me
  v = pAreaHeight
  vm = random(3)
  pMiddle = pSprite.width + (random(pAreaWidth) - pSprite.width)
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = (pAreaWidth - (pAreaWidth - pMiddle)) / 2
end

on update me
  pMuutos = pMuutos + 7
  pSprite.locH = pFromLeft + pMiddle - (pMaksimi * sin(pMuutos * pDivPi) * sin(pMuutos2 * pDivPi))
  pSprite.locV = v
  v = v - vm
  if v <= -pSprite.height then
    me.replace()
  end if
end
