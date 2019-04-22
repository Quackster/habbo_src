on prepare(me)
  pOffX = 0
  pOffY = 0
  pOwnW = me.getProp(#pProps, #width)
  pOwnH = me.getProp(#pProps, #height)
  pScrolls = []
  pUpdateLock = 0
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
  exit
end

on feedImage(me, tImage)
  if not ilk(tImage) = #image then
    return(error(me, "Image object expected!" && tImage, #feedImage))
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  undefined.fill(tTargetRect, me.getProp(#pProps, #bgColor))
  me.pimage = tImage
  me.render()
  pUpdateLock = 1
  me.registerScroll()
  pUpdateLock = 0
  return(1)
  exit
end

on clearImage(me)
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  return(undefined.fill(tTargetRect, me.getProp(#pProps, #bgColor)))
  exit
end

on clearBuffer(me)
  return(me.fill(me.rect, me.getProp(#pProps, #bgColor)))
  exit
end

on registerScroll(me, tid)
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
  tWndObj = getWindowManager().get(me.pMotherId)
  repeat while me <= undefined
    tScrollId = getAt(undefined, tid)
    tScrollList.add(tWndObj.getElement(tScrollId))
  end repeat
  call(#updateData, tScrollList, tSourceRect, me.rect)
  exit
end

on adjustOffsetTo(me, tX, tY)
  pOffX = tX
  pOffY = tY
  if not pUpdateLock then
    me.clearImage()
    me.render()
  end if
  exit
end

on adjustOffsetBy(me, tOffX, tOffY)
  pOffX = pOffX + tOffX
  pOffY = pOffY + tOffY
  if not pUpdateLock then
    me.clearImage()
    me.render()
  end if
  exit
end

on adjustXOffsetTo(me, tX)
  me.adjustOffsetTo(tX, pOffY)
  exit
end

on adjustYOffsetTo(me, tY)
  me.adjustOffsetTo(pOffX, tY)
  exit
end

on setOffsetX(me, tX)
  me.adjustOffsetTo(tX, pOffY)
  exit
end

on setOffsetY(me, tY)
  me.adjustOffsetTo(pOffX, tY)
  exit
end

on getOffsetX(me)
  return(pOffX)
  exit
end

on getOffsetY(me)
  return(pOffY)
  exit
end

on resizeBy(me, tOffH, tOffV)
  if tOffH <> 0 or tOffV <> 0 then
    if me.getProp(#pProps, #style) = #unique then
      if me = #move then
        me.moveBy(tOffH, 0)
      else
        if me = #scale then
          me.pwidth = me.pwidth + tOffH
        else
          if me = #center then
            me.moveBy(tOffH / 2, 0)
          end if
        end if
      end if
      if me = #move then
        me.moveBy(0, tOffV)
      else
        if me = #scale then
          me.pheight = me.pheight + tOffV
        else
          if me = #center then
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
      if me = #move then
        pOwnX = pOwnX + tOffH
      else
        if me = #scale then
          pOwnW = pOwnW + tOffH
        else
          if me = #center then
            pOwnX = pOwnX + tOffH / 2
          end if
        end if
      end if
      if me = #move then
        pOwnY = pOwnY + tOffV
      else
        if me = #scale then
          pOwnH = pOwnH + tOffV
        else
          if me = #center then
            pOwnY = pOwnY + tOffV / 2
          end if
        end if
      end if
    end if
    me.registerScroll()
    me.render()
  end if
  exit
end

on render(me)
  if not me.pVisible then
    return()
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  undefined.copyPixels(me.pimage, tTargetRect, tSourceRect, me.pParams)
  exit
end

on mouseDown(me)
  return(point(the mouseV, me - pSprite.locV + pOwnY + pOffY))
  exit
end

on mouseUp(me)
  return(point(the mouseV, me - pSprite.locV + pOwnY + pOffY))
  exit
end