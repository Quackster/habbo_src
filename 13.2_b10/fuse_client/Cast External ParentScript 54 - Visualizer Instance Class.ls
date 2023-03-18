property pTitle, pLayout, pLocX, pLocY, pLocZ, pwidth, pheight, pVisible, pSpriteList, pSpriteData, pActSprList, pDragFlag, pDragOffset, pBoundary, pWrappedParts, pSwapAnimList

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
  pBoundary = rect(0, 0, (the stage).rect.width, (the stage).rect.height) + [-1000, -1000, 1000, 1000]
  pWrappedParts = [:]
  pSwapAnimList = [:]
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  repeat with i = 1 to pSpriteList.count
    releaseSprite(pSpriteList[i].spriteNum)
  end repeat
  pSpriteList = []
  pSpriteData = []
  pActSprList = [:]
  pBoundary = []
  repeat with tWrapper in pWrappedParts
    tWrapper.deconstruct()
  end repeat
  pWrappedParts = [:]
  return 1
end

on define me, tProps
  if voidp(tProps) then
    return 0
  end if
  if not voidp(tProps[#locX]) then
    pLocX = tProps[#locX]
  end if
  if not voidp(tProps[#locY]) then
    pLocY = tProps[#locY]
  end if
  if not voidp(tProps[#locZ]) then
    pLocZ = tProps[#locZ]
  end if
  if not voidp(tProps[#layout]) then
    pLayout = tProps[#layout]
  end if
  if not voidp(tProps[#boundary]) then
    pBoundary = tProps[#boundary]
  end if
  return me.open(pLayout)
end

on open me, tLayout
  if voidp(tLayout) then
    tLayout = pLayout
  end if
  pLayout = tLayout
  if pSpriteList.count > 0 then
    repeat with i = 1 to pSpriteList.count
      releaseSprite(pSpriteList[i].spriteNum)
    end repeat
    pSpriteList = []
  end if
  return me.buildVisual(pLayout)
end

on close me
  return me.Remove(me.getID)
end

on moveTo me, tX, tY
  me.moveBy(tX - pLocX, tY - pLocY)
end

on moveBy me, tOffX, tOffY
  if (pLocX + tOffX) < pBoundary[1] then
    tOffX = pBoundary[1] - pLocX
  end if
  if (pLocY + tOffY) < pBoundary[2] then
    tOffY = pBoundary[2] - pLocY
  end if
  if (pLocX + pwidth + tOffX) > pBoundary[3] then
    tOffX = pBoundary[3] - pLocX - pwidth
  end if
  if (pLocY + pheight + tOffY) > pBoundary[4] then
    tOffY = pBoundary[4] - pLocY - pheight
  end if
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.moveXY(tOffX, tOffY)
end

on moveZ me, tZ
  if not integerp(tZ) then
    return error(me, "Integer expected:" && tZ, #moveZ)
  end if
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].locZ = tZ + i - 1
  end repeat
  repeat with tPart in pWrappedParts
    tPart.setProperty(#visLocZ, tZ)
  end repeat
  pLocZ = tZ
end

on getSprite me, tid
  return pActSprList[tid]
end

on getSprById me, tid
  return pActSprList[tid]
end

on getSpriteByID me, tid
  return pActSprList[tid]
end

on spriteExists me, tid
  return not voidp(pActSprList[tid])
end

on moveSprBy me, tid, tX, tY
  tsprite = pActSprList[tid]
  if voidp(tsprite) then
    return error(me, "Sprite not found:" && tid, #moveSprBy)
  end if
  tsprite.loc = tsprite.loc + [tX, tY]
  return me.Refresh()
end

on moveSprTo me, tid, tX, tY
  tsprite = pActSprList[tid]
  if voidp(tsprite) then
    return error(me, "Sprite not found:" && tid, #moveSprTo)
  end if
  tsprite.loc = point(tX, tY)
  return me.Refresh()
end

on setActive me
  return 1
end

on setDeactive me
  return 1
end

on hide me
  if pVisible = 1 then
    pVisible = 0
    me.moveX(10000)
    return 1
  end if
  return 0
end

on show me
  if pVisible = 0 then
    pVisible = 1
    me.moveX(-10000)
    return 1
  end if
  return 0
end

on drag me, tBoolean
  if (tBoolean = 1) and (pDragFlag = 0) then
    pDragOffset = the mouseLoc - [pLocX, pLocY]
    receiveUpdate(me.getID())
    pDragFlag = 1
  else
    if (tBoolean = 0) and (pDragFlag = 1) then
      removeUpdate(me.getID())
      pDragFlag = 0
    end if
  end if
  return 1
end

on getProperty me, tProp
  case tProp of
    #layout:
      return pLayout
    #locX:
      return pLocX
    #locY:
      return pLocY
    #locZ:
      return pLocZ
    #boundary:
      return pBoundary
    #width:
      return pwidth
    #height:
      return pheight
    #sprCount:
      return pSpriteList.count
    #spriteList:
      return pSpriteList
    #spriteData:
      return pSpriteData
    #visible:
      return pVisible
    #title:
      return pTitle
    #id:
      return me.getID()
    #swapAnims:
      return pSwapAnimList
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #layout:
      return me.open(tValue)
    #locX:
      return me.moveX(tValue)
    #locY:
      return me.moveY(tValue)
    #locZ:
      return me.moveZ(tValue)
    #boundary:
      pBoundary = tValue
      return 1
    #visible:
      if tValue then
        return me.show()
      else
        return me.hide()
      end if
    #title:
      pTitle = tValue
      return 1
  end case
  return 0
end

on getWrappedParts me, tWrapTypes
  if voidp(tWrapTypes) or (ilk(tWrapTypes) <> #list) then
    tWrapTypes = [#all]
  end if
  if tWrapTypes.getPos(#all) > 0 then
    return pWrappedParts
  end if
  tWrappedParts = [:]
  repeat with tWrap in pWrappedParts
    if tWrapTypes.getPos(tWrap.getProperty(#type)) > 0 then
      tWrappedParts[tWrap.getProperty(#id)] = tWrap
    end if
  end repeat
  return tWrappedParts
end

on activateWrap me, tWrapper
  tSpr = tWrapper.getProperty(#sprite)
  getSpriteManager().setEventBroker(tSpr.spriteNum, me.getID())
end

on getPartAtLocation me, tLocX, tLocY, tWrapperTypes
  if not (ilk(tWrapperTypes) = #list) then
    tWrapperTypes = [tWrapperTypes]
  end if
  repeat with tWrap in pWrappedParts
    if tWrapperTypes.getOne(tWrap.getProperty(#type)) then
      tPart = tWrap.getPartAt(tLocX, tLocY)
      if ilk(tPart) = #propList then
        return tPart
      end if
    end if
  end repeat
  return 0
end

on createWrapper me, tWrapID
  if not voidp(getaProp(pWrappedParts, tWrapID)) then
    return error(me, "Duplicate wrap id:" && tWrapID, #createWrapper)
  end if
  tWrap = createObject(#random, getClassVariable("visualizer.wrapper.class"))
  tWrap.setProperty(#owner, me.getID())
  pWrappedParts[tWrapID] = tWrap
  tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
  tWrap.setProperty(#sprite, tSpr)
  pSpriteList.append(tSpr)
  pSpriteData.append([:])
  return tWrap
end

on getWallPartUnderRect me, tRect, tSlope
  repeat with tWrap in pWrappedParts
    tWrapType = tWrap.getProperty(#type)
    if (tWrapType = #wallleft) or (tWrapType = #wallright) then
      tPart = tWrap.fitRectToWall(tRect, tSlope)
      if tPart[#insideWall] = 1 then
        return tPart
      end if
    end if
  end repeat
  return [#insideWall: 0]
end

on moveX me, tOffX
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].locH = pSpriteList[i].locH + tOffX
  end repeat
end

on moveY me, tOffY
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].locV = pSpriteList[i].locV + tOffY
  end repeat
end

on moveXY me, tOffX, tOffY
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].loc = pSpriteList[i].loc + [tOffX, tOffY]
  end repeat
end

on update me
  me.moveTo(the mouseH - pDragOffset[1], the mouseV - pDragOffset[2])
end

on Refresh me
  tRect = rect(100000, 100000, -100000, -100000)
  repeat with tWrapper in pWrappedParts
    tWrapper.updateWrap()
  end repeat
  repeat with tSpr in pSpriteList
    if tSpr.locH < tRect[1] then
      tRect[1] = tSpr.locH
    end if
    if tSpr.locV < tRect[2] then
      tRect[2] = tSpr.locV
    end if
    if (tSpr.locH + tSpr.width) > tRect[3] then
      tRect[3] = tSpr.locH + tSpr.width
    end if
    if (tSpr.locV + tSpr.height) > tRect[4] then
      tRect[4] = tSpr.locV + tSpr.height
    end if
  end repeat
  pLocX = tRect[1]
  pLocY = tRect[2]
  pwidth = tRect.width
  pheight = tRect.height
  if pSpriteData.count > 0 then
    repeat with i = 1 to pSpriteList.count
      if listp(pSpriteData[i]) then
        pSpriteData[i][#loc] = pSpriteList[i].loc - [tRect[1], tRect[2]]
      end if
    end repeat
  end if
  return 1
end

on buildVisual me, tLayout
  tLayout = getObjectManager().GET(#layout_parser).parse(tLayout)
  if not listp(tLayout) then
    return error(me, "Invalid visualizer definition:" && tLayout, #buildVisual)
  end if
  if not voidp(tLayout[#rect]) then
    if tLayout[#rect].count > 0 then
      pLocX = pLocX + tLayout[#rect][1][1]
      pLocY = pLocY + tLayout[#rect][1][2]
    end if
  end if
  tLayout = tLayout[#elements]
  tSpriteList = []
  tSpriteCollections = [:]
  repeat with i = 1 to tLayout.count
    tMemNum = getResourceManager().getmemnum(tLayout[i][#member])
    if tMemNum < 1 then
      error(me, "Member" && tLayout[i][#member] && "required by visualizer:" && me.getID() && "not found!", #buildVisual)
      next repeat
    end if
    tElem = tLayout[i]
    if not voidp(tElem[#wrapperID]) then
      tWrapID = tElem[#wrapperID]
      if voidp(pWrappedParts[tWrapID]) then
        tPartWrapper = me.createWrapper(tWrapID)
        tProps = [:]
        tProps[#id] = tWrapID
        tProps[#palette] = tElem[#palette]
        tProps[#offsetx] = pLocX
        tProps[#offsety] = pLocY
        tProps[#locZ] = pLocZ
        tProps[#typeDef] = tElem[#typeDef]
        tPartWrapper.define(tProps)
      else
        tPartWrapper = pWrappedParts[tWrapID]
      end if
      tPartWrapper.addPart(tElem)
    else
      tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
      if tSpr.spriteNum < 1 then
        repeat with t_rSpr in tSpriteList
          releaseSprite(t_rSpr.spriteNum, me.getID())
        end repeat
        tSpriteList = [:]
        return error(me, "Failed to build visual. System out of sprites!", #buildVisual)
      end if
      tSpr.castNum = tMemNum
      tSpr.ink = tElem[#ink]
      tSpr.locH = tElem[#locH] + pLocX
      tSpr.locV = tElem[#locV] + pLocY
      tSpr.width = tElem[#width]
      tSpr.height = tElem[#height]
      tSpr.blend = tElem[#blend]
      tSpr.rotation = tElem[#rotation]
      tSpr.skew = tElem[#skew]
      tSpr.flipH = tElem[#flipH]
      tSpr.flipV = tElem[#flipV]
      tSpr.color = rgb(tElem[#color])
      tSpr.bgColor = rgb(tElem[#bgColor])
      if (tElem[#media] = #text) or (tElem[#media] = #field) then
        tTxtMem = member(tMemNum)
        if not voidp(tElem[#txtColor]) then
          tTxtMem.color = rgb(tElem[#txtColor])
        end if
        if not voidp(tElem[#txtBgColor]) then
          tTxtMem.bgColor = rgb(tElem[#txtBgColor])
        end if
        if tTxtMem.font <> tElem[#font] then
          tTxtMem.font = tElem[#font]
        end if
        if tTxtMem.fontSize <> tElem[#fontSize] then
          tTxtMem.fontSize = tElem[#fontSize]
        end if
        if tTxtMem.fontStyle <> tElem[#fontStyle] then
          tTxtMem.fontStyle = tElem[#fontStyle]
        end if
        if tElem[#media] = #text then
          if tTxtMem.fixedLineSpace <> tElem[#fixedLineSpace] then
            tTxtMem.fixedLineSpace = tElem[#fixedLineSpace]
          end if
        else
          if tElem[#media] = #field then
            if tTxtMem.lineHeight <> tElem[#lineHeight] then
              tTxtMem.lineHeight = tElem[#lineHeight]
            end if
          end if
        end if
      end if
      if voidp(tElem[#locZ]) then
        tSpr.locZ = pLocZ + i - 1
      else
        tSpr.locZ = integer(tElem[#locZ]) + pLocZ
      end if
      if not voidp(tElem[#id]) then
        if (tElem[#Active] = 1) or (voidp(tElem[#Active]) and voidp(tElem[#type])) then
          getSpriteManager().setEventBroker(tSpr.spriteNum, tElem[#id])
          if not voidp(tElem[#cursor]) then
            tSpr.setcursor(tElem[#cursor])
          end if
          if not voidp(tElem[#link]) then
            tSpr.setLink(tElem[#link])
          end if
        end if
        pActSprList[tLayout[i][#id]] = tSpr
      end if
      pSpriteData.append([:])
      tSpriteList.append(tSpr)
    end if
    if not voidp(tElem[#swapAnimType]) then
      tAnimProps = [:]
      tAnimProps[#sprite] = tSpr
      tAnimProps[#animType] = tElem[#swapAnimType]
      tAnimProps[#initDelayType] = tElem[#swapInitDelayType]
      tAnimProps[#initDelay] = tElem[#swapInitDelayValue]
      tAnimProps[#animDelayType] = tElem[#swapAnimDelayType]
      tAnimProps[#animDelay] = tElem[#swapAnimDelayValue]
      tAnimProps[#frameList] = tElem[#swapAnimFrameList]
      tAnimProps[#animLoopCount] = tElem[#swapAnimLoopCount]
      if not voidp(tElem[#id]) then
        pSwapAnimList[tElem[#id]] = tAnimProps
        next repeat
      end if
      error(me, "Animation had no ID", #buildVisual)
    end if
  end repeat
  repeat with tSpr in tSpriteList
    pSpriteList.append(tSpr)
  end repeat
  repeat with tWrapper in pWrappedParts
    if tWrapper.getProperty(#Active) then
      me.activateWrap(tWrapper)
    end if
  end repeat
  return me.Refresh()
end
