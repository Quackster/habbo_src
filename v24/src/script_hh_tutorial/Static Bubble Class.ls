on construct(me)
  me.pWindowType = "bubble_static.window"
  me.pTextWidth = 160
  pLocX = -1000
  pLocY = 0
  pTargetX = pLocX
  pTargetY = pLocY
  pBubbleId = void()
  me.Init()
  me.registerProcedure(#eventHandler, me.getID(), #mouseUp)
  return(1)
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
  if me = #bubbleId then
    pBubbleId = tValue
  else
    if me = #targetX then
      pTargetX = tValue
      me.selectPointerAndPosition(me.pDirection)
    else
      if me = #targetY then
        pTargetY = tValue
        me.selectPointerAndPosition(me.pDirection)
      else
        callAncestor(#setProperty, [me], tProperty, tValue)
      end if
    end if
  end if
  exit
end

on moveTo(me, tLocX, tLocY)
  pLocX = tLocX
  pLocY = tLocY
  if objectp(me.pWindow) then
    me.moveTo(pLocX, pLocY)
  end if
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
    tCloseElem.moveTo(tTextElem.getProperty(#width) + tTextElem.getProperty(#locX) + 5, tCloseElem.getProperty(#locY))
  end if
  me.selectPointerAndPosition(me.pDirection)
  exit
end

on selectPointerAndPosition(me, tPointerIndex)
  callAncestor(#selectPointer, [me], tPointerIndex)
  if not objectp(me.pWindow) then
    return(0)
  end if
  tMarginH = 20
  tMarginV = 15
  if me = 1 then
    me.moveTo(pTargetX - tMarginH, pTargetY)
  else
    if me = 2 then
      me.moveTo(pTargetX - me.getProperty(#width) + tMarginH, pTargetY)
    else
      if me = 3 then
        me.moveTo(pTargetX - me.getProperty(#width), pTargetY - tMarginV)
      else
        if me = 4 then
          me.moveTo(pTargetX - me.getProperty(#width), pTargetY - me.getProperty(#height) + tMarginV)
        else
          if me = 5 then
            me.moveTo(pTargetX - me.getProperty(#width) + tMarginH, pTargetY - me.getProperty(#height))
          else
            if me = 6 then
              me.moveTo(pTargetX - tMarginH, pTargetY - me.getProperty(#height))
            else
              if me = 7 then
                me.moveTo(pTargetX, pTargetY - me.getProperty(#height) + tMarginV)
              else
                if me = 8 then
                  me.moveTo(pTargetX, pTargetY - tMarginV)
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

on hideCloseButton(me)
  tWndObj = getWindow(me.pWindowID)
  if objectp(tWndObj) then
    if tWndObj.elementExists("bubble_close") then
      tElem = tWndObj.getElement("bubble_close")
      tElem.setProperty(#visible, 0)
    end if
  end if
  exit
end

on eventHandler(me, tEvent, tSpriteID, tParam)
  if tSpriteID = "bubble_close" then
    executeMessage(#NUH_close, pBubbleId)
  end if
  exit
end