property pSprite, pRandom, pCount, pAdd, pMyNo

on define me, tsprite, tNo
  pSprite = tsprite
  pMyNo = tNo
  me.reset()
  return 1
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
    case 1 of
      ((pCount >= 0) and (pCount <= 100)):
        sprite(pSprite).blend = pCount
      (pCount > 100):
        pAdd = pAdd * -1
      (pCount < 0):
        me.reset()
    end case
  else
    me.reset()
  end if
end
