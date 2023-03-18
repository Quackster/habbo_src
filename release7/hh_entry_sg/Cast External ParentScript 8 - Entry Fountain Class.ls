property pSprite, pDelayAmount, pDelayCounter, pFrame, pStartFrame, pLastFrame, pFountainModel

on define me, tSprite, tmodel
  pSprite = tSprite
  pDelayAmount = 0
  pDelayCounter = 0
  pStartFrame = 1
  pLastFrame = 3
  pFrame = pStartFrame
  pFountainModel = tmodel
  return 1
end

on update me
  if pDelayCounter < pDelayAmount then
    pDelayCounter = pDelayCounter + 1
    return 1
  end if
  pDelayCounter = 0
  pFrame = pFrame + 1
  if pFrame > pLastFrame then
    pFrame = pStartFrame
  end if
  pSprite.castNum = getmemnum(pFountainModel & pFrame)
end
