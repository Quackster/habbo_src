property pSprite, areaWidth, areaHeight, pKeskipiste, pMuutos, v, pFromLeft, pMaksimi, pMuutos2, vm

on beginSprite me 
  pSprite = sprite(me.spriteNum)
  areaWidth = 20
  areaHeight = 500
  pKeskipiste = pSprite.width + random(areaWidth) - pSprite.width
  v = random(areaHeight)
  vm = random(3)
  pMuutos = random(10)
  pMuutos2 = random(10)
  pMaksimi = areaWidth - areaWidth - pKeskipiste / 2
  pFromLeft = 114
end

on exitFrame me 
  pMuutos = pMuutos + 7
  pSprite.locV = v
  if pSprite.locV > 354 or pSprite.locV < 244 then
    pSprite.locH = pFromLeft + pKeskipiste - pMaksimi * sin(pMuutos * pi() / 180) * sin(pMuutos2 * pi() / 180)
  else
    pSprite.locH = -20
  end if
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
