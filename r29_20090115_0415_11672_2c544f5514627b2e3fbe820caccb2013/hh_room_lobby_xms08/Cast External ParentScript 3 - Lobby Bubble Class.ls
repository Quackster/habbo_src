property pSprite, pAreaWidth, pAreaHeight, v, vm, pMuutos, pMuutos2, pMiddle, pMaksimi, pFromLeft, pDivPi

on define me, tIndex, tLocH
  pSprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("bubble" & tIndex)
  pAreaWidth = 20
  pAreaHeight = 220
  pFromLeft = tLocH - (pAreaWidth / 2)
  pDivPi = PI / 180
  me.replace()
  pSprite.locV = pSprite.locV
  v = random(100)
  return 1
end

on replace me
  v = 0
  vm = random(3)
  pMiddle = pSprite.width + (random(pAreaWidth) - pSprite.width)
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = (pAreaWidth - (pAreaWidth - pMiddle)) / 2
end

on update me
  pMuutos = pMuutos + 7
  pSprite.locH = pFromLeft + pMiddle - (pMaksimi * sin(pMuutos * pDivPi) * sin(pMuutos2 * pDivPi))
  pSprite.locV = v / 3
  v = v + vm
  if (v / 3) >= pAreaHeight then
    me.replace()
  end if
end
