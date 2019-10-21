on construct(me)
  me.pWindowType = "bubble_text.window"
  me.pFadeState = #ready
  me.pTextWidth = 120
  me.pFaded = 0
  me.Init()
  me.registerProcedure(#blendHandler, me.getID(), #mouseEnter)
  me.registerProcedure(#blendHandler, me.getID(), #mouseLeave)
  return(1)
  exit
end

on deconstruct(me)
  removeWindow(me.pWindowID)
  removeWriter(me.getID())
  exit
end

on Init(me)
  if voidp(me.pWindowID) then
    me.pWindowID = "Bubble " & getUniqueID()
  end if
  createWindow(pWindowID, "bubble.window")
  me.pWindow = getWindow(pWindowID)
  me.merge(me.pWindowType)
  me.selectPointer(6)
  tElem = me.getElement("bubble_text")
  me.resizeBy(pTextWidth - tElem.getProperty(#width), 0)
  me.pTextHeight = tElem.getProperty(#height)
  tPlainFont = getStructVariable("struct.font.plain")
  tWriterId = getUniqueID()
  createWriter(tWriterId, tPlainFont)
  me.pWriter = getWriter(tWriterId)
  tMetrics = [#wordWrap:1, #rect:rect(0, 0, pTextWidth, 0)]
  me.define(tMetrics)
  undefined.fixedLineSpace = 11
  me.pEmptySizeX = me.getProperty(#width)
  me.pEmptySizeY = me.getProperty(#height)
  me.hide()
  return(1)
  exit
end

on hide(me)
  me.hide()
  me.pTargetWindowID = void()
  exit
end

on show(me)
  me.show()
  exit
end

on setText(me, tText)
  me.pText = tText
  tTextImage = me.render(tText).duplicate()
  tElem = me.getElement("bubble_text")
  tMarginH = me.getProperty(#height) - tElem.getProperty(#height)
  tElem.feedImage(tTextImage)
  tElem.resizeTo(tTextImage.width, tTextImage.height, 1)
  me.resizeTo(me.pEmptySizeX, tMarginH + tTextImage.height)
  me.updatePointer()
  exit
end

on addText(me, tText)
  me.setText(me.pText & "\r" & "\r" & getText(tText))
  exit
end

on getProperty(me, tProp)
  if me = #windowId then
    return(me.pWindowID)
  else
    if me = #targetWindowID then
      return(me.pTargetWindowID)
    else
      if me = #text then
        return(me.pText)
      else
        if me = #offset then
          return(me.pOffset)
        else
          if me = #direction then
            return(me.pDirection)
          else
            if me = #special then
              return(me.pSpecial)
            end if
          end if
        end if
      end if
    end if
  end if
  return(void())
  exit
end

on setProperty(me, tProperty, tValue)
  if listp(tProperty) then
    i = 1
    repeat while i <= tProperty.count
      me.setProperty(tProperty.getPropAt(i), tProperty.getAt(i))
      i = 1 + i
    end repeat
  end if
  if me = #textKey then
    tText = getText(tValue)
    tText = replaceChunks(tText, "\\n", "\r" & "\r")
    me.setText(tText)
  else
    if me = #targetID then
      me.pTargetElementID = tValue
    else
      if me = #direction then
        me.selectPointer(tValue)
      else
        if me = #offsetx then
          me.pOffsetX = value(tValue)
        else
          if me = #offsety then
            me.pOffsetY = value(tValue)
          else
            if me = #special then
              me.pSpecial = tValue
            else
              nothing()
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end

on selectPointer(me, tPointerNum)
  me.pDirection = tPointerNum
  i = 1
  repeat while i <= 8
    tElemName = "pointer_" & i
    if not pWindow.elementExists(tElemName) then
    else
      if i = tPointerNum then
        pWindow.getElement(tElemName).show()
      else
        pWindow.getElement(tElemName).hide()
      end if
      tElemName = "pointer_" & i & "_shadow"
      if not pWindow.elementExists(tElemName) then
      else
        if i = tPointerNum then
          pWindow.getElement(tElemName).show()
        else
          pWindow.getElement(tElemName).hide()
        end if
      end if
    end if
    i = 1 + i
  end repeat
  me.updatePointer()
  exit
end

on update(me)
  if me.pFaded then
    tX1 = me.getProperty(#locX)
    tY1 = me.getProperty(#locY)
    tX2 = tX1 + me.getProperty(#width)
    tY2 = tY1 + me.getProperty(#height)
    if not the mouseLoc.inside(rect(tX1, tY1, tX2, tY2)) then
      me.pFaded = 0
      me.show()
    end if
  end if
  me.updateFade()
  me.updatePosition()
  exit
end

on updatePointer(me)
  if me = 1 then
    me.pPointerX = 33
    me.pPointerY = 0
  else
    if me = 2 then
      me.pPointerX = me.getProperty(#width) - 33
      me.pPointerY = 0
    else
      if me = 3 then
        me.pPointerX = me.getProperty(#width)
        me.pPointerY = 26
      else
        if me = 4 then
          me.pPointerX = me.getProperty(#width)
          me.pPointerY = me.getProperty(#height) - 26
        else
          if me = 5 then
            me.pPointerX = me.getProperty(#width) - 33
            me.pPointerY = me.getProperty(#height)
          else
            if me = 6 then
              me.pPointerX = 33
              me.pPointerY = me.getProperty(#height)
            else
              if me = 7 then
                me.pPointerX = 0
                me.pPointerY = me.getProperty(#height) - 26
              else
                if me = 8 then
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
  exit
end

on updatePosition(me)
  if voidp(me.pTargetElementID) then
    return(1)
  end if
  if voidp(me.pTargetWindowID) then
    if not me.findTargetWindow() then
      me.hide()
      return(1)
    end if
  end if
  tTargetWindow = getWindow(me.pTargetWindowID)
  if not tTargetWindow then
    me.hide()
    return(1)
  end if
  if not tTargetWindow.getProperty(#visible) then
    me.hide()
    return(1)
  end if
  tTargetElem = getWindow(me.pTargetWindowID).getElement(me.pTargetElementID)
  if not tTargetElem then
    me.hide()
    return(1)
  end if
  if not tTargetElem.getProperty(#visible) then
    me.hide()
    return(1)
  end if
  tTargetSprite = tTargetElem.getProperty(#sprite)
  tTargetRect = tTargetSprite.rect
  tX = tTargetRect.getAt(1) + me.pOffsetX - me.pPointerX
  tY = tTargetRect.getAt(2) + me.pOffsetY - me.pPointerY
  me.moveTo(tX, tY)
  if not me.pFaded then
    me.show()
  end if
  exit
end

on findTargetWindow(me)
  tWindowList = getWindowIDList()
  repeat while me <= undefined
    tWindowID = getAt(undefined, undefined)
    if getWindow(tWindowID).elementExists(me.pTargetElementID) then
      me.pTargetWindowID = tWindowID
      return(1)
    end if
  end repeat
  return(0)
  exit
end

on updateFade(me)
  if me.pFadeState = #ready then
    return(1)
  end if
  tFadeSpeed = 5
  tUpperLimit = 100
  tLowerLimit = 0
  tElemBG = me.getElement("bubble_bg")
  tBlend = tElemBG.getProperty(#blend)
  if me = #in then
    tNewBlend = tBlend + tFadeSpeed
  else
    if me = #out then
      tNewBlend = tBlend - tFadeSpeed
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
    me.hide()
  end if
  if me.pFadeState = #ready then
    removeUpdate(me.getID())
  end if
  tElemList = me.getProperty(#elementList)
  repeat while me <= undefined
    tElem = getAt(undefined, undefined)
    if tElemList.getOne(tElem) contains "shadow" then
    else
      tElem.setProperty(#blend, tNewBlend)
    end if
  end repeat
  exit
end

on blendHandler(me, tEvent, tSpriteID, tParam)
  if me = #mouseEnter then
    me.pFadeState = #out
  else
    if me = #mouseLeave then
      me.pFadeState = #in
    end if
  end if
  receiveUpdate(me.getID())
  exit
end