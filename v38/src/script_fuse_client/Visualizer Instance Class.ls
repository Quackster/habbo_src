property pSpriteList, pWrappedParts, pLayout, pLocX, pLocY, pBoundary, pwidth, pheight, pActSprList, pVisible, pDragFlag, pLocZ, pSpriteData, pTitle, pSwapAnimList, pDragOffset

on construct me 
  pTitle = me.getID()
  pLayout = []
  pLocX = 0
  pLocY = 0
  pLocZ = 0
  pwidth = 0
  pheight = 0
  pVisible = 1
  pSpriteList = []
  pSpriteData = []
  pActSprList = [:]
  pDragFlag = 0
  pDragOffset = [0, 0]
  pBoundary = rect(0, 0, undefined.width, undefined.height) + [-1000, -1000, 1000, 1000]
  pWrappedParts = [:]
  pSwapAnimList = [:]
  return(1)
end

on deconstruct me 
  removeUpdate(me.getID())
  i = 1
  repeat while i <= pSpriteList.count
    releaseSprite(pSpriteList.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  pSpriteList = []
  pSpriteData = []
  pActSprList = [:]
  pBoundary = []
  repeat while pWrappedParts <= undefined
    tWrapper = getAt(undefined, undefined)
    tWrapper.deconstruct()
  end repeat
  pWrappedParts = [:]
  return(1)
end

on define me, tProps 
  if voidp(tProps) then
    return(0)
  end if
  if not voidp(tProps.getAt(#locX)) then
    pLocX = tProps.getAt(#locX)
  end if
  if not voidp(tProps.getAt(#locY)) then
    pLocY = tProps.getAt(#locY)
  end if
  if not voidp(tProps.getAt(#locZ)) then
    pLocZ = tProps.getAt(#locZ)
  end if
  if not voidp(tProps.getAt(#layout)) then
    pLayout = tProps.getAt(#layout)
  end if
  if not voidp(tProps.getAt(#boundary)) then
    pBoundary = tProps.getAt(#boundary)
  end if
  return(me.open(pLayout))
end

on open me, tLayout 
  if voidp(tLayout) then
    tLayout = pLayout
  end if
  pLayout = tLayout
  if pSpriteList.count > 0 then
    i = 1
    repeat while i <= pSpriteList.count
      releaseSprite(pSpriteList.getAt(i).spriteNum)
      i = 1 + i
    end repeat
    pSpriteList = []
  end if
  return(me.buildVisual(pLayout))
end

on close me 
  return(me.Remove(me.getID))
end

on moveTo me, tX, tY 
  me.moveBy(tX - pLocX, tY - pLocY)
end

on moveBy me, tOffX, tOffY 
  if pLocX + tOffX < pBoundary.getAt(1) then
    tOffX = pBoundary.getAt(1) - pLocX
  end if
  if pLocY + tOffY < pBoundary.getAt(2) then
    tOffY = pBoundary.getAt(2) - pLocY
  end if
  if pLocX + pwidth + tOffX > pBoundary.getAt(3) then
    tOffX = pBoundary.getAt(3) - pLocX - pwidth
  end if
  if pLocY + pheight + tOffY > pBoundary.getAt(4) then
    tOffY = pBoundary.getAt(4) - pLocY - pheight
  end if
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.moveXY(tOffX, tOffY)
end

on moveZ me, tZ 
  if not integerp(tZ) then
    return(error(me, "Integer expected:" && tZ, #moveZ, #minor))
  end if
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).locZ = tZ + i - 1
    i = 1 + i
  end repeat
  repeat while pWrappedParts <= undefined
    tPart = getAt(undefined, tZ)
    tPart.setProperty(#visLocZ, tZ)
  end repeat
  pLocZ = tZ
end

on getSprite me, tID 
  return(pActSprList.getaProp(tID))
end

on getSprById me, tID 
  return(pActSprList.getaProp(tID))
end

on getSpriteByID me, tID 
  return(pActSprList.getaProp(tID))
end

on spriteExists me, tID 
  return(not voidp(pActSprList.getaProp(tID)))
end

on moveSprBy me, tID, tX, tY 
  tsprite = pActSprList.getaProp(tID)
  if voidp(tsprite) then
    return(error(me, "Sprite not found:" && tID, #moveSprBy, #minor))
  end if
  tsprite.loc = tsprite.loc + [tX, tY]
  return(me.Refresh())
end

on moveSprTo me, tID, tX, tY 
  tsprite = pActSprList.getaProp(tID)
  if voidp(tsprite) then
    return(error(me, "Sprite not found:" && tID, #moveSprTo, #minor))
  end if
  tsprite.loc = point(tX, tY)
  return(me.Refresh())
end

on setActive me 
  return(1)
end

on setDeactive me 
  return(1)
end

on hide me 
  if pVisible = 1 then
    pVisible = 0
    me.moveX(10000)
    return(1)
  end if
  return(0)
end

on show me 
  if pVisible = 0 then
    pVisible = 1
    me.moveX(-10000)
    return(1)
  end if
  return(0)
end

on drag me, tBoolean 
  if tBoolean = 1 and pDragFlag = 0 then
    pDragOffset = the mouseLoc - [pLocX, pLocY]
    receiveUpdate(me.getID())
    pDragFlag = 1
  else
    if tBoolean = 0 and pDragFlag = 1 then
      removeUpdate(me.getID())
      pDragFlag = 0
    end if
  end if
  return(1)
end

on getProperty me, tProp 
  if tProp = #layout then
    return(pLayout)
  else
    if tProp = #locX then
      return(pLocX)
    else
      if tProp = #locY then
        return(pLocY)
      else
        if tProp = #locZ then
          return(pLocZ)
        else
          if tProp = #boundary then
            return(pBoundary)
          else
            if tProp = #width then
              return(pwidth)
            else
              if tProp = #height then
                return(pheight)
              else
                if tProp = #sprCount then
                  return(pSpriteList.count)
                else
                  if tProp = #spriteList then
                    return(pSpriteList)
                  else
                    if tProp = #spriteData then
                      return(pSpriteData)
                    else
                      if tProp = #visible then
                        return(pVisible)
                      else
                        if tProp = #title then
                          return(pTitle)
                        else
                          if tProp = #id then
                            return(me.getID())
                          else
                            if tProp = #swapAnims then
                              return(pSwapAnimList)
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
  return(0)
end

on setProperty me, tProp, tValue 
  if tProp = #layout then
    return(me.open(tValue))
  else
    if tProp = #locX then
      return(me.moveX(tValue))
    else
      if tProp = #locY then
        return(me.moveY(tValue))
      else
        if tProp = #locZ then
          return(me.moveZ(tValue))
        else
          if tProp = #boundary then
            pBoundary = tValue
            return(1)
          else
            if tProp = #visible then
              if tValue then
                return(me.show())
              else
                return(me.hide())
              end if
            else
              if tProp = #title then
                pTitle = tValue
                return(1)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(0)
end

on getWrappedParts me, tWrapTypes 
  if voidp(tWrapTypes) or ilk(tWrapTypes) <> #list then
    tWrapTypes = [#all]
  end if
  if tWrapTypes.getPos(#all) > 0 then
    return(pWrappedParts)
  end if
  tWrappedParts = [:]
  repeat while pWrappedParts <= undefined
    tWrap = getAt(undefined, tWrapTypes)
    if tWrapTypes.getPos(tWrap.getProperty(#type)) > 0 then
      tWrappedParts.setAt(tWrap.getProperty(#id), tWrap)
    end if
  end repeat
  return(tWrappedParts)
end

on activateWrap me, tWrapper 
  tSpr = tWrapper.getProperty(#sprite)
  getSpriteManager().setEventBroker(tSpr.spriteNum, me.getID())
end

on getPartAtLocation me, tLocX, tLocY, tWrapperTypes 
  if not ilk(tWrapperTypes) = #list then
    tWrapperTypes = [tWrapperTypes]
  end if
  repeat while pWrappedParts <= tLocY
    tWrap = getAt(tLocY, tLocX)
    if tWrapperTypes.getOne(tWrap.getProperty(#type)) then
      tPart = tWrap.getPartAt(tLocX, tLocY)
      if ilk(tPart) = #propList then
        return(tPart)
      end if
    end if
  end repeat
  return(0)
end

on createWrapper me, tWrapID 
  if not voidp(getaProp(pWrappedParts, tWrapID)) then
    return(error(me, "Duplicate wrap id:" && tWrapID, #createWrapper))
  end if
  tWrap = createObject(#random, getClassVariable("visualizer.wrapper.class"))
  tWrap.setProperty(#owner, me.getID())
  pWrappedParts.setAt(tWrapID, tWrap)
  tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
  tWrap.setProperty(#sprite, tSpr)
  pSpriteList.append(tSpr)
  pSpriteData.append([:])
  return(tWrap)
end

on getWallPartUnderRect me, tRect, tSlope 
  repeat while pWrappedParts <= tSlope
    tWrap = getAt(tSlope, tRect)
    tWrapType = tWrap.getProperty(#type)
    if tWrapType = #wallleft or tWrapType = #wallright then
      tPart = tWrap.fitRectToWall(tRect, tSlope)
      if tPart.getAt(#insideWall) = 1 then
        return(tPart)
      end if
    end if
  end repeat
  return([#insideWall:0])
end

on renderWrappedParts me, tColor 
  if ilk(tColor) <> #color then
    return(0)
  end if
  if tColor.red + tColor.green + tColor.blue > (250 * 3) then
    tColor = color(248, 248, 248)
  end if
  repeat while pWrappedParts <= undefined
    tWrapper = getAt(undefined, tColor)
    tWrapper.renderWithColor(tColor)
  end repeat
end

on setDimmerColor me, tColor 
  if ilk(tColor) <> #color then
    return(0)
  end if
  tColor = rgb(255 - tColor.red, 255 - tColor.green, 255 - tColor.blue)
  if memberExists("room_dimmer_image") then
    tMem = getMember("room_dimmer_image")
    tMem.setPixel(0, 0, tColor)
  end if
end

on moveX me, tOffX 
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).locH = pSpriteList.getAt(i).locH + tOffX
    i = 1 + i
  end repeat
end

on moveY me, tOffY 
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).locV = pSpriteList.getAt(i).locV + tOffY
    i = 1 + i
  end repeat
end

on moveXY me, tOffX, tOffY 
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).loc = pSpriteList.getAt(i).loc + [tOffX, tOffY]
    i = 1 + i
  end repeat
end

on update me 
  me.moveTo(the mouseH - pDragOffset.getAt(1), the mouseV - pDragOffset.getAt(2))
end

on Refresh me 
  tRect = rect(100000, 100000, -100000, -100000)
  repeat while pWrappedParts <= undefined
    tWrapper = getAt(undefined, undefined)
    tWrapper.updateWrap()
  end repeat
  repeat while pWrappedParts <= undefined
    tSpr = getAt(undefined, undefined)
    if tSpr.locH < tRect.getAt(1) then
      tRect.setAt(1, tSpr.locH)
    end if
    if tSpr.locV < tRect.getAt(2) then
      tRect.setAt(2, tSpr.locV)
    end if
    if tSpr.locH + tSpr.width > tRect.getAt(3) then
      tRect.setAt(3, tSpr.locH + tSpr.width)
    end if
    if tSpr.locV + tSpr.height > tRect.getAt(4) then
      tRect.setAt(4, tSpr.locV + tSpr.height)
    end if
  end repeat
  pLocX = tRect.getAt(1)
  pLocY = tRect.getAt(2)
  pwidth = tRect.width
  pheight = tRect.height
  if pSpriteData.count > 0 then
    i = 1
    repeat while i <= pSpriteList.count
      if listp(pSpriteData.getAt(i)) then
        pSpriteData.getAt(i).setAt(#loc, pSpriteList.getAt(i).loc - [tRect.getAt(1), tRect.getAt(2)])
      end if
      i = 1 + i
    end repeat
  end if
  return(1)
end

on buildVisual me, tLayout 
  tLayoutName = tLayout
  tPrivate = 0
  if tLayoutName.length >= 7 then
    -- UNK_21
    ERROR.setContents()
    if tLayoutName = "model_x.room" then
      tPrivate = 1
    end if
  end if
  tLayout = getObjectManager().GET(#layout_parser).parse(tLayout)
  if not listp(tLayout) then
    return(error(me, "Invalid visualizer definition:" && tLayout, #buildVisual, #major))
  end if
  if not voidp(tLayout.getAt(#rect)) then
    if tLayout.getAt(#rect).count > 0 then
      pLocX = pLocX + tLayout.getAt(#rect).getAt(1).getAt(1)
      pLocY = pLocY + tLayout.getAt(#rect).getAt(1).getAt(2)
    end if
  end if
  tLayout = tLayout.getAt(#elements)
  tSpriteList = []
  tSpriteCollections = [:]
  i = 1
  repeat while i <= tLayout.count
    tMemNum = getResourceManager().getmemnum(tLayout.getAt(i).getAt(#member))
    if tMemNum < 1 then
      error(me, "Member" && tLayout.getAt(i).getAt(#member) && "required by visualizer:" && me.getID() && "not found!", #buildVisual, #major)
    else
      tElem = tLayout.getAt(i)
      if not voidp(tElem.getAt(#wrapperID)) then
        tWrapID = tElem.getAt(#wrapperID)
        if voidp(pWrappedParts.getAt(tWrapID)) then
          tPartWrapper = me.createWrapper(tWrapID)
          tProps = [:]
          tProps.setAt(#id, tWrapID)
          tProps.setAt(#palette, tElem.getAt(#palette))
          tProps.setAt(#offsetx, pLocX)
          tProps.setAt(#offsety, pLocY)
          tProps.setAt(#locZ, pLocZ)
          tProps.setAt(#typeDef, tElem.getAt(#typeDef))
          tPartWrapper.define(tProps)
        else
          tPartWrapper = pWrappedParts.getAt(tWrapID)
        end if
        tPartWrapper.addPart(tElem)
      else
        tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
        if tSpr.spriteNum < 1 then
          repeat while tSpriteList <= undefined
            t_rSpr = getAt(undefined, tLayout)
            releaseSprite(t_rSpr.spriteNum, me.getID())
          end repeat
          tSpriteList = [:]
          return(error(me, "Failed to build visual. System out of sprites!", #buildVisual, #major))
        end if
        tSpr.castNum = tMemNum
        tSpr.ink = tElem.getAt(#ink)
        tSpr.locH = tElem.getAt(#locH) + pLocX
        tSpr.locV = tElem.getAt(#locV) + pLocY
        tSpr.width = tElem.getAt(#width)
        tSpr.height = tElem.getAt(#height)
        tSpr.blend = tElem.getAt(#blend)
        tSpr.rotation = tElem.getAt(#rotation)
        tSpr.skew = tElem.getAt(#skew)
        tSpr.flipH = tElem.getAt(#flipH)
        tSpr.flipV = tElem.getAt(#flipV)
        tSpr.color = rgb(tElem.getAt(#color))
        tSpr.bgColor = rgb(tElem.getAt(#bgColor))
        if tElem.getAt(#media) = #text or tElem.getAt(#media) = #field then
          tTxtMem = member(tMemNum)
          if not voidp(tElem.getAt(#txtColor)) then
            tTxtMem.color = rgb(tElem.getAt(#txtColor))
          end if
          if not voidp(tElem.getAt(#txtBgColor)) then
            tTxtMem.bgColor = rgb(tElem.getAt(#txtBgColor))
          end if
          if tTxtMem.font <> tElem.getAt(#font) then
            tTxtMem.font = tElem.getAt(#font)
          end if
          if tTxtMem.fontSize <> tElem.getAt(#fontSize) then
            tTxtMem.fontSize = tElem.getAt(#fontSize)
          end if
          if tTxtMem.fontStyle <> tElem.getAt(#fontStyle) then
            tTxtMem.fontStyle = tElem.getAt(#fontStyle)
          end if
          if tElem.getAt(#media) = #text then
            if tTxtMem.fixedLineSpace <> tElem.getAt(#fixedLineSpace) then
              tTxtMem.fixedLineSpace = tElem.getAt(#fixedLineSpace)
            end if
          else
            if tElem.getAt(#media) = #field then
              if tTxtMem.lineHeight <> tElem.getAt(#lineHeight) then
                tTxtMem.lineHeight = tElem.getAt(#lineHeight)
              end if
            end if
          end if
        end if
        if voidp(tElem.getAt(#locZ)) then
          tSpr.locZ = pLocZ + i - 1
        else
          tSpr.locZ = integer(tElem.getAt(#locZ)) + pLocZ
        end if
        if not voidp(tElem.getAt(#id)) then
          if tElem.getAt(#Active) = 1 or voidp(tElem.getAt(#Active)) and voidp(tElem.getAt(#type)) then
            getSpriteManager().setEventBroker(tSpr.spriteNum, tElem.getAt(#id))
            if not voidp(tElem.getAt(#cursor)) then
              tSpr.setcursor(tElem.getAt(#cursor))
            end if
            if not voidp(tElem.getAt(#link)) then
              tSpr.setLink(tElem.getAt(#link))
            end if
          end if
          pActSprList.setAt(tLayout.getAt(i).getAt(#id), tSpr)
        end if
        pSpriteData.append([:])
        tSpriteList.append(tSpr)
      end if
      if not voidp(tElem.getAt(#swapAnimType)) then
        tAnimProps = [:]
        tAnimProps.setAt(#sprite, tSpr)
        tAnimProps.setAt(#animType, tElem.getAt(#swapAnimType))
        tAnimProps.setAt(#initDelayType, tElem.getAt(#swapInitDelayType))
        tAnimProps.setAt(#initDelay, tElem.getAt(#swapInitDelayValue))
        tAnimProps.setAt(#animDelayType, tElem.getAt(#swapAnimDelayType))
        tAnimProps.setAt(#animDelay, tElem.getAt(#swapAnimDelayValue))
        tAnimProps.setAt(#frameList, tElem.getAt(#swapAnimFrameList))
        tAnimProps.setAt(#animLoopCount, tElem.getAt(#swapAnimLoopCount))
        if not voidp(tElem.getAt(#id)) then
          pSwapAnimList.setAt(tElem.getAt(#id), tAnimProps)
        else
          error(me, "Animation had no ID", #buildVisual, #minor)
        end if
      end if
    end if
    i = 1 + i
  end repeat
  if tPrivate then
    tThread = getThread(#room)
    if tThread <> 0 then
      tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
      tmember = getMember("room_dimmer_image")
      if tmember <> 0 then
        tSpr.member = tmember.number
        tSpr.ink = 35
        tSpr.locH = 0
        tSpr.locV = 0
        tSpr.width = 800
        tSpr.height = 600
        tSpr.blend = 100
        tGeometry = tThread.getInterface().getGeometry()
        tScreenLoc = tGeometry.getScreenCoordinate(2, 2, 0)
        tSpr.locZ = tSpriteList.getAt(tSpriteList.count).locZ + (100 * 1000)
        tSpriteList.append(tSpr)
        pSpriteData.append([:])
      end if
    end if
  end if
  repeat while tSpriteList <= undefined
    tSpr = getAt(undefined, tLayout)
    pSpriteList.append(tSpr)
  end repeat
  repeat while tSpriteList <= undefined
    tWrapper = getAt(undefined, tLayout)
    if tWrapper.getProperty(#Active) then
      me.activateWrap(tWrapper)
    end if
  end repeat
  return(me.Refresh())
end

on handlers  
  return([])
end
