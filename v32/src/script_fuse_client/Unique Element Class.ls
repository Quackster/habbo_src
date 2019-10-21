on define(me, tProps)
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

on show(me)
  pVisible = 1
  pSprite.visible = 1
  return(1)
  exit
end

on hide(me)
  pVisible = 0
  pSprite.visible = 0
  return(1)
  exit
end

on moveTo(me, tLocX, tLocY)
  tOffX = tLocX - pLocX
  tOffY = tLocY - pLocY
  pLocX = tLocX
  pLocY = tLocY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
  exit
end

on moveBy(me, tOffX, tOffY)
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
  exit
end

on resizeTo(me, tX, tY, tForcedTag)
  tOffX = tX - pSprite.width
  tOffY = tY - pSprite.height
  return(me.resizeBy(tOffX, tOffY, tForcedTag))
  exit
end

on resizeBy(me, tOffH, tOffV, tForcedTag)
  if tOffH <> 0 or tOffV <> 0 then
    if me = #move then
      me.moveBy(tOffH, 0)
    else
      if me = #scale then
        pSprite.width = pSprite.width + tOffH
      else
        if me = #center then
          me.moveBy(tOffH / 2, 0)
        else
          if me = #fixed then
            if tForcedTag then
              pSprite.width = pSprite.width + tOffH
            end if
          end if
        end if
      end if
    end if
    if me = #move then
      me.moveBy(0, tOffV)
    else
      if me = #scale then
        pSprite.height = pSprite.height + tOffV
      else
        if me = #center then
          me.moveBy(0, tOffV / 2)
        else
          if me = #fixed then
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
  exit
end

on flipH(me)
  tImage = image(pimage.width, pimage.height, pimage.depth, me.paletteRef)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
  exit
end

on flipV(me)
  tImage = image(pimage.width, pimage.height, pimage.depth, me.paletteRef)
  tQuad = [point(0, pimage.height), point(pimage.width, pimage.height), point(pimage.width, 0), point(0, 0)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
  exit
end

on getProperty(me, tProp)
  if me = #image then
    return(pimage)
  else
    if me = #buffer then
      return(pBuffer)
    else
      if me = #member then
        return(pBuffer)
      else
        if me = #sprite then
          return(pSprite)
        else
          if me = #scaleH then
            return(pScaleH)
          else
            if me = #scaleV then
              return(pScaleV)
            else
              if me = #locX then
                return(pLocX)
              else
                if me = #locY then
                  return(pLocY)
                else
                  if me = #locH then
                    return(pLocX)
                  else
                    if me = #locV then
                      return(pLocY)
                    else
                      if me = #locZ then
                        return(pSprite.locZ)
                      else
                        if me = #width then
                          return(pSprite.width)
                        else
                          if me = #height then
                            return(pSprite.height)
                          else
                            if me = #rect then
                              return(pSprite.rect)
                            else
                              if me = #depth then
                                return(pimage.depth)
                              else
                                if me = #color then
                                  return(pSprite.color)
                                else
                                  if me = #bgColor then
                                    return(pSprite.bgColor)
                                  else
                                    if me = #blend then
                                      return(pSprite.blend)
                                    else
                                      if me = #ink then
                                        return(pSprite.ink)
                                      else
                                        if me = #palette then
                                          return(pPalette)
                                        else
                                          if me = #visible then
                                            return(pVisible)
                                          else
                                            if me = #cursor then
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
  exit
end

on setProperty(me, tProp, tValue)
  if me = #scaleH then
    pScaleH = tValue
  else
    if me = #scaleV then
      pScaleV = tValue
    else
      if me = #locX then
        me.moveTo(tValue, pLocY)
      else
        if me = #locY then
          me.moveTo(pLocX, tValue)
        else
          if me = #locH then
            me.moveTo(tValue, pLocY)
          else
            if me = #locV then
              me.moveTo(pLocX, tValue)
            else
              if me = #width then
                me.resizeTo(tValue, pheight)
              else
                if me = #height then
                  me.resizeTo(pwidth, tValue)
                else
                  if me = #color then
                    pSprite.color = tValue
                  else
                    if me = #bgColor then
                      pSprite.bgColor = tValue
                    else
                      if me = #blend then
                        pSprite.blend = tValue
                      else
                        if me = #ink then
                          pSprite.ink = tValue
                        else
                          if me = #cursor then
                            pSprite.setcursor(tValue)
                          else
                            if me = #image then
                              pimage = tValue
                              me.render()
                            else
                              if me <> #buffer then
                                if me = #member then
                                  if me = #member then
                                    pSprite.member = tValue
                                  else
                                    if me = #string then
                                      pSprite.member = getMember(tValue)
                                    else
                                      if me = #integer then
                                        pSprite.member = member(tValue)
                                      else
                                        return(error(me, "Can't set #buffer/#member to type : " & ilk(tValue), #setProperty, #minor))
                                      end if
                                    end if
                                  end if
                                  pSprite.width = member.width
                                  pSprite.height = member.height
                                else
                                  if me = #palette then
                                    pPalette = tValue
                                    pimage.paletteRef = pPalette
                                  else
                                    if me = #depth then
                                      pDepth = tValue
                                      tImage = pimage.duplicate()
                                      pimage = image(pimage.width, pimage.height, pDepth)
                                      pimage.copyPixels(tImage, tImage.rect, tImage.rect)
                                      pimage.paletteRef = pPalette
                                    else
                                      if me = #visible then
                                        if tValue = 1 then
                                          me.show()
                                        else
                                          me.hide()
                                        end if
                                      else
                                        if me = #image then
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
                                exit
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

on render(me)
  pBuffer.copyPixels(pimage, pBuffer.rect, pimage.rect, pParams)
  exit
end

on draw(me, tRGB)
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pBuffer.draw(pBuffer.rect, [#shapeType:#rect, #color:tRGB])
  exit
end

on handlers()
  return([])
  exit
end