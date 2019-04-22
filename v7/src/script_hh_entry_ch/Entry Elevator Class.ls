property pFloors, pSpriteA, pBottomLimit, pTopLimit, pCurrentFloor, pSpriteB, pContinueTime, pTargetFloor, pmode

on define me, tSpriteA, tSpriteB 
  pSpriteA = tSpriteA
  pSpriteB = tSpriteB
  pmode = #up
  pPause = 0
  pTopLimit = 296
  pBottomLimit = 431
  pFloors = 8
  pCurrentFloor = random(pFloors - 1)
  pContinueTime = the milliSeconds
  pSpriteA.locV = pBottomLimit - pBottomLimit - pTopLimit / pFloors * pCurrentFloor
  pSpriteB.locV = pSpriteA.locV
end

on update me 
  if pContinueTime < the milliSeconds then
    if pSpriteA.locV > pBottomLimit - pBottomLimit - pTopLimit / pFloors * pTargetFloor then
      pSpriteA.locV = pSpriteA.locV - 2
      pSpriteB.locV = pSpriteA.locV
    end if
    if pSpriteA.locV < pBottomLimit - pBottomLimit - pTopLimit / pFloors * pTargetFloor then
      pSpriteA.locV = pSpriteA.locV + 2
      pSpriteB.locV = pSpriteA.locV
    end if
    if abs(pSpriteA.locV - pBottomLimit - pBottomLimit - pTopLimit / pFloors * pTargetFloor) < 2 then
      pContinueTime = the milliSeconds + random(5) + 2 * 1000
      pCurrentFloor = pTargetFloor
      me.modechange()
    end if
  end if
end

on modechange me 
  if pmode = #up then
    if pCurrentFloor = pFloors then
      mode = #down
      me.goDownRandom()
    else
      if random(4) = 1 and pCurrentFloor <> 0 then
        mode = #down
        me.goDownRandom()
      else
        me.goUpRandom()
      end if
    end if
  else
    if pmode = #down then
      if pCurrentFloor = 0 then
        mode = #up
        me.goUpRandom()
      else
        if random(10) = 1 and pCurrentFloor <> pFloors then
          mode = #up
          me.goUpRandom()
        end if
        me.goDownRandom()
      end if
    end if
  end if
end

on goDownRandom me 
  if random(2) = 1 then
    pTargetFloor = 0
    pmode = #up
  else
    pTargetFloor = pCurrentFloor - random(pCurrentFloor) + 1
  end if
end

on goUpRandom me 
  pTargetFloor = random(pFloors - pCurrentFloor) + pCurrentFloor
end
