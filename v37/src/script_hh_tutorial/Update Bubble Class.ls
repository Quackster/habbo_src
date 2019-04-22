on construct(me)
  pUpdate = 1
  receiveUpdate(me.getID())
  pSkipFrames = 1
  me.pWindowType = "bubble_static.window"
  me.pTextWidth = 160
  pLocX = -1000
  pLocY = 0
  pTargetX = pLocX
  pTargetY = pLocY
  pBubbleId = void()
  pHumanObj = void()
  me.Init()
  me.registerProcedure(#eventHandler, me.getID(), #mouseUp)
  return(1)
  exit
end

on deconstruct(me)
  pUpdate = 0
  removeUpdate(me.getID())
  callAncestor(#deconstruct, [me])
  return(1)
  exit
end

on setText(me, tText)
  callAncestor(#setText, [me], tText)
  if not objectp(me.pWindow) then
    return(0)
  end if
  tCloseElemId = "bubble_close"
  if me.elementExists(tCloseElemId) then
    tTextElem = me.getElement("bubble_text")
    tCloseElem = me.getElement(tCloseElemId)
    tPosX = tTextElem.getProperty(#width) / 2 - tCloseElem.getProperty(#width) / 2 - 10
    tCloseElem.moveBy(tPosX, tTextElem.getProperty(#height) - 5)
  end if
  me.selectPointerAndPosition(me.pDirection)
  exit
end

on setTargetHumanObj(me, tHumanObj)
  pHumanObj = tHumanObj
  exit
end

on update(me)
  pSkipFrames = not pSkipFrames
  if pSkipFrames = 1 then
    return(0)
  end if
  if pHumanObj = 0 then
    return(0)
  end if
  tHumanLoc = pHumanObj.getPartLocation("hd")
  me.setProperty(#targetX, tHumanLoc.getAt(1))
  me.setProperty(#targetY, tHumanLoc.getAt(2))
  tSideThreshold = 200
  if objectp(me.pWindow) then
    tSideThreshold = me.getProperty(#width) - 10
  end if
  if tHumanLoc.getAt(1) < tSideThreshold then
    me.selectPointerAndPosition(7)
  else
    me.selectPointerAndPosition(4)
  end if
  exit
end