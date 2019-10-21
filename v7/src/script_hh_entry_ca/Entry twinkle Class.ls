on define(me, tSprite)
  pSprite = tSprite
  me.reset()
  return(1)
  exit
end

on reset(me)
  pRandom = random(90) + 18
  pSprite.member = getmemnum("twinkle_0")
  pFrameCount = 1
  pCount = 0
  exit
end

on update(me)
  tFrameList = [0, 1, 2, 3, 4, 5, 6, 7]
  pCount = pCount + 1
  if me = pCount > 0 and pCount <= 15 then
    if pCount mod 2 then
      tImage = getmemnum("twinkle_" & tFrameList.getAt(pFrameCount))
      pSprite.member = tImage
      pFrameCount = pFrameCount + 1
    end if
  else
    if me = pCount = 18 then
      pSprite.member = getmemnum("twinkle_0")
    else
      if me = pCount = pRandom then
        me.reset()
      end if
    end if
  end if
  exit
end