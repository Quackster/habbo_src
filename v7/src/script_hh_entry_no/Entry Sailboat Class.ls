property pCurrentLoc, pXEnd, pXSpeed, pYSpeed, pSprite, pDelayAmount

on define me, tSprite 
  pSprite = tSprite
  pXStart = 730
  pXEnd = 280
  pXSpeed = 0.6
  pYSpeed = 0.3
  me.reset()
  return(1)
end

on reset me 
  pCurrentLoc = [730, 430]
  pDelayAmount = random(20) + 40
end

on update me 
  if pCurrentLoc.getAt(1) > pXEnd then
    pCurrentLoc.setAt(1, pCurrentLoc.getAt(1) - pXSpeed)
    pCurrentLoc.setAt(2, pCurrentLoc.getAt(2) - pYSpeed)
    pSprite.locH = integer(pCurrentLoc.getAt(1))
    pSprite.locV = integer(pCurrentLoc.getAt(2))
  else
    pDelayAmount = pDelayAmount - 1
    if pDelayAmount < 0 then
      me.reset()
    end if
  end if
end
