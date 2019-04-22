property pOwnX, pOwnY, pOwnW, pOwnH, pScrolls, pOffX, pOffY

on prepare me 
  pOffX = 0
  pOffY = 0
  pOwnW = me.getProp(#pProps, #width)
  pOwnH = me.getProp(#pProps, #height)
  pScrolls = []
  me.pDepth = the colorDepth
  me.pimage = image(me.pwidth, me.pheight, me.pDepth)
  if me.getProp(#pProps, #style) = #unique then
    pOwnX = 0
    pOwnY = 0
  else
    pOwnX = me.getProp(#pProps, #locH)
    pOwnY = me.getProp(#pProps, #locV)
  end if
  if me.getProp(#pProps, #flipH) then
    me.flipH()
  end if
  if me.getProp(#pProps, #flipV) then
    me.flipV()
  end if
  return(1)
end

on feedImage me, tImage 
  if not ilk(tImage, #image) then
    return(error(me, "Image object expected!" && tImage, #feedImage))
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  undefined.fill(tTargetRect, me.getProp(#pProps, #bgColor))
  me.pimage = tImage
  me.render()
  me.registerScroll()
  return(1)
end

on clearImage me 
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  return(undefined.fill(tTargetRect, me.getProp(#pProps, #bgColor)))
end

on clearBuffer me 
  return(me.fill(me.rect, me.getProp(#pProps, #bgColor)))
end

on registerScroll me, tid 
  if voidp(pScrolls) then
    me.prepare()
  end if
  if not voidp(tid) then
    if pScrolls.getPos(tid) = 0 then
      pScrolls.add(tid)
    end if
  else
    if pScrolls.count = 0 then
      return(0)
    end if
  end if
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  tScrollList = []
  repeat while pScrolls <= undefined
    tScrollId = getAt(undefined, tid)
    tScrollList.add(getWindowManager().get(me.pMotherId).getElement(tScrollId))
  end repeat
  call(#updateData, tScrollList, tSourceRect, me.rect)
end

on adjustOffsetTo me, tX, tY 
  pOffX = tX
  pOffY = tY
  me.clearImage()
  me.render()
end

on adjustOffsetBy me, tOffX, tOffY 
  pOffX = pOffX + tOffX
  pOffY = pOffY + tOffY
  me.clearImage()
  me.render()
end

on adjustXOffsetTo me, tX 
  me.adjustOffsetTo(tX, pOffY)
end

on adjustYOffsetTo me, tY 
  me.adjustOffsetTo(pOffX, tY)
end

on setOffsetX me, tX 
  me.adjustOffsetTo(tX, pOffY)
end

on setOffsetY me, tY 
  me.adjustOffsetTo(pOffX, tY)
end

on getOffsetX me 
  return(pOffX)
end

on getOffsetY me 
  return(pOffY)
end

on resizeBy me, tOffH, tOffV 
  if tOffH <> 0 or tOffV <> 0 then
    if me.getProp(#pProps, #style) = #unique then
      if me.pScaleH = #move then
        me.moveBy(tOffH, 0)
      else
        if me.pScaleH = #scale then
          me.pwidth = me.pwidth + tOffH
        else
          if me.pScaleH = #center then
            me.moveBy(tOffH / 2, 0)
          end if
        end if
      end if
      if me.pScaleH = #move then
        me.moveBy(0, tOffV)
      else
        if me.pScaleH = #scale then
          me.pheight = me.pheight + tOffV
        else
          if me.pScaleH = #center then
            me.moveBy(0, tOffV / 2)
          end if
        end if
      end if
      if me.pwidth < 1 then
        me.pwidth = 1
      end if
      if me.pheight < 1 then
        me.pheight = 1
      end if
      pOwnW = me.pwidth
      pOwnH = me.pheight
      me.image = image(pOwnW, pOwnH, me.pDepth)
      me.regPoint = point(0, 0)
      pSprite.width = pOwnW
      pSprite.height = pOwnH
    else
      if me.pScaleH = #move then
        pOwnX = pOwnX + tOffH
      else
        if me.pScaleH = #scale then
          pOwnW = pOwnW + tOffH
        else
          if me.pScaleH = #center then
            pOwnX = pOwnX + tOffH / 2
          end if
        end if
      end if
      if me.pScaleH = #move then
        pOwnY = pOwnY + tOffV
      else
        if me.pScaleH = #scale then
          pOwnH = pOwnH + tOffV
        else
          if me.pScaleH = #center then
            pOwnY = pOwnY + tOffV / 2
          end if
        end if
      end if
    end if
    me.registerScroll()
    me.render()
  end if
end

on render me 
  if not me.pVisible then
    return()
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  undefined.copyPixels(me.pimage, tTargetRect, tSourceRect, me.pParams)
end

on mouseDown me 
  return(point(the mouseV, the mouseH - pSprite.locV + pOwnY + pOffY))
end

on mouseUp me 
  return(point(the mouseV, the mouseH - pSprite.locV + pOwnY + pOffY))
end
