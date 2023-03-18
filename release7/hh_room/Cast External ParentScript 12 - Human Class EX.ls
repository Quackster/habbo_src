property pName, pClass, pCustom, pSex, pModState, pCtrlType, pBadge, pBuffer, pSprite, pMatteSpr, pMember, pShadowSpr, pShadowFix, pDefShadowMem, pPartList, pPartIndex, pFlipList, pUpdateRect, pDirection, pLastDir, pHeadDir, pLocX, pLocY, pLocH, pLocFix, pXFactor, pYFactor, pHFactor, pScreenLoc, pStartLScreen, pDestLScreen, pRestingHeight, pAnimCounter, pMoveStart, pMoveTime, pEyesClosed, pSync, pChanges, pAlphaColor, pCanvasSize, pColors, pPeopleSize, pMainAction, pMoving, pTalking, pCarrying, pSleeping, pDancing, pWaving, pTrading, pAnimating, pCurrentAnim, pGeometry, pExtraObjs, pInfoStruct, pCorrectLocZ, pPartClass, pQueuesWithObj, pPreviousLoc

on construct me
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
  pPartClass = value(getThread(#room).getComponent().getClassContainer().get("bodypart"))
  return 1
end

on deconstruct me
  pGeometry = VOID
  pPartList = []
  pInfoStruct = [:]
  releaseSprite(pSprite.spriteNum)
  releaseSprite(pMatteSpr.spriteNum)
  releaseSprite(pShadowSpr.spriteNum)
  if memberExists(pClass && pName && "Canvas") then
    removeMember(pClass && pName && "Canvas")
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
  if not memberExists(pClass && pName && "Canvas") then
    createMember(pClass && pName && "Canvas", #bitmap)
  end if
  tSize = pCanvasSize[#std]
  pMember = member(getmemnum(pClass && pName && "Canvas"))
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
  pInfoStruct[#Custom] = pCustom
  pInfoStruct[#image] = me.getPicture()
  pInfoStruct[#ctrl] = "furniture"
  pInfoStruct[#badge] = " "
  return 1
end

on setup me, tdata
  pName = tdata[#name]
  pClass = tdata[#class]
  pCustom = tdata[#Custom]
  pSex = tdata[#sex]
  pDirection = tdata[#direction][1]
  pHeadDir = pDirection
  pLastDir = pDirection
  pLocX = tdata[#x]
  pLocY = tdata[#y]
  pLocH = tdata[#h]
  pBadge = tdata[#badge]
  pPeopleSize = getVariable("human.size." & integer(pXFactor))
  if not pPeopleSize then
    error(me, "People size not found, using default!", #setup)
    pPeopleSize = "h"
  end if
  pCorrectLocZ = pPeopleSize = "h"
  pCanvasSize = value(getVariable("human.canvas." & pPeopleSize))
  if not pCanvasSize then
    error(me, "Canvas size not found, using default!", #setup)
    pCanvasSize = [#std: [64, 102, 32, -10], #lay: [89, 102, 32, -8]]
  end if
  tPartSymbols = tdata[#parts]
  if not me.setPartLists(tdata[#figure]) then
    return error(me, "Couldn't create part lists!", #setup)
  end if
  me.arrangeParts()
  me.refresh(pLocX, pLocY, pLocH, pDirection, pHeadDir)
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

on refresh me, tX, tY, tH, tDirHead, tDirBody
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return 1
  end if
  if pDancing then
    tDirHead = tDirBody
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
  pLocFix = point(-1, 2)
  call(#reset, pPartList)
  pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0.0
  if tDirBody <> pFlipList[tDirBody + 1] then
    if tDirBody <> tDirHead then
      case tDirHead of
        4:
          tDirHead = 2
        5:
          tDirHead = 1
        6:
          tDirHead = 4
        7:
          tDirHead = 5
      end case
    end if
  end if
  call(#defineDir, pPartList, tDirBody)
  call(#defineDirMultiple, pPartList, tDirHead, ["hd", "hr", "ey", "fc"])
  pDirection = tDirBody
  pHeadDir = tDirHead
  me.arrangeParts()
  if pExtraObjs.count > 0 then
    call(#refresh, pExtraObjs)
  end if
  pQueuesWithObj = 0
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
  if voidp(tImg) then
    tCanvas = image(64, 102, 32)
  else
    tCanvas = tImg
  end if
  tPartDefinition = getVariableValue("human.parts." & pPeopleSize)
  tTempPartList = []
  repeat with tPartSymbol in tPartDefinition
    if not voidp(pPartIndex[tPartSymbol]) then
      tTempPartList.append(pPartList[pPartIndex[tPartSymbol]])
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas)
  return me.flipImage(tCanvas)
end

on getInfo me
  if pCtrlType = EMPTY then
    pInfoStruct[#ctrl] = "furniture"
  else
    pInfoStruct[#ctrl] = pCtrlType
  end if
  pInfoStruct[#badge] = me.pBadge
  if pTrading then
    pInfoStruct[#Custom] = pCustom & RETURN & getText("human_trading", "Trading")
  else
    if pCarrying <> 0 then
      pInfoStruct[#Custom] = pCustom & RETURN & getText("human_carrying", "Carrying:") && pCarrying
    else
      pInfoStruct[#Custom] = pCustom
    end if
  end if
  return pInfoStruct
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
    otherwise:
      return 0
  end case
end

on setProperty me, tPropID, tValue
  case tPropID of
    otherwise:
      return 0
  end case
end

on closeEyes me
  if pMainAction = "lay" then
    call(#defineActMultiple, pPartList, "ley", ["ey"])
  else
    call(#defineActMultiple, pPartList, "eyb", ["ey"])
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me
  if pMainAction = "lay" then
    call(#defineActMultiple, pPartList, "lay", ["ey"])
  else
    call(#defineActMultiple, pPartList, "std", ["ey"])
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
      call(#defineActMultiple, pPartList, "lsp", ["hd", "hr", "fc"])
    else
      call(#defineActMultiple, pPartList, "spk", ["hd", "hr", "fc"])
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
    call(#doHandWorkLeft, pPartList, "wav")
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
  if (pFlipList[pDirection + 1] <> pDirection) or ((pDirection = 3) and (pHeadDir = 4)) or ((pDirection = 7) and (pHeadDir = 6)) then
    pMember.regPoint = point(pMember.image.width, pMember.regPoint[2])
    pShadowFix = pXFactor
    if not pSprite.flipH then
      pSprite.flipH = 1
      pMatteSpr.flipH = 1
      pShadowSpr.flipH = 1
    end if
  else
    pMember.regPoint = point(0, pMember.regPoint[2])
    pShadowFix = 0
    if pSprite.flipH then
      pSprite.flipH = 0
      pMatteSpr.flipH = 0
      pShadowSpr.flipH = 0
    end if
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
  pSprite.locZ = pScreenLoc[3] + tOffZ
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

on setPartLists me, tmodels
  tAction = pMainAction
  pPartList = []
  tPartDefinition = getVariableValue("human.parts." & pPeopleSize)
  repeat with i = 1 to tPartDefinition.count
    tPartSymbol = tPartDefinition[i]
    if voidp(tmodels[tPartSymbol]) then
      tmodels[tPartSymbol] = [:]
    end if
    if voidp(tmodels[tPartSymbol]["model"]) then
      tmodels[tPartSymbol]["model"] = "001"
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
  if pPartIndex["lg"] < pPartIndex["sh"] then
    tIndex1 = pPartIndex["lg"]
    tIndex2 = pPartIndex["sh"]
  else
    tIndex1 = pPartIndex["sh"]
    tIndex2 = pPartIndex["lg"]
  end if
  tLG = pPartList[pPartIndex["lg"]]
  tSH = pPartList[pPartIndex["sh"]]
  case pMainAction of
    "sit", "lay":
      if pFlipList[pDirection + 1] = 0 then
        pPartList[tIndex1] = tSH
        pPartList[tIndex2] = tLG
      else
        pPartList[tIndex1] = tLG
        pPartList[tIndex2] = tSH
      end if
    otherwise:
      pPartList[tIndex1] = tSH
      pPartList[tIndex2] = tLG
  end case
  tRS = pPartList[pPartIndex["rs"]]
  tRH = pPartList[pPartIndex["rh"]]
  tRI = pPartList[pPartIndex["ri"]]
  pPartList.deleteAt(pPartIndex["rs"])
  pPartList.deleteAt(pPartIndex["rh"])
  pPartList.deleteAt(pPartIndex["ri"])
  if (tRH.pActionRh = "drk") and ([0, 6].getPos(pDirection) <> 0) then
    pPartList.addAt(1, tRI)
    pPartList.append(tRH)
    pPartList.append(tRS)
  else
    if pDirection = 7 then
      pPartList.addAt(1, tRI)
      pPartList.addAt(2, tRH)
      pPartList.addAt(3, tRS)
    else
      pPartList.append(tRI)
      pPartList.append(tRH)
      pPartList.append(tRS)
    end if
  end if
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
  if pLastDir = pDirection then
    return 
  end if
  pLastDir = pDirection
  tLS = pPartList[pPartIndex["ls"]]
  tLH = pPartList[pPartIndex["lh"]]
  tLI = pPartList[pPartIndex["li"]]
  pPartList.deleteAt(pPartIndex["ls"])
  pPartList.deleteAt(pPartIndex["lh"])
  pPartList.deleteAt(pPartIndex["li"])
  case pDirection of
    3:
      pPartList.addAt(8, tLI)
      pPartList.addAt(9, tLH)
      pPartList.addAt(10, tLS)
    otherwise:
      pPartList.addAt(1, tLI)
      pPartList.addAt(2, tLH)
      pPartList.addAt(3, tLS)
  end case
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

on action_mv me, tProps
  pMainAction = "wlk"
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = float(tloc.item[3])
  the itemDelimiter = tDelim
  pMoveStart = the milliSeconds
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  call(#defineActMultiple, pPartList, "wlk", ["bd", "lg", "lh", "rh", "ls", "rs", "sh"])
end

on action_sld me, tProps
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = float(tloc.item[3])
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
  call(#defineActMultiple, pPartList, "sit", ["bd", "lg", "sh"])
  pMainAction = "sit"
  pRestingHeight = float(tProps.word[2]) - 1.0
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  tIsInQueue = integer(tProps.word[3])
  pQueuesWithObj = tIsInQueue
  me.arrangeParts()
end

on action_lay me, tProps
  pMainAction = "lay"
  pCarrying = 0
  pRestingHeight = float(tProps.word[2]) - 1.0
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  case pFlipList[pDirection + 1] of
    2:
      pScreenLoc = pScreenLoc + [10, 30, 2000]
    0:
      pScreenLoc = pScreenLoc + [-47, 32, 2000]
  end case
  pLocFix = point(30, -10)
  call(#layDown, pPartList)
  if pDirection = 0 then
    pDirection = 4
  end if
  call(#defineDir, pPartList, pDirection)
  me.arrangeParts()
end

on action_carryd me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "crr")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "crr")
      pPartList[pPartIndex["ri"]].setModel(tCarryItm)
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
    call(#doHandWorkRight, pPartList, "crr")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "crr")
      pPartList[pPartIndex["ri"]].setModel(tCarryItm)
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
    call(#doHandWorkRight, pPartList, "drk")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    me.arrangeParts()
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "drk")
      pPartList[pPartIndex["ri"]].setModel(tCarryItm)
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
    call(#doHandWorkRight, pPartList, "drk")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    me.arrangeParts()
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "drk")
      pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    end if
    me.arrangeParts()
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
    call(#doHandWorkRight, pPartList, "crr")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, tItem)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "004"
      call(#doHandWorkRight, pPartList, "crr")
      pPartList[pPartIndex["ri"]].setModel(tCarryItm)
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
    call(#doHandWorkRight, pPartList, "drk")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.word[2..tProps.word.count]
      tCarryItm = "004"
      call(#doHandWorkRight, pPartList, "drk")
      pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    end if
  end if
end

on action_talk me, tProps
  pTalking = 1
end

on action_gest me, tProps
  if pPeopleSize = "sh" then
    return 
  end if
  tList = ["ey", "fc"]
  tGesture = tProps.word[2]
  if tGesture = "spr" then
    tGesture = "srp"
  end if
  if pMainAction = "lay" then
    tGesture = "l" & tGesture.char[1..2]
    call(#defineActMultiple, pPartList, tGesture, tList)
  else
    call(#defineActMultiple, pPartList, tGesture, tList)
    if tGesture = "ohd" then
      pPartList[pPartIndex["hd"]].defineAct(tGesture)
      pPartList[pPartIndex["hr"]].defineAct(tGesture)
    end if
  end if
end

on action_wave me, tProps
  pWaving = 1
end

on action_dance me, tProps
  pDancing = 1
  tStyle = tProps.word[2]
  if tStyle = EMPTY then
    tStyle = "dance.aero"
  end if
  me.startAnimation(tStyle)
end

on action_ohd me
  call(#defineActMultiple, pPartList, "ohd", ["hd", "fc", "ey", "hr"])
  call(#doHandWorkRight, pPartList, "ohd")
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
  call(#doHandWorkLeft, me.pPartList, "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(pExtraObjs[tSignObjID]) then
    pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, pExtraObjs, ["sprite": pSprite, "direction": pDirection, "signmember": tSignMem])
end
