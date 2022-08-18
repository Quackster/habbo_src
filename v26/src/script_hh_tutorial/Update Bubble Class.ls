property pUpdate, pSkipFrames

on construct me
  pUpdate = 1
  receiveUpdate(me.getID())
  pSkipFrames = 1
  me.pWindowType = "bubble_static.window"
  me.pTextWidth = 160
  pLocX = -1000
  pLocY = 0
  pTargetX = pLocX
  pTargetY = pLocY
  pBubbleId = VOID
  me.Init()
  me.pWindow.registerProcedure(#eventHandler, me.getID(), #mouseUp)
  return 1
end

on deconstruct me
  pUpdate = 0
  removeUpdate(me.getID())
  callAncestor(#deconstruct, [me])
  return 1
end

on setText me, tText
  callAncestor(#setText, [me], tText)
  if not objectp(me.pWindow) then
    return 0
  end if
  tCloseElemId = "bubble_close"
  if me.pWindow.elementExists(tCloseElemId) then
    tTextElem = me.pWindow.getElement("bubble_text")
    tCloseElem = me.pWindow.getElement(tCloseElemId)
    tPosX = (((tTextElem.getProperty(#width) / 2) - (tCloseElem.getProperty(#width) / 2)) - 10)
    tCloseElem.moveBy(tPosX, (tTextElem.getProperty(#height) - 5))
  end if
  me.selectPointerAndPosition(me.pDirection)
end

on update me
  pSkipFrames = not pSkipFrames
  if (pSkipFrames = 1) then
    return 0
  end if
  tRoomComponent = getThread("room").getComponent()
  tOwnRoomId = tRoomComponent.getUsersRoomId(getObject(#session).GET("user_name"))
  tHumanObj = tRoomComponent.getUserObject(tOwnRoomId)
  if (tHumanObj = 0) then
    return 0
  end if
  tHumanLoc = tHumanObj.getPartLocation("hd")
  me.setProperty(#targetX, tHumanLoc[1])
  me.setProperty(#targetY, tHumanLoc[2])
  tSideThreshold = 200
  if objectp(me.pWindow) then
    tSideThreshold = (me.pWindow.getProperty(#width) - 10)
  end if
  if (tHumanLoc[1] < tSideThreshold) then
    me.selectPointerAndPosition(7)
  else
    me.selectPointerAndPosition(4)
  end if
end
