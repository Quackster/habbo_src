on define(me, tSprite)
  pFrameDelay = 2
  pFrames = [1, 1, 2, 1]
  pMemberBase = "Waterfall."
  pSprite = tSprite
  me.reset()
  return(1)
  exit
end

on reset(me)
  pDelayCounter = 0
  pInFrame = 1
  pSprite.member = pMemberBase & 1
  pSprite.blend = 0
  exit
end

on update(me)
  pDelayCounter = pDelayCounter + 1
  if pDelayCounter < pFrameDelay then
    return(1)
  else
    pDelayCounter = 0
    pInFrame = pInFrame + 1
    if pInFrame > pFrames.count then
      pInFrame = 1
      pSprite.blend = 0
    else
      pSprite.blend = 100
      pSprite.member = pMemberBase & pFrames.getAt(pInFrame)
    end if
  end if
  exit
end