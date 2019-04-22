on construct(me)
  pWindowObj = void()
  pAnimating = 0
  pUpperJawElement = void()
  pLowerJawElement = void()
  pUpperElementDefaultPos = void()
  pLowerElementDefaultPos = void()
  pUpperFrameOffs = getVariableValue("jaw.upper.frame.offsets")
  pLowerFrameOffs = getVariableValue("jaw.lower.frame.offsets")
  pCurrentFrame = 1
  pCurrentSkipCounter = 0
  pMaxFrames = min([pUpperFrameOffs.count, pLowerFrameOffs.count])
  exit
end

on deconstruct(me)
  pWindowObj = void()
  pAnimating = 0
  exit
end

on startAnimation(me, tWindowObj)
  if voidp(tWindowObj) then
    return(0)
  end if
  pWindowObj = tWindowObj
  if pWindowObj.elementExists("rec_jaw_upper") then
    pUpperJawElement = pWindowObj.getElement("rec_jaw_upper")
    pUpperElementDefaultPos = [pUpperJawElement.getProperty(#locH), pUpperJawElement.getProperty(#locV)]
  else
    return(0)
  end if
  if pWindowObj.elementExists("rec_jaw_lower") then
    pLowerJawElement = pWindowObj.getElement("rec_jaw_lower")
    pLowerElementDefaultPos = [pLowerJawElement.getProperty(#locH), pLowerJawElement.getProperty(#locV)]
  else
    return(0)
  end if
  pCurrentFrame = 1
  pCurrentSkipCounter = 0
  pAnimating = 1
  receivePrepare(me.getID())
  exit
end

on stopAnimation(me)
  pAnimating = 0
  removePrepare(me.getID())
  if not voidp(pWindowObj) then
    if pWindowObj.elementExists("rec_jaw_upper") then
      pWindowObj.getElement("rec_jaw_upper").setProperty(#locV, pUpperElementDefaultPos.getAt(1))
      pWindowObj.getElement("rec_jaw_upper").setProperty(#locH, pUpperElementDefaultPos.getAt(2))
    end if
    if pWindowObj.elementExists("rec_jaw_lower") then
      pWindowObj.getElement("rec_jaw_lower").setProperty(#locV, pLowerElementDefaultPos.getAt(1))
      pWindowObj.getElement("rec_jaw_lower").setProperty(#locH, pLowerElementDefaultPos.getAt(2))
    end if
  end if
  exit
end

on getElementPosition(me, tElementType, tFrame)
  tOffsetList = [[0, 0]]
  tDefaultPos = [0, 0]
  if me = #upper then
    tOffsetList = pUpperFrameOffs
    tDefaultPos = pUpperElementDefaultPos
  else
    if me = #lower then
      tOffsetList = pLowerFrameOffs
      tDefaultPos = pLowerElementDefaultPos
    end if
  end if
  tOffset = [tOffsetList.getAt(tFrame).getAt(1), tOffsetList.getAt(tFrame).getAt(2)]
  tPosition = tDefaultPos + tOffset
  return(tPosition)
  exit
end

on prepare(me)
  if pCurrentSkipCounter <= 0 then
    pCurrentSkipCounter = 4
  else
    pCurrentSkipCounter = pCurrentSkipCounter - 1
    return(0)
  end if
  pCurrentFrame = pCurrentFrame + 1
  if pCurrentFrame > pMaxFrames then
    pCurrentFrame = 1
  end if
  if not voidp(pWindowObj) then
    if pWindowObj.elementExists("rec_jaw_upper") then
      tPos = me.getElementPosition(#upper, pCurrentFrame)
      pUpperJawElement.setProperty(#locH, tPos.getAt(1))
      pUpperJawElement.setProperty(#locV, tPos.getAt(2))
    end if
    if pWindowObj.elementExists("rec_jaw_lower") then
      tPos = me.getElementPosition(#lower, pCurrentFrame)
      pLowerJawElement.setProperty(#locH, tPos.getAt(1))
      pLowerJawElement.setProperty(#locV, tPos.getAt(2))
    end if
  end if
  exit
end