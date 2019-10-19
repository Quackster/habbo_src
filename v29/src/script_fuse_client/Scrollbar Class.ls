property pAgentID, pParts, pButtonImg, pClientID, pScrollOffset, pClientSourceRect, pScrollStep, pViewClientRect, pClickPass, pState, pRects, pClickPoint, pMaxOffset, pButtonStates, pPageSize

on deconstruct me 
  removeObject(pAgentID)
  return(1)
end

on define me, tProps 
  tField = tProps.getAt(#type) & tProps.getAt(#model) & ".element"
  pParts = getObject(#layout_parser).parse(tField)
  if pParts = 0 then
    return(0)
  end if
  me.pProps = tProps
  me.pID = tProps.getAt(#id)
  me.pMotherId = tProps.getAt(#mother)
  me.pType = tProps.getAt(#type)
  me.pScaleH = tProps.getAt(#scaleH)
  me.pScaleV = tProps.getAt(#scaleV)
  me.pBuffer = tProps.getAt(#buffer)
  me.pSprite = tProps.getAt(#sprite)
  me.pLocX = tProps.getAt(#locX)
  me.pLocY = tProps.getAt(#locY)
  me.pwidth = tProps.getAt(#width)
  me.pheight = tProps.getAt(#height)
  pClientID = tProps.getAt(#client)
  pScrollStep = tProps.getAt(#offset)
  pButtonImg = [:]
  if variableExists("interface.palette") then
    me.pPalette = member(getmemnum(getVariable("interface.palette")))
  else
    me.pPalette = #systemMac
  end if
  pRects = [:]
  pState = #waitMouseEvent
  pScrollOffset = 0
  pButtonStates = [#top:#up, #bottom:#up, #bar:#up, #lift:#up]
  me.UpdateImageObjects(void(), [#up, #down, #passive])
  if me.pType = "scrollbarv" then
    me.pwidth = pButtonImg.getAt("top_up").width
  else
    me.pheight = pButtonImg.getAt("top_up").height
  end if
  me.pimage = image(me.pwidth, me.pheight, 8, me.pPalette)
  me.UpdateScrollBar([#top, #bottom, #bar, #lift], #up)
  tTempOffset = me.regPoint
  me.image = me.pimage
  me.regPoint = tTempOffset
  pAgentID = me.getID() && the milliSeconds
  createObject(pAgentID, getClassVariable("event.agent.class"))
  return(1)
end

on prepare me 
  me.width = me.pwidth
  me.height = me.pheight
  call(#registerScroll, [getWindow(me.pMotherId).getElement(pClientID)], me.pID)
end

on getProperty me, tProp 
  if tProp = #width then
    return(me.pwidth)
  else
    if tProp = #height then
      return(me.pheight)
    else
      if tProp = #locH then
        return(me.pLocX)
      else
        if tProp = #locV then
          return(me.pLocY)
        else
          if tProp = #locX then
            return(me.pLocX)
          else
            if tProp = #locY then
              return(me.pLocY)
            else
              if tProp = #offset then
                return(pScrollOffset)
              else
                if tProp = #scrollrange then
                  if me.pType = "scrollbarv" then
                    return(pClientSourceRect.getAt(4) - pClientSourceRect.getAt(2))
                  else
                    return(pClientSourceRect.getAt(2) - pClientSourceRect.getAt(1))
                  end if
                else
                  if tProp = #scrollStep then
                    return(pScrollStep)
                  else
                    return(0)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on getScrollOffset me 
  return(pScrollOffset)
end

on setScrollOffset me, tOffset 
  me.sendAdjustOffsetTo(tOffset)
  me.UpdateLiftPosition()
  me.ButtonsStates()
  return(1)
end

on updateData me, tViewClientRect, tClientSourceRect 
  pViewClientRect = tViewClientRect
  pClientSourceRect = tClientSourceRect
  if me.pType = "scrollbarv" then
    if (pViewClientRect.height mod pScrollStep) <> 0 then
      pViewClientRect.bottom = pViewClientRect.bottom - (pViewClientRect.height mod pScrollStep) + pScrollStep
    end if
    if pViewClientRect.height > pClientSourceRect.height then
      pScrollOffset = 0
    end if
    pMaxOffset = pClientSourceRect.height - pViewClientRect.height
    pPageSize = pViewClientRect.height
  else
    if (pViewClientRect.width mod pScrollStep) <> 0 then
      pViewClientRect.right = pViewClientRect.right - (pViewClientRect.width mod pScrollStep) + pScrollStep
    end if
    if pViewClientRect.width > pClientSourceRect.width then
      pScrollOffset = 0
    end if
    pMaxOffset = pClientSourceRect.width - pViewClientRect.width
    pPageSize = pViewClientRect.width
  end if
  me.sendAdjustOffsetTo(pScrollOffset)
  me.ButtonsStates()
end

on ScrollBarPercentV me 
  tHeight = float(pClientSourceRect.height - pViewClientRect.height)
  if tHeight = 0 then
    return(0)
  else
    tPercent = (float(pScrollOffset) / tHeight)
    if tPercent > 1 then
      return(1)
    else
      return(tPercent)
    end if
  end if
end

on ScrollBarPercentH me 
  tWidth = float(pClientSourceRect.width - pViewClientRect.width)
  if tWidth = 0 then
    return(0)
  else
    tPercent = (float(pScrollOffset) / tWidth)
    if tPercent > 1 then
      return(1)
    else
      return(tPercent)
    end if
  end if
end

on mouseDown me 
  if me.blend < 100 then
    return(0)
  end if
  pClickPass = 1
  pClickPoint = the mouseLoc
  me.ScrollBarMouseEvent(#down)
  me.render()
  return(1)
end

on mouseUp me 
  me.initEventAgent(0)
  if me.blend < 100 then
    return(0)
  end if
  if pClickPass = 0 then
    return(0)
  end if
  pClickPass = 0
  me.ScrollBarMouseEvent(#up)
  pState = #waitMouseEvent
  me.ButtonsStates()
  me.render()
  return(1)
end

on mouseWithin me 
  if pState = #lift then
    tMouseH = the mouseH
    tMouseV = the mouseV
    if me.pType = "scrollbarv" then
      if tMouseV > me.bottom - pRects.getAt(#bottom).height then
        tMouseV = me.bottom - pRects.getAt(#bottom).height
      else
        if tMouseV < me.top + pRects.getAt(#top).height then
          tMouseV = me.top + pRects.getAt(#top).height
        end if
      end if
      tNewLocV = pClickPoint.locV - tMouseV
      tNewLiftRect = pRects.getAt(#lift) - rect(0, tNewLocV, 0, tNewLocV)
      if tNewLiftRect.bottom > pRects.getAt(#bottom).top then
        tNewLiftRect = pButtonImg.getAt(#lift_up).rect + rect(0, pRects.getAt(#bottom).top - pRects.getAt(#lift).height, 0, pRects.getAt(#bottom).top - pRects.getAt(#lift).height)
      end if
      if tNewLiftRect.top < pRects.getAt(#top).bottom then
        tNewLiftRect = pButtonImg.getAt(#lift_up).rect + rect(0, pRects.getAt(#top).height, 0, pRects.getAt(#top).height)
      end if
    else
      if tMouseH > me.right - pRects.getAt(#bottom).left then
        tMouseH = me.right - pRects.getAt(#bottom).left
      else
        if tMouseH < me.left + pRects.getAt(#top).right then
          tMouseH = me.left + pRects.getAt(#top).right
        end if
      end if
      tNewLocH = pClickPoint.locH - tMouseH
      tNewLiftRect = pRects.getAt(#lift) - rect(tNewLocH, 0, tNewLocH, 0)
      if tNewLiftRect.right > pRects.getAt(#bottom).left then
        tNewLiftRect = pButtonImg.getAt(#lift_up).rect + rect(pRects.getAt(#bottom).left - pRects.getAt(#lift).width, 0, pRects.getAt(#bottom).left - pRects.getAt(#lift).width, 0)
      end if
      if tNewLiftRect.left < pRects.getAt(#top).right then
        tNewLiftRect = pButtonImg.getAt(#lift_up).rect + rect(pRects.getAt(#top).width, 0, pRects.getAt(#top).width, 0)
      end if
    end if
    pRects.setAt(#lift, tNewLiftRect)
    me.UpdateScrollBar([#bar], #up)
    me.UpdateScrollBar([#lift], #down)
    me.ScrollByLift()
    me.ButtonsStates()
    pClickPoint = point(tMouseH, tMouseV)
  else
    if pState = #top or pState = #bottom then
      me.ScrollBarMouseEvent(#down)
      me.ButtonsStates()
    end if
  end if
end

on mouseUpOutSide me 
  if me.blend < 100 then
    return(0)
  end if
  pClickPass = 0
  pState = #waitMouseEvent
  me.ButtonsStates()
  me.render()
  return(0)
end

on UpdateLiftPosition me 
  if me.pType = "scrollbarv" then
    tMoveAreaV = pRects.getAt(#bar).height - pRects.getAt(#lift).height
    tNewOffset = integer((me.ScrollBarPercentV() * tMoveAreaV))
    pRects.setAt(#lift, rect(0, tNewOffset + pRects.getAt(#top).height, pRects.getAt(#lift).width, tNewOffset + pRects.getAt(#top).height + pRects.getAt(#lift).height))
  else
    tMoveAreaV = pRects.getAt(#bar).width - pRects.getAt(#lift).width
    tNewOffset = integer((me.ScrollBarPercentH() * tMoveAreaV))
    pRects.setAt(#lift, rect(tNewOffset + pRects.getAt(#top).width, 0, tNewOffset + pRects.getAt(#top).width + pRects.getAt(#lift).width, pRects.getAt(#lift).height))
  end if
end

on ScrollByLift me 
  if me.pType = "scrollbarv" then
    tMoveAreaV = pRects.getAt(#bar).height - pRects.getAt(#lift).height
    if tMoveAreaV = 0 then
      return(0)
    end if
    tScrollPercent = ((pRects.getAt(#lift).top - pRects.getAt(#lift).height + 1 * 100) / tMoveAreaV)
    tNowPercent = (float(tScrollPercent) / 100)
    tNowOffset = integer(((pClientSourceRect.bottom - pViewClientRect.height * float(tScrollPercent)) / 100))
  else
    tMoveAreaH = pRects.getAt(#bar).width - pRects.getAt(#lift).width
    if tMoveAreaH = 0 then
      return(0)
    end if
    tScrollPercent = ((pRects.getAt(#lift).left - pRects.getAt(#lift).width + 1 * 100) / tMoveAreaH)
    tNowPercent = (float(tScrollPercent) / 100)
    tNowOffset = integer(((pClientSourceRect.right - pViewClientRect.width * float(tScrollPercent)) / 100))
  end if
  me.sendAdjustOffsetTo(tNowOffset)
end

on sendAdjustOffsetTo me, tNewOffset 
  if abs(pScrollOffset - tNewOffset) < pScrollStep and tNewOffset < pMaxOffset and tNewOffset > 0 then
    return(1)
  end if
  if tNewOffset < pMaxOffset then
    pScrollOffset = tNewOffset
    if pScrollStep > 0 then
      pScrollOffset = ((pScrollOffset / pScrollStep) * pScrollStep)
    end if
  else
    pScrollOffset = pMaxOffset
  end if
  if pScrollOffset <= 0 then
    pScrollOffset = 0
  end if
  if me.pType = "scrollbarv" then
    call(#setOffsetY, [getWindow(me.pMotherId).getElement(pClientID)], pScrollOffset)
  else
    call(#setOffsetX, [getWindow(me.pMotherId).getElement(pClientID)], pScrollOffset)
  end if
end

on UpdateImageObjects me, tPalette, tListStates 
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat while [#top, #lift, #bottom, #bar] <= tListStates
    f = getAt(tListStates, tPalette)
    repeat while [#top, #lift, #bottom, #bar] <= tListStates
      i = getAt(tListStates, tPalette)
      tDesc = pParts.getAt(i).getAt(#members).getAt(f)
      if not voidp(tDesc) then
        tmember = member(getmemnum(tDesc.getAt(#member)))
        if not voidp(tDesc.getAt(#palette)) then
          me.pPalette = member(getmemnum(tDesc.getAt(#palette)))
        else
          me.pPalette = tPalette
        end if
        tImage = tmember.duplicate()
        if tDesc.getAt(#flipH) then
          tImage = me.flipH(tImage)
        end if
        if tDesc.getAt(#flipV) then
          tImage = me.flipV(tImage)
        end if
        if not voidp(tDesc.getAt(#rotate)) then
          tImage = me.rotateImg(tImage, tDesc.getAt(#rotate))
        end if
        pButtonImg.addProp(symbol(f & "_" & i), tImage)
      end if
    end repeat
    me.DefineRects(f)
  end repeat
  return(tPalette)
end

on DefineRects me, tElementPart 
  if me.pType = "scrollbarv" then
    tRect = pButtonImg.getAt(tElementPart & "_up").rect
    if tElementPart = #lift then
      tRect = tRect + rect(0, pButtonImg.getAt("top_up").height, 0, pButtonImg.getAt("top_up").height)
    else
      if tElementPart = #bottom then
        tRect = tRect + rect(0, me.pheight - pButtonImg.getAt("bottom_up").height, 0, me.pheight - pButtonImg.getAt("bottom_up").height)
      else
        if tElementPart = #bar then
          tRect = tRect + rect(0, pButtonImg.getAt(#top_up).height, 0, me.pheight - pButtonImg.getAt(#bottom_up).height - 1)
        end if
      end if
    end if
    pRects.addProp(tElementPart, tRect)
  else
    tRect = pButtonImg.getAt(tElementPart & "_up").rect
    if tElementPart = #lift then
      tRect = tRect + rect(pButtonImg.getAt("top_up").width, 0, pButtonImg.getAt("top_up").width, 0)
    else
      if tElementPart = #bottom then
        tRect = tRect + rect(me.pwidth - pButtonImg.getAt("bottom_up").width, 0, me.pwidth - pButtonImg.getAt("bottom_up").width, 0)
      else
        if tElementPart = #bar then
          tRect = tRect + rect(pButtonImg.getAt(#top_up).width, 0, me.pwidth - pButtonImg.getAt(#bottom_up).width - 1, 0)
        end if
      end if
    end if
    pRects.addProp(tElementPart, tRect)
  end if
end

on DrawSpecificRect me, tdestrect, tElementPart, tstate 
  tImgPropName = tElementPart & "_" & tstate
  me.copyPixels(pButtonImg.getProp(tImgPropName), tdestrect, pButtonImg.getProp(tImgPropName).rect)
end

on UpdateScrollBar me, tElementPartList, tstate 
  repeat while tElementPartList <= tstate
    f = getAt(tstate, tElementPartList)
    tDstRect = pRects.getAt(f)
    tImgPropName = f & "_" & tstate
    me.copyPixels(pButtonImg.getProp(tImgPropName), tDstRect, pButtonImg.getProp(tImgPropName).rect, [#ink:36])
  end repeat
end

on ScrollBarMouseEvent me, tstate 
  if pButtonStates.getAt(#top) = #passive and pButtonStates.getAt(#bottom) = #passive then
    return()
  end if
  if pState = #lift then
    me.UpdateScrollBar([#bar, #lift], #up)
    pButtonStates.setAt(#lift, #up)
    return()
  end if
  tClickbutton = me.buttonOfClickArea(pClickPoint)
  if voidp(tClickbutton) then
    return()
  end if
  if pButtonStates.getAt(tClickbutton) = #passive then
    return()
  end if
  pButtonStates.setAt(tClickbutton, tstate)
  pState = symbol(tClickbutton)
  if tClickbutton = #top or tClickbutton = #bottom then
    me.UpdateScrollBar([tClickbutton], tstate)
    if tClickbutton = #top then
      me.sendAdjustOffsetTo(pScrollOffset - pScrollStep)
    else
      me.sendAdjustOffsetTo(pScrollOffset + pScrollStep)
    end if
    me.UpdateLiftPosition()
    me.UpdateScrollBar([#bar, #lift], #up)
  else
    if tClickbutton = #lift then
      me.UpdateScrollBar([#bar], #up)
      me.UpdateScrollBar([#lift], tstate)
      me.initEventAgent(1)
    else
      if tClickbutton = #bar and tstate = #down then
        tUpPageUp = 0
        me.UpdateLiftPosition()
        if me.pType = "scrollbarv" then
          if pClickPoint.locV - me.locV <= pRects.getAt(#lift).top then
            tUpPageUp = 1
          end if
        else
          if pClickPoint.locH - me.locH <= pRects.getAt(#lift).left then
            tUpPageUp = 1
          end if
        end if
        if me.pType = "scrollbarv" then
          if tUpPageUp then
            me.sendAdjustOffsetTo(pScrollOffset - pPageSize)
            tTop = pRects.getAt(#lift).bottom
            tBottom = pRects.getAt(#bottom).top
          else
            me.sendAdjustOffsetTo(pScrollOffset + pPageSize)
            tTop = pRects.getAt(#top).bottom
            tBottom = pRects.getAt(#lift).top
          end if
          me.UpdateScrollBar([#bar], tstate)
          me.DrawSpecificRect(rect(0, tTop, pRects.getAt(#bar).width, tBottom), #bar, #up)
        else
          if tUpPageUp then
            me.sendAdjustOffsetTo(pScrollOffset - pPageSize)
            tLeft = pRects.getAt(#lift).right
            tRight = pRects.getAt(#bottom).left
          else
            me.sendAdjustOffsetTo(pScrollOffset + pPageSize)
            tLeft = pRects.getAt(#top).right
            tRight = pRects.getAt(#lift).left
          end if
          me.UpdateScrollBar([#bar], tstate)
          me.DrawSpecificRect(rect(tLeft, 0, tRight, pRects.getAt(#bar).height), #bar, #up)
        end if
        me.UpdateScrollBar([#lift], #up)
      end if
    end if
  end if
end

on ButtonsStates me 
  if pScrollOffset > 0 and pButtonStates.getAt(#top) <> #up and pState <> #top then
    pButtonStates.setAt(#top, #up)
    me.UpdateScrollBar([#top], #up)
  else
    if pScrollOffset <= 0 and pButtonStates.getAt(#top) <> #passive then
      pButtonStates.setAt(#top, #passive)
      me.UpdateScrollBar([#top], #passive)
    end if
  end if
  if pScrollOffset < pMaxOffset and pButtonStates.getAt(#bottom) <> #up and pState <> #bottom then
    pButtonStates.setAt(#bottom, #up)
    me.UpdateScrollBar([#bottom], #up)
  else
    if pScrollOffset >= pMaxOffset and pButtonStates.getAt(#bottom) <> #passive then
      pButtonStates.setAt(#bottom, #passive)
      me.UpdateScrollBar([#bottom], #passive)
    end if
  end if
  if pButtonStates.getAt(#top) = #passive and pButtonStates.getAt(#bottom) = #passive then
    pButtonStates.setAt(#lift, #passive)
    me.UpdateScrollBar([#bar], #up)
    me.UpdateScrollBar([#lift], #passive)
  else
    if pState <> #lift then
      pButtonStates.setAt(#lift, #up)
      me.UpdateLiftPosition()
      me.UpdateScrollBar([#bar, #lift], #up)
    end if
  end if
  me.render()
end

on buttonOfClickArea me, tpoint 
  tpoint = tpoint - point(me.left, me.top)
  r = 1
  repeat while r <= pRects.count()
    if tpoint.inside(pRects.getAt(r)) then
      return(pRects.getPropAt(r))
    else
      r = 1 + r
    end if
  end repeat
end

on initEventAgent me, tBoolean 
  tAgent = getObject(pAgentID)
  if tBoolean then
    tAgent.registerEvent(me, #mouseUp, #mouseUp)
    tAgent.registerEvent(me, #mouseWithin, #mouseWithin)
  else
    tAgent.unregisterEvent(#mouseUp)
    tAgent.unregisterEvent(#mouseWithin)
  end if
end

on resizeBy me, tOffH, tOffV 
  if tOffH <> 0 or tOffV <> 0 then
    if me.pScaleH = #move then
      me.locH = me.locH + tOffH
    else
      if me.pScaleH = #scale then
        me.width = me.width + tOffH
      else
        if me.pScaleH = #center then
          me.locH = me.locH + (tOffH / 2)
        end if
      end if
    end if
    if me.pScaleH = #move then
      me.locV = me.locV + tOffV
    else
      if me.pScaleH = #scale then
        me.height = me.height + tOffV
      else
        if me.pScaleH = #center then
          me.locV = me.locV + (tOffV / 2)
        end if
      end if
    end if
    pRects = [:]
    pState = #waitMouseEvent
    pScrollOffset = 0
    pButtonStates = [#top:#up, #bottom:#up, #bar:#up, #lift:#up]
    if me.pType = "scrollbarv" then
      me.pwidth = pButtonImg.getAt("top_up").width
      me.pheight = me.height
    else
      me.pwidth = me.width
      me.pheight = pButtonImg.getAt("top_up").height
    end if
    if me.pwidth < 1 then
      me.pwidth = 1
    end if
    if me.pheight < 1 then
      me.pheight = 1
    end if
    me.UpdateImageObjects(void(), [#up, #down, #passive])
    me.pimage = image(me.pwidth, me.pheight, 8, me.pPalette)
    me.UpdateScrollBar([#top, #bottom, #bar, #lift], #up)
    tTempOffset = me.regPoint
    me.image = me.pimage
    me.regPoint = tTempOffset
  end if
end

on flipH me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on flipV me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on rotateImg me, tImg, tDirection 
  tImage = image(tImg.height, tImg.width, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, 0), point(tImg.height, 0), point(tImg.height, tImg.width), point(0, tImg.width)]
  tQuad = me.RotateQuad(tQuad, tDirection)
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on RotateQuad me, tDestquad, tClockwise 
  tPnt1 = tDestquad.getAt(1)
  tPnt2 = tDestquad.getAt(2)
  tPnt3 = tDestquad.getAt(3)
  tPnt4 = tDestquad.getAt(4)
  if tClockwise then
    return([tPnt2, tPnt3, tPnt4, tPnt1])
  else
    return([tPnt4, tPnt1, tPnt2, tPnt3])
  end if
end

on handlers  
  return([])
end
