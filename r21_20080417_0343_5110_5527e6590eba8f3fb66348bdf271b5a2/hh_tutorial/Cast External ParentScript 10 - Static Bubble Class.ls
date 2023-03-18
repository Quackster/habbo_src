property pLocX, pLocY, pTargetX, pTargetY, pBubbleId

on construct me
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

on setProperty me, tProperty, tValue
  if listp(tProperty) then
    repeat with i = 1 to tProperty.count
      me.setProperty(tProperty.getPropAt(i), tProperty[i])
    end repeat
  end if
  case tProperty of
    #bubbleId:
      pBubbleId = tValue
    #targetX:
      pTargetX = tValue
      me.selectPointerAndPosition(me.pDirection)
    #targetY:
      pTargetY = tValue
      me.selectPointerAndPosition(me.pDirection)
    otherwise:
      callAncestor(#setProperty, [me], tProperty, tValue)
  end case
end

on moveTo me, tLocX, tLocY
  pLocX = tLocX
  pLocY = tLocY
  if objectp(me.pWindow) then
    me.pWindow.moveTo(pLocX, pLocY)
  end if
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
    tCloseElem.moveTo(tTextElem.getProperty(#width) + tTextElem.getProperty(#locX) + 5, tCloseElem.getProperty(#locY))
  end if
  me.selectPointerAndPosition(me.pDirection)
end

on selectPointerAndPosition me, tPointerIndex
  callAncestor(#selectPointer, [me], tPointerIndex)
  if not objectp(me.pWindow) then
    return 0
  end if
  tMarginH = 20
  tMarginV = 15
  case tPointerIndex of
    1:
      me.pWindow.moveTo(pTargetX - tMarginH, pTargetY)
    2:
      me.pWindow.moveTo(pTargetX - me.pWindow.getProperty(#width) + tMarginH, pTargetY)
    3:
      me.pWindow.moveTo(pTargetX - me.pWindow.getProperty(#width), pTargetY - tMarginV)
    4:
      me.pWindow.moveTo(pTargetX - me.pWindow.getProperty(#width), pTargetY - me.pWindow.getProperty(#height) + tMarginV)
    5:
      me.pWindow.moveTo(pTargetX - me.pWindow.getProperty(#width) + tMarginH, pTargetY - me.pWindow.getProperty(#height))
    6:
      me.pWindow.moveTo(pTargetX - tMarginH, pTargetY - me.pWindow.getProperty(#height))
    7:
      me.pWindow.moveTo(pTargetX, pTargetY - me.pWindow.getProperty(#height) + tMarginV)
    8:
      me.pWindow.moveTo(pTargetX, pTargetY - tMarginV)
  end case
end

on eventHandler me, tEvent, tSpriteID, tParam
  if tSpriteID = "bubble_close" then
    me.hide()
    if threadExists("new_user_help") then
      getThread("new_user_help").getComponent().setHelpItemClosed(pBubbleId)
    end if
  end if
end
