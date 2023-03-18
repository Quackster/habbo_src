property pWindowID, pTargetElementID, pTargetWindowID, pLocX, pLocY, pText, pOffsetX, pOffsetY, pDirection, pSpecial, pWindow, pWindowType, pTextWidth, pTextHeight, pWriter, pFadeState, pFaded, pTextOffset, pEmptySizeX, pEmptySizeY, pPointerX, pPointerY

on construct me
  me.pWindowType = "bubble_text.window"
  me.pFadeState = #ready
  me.pTextWidth = 120
  me.pFaded = 0
  me.Init()
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseEnter)
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseLeave)
  return 1
end

on deconstruct me
  removeWindow(me.pWindowID)
  removeWriter(me.pWriter.getID())
end

on Init me
  if voidp(me.pWindowID) then
    me.pWindowID = getUniqueID()
  end if
  createWindow(pWindowID, "bubble.window")
  me.pWindow = getWindow(pWindowID)
  me.pWindow.merge(me.pWindowType)
  me.selectPointer(6)
  tElem = me.pWindow.getElement("bubble_text")
  me.pWindow.resizeBy(pTextWidth - tElem.getProperty(#width), 0)
  me.pTextHeight = tElem.getProperty(#height)
  tPlainFont = getStructVariable("struct.font.plain")
  tWriterID = getUniqueID()
  createWriter(tWriterID, tPlainFont)
  me.pWriter = getWriter(tWriterID)
  tMetrics = [#wordWrap: 1, #rect: rect(0, 0, pTextWidth, 0)]
  me.pWriter.define(tMetrics)
  me.pWriter.pMember.fixedLineSpace = 11
  me.pEmptySizeX = me.pWindow.getProperty(#width)
  me.pEmptySizeY = me.pWindow.getProperty(#height)
  me.hide()
  return 1
end

on hide me
  me.pWindow.hide()
  me.pTargetWindowID = VOID
end

on show me
  me.pWindow.show()
end

on setText me, tText
  me.pText = tText
  tTextImage = me.pWriter.render(tText).duplicate()
  tElem = me.pWindow.getElement("bubble_text")
  tElem.feedImage(tTextImage)
  tElem.resizeTo(tTextImage.width, tTextImage.height, 1)
  me.pWindow.resizeTo(me.pEmptySizeX, me.pEmptySizeY + tTextImage.height)
  me.updatePointer()
end

on addText me, tText
  me.setText(me.pText & RETURN & RETURN & getText(tText))
end

on getProperty me, tProp
  case tProp of
    #windowID:
      return me.pWindowID
    #targetWindowID:
      return me.pTargetWindowID
    #text:
      return me.pText
    #offset:
      return me.pOffset
    #direction:
      return me.pDirection
    #special:
      return me.pSpecial
  end case
  return VOID
end

on setProperty me, tProperty, tValue
  if listp(tProperty) then
    repeat with i = 1 to tProperty.count
      me.setProperty(tProperty.getPropAt(i), tProperty[i])
    end repeat
  end if
  case tProperty of
    #textKey:
      tText = getText(tValue)
      tText = replaceChunks(tText, "\n", RETURN & RETURN)
      me.setText(tText)
    #targetID:
      me.pTargetElementID = tValue
    #direction:
      me.selectPointer(tValue)
    #offsetx:
      me.pOffsetX = value(tValue)
    #offsety:
      me.pOffsetY = value(tValue)
    #special:
      me.pSpecial = tValue
    otherwise:
      nothing()
  end case
end

on selectPointer me, tPointerNum
  me.pDirection = tPointerNum
  repeat with i = 1 to 8
    tElemName = "pointer_" & i
    if not pWindow.elementExists(tElemName) then
      next repeat
    end if
    if i = tPointerNum then
      pWindow.getElement(tElemName).show()
    else
      pWindow.getElement(tElemName).hide()
    end if
    tElemName = "pointer_" & i & "_shadow"
    if not pWindow.elementExists(tElemName) then
      next repeat
    end if
    if i = tPointerNum then
      pWindow.getElement(tElemName).show()
      next repeat
    end if
    pWindow.getElement(tElemName).hide()
  end repeat
  me.updatePointer()
end

on update me
  if me.pFaded then
    tX1 = me.pWindow.getProperty(#locX)
    tY1 = me.pWindow.getProperty(#locY)
    tX2 = tX1 + me.pWindow.getProperty(#width)
    tY2 = tY1 + me.pWindow.getProperty(#height)
    if not (the mouseLoc).inside(rect(tX1, tY1, tX2, tY2)) then
      me.pFaded = 0
      me.show()
    end if
  end if
  me.updateFade()
  me.updatePosition()
end

on updatePointer me
  case me.pDirection of
    1:
      me.pPointerX = 33
      me.pPointerY = 0
    2:
      me.pPointerX = me.pWindow.getProperty(#width) - 33
      me.pPointerY = 0
    3:
      me.pPointerX = me.pWindow.getProperty(#width)
      me.pPointerY = 26
    4:
      me.pPointerX = me.pWindow.getProperty(#width)
      me.pPointerY = me.pWindow.getProperty(#height) - 26
    5:
      me.pPointerX = me.pWindow.getProperty(#width) - 33
      me.pPointerY = me.pWindow.getProperty(#height)
    6:
      me.pPointerX = 33
      me.pPointerY = me.pWindow.getProperty(#height)
    7:
      me.pPointerX = 0
      me.pPointerY = me.pWindow.getProperty(#height) - 26
    8:
      me.pPointerX = 0
      me.pPointerY = 26
  end case
end

on updatePosition me
  if voidp(me.pTargetElementID) then
    return 1
  end if
  if voidp(me.pTargetWindowID) then
    if not me.findTargetWindow() then
      me.hide()
      return 1
    end if
  end if
  tTargetWindow = getWindow(me.pTargetWindowID)
  if not tTargetWindow then
    me.hide()
    return 1
  end if
  if not tTargetWindow.getProperty(#visible) then
    me.hide()
    return 1
  end if
  tTargetElem = getWindow(me.pTargetWindowID).getElement(me.pTargetElementID)
  if not tTargetElem then
    me.hide()
    return 1
  end if
  if not tTargetElem.getProperty(#visible) then
    me.hide()
    return 1
  end if
  tTargetSprite = tTargetElem.getProperty(#sprite)
  tTargetRect = tTargetSprite.rect
  tX = tTargetRect[1] + me.pOffsetX - me.pPointerX
  tY = tTargetRect[2] + me.pOffsetY - me.pPointerY
  me.pWindow.moveTo(tX, tY)
  if not me.pFaded then
    me.pWindow.show()
  end if
end

on findTargetWindow me
  tWindowList = getWindowIDList()
  repeat with tWindowID in tWindowList
    if getWindow(tWindowID).elementExists(me.pTargetElementID) then
      me.pTargetWindowID = tWindowID
      return 1
    end if
  end repeat
  return 0
end

on updateFade me
  if me.pFadeState = #ready then
    return 1
  end if
  tFadeSpeed = 5
  tUpperLimit = 100
  tLowerLimit = 0
  tElemBG = me.pWindow.getElement("bubble_bg")
  tBlend = tElemBG.getProperty(#blend)
  case me.pFadeState of
    #in:
      tNewBlend = tBlend + tFadeSpeed
    #out:
      tNewBlend = tBlend - tFadeSpeed
  end case
  if tNewBlend >= tUpperLimit then
    tNewBlend = tUpperLimit
    me.pFadeState = #ready
  end if
  if tNewBlend <= tLowerLimit then
    tNewBlend = tLowerLimit
    me.pFadeState = #ready
    me.pFaded = 1
    me.pWindow.hide()
  end if
  if me.pFadeState = #ready then
    removeUpdate(me.getID())
  end if
  tElemList = me.pWindow.getProperty(#elementList)
  repeat with tElem in tElemList
    if tElemList.getOne(tElem) contains "shadow" then
      next repeat
    end if
    tElem.setProperty(#blend, tNewBlend)
  end repeat
end

on blendHandler me, tEvent, tSpriteID, tParam
  case tEvent of
    #mouseEnter:
      me.pFadeState = #out
    #mouseLeave:
      me.pFadeState = #in
  end case
  receiveUpdate(me.getID())
end
