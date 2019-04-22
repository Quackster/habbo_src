property pSprite, pCount, pAdd, pRandom

on define me, tsprite 
  pSprite = tsprite
  me.reset()
  return(1)
end

on reset me 
  pRandom = random(30)
  pSprite.member = getmemnum("twinkle_0")
  pFrameCount = 1
  pCount = 0
  pAdd = 15
  sprite(pSprite).blend = pCount
end

on update me 
  pCount = pCount + pAdd
  if pRandom = 1 then
    if 1 = pCount >= 0 and pCount <= 100 then
      sprite(pSprite).blend = pCount
    else
      if 1 = pCount > 100 then
        pAdd = pAdd * -1
      else
        if 1 = pCount < 0 then
          me.reset()
        end if
      end if
    end if
  else
    me.reset()
  end if
end
