property pSplashFrameCount, pAnimTimeoutMax, pSprite, pInitialLoc, pBoundsX, pBoundsY, pMoveTarget, pMoveTime, pAnimTimeout, pSplashFrame, pDir, pMoving, pMovementTimer, pPixelsPerTimeX, pPixelsPerTimeY

on define me, tsprite 
  pSprite = tsprite
  pSplashFrameCount = 4
  pSplashFrame = random(pSplashFrameCount)
  pAnimTimeoutMax = 4
  pAnimTimeout = pAnimTimeoutMax
  tMemName = member.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tTemp = tMemName.getProp(#item, 1)
  pDir = chars(tTemp, tTemp.length, tTemp.length)
  the itemDelimiter = tDelim
  pInitialLoc = tsprite.loc
  tMoveMargin = 8
  pBoundsX = [pInitialLoc.getAt(1) - tMoveMargin, pInitialLoc.getAt(1) + tMoveMargin]
  pBoundsY = [pInitialLoc.getAt(2) - tMoveMargin, pInitialLoc.getAt(2) + tMoveMargin]
  me.setNewMoveTarget()
  return(1)
end

on setNewMoveTarget me 
  pMoving = 0
  tLimitX = pBoundsX.getAt(2) - pBoundsX.getAt(1)
  tNewX = random(tLimitX) + pBoundsX.getAt(1)
  tLimitY = pBoundsY.getAt(2) - pBoundsY.getAt(1)
  tNewY = random(tLimitY) + pBoundsY.getAt(2)
  pMoveTarget = point(tNewX, tNewY)
  pInitialLoc = pSprite.loc
  tDirOptions = [1, 2, 3, 4]
  if pInitialLoc.getAt(1) > pMoveTarget.getAt(1) then
    tDirOptions.deleteOne(2)
    tDirOptions.deleteOne(4)
  else
    tDirOptions.deleteOne(1)
    tDirOptions.deleteOne(3)
  end if
  if pInitialLoc.getAt(2) > pMoveTarget.getAt(2) then
    tDirOptions.deleteOne(1)
    tDirOptions.deleteOne(2)
  else
    tDirOptions.deleteOne(3)
    tDirOptions.deleteOne(4)
  end if
  pDir = tDirOptions.getAt(1)
  pMoveTime = random(50) + 50
  pMovementTimer = 0
  tMovementDistX = pMoveTarget.getAt(1) - pInitialLoc.getAt(1)
  tMovementDistY = pMoveTarget.getAt(2) - pInitialLoc.getAt(2)
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
      return(0)
    end if
    pMovementTimer = pMovementTimer + 1
    tCurrX = pInitialLoc.getAt(1) + pMovementTimer * pPixelsPerTimeX
    tCurrY = pInitialLoc.getAt(2) + pMovementTimer * pPixelsPerTimeY
    tloc = point(integer(tCurrX), integer(tCurrY))
    pSprite.loc = tloc
    if pMovementTimer > pMoveTime then
      me.setNewMoveTarget()
    end if
  end if
end
