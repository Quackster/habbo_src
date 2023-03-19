property pOwnX, pOwnY, pOwnW, pOwnH, pOffX, pOffY, pScrolls, pUpdateLock

on prepare me
  pOffX = 0
  pOffY = 0
  pOwnW = me.pProps[#width]
  pOwnH = me.pProps[#height]
  pScrolls = []
  pUpdateLock = 0
  me.pDepth = the colorDepth
  me.pimage = image(me.pwidth, me.pheight, me.pDepth)
  if me.pProps[#style] = #unique then
    pOwnX = 0
    pOwnY = 0
  else
    pOwnX = me.pProps[#locH]
    pOwnY = me.pProps[#locV]
  end if
  if me.pProps[#flipH] then
    me.flipH()
  end if
  if me.pProps[#flipV] then
    me.flipV()
  end if
  return 1
end

on feedImage me, tImage
  if not (ilk(tImage) = #image) then
    return error(me, "Image object expected!" && tImage, #feedImage)
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  me.pBuffer.image.fill(tTargetRect, me.pProps[#bgColor])
  me.pimage = tImage
  me.render()
  pUpdateLock = 1
  me.registerScroll()
  pUpdateLock = 0
  return 1
end

on clearImage me
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  return me.pBuffer.image.fill(tTargetRect, me.pProps[#bgColor])
end

on clearBuffer me
  return me.pimage.fill(me.pimage.rect, me.pProps[#bgColor])
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
      return 0
    end if
  end if
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  tScrollList = []
  tWndObj = getWindowManager().get(me.pMotherId)
  repeat with tScrollId in pScrolls
    tScrollList.add(tWndObj.getElement(tScrollId))
  end repeat
  call(#updateData, tScrollList, tSourceRect, me.pimage.rect)
end

on adjustOffsetTo me, tX, tY
  pOffX = tX
  pOffY = tY
  if not pUpdateLock then
    me.clearImage()
    me.render()
  end if
end

on adjustOffsetBy me, tOffX, tOffY
  pOffX = pOffX + tOffX
  pOffY = pOffY + tOffY
  if not pUpdateLock then
    me.clearImage()
    me.render()
  end if
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
  return pOffX
end

on getOffsetY me
  return pOffY
end

on resizeBy me, tOffH, tOffV
  if (tOffH <> 0) or (tOffV <> 0) then
    if me.pProps[#style] = #unique then
      case me.pScaleH of
        #move:
          me.moveBy(tOffH, 0)
        #scale:
          me.pwidth = me.pwidth + tOffH
        #center:
          me.moveBy(tOffH / 2, 0)
      end case
      case me.pScaleV of
        #move:
          me.moveBy(0, tOffV)
        #scale:
          me.pheight = me.pheight + tOffV
        #center:
          me.moveBy(0, tOffV / 2)
      end case
      if me.pwidth < 1 then
        me.pwidth = 1
      end if
      if me.pheight < 1 then
        me.pheight = 1
      end if
      pOwnW = me.pwidth
      pOwnH = me.pheight
      me.pBuffer.image = image(pOwnW, pOwnH, me.pDepth)
      me.pBuffer.regPoint = point(0, 0)
      me.pSprite.width = pOwnW
      me.pSprite.height = pOwnH
    else
      case me.pScaleH of
        #move:
          pOwnX = pOwnX + tOffH
        #scale:
          pOwnW = pOwnW + tOffH
        #center:
          pOwnX = pOwnX + (tOffH / 2)
      end case
      case me.pScaleV of
        #move:
          pOwnY = pOwnY + tOffV
        #scale:
          pOwnH = pOwnH + tOffV
        #center:
          pOwnY = pOwnY + (tOffV / 2)
      end case
    end if
    me.registerScroll()
    me.render()
  end if
end

on render me
  if not me.pVisible then
    return 
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  me.pBuffer.image.copyPixels(me.pimage, tTargetRect, tSourceRect, me.pParams)
end

on mouseDown me
  return point(the mouseH - me.pSprite.locH + pOwnX + pOffX, the mouseV - me.pSprite.locV + pOwnY + pOffY)
end

on mouseUp me
  return point(the mouseH - me.pSprite.locH + pOwnX + pOffX, the mouseV - me.pSprite.locV + pOwnY + pOffY)
end
