on define(me, tProps)
  pID = tProps.getAt(#id)
  pMotherId = tProps.getAt(#mother)
  pType = tProps.getAt(#type)
  pBuffer = tProps.getAt(#buffer)
  pSprite = tProps.getAt(#sprite)
  pPalette = tProps.getAt(#palette)
  pScaleH = tProps.getAt(#scaleH)
  pScaleV = tProps.getAt(#scaleV)
  pLocX = tProps.getAt(#locH)
  pLocY = tProps.getAt(#locV)
  pwidth = tProps.getAt(#width)
  pheight = tProps.getAt(#height)
  pProps = tProps
  pVisible = 1
  if voidp(pPalette) then
    pPalette = #systemMac
  else
    if stringp(pPalette) then
      pPalette = member(getResourceManager().getmemnum(pPalette))
    end if
  end if
  if voidp(pProps.getAt(#member)) then
    tMemNum = 0
  else
    tMemNum = getResourceManager().getmemnum(pProps.getAt(#member))
  end if
  if tMemNum > 0 and pType <> "image" then
    tmember = member(tMemNum)
    pDepth = tmember.depth
    pimage = tmember.duplicate()
    if pimage.paletteRef <> pPalette then
      pimage.paletteRef = pPalette
    end if
  else
    pDepth = the colorDepth
    pimage = image(1, 1, pDepth, pPalette)
  end if
  if me.getProp(#pProps, #flipH) then
    me.flipH()
  end if
  if me.getProp(#pProps, #flipV) then
    me.flipV()
  end if
  pParams = []
  if tProps.getAt(#blend) < 100 then
    pParams.setAt(#blend, tProps.getAt(#blend))
  end if
  if tProps.getAt(#color) <> rgb(0, 0, 0) then
    pParams.setAt(#color, tProps.getAt(#color))
  end if
  if tProps.getAt(#bgColor) <> rgb(255, 255, 255) then
    pParams.setAt(#bgColor, tProps.getAt(#bgColor))
  end if
  if tProps.getAt(#ink) <> 0 then
    pParams.setAt(#ink, tProps.getAt(#ink))
  end if
  if pParams.count = 0 then
    pParams = void()
  end if
  return(1)
  exit
end

on prepare(me)
  exit
end

on moveTo(me, tLocX, tLocY)
  pLocX = tLocX
  pLocY = tLocY
  me.render()
  exit
end

on moveBy(me, tOffX, tOffY)
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.render()
  exit
end

on resizeTo(me, tX, tY)
  tOffX = tX - pwidth
  tOffY = tY - pheight
  return(me.resizeBy(tOffX, tOffY))
  exit
end

on resizeBy(me, tOffH, tOffV)
  if me = #move then
    pLocX = pLocX + tOffH
  else
    if me = #center then
      pLocX = pLocX + tOffH / 2
    else
      if me = #scale then
        pwidth = pwidth + tOffH
      end if
    end if
  end if
  if me = #move then
    pLocY = pLocY + tOffV
  else
    if me = #center then
      pLocY = pLocY + tOffV / 2
    else
      if me = #scale then
        pheight = pheight + tOffV
      end if
    end if
  end if
  me.render()
  exit
end

on flipH(me)
  tImage = image(pimage.width, pimage.height, pimage.depth, pimage.paletteRef)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  me.pimage = tImage
  exit
end

on flipV(me)
  tImage = image(pimage.width, pimage.height, pimage.depth, pimage.paletteRef)
  tQuad = [point(0, pimage.height), point(pimage.width, pimage.height), point(pimage.width, 0), point(0, 0)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
  exit
end

on getProperty(me, tProp)
  if me = #buffer then
    return(pBuffer)
  else
    if me = #sprite then
      return(pSprite)
    else
      if me = #width then
        return(pwidth)
      else
        if me = #height then
          return(pheight)
        else
          if me = #locX then
            return(pLocX)
          else
            if me = #locY then
              return(pLocY)
            else
              if me = #scaleH then
                return(pScaleH)
              else
                if me = #scaleV then
                  return(pScaleV)
                else
                  if me = #depth then
                    return(pDepth)
                  else
                    if me = #palette then
                      return(pPalette)
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
  end if
  exit
end

on render(me)
  tTargetRect = rect(pLocX, pLocY, pLocX + pwidth, pLocY + pheight)
  tSourceRect = pimage.rect
  pBuffer.copyPixels(pimage, tTargetRect, tSourceRect, pParams)
  exit
end

on draw(me, tRGB)
  if not ilk(tRGB, #color) then
    tRGB = rgb(0, 0, 255)
  end if
  tTargetRect = rect(pLocX, pLocY, pLocX + pwidth, pLocY + pheight)
  pBuffer.draw(tTargetRect, [#shapeType:#rect, #color:tRGB])
  exit
end