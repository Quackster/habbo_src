on define(me, tIndex)
  pSprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("bubble" & tIndex)
  pAreaWidth = 20
  pAreaHeight = 220
  pFromLeft = 310
  pDivPi = pi() / 180
  me.replace()
  return(1)
  exit
end

on replace(me)
  V = pAreaHeight
  vm = random(3)
  pMiddle = pSprite.width + random(pAreaWidth) - pSprite.width
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = pAreaWidth - pAreaWidth - pMiddle / 2
  exit
end

on update(me)
  pMuutos = pMuutos + 7
  pSprite.locH = pFromLeft + pMiddle - pMaksimi * sin(pMuutos * pDivPi) * sin(pMuutos2 * pDivPi)
  pSprite.locV = V
  V = V - vm
  if V <= -pSprite.height then
    me.replace()
  end if
  exit
end