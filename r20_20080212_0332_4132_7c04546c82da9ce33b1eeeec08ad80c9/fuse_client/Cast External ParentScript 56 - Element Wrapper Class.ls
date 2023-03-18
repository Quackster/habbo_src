property pID, pElemList, pBuffer, pSprite, pPalette, pScaleH, pScaleV, pLocX, pLocY, pwidth, pheight, pVisible

on construct me
  pElemList = []
  pPalette = #systemMac
  pScaleH = #fixed
  pScaleV = #fixed
  pLocX = 0
  pLocY = 0
  pwidth = 0
  pheight = 0
  pVisible = 1
  return 1
end

on deconstruct me
  call(#deconstruct, pElemList)
  pElemList = []
  pBuffer = VOID
  pSprite = VOID
  return 1
end

on define me, tProps
  pID = tProps[#id]
  pBuffer = tProps[#buffer]
  pSprite = tProps[#sprite]
  pLocX = tProps[#locX]
  pLocY = tProps[#locY]
  pwidth = pBuffer.width
  pheight = pBuffer.height
  pPalette = pBuffer.paletteRef
  return 1
end

on add me, tElement
  if not objectp(tElement) then
    return 0
  end if
  if tElement.getProperty(#scaleH) <> #fixed then
    pScaleH = #scale
  end if
  if tElement.getProperty(#scaleV) <> #fixed then
    pScaleV = #scale
  end if
  pElemList.add(tElement)
  return 1
end

on show me
  pVisible = 1
  pSprite.visible = 1
  return 1
end

on hide me
  pVisible = 0
  pSprite.visible = 0
  return 1
end

on moveTo me, tLocX, tLocY
  tOffX = tLocX - pLocX
  tOffY = tLocY - pLocY
  me.moveBy(tOffX, tOffY)
end

on moveBy me, tOffX, tOffY
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
end

on resizeBy me, tOffW, tOffH
  if (tOffW <> 0) or (tOffH <> 0) then
    case pScaleH of
      #fixed:
        tOffW = 0
      #scale:
        pwidth = pwidth + tOffW
      #move:
        me.moveBy(tOffW, 0)
      #center:
        me.moveBy(tOffW / 2, 0)
    end case
    if pScaleH <> #scale then
      tOffW = 0
    end if
    case pScaleV of
      #fixed:
        tOffH = 0
      #scale:
        pheight = pheight + tOffH
      #move:
        me.moveBy(0, tOffH)
      #center:
        me.moveBy(0, tOffH / 2)
    end case
    if pScaleV <> #scale then
      tOffH = 0
    end if
    if (tOffW <> 0) or (tOffH <> 0) then
      if pwidth < 1 then
        pwidth = 1
      end if
      if pheight < 1 then
        pheight = 1
      end if
      pBuffer.image = image(pwidth, pheight, pBuffer.image.depth, pPalette)
      pBuffer.regPoint = point(0, 0)
      pSprite.width = pwidth
      pSprite.height = pheight
      pSprite.stretch = 0
      call(#resizeBy, pElemList, tOffW, tOffH)
    end if
  end if
end

on getProperty me, tProp
  case tProp of
    #image:
      return pBuffer.image
    #buffer:
      return pBuffer
    #member:
      return pBuffer
    #sprite:
      return pSprite
    #scaleH:
      return pScaleH
    #scaleV:
      return pScaleV
    #locX:
      return pLocX
    #locY:
      return pLocY
    #locH:
      return pLocX
    #locV:
      return pLocY
    #locZ:
      return pSprite.locZ
    #width:
      return pwidth
    #height:
      return pheight
    #depth:
      return pBuffer.image.depth
    #color:
      return pSprite.color
    #bgColor:
      return pSprite.bgColor
    #blend:
      return pSprite.blend
    #ink:
      return pSprite.ink
    #palette:
      return pPalette
    #visible:
      return pVisible
    #cursor:
      return pSprite.cursor
    otherwise:
      return 0
  end case
end

on setProperty me, tProp, tValue
  case tProp of
    #scaleH:
      pScaleH = tValue
    #scaleV:
      pScaleV = tValue
    #locX:
      me.moveTo(tValue, pLocY)
    #locY:
      me.moveTo(pLocX, tValue)
    #locH:
      me.moveTo(tValue, pLocY)
    #locV:
      me.moveTo(pLocX, tValue)
    #width:
      me.resizeBy(pwidth - tValue, 0)
    #height:
      me.resizeBy(0, pheight - tValue)
    #color:
      pSprite.color = tValue
    #bgColor:
      pSprite.bgColor = tValue
    #blend:
      pSprite.blend = tValue
    #ink:
      pSprite.ink = tValue
    #cursor:
      pSprite.setcursor(tValue)
    #image:
      tRegPnt = pBuffer.regPoint
      pBuffer.image = tValue
      pBuffer.regPoint = tRegPnt
      pSprite.width = pBuffer.width
      pSprite.height = pBuffer.height
      pwidth = pBuffer.width
      pheight = pBuffer.height
    #buffer, #member:
      pBuffer = tValue
      pwidth = pBuffer.width
      pheight = pBuffer.height
      pPalette = pBuffer.paletteRef
      pSprite.castNum = pBuffer.number
    #palette:
      pPalette = tValue
      pBuffer.image.paletteRef = pPalette
    #depth:
      tImage = pBuffer.image.duplicate()
      pBuffer.image = image(tImage.width, tImage.height, tValue)
      pBuffer.image.copyPixels(tImage, tImage.rect, tImage.rect)
      pBuffer.image.paletteRef = pPalette
    #visible:
      if tValue = 1 then
        me.show()
      else
        me.hide()
      end if
    otherwise:
      return 0
  end case
  return 1
end

on prepare me
  call(#prepare, pElemList)
end

on render me
  if pVisible then
    call(#render, pElemList)
  end if
end

on draw me, tRGB
  call(#draw, pElemList, tRGB)
end
