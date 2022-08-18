property pSprite, areaWidth, areaHeight, v, vm, pMuutos, pMuutos2, pKeskipiste, pMaksimi, pFromLeft

on beginSprite me
  pSprite = sprite(me.spriteNum)
  areaWidth = 185
  areaHeight = 234
  pKeskipiste = (pSprite.width + (random(areaWidth) - pSprite.width))
  v = random(areaHeight)
  vm = random(3)
  pMuutos = random(10)
  pMuutos2 = random(10)
  pMaksimi = ((areaWidth - (areaWidth - pKeskipiste)) / 2)
  pFromLeft = 326
end

on exitFrame me
  pMuutos = (pMuutos + 7)
  pSprite.locH = ((pFromLeft + pKeskipiste) - ((pMaksimi * sin(((pMuutos * PI) / 180))) * sin(((pMuutos2 * PI) / 180))))
  pSprite.locV = v
  v = (v - vm)
  if (v <= 80) then
    replace(me)
  end if
end

on replace me
  v = areaHeight
  vm = random(3)
  pKeskipiste = (pSprite.width + (random(areaWidth) - pSprite.width))
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = ((areaWidth - (areaWidth - pKeskipiste)) / 2)
end
