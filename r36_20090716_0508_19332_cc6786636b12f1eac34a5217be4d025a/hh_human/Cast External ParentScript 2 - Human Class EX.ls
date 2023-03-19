property pName, pClass, pCustom, pSex, pModState, pCtrlType, pBadges, pID, pWebID, pBuffer, pSprite, pMatteSpr, pMember, pShadowSpr, pShadowFix, pDefShadowMem, pPartList, pPartIndex, pFlipList, pFlipPartList, pUpdateRect, pDirection, pLastDir, pHeadDir, pLocX, pLocY, pLocH, pLocFix, pXFactor, pYFactor, pHFactor, pScreenLoc, pStartLScreen, pDestLScreen, pRestingHeight, pAnimCounter, pMoveStart, pMoveTime, pEyesClosed, pSync, pChanges, pAlphaColor, pCanvasSize, pColors, pPeopleSize, pMainAction, pMoving, pTalking, pCarrying, pSleeping, pDancing, pWaving, pTrading, pAnimating, pSwim, pCurrentAnim, pGeometry, pExtraObjs, pExtraObjsActive, pInfoStruct, pCorrectLocZ, pPartClass, pQueuesWithObj, pPreviousLoc, pBaseLocZ, pGroupId, pStatusInGroup, pXP, pFx, pFXManager, pFrozenAnimFrame, pPartListSubSet, pPartListFull, pPartActionList, pPartOrderOld, pLeftHandUp, pRightHandUp, pRawFigure, pTypingSprite, pUserIsTyping, pUserTypingStartTime, pCanvasName, pDrinkEatTimeoutList, pDrinkEatParams, pCarryItemCode, pGesture, pSitting, pLayingDown, pPersistedFX

on construct me
  pFrozenAnimFrame = 0
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
  pFx = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pAnimating = 0
  pSwim = 0
  pBadges = [:]
  pCurrentAnim = EMPTY
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pColors = [:]
  pModState = 0
  pExtraObjs = [:]
  pExtraObjsActive = [:]
  pDefShadowMem = member(0)
  pInfoStruct = [:]
  pQueuesWithObj = 0
  pXP = 0
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
  pRawFigure = [:]
  pPartOrderOld = EMPTY
  pUserIsTyping = 0
  pUserTypingStartTime = 0
  pCanvasName = "Canvas:" & getUniqueID()
  tSubSetList = ["figure", "head", "speak", "gesture", "eye", "handRight", "handLeft", "walk", "sit", "itemRight"]
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
  pPartListFull = getVariableValue("human.parts." & pPeopleSize)
  if ilk(pPartListFull) <> #list then
    pPartListFull = []
  end if
  pFlipPartList = getVariable("human.parts.flipList")
  if ilk(pFlipPartList) <> #propList then
    pFlipPartList = [:]
  end if
  pDrinkEatParams = [:]
  pPartActionList = VOID
  pLeftHandUp = 0
  pRightHandUp = 0
  pDrinkEatTimeoutList = []
  pCarryItemCode = VOID
  pGesture = 0
  pSitting = 0
  pLayingDown = 0
  pPersistedFX = 0
  return 1
end

