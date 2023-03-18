property pSprite, pRandom, pFrameCount, pCount

on define me, tsprite
  pSprite = tsprite
  me.reset()
  return 1
end

on reset me
  pRandom = random(90) + 18
  pSprite.member = getmemnum("twinkle_0")
  pFrameCount = 1
  pCount = 0
end

on update me
  tFrameList = [0, 1, 2, 3, 4, 5, 6, 7]
  pCount = pCount + 1
  case 1 of
    ((pCount > 0) and (pCount <= 15)):
      if pCount mod 2 then
        tImage = getmemnum("twinkle_" & tFrameList[pFrameCount])
        pSprite.member = tImage
        pFrameCount = pFrameCount + 1
      end if
    (pCount = 18):
      pSprite.member = getmemnum("twinkle_0")
    (pCount = pRandom):
      me.reset()
  end case
end
