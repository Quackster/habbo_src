property pSprite, pCount, pRandom, pAdd

on define me, tSprite, tNo 
  pSprite = tSprite
  pMyNo = tNo
  me.reset()
  return(1)
end

on reset me 
  pRandom = random(100)
  pSprite.member = getmemnum("twinkle_small")
  pCount = 0
  pAdd = 15
  sprite(pSprite).blend = pCount
end

on update me 
  if pRandom = 1 then
    pCount = pCount + pAdd
    if 1 = pCount >= 0 and pCount <= 100 then
      sprite(pSprite).blend = pCount
    else
      if 1 = pCount > 100 then
        pAdd = (pAdd * -1)
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
