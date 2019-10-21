on construct(me)
  pElemList = []
  pPalette = #systemMac
  pScaleH = #fixed
  pScaleV = #fixed
  pLocX = 0
  pLocY = 0
  pwidth = 0
  pheight = 0
  pVisible = 1
  return(1)
  exit
end

on deconstruct(me)
  call(#deconstruct, pElemList)
  pElemList = []
  pBuffer = void()
  pSprite = void()
  return(1)
  exit
end

on define(me, tProps)
  pID = tProps.getAt(#id)
  pBuffer = tProps.getAt(#buffer)
  pSprite = tProps.getAt(#sprite)
  pLocX = tProps.getAt(#locX)
  pLocY = tProps.getAt(#locY)
  pwidth = pBuffer.width
  pheight = pBuffer.height
  pPalette = pBuffer.paletteRef
  return(1)
  exit
end

on add(me, tElement)
  if not objectp(tElement) then
    return(0)
  end if
  if tElement.getProperty(#scaleH) <> #fixed then
    pScaleH = #scale
  end if
  if tElement.getProperty(#scaleV) <> #fixed then
    pScaleV = #scale
  end if
  pElemList.add(tElement)
  return(1)
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
  me.moveBy(tOffX, tOffY)
  exit
end

on moveBy(me, tOffX, tOffY)
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
  exit
end

on resizeBy(me, tOffW, tOffH)
  if tOffW <> 0 or tOffH <> 0 then
    if me = #fixed then
      tOffW = 0
    else
      if me = #scale then
        pwidth = pwidth + tOffW
      else
        if me = #move then
          me.moveBy(tOffW, 0)
        else
          if me = #center then
            me.moveBy(tOffW / 2, 0)
          end if
        end if
      end if
    end if
    if pScaleH <> #scale then
      tOffW = 0
    end if
    if me = #fixed then
      tOffH = 0
    else
      if me = #scale then
        pheight = pheight + tOffH
      else
        if me = #move then
          me.moveBy(0, tOffH)
        else
          if me = #center then
            me.moveBy(0, tOffH / 2)
          end if
        end if
      end if
    end if
    if pScaleV <> #scale then
      tOffH = 0
    end if
    if tOffW <> 0 or tOffH <> 0 then
      if pwidth < 1 then
        pwidth = 1
      end if
      if pheight < 1 then
        pheight = 1
      end if
      pBuffer.image = image(pwidth, pheight, pBuffer.depth, pPalette)
      pBuffer.regPoint = point(0, 0)
      pSprite.width = pwidth
      pSprite.height = pheight
      pSprite.stretch = 0
      call(#resizeBy, pElemList, tOffW, tOffH)
    end if
  end if
  exit
end

on getProperty(me, tProp)
  if me = #image then
    return(pBuffer.image)
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
                          return(pwidth)
                        else
                          if me = #height then
                            return(pheight)
                          else
                            if me = #depth then
                              return(pBuffer.depth)
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
                me.resizeBy(pwidth - tValue, 0)
              else
                if me = #height then
                  me.resizeBy(0, pheight - tValue)
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
                              tRegPnt = pBuffer.regPoint
                              pBuffer.image = tValue
                              pBuffer.regPoint = tRegPnt
                              pSprite.width = pBuffer.width
                              pSprite.height = pBuffer.height
                              pwidth = pBuffer.width
                              pheight = pBuffer.height
                            else
                              if me <> #buffer then
                                if me = #member then
                                  pBuffer = tValue
                                  pwidth = pBuffer.width
                                  pheight = pBuffer.height
                                  pPalette = pBuffer.paletteRef
                                  pSprite.castNum = pBuffer.number
                                else
                                  if me = #palette then
                                    pPalette = tValue
                                    pBuffer.paletteRef = pPalette
                                  else
                                    if me = #depth then
                                      tImage = pBuffer.duplicate()
                                      pBuffer.image = image(tImage.width, tImage.height, tValue)
                                      pBuffer.copyPixels(tImage, tImage.rect, tImage.rect)
                                      pBuffer.paletteRef = pPalette
                                    else
                                      if me = #visible then
                                        if tValue = 1 then
                                          me.show()
                                        else
                                          me.hide()
                                        end if
                                      else
                                        return(0)
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

on prepare(me)
  call(#prepare, pElemList)
  exit
end

on render(me)
  if pVisible then
    call(#render, pElemList)
  end if
  exit
end

on draw(me, tRGB)
  call(#draw, pElemList, tRGB)
  exit
end