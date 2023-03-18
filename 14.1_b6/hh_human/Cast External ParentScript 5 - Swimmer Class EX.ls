property pPhFigure, pPelleFigure, pFigure, pSwim, pSwimAndStay, pSwimAnimCount

on define me, tdata
  pPhFigure = tdata[#phfigure]
  pFigure = tdata[#figure]
  pSwimAnimCount = 0
  pSwimAndStay = 0
  me.setup(tdata)
  if not memberExists(me.getCanvasName()) then
    createMember(me.getCanvasName(), #bitmap)
  end if
  if voidp(me.pCanvasSize[#swm]) then
    me.pCanvasSize[#swm] = [60, 60, 32, -8]
  end if
  tSize = me.pCanvasSize[#std]
  me.pMember = member(getmemnum(me.getCanvasName()))
  me.pMember.image = image(tSize[1], tSize[2], tSize[3])
  me.pMember.regPoint = point(0, me.pMember.image.height + tSize[4])
  me.pBuffer = me.pMember.image.duplicate()
  me.pSprite = sprite(reserveSprite(me.getID()))
  me.pSprite.castNum = me.pMember.number
  me.pSprite.width = me.pMember.width
  me.pSprite.height = me.pMember.height
  me.pSprite.ink = 36
  me.pMatteSpr = sprite(reserveSprite(me.getID()))
  me.pMatteSpr.castNum = me.pMember.number
  me.pMatteSpr.ink = 8
  me.pMatteSpr.blend = 0
  me.pShadowSpr = sprite(reserveSprite(me.getID()))
  me.pShadowSpr.blend = 10
  me.pShadowSpr.ink = 8
  me.pShadowFix = 0
  me.pDefShadowMem = member(getmemnum(me.pPeopleSize & "_std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(me.pMatteSpr.spriteNum, me.getID())
  me.pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  me.pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  me.pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  setEventBroker(me.pShadowSpr.spriteNum, me.getID())
  me.pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  me.pInfoStruct[#name] = me.pName
  me.pInfoStruct[#class] = me.pClass
  me.pInfoStruct[#custom] = me.pCustom
  me.pInfoStruct[#image] = me.getPicture()
  me.pInfoStruct[#ctrl] = "furniture"
  me.pInfoStruct[#badge] = " "
  return 1
end

on getPelleFigure me
  return pPelleFigure
end

on getFigure me
  return pFigure
end

on isSwimming me
  return pSwim
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody
  me.pMoving = 0
  me.pDancing = 0
  me.pTalking = 0
  me.pCarrying = 0
  me.pWaving = 0
  me.pTrading = 0
  me.pCtrlType = 0
  me.pAnimating = 0
  me.pModState = 0
  me.pSleeping = 0
  pSwim = 0
  pSwimAndStay = 0
  me.pLocFix = point(0, 0)
  call(#reset, me.pPartList)
  if me.pMainAction = "sit" then
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, me.pRestingHeight)
  else
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  if tDirBody <> me.pFlipList[tDirBody + 1] then
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
  call(#defineDir, me.pPartList, tDirBody)
  call(#defineDirMultiple, me.pPartList, tDirHead, ["hd", "hr", "ey", "fc"])
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pMainAction = "std"
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  me.pRestingHeight = 0.0
  if me.pExtraObjs.count > 0 then
    call(#Refresh, me.pExtraObjs)
  end if
  return 1
end

on Refresh me, tX, tY, tH
  me.arrangeParts()
  me.pSync = 0
  me.pChanges = 1
end

on deconstructPartList me
  repeat with tPart in me.pPartList
    tPart.deconstruct()
  end repeat
end

on setPartLists me, tmodels
  tAction = me.pMainAction
  if me.pPartList.ilk = #list then
    me.deconstructPartList()
  end if
  me.pPartList = []
  if me.pSex = "F" then
    tphModel = "s01"
  else
    tphModel = "s02"
  end if
  tColor = pPhFigure["color"]
  tmodels["ch"] = ["model": tphModel, "color": tColor]
  repeat with f in ["bd", "lh", "rh"]
    if voidp(tmodels[f]) then
      tmodels[f] = ["model": "001", "color": rgb("#EEEEEE")]
    end if
  end repeat
  tmodels["bd"]["model"] = "s" & tmodels["bd"]["model"].char[2..3]
  tmodels["lh"]["model"] = "s" & tmodels["bd"]["model"].char[2..3]
  tmodels["rh"]["model"] = "s" & tmodels["bd"]["model"].char[2..3]
  pPelleFigure = tmodels
  tPartDefinition = ["li", "lh", "bd", "ch", "hd", "fc", "ey", "hr", "ri", "rh"]
  repeat with i = 1 to tPartDefinition.count
    tPartSymbol = tPartDefinition[i]
    if voidp(tmodels[tPartSymbol]) then
      tmodels[tPartSymbol] = [:]
    end if
    if voidp(tmodels[tPartSymbol]["model"]) then
      tmodels[tPartSymbol]["model"] = "001"
    end if
    if voidp(tmodels[tPartSymbol]["color"]) then
      tmodels[tPartSymbol]["color"] = rgb("#EEEEEE")
    end if
    if (tPartSymbol = "fc") and (tmodels[tPartSymbol]["model"] <> "001") and (me.pXFactor < 33) then
      tmodels[tPartSymbol]["model"] = "001"
    end if
    tPartCls = value(getThread(#room).getComponent().getClassContainer().GET("swimpart"))
    tPartObj = createObject(#temp, tPartCls)
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
    tPartObj.define(tPartSymbol, tmodels[tPartSymbol]["model"], tColor, me.pDirection, tAction, me)
    me.pPartList.add(tPartObj)
    me.pColors.setaProp(tPartSymbol, tColor)
  end repeat
  me.pPartIndex = [:]
  repeat with i = 1 to me.pPartList.count
    me.pPartIndex[me.pPartList[i].pPart] = i
  end repeat
  if not me.isSwimming() then
    me.resumeAnimation()
  end if
  return 1
end

on arrangeParts me
  tRH = me.pPartList[me.pPartIndex["rh"]]
  tRI = me.pPartList[me.pPartIndex["ri"]]
  me.pPartList.deleteAt(me.pPartIndex["rh"])
  me.pPartList.deleteAt(me.pPartIndex["ri"])
  if (tRH.pActionRh = "drk") and ([0, 6].getPos(me.pDirection) <> 0) then
    me.pPartList.addAt(8, tRI)
    me.pPartList.addAt(9, tRH)
  else
    if me.pDirection = 7 then
      me.pPartList.addAt(1, tRI)
      me.pPartList.addAt(2, tRH)
    else
      me.pPartList.append(tRI)
      me.pPartList.append(tRH)
    end if
  end if
  repeat with i = 1 to me.pPartList.count
    me.pPartIndex[me.pPartList[i].pPart] = i
  end repeat
  if me.pLastDir = me.pDirection then
    return 
  end if
  me.pLastDir = me.pDirection
  tLH = me.pPartList[me.pPartIndex["lh"]]
  tLI = me.pPartList[me.pPartIndex["li"]]
  me.pPartList.deleteAt(me.pPartIndex["lh"])
  me.pPartList.deleteAt(me.pPartIndex["li"])
  case me.pDirection of
    3:
      me.pPartList.addAt(8, tLI)
      me.pPartList.addAt(9, tLH)
    otherwise:
      me.pPartList.addAt(1, tLI)
      me.pPartList.addAt(2, tLH)
  end case
  repeat with i = 1 to me.pPartList.count
    me.pPartIndex[me.pPartList[i].pPart] = i
  end repeat
end

on prepare me
  if pSwim then
    if me.pMoving then
      pSwimAndStay = 0
      me.pMainAction = "swm"
      call(#defineActMultiple, me.pPartList, "swm", ["bd", "lh", "ch", "rh"])
    else
      pSwimAndStay = 1
      me.pMainAction = "sws"
      call(#defineActMultiple, me.pPartList, "sws", ["bd", "lh", "ch", "rh"])
    end if
    tSwimAnim = [0, 1, 2, 3, 2, 1]
    pSwimAnimCount = pSwimAnimCount + 1
    if pSwimAnimCount > tSwimAnim.count then
      pSwimAnimCount = 1
    end if
    me.pAnimCounter = tSwimAnim[pSwimAnimCount]
    if objectExists(#waterripples) and (random(2) = 1) then
      tPos = me.getTileCenter()
      tPos[1] = tPos[1] - me.pXFactor
      tPos[2] = tPos[2] - me.pXFactor
      getObject(#waterripples).NewRipple(tPos)
    end if
    me.pChanges = 1
  else
    if me.pMoving then
      call(#defineActMultiple, me.pPartList, "wlk", ["bd", "lh", "rh"])
    end if
    me.pAnimCounter = (me.pAnimCounter + 1) mod 4
  end if
  if me.pEyesClosed and not me.pSleeping then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if me.pTalking and (random(3) > 1) then
    if me.pMainAction = "lay" then
      call(#defineActMultiple, me.pPartList, "lsp", ["hd", "hr", "fc"])
    else
      call(#defineActMultiple, me.pPartList, "spk", ["hd", "hr", "fc", "ey"])
    end if
    me.pChanges = 1
  end if
  if not pSwim then
    if me.pMoving or pSwimAndStay then
      me.pLocFix = point(0, me.pAnimCounter > 1)
    end if
  else
    me.pDancing = 0
    if pSwimAndStay then
      me.pLocFix = point(0, me.pAnimCounter > 1)
    else
      me.pLocFix = point(0, 0)
    end if
  end if
  if me.pMoving then
    tFactor = float(the milliSeconds - me.pMoveStart) / (me.pMoveTime * 1.0)
    if tFactor > 1.0 then
      tFactor = 1.0
    end if
    me.pScreenLoc = ((me.pDestLScreen - me.pStartLScreen) * 1.0 * tFactor) + me.pStartLScreen
    me.pChanges = 1
  end if
  if me.pWaving then
    call(#doHandWorkLeft, me.pPartList, "wav")
    me.pChanges = 1
  end if
  if me.pDancing then
    me.pLocFix = point(0, 2)
    me.pAnimating = 1
    me.pChanges = 1
  end if
end

on render me
  if not me.pChanges then
    return 
  end if
  me.pChanges = 0
  if me.pMainAction = "sit" then
    me.pShadowSpr.castNum = getmemnum(me.pPeopleSize & "_sit_sd_001_" & me.pFlipList[me.pDirection + 1] & "_0")
  else
    if me.pShadowSpr.member <> me.pDefShadowMem then
      me.pShadowSpr.castNum = me.pDefShadowMem.number
    end if
  end if
  if me.pMainAction = "swm" then
    tSize = me.pCanvasSize[#swm]
  else
    tSize = me.pCanvasSize[#std]
  end if
  if (me.pBuffer.width <> tSize[1]) or (me.pBuffer.height <> tSize[2]) then
    me.pMember.image = image(tSize[1], tSize[2], tSize[3])
    me.pMember.regPoint = point(0, tSize[2] + tSize[4])
    me.pSprite.width = tSize[1]
    me.pSprite.height = tSize[2]
    me.pMatteSpr.width = tSize[1]
    me.pMatteSpr.height = tSize[2]
    me.pBuffer = image(tSize[1], tSize[2], tSize[3])
  end if
  if (me.pFlipList[me.pDirection + 1] <> me.pDirection) or ((me.pDirection = 3) and (me.pHeadDir = 4)) or ((me.pDirection = 7) and (me.pHeadDir = 6)) then
    if not me.pSprite.flipH then
      me.pSprite.flipH = 1
      me.pMatteSpr.flipH = 1
      me.pShadowSpr.flipH = 1
      me.pShadowFix = me.pXFactor
    end if
    me.pMember.regPoint = point(me.pMember.image.width, me.pMember.regPoint[2])
  else
    if me.pSprite.flipH then
      me.pSprite.flipH = 0
      me.pMatteSpr.flipH = 0
      me.pShadowSpr.flipH = 0
      me.pShadowFix = 0
    end if
    me.pMember.regPoint = point(0, me.pMember.regPoint[2])
  end if
  me.pSprite.locH = me.pScreenLoc[1]
  me.pSprite.locV = me.pScreenLoc[2]
  me.pSprite.locZ = me.pScreenLoc[3] + 2
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = me.pSprite.locZ + 1
  me.pShadowSpr.loc = me.pSprite.loc + [me.pShadowFix, 0]
  me.pShadowSpr.locZ = me.pSprite.locZ - 3
  if me.pMainAction = "swm" then
    me.pSprite.locH = me.pSprite.locH - 12
    me.pMatteSpr.locH = me.pSprite.locH
  end if
  pUpdateRect = rect(0, 0, 0, 0)
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  if me.pMainAction = "swm" then
    me.pUpdateRect = me.pUpdateRect + [14, 0, 14, 0]
  end if
  me.pMember.image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
end

on action_swim me, props
  me.stopAnimation()
  pSwim = 1
end

on action_mv me, tProps
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = getLocalFloat(tloc.item[3])
  the itemDelimiter = tDelim
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
end

on isInSwimsuit me
  return 1
end
