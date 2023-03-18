property pID, pMotherId, pType, pBuffer, pSprite, pPalette, pScaleH, pScaleV, pLocX, pLocY, pwidth, pheight, pDepth, pimage, pParams, pProps, pVisible

on define me, tProps
  pID = tProps[#id]
  pMotherId = tProps[#mother]
  pType = tProps[#type]
  pBuffer = tProps[#buffer]
  pSprite = tProps[#sprite]
  pPalette = tProps[#palette]
  pScaleH = tProps[#scaleH]
  pScaleV = tProps[#scaleV]
  pLocX = tProps[#locH]
  pLocY = tProps[#locV]
  pwidth = tProps[#width]
  pheight = tProps[#height]
  pProps = tProps
  pVisible = 1
  if voidp(pPalette) then
    pPalette = #systemMac
  else
    if stringp(pPalette) then
      pPalette = member(getResourceManager().getmemnum(pPalette))
    end if
  end if
  if voidp(pProps[#member]) then
    tMemNum = 0
  else
    tMemNum = getResourceManager().getmemnum(pProps[#member])
  end if
  if (tMemNum > 0) and (pType <> "image") then
    tmember = member(tMemNum)
    pDepth = tmember.image.depth
    pimage = tmember.image.duplicate()
    if pimage.paletteRef <> pPalette then
      pimage.paletteRef = pPalette
    end if
  else
    pDepth = the colorDepth
    pimage = image(1, 1, pDepth, pPalette)
  end if
  if me.pProps[#flipH] then
    me.flipH()
  end if
  if me.pProps[#flipV] then
    me.flipV()
  end if
  pParams = [:]
  if tProps[#blend] < 100 then
    pParams[#blend] = tProps[#blend]
  end if
  if tProps[#color] <> rgb(0, 0, 0) then
    pParams[#color] = tProps[#color]
  end if
  if tProps[#bgColor] <> rgb(255, 255, 255) then
    pParams[#bgColor] = tProps[#bgColor]
  end if
  if tProps[#ink] <> 0 then
    pParams[#ink] = tProps[#ink]
  end if
  if pParams.count = 0 then
    pParams = VOID
  end if
  return 1
end

on prepare me
end

on moveTo me, tLocX, tLocY
  pLocX = tLocX
  pLocY = tLocY
  me.render()
end

on moveBy me, tOffX, tOffY
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.render()
end

on resizeTo me, tX, tY
  tOffX = tX - pwidth
  tOffY = tY - pheight
  return me.resizeBy(tOffX, tOffY)
end

on resizeBy me, tOffH, tOffV
  case pScaleH of
    #move:
      pLocX = pLocX + tOffH
    #center:
      pLocX = pLocX + (tOffH / 2)
    #scale:
      pwidth = pwidth + tOffH
  end case
  case pScaleV of
    #move:
      pLocY = pLocY + tOffV
    #center:
      pLocY = pLocY + (tOffV / 2)
    #scale:
      pheight = pheight + tOffV
  end case
  me.render()
end

on flipH me
  tImage = image(pimage.width, pimage.height, pimage.depth, pimage.paletteRef)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  me.pimage = tImage
end

on flipV me
  tImage = image(pimage.width, pimage.height, pimage.depth, pimage.paletteRef)
  tQuad = [point(0, pimage.height), point(pimage.width, pimage.height), point(pimage.width, 0), point(0, 0)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
end

on getProperty me, tProp
  case tProp of
    #buffer:
      return pBuffer
    #sprite:
      return pSprite
    #width:
      return pwidth
    #height:
      return pheight
    #locX:
      return pLocX
    #locY:
      return pLocY
    #scaleH:
      return pScaleH
    #scaleV:
      return pScaleV
    #depth:
      return pDepth
    #palette:
      return pPalette
    otherwise:
      return 0
  end case
end

on render me
  tTargetRect = rect(pLocX, pLocY, pLocX + pwidth, pLocY + pheight)
  tSourceRect = pimage.rect
  pBuffer.image.copyPixels(pimage, tTargetRect, tSourceRect, pParams)
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(0, 0, 255)
  end if
  tTargetRect = rect(pLocX, pLocY, pLocX + pwidth, pLocY + pheight)
  pBuffer.image.draw(tTargetRect, [#shapeType: #rect, #color: tRGB])
end
