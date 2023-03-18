property pName, pClass, pCustom, pSex, pModState, pCtrlType, pBadge, pID, pWebID, pBuffer, pSprite, pMatteSpr, pMember, pShadowSpr, pShadowFix, pDefShadowMem, pPartList, pPartIndex, pFlipList, pUpdateRect, pDirection, pLastDir, pHeadDir, pLocX, pLocY, pLocH, pLocFix, pXFactor, pYFactor, pHFactor, pScreenLoc, pStartLScreen, pDestLScreen, pRestingHeight, pAnimCounter, pMoveStart, pMoveTime, pEyesClosed, pSync, pChanges, pAlphaColor, pCanvasSize, pColors, pPeopleSize, pMainAction, pMoving, pTalking, pCarrying, pSleeping, pDancing, pWaving, pTrading, pAnimating, pSwim, pCurrentAnim, pGeometry, pExtraObjs, pInfoStruct, pCorrectLocZ, pPartClass, pQueuesWithObj, pPreviousLoc, pBaseLocZ, pGroupId, pStatusInGroup, pPartListSubSet, pPartOrderOld

on construct me
  pID = 0
  pWebID = VOID
  pName = EMPTY
  pPartList = []
  pPartIndex = [:]
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pLocFix = point(0, 0)
  pUpdateRect = rect(0, 0, 0, 0)
  pScreenLoc = [0, 0, 0]
  pStartLScreen = [0, 0, 0]
  pDestLScreen = [0, 0, 0]
  pPreviousLoc = [0, 0, 0]
  pRestingHeight = 0.0
  pAnimCounter = 0
  pMoveStart = 0
  pMoveTime = 500
  pEyesClosed = 0
  pSync = 1
  pChanges = 1
  pMainAction = "std"
  pMoving = 0
  pTalking = 0
  pCarrying = 0
  pSleeping = 0
  pDancing = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pAnimating = 0
  pSwim = 0
  pBadge = SPACE
  pCurrentAnim = EMPTY
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pColors = [:]
  pModState = 0
  pExtraObjs = [:]
  pDefShadowMem = member(0)
  pInfoStruct = [:]
  pQueuesWithObj = 0
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  pHFactor = pGeometry.pHFactor
  pCorrectLocZ = 0
  pPartClass = value(getThread(#room).getComponent().getClassContainer().GET("bodypart"))
  pGroupId = VOID
  pStatusInGroup = VOID
  pBaseLocZ = 0
  pPeopleSize = getVariable("human.size.64")
  pPartOrderOld = EMPTY
  tSubSetList = ["head", "speak", "gesture", "eye", "handRight", "handLeft", "walk", "sit", "itemRight"]
  pPartListSubSet = [:]
  repeat with tSubSet in tSubSetList
    tSetName = "human.partset." & tSubSet & "." & pPeopleSize
    if not variableExists(tSetName) then
      pPartListSubSet[tSubSet] = []
      error(me, tSetName && "not found!", #construct, #major)
      next repeat
    end if
    pPartListSubSet[tSubSet] = getVariableValue(tSetName)
  end repeat
  return 1
end

on deconstruct me
  pGeometry = VOID
  pPartList = []
  pInfoStruct = [:]
  if not voidp(pSprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  if not voidp(pMatteSpr) then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if not voidp(pShadowSpr) then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if memberExists(me.getCanvasName()) then
    removeMember(me.getCanvasName())
  end if
  call(#deconstruct, pExtraObjs)
  pExtraObjs = VOID
  pShadowSpr = VOID
  pMatteSpr = VOID
  pSprite = VOID
  return 1
end

on define me, tdata
  me.setup(tdata)
  if not memberExists(me.getCanvasName()) then
    createMember(me.getCanvasName(), #bitmap)
  end if
  tSize = pCanvasSize[#std]
  pMember = member(getmemnum(me.getCanvasName()))
  pMember.image = image(tSize[1], tSize[2], tSize[3])
  pMember.regPoint = point(0, pMember.image.height + tSize[4])
  pBuffer = pMember.image.duplicate()
  pSprite = sprite(reserveSprite(me.getID()))
  pSprite.castNum = pMember.number
  pSprite.width = pMember.width
  pSprite.height = pMember.height
  pSprite.ink = 36
  pMatteSpr = sprite(reserveSprite(me.getID()))
  pMatteSpr.castNum = pMember.number
  pMatteSpr.ink = 8
  pMatteSpr.blend = 0
  pShadowSpr = sprite(reserveSprite(me.getID()))
  pShadowSpr.blend = 16
  pShadowSpr.ink = 8
  pShadowFix = 0
  pDefShadowMem = member(getmemnum(pPeopleSize & "_std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  setEventBroker(pShadowSpr.spriteNum, me.getID())
  pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pInfoStruct[#name] = pName
  pInfoStruct[#class] = pClass
  pInfoStruct[#custom] = pCustom
  pInfoStruct[#image] = me.getPicture()
  pInfoStruct[#ctrl] = "furniture"
  pInfoStruct[#badge] = " "
  tThread = getThread(#room)
  if tThread <> 0 then
    tInterface = tThread.getInterface()
    if tInterface <> 0 then
      tViz = tThread.getInterface().getRoomVisualizer()
      if tViz <> 0 then
        tPart = tViz.getPartAtLocation(tdata[#x], tdata[#y], [#wallleft, #wallright])
        if not (tPart = 0) then
          pBaseLocZ = tPart[#locZ] - 1000
        end if
      end if
    end if
  end if
  return 1
end

on changeFigureAndData me, tdata
  pSex = tdata[#sex]
  pCustom = tdata[#custom]
  tmodels = tdata[#figure]
  tPartDefinition = me.getClearedFigurePartList(tmodels)
  repeat with tPart in pPartList
    tPartId = tPart.getPartID()
    tNewModelItem = tmodels[tPartId]
    if ilk(tNewModelItem) = #propList then
      tmodel = tNewModelItem["model"]
      tColor = tNewModelItem["color"]
      if (tColor.red + tColor.green + tColor.blue) > (238 * 3) then
        tColor = rgb("EEEEEE")
      end if
      if tPartDefinition.findPos(tPartId) = 0 then
        tmodel = "000"
      end if
      if voidp(tmodel) then
        tmodel = "000"
      end if
      tPart.changePartData(tmodel, tColor)
      pColors[tPartId] = tColor
    end if
  end repeat
  pChanges = 1
  me.render()
  if me.isInSwimsuit() then
    me.setPartLists(tdata[#figure], #preserveAnimation)
  else
    me.reDraw()
  end if
  pInfoStruct[#image] = me.getPicture()
end

on setup me, tdata
  pName = tdata[#name]
  pClass = tdata[#class]
  pCustom = tdata[#custom]
  pSex = tdata[#sex]
  pDirection = tdata[#direction][1]
  pHeadDir = pDirection
  pLastDir = pDirection
  pLocX = tdata[#x]
  pLocY = tdata[#y]
  pLocH = tdata[#h]
  pBadge = tdata[#badge]
  pGroupId = tdata[#groupid]
  pStatusInGroup = tdata[#groupstatus]
  if not voidp(tdata.getaProp(#webID)) then
    pWebID = tdata[#webID]
  end if
  pPeopleSize = getVariable("human.size." & integer(pXFactor))
  if not pPeopleSize then
    error(me, "People size not found, using default!", #setup, #minor)
    pPeopleSize = "h"
  end if
  pCorrectLocZ = pPeopleSize = "h"
  pCanvasSize = value(getVariable("human.canvas." & pPeopleSize))
  if not pCanvasSize then
    error(me, "Canvas size not found, using default!", #setup, #minor)
    pCanvasSize = [#std: [64, 102, 32, -10], #lay: [89, 102, 32, -8]]
  end if
  if not me.setPartLists(tdata[#figure]) then
    return error(me, "Couldn't create part lists!", #setup, #major)
  end if
  me.resetValues(pLocX, pLocY, pLocH, pHeadDir, pDirection)
  me.Refresh(pLocX, pLocY, pLocH, pDirection)
  pSync = 0
end

on update me
  if pQueuesWithObj then
    me.prepare()
    me.render()
  else
    pSync = not pSync
    if pSync then
      me.prepare()
    else
      me.render()
    end if
  end if
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return 1
  end if
  pMoving = 0
  pDancing = 0
  pTalking = 0
  pCarrying = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pAnimating = 0
  pModState = 0
  pSleeping = 0
  pQueuesWithObj = 0
  pLocFix = point(-1, 2)
  call(#reset, pPartList)
  pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0.0
  pDirection = tDirBody
  pHeadDir = tDirHead
  if pExtraObjs.count > 0 then
    call(#Refresh, pExtraObjs)
  end if
end

on Refresh me, tX, tY, tH
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return 1
  end if
  if (pDancing > 0) or (pMainAction = "lay") then
    pHeadDir = pDirection
  end if
  call(#defineDir, pPartList, pDirection)
  call(#defineDirMultiple, pPartList, pHeadDir, pPartListSubSet["head"])
  me.arrangeParts()
  pChanges = 1
end

on select me
  return 1
end

on getName me
  return pName
end

on getClass me
  return "user"
end

on setPartModel me, tPart, tmodel
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  pPartList[pPartIndex[tPart]].setModel(tmodel)
end

on setPartColor me, tPart, tColor
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  pPartList[pPartIndex[tPart]].setColor(tColor)
end

on getCustom me
  return pCustom
end

on getLocation me
  return [pLocX, pLocY, pLocH]
end

on getScrLocation me
  return pScreenLoc
end

on getTileCenter me
  return point(pScreenLoc[1] + (pXFactor / 2), pScreenLoc[2])
end

on getPartLocation me, tPart
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  tPartLoc = pPartList[pPartIndex[tPart]].getLocation()
  if pMainAction <> "lay" then
    tloc = pSprite.loc + tPartLoc
  else
    tloc = point(pSprite.rect[1] + (pSprite.width / 2), pSprite.rect[2] + (pSprite.height / 2))
  end if
  return tloc
end

on getDirection me
  return pDirection
end

on getPartMember me, tPart
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  return pPartList[pPartIndex[tPart]].getCurrentMember()
end

on getPartColor me, tPart
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  return pPartList[pPartIndex[tPart]].getColor()
end

on getPicture me, tImg
  return me.getPartialPicture(#Full, tImg, 4, "h")
end

on getPartialPicture me, tPartList, tImg, tDirection, tPeopleSize
  if tPartList.ilk <> #list then
    tPartName = EMPTY
    if tPartList = #head then
      tPartList = pPartListSubSet["head"]
    else
      if tPartList = #Full then
        tPartName = "human.parts." & pPeopleSize
      else
        if tPartList = #swimmer then
          tPartName = "swimmer.parts." & pPeopleSize
        end if
      end if
      if variableExists(tPartName) then
        tPartList = value(getVariable(tPartName))
      end if
    end if
    if tPartList.ilk <> #list then
      return tImg
    end if
  end if
  if voidp(tImg) then
    tCanvas = image(64, 102, 32)
  else
    tCanvas = tImg
  end if
  if voidp(tDirection) then
    tDirection = pDirection
  end if
  if voidp(tPeopleSize) then
    tPeopleSize = pPeopleSize
  end if
  tDirData = "." & tDirection
  tTempPartList = []
  tPartOrder = "human.parts." & pPeopleSize & tDirData
  if not variableExists(tPartOrder) then
    error(me, "No human part order found" && tPartOrder, #getPartialPicture, #major)
    repeat with i = 1 to pPartIndex.count
      tPartSymbol = pPartIndex.getPropAt(i)
      if tPartList.findPos(tPartSymbol) > 0 then
        tTempPartList.append(pPartList[pPartIndex[tPartSymbol]])
      end if
    end repeat
  else
    tPartDefinition = getVariableValue(tPartOrder)
    repeat with tPartSymbol in tPartDefinition
      if not voidp(pPartIndex[tPartSymbol]) then
        if tPartList.findPos(tPartSymbol) > 0 then
          tTempPartList.append(pPartList[pPartIndex[tPartSymbol]])
        end if
      end if
    end repeat
  end if
  call(#copyPicture, tTempPartList, tCanvas, tDirection, tPeopleSize)
  return tCanvas
end

on getInfo me
  if pCtrlType = EMPTY then
    pInfoStruct[#ctrl] = "furniture"
  else
    pInfoStruct[#ctrl] = pCtrlType
  end if
  pInfoStruct[#badge] = me.pBadge
  pInfoStruct[#groupid] = me.pGroupId
  if pTrading then
    pInfoStruct[#custom] = pCustom & RETURN & getText("human_trading", "Trading")
  else
    if pCarrying <> 0 then
      pInfoStruct[#custom] = pCustom & RETURN & getText("human_carrying", "Carrying:") && pCarrying
    else
      pInfoStruct[#custom] = pCustom
    end if
  end if
  return pInfoStruct
end

on getWebID me
  return pWebID
end

on getSprites me
  return [pSprite, pShadowSpr, pMatteSpr]
end

on getProperty me, tPropID
  case tPropID of
    #dancing:
      return pDancing
    #carrying:
      return pCarrying
    #loc:
      return [pLocX, pLocY, pLocH]
    #mainAction:
      return pMainAction
    #moving:
      return me.pMoving
    #badge:
      return me.pBadge
    #swimming:
      return me.pSwim
    #groupid:
      return pGroupId
    #groupstatus:
      return pStatusInGroup
    otherwise:
      return 0
  end case
end

on setProperty me, tPropID, tValue
  case tPropID of
    #groupid:
      pGroupId = tValue
    #groupstatus:
      pStatusInGroup = tValue
    otherwise:
      return 0
  end case
end

on isInSwimsuit me
  return 0
end

on closeEyes me
  if pMainAction = "lay" then
    call(#defineActMultiple, pPartList, "ley", pPartListSubSet["eye"])
  else
    call(#defineActMultiple, pPartList, "eyb", pPartListSubSet["eye"])
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me
  if pMainAction = "lay" then
    call(#defineActMultiple, pPartList, "lay", pPartListSubSet["eye"])
  else
    call(#defineActMultiple, pPartList, "std", pPartListSubSet["eye"])
  end if
  pEyesClosed = 0
  pChanges = 1
end

on startAnimation me, tMemName
  if tMemName = pCurrentAnim then
    return 0
  end if
  if not memberExists(tMemName) then
    return 0
  end if
  tmember = member(getmemnum(tMemName))
  tList = tmember.text
  tTempDelim = the itemDelimiter
  the itemDelimiter = "/"
  repeat with i = 1 to tList.line.count
    tPart = tList.line[i].item[1]
    tAnim = tList.line[i].item[2]
    call(#setAnimation, pPartList, tPart, tAnim)
  end repeat
  the itemDelimiter = tTempDelim
  pAnimating = 1
  pCurrentAnim = tMemName
end

on stopAnimation me
  pAnimating = 0
  pCurrentAnim = EMPTY
  call(#remAnimation, pPartList)
end

on resumeAnimation me
  tMemName = pCurrentAnim
  pCurrentAnim = EMPTY
  me.startAnimation(tMemName)
end

on show me
  pSprite.visible = 1
  pMatteSpr.visible = 1
  pShadowSpr.visible = 1
end

on hide me
  pSprite.visible = 0
  pMatteSpr.visible = 0
  pShadowSpr.visible = 0
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.image.draw(pMember.image.rect, [#shapeType: #rect, #color: tRGB])
end

on prepare me
  pAnimCounter = (pAnimCounter + 1) mod 4
  if pEyesClosed and not pSleeping then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if pTalking and (random(3) > 1) then
    if pMainAction = "lay" then
      call(#defineActMultiple, pPartList, "lsp", pPartListSubSet["speak"])
    else
      call(#defineActMultiple, pPartList, "spk", pPartListSubSet["speak"])
    end if
    pChanges = 1
  end if
  if pMoving then
    tFactor = float(the milliSeconds - pMoveStart) / pMoveTime
    if tFactor > 1.0 then
      tFactor = 1.0
    end if
    pScreenLoc = ((pDestLScreen - pStartLScreen) * tFactor) + pStartLScreen
    pChanges = 1
  end if
  if pWaving and (pMainAction <> "lay") then
    call(#doHandWorkLeft, me.getDefinedPartList(pPartListSubSet["handLeft"]), "wav")
    pChanges = 1
  end if
  if pDancing then
    pAnimating = 1
    pChanges = 1
  end if
end

on render me
  if not pChanges then
    return 
  end if
  if pPeopleSize = "sh" then
    tSkipFreq = 4
  else
    tSkipFreq = 5
  end if
  if (random(tSkipFreq) = 2) and not pMoving then
    call(#skipAnimationFrame, pPartList)
    return 1
  end if
  pChanges = 0
  if pMainAction = "sit" then
    tSize = pCanvasSize[#std]
    pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_001_" & pFlipList[pDirection + 1] & "_0")
  else
    if pMainAction = "lay" then
      tSize = pCanvasSize[#lay]
      pShadowSpr.castNum = 0
      pShadowFix = 0
    else
      tSize = pCanvasSize[#std]
      if pShadowSpr.member <> pDefShadowMem then
        pShadowSpr.member = pDefShadowMem
      end if
    end if
  end if
  if (pBuffer.width <> tSize[1]) or (pBuffer.height <> tSize[2]) then
    pMember.image = image(tSize[1], tSize[2], tSize[3])
    pMember.regPoint = point(0, tSize[2] + tSize[4])
    pSprite.width = tSize[1]
    pSprite.height = tSize[2]
    pMatteSpr.width = tSize[1]
    pMatteSpr.height = tSize[2]
    pBuffer = image(tSize[1], tSize[2], tSize[3])
  end if
  pMember.regPoint = point(0, pMember.regPoint[2])
  pShadowFix = 0
  if pSprite.flipH then
    pSprite.flipH = 0
    pMatteSpr.flipH = 0
    pShadowSpr.flipH = 0
  end if
  if pCorrectLocZ then
    tOffZ = ((pLocH + pRestingHeight) * 1000) + 2
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc[1]
  pSprite.locV = pScreenLoc[2]
  pMatteSpr.loc = pSprite.loc
  pShadowSpr.loc = pSprite.loc + [pShadowFix, 0]
  if pBaseLocZ <> 0 then
    pSprite.locZ = pBaseLocZ
  else
    pSprite.locZ = pScreenLoc[3] + tOffZ + pBaseLocZ
  end if
  pMatteSpr.locZ = pSprite.locZ + 1
  pShadowSpr.locZ = pSprite.locZ - 3
  pUpdateRect = rect(0, 0, 0, 0)
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#update, pPartList)
  pMember.image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
end

on reDraw me
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on getClearedFigurePartList me, tmodels
  return me.getSpecificClearedFigurePartList(tmodels, "human.parts")
end

on getSpecificClearedFigurePartList me, tmodels, tListName
  tPartList = getVariableValue(tListName & "." & pPeopleSize)
  if tPartList.ilk <> #list then
    return []
  end if
  if not objectExists("Figure_System") then
    error("No figure system!", me.getID, #getSpecificClearedFigurePartList, #critical)
    return tPartList
  end if
  tFigureSystem = getObject("Figure_System")
  repeat with tmodel in tmodels
    tSetID = tmodel["setid"]
    tsex = pSex
    if voidp(pSex) then
      tsex = "M"
    end if
    tPreventedParts = tFigureSystem.getPreventedPartsBySetID(tsex, tSetID)
    if tPreventedParts.count > 0 then
      repeat with tPart in tPreventedParts
        if tPartList.getOne(tPart) then
          tPartList.deleteOne(tPart)
        end if
      end repeat
    end if
  end repeat
  return tPartList
end

on setPartLists me, tmodels
  tAction = pMainAction
  pPartList = []
  tPartDefinition = me.getClearedFigurePartList(tmodels)
  repeat with i = 1 to tPartDefinition.count
    tPartSymbol = tPartDefinition[i]
    if voidp(tmodels[tPartSymbol]) then
      tmodels[tPartSymbol] = [:]
    end if
    if voidp(tmodels[tPartSymbol]["model"]) then
      tmodels[tPartSymbol]["model"] = "000"
    end if
    if voidp(tmodels[tPartSymbol]["color"]) then
      tmodels[tPartSymbol]["color"] = rgb("EEEEEE")
    end if
    if (tPartSymbol = "fc") and (tmodels[tPartSymbol]["model"] <> "001") and (pXFactor < 33) then
      tmodels[tPartSymbol]["model"] = "001"
    end if
    tPartObj = createObject(#temp, pPartClass)
    if stringp(tmodels[tPartSymbol]["color"]) then
      tColor = value("rgb(" & tmodels[tPartSymbol]["color"] & ")")
    end if
    if tmodels[tPartSymbol]["color"].ilk <> #color then
      tColor = rgb(tmodels[tPartSymbol]["color"])
    else
      tColor = tmodels[tPartSymbol]["color"]
    end if
    if (tColor.red + tColor.green + tColor.blue) > (238 * 3) then
      tColor = rgb("EEEEEE")
    end if
    tPartObj.define(tPartSymbol, tmodels[tPartSymbol]["model"], tColor, pDirection, tAction, me)
    pPartList.add(tPartObj)
    pColors.setaProp(tPartSymbol, tColor)
  end repeat
  pPartIndex = [:]
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
  return 1
end

on arrangeParts me
  tPartOrder = EMPTY
  tDirData = EMPTY
  if not voidp(pDirection) then
    tDirData = "." & pDirection
  end if
  tPartOrder = "human.parts." & pPeopleSize
  tPartOrderAction = tPartOrder & "." & pMainAction
  if variableExists(tPartOrderAction & tDirData) then
    tPartOrder = tPartOrderAction
  end if
  if pWaving then
    tPartOrderWave = tPartOrder & ".wave"
    if variableExists(tPartOrderWave & tDirData) then
      tPartOrder = tPartOrderWave
    end if
  end if
  tPartOrder = tPartOrder & tDirData
  if tPartOrder = pPartOrderOld then
    return 1
  end if
  if not variableExists(tPartOrder) then
    error(me, "No human part order found" && tPartOrder, #arrangeParts, #major)
  else
    tPartDefinition = getVariableValue(tPartOrder)
    tTempPartList = []
    repeat with tPartSymbol in tPartDefinition
      if not voidp(pPartIndex[tPartSymbol]) then
        tTempPartList.append(pPartList[pPartIndex[tPartSymbol]])
      end if
    end repeat
    if tTempPartList.count <> pPartList.count then
      return error(me, "Invalid human part order" && tPartOrder, #arrangeParts, #major)
    end if
    pPartList = tTempPartList
    pPartOrderOld = tPartOrder
  end if
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end

on getCanvasName me
  return pClass && pName & me.getID() && "Canvas"
end

on getDefinedPartList me, tPartNameList
  tPartList = []
  repeat with tPartName in tPartNameList
    if not voidp(pPartIndex[tPartName]) then
      tPos = pPartIndex[tPartName]
      tPartList.append(pPartList[tPos])
    end if
  end repeat
  return tPartList
end

on action_mv me, tProps
  pMainAction = "wlk"
  pMoving = 1
  pBaseLocZ = 0
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = getLocalFloat(tloc.item[3])
  the itemDelimiter = tDelim
  pMoveStart = the milliSeconds
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  call(#defineActMultiple, pPartList, "wlk", pPartListSubSet["walk"])
end

on action_sld me, tProps
  pMoving = 1
  pBaseLocZ = 0
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = getLocalFloat(tloc.item[3])
  the itemDelimiter = tDelim
  pQueuesWithObj = integer(tProps.word[3])
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pPreviousLoc = [pLocX, pLocY, pLocH]
  tStartTime = tProps.word[4]
  if voidp(tStartTime) then
    pMoveStart = the milliSeconds
  else
    pMoveStart = tStartTime
  end if
end

on action_sit me, tProps
  call(#defineActMultiple, pPartList, "sit", pPartListSubSet["sit"])
  pMainAction = "sit"
  pRestingHeight = getLocalFloat(tProps.word[2]) - 1.0
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  tIsInQueue = integer(tProps.word[3])
  pQueuesWithObj = tIsInQueue
end

on action_lay me, tProps
  pMainAction = "lay"
  pCarrying = 0
  tRestingHeight = getLocalFloat(tProps.word[2])
  if tRestingHeight < 0.0 then
    pRestingHeight = abs(tRestingHeight) - 1.0
    tZOffset = 0
  else
    pRestingHeight = tRestingHeight - 1.0
    tZOffset = 2000
  end if
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  if pXFactor < 33 then
    case pFlipList[pDirection + 1] of
      2:
        pScreenLoc = pScreenLoc + [-10, 18, tZOffset]
      0:
        pScreenLoc = pScreenLoc + [-17, 18, tZOffset]
    end case
  else
    case pFlipList[pDirection + 1] of
      2:
        pScreenLoc = pScreenLoc + [10, 30, tZOffset]
      0:
        pScreenLoc = pScreenLoc + [-47, 32, tZOffset]
    end case
  end if
  if pXFactor > 32 then
    pLocFix = point(30, -10)
  else
    pLocFix = point(35, -5)
  end if
  call(#layDown, pPartList)
  if pDirection = 0 then
    pDirection = 4
    pHeadDir = 4
  end if
  call(#defineDir, pPartList, pDirection)
end

on action_carryd me, tProps
  tItem = tProps.word[2]
  if value(tItem) > 0 then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_cri me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "075")
    else
      tCarryItm = "075"
    end if
    call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_usei me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_drink me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_carryf me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, tItem)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "004"
      call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_eat me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "004"
      call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_talk me, tProps
  if (pMainAction = "lay") and (pXFactor < 33) then
    return 0
  end if
  pTalking = 1
end

on action_gest me, tProps
  if pPeopleSize = "sh" then
    return 
  end if
  tGesture = tProps.word[2]
  if tGesture = "spr" then
    tGesture = "srp"
  end if
  if pMainAction = "lay" then
    tGesture = "l" & tGesture.char[1..2]
    call(#defineActMultiple, pPartList, tGesture, pPartListSubSet["gesture"])
  else
    call(#defineActMultiple, pPartList, tGesture, pPartListSubSet["gesture"])
    if tGesture = "ohd" then
      call(#defineActMultiple, pPartList, "ohd", pPartListSubSet["head"])
    end if
  end if
end

on action_wave me, tProps
  pWaving = 1
end

on action_dance me, tProps
  tStyleNum = tProps.word[2]
  pDancing = integer(tStyleNum)
  if pDancing = VOID then
    pDancing = 1
  end if
  tStyle = "dance." & pDancing
  me.startAnimation(tStyle)
end

on action_ohd me
  call(#defineActMultiple, pPartList, "ohd", pPartListSubSet["head"])
  call(#doHandWorkRight, me.getDefinedPartList(pPartListSubSet["handRight"]), "ohd")
end

on action_trd me
  pTrading = 1
end

on action_sleep me
  pSleeping = 1
end

on action_flatctrl me, tProps
  pCtrlType = tProps.word[2]
end

on action_mod me, tProps
  pModState = tProps.word[2]
end

on action_sign me, props
  tSignMem = "sign" & props.word[2]
  if getmemnum(tSignMem) = 0 then
    return 0
  end if
  call(#doHandWorkLeft, me.getDefinedPartList(pPartListSubSet["handLeft"]), "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(pExtraObjs[tSignObjID]) then
    pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, pExtraObjs, ["sprite": pSprite, "direction": pDirection, "signmember": tSignMem])
end
