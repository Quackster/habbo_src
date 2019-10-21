on define(me, tSprite)
  pSprite = tSprite
  me.reset()
  return(1)
  exit
end

on reset(me)
  pRandom = random(30)
  pSprite.member = getmemnum("twinkle_0")
  pFrameCount = 1
  pCount = 0
  pAdd = 15
  sprite(pSprite).blend = pCount
  exit
end

on update(me)
  pCount = pCount + pAdd
  if pRandom = 1 then
    if me = pCount >= 0 and pCount <= 100 then
      sprite(pSprite).blend = pCount
    else
      if me = pCount > 100 then
        pAdd = pAdd * -1
      else
        if me = pCount < 0 then
          me.reset()
        end if
      end if
    end if
  else
    me.reset()
  end if
  exit
end