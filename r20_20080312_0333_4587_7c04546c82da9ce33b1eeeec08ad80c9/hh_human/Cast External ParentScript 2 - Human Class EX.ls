property pName, pClass, pCustom, pSex, pModState, pCtrlType, pBadge, pID, pWebID, pBuffer, pSprite, pMatteSpr, pMember, pShadowSpr, pShadowFix, pDefShadowMem, pPartList, pPartIndex, pFlipList, pUpdateRect, pDirection, pLastDir, pHeadDir, pLocX, pLocY, pLocH, pLocFix, pXFactor, pYFactor, pHFactor, pScreenLoc, pStartLScreen, pDestLScreen, pRestingHeight, pAnimCounter, pMoveStart, pMoveTime, pEyesClosed, pSync, pChanges, pAlphaColor, pCanvasSize, pColors, pPeopleSize, pMainAction, pMoving, pTalking, pCarrying, pSleeping, pDancing, pWaving, pTrading, pAnimating, pSwim, pCurrentAnim, pGeometry, pExtraObjs, pInfoStruct, pCorrectLocZ, pPartClass, pQueuesWithObj, pPreviousLoc, pBaseLocZ, pGroupId, pStatusInGroup, pFrozenAnimFrame, pPartListSubSet, pPartListFull, pPartActionList, pPartOrderOld, pLeftHandUp, pRightHandUp, pRawFigure, pTypingSprite, pUserIsTyping, pUserTypingStartTime

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
  pRawFigure = [:]
  pPartOrderOld = EMPTY
  pUserIsTyping = 0
  pUserTypingStartTime = 0
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
  pPartActionList = VOID
  pLeftHandUp = 0
  pRightHandUp = 0
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
  if not voidp(pTypingSprite) then
    releaseSprite(pTypingSprite.spriteNum)
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
  pDefShadowMem = member(getmemnum(pPeopleSize & "_std_sd_1_0_0"))
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
  me.setPartLists(tmodels)
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
  if pGeometry <> VOID then
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0.0
  pDirection = tDirBody
  pHeadDir = tDirHead
  me.resetAction()
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
    #typing:
      return pUserIsTyping
    #peoplesize:
      return pPeopleSize
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
  if tMemName = "dance.2" then
    pLeftHandUp = 1
  end if
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
  me.updateTypingSpriteLoc()
end

on hide me
  pSprite.visible = 0
  pMatteSpr.visible = 0
  pShadowSpr.visible = 0
  me.updateTypingSpriteLoc()
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
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
  if pDancing then
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
  if not pChanges then
    return 
  end if
  if pPeopleSize = "sh" then
    tSkipFreq = 4
  else
    tSkipFreq = 5
  end if
  if (random(tSkipFreq) = 2) and not pMoving and not tForceUpdate then
    call(#skipAnimationFrame, pPartList)
    return 1
  end if
  pChanges = 0
  if pMainAction = "sit" then
    tSize = pCanvasSize[#std]
    pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_1_" & pFlipList[pDirection + 1] & "_0")
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
  return tPartList
end

on getRawFigure me
  return pRawFigure
end

on setPartLists me, tmodels
  if voidp(pPartActionList) then
    me.resetAction()
  end if
  tmodels = tmodels.duplicate()
  pRawFigure = tmodels
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
  tFlipList = getVariable("human.parts.flipList")
  if ilk(tFlipList) <> #propList then
    tFlipList = [:]
  end if
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
    tFlipPart = tFlipList[tPartSymbol]
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
      tPartObj.define(tPartSymbol, tmodel["model"], tmodel["color"], tDirection, tAction, me, tFlipPart)
      tPartObj.setAnimations(tAnimationList[tPartSymbol])
      pPartList.add(tPartObj)
    else
      if tmodel["model"].count > 0 then
        pPartList[i].clearGraphics()
        tCurrentPartList[tPartSymbol].changePartData(tmodel["model"], tmodel["color"])
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
      if (tPos > 0) and (tPos <= pPartList.count) then
        tPartList.append(pPartList[tPos])
      end if
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
  call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), "0")
end

on getPartClass me, tPartSymbol
  return pPartClass
end

on getPartListNameBase me
  return "human.parts"
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
  me.definePartListAction(pPartListSubSet["walk"], "wlk")
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
  me.definePartListAction(pPartListSubSet["sit"], "sit")
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
  me.definePartListAction(pPartListFull, "lay")
  if pDirection = 0 then
    pDirection = 4
    pHeadDir = 4
  end if
  call(#defineDir, pPartList, pDirection)
end

on carryObject me, tProps, tDefaultItem, tDefaultItemPublic
  tItem = tProps.word[2]
  if value(tItem) > 0 then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, string(tDefaultItem))
    else
      tCarryItm = string(tDefaultItem)
    end if
    me.definePartListAction(pPartListSubSet["handRight"], "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
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

on useObject me, tProps, tDefaultItem, tDefaultItemPublic
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
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
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = string(tDefaultItemPublic)
      me.definePartListAction(pPartListSubSet["handRight"], "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet["itemRight"]), tCarryItm)
      pRightHandUp = 1
    end if
  end if
end

on action_usei me, tProps
  me.useObject(tProps, "1", "1")
end

on action_drink me, tProps
  me.useObject(tProps, "1", "1")
end

on action_eat me, tProps
  me.useObject(tProps, "1", "4")
end

on action_talk me, tProps
  if pPeopleSize = "sh" then
    if pMainAction = "lay" then
      return 0
    end if
  end if
  pTalking = 1
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
end

on action_wave me, tProps
  pWaving = 1
  pLeftHandUp = 1
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
  me.definePartListAction(pPartListSubSet["head"], "ohd")
  me.definePartListAction(pPartListSubSet["handRight"], "ohd")
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
  me.definePartListAction(pPartListSubSet["handLeft"], "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(pExtraObjs[tSignObjID]) then
    pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, pExtraObjs, ["sprite": pSprite, "direction": pDirection, "signmember": tSignMem])
  pLeftHandUp = 1
end
