property pPalette, pProps, pimage, pDepth, pParams, pSprite, pLocX, pLocY, pScaleH, pScaleV, pBuffer, pVisible, pheight, pwidth

on define me, tProps 
  pID = tProps.getAt(#id)
  pMotherId = tProps.getAt(#mother)
  pType = tProps.getAt(#type)
  pScaleH = tProps.getAt(#scaleH)
  pScaleV = tProps.getAt(#scaleV)
  pBuffer = tProps.getAt(#buffer)
  pSprite = tProps.getAt(#sprite)
  pLocX = tProps.getAt(#locH)
  pLocY = tProps.getAt(#locV)
  pwidth = tProps.getAt(#width)
  pheight = tProps.getAt(#height)
  pPalette = tProps.getAt(#palette)
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
  tMemNum = getResourceManager().getmemnum(pProps.getAt(#member))
  if tMemNum > 0 then
    tmember = member(tMemNum)
    if tmember.type = #bitmap then
      pimage = tmember.duplicate()
      pDepth = tmember.depth
      if pimage.paletteRef <> pPalette then
        pimage.paletteRef = pPalette
      end if
    end if
  end if
  if voidp(pimage) then
    pDepth = the colorDepth
    pimage = image(1, 1, pDepth, pPalette)
  end if
  if pProps.getAt(#flipH) then
    me.flipH()
  end if
  if pProps.getAt(#flipV) then
    me.flipV()
  end if
  pParams = [:]
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
end

on prepare me 
end

on show me 
  pVisible = 1
  pSprite.visible = 1
  return(1)
end

on hide me 
  pVisible = 0
  pSprite.visible = 0
  return(1)
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
  return(me.resizeBy(tOffX, tOffY, tForcedTag))
end

on resizeBy me, tOffH, tOffV, tForcedTag 
  if tOffH <> 0 or tOffV <> 0 then
    if pScaleH = #move then
      me.moveBy(tOffH, 0)
    else
      if pScaleH = #scale then
        pSprite.width = pSprite.width + tOffH
      else
        if pScaleH = #center then
          me.moveBy((tOffH / 2), 0)
        else
          if pScaleH = #fixed then
            if tForcedTag then
              pSprite.width = pSprite.width + tOffH
            end if
          end if
        end if
      end if
    end if
    if pScaleH = #move then
      me.moveBy(0, tOffV)
    else
      if pScaleH = #scale then
        pSprite.height = pSprite.height + tOffV
      else
        if pScaleH = #center then
          me.moveBy(0, (tOffV / 2))
        else
          if pScaleH = #fixed then
            if tForcedTag then
              pSprite.height = pSprite.height + tOffV
            end if
          end if
        end if
      end if
    end if
    pwidth = pSprite.width
    pheight = pSprite.height
    me.render()
  end if
end

on flipH me 
  tImage = image(pimage.width, pimage.height, pimage.depth, me.paletteRef)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
end

on flipV me 
  tImage = image(pimage.width, pimage.height, pimage.depth, me.paletteRef)
  tQuad = [point(0, pimage.height), point(pimage.width, pimage.height), point(pimage.width, 0), point(0, 0)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
end

on getProperty me, tProp 
  if tProp = #image then
    return(pimage)
  else
    if tProp = #buffer then
      return(pBuffer)
    else
      if tProp = #member then
        return(pBuffer)
      else
        if tProp = #sprite then
          return(pSprite)
        else
          if tProp = #scaleH then
            return(pScaleH)
          else
            if tProp = #scaleV then
              return(pScaleV)
            else
              if tProp = #locX then
                return(pLocX)
              else
                if tProp = #locY then
                  return(pLocY)
                else
                  if tProp = #locH then
                    return(pLocX)
                  else
                    if tProp = #locV then
                      return(pLocY)
                    else
                      if tProp = #locZ then
                        return(pSprite.locZ)
                      else
                        if tProp = #width then
                          return(pSprite.width)
                        else
                          if tProp = #height then
                            return(pSprite.height)
                          else
                            if tProp = #rect then
                              return(pSprite.rect)
                            else
                              if tProp = #depth then
                                return(pimage.depth)
                              else
                                if tProp = #color then
                                  return(pSprite.color)
                                else
                                  if tProp = #bgColor then
                                    return(pSprite.bgColor)
                                  else
                                    if tProp = #blend then
                                      return(pSprite.blend)
                                    else
                                      if tProp = #ink then
                                        return(pSprite.ink)
                                      else
                                        if tProp = #palette then
                                          return(pPalette)
                                        else
                                          if tProp = #visible then
                                            return(pVisible)
                                          else
                                            if tProp = #cursor then
                                              return(pSprite.cursor)
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
    end if
  end if
end

on setProperty me, tProp, tValue 
  if tProp = #scaleH then
    pScaleH = tValue
  else
    if tProp = #scaleV then
      pScaleV = tValue
    else
      if tProp = #locX then
        me.moveTo(tValue, pLocY)
      else
        if tProp = #locY then
          me.moveTo(pLocX, tValue)
        else
          if tProp = #locH then
            me.moveTo(tValue, pLocY)
          else
            if tProp = #locV then
              me.moveTo(pLocX, tValue)
            else
              if tProp = #width then
                me.resizeTo(tValue, pheight)
              else
                if tProp = #height then
                  me.resizeTo(pwidth, tValue)
                else
                  if tProp = #color then
                    pSprite.color = tValue
                  else
                    if tProp = #bgColor then
                      pSprite.bgColor = tValue
                    else
                      if tProp = #blend then
                        pSprite.blend = tValue
                      else
                        if tProp = #ink then
                          pSprite.ink = tValue
                        else
                          if tProp = #cursor then
                            pSprite.setcursor(tValue)
                          else
                            if tProp = #image then
                              pimage = tValue
                              me.render()
                            else
                              if tProp <> #buffer then
                                if tProp = #member then
                                  pSprite.member = tValue
                                  pSprite.width = member.width
                                  pSprite.height = member.height
                                else
                                  if tProp = #palette then
                                    pPalette = tValue
                                    pimage.paletteRef = pPalette
                                  else
                                    if tProp = #depth then
                                      pDepth = tValue
                                      tImage = pimage.duplicate()
                                      pimage = image(pimage.width, pimage.height, pDepth)
                                      pimage.copyPixels(tImage, tImage.rect, tImage.rect)
                                      pimage.paletteRef = pPalette
                                    else
                                      if tProp = #visible then
                                        if tValue = 1 then
                                          me.show()
                                        else
                                          me.hide()
                                        end if
                                      else
                                        if tProp = #image then
                                          pimage = tValue
                                          me.render()
                                        else
                                          return(0)
                                        end if
                                      end if
                                    end if
                                  end if
                                end if
                                return(1)
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
          end if
        end if
      end if
    end if
  end if
end

on render me 
  pBuffer.copyPixels(pimage, pBuffer.rect, pimage.rect, pParams)
end

on draw me, tRGB 
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pBuffer.draw(pBuffer.rect, [#shapeType:#rect, #color:tRGB])
end
