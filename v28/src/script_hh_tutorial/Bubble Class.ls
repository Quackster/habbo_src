property pWindowID, pTextWidth, pWindow

on construct me 
  me.pWindowType = "bubble_text.window"
  me.pFadeState = #ready
  me.pTextWidth = 120
  me.pFaded = 0
  me.Init()
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseEnter)
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseLeave)
  return TRUE
end

on deconstruct me 
  removeWindow(me.pWindowID)
  removeWriter(me.pWriter.getID())
end

on Init me 
  if voidp(me.pWindowID) then
    me.pWindowID = "Bubble " & getUniqueID()
  end if
  createWindow(pWindowID, "bubble.window")
  me.pWindow = getWindow(pWindowID)
  me.pWindow.merge(me.pWindowType)
  me.selectPointer(6)
  tElem = me.pWindow.getElement("bubble_text")
  me.pWindow.resizeBy((pTextWidth - tElem.getProperty(#width)), 0)
  me.pTextHeight = tElem.getProperty(#height)
  tPlainFont = getStructVariable("struct.font.plain")
  tWriterId = getUniqueID()
  createWriter(tWriterId, tPlainFont)
  me.pWriter = getWriter(tWriterId)
  tMetrics = [#wordWrap:1, #rect:rect(0, 0, pTextWidth, 0)]
  me.pWriter.define(tMetrics)
  me.pWriter.pMember.fixedLineSpace = 11
  me.pEmptySizeX = me.pWindow.getProperty(#width)
  me.pEmptySizeY = me.pWindow.getProperty(#height)
  me.hide()
  return TRUE
end

on hide me 
  me.pWindow.hide()
  me.pTargetWindowID = void()
end

on show me 
  me.pWindow.show()
end

on setText me, tText 
  me.pText = tText
  tTextImage = me.pWriter.render(tText).duplicate()
  tElem = me.pWindow.getElement("bubble_text")
  tMarginH = (me.pWindow.getProperty(#height) - tElem.getProperty(#height))
  tElem.feedImage(tTextImage)
  tElem.resizeTo(tTextImage.width, tTextImage.height, 1)
  me.pWindow.resizeTo(me.pEmptySizeX, (tMarginH + tTextImage.height))
  me.updatePointer()
end

on addText me, tText 
  me.setText(me.pText & "\r" & "\r" & getText(tText))
end

on getProperty me, tProp 
  if (tProp = #windowId) then
    return(me.pWindowID)
  else
    if (tProp = #targetWindowID) then
      return(me.pTargetWindowID)
    else
      if (tProp = #text) then
        return(me.pText)
      else
        if (tProp = #offset) then
          return(me.pOffset)
        else
          if (tProp = #direction) then
            return(me.pDirection)
          else
            if (tProp = #special) then
              return(me.pSpecial)
            end if
          end if
        end if
      end if
    end if
  end if
  return(void())
end

on setProperty me, tProperty, tValue 
  if listp(tProperty) then
    i = 1
    repeat while i <= tProperty.count
      me.setProperty(tProperty.getPropAt(i), tProperty.getAt(i))
      i = (1 + i)
    end repeat
  end if
  if (tProperty = #textKey) then
    tText = getText(tValue)
    tText = replaceChunks(tText, "\\n", "\r" & "\r")
    me.setText(tText)
  else
    if (tProperty = #targetID) then
      me.pTargetElementID = tValue
    else
      if (tProperty = #direction) then
        me.selectPointer(tValue)
      else
        if (tProperty = #offsetx) then
          me.pOffsetX = value(tValue)
        else
          if (tProperty = #offsety) then
            me.pOffsetY = value(tValue)
          else
            if (tProperty = #special) then
              me.pSpecial = tValue
            else
              nothing()
            end if
          end if
        end if
      end if
    end if
  end if
end

on selectPointer me, tPointerNum 
  me.pDirection = tPointerNum
  i = 1
  repeat while i <= 8
    tElemName = "pointer_" & i
    if not pWindow.elementExists(tElemName) then
    else
      if (i = tPointerNum) then
        pWindow.getElement(tElemName).show()
      else
        pWindow.getElement(tElemName).hide()
      end if
      tElemName = "pointer_" & i & "_shadow"
      if not pWindow.elementExists(tElemName) then
      else
        if (i = tPointerNum) then
          pWindow.getElement(tElemName).show()
        else
          pWindow.getElement(tElemName).hide()
        end if
      end if
    end if
    i = (1 + i)
  end repeat
  me.updatePointer()
end

on update me 
  if me.pFaded then
    tX1 = me.pWindow.getProperty(#locX)
    tY1 = me.pWindow.getProperty(#locY)
    tX2 = (tX1 + me.pWindow.getProperty(#width))
    tY2 = (tY1 + me.pWindow.getProperty(#height))
    if not the mouseLoc.inside(rect(tX1, tY1, tX2, tY2)) then
      me.pFaded = 0
      me.show()
    end if
  end if
  me.updateFade()
  me.updatePosition()
end

on updatePointer me 
  if (me.pDirection = 1) then
    me.pPointerX = 33
    me.pPointerY = 0
  else
    if (me.pDirection = 2) then
      me.pPointerX = (me.pWindow.getProperty(#width) - 33)
      me.pPointerY = 0
    else
      if (me.pDirection = 3) then
        me.pPointerX = me.pWindow.getProperty(#width)
        me.pPointerY = 26
      else
        if (me.pDirection = 4) then
          me.pPointerX = me.pWindow.getProperty(#width)
          me.pPointerY = (me.pWindow.getProperty(#height) - 26)
        else
          if (me.pDirection = 5) then
            me.pPointerX = (me.pWindow.getProperty(#width) - 33)
            me.pPointerY = me.pWindow.getProperty(#height)
          else
            if (me.pDirection = 6) then
              me.pPointerX = 33
              me.pPointerY = me.pWindow.getProperty(#height)
            else
              if (me.pDirection = 7) then
                me.pPointerX = 0
                me.pPointerY = (me.pWindow.getProperty(#height) - 26)
              else
                if (me.pDirection = 8) then
                  me.pPointerX = 0
                  me.pPointerY = 26
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on updatePosition me 
  if voidp(me.pTargetElementID) then
    return TRUE
  end if
  if voidp(me.pTargetWindowID) then
    if not me.findTargetWindow() then
      me.hide()
      return TRUE
    end if
  end if
  tTargetWindow = getWindow(me.pTargetWindowID)
  if not tTargetWindow then
    me.hide()
    return TRUE
  end if
  if not tTargetWindow.getProperty(#visible) then
    me.hide()
    return TRUE
  end if
  tTargetElem = getWindow(me.pTargetWindowID).getElement(me.pTargetElementID)
  if not tTargetElem then
    me.hide()
    return TRUE
  end if
  if not tTargetElem.getProperty(#visible) then
    me.hide()
    return TRUE
  end if
  tTargetSprite = tTargetElem.getProperty(#sprite)
  tTargetRect = tTargetSprite.rect
  tX = ((tTargetRect.getAt(1) + me.pOffsetX) - me.pPointerX)
  tY = ((tTargetRect.getAt(2) + me.pOffsetY) - me.pPointerY)
  me.pWindow.moveTo(tX, tY)
  if not me.pFaded then
    me.pWindow.show()
  end if
end

on findTargetWindow me 
  tWindowList = getWindowIDList()
  repeat while tWindowList <= undefined
    tWindowID = getAt(undefined, undefined)
    if getWindow(tWindowID).elementExists(me.pTargetElementID) then
      me.pTargetWindowID = tWindowID
      return TRUE
    end if
  end repeat
  return FALSE
end

on updateFade me 
  if (me.pFadeState = #ready) then
    return TRUE
  end if
  tFadeSpeed = 5
  tUpperLimit = 100
  tLowerLimit = 0
  tElemBG = me.pWindow.getElement("bubble_bg")
  tBlend = tElemBG.getProperty(#blend)
  if (me.pFadeState = #in) then
    tNewBlend = (tBlend + tFadeSpeed)
  else
    if (me.pFadeState = #out) then
      tNewBlend = (tBlend - tFadeSpeed)
    end if
  end if
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
  if (me.pFadeState = #ready) then
    removeUpdate(me.getID())
  end if
  tElemList = me.pWindow.getProperty(#elementList)
  repeat while me.pFadeState <= undefined
    tElem = getAt(undefined, undefined)
    if tElemList.getOne(tElem) contains "shadow" then
    else
      tElem.setProperty(#blend, tNewBlend)
    end if
  end repeat
end

on blendHandler me, tEvent, tSpriteID, tParam 
  if (tEvent = #mouseEnter) then
    me.pFadeState = #out
  else
    if (tEvent = #mouseLeave) then
      me.pFadeState = #in
    end if
  end if
  receiveUpdate(me.getID())
end
