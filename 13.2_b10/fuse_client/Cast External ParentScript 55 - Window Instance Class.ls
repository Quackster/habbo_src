property pTitle, pClientID, pProcedures, pLock, pLocX, pLocY, pLocZ, pwidth, pheight, pModal, pActive, pVisible, pDragFlag, pDragOffset, pBoundary, pScaleFlag, pScaleOffset, pElemList, pMemberList, pGroupData, pSpriteList, pSpecialIDList, pClientRect, pElemClsList, pWindowMngr

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
  pBoundary = rect(0, 0, (the stage).rect.width, (the stage).rect.height) + [-20, -20, 20, 20]
  pClientID = VOID
  pMemberList = [:]
  pElemList = [:]
  pGroupData = []
  pClientRect = [0, 0, 0, 0]
  pSpecialIDList = ["drag", "close", "scale"]
  pProcedures = me.createProcListTemplate()
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  removePrepare(me.getID())
  repeat with i = 1 to pSpriteList.count
    tSprNum = pSpriteList[i].spriteNum
    releaseSprite(tSprNum)
  end repeat
  call(#deconstruct, pElemList)
  repeat with i = 1 to pMemberList.count
    removeMember(pMemberList[i].name)
  end repeat
  pElemList = [:]
  pSpriteList = [:]
  pMemberList = [:]
  pGroupData = []
  pClientID = EMPTY
  pWindowMngr = VOID
  return 1
end

on define me, tProps
  pLocX = tProps[#locX]
  pLocY = tProps[#locY]
  pLocZ = tProps[#locZ]
  pBoundary = tProps[#boundary]
  pElemClsList = tProps[#elements]
  pWindowMngr = tProps[#manager]
  return 1
end

on close me
  return removeWindow(me.getID())
end

on merge me, tLayout
  me.setDeactive()
  if not me.buildVisual(tLayout) then
    return 0
  end if
  pSpecialIDList.add("drag" & pGroupData.count)
  pSpecialIDList.add("close" & pGroupData.count)
  pWindowMngr.Activate(me.getID())
  return 1
end

on unmerge me
  if pGroupData.count = 0 then
    return error(me, "Cant't unmerge window without content!", #unmerge)
  end if
  tGroupData = pGroupData.getLast()
  call(#deconstruct, tGroupData[#items])
  pClientRect = pClientRect - tGroupData[#border]
  repeat with tItem in tGroupData[#items]
    pElemList.deleteProp(pElemList.getOne(tItem))
  end repeat
  repeat with tsprite in tGroupData[#sprites]
    pSpriteList.deleteProp(pSpriteList.getOne(tsprite))
    releaseSprite(tsprite.spriteNum)
  end repeat
  repeat with tmember in tGroupData[#members]
    pMemberList.deleteProp(pMemberList.getOne(tmember))
    removeMember(tmember.name)
  end repeat
  pSpecialIDList.deleteOne("drag" & pGroupData.count)
  pSpecialIDList.deleteOne("drag" & pGroupData.count)
  pGroupData.deleteAt(pGroupData.count)
  return 1
end

on lock me, tBoolean
  if voidp(tBoolean) then
    tBoolean = 1
  end if
  pLock = tBoolean
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
  pLocZ = tZ
end

on center me
  tX = ((the stageRight - the stageLeft) / 2) - (pwidth / 2)
  tY = ((the stageBottom - the stageTop) / 2) - (pheight / 2)
  return me.moveTo(tX, tY)
end

on resizeBy me, tOffX, tOffY
  if (tOffX <> 0) or (tOffY <> 0) then
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
    return 1
  else
    return 0
  end if
end

on setDeactive me
  if pLock then
    return 0
  else
    if pActive then
      pActive = 0
      return 1
    else
      return 0
    end if
  end if
end

on getClientRect me
  return rect(pLocX, pLocY, pLocX + pwidth, pLocY + pheight)
end

on getElement me, tid
  tElement = pElemList[tid]
  if voidp(tElement) then
    return 0
  end if
  return tElement
end

on elementExists me, tid
  return not voidp(pElemList[tid])
end

on registerClient me, tClientID
  if not objectExists(tClientID) then
    return error(me, "Object not found:" && tClientID, #registerClient)
  end if
  pClientID = tClientID
  return 1
end

on removeClient me
  pClientID = VOID
  return 1
end

on registerProcedure me, tMethod, tClientID, tEvent
  if not symbolp(tMethod) then
    return error(me, "Symbol expected:" && tMethod, #registerProcedure)
  end if
  if not objectExists(tClientID) then
    return error(me, "Object not found:" && tClientID, #registerProcedure)
  end if
  if voidp(tEvent) then
    repeat with i = 1 to pProcedures.count
      pProcedures[i] = [tMethod, tClientID]
    end repeat
  else
    pProcedures[tEvent] = [tMethod, tClientID]
  end if
  return 1
end

on removeProcedure me, tEvent
  if voidp(tEvent) then
    pProcedures = me.createProcListTemplate()
  else
    if pProcedures.getaProp(tEvent) <> VOID then
      pProcedures[tEvent] = [#null, me.getID()]
    end if
  end if
  return 1
end

on getProperty me, tProp
  case tProp of
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
    #visible:
      return pVisible
    #title:
      return pTitle
    #id:
      return me.getID()
    #modal:
      return pModal
    #spriteList:
      return pSpriteList
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #locX:
      me.moveX(tValue)
    #locY:
      me.moveY(tValue)
    #locZ:
      me.moveZ(tValue)
    #boundary:
      pBoundary = tValue
    #title:
      pTitle = tValue
    #modal:
      pModal = tValue
    #visible:
      if tValue then
        me.show()
      else
        me.hide()
      end if
    #otherwise:
      return 0
  end case
  return 1
end

on mouseEnter me, tNull, tSprID
  return me.redirectEvent(#mouseEnter, tSprID)
end

on mouseLeave me, tNull, tSprID
  return me.redirectEvent(#mouseLeave, tSprID)
end

on mouseWithin me, tNull, tSprID
  return me.redirectEvent(#mouseWithin, tSprID)
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
  return me.redirectEvent(#mouseDown, tSprID)
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
            return pWindowMngr.Remove(me.getID())
          else
            tSprID = "close"
          end if
        end if
      end if
    end if
  end if
  return me.redirectEvent(#mouseUp, tSprID)
end

on mouseUpOutSide me, tNull, tSprID
  if tSprID contains "drag" then
    me.drag(0)
  end if
  if tSprID contains "scale" then
    me.scale(0)
  end if
  return me.redirectEvent(#mouseUpOutSide, tSprID)
end

on keyDown me, tNull, tSprID
  return me.redirectEvent(#keyDown, tSprID)
end

on keyUp me, tNull, tSprID
  return me.redirectEvent(#keyUp, tSprID)
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
  return tList
end

on redirectEvent me, tEvent, tSprID
  tMethod = pProcedures[tEvent][1]
  tTarget = pProcedures[tEvent][2]
  tParam = call(tEvent, [pElemList[tSprID]], tSprID)
  if tParam = 0 then
    return 0
  end if
  tClient = getObject(tTarget)
  if tClient <> 0 then
    return call(tMethod, tClient, tEvent, tSprID, tParam, me.getID())
  else
    return me.removeProcedure(tEvent)
  end if
end

on buildVisual me, tLayout
  tLayout = getObject(#layout_parser).parse(tLayout)
  if not listp(tLayout) then
    return error(me, "Invalid window definition:" && tLayout, #buildVisual)
  end if
  tGroupNum = pGroupData.count
  tElemList = [:]
  tmemberlist = [:]
  tSpriteList = [:]
  tGroupData = [#members: [], #sprites: [], #items: [], #rect: [], #border: []]
  tSprManager = getSpriteManager()
  tResManager = getResourceManager()
  repeat with tElement in tLayout[#elements]
    tid = tElement[1][#id]
    if not voidp(pElemList[tid]) then
      tid = tid & tGroupNum
    end if
    tmember = member(tResManager.createMember(me.getID() & "_" & tid, #bitmap))
    tsprite = sprite(tSprManager.reserveSprite(me.getID()))
    if tsprite.spriteNum < 1 then
      repeat with t_rSpr in tSpriteList
        releaseSprite(t_rSpr.spriteNum, me.getID())
      end repeat
      tSpriteList = [:]
      repeat with t_rMem in tmemberlist
        removeMember(t_rMem.name)
      end repeat
      tmemberlist = [:]
      return error(me, "Failed to build window. System out of sprites!", #buildVisual)
    end if
    tmemberlist[tid] = tmember
    tSpriteList[tid] = tsprite
    tsprite.castNum = tmember.number
    tsprite.ink = 8
    tElemRect = rect(2000, 2000, -2000, -2000)
    tGroupData[#members].add(tmember)
    tGroupData[#sprites].add(tsprite)
    tSprManager.setEventBroker(tsprite.spriteNum, tid)
    tsprite.registerProcedure(VOID, me.getID(), VOID)
    tBlend = tElement[1][#blend]
    tInk = tElement[1][#ink]
    tColor = tElement[1][#color]
    tBgColor = tElement[1][#bgColor]
    tPalette = tElement[1][#palette]
    tIsBlendShared = 1
    tIsColorShared = 1
    tIsBgColorShared = 1
    tIsInkShared = 1
    tIsPaletteShared = 1
    repeat with tItem in tElement
      tItem[#id] = tid
      tItem[#mother] = me.getID()
      tItem[#buffer] = tmember
      tItem[#sprite] = tsprite
      if tItem[#blend] <> tBlend then
        tIsBlendShared = 0
      end if
      if tItem[#ink] <> tInk then
        tIsInkShared = 0
      end if
      if tItem[#color] <> tColor then
        tIsColorShared = 0
      end if
      if tItem[#bgColor] <> tBgColor then
        tIsBgColorShared = 0
      end if
      if tItem[#palette] <> tPalette then
        tIsPaletteShared = 0
      end if
      if tItem[#type] = "image" then
        tIsPaletteShared = 0
      end if
      if tItem[#flipH] then
        tItem.locH = tItem.locH - tItem.width
      end if
      if tItem[#flipV] then
        tItem.locV = tItem.locV - tItem.height
      end if
      if tItem[#locH] < tElemRect[1] then
        tElemRect[1] = tItem[#locH]
      end if
      if tItem[#locV] < tElemRect[2] then
        tElemRect[2] = tItem[#locV]
      end if
      if (tItem[#locH] + tItem[#width]) > tElemRect[3] then
        tElemRect[3] = tItem[#locH] + tItem[#width]
      end if
      if (tItem[#locV] + tItem[#height]) > tElemRect[4] then
        tElemRect[4] = tItem[#locV] + tItem[#height]
      end if
      if not voidp(tItem[#cursor]) then
        tsprite.setcursor(tItem[#cursor])
        next repeat
      end if
      tsprite.setcursor(#arrow)
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
      tItem = tElement[1]
      tItem[#style] = #unique
      if tIsBlendShared then
        tItem[#blend] = 100
      end if
      tWrapper = me.CreateElement(tItem)
    else
      tProps = [#id: tid, #type: #wrapper, #style: #wrapper, #buffer: tmember, #sprite: tsprite, #locX: tElemRect[1], #locY: tElemRect[2]]
      tWrapper = me.CreateElement(tProps)
      repeat with tItem in tElement
        tItem[#locH] = tItem[#locH] - tElemRect[1]
        tItem[#locV] = tItem[#locV] - tElemRect[2]
        tItem[#style] = #grouped
        if tIsBlendShared then
          tItem[#blend] = 100
        end if
        tWrapper.add(me.CreateElement(tItem))
      end repeat
    end if
    if objectp(tWrapper) then
      tElemList.addProp(tid, tWrapper)
      tGroupData[#items].add(tWrapper)
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
    tsprite.locH = tElemRect[1] + pClientRect[1]
    tsprite.locV = tElemRect[2] + pClientRect[2]
    tsprite.width = tElemRect.width
    tsprite.height = tElemRect.height
  end repeat
  tGroupData[#rect] = tLayout[#rect][1]
  tGroupData[#border] = tLayout[#border][1]
  if tGroupNum = 0 then
    pLocX = pLocX + tGroupData[#rect][1]
    pLocY = pLocY + tGroupData[#rect][2]
    pwidth = tGroupData[#rect].width
    pheight = tGroupData[#rect].height
  else
    tNewW = pClientRect[1] + pClientRect[3] + tGroupData[#rect].width
    tNewH = pClientRect[2] + pClientRect[4] + tGroupData[#rect].height
    if (tNewW <> pwidth) or (tNewH <> pheight) then
      me.resizeTo(tNewW, tNewH)
    end if
  end if
  pClientRect = pClientRect + tGroupData[#border]
  repeat with i = 1 to tSpriteList.count
    tloc = tSpriteList[i].loc - [tGroupData[#rect][1], tGroupData[#rect][2]]
    tSpriteList[i].loc = point(pLocX, pLocY) + tloc
    tid = tmemberlist.getPropAt(i)
    pMemberList.addProp(tid, tmemberlist[tid])
    pSpriteList.addProp(tid, tSpriteList[tid])
  end repeat
  repeat with i = 1 to tElemList.count
    pElemList.addProp(tElemList.getPropAt(i), tElemList[i])
  end repeat
  pGroupData.add(tGroupData)
  call(#prepare, tGroupData[#items])
  call(#render, tGroupData[#items])
  return 1
end

on prepare me
  tOffX = the mouseH - pScaleOffset[1]
  tOffY = the mouseV - pScaleOffset[2]
  pScaleOffset = the mouseLoc
  if (pwidth + tOffX) < 64 then
    tOffX = 64 - pwidth
  end if
  if (pheight + tOffY) < 64 then
    tOffY = 64 - pheight
  end if
  me.resizeBy(tOffX, tOffY)
end

on update me
  me.moveTo(the mouseH - pDragOffset[1], the mouseV - pDragOffset[2])
end

on CreateElement me, tProps
  tTemplate = pElemClsList[tProps[#style]]
  ttype = tProps[#type]
  tmodel = tProps[#model]
  tClass = "window." & ttype & tmodel & ".class"
  if not voidp(pElemClsList[tClass]) then
    tClsStruct = pElemClsList[tClass]
  else
    if variableExists(tClass) then
      tClsStruct = getClassVariable(tClass)
      pElemClsList[tClass] = tClsStruct
    else
      tClsStruct = VOID
    end if
  end if
  if voidp(tClsStruct) then
    tElement = createObject(#temp, tTemplate)
  else
    tElement = createObject(#temp, tTemplate, tClsStruct)
  end if
  if not tElement then
    return error(me, "Illegal element type:" && tProps[#id] && tClass, #CreateElement)
  end if
  tElement.setID(tProps[#id])
  tElement.define(tProps)
  return tElement
end

on createProcListTemplate me
  tList = [:]
  repeat with tEvent in me.supportedEvents()
    tList[tEvent] = [#null, me.getID()]
  end repeat
  return tList
end

on scale me, tBoolean
  if (tBoolean = 1) and (pScaleFlag = 0) then
    pScaleOffset = the mouseLoc
    receivePrepare(me.getID())
    pScaleFlag = 1
  else
    if (tBoolean = 0) and (pScaleFlag = 1) then
      removePrepare(me.getID())
      pScaleFlag = 0
    end if
  end if
  return 1
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

on draw me, tRGB
  call(#draw, pElemList, tRGB)
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

on null me
  return 0
end

on movePartBy me, ttype, tX, tY, tInverse
  tsprite = pSpriteList[ttype]
  if voidp(tsprite) then
    return 0
  end if
  if tInverse then
    repeat with i = 1 to pSpriteList.count
      tSymbol = pSpriteList.getPropAt(i)
      if tSymbol <> ttype then
        tsprite = pSpriteList[tSymbol]
        tsprite.loc = tsprite.loc + [tX, tY]
      end if
    end repeat
  else
    tsprite.loc = tsprite.loc + [tX, tY]
  end if
end

on movePartTo me, ttype, tX, tY, tInverse
  tX = tX - pLocX
  tY = tY - pLocY
  me.movePartBy(ttype, tX, tY, tInverse)
end
