property pSprite, areaWidth, areaHeight, pKeskipiste, pMuutos, pFromLeft, pMaksimi, pMuutos2, v, vm

on beginSprite me 
  pSprite = sprite(me.spriteNum)
  areaWidth = 20
  areaHeight = 220
  pKeskipiste = pSprite.width + random(areaWidth) - pSprite.width
  v = random(areaHeight)
  vm = random(3)
  pMuutos = random(10)
  pMuutos2 = random(10)
  pMaksimi = areaWidth - areaWidth - pKeskipiste / 2
  pFromLeft = 310
end

on exitFrame me 
  pMuutos = pMuutos + 7
  pSprite.locH = pFromLeft + pKeskipiste - pMaksimi * sin(pMuutos * pi() / 180) * sin(pMuutos2 * pi() / 180)
  pSprite.locV = v
  v = v - vm
  if v <= -pSprite.height then
    replace(me)
  end if
end

on replace me 
  v = areaHeight
  vm = random(3)
  pKeskipiste = pSprite.width + random(areaWidth) - pSprite.width
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = areaWidth - areaWidth - pKeskipiste / 2
end