on deconstruct me
  pGeometry = VOID
  pPartList = []
  pPartIndex = [:]
  pInfoStruct = [:]
  me.resetSpriteColors()
  if not voidp(pSprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  if not voidp(pMatteSpr) then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if not voidp(pShadowSpr) then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if not voidp(pTypingSprite) then
    releaseSprite(pTypingSprite.spriteNum)
  end if
  if memberExists(me.getCanvasName()) then
    removeMember(me.getCanvasName())
  end if
  if objectp(pFXManager) then
    pFXManager.deconstruct()
  end if
  pFXManager = VOID
  pFx = 0
  call(#deconstruct, pExtraObjs)
  pExtraObjsActive = [:]
  pExtraObjs = VOID
  pShadowSpr = VOID
  pMatteSpr = VOID
  pSprite = VOID
  timeout("wavetimeout" & me.getID()).forget()
  repeat with tName in pDrinkEatTimeoutList
    timeout(tName).forget()
  end repeat
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
  pMatteSpr = sprite(reserveSprite(me.getID()))
  pMatteSpr.castNum = pMember.number
  pShadowFix = 0
  pDefShadowMem = member(getmemnum(pPeopleSize & "_std_sd_1_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  pShadowSpr = sprite(reserveSprite(me.getID()))
  if ilk(pShadowSpr) = #sprite then
    setEventBroker(pShadowSpr.spriteNum, me.getID())
    pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  end if
  me.resetSpriteColors()
  pInfoStruct[#name] = pName
  pInfoStruct[#class] = pClass
  pInfoStruct[#custom] = pCustom
  pInfoStruct[#image] = me.getPicture()
  pInfoStruct[#ctrl] = "furniture"
  pInfoStruct[#badges] = [:]
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
  if tdata <> VOID then
    pSex = tdata[#sex]
    pCustom = tdata[#custom]
    tmodels = tdata[#figure]
    me.setPartLists(tmodels)
  else
    me.setPartLists()
  end if
  pPartOrderOld = EMPTY
  me.arrangeParts()
  tAnimating = pAnimating
  me.resumeAnimation()
  pAnimating = tAnimating
  pChanges = 1
  me.render(1)
  me.reDraw()
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
  pBadges = tdata[#badge]
  pGroupId = tdata[#groupID]
  pStatusInGroup = tdata[#groupstatus]
  pXP = tdata.getaProp(#xp)
  if not voidp(tdata.getaProp(#webID)) then
    pWebID = tdata[#webID]
  end if
  pPeopleSize = getVariable("human.size." & integer(pXFactor))
  if not pPeopleSize then
    error(me, "People size not found, using default!", #setup, #minor)
    pPeopleSize = "h"
  end if
  tRoomStruct = getObject(#session).GET("lastroom")
  if not listp(tRoomStruct) then
    error(me, "Room struct not saved in #session!", #construct)
    ttype = #public
  else
    ttype = tRoomStruct.getaProp(#type)
  end if
  if ttype = #private then
    pCorrectLocZ = 1
  else
    pCorrectLocZ = 0
  end if
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

on resetSpriteColors me
  if ilk(pSprite) = #sprite then
    pSprite.ink = 36
    pSprite.blend = 100
    pSprite.bgColor = paletteIndex(0)
    pSprite.foreColor = 255
  end if
  if ilk(pMatteSpr) = #sprite then
    pMatteSpr.ink = 8
    pMatteSpr.blend = 0
    pMatteSpr.bgColor = paletteIndex(0)
    pMatteSpr.foreColor = 255
  end if
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.blend = 16
    pShadowSpr.ink = 8
    pShadowSpr.bgColor = paletteIndex(0)
    pShadowSpr.foreColor = 255
  end if
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody, tActionList
  if tActionList = VOID then
    tActionList = []
  end if
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return 1
  end if
  tWasDancing = pDancing
  pMoving = 0
  pTrading = tActionList.findPos("trd") > 0
  pCtrlType = 0
  pAnimating = pDancing or pFx
  pModState = 0
  pQueuesWithObj = 0
  if tWasDancing and not pDancing then
    executeMessage(#updateInfoStandButtons)
  end if
  repeat with i = 1 to pExtraObjsActive.count
    if pExtraObjsActive.getPropAt(i) <> "IG_ICON" then
      pExtraObjsActive[i] = 0
    end if
  end repeat
  pLocFix = point(-1, 2)
  call(#reset, pPartList)
  if pGeometry <> VOID then
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0.0
  pDirection = (tDirBody + me.getEffectDirOffset()) mod 8
  pHeadDir = (tDirHead + me.getEffectDirOffset()) mod 8
  me.resetAction()
  if pExtraObjs.count > 0 then
    call(#Refresh, pExtraObjs)
  end if
end

on Refresh me, tX, tY, tH
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return 1
  end if
  if (pFx > 0) or (pDancing > 0) or (pMainAction = "lay") then
    pHeadDir = pDirection
  end if
  call(#defineDir, pPartList, pDirection)
  call(#defineDirMultiple, pPartList, pHeadDir, pPartListSubSet["head"])
  if pCarrying <> 0 then
    call("action_" & pDrinkEatParams[#action], [me], pDrinkEatParams[#action] && pDrinkEatParams[#params])
  end if
  if pGesture <> 0 then
    call("action_gest", [me], "gest " && pGesture)
  end if
  me.arrangeParts()
  i = 1
  repeat while i <= pExtraObjsActive.count
    if pExtraObjsActive[i] = 0 then
      pExtraObjs[i].deconstruct()
      pExtraObjs.deleteAt(i)
      pExtraObjsActive.deleteAt(i)
      next repeat
    end if
    i = i + 1
  end repeat
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
  pInfoStruct[#badges] = me.pBadges
  if voidp(me.pBadges) then
    tConn = getConnection(getVariable("connection.info.id"))
    if tConn <> 0 then
      tConn.send("GETSELECTEDBADGES", [#integer: integer(me.pWebID)])
    end if
  end if
  pInfoStruct[#groupID] = me.pGroupId
  if pCustom = EMPTY then
    tPrefix = EMPTY
  else
    tPrefix = pCustom & RETURN & RETURN
  end if
  if pTrading then
    pInfoStruct[#custom] = tPrefix & getText("human_trading", "Trading")
  else
    if pCarrying <> 0 then
      pInfoStruct[#custom] = tPrefix & getText("human_carrying", "Carrying:") && pCarrying
    else
      pInfoStruct[#custom] = pCustom
    end if
  end if
  pInfoStruct.setaProp(#xp, pXP)
  pInfoStruct.setaProp(#FX, me.getCurrentEffectState())
  return pInfoStruct
end

on getWebID me
  return pWebID
end

on getSprites me
  if ilk(pShadowSpr) = #sprite then
    return [pSprite, pShadowSpr, pMatteSpr]
  else
    return [pSprite, pMatteSpr]
  end if
end

on getProperty me, tPropID
  case tPropID of
    #carrying:
      return pCarrying
    #direction:
      return pDirection
    #dancing:
      return pDancing
    #FX:
      return pFx
    #loc:
      return [pLocX, pLocY, pLocH]
    #mainAction:
      return pMainAction
    #moving:
      return me.pMoving
    #badges:
      return me.pBadges
    #swimming:
      return me.pSwim
    #groupID:
      return pGroupId
    #groupstatus:
      return pStatusInGroup
    #typing:
      return pUserIsTyping
    #peoplesize:
      return pPeopleSize
    #locZ:
      if pSprite.ilk = #sprite then
        return pSprite.locZ
      end if
    otherwise:
      return 0
  end case
end

on setProperty me, tPropID, tValue
  case tPropID of
    #groupID:
      pGroupId = tValue
    #groupstatus:
      pStatusInGroup = tValue
    otherwise:
      return 0
  end case
end

on setUserTypingStatus me, tValue
  if tValue = 1 then
    if ilk(pTypingSprite) <> #sprite then
      pTypingSprite = sprite(reserveSprite(me.getID()))
    end if
    if ilk(pTypingSprite) = #sprite then
      if pPeopleSize = "sh" then
        pTypingSprite.member = getMember("chat_typing_bubble_small")
      else
        pTypingSprite.member = getMember("chat_typing_bubble")
      end if
      pTypingSprite.ink = 8
      me.updateTypingSpriteLoc()
    end if
    pUserTypingStartTime = the milliSeconds
  else
    if ilk(pTypingSprite) = #sprite then
      releaseSprite(pTypingSprite.spriteNum)
      pTypingSprite = VOID
      pUserTypingStartTime = 0
    end if
  end if
end

on updateTypingSpriteLoc me
  if (ilk(pTypingSprite) = #sprite) and (ilk(pSprite) = #sprite) then
    tOffset = point(57, -75)
    tOffsetLocZ = 30
    if pPeopleSize = "sh" then
      tOffset = point(33, -40)
    end if
    pTypingSprite.loc = pSprite.loc + tOffset
    pTypingSprite.visible = pSprite.visible
    pTypingSprite.locZ = pSprite.locZ + tOffsetLocZ
  end if
end

on getPartCarrying me, tPart
  if pPartListSubSet["handRight"].findPos(tPart) and me.getProperty(#carrying) then
    return 1
  end if
  return 0
end

on isInSwimsuit me
  return 0
end

on closeEyes me
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet["eye"], "ley")
  else
    me.definePartListAction(pPartListSubSet["eye"], "eyb")
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet["eye"], "lay")
  else
    me.definePartListAction(pPartListSubSet["eye"], "std")
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
    tChar = tList.line[i].char[1]
    if (tChar <> "#") and (tChar <> EMPTY) then
      tPart = tList.line[i].item[1]
      tAnim = tList.line[i].item[2]
      case tPart of
        "leftHandUp":
          pLeftHandUp = 1
        "all":
          call(#setAnimation, pPartList, "all", tAnim)
          call(#setAnimation, [pFXManager], "all", tAnim)
        otherwise:
          call(#setAnimation, pPartList, tPart, tAnim)
          call(#setAnimation, [pFXManager], tPart, tAnim)
      end case
    end if
  end repeat
  the itemDelimiter = tTempDelim
  pAnimating = 1
  pCurrentAnim = tMemName
end

on stopAnimation me
  pAnimating = 0
  pCurrentAnim = EMPTY
  call(#remAnimation, pPartList)
  me.resetSpriteColors()
end

on resumeAnimation me
  tMemName = pCurrentAnim
  pCurrentAnim = EMPTY
  me.startAnimation(tMemName)
end

on show me
  pSprite.visible = 1
  pMatteSpr.visible = 1
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.visible = 1
  end if
  me.updateTypingSpriteLoc()
  tFXSprites = me.getEffectSpriteProps()
  repeat with tProps in tFXSprites
    tsprite = tProps.getaProp(#sprite)
    tsprite.visible = 1
  end repeat
end

on hide me
  pSprite.visible = 0
  pMatteSpr.visible = 0
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.visible = 0
  end if
  me.updateTypingSpriteLoc()
  tFXSprites = me.getEffectSpriteProps()
  repeat with tProps in tFXSprites
    tsprite = tProps.getaProp(#sprite)
    tsprite.visible = 0
  end repeat
end

on draw me, tRGB
  if ilk(tRGB) <> #color then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.image.draw(pMember.image.rect, [#shapeType: #rect, #color: tRGB])
end

on prepare me
  if not pFrozenAnimFrame then
    pAnimCounter = (pAnimCounter + 1) mod 4
  else
    pAnimCounter = pFrozenAnimFrame - 1
  end if
  if pEyesClosed and not pSleeping then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if pTalking and (random(3) > 1) then
    if pMainAction = "lay" then
      me.definePartListAction(pPartListSubSet["speak"], "lsp")
    else
      me.definePartListAction(pPartListSubSet["speak"], "spk")
    end if
    pChanges = 1
  else
    if pMainAction = "lay" then
      me.definePartListAction(pPartListSubSet["speak"], "lay")
    else
      me.definePartListAction(pPartListSubSet["speak"], "std")
    end if
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
    me.definePartListAction(pPartListSubSet["handLeft"], "wav")
    pChanges = 1
  end if
  if pDancing or pFx then
    pAnimating = 1
    pChanges = 1
  end if
  tTimeNow = the milliSeconds
  tMaxTypingTime = 30000
  if ((tTimeNow - pUserTypingStartTime) > tMaxTypingTime) and (pUserTypingStartTime <> 0) then
    pUserTypingStartTime = 0
    me.setUserTypingStatus(0)
  end if
end

on render me, tForceUpdate
  call(#update, pExtraObjs)
  if not pChanges then
    return 
  end if
  if not (me.pFx or me.pMoving or tForceUpdate) then
    if pPeopleSize = "sh" then
      tSkipFreq = 4
    else
      tSkipFreq = 5
    end if
    if random(tSkipFreq) = 2 then
      call(#skipAnimationFrame, pPartList)
      return 1
    end if
  end if
  pChanges = 0
  if pMainAction = "lay" then
    tSize = pCanvasSize[#lay]
  else
    tSize = pCanvasSize[#std]
  end if
  if pFXManager <> 0 then
    tSize = tSize.duplicate()
    tEffectSize = pFXManager.getEffectSizeParams()
    if tEffectSize <> 0 then
      if tEffectSize[1] > tSize[1] then
        tSize[1] = tEffectSize[1]
      end if
      if tEffectSize[2] > tSize[2] then
        tSize[2] = tEffectSize[2]
      end if
    end if
  end if
  if ilk(pShadowSpr) = #sprite then
    if pMainAction = "sit" then
      pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_1_" & pFlipList[pDirection + 1] & "_0")
    else
      if pMainAction = "lay" then
        pShadowSpr.castNum = 0
        pShadowFix = 0
      else
        if me.pFx then
          tShadowMem = me.getEffectShadowName()
          if tShadowMem <> VOID then
            tMemNum = getmemnum(pPeopleSize & "_" & tShadowMem & "_" & pDirection & "_0")
            if tMemNum = 0 then
              tMemNum = getmemnum(pPeopleSize & "_" & tShadowMem & "_" & pFlipList[pDirection + 1] & "_0")
            end if
            pShadowSpr.castNum = tMemNum
          end if
        end if
        if tShadowMem = VOID then
          if pShadowSpr.member <> pDefShadowMem then
            pShadowSpr.member = pDefShadowMem
          end if
        end if
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
  end if
  if ilk(pShadowSpr) = #sprite then
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
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.loc = pSprite.loc + [pShadowFix, 0]
  end if
  if pBaseLocZ <> 0 then
    pSprite.locZ = pBaseLocZ
  else
    pSprite.locZ = pScreenLoc[3] + tOffZ + pBaseLocZ
  end if
  pMatteSpr.locZ = pSprite.locZ + 1
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.locZ = pSprite.locZ - 3
  end if
  me.updateTypingSpriteLoc()
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  repeat with tPart in pPartList
    tRectMod = [0, 0, 0, 0]
    if tPart.pPart = "ey" then
      if pTalking then
        if (pMainAction <> "lay") and ((pAnimCounter mod 2) = 0) then
          tRectMod = [0, -1, 0, -1]
        end if
      end if
    end if
    tPart.update(tForceUpdate, tRectMod)
  end repeat
  pMember.image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
  pUpdateRect = rect(0, 0, 0, 0)
  me.updateEffects()
end

on reDraw me
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on getClearedFigurePartList me, tmodels
  return me.getSpecificClearedFigurePartList(tmodels, me.getPartListNameBase())
end

on getSpecificClearedFigurePartList me, tmodels, tListName
  tPartList = getVariableValue(tListName & "." & pPeopleSize)
  if tPartList.ilk <> #list then
    return []
  end if
  tPartListLegal = tPartList.duplicate()
  repeat with tPart in pPartListSubSet["figure"]
    tPos = tPartList.findPos(tPart)
    if tPos > 0 then
      tPartList.deleteAt(tPos)
    end if
  end repeat
  repeat with i = 1 to tmodels.count
    tPartName = tmodels.getPropAt(i)
    if (tPartList.findPos(tPartName) = 0) and (tPartListLegal.findPos(tPartName) > 0) then
      tPartList.add(tPartName)
    end if
  end repeat
  tEffectParts = me.getEffectAddedPartIndex()
  repeat with i = 1 to tEffectParts.count
    tPartName = tEffectParts[i]
    if tPartList.findPos(tPartName) = 0 then
      tPartList.add(tPartName)
    end if
  end repeat
  tExcludedParts = me.getEffectExcludedPartIndex()
  repeat with tPartId in tExcludedParts
    tPartList.deleteOne(tPartId)
  end repeat
  return tPartList
end

on getRawFigure me
  return pRawFigure
end

on setPartLists me, tmodels
  if voidp(pPartActionList) then
    me.resetAction()
  end if
  if tmodels = VOID then
    tmodels = pRawFigure
  else
    tmodels = tmodels.duplicate()
    pRawFigure = tmodels
  end if
  tPartDefinition = me.getClearedFigurePartList(tmodels)
  tCurrentPartList = [:]
  repeat with i = pPartList.count down to 1
    tPartObj = pPartList[i]
    tPartType = tPartObj.pPart
    if (tPartDefinition.findPos(tPartType) = 0) and pPartListSubSet["figure"].findPos(tPartType) then
      pPartList[i].clearGraphics()
      pPartList.deleteAt(i)
      next repeat
    end if
    tCurrentPartList.addProp(tPartType, tPartObj)
  end repeat
  pPartIndex = [:]
  pColors = [:]
  tAnimationList = getVariable("human.parts.animationList")
  if ilk(tAnimationList) <> #propList then
    tAnimationList = [:]
  end if
  repeat with i = 1 to tPartDefinition.count
    tPartSymbol = tPartDefinition[i]
    tmodel = [:]
    tmodel["model"] = []
    tmodel["color"] = []
    if not voidp(tmodels[tPartSymbol]) then
      repeat with j = 1 to tmodels.count
        if tmodels.getPropAt(j) = tPartSymbol then
          tmodel["model"].add(tmodels[j]["model"])
          tmodel["color"].add(tmodels[j]["color"])
        end if
      end repeat
    end if
    repeat with j = 1 to tmodel["color"].count
      tColor = tmodel["color"][j]
      if voidp(tColor) then
        tColor = rgb("EEEEEE")
      end if
      if stringp(tColor) then
        tColor = value("rgb(" & tColor & ")")
      end if
      if tColor.ilk <> #color then
        tColor = rgb("EEEEEE")
      end if
      if (tColor.red + tColor.green + tColor.blue) > (238 * 3) then
        tColor = rgb("EEEEEE")
      end if
      tmodel["color"][j] = tColor
    end repeat
    if tmodels.findPos(tPartSymbol) > 0 then
      tPartModels = tmodels[tPartSymbol]
      repeat with k = 1 to tPartModels.count
        tPropKey = tPartModels.getPropAt(k)
        if tmodel.findPos(tPropKey) = 0 then
          tmodel.setaProp(tPropKey, tPartModels[k])
        end if
      end repeat
    end if
    tFlipPart = pFlipPartList[tPartSymbol]
    tAction = pPartActionList[tPartSymbol]
    if voidp(tAction) then
      tAction = "std"
      error(me, "Missing action for part" && tPartSymbol, #setPartLists, #major)
    end if
    if tCurrentPartList.findPos(tPartSymbol) = 0 then
      tPartClass = me.getPartClass(tPartSymbol)
      tPartObj = createObject(#temp, tPartClass)
      tDirection = pDirection
      if pPartListSubSet["head"].findPos(tPartSymbol) > 0 then
        tDirection = pHeadDir
      end if
      tPartObj.define(tPartSymbol, tmodel["model"], tmodel["color"], tDirection, tAction, me, tFlipPart, tmodel.getaProp("ink"))
      if tmodel.findPos("blend") > 0 then
        tPartObj.defineBlend(tmodel.getaProp("blend"))
      end if
      tPartObj.setAnimations(tAnimationList[tPartSymbol])
      pPartList.add(tPartObj)
    else
      if tmodel["model"].count > 0 then
        pPartList[i].clearGraphics()
        tPartObj = tCurrentPartList[tPartSymbol]
        tPartObj.changePartData(tmodel["model"], tmodel["color"])
        if tmodel.findPos("blend") > 0 then
          tPartObj.defineBlend(tmodel.getaProp("blend"))
        end if
        if tmodel.findPos("ink") > 0 then
          tPartObj.defineInk(tmodel.getaProp("ink"))
        end if
        tPartObj.setAnimations(tAnimationList[tPartSymbol])
      end if
    end if
    if tmodel["color"].count > 0 then
      pColors.setaProp(tPartSymbol, tmodel["color"])
    end if
  end repeat
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
  return 1
end

on arrangeParts me, tOrderName
  tPartOrder = EMPTY
  tDirData = EMPTY
  if not voidp(pDirection) then
    tDirData = "." & pDirection
  end if
  if voidp(tOrderName) then
    tOrderName = "human.parts"
  end if
  tPartOrder = tOrderName & "." & pPeopleSize
  tPartOrderAction = tPartOrder & "." & pMainAction
  if variableExists(tPartOrderAction & tDirData) then
    tPartOrder = tPartOrderAction
  end if
  if pLeftHandUp then
    tPartOrderLeftHand = tPartOrder & ".lh-up"
    if variableExists(tPartOrderLeftHand & tDirData) then
      tPartOrder = tPartOrderLeftHand
    end if
  end if
  if pRightHandUp then
    tPartOrderRightHand = tPartOrder & ".rh-up"
    if variableExists(tPartOrderRightHand & tDirData) then
      tPartOrder = tPartOrderRightHand
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
    if pFXManager <> 0 then
      pFXManager.alignEffectBodyparts(tPartDefinition, pDirection)
    end if
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
  return pCanvasName
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

on definePartListAction me, tPartList, tAction
  if voidp(pPartActionList) then
    me.resetAction()
  end if
  repeat with tPart in tPartList
    pPartActionList[tPart] = tAction
  end repeat
  call(#defineAct, me.getDefinedPartList(tPartList), tAction)
end

on resetAction me
  pMainAction = "std"
  pLeftHandUp = 0
  pRightHandUp = 0
  if voidp(pPartActionList) then
    pPartActionList = [:]
  end if
  if pPartActionList.count = 0 then
    tPartList = getVariableValue(me.getPartListNameBase() & "." & pPeopleSize)
    if tPartList.ilk = #list then
      repeat with tPart in tPartList
        pPartActionList[tPart] = pMainAction
      end repeat
    end if
  else
    repeat with i = 1 to pPartActionList.count
      pPartActionList[i] = pMainAction
    end repeat
  end if
end

on getPartClass me, tPartSymbol
  return pPartClass
end

on getPartListNameBase me
  return "human.parts"
end

on releaseShadowSprite me
  if ilk(pShadowSpr) = #sprite then
    releaseSprite(pShadowSpr.spriteNum)
    pShadowSpr = VOID
  end if
end

on action_std me, tProps
  if (pLayingDown or pSitting) and (pPersistedFX <> 0) then
    tReactivateFX = 1
  else
    tReactivateFX = 0
  end if
  pLayingDown = 0
  pSitting = 0
  if tReactivateFX then
    me.action_fx("fx" && pPersistedFX)
  end if
end

on action_mv me, tProps
  if (pLayingDown or pSitting) and (pPersistedFX <> 0) then
    tReactivateFX = 1
  else
    tReactivateFX = 0
  end if
  pLayingDown = 0
  pSitting = 0
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
  me.definePartListAction(pPartListSubSet["walk"], "wlk")
  if tReactivateFX then
    me.action_fx("fx" && pPersistedFX)
  end if
end

on action_sld me, tProps
  pLayingDown = 0
  pSitting = 0
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
  pLayingDown = 0
  pSitting = 1
  if pDancing then
    me.stop_action_dance()
  end if
  me.definePartListAction(pPartListSubSet["sit"], "sit")
  pMainAction = "sit"
  pRestingHeight = getLocalFloat(tProps.word[2]) - 1.0
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  tIsInQueue = integer(tProps.word[3])
  pQueuesWithObj = tIsInQueue
  if pCarrying <> 0 then
    call("action_" & pDrinkEatParams[#action], [me], pDrinkEatParams[#action] && pDrinkEatParams[#params])
  end if
end

on action_lay me, tProps
  if pDancing then
    me.stop_action_dance()
  end if
  if pCarrying <> 0 then
    me.stop_action_carry()
  end if
  pLayingDown = 1
  pSitting = 0
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
  me.definePartListAction(pPartListFull, "lay")
  if pDirection = 0 then
    pDirection = 4
    pHeadDir = 4
  end if
  call(#defineDir, pPartList, pDirection)
end

on carryObject me, tProps, tDefaultItem, tDefaultItemPublic
  tItem = tProps.word[2]
  tItemInt = integer(tItem)
  tItemString = string(tItem)
  tIsInteger = string(tItemInt) = tItemString
  if tIsInteger and (tItemInt > 0) then
    tItem = tItemInt
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, string(tDefaultItem))
    else
      tCarryItm = string(tDefaultItem)
    end if
    me.definePartListAction(pPartListSubSet["handRight"], "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    pCarrying = getText("handitem" & tCarrying)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = string(tDefaultItemPublic)
      me.definePartListAction(pPartListSubSet["handRight"], "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    end if
  end if
end

on action_carryd me, tProps
  me.carryObject(tProps, "1", "1")
end

on action_carryf me, tProps
  me.carryObject(tProps, "1", "4")
end

on action_cri me, tProps
  me.carryObject(tProps, "75", "1")
end

on stop_action_carry me, tProps
  pCarrying = 0
  repeat with tName in pDrinkEatTimeoutList
    timeout(tName).forget()
  end repeat
  pDrinkEatTimeoutList = []
  if not me.pFx then
    me.resetAction()
  end if
  me.definePartListAction(pPartListSubSet["handRight"], "std")
  call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), "std")
  me.arrangeParts()
  pChanges = 1
  me.render(1)
end

on stop_action_carryd me, tProps
  me.stop_action_carry(tProps)
end

on stop_action_carryf me, tProps
  me.stop_action_carry(tProps)
end

on stop_action_cri me, tProps
  me.stop_action_carry(tProps)
end

on useObject me, tProps, tDefaultItem, tDefaultItemPublic
  tItem = tProps.word[2]
  tItemInt = integer(tItem)
  tItemString = string(tItem)
  tIsInteger = string(tItemInt) = tItemString
  if tIsInteger and (tItemInt > 0) then
    tItem = tItemInt
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, string(tDefaultItem))
    else
      tCarryItm = string(tDefaultItem)
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    me.definePartListAction(pPartListSubSet["handRight"], "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    pRightHandUp = 1
    me.arrangeParts()
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = string(tDefaultItemPublic)
      me.definePartListAction(pPartListSubSet["handRight"], "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
      pRightHandUp = 1
      me.arrangeParts()
    end if
  end if
end

on action_usei me, tProps
  if not me.pFx then
    me.useObject(tProps, "1", "1")
  end if
end

on stop_action_usei me, tProps
  if not me.pFx then
    me.resetAction()
  end if
  pChanges = 1
  me.render(1)
end

on action_drink me, tProps
  if not me.pFx then
    me.useObject(tProps, "1", "1")
  end if
end

on action_eat me, tProps
  if not me.pFx then
    me.useObject(tProps, "1", "4")
  end if
end

on action_talk me, tProps
  if pPeopleSize = "sh" then
    if pMainAction = "lay" then
      pTalking = 0
      return 0
    end if
  end if
  pTalking = 1
end

on stop_action_talk me, tProps
  pTalking = 0
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet["head"], "lay")
  else
    me.definePartListAction(pPartListSubSet["head"], "std")
  end if
  pChanges = 1
  me.render(1)
end

on action_gest me, tProps
  if pPeopleSize = "sh" then
    return 0
  end if
  tGesture = tProps.word[2]
  if tGesture = "spr" then
    tGesture = "srp"
  end if
  if pMainAction = "lay" then
    tGesture = "l" & tGesture.char[1..2]
    me.definePartListAction(pPartListSubSet["gesture"], tGesture)
  else
    me.definePartListAction(pPartListSubSet["gesture"], tGesture)
    if tGesture = "ohd" then
      me.definePartListAction(pPartListSubSet["head"], "ohd")
    end if
  end if
  pGesture = tGesture
  pChanges = 1
  me.render(1)
end

on stop_action_gest me, tProps
  me.action_gest("gest std")
  pGesture = 0
end

on action_wave me, tProps
  pWaving = 1
  pLeftHandUp = 1
  timeout("wavetimeout" & me.getID()).new(2000, #stop_action_wave, me)
  me.stopAnimation()
end

on stop_action_wave me
  timeout("wavetimeout" & me.getID()).forget()
  pWaving = 0
  pLeftHandUp = 0
  if not me.pAnimating then
    me.definePartListAction(pPartListSubSet["handLeft"], pMainAction)
  end if
  pChanges = 1
end

on action_dance me, tProps
  if not me.allowDancing() then
    return 1
  end if
  me.clearEffects()
  tStyleNum = tProps.word[2]
  pDancing = integer(tStyleNum)
  if pDancing = VOID then
    pDancing = 1
  end if
  tStyle = "dance." & pDancing
  if tStyleNum <> "0" then
    me.stop_action_carry(EMPTY)
    me.stop_action_wave()
    me.startAnimation(tStyle)
  else
    me.stopAnimation()
    pDancing = 0
    me.resetAction()
    pChanges = 1
    me.render(1)
  end if
  executeMessage(#updateInfostandAvatar)
end

on allowDancing me
  if pMainAction = "lay" then
    return 0
  end if
  if pMainAction = "sit" then
    return 0
  end if
  return 1
end

on stop_action_dance me, tProps
  me.action_dance("dance 0")
  me.resetAction()
  pChanges = 1
end

on action_ohd me
  if not me.pFx then
    me.definePartListAction(pPartListSubSet["head"], "ohd")
    me.definePartListAction(pPartListSubSet["handRight"], "ohd")
  end if
end

on action_trd me
  pTrading = 1
end

on action_sleep me, tSleep
  pSleeping = tSleep
end

on action_flatctrl me, tProps
  pCtrlType = tProps.word[2]
end

on action_mod me, tProps
  pModState = tProps.word[2]
end

on action_sign me, props
  if not me.pFx then
    tSignMem = "sign" & props.word[2]
    if getmemnum(tSignMem) = 0 then
      return 0
    end if
    me.definePartListAction(pPartListSubSet["handLeft"], "sig")
    tSignObjID = "SIGN_EXTRA"
    pExtraObjsActive.setaProp(tSignObjID, 1)
    if voidp(pExtraObjs[tSignObjID]) then
      pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
    end if
    call(#show_sign, pExtraObjs, ["sprite": pSprite, "direction": pDirection, "signmember": tSignMem])
    pLeftHandUp = 1
  end if
end

on action_joingame me, tProps
  if tProps.word.count < 3 then
    return 0
  end if
  tSignObjID = "IG_ICON"
  pExtraObjsActive.setaProp(tSignObjID, 1)
  if tProps.length = string("joingame").length then
    pExtraObjsActive.setaProp(tSignObjID, 0)
    return 
  end if
  if pExtraObjs.findPos(tSignObjID) = 0 then
    tObject = createObject(#temp, "IG HumanIcon Class")
    if tObject = 0 then
      return 0
    end if
    pExtraObjs.setaProp(tSignObjID, tObject)
  end if
  call(#show_ig_icon, pExtraObjs, ["userid": me.getID(), "gameid": tProps.word[2], "gametype": tProps.word[3], "locz": pSprite.locZ])
end

on action_fx me, tProps
  me.pPersistedFX = 0
  if tProps = VOID then
    return 0
  end if
  if tProps.length < 4 then
    return 0
  end if
  tID = integer(tProps.char[4..tProps.length])
  tManager = me.getEffectManager()
  if tManager = 0 then
    return 0
  end if
  if tID = 0 then
    me.clearEffects()
    me.pFx = tID
    me.pPersistedFX = 0
    executeMessage(#updateInfostandAvatar)
    return 1
  end if
  if tManager.effectExists(tID) then
    return 1
  end if
  me.clearEffects()
  if not tManager.constructEffect(me, tID) then
    return error(me, "Can not construct effect:" && tID, #action_fx, #minor)
  end if
  me.pFx = tID
  executeMessage(#updateInfostandAvatar)
  return 1
end

on persist_fx me, ttype
  me.pPersistedFX = ttype
end

on handle_user_carry_object me, tItemType, tItemName
  tAction = "carryd"
  if tItemType = 20 then
    tAction = "cri"
  end if
  if tItemType = 101 then
    tAction = "carryf"
  end if
  tParams = string(tItemType)
  if (tItemType = 100) or (tItemType = 101) then
    tParams = tItemName
  end if
  call("action_" & tAction, [me], tAction && tParams)
  pChanges = 1
  me.render(1)
  pCarryItemCode = tItemType
  if (tItemType = 0) or (tItemType = 20) then
    pDrinkEatParams = [:]
    return 
  end if
  tHandler = #execute_drink
  if tItemType = 101 then
    tHandler = #execute_eat
  end if
  pDrinkEatParams = [#params: tParams, #action: tAction]
  repeat with i = 1 to 10
    tID = getUniqueID()
    timeout(tID).new(i * 10 * 1000, tHandler, me)
    pDrinkEatTimeoutList.add(tID)
  end repeat
  tID = getUniqueID()
  timeout(tID).new((10 * 10 * 1000) + 1000, #stop_action_carry, me)
  pDrinkEatTimeoutList.add(tID)
end

on execute_eat me, tTimeout
  pDrinkEatTimeoutList.deleteOne(tTimeout.name)
  timeout(tTimeout.name).forget()
  me.action_eat("eat " & pDrinkEatParams[#params])
  pChanges = 1
  me.render(1)
  tID = getUniqueID()
  timeout(tID).new(500, #execute_continue_carry, me)
  pDrinkEatTimeoutList.add(tID)
end

on execute_drink me, tTimeout
  pDrinkEatTimeoutList.deleteOne(tTimeout.name)
  timeout(tTimeout.name).forget()
  me.action_drink("drink " & pDrinkEatParams[#params])
  pChanges = 1
  me.render(1)
  tID = getUniqueID()
  timeout(tID).new(500, #execute_continue_carry, me)
  pDrinkEatTimeoutList.add(tID)
end

on execute_continue_carry me, tTimeout
  pDrinkEatTimeoutList.deleteOne(tTimeout.name)
  timeout(tTimeout.name).forget()
  call("action_" & pDrinkEatParams[#action], [me], pDrinkEatParams[#action] && pDrinkEatParams[#params])
  pChanges = 1
  me.render(1)
end

on handle_user_use_object me, tItemType
  if tItemType <> 0 then
    me.action_usei("usei " & tItemType)
  else
    me.stop_action_usei(EMPTY)
  end if
end

on validateFxForActionList me, tActionDefs, tActionIndex
  if ilk(tActionDefs) <> #list then
    return 0
  end if
  if ilk(tActionIndex) <> #list then
    return 0
  end if
  tEffectID = VOID
  if pFx <> 0 then
    tEffectID = pFx
  end if
  tActions = []
  repeat with tAction in tActionDefs
    if ilk(tAction) = #propList then
      if tAction.getaProp(#name) = "fx" then
        tEffectID = tAction.getaProp(#params).word[2]
        next repeat
      end if
      tActions.add(tAction.getaProp(#name))
    end if
  end repeat
  if pDrinkEatParams.ilk = #propList then
    if pCarrying <> 0 then
      tActions.add(pDrinkEatParams[#action])
    end if
  end if
  if pSitting <> 0 then
    tActions.add("sit")
  end if
  if pLayingDown <> 0 then
    tActions.add("lay")
  end if
  if pDancing <> 0 then
    tActions.add("dance")
  end if
  if tEffectID = VOID then
    if pFx then
      me.clearEffects()
    end if
    return 0
  end if
  tVarName = "fx.blacklist." & tEffectID
  if not variableExists(tVarName) then
    return 1
  end if
  tBlackList = getVariableValue(tVarName)
  if ilk(tBlackList) <> #list then
    return 1
  end if
  if variableExists("fx.whitelist." & tEffectID) then
    tWhiteList = getVariableValue("fx.whitelist." & tEffectID)
  end if
  if ilk(tWhiteList) <> #list then
    tWhiteList = []
  end if
  tAllow = 1
  tRemovedActions = []
  repeat with tAction in tActions
    if tBlackList.getOne(tAction) then
      if tWhiteList.getOne(tAction) then
        tRemovedActions.add(tAction)
        call("stop_action_" & tAction, [me], EMPTY)
        next repeat
      end if
      if pFx then
        me.clearEffects(1)
      end if
      tAllow = 0
    end if
  end repeat
  repeat with tNumAction = tActionDefs.count down to 1
    tAction = tActionDefs[tNumAction]
    if ilk(tAction) <> #propList then
      next repeat
    end if
    if tRemovedActions.getOne(tAction[#name]) then
      tActionDefs.deleteAt(tNumAction)
      tPos = tActionIndex.getPos(tAction[#name])
      if tPos > 0 then
        tActionIndex.deleteAt(tPos)
      end if
    end if
  end repeat
  if pCarrying <> 0 then
    tActions.deleteOne(pDrinkEatParams[#action])
  end if
  if pSitting <> 0 then
    tActions.deleteOne("sit")
  end if
  if pLayingDown <> 0 then
    tActions.deleteOne("lay")
  end if
  if pDancing <> 0 then
    tActions.deleteOne("dance")
  end if
  return tAllow
end

on validateCarryForCurrentState me
  tEffectID = VOID
  if pFx <> 0 then
    tEffectID = pFx
  else
    return 1
  end if
  tVarName = "fx.blacklist." & tEffectID
  if not variableExists(tVarName) then
    return 1
  end if
  tBlackList = getVariableValue(tVarName)
  if ilk(tBlackList) <> #list then
    return 1
  end if
  if tBlackList.getPos("carryd") or tBlackList.getPos("carryf") or tBlackList.getPos("cri") then
    return 0
  else
    return 1
  end if
end

on getEffectDirOffset me
  if pFXManager = 0 then
    return 0
  end if
  return pFXManager.getEffectDirOffset()
end

on getEffectShadowName me
  if pFXManager = 0 then
    return []
  end if
  return pFXManager.getEffectShadowName()
end

on getEffectSpriteProps me
  if pFXManager = 0 then
    return []
  end if
  return pFXManager.getEffectSpriteProps()
end

on getEffectAddedPartIndex me
  if pFXManager = 0 then
    return []
  end if
  return pFXManager.getEffectAddedPartIndex()
end

on getEffectExcludedPartIndex me
  if pFXManager = 0 then
    return []
  end if
  return pFXManager.getEffectExcludedPartIndex()
end

on updateEffects me
  if pFXManager = 0 then
    return 1
  end if
  pFXManager.updateEffects(me)
end

on clearEffects me, tTemp
  if tTemp <> 0 then
    me.pPersistedFX = me.pFx
  end if
  if pFXManager <> 0 then
    pFXManager.clearEffects(me)
  end if
  me.pFx = 0
  me.pChanges = 1
  return 1
end

on getCurrentEffectState me
  if pFXManager = 0 then
    return VOID
  end if
  return pFXManager.getCurrentEffectState()
end

on getEffectManager me
  if objectp(pFXManager) then
    return pFXManager
  end if
  pFXManager = createObject(#temp, "Avatar Effect Manager")
  return pFXManager
end
