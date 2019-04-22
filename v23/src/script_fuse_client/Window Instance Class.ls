property pSpriteList, pElemList, pMemberList, pSpecialIDList, pGroupData, pWindowMngr, pClientRect, pVisible, pLocX, pLocY, pBoundary, pwidth, pheight, pActive, pLock, pProcedures, pLocZ, pTitle, pModal, pClientID, pScaleOffset, pDragOffset, pElemClsList, pScaleFlag, pDragFlag

on construct me 
  pTitle = me.getID()
  pLocX = 0
  pLocY = 0
  pLocZ = 0
  pwidth = 0
  pheight = 0
  pVisible = 1
  pActive = 0
  pLock = 0
  pModal = 0
  pSpriteList = [:]
  pScaleFlag = 0
  pDragFlag = 0
  pDragOffset = [0, 0]
  pBoundary = rect(the stage, rect.width, the stage, rect.height) + [-20, -20, 20, 20]
  pClientID = void()
  pMemberList = [:]
  pElemList = [:]
  pGroupData = []
  pClientRect = [0, 0, 0, 0]
  pSpecialIDList = ["drag", "close", "scale"]
  pProcedures = me.createProcListTemplate()
  return(1)
end

on deconstruct me 
  removeUpdate(me.getID())
  removePrepare(me.getID())
  i = 1
  repeat while i <= pSpriteList.count
    tSprNum = pSpriteList.getAt(i).spriteNum
    releaseSprite(tSprNum)
    i = 1 + i
  end repeat
  call(#deconstruct, pElemList)
  i = 1
  repeat while i <= pMemberList.count
    removeMember(pMemberList.getAt(i).name)
    i = 1 + i
  end repeat
  pElemList = [:]
  pSpriteList = [:]
  pMemberList = [:]
  pGroupData = []
  pClientID = ""
  pWindowMngr = void()
  return(1)
end

on define me, tProps 
  pLocX = tProps.getAt(#locX)
  pLocY = tProps.getAt(#locY)
  pLocZ = tProps.getAt(#locZ)
  pBoundary = tProps.getAt(#boundary)
  pElemClsList = tProps.getAt(#elements)
  pWindowMngr = tProps.getAt(#manager)
  return(1)
end

on close me 
  return(removeWindow(me.getID()))
end

on merge me, tLayout 
  me.setDeactive()
  if not me.buildVisual(tLayout) then
    return(0)
  end if
  pSpecialIDList.add("drag" & pGroupData.count)
  pSpecialIDList.add("close" & pGroupData.count)
  pWindowMngr.Activate(me.getID())
  return(1)
end

on unmerge me 
  if pGroupData.count = 0 then
    return(error(me, "Cant't unmerge window without content!", #unmerge, #minor))
  end if
  tGroupData = pGroupData.getLast()
  call(#deconstruct, tGroupData.getAt(#items))
  pClientRect = pClientRect - tGroupData.getAt(#border)
  repeat while tGroupData.getAt(#items) <= undefined
    tItem = getAt(undefined, undefined)
    pElemList.deleteProp(pElemList.getOne(tItem))
  end repeat
  repeat while tGroupData.getAt(#items) <= undefined
    tsprite = getAt(undefined, undefined)
    pSpriteList.deleteProp(pSpriteList.getOne(tsprite))
    releaseSprite(tsprite.spriteNum)
  end repeat
  repeat while tGroupData.getAt(#items) <= undefined
    tmember = getAt(undefined, undefined)
    pMemberList.deleteProp(pMemberList.getOne(tmember))
    removeMember(tmember.name)
  end repeat
  pSpecialIDList.deleteOne("drag" & pGroupData.count)
  pSpecialIDList.deleteOne("drag" & pGroupData.count)
  pGroupData.deleteAt(pGroupData.count)
  return(1)
end

on lock me, tBoolean 
  if voidp(tBoolean) then
    tBoolean = 1
  end if
  pLock = tBoolean
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
  pLocZ = tZ
end

on center me 
  tX = the stageRight - the stageLeft / 2 - pwidth / 2
  tY = the stageBottom - the stageTop / 2 - pheight / 2
  return(me.moveTo(tX, tY))
end

on resizeBy me, tOffX, tOffY 
  if tOffX <> 0 or tOffY <> 0 then
    pwidth = pwidth + tOffX
    pheight = pheight + tOffY
    call(#resizeBy, pElemList, tOffX, tOffY)
  end if
end

on resizeTo me, tX, tY 
  tOffW = tX - pwidth
  tOffH = tY - pheight
  me.resizeBy(tOffW, tOffH)
end

on setActive me 
  if not pActive then
    pActive = 1
    return(1)
  else
    return(0)
  end if
end

on setDeactive me 
  if pLock then
    return(0)
  else
    if pActive then
      pActive = 0
      return(1)
    else
      return(0)
    end if
  end if
end

on getClientRect me 
  return(rect(pLocX, pLocY, pLocX + pwidth, pLocY + pheight))
end

on getElement me, tID 
  tElement = pElemList.getAt(tID)
  if voidp(tElement) then
    return(0)
  end if
  return(tElement)
end

on elementExists me, tID 
  return(not voidp(pElemList.getAt(tID)))
end

on registerClient me, tClientID 
  if not objectExists(tClientID) then
    return(error(me, "Object not found:" && tClientID, #registerClient, #major))
  end if
  pClientID = tClientID
  return(1)
end

on removeClient me 
  pClientID = void()
  return(1)
end

on registerProcedure me, tMethod, tClientID, tEvent 
  if not symbolp(tMethod) then
    return(error(me, "Symbol expected:" && tMethod, #registerProcedure, #major))
  end if
  if not objectExists(tClientID) then
    return(error(me, "Object not found:" && tClientID, #registerProcedure, #major))
  end if
  if voidp(tEvent) then
    i = 1
    repeat while i <= pProcedures.count
      pProcedures.setAt(i, [tMethod, tClientID])
      i = 1 + i
    end repeat
    exit repeat
  end if
  pProcedures.setAt(tEvent, [tMethod, tClientID])
  return(1)
end

on removeProcedure me, tEvent 
  if voidp(tEvent) then
    pProcedures = me.createProcListTemplate()
  else
    if pProcedures.getaProp(tEvent) <> void() then
      pProcedures.setAt(tEvent, [#null, me.getID()])
    end if
  end if
  return(1)
end

on getProperty me, tProp 
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
              if tProp = #visible then
                return(pVisible)
              else
                if tProp = #title then
                  return(pTitle)
                else
                  if tProp = #id then
                    return(me.getID())
                  else
                    if tProp = #modal then
                      return(pModal)
                    else
                      if tProp = #spriteList then
                        return(pSpriteList)
                      else
                        if tProp = #elementList then
                          return(pElemList)
                        else
                          if tProp = #Active then
                            return(pActive)
                          else
                            if tProp = #lock then
                              return(pLock)
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
  if tProp = #locX then
    me.moveX(tValue)
  else
    if tProp = #locY then
      me.moveY(tValue)
    else
      if tProp = #locZ then
        me.moveZ(tValue)
      else
        if tProp = #boundary then
          pBoundary = tValue
        else
          if tProp = #title then
            pTitle = tValue
          else
            if tProp = #modal then
              pModal = tValue
            else
              if tProp = #visible then
                if tValue then
                  me.show()
                else
                  me.hide()
                end if
              else
                if tProp = #otherwise then
                  return(0)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on setBlend me, tNewBlend 
  repeat while pSpriteList <= undefined
    tsprite = getAt(undefined, tNewBlend)
    tsprite.blend = tNewBlend
  end repeat
  return(1)
end

on mouseEnter me, tNull, tSprID 
  return(me.redirectEvent(#mouseEnter, tSprID))
end

on mouseLeave me, tNull, tSprID 
  return(me.redirectEvent(#mouseLeave, tSprID))
end

on mouseWithin me, tNull, tSprID 
  return(me.redirectEvent(#mouseWithin, tSprID))
end

on mouseDown me, tNull, tSprID 
  if not pActive and not pLock then
    pWindowMngr.Activate(me.getID())
  end if
  if pSpecialIDList.getPos(tSprID) <> 0 then
    if tSprID contains "drag" then
      me.drag(1)
    else
      if tSprID contains "scale" then
        me.scale(1)
      end if
    end if
  end if
  return(me.redirectEvent(#mouseDown, tSprID))
end

on mouseUp me, tNull, tSprID 
  if pSpecialIDList.getPos(tSprID) <> 0 then
    if tSprID contains "drag" then
      me.drag(0)
    else
      if tSprID contains "scale" then
        me.scale(0)
      else
        if tSprID contains "close" then
          if voidp(pClientID) then
            return(pWindowMngr.Remove(me.getID()))
          else
            tSprID = "close"
          end if
        end if
      end if
    end if
  end if
  return(me.redirectEvent(#mouseUp, tSprID))
end

on mouseUpOutSide me, tNull, tSprID 
  if tSprID contains "drag" then
    me.drag(0)
  end if
  if tSprID contains "scale" then
    me.scale(0)
  end if
  return(me.redirectEvent(#mouseUpOutSide, tSprID))
end

on keyDown me, tNull, tSprID 
  return(me.redirectEvent(#keyDown, tSprID))
end

on keyUp me, tNull, tSprID 
  return(me.redirectEvent(#keyUp, tSprID))
end

on supportedEvents me 
  tList = []
  tList.add(#mouseEnter)
  tList.add(#mouseLeave)
  tList.add(#mouseWithin)
  tList.add(#mouseDown)
  tList.add(#mouseUp)
  tList.add(#mouseUpOutSide)
  tList.add(#keyDown)
  tList.add(#keyUp)
  return(tList)
end

on redirectEvent me, tEvent, tSprID 
  getWindowManager().registerWindowEvent(pTitle, tSprID, tEvent)
  tMethod = pProcedures.getAt(tEvent).getAt(1)
  tTarget = pProcedures.getAt(tEvent).getAt(2)
  tParam = call(tEvent, [pElemList.getAt(tSprID)], tSprID)
  if tParam = 0 and ilk(tParam) = #integer then
    return(0)
  end if
  tClient = getObject(tTarget)
  if tClient <> 0 then
    return(call(tMethod, tClient, tEvent, tSprID, tParam, me.getID()))
  else
    return(me.removeProcedure(tEvent))
  end if
end

on buildVisual me, tLayout 
  tLayout = getObject(#layout_parser).parse(tLayout)
  if not listp(tLayout) then
    return(error(me, "Invalid window definition:" && tLayout, #buildVisual, #major))
  end if
  tGroupNum = pGroupData.count
  tElemList = [:]
  tmemberlist = [:]
  tSpriteList = [:]
  tGroupData = [#members:[], #sprites:[], #items:[], #rect:[], #border:[]]
  tSprManager = getSpriteManager()
  tResManager = getResourceManager()
  repeat while tLayout.getAt(#elements) <= undefined
    tElement = getAt(undefined, tLayout)
    tID = tElement.getAt(1).getAt(#id)
    if not voidp(pElemList.getAt(tID)) then
      tID = tID & tGroupNum
    end if
    tmember = member(tResManager.createMember(me.getID() & "_" & tID, #bitmap))
    tsprite = sprite(tSprManager.reserveSprite(me.getID()))
    if tsprite.spriteNum < 1 then
      repeat while tLayout.getAt(#elements) <= undefined
        t_rSpr = getAt(undefined, tLayout)
        releaseSprite(t_rSpr.spriteNum, me.getID())
      end repeat
      tSpriteList = [:]
      repeat while tLayout.getAt(#elements) <= undefined
        t_rMem = getAt(undefined, tLayout)
        removeMember(t_rMem.name)
      end repeat
      tmemberlist = [:]
      return(error(me, "Failed to build window. System out of sprites!", #buildVisual, #major))
    end if
    tmemberlist.setAt(tID, tmember)
    tSpriteList.setAt(tID, tsprite)
    tsprite.castNum = tmember.number
    tsprite.ink = 8
    tElemRect = rect(2000, 2000, -2000, -2000)
    tGroupData.getAt(#members).add(tmember)
    tGroupData.getAt(#sprites).add(tsprite)
    tSprManager.setEventBroker(tsprite.spriteNum, tID)
    tsprite.registerProcedure(void(), me.getID(), void())
    tBlend = tElement.getAt(1).getAt(#blend)
    tInk = tElement.getAt(1).getAt(#ink)
    tColor = tElement.getAt(1).getAt(#color)
    tBgColor = tElement.getAt(1).getAt(#bgColor)
    tPalette = tElement.getAt(1).getAt(#palette)
    tIsBlendShared = 1
    tIsColorShared = 1
    tIsBgColorShared = 1
    tIsInkShared = 1
    tIsPaletteShared = 1
    repeat while tLayout.getAt(#elements) <= undefined
      tItem = getAt(undefined, tLayout)
      tItem.setAt(#id, tID)
      tItem.setAt(#mother, me.getID())
      tItem.setAt(#buffer, tmember)
      tItem.setAt(#sprite, tsprite)
      if tItem.getAt(#blend) <> tBlend then
        tIsBlendShared = 0
      end if
      if tItem.getAt(#ink) <> tInk then
        tIsInkShared = 0
      end if
      if tItem.getAt(#color) <> tColor then
        tIsColorShared = 0
      end if
      if tItem.getAt(#bgColor) <> tBgColor then
        tIsBgColorShared = 0
      end if
      if tItem.getAt(#palette) <> tPalette then
        tIsPaletteShared = 0
      end if
      if tItem.getAt(#type) = "image" then
        tIsPaletteShared = 0
      end if
      if tItem.getAt(#flipH) then
        tItem.locH = tItem.locH - tItem.width
      end if
      if tItem.getAt(#flipV) then
        tItem.locV = tItem.locV - tItem.height
      end if
      if tItem.getAt(#locH) < tElemRect.getAt(1) then
        tElemRect.setAt(1, tItem.getAt(#locH))
      end if
      if tItem.getAt(#locV) < tElemRect.getAt(2) then
        tElemRect.setAt(2, tItem.getAt(#locV))
      end if
      if tItem.getAt(#locH) + tItem.getAt(#width) > tElemRect.getAt(3) then
        tElemRect.setAt(3, tItem.getAt(#locH) + tItem.getAt(#width))
      end if
      if tItem.getAt(#locV) + tItem.getAt(#height) > tElemRect.getAt(4) then
        tElemRect.setAt(4, tItem.getAt(#locV) + tItem.getAt(#height))
      end if
      if not voidp(tItem.getAt(#cursor)) then
        tsprite.setcursor(tItem.getAt(#cursor))
      else
        tsprite.setcursor(#arrow)
      end if
    end repeat
    if tIsPaletteShared and not voidp(tPalette) then
      if stringp(tPalette) then
        tPalette = member(tResManager.getmemnum(tPalette))
      end if
      tmember.image = image(tElemRect.width, tElemRect.height, 8, tPalette)
    else
      tmember.image = image(tElemRect.width, tElemRect.height, the colorDepth)
    end if
    tmember.regPoint = point(0, 0)
    if tElement.count = 1 then
      tItem = tElement.getAt(1)
      tItem.setAt(#style, #unique)
      if tIsBlendShared then
        tItem.setAt(#blend, 100)
      end if
      tWrapper = me.CreateElement(tItem)
    else
      tProps = [#id:tID, #type:#wrapper, #style:#wrapper, #buffer:tmember, #sprite:tsprite, #locX:tElemRect.getAt(1), #locY:tElemRect.getAt(2)]
      tWrapper = me.CreateElement(tProps)
      repeat while tLayout.getAt(#elements) <= undefined
        tItem = getAt(undefined, tLayout)
        tItem.setAt(#locH, tItem.getAt(#locH) - tElemRect.getAt(1))
        tItem.setAt(#locV, tItem.getAt(#locV) - tElemRect.getAt(2))
        tItem.setAt(#style, #grouped)
        if tIsBlendShared then
          tItem.setAt(#blend, 100)
        end if
        tWrapper.add(me.CreateElement(tItem))
      end repeat
    end if
    if objectp(tWrapper) then
      tElemList.addProp(tID, tWrapper)
      tGroupData.getAt(#items).add(tWrapper)
    end if
    if tIsBlendShared then
      tsprite.blend = tBlend
    end if
    if tIsInkShared then
      tsprite.ink = tInk
    end if
    if tIsColorShared then
      tsprite.color = tColor
    end if
    if tIsBgColorShared then
      tsprite.bgColor = tBgColor
    end if
    tsprite.locH = tElemRect.getAt(1) + pClientRect.getAt(1)
    tsprite.locV = tElemRect.getAt(2) + pClientRect.getAt(2)
    tsprite.width = tElemRect.width
    tsprite.height = tElemRect.height
  end repeat
  tGroupData.setAt(#rect, tLayout.getAt(#rect).getAt(1))
  tGroupData.setAt(#border, tLayout.getAt(#border).getAt(1))
  if tGroupNum = 0 then
    pLocX = pLocX + tGroupData.getAt(#rect).getAt(1)
    pLocY = pLocY + tGroupData.getAt(#rect).getAt(2)
    pwidth = tGroupData.getAt(#rect).width
    pheight = tGroupData.getAt(#rect).height
  else
    tNewW = pClientRect.getAt(1) + pClientRect.getAt(3) + tGroupData.getAt(#rect).width
    tNewH = pClientRect.getAt(2) + pClientRect.getAt(4) + tGroupData.getAt(#rect).height
    if tNewW <> pwidth or tNewH <> pheight then
      me.resizeTo(tNewW, tNewH)
    end if
  end if
  pClientRect = pClientRect + tGroupData.getAt(#border)
  i = 1
  repeat while i <= tSpriteList.count
    tloc = tSpriteList.getAt(i).loc - [tGroupData.getAt(#rect).getAt(1), tGroupData.getAt(#rect).getAt(2)]
    tSpriteList.getAt(i).loc = point(pLocX, pLocY) + tloc
    tID = tmemberlist.getPropAt(i)
    pMemberList.addProp(tID, tmemberlist.getAt(tID))
    pSpriteList.addProp(tID, tSpriteList.getAt(tID))
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tElemList.count
    pElemList.addProp(tElemList.getPropAt(i), tElemList.getAt(i))
    i = 1 + i
  end repeat
  pGroupData.add(tGroupData)
  call(#prepare, tGroupData.getAt(#items))
  call(#render, tGroupData.getAt(#items))
  return(1)
end

on prepare me 
  tOffX = the mouseH - pScaleOffset.getAt(1)
  tOffY = the mouseV - pScaleOffset.getAt(2)
  pScaleOffset = the mouseLoc
  if pwidth + tOffX < 64 then
    tOffX = 64 - pwidth
  end if
  if pheight + tOffY < 64 then
    tOffY = 64 - pheight
  end if
  me.resizeBy(tOffX, tOffY)
end

on update me 
  me.moveTo(the mouseH - pDragOffset.getAt(1), the mouseV - pDragOffset.getAt(2))
end

on CreateElement me, tProps 
  tTemplate = pElemClsList.getAt(tProps.getAt(#style))
  ttype = tProps.getAt(#type)
  tmodel = tProps.getAt(#model)
  tClass = "window." & ttype & tmodel & ".class"
  if not voidp(pElemClsList.getAt(tClass)) then
    tClsStruct = pElemClsList.getAt(tClass)
  else
    if variableExists(tClass) then
      tClsStruct = getClassVariable(tClass)
      pElemClsList.setAt(tClass, tClsStruct)
    else
      tClsStruct = void()
    end if
  end if
  if voidp(tClsStruct) then
    tElement = createObject(#temp, tTemplate)
  else
    tElement = createObject(#temp, tTemplate, tClsStruct)
  end if
  if not tElement then
    return(error(me, "Illegal element type:" && tProps.getAt(#id) && tClass, #CreateElement, #major))
  end if
  tElement.setID(tProps.getAt(#id))
  tElement.define(tProps)
  return(tElement)
end

on createProcListTemplate me 
  tList = [:]
  repeat while me.supportedEvents() <= undefined
    tEvent = getAt(undefined, undefined)
    tList.setAt(tEvent, [#null, me.getID()])
  end repeat
  return(tList)
end

on scale me, tBoolean 
  if tBoolean = 1 and pScaleFlag = 0 then
    pScaleOffset = the mouseLoc
    receivePrepare(me.getID())
    pScaleFlag = 1
  else
    if tBoolean = 0 and pScaleFlag = 1 then
      removePrepare(me.getID())
      pScaleFlag = 0
    end if
  end if
  return(1)
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

on draw me, tRGB 
  call(#draw, pElemList, tRGB)
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

on null me 
  return(0)
end

on movePartBy me, ttype, tX, tY, tInverse 
  tsprite = pSpriteList.getAt(ttype)
  if voidp(tsprite) then
    return(0)
  end if
  if tInverse then
    i = 1
    repeat while i <= pSpriteList.count
      tSymbol = pSpriteList.getPropAt(i)
      if tSymbol <> ttype then
        tsprite = pSpriteList.getAt(tSymbol)
        tsprite.loc = tsprite.loc + [tX, tY]
      end if
      i = 1 + i
    end repeat
    exit repeat
  end if
  tsprite.loc = tsprite.loc + [tX, tY]
end

on movePartTo me, ttype, tX, tY, tInverse 
  tX = tX - pLocX
  tY = tY - pLocY
  me.movePartBy(ttype, tX, tY, tInverse)
end
