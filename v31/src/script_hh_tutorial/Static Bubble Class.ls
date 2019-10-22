property pLocX, pLocY, pTargetX, pTargetY, pBubbleId

on construct me 
  me.pWindowType = "bubble_text.window"
  me.pTextWidth = 160
  pLocX = -1000
  pLocY = 0
  pTargetX = pLocX
  pTargetY = pLocY
  pBubbleId = void()
  me.Init()
  me.pWindow.registerProcedure(#eventHandler, me.getID(), #mouseUp)
  return TRUE
end

on setProperty me, tProperty, tValue 
  if listp(tProperty) then
    i = 1
    repeat while i <= tProperty.count
      me.setProperty(tProperty.getPropAt(i), tProperty.getAt(i))
      i = (1 + i)
    end repeat
  end if
  if (tProperty = #bubbleId) then
    pBubbleId = tValue
  else
    if (tProperty = #targetX) then
      pTargetX = tValue
      me.selectPointerAndPosition(me.pDirection)
    else
      if (tProperty = #targetY) then
        pTargetY = tValue
        me.selectPointerAndPosition(me.pDirection)
      else
        callAncestor(#setProperty, [me], tProperty, tValue)
      end if
    end if
  end if
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
    return FALSE
  end if
  tCloseElemId = "bubble_close"
  if me.pWindow.elementExists(tCloseElemId) then
    tTextElem = me.pWindow.getElement("bubble_text")
    tCloseElem = me.pWindow.getElement(tCloseElemId)
  end if
  me.selectPointerAndPosition(me.pDirection)
end

on selectPointerAndPosition me, tPointerIndex 
  callAncestor(#selectPointer, [me], tPointerIndex)
  if not objectp(me.pWindow) then
    return FALSE
  end if
  tMarginH = 20
  tMarginV = 15
  if (tPointerIndex = 1) then
    me.pWindow.moveTo((pTargetX - tMarginH), pTargetY)
  else
    if (tPointerIndex = 2) then
      me.pWindow.moveTo(((pTargetX - me.pWindow.getProperty(#width)) + tMarginH), pTargetY)
    else
      if (tPointerIndex = 3) then
        me.pWindow.moveTo((pTargetX - me.pWindow.getProperty(#width)), (pTargetY - tMarginV))
      else
        if (tPointerIndex = 4) then
          me.pWindow.moveTo((pTargetX - me.pWindow.getProperty(#width)), ((pTargetY - me.pWindow.getProperty(#height)) + tMarginV))
        else
          if (tPointerIndex = 5) then
            me.pWindow.moveTo(((pTargetX - me.pWindow.getProperty(#width)) + tMarginH), (pTargetY - me.pWindow.getProperty(#height)))
          else
            if (tPointerIndex = 6) then
              me.pWindow.moveTo((pTargetX - tMarginH), (pTargetY - me.pWindow.getProperty(#height)))
            else
              if (tPointerIndex = 7) then
                me.pWindow.moveTo(pTargetX, ((pTargetY - me.pWindow.getProperty(#height)) + tMarginV))
              else
                if (tPointerIndex = 8) then
                  me.pWindow.moveTo(pTargetX, (pTargetY - tMarginV))
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on hideCloseButton me 
  tWndObj = getWindow(me.pWindowID)
  if objectp(tWndObj) then
    if tWndObj.elementExists("bubble_close") then
      tElem = tWndObj.getElement("bubble_close")
      tElem.setProperty(#visible, 0)
    end if
  end if
end

on eventHandler me, tEvent, tSpriteID, tParam 
  if (tSpriteID = "bubble_close") then
    executeMessage(#NUH_close, pBubbleId)
  end if
end
