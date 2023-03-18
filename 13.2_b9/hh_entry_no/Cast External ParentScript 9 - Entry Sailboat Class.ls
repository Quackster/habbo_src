property pSprite, pCurrentLoc, pXStart, pXEnd, pDelayAmount, pXSpeed, pYSpeed

on define me, tSprite
  pSprite = tSprite
  pXStart = 730
  pXEnd = 280
  pXSpeed = 0.59999999999999998
  pYSpeed = 0.29999999999999999
  me.reset()
  return 1
end

on reset me
  pCurrentLoc = [730, 430]
  pDelayAmount = random(20) + 40
end

on update me
  if pCurrentLoc[1] > pXEnd then
    pCurrentLoc[1] = pCurrentLoc[1] - pXSpeed
    pCurrentLoc[2] = pCurrentLoc[2] - pYSpeed
    pSprite.locH = integer(pCurrentLoc[1])
    pSprite.locV = integer(pCurrentLoc[2])
  else
    pDelayAmount = pDelayAmount - 1
    if pDelayAmount < 0 then
      me.reset()
    end if
  end if
end
