property pID, pMotherId, pType, pBuffer, pSprite, pPalette, pScaleH, pScaleV, pLocX, pLocY, pwidth, pheight, pVisible, pDepth, pimage, pParams, pProps

on define me, tProps
  pID = tProps[#id]
  pMotherId = tProps[#mother]
  pType = tProps[#type]
  pScaleH = tProps[#scaleH]
  pScaleV = tProps[#scaleV]
  pBuffer = tProps[#buffer]
  pSprite = tProps[#sprite]
  pLocX = tProps[#locH]
  pLocY = tProps[#locV]
  pwidth = tProps[#width]
  pheight = tProps[#height]
  pPalette = tProps[#palette]
  pProps = tProps
  pDepth = the colorDepth
  pVisible = 1
  if voidp(pPalette) then
    pPalette = #systemMac
  else
    if stringp(pPalette) then
      pPalette = member(getResourceManager().getmemnum(pPalette))
    end if
  end if
  tMemNum = getResourceManager().getmemnum(pProps[#member])
  if tMemNum > 0 then
    tmember = member(tMemNum)
    if tmember.type = #bitmap then
      pimage = tmember.image.duplicate()
      pDepth = tmember.image.depth
      if pimage.paletteRef <> pPalette then
        pimage.paletteRef = pPalette
      end if
    end if
  end if
  if voidp(pimage) then
    pDepth = the colorDepth
    pimage = image(1, 1, pDepth, pPalette)
  end if
  if pProps[#flipH] then
    me.flipH()
  end if
  if pProps[#flipV] then
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
  pLocX = tLocX
  pLocY = tLocY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
end

on moveBy me, tOffX, tOffY
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
end

on resizeTo me, tX, tY, tForcedTag
  tOffX = tX - pSprite.width
  tOffY = tY - pSprite.height
  return me.resizeBy(tOffX, tOffY, tForcedTag)
end

on resizeBy me, tOffH, tOffV, tForcedTag
  if (tOffH <> 0) or (tOffV <> 0) then
    case pScaleH of
      #move:
        me.moveBy(tOffH, 0)
      #scale:
        pSprite.width = pSprite.width + tOffH
      #center:
        me.moveBy(tOffH / 2, 0)
      #fixed:
        if tForcedTag then
          pSprite.width = pSprite.width + tOffH
        end if
    end case
    case pScaleV of
      #move:
        me.moveBy(0, tOffV)
      #scale:
        pSprite.height = pSprite.height + tOffV
      #center:
        me.moveBy(0, tOffV / 2)
      #fixed:
        if tForcedTag then
          pSprite.height = pSprite.height + tOffV
        end if
    end case
    pwidth = pSprite.width
    pheight = pSprite.height
    me.render()
  end if
end

on flipH me
  tImage = image(pimage.width, pimage.height, pimage.depth, me.pimage.paletteRef)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
end

on flipV me
  tImage = image(pimage.width, pimage.height, pimage.depth, me.pimage.paletteRef)
  tQuad = [point(0, pimage.height), point(pimage.width, pimage.height), point(pimage.width, 0), point(0, 0)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
end

on getProperty me, tProp
  case tProp of
    #image:
      return pimage
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
      return pSprite.width
    #height:
      return pSprite.height
    #rect:
      return pSprite.rect
    #depth:
      return pimage.depth
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
      me.resizeTo(tValue, pheight)
    #height:
      me.resizeTo(pwidth, tValue)
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
      pimage = tValue
      me.render()
    #buffer, #member:
      pSprite.member = tValue
      pSprite.width = pSprite.member.width
      pSprite.height = pSprite.member.height
    #palette:
      pPalette = tValue
      pimage.paletteRef = pPalette
    #depth:
      pDepth = tValue
      tImage = pimage.duplicate()
      pimage = image(pimage.width, pimage.height, pDepth)
      pimage.copyPixels(tImage, tImage.rect, tImage.rect)
      pimage.paletteRef = pPalette
    #visible:
      if tValue = 1 then
        me.show()
      else
        me.hide()
      end if
    #image:
      pimage = tValue
      me.render()
    otherwise:
      return 0
  end case
  return 1
end

on render me
  pBuffer.image.copyPixels(pimage, pBuffer.image.rect, pimage.rect, pParams)
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pBuffer.image.draw(pBuffer.image.rect, [#shapeType: #rect, #color: tRGB])
end
