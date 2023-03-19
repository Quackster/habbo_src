property pSprite, pInitialLoc, pDir, pMoveTarget, pMoving, pMoveTime, pMovementTimer, pPixelsPerTimeX, pPixelsPerTimeY, pBoundsX, pBoundsY, pSplashFrameCount, pSplashFrame, pAnimTimeoutMax, pAnimTimeout

on define me, tsprite
  pSprite = tsprite
  pSplashFrameCount = 4
  pSplashFrame = random(pSplashFrameCount)
  pAnimTimeoutMax = 4
  pAnimTimeout = pAnimTimeoutMax
  tMemName = pSprite.member.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tTemp = tMemName.item[1]
  pDir = chars(tTemp, tTemp.length, tTemp.length)
  the itemDelimiter = tDelim
  pInitialLoc = tsprite.loc
  tMoveMargin = 8
  pBoundsX = [pInitialLoc[1] - tMoveMargin, pInitialLoc[1] + tMoveMargin]
  pBoundsY = [pInitialLoc[2] - tMoveMargin, pInitialLoc[2] + tMoveMargin]
  me.setNewMoveTarget()
  return 1
end

on setNewMoveTarget me
  pMoving = 0
  tLimitX = pBoundsX[2] - pBoundsX[1]
  tNewX = random(tLimitX) + pBoundsX[1]
  tLimitY = pBoundsY[2] - pBoundsY[1]
  tNewY = random(tLimitY) + pBoundsY[2]
  pMoveTarget = point(tNewX, tNewY)
  pInitialLoc = pSprite.loc
  tDirOptions = [1, 2, 3, 4]
  if pInitialLoc[1] > pMoveTarget[1] then
    tDirOptions.deleteOne(2)
    tDirOptions.deleteOne(4)
  else
    tDirOptions.deleteOne(1)
    tDirOptions.deleteOne(3)
  end if
  if pInitialLoc[2] > pMoveTarget[2] then
    tDirOptions.deleteOne(1)
    tDirOptions.deleteOne(2)
  else
    tDirOptions.deleteOne(3)
    tDirOptions.deleteOne(4)
  end if
  pDir = tDirOptions[1]
  pMoveTime = random(50) + 50
  pMovementTimer = 0
  tMovementDistX = pMoveTarget[1] - pInitialLoc[1]
  tMovementDistY = pMoveTarget[2] - pInitialLoc[2]
  pPixelsPerTimeX = float(tMovementDistX) / pMoveTime
  pPixelsPerTimeY = float(tMovementDistY) / pMoveTime
  me.enableMoving()
end

on enableMoving me
  pMoving = 1
end

on update me
  pAnimTimeout = pAnimTimeout - 1
  if pAnimTimeout < 0 then
    pAnimTimeout = pAnimTimeoutMax
    pSplashFrame = pSplashFrame + 1
    if pSplashFrame > pSplashFrameCount then
      pSplashFrame = 1
    end if
    tMemberName = "duck" & pDir & "_a_0_0_" & pSplashFrame
    tMem = member(getmemnum(tMemberName))
    pSprite.member = tMem
    pSprite.width = tMem.width
    pSprite.height = tMem.height
    if not pMoving then
      return 0
    end if
    pMovementTimer = pMovementTimer + 1
    tCurrX = pInitialLoc[1] + (pMovementTimer * pPixelsPerTimeX)
    tCurrY = pInitialLoc[2] + (pMovementTimer * pPixelsPerTimeY)
    tloc = point(integer(tCurrX), integer(tCurrY))
    pSprite.loc = tloc
    if pMovementTimer > pMoveTime then
      me.setNewMoveTarget()
    end if
  end if
end
