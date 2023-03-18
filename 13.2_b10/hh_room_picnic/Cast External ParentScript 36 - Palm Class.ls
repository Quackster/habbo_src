property pAnimCycle, pFrameCounter, pSkipPulseAmount, pSkipPulseCounter, pSprite, pPauseTimer

on define me, tSprite
  pSprite = tSprite
  pAnimCycle = [1, 2, 3, 2]
  pFrameCounter = random(10)
  pSkipPulseCounter = 1
  pSkipPulseAmount = 12
  pPauseTimer = random(20)
  return 1
end

on update me
  if pPauseTimer > 0 then
    pPauseTimer = pPauseTimer - 1
    return 1
  end if
  pSkipPulseCounter = pSkipPulseCounter + 1
  if pSkipPulseCounter > pSkipPulseAmount then
    pSkipPulseCounter = 1
    pFrameCounter = pFrameCounter + 1
    if pFrameCounter > pAnimCycle.count then
      pFrameCounter = 1
      pPauseTimer = random(100)
    end if
    pSprite.castNum = getmemnum("palmtop" & pAnimCycle[pFrameCounter])
  end if
end
