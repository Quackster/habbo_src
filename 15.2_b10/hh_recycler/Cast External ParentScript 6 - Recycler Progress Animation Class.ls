property pWindowObj, pAnimating, pUpperJawElement, pLowerJawElement, pUpperElementDefaultPos, pLowerElementDefaultPos, pUpperFrameOffs, pLowerFrameOffs, pCurrentFrame, pCurrentSkipCounter, pMaxFrames

on construct me
  pWindowObj = VOID
  pAnimating = 0
  pUpperJawElement = VOID
  pLowerJawElement = VOID
  pUpperElementDefaultPos = VOID
  pLowerElementDefaultPos = VOID
  pUpperFrameOffs = getVariableValue("jaw.upper.frame.offsets")
  pLowerFrameOffs = getVariableValue("jaw.lower.frame.offsets")
  pCurrentFrame = 1
  pCurrentSkipCounter = 0
  pMaxFrames = min([pUpperFrameOffs.count, pLowerFrameOffs.count])
end

on deconstruct me
  pWindowObj = VOID
  pAnimating = 0
end

on startAnimation me, tWindowObj
  if voidp(tWindowObj) then
    return 0
  end if
  pWindowObj = tWindowObj
  if pWindowObj.elementExists("rec_jaw_upper") then
    pUpperJawElement = pWindowObj.getElement("rec_jaw_upper")
    pUpperElementDefaultPos = [pUpperJawElement.getProperty(#locH), pUpperJawElement.getProperty(#locV)]
  else
    return 0
  end if
  if pWindowObj.elementExists("rec_jaw_lower") then
    pLowerJawElement = pWindowObj.getElement("rec_jaw_lower")
    pLowerElementDefaultPos = [pLowerJawElement.getProperty(#locH), pLowerJawElement.getProperty(#locV)]
  else
    return 0
  end if
  pCurrentFrame = 1
  pCurrentSkipCounter = 0
  pAnimating = 1
  receivePrepare(me.getID())
end

on stopAnimation me
  pAnimating = 0
  removePrepare(me.getID())
  if not voidp(pWindowObj) then
    if pWindowObj.elementExists("rec_jaw_upper") then
      pWindowObj.getElement("rec_jaw_upper").setProperty(#locV, pUpperElementDefaultPos[1])
      pWindowObj.getElement("rec_jaw_upper").setProperty(#locH, pUpperElementDefaultPos[2])
    end if
    if pWindowObj.elementExists("rec_jaw_lower") then
      pWindowObj.getElement("rec_jaw_lower").setProperty(#locV, pLowerElementDefaultPos[1])
      pWindowObj.getElement("rec_jaw_lower").setProperty(#locH, pLowerElementDefaultPos[2])
    end if
  end if
end

on getElementPosition me, tElementType, tFrame
  tOffsetList = [[0, 0]]
  tDefaultPos = [0, 0]
  case tElementType of
    #upper:
      tOffsetList = pUpperFrameOffs
      tDefaultPos = pUpperElementDefaultPos
    #lower:
      tOffsetList = pLowerFrameOffs
      tDefaultPos = pLowerElementDefaultPos
  end case
  tOffset = [tOffsetList[tFrame][1], tOffsetList[tFrame][2]]
  tPosition = tDefaultPos + tOffset
  return tPosition
end

on prepare me
  if pCurrentSkipCounter <= 0 then
    pCurrentSkipCounter = 4
  else
    pCurrentSkipCounter = pCurrentSkipCounter - 1
    return 0
  end if
  pCurrentFrame = pCurrentFrame + 1
  if pCurrentFrame > pMaxFrames then
    pCurrentFrame = 1
  end if
  if not voidp(pWindowObj) then
    if pWindowObj.elementExists("rec_jaw_upper") then
      tPos = me.getElementPosition(#upper, pCurrentFrame)
      pUpperJawElement.setProperty(#locH, tPos[1])
      pUpperJawElement.setProperty(#locV, tPos[2])
    end if
    if pWindowObj.elementExists("rec_jaw_lower") then
      tPos = me.getElementPosition(#lower, pCurrentFrame)
      pLowerJawElement.setProperty(#locH, tPos[1])
      pLowerJawElement.setProperty(#locV, tPos[2])
    end if
  end if
end
