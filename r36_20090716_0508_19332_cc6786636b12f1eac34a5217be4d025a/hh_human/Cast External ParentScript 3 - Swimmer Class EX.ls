property pPhFigure, pPelleFigure, pFigure, pSwim, pSwimAndStay, pSwimAnimCount

on define me, tdata
  me.pPartClass = value(getThread(#room).getComponent().getClassContainer().GET("swimpart"))
  pPhFigure = tdata[#phfigure]
  pFigure = tdata[#figure]
  pSwimAnimCount = 0
  pSwimAndStay = 0
  callAncestor(#define, [me], tdata)
  if voidp(me.pCanvasSize[#swm]) then
    me.pCanvasSize[#swm] = [60, 60, 32, -8]
  end if
  tSubSetList = ["swim"]
  if voidp(me.pPartListSubSet) then
    me.pPartListSubSet = [:]
  end if
  repeat with tSubSet in tSubSetList
    tSetName = "human.partset." & tSubSet & "." & me.pPeopleSize
    if not variableExists(tSetName) then
      me.pPartListSubSet[tSubSet] = []
      error(me, tSetName && "not found!", #define, #major)
      next repeat
    end if
    me.pPartListSubSet[tSubSet] = getVariableValue(tSetName)
  end repeat
  return 1
end

on changeFigureAndData me, tdata
  tdata[#figure] = me.fixSwimmerFigure(tdata[#figure])
  callAncestor(#changeFigureAndData, [me], tdata)
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
  me.pFx = 0
  pSwim = 0
  pSwimAndStay = 0
  repeat with i = 1 to me.pExtraObjsActive.count
    me.pExtraObjsActive[i] = 0
  end repeat
  me.pLocFix = point(0, 0)
  call(#reset, me.pPartList)
  if me.pMainAction = "sit" then
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, me.pRestingHeight)
  else
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  call(#defineDir, me.pPartList, tDirBody)
  call(#defineDirMultiple, me.pPartList, tDirHead, me.pPartListSubSet["head"])
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  me.pRestingHeight = 0.0
  me.resetAction()
  if me.pExtraObjs.count > 0 then
    call(#Refresh, me.pExtraObjs)
  end if
  return 1
end

on Refresh me, tX, tY, tH
  me.arrangeParts()
  me.pSync = 0
  me.pChanges = 1
  i = 1
  repeat while i <= me.pExtraObjsActive.count
    if me.pExtraObjsActive[i] = 0 then
      me.pExtraObjs[i].deconstruct()
      me.pExtraObjs.deleteAt(i)
      me.pExtraObjsActive.deleteAt(i)
      next repeat
    end if
    i = i + 1
  end repeat
end

on getPartListNameBase me
  return "swimmer.parts"
end

on setPartLists me, tmodels
  tmodels = me.fixSwimmerFigure(tmodels)
  callAncestor(#setPartLists, [me], tmodels)
  pPelleFigure = [:]
  tDirectionOld = me.pDirection
  tActionOld = me.pMainAction
  me.pDirection = 3
  me.pMainAction = "std"
  me.arrangeParts()
  repeat with i = 1 to me.pPartList.count
    tPartObj = me.pPartList[i]
    tPartSymbol = tPartObj.pPart
    tPartModel = tPartObj.getModel()
    tPartColor = tPartObj.getColor()
    if tPartModel.count >= 1 then
      pPelleFigure.addProp(tPartSymbol, ["model": tPartModel[1], "color": tPartColor])
    end if
    if me.pPartListSubSet["head"].findPos(tPartSymbol) then
      tPartObj.setUnderWater(0)
      next repeat
    end if
    tPartObj.setUnderWater(1)
  end repeat
  me.pDirection = tDirectionOld
  me.pMainAction = tActionOld
  me.arrangeParts()
  if not me.isSwimming() then
    me.resumeAnimation()
  end if
  return 1
end

on prepare me
  if pSwim then
    if me.pMoving then
      pSwimAndStay = 0
      me.pMainAction = "swm"
      me.definePartListAction(me.pPartListSubSet["swim"], "swm")
    else
      pSwimAndStay = 1
      me.pMainAction = "sws"
      me.definePartListAction(me.pPartListSubSet["swim"], "sws")
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
      me.definePartListAction(me.pPartListSubSet["walk"], "wlk")
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
      me.definePartListAction(me.pPartListSubSet["speak"], "lsp")
    else
      me.definePartListAction(me.pPartListSubSet["speak"], "spk")
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
    me.definePartListAction(me.pPartListSubSet["handLeft"], "wav")
    me.pChanges = 1
  end if
  if me.pDancing then
    me.pLocFix = point(0, 2)
    me.pAnimating = 1
    me.pChanges = 1
  end if
end

on render me
  call(#update, me.pExtraObjs)
  if not me.pChanges then
    return 
  end if
  me.pChanges = 0
  if me.pMainAction = "sit" then
    me.pShadowSpr.castNum = getmemnum(me.pPeopleSize & "_sit_sd_1_" & me.pFlipList[me.pDirection + 1] & "_0")
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
  me.pSprite.flipH = 0
  me.pMatteSpr.flipH = 0
  me.pShadowSpr.flipH = 0
  me.pShadowFix = 0
  me.pMember.regPoint = point(0, me.pMember.regPoint[2])
  me.pSprite.locH = me.pScreenLoc[1]
  me.pSprite.locV = me.pScreenLoc[2]
  me.pSprite.locZ = me.pScreenLoc[3] + 2
  me.updateTypingSpriteLoc()
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
  if me.pMainAction = "swm" then
    tRectMod = rect(14, 0, 14, 0)
  else
    tRectMod = rect(0, 0, 0, 0)
  end if
  call(#update, me.pPartList, 0, tRectMod)
  me.pMember.image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
end

on isInSwimsuit me
  return 1
end

on fixSwimmerFigure me, tFigure
  tPredefinedParts = ["rh", "lh", "ch", "bd"]
  repeat with tPrePart in tPredefinedParts
    tOccurrenceCount = 0
    repeat with tItemNo = 1 to tFigure.count
      tPartType = tFigure.getPropAt(tItemNo)
      if tPartType = tPrePart then
        tOccurrenceCount = tOccurrenceCount + 1
        if tOccurrenceCount > 1 then
          tFigure.deleteAt(tItemNo)
          tItemNo = tItemNo - 1
        end if
      end if
    end repeat
  end repeat
  if me.pSex = "F" then
    tphModel = "s01"
  else
    tphModel = "s02"
  end if
  tColor = pPhFigure["color"]
  tFigure["ch"] = ["model": tphModel, "color": tColor]
  repeat with f in ["bd", "lh", "rh"]
    if voidp(tFigure[f]) then
      tFigure[f] = ["model": "1", "color": rgb("#EEEEEE")]
    end if
  end repeat
  tBodyModel = tFigure["bd"]["model"]
  if ilk(tBodyModel) <> #string then
    tBodyModel = EMPTY
  end if
  repeat while tBodyModel.length < 3
    tBodyModel = "0" & tBodyModel
  end repeat
  tFigure["bd"]["model"] = "s" & tBodyModel.char[2..3]
  tFigure["lh"]["model"] = "s" & tBodyModel.char[2..3]
  tFigure["rh"]["model"] = "s" & tBodyModel.char[2..3]
  return tFigure
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

on action_fx me, tProps
  return 1
end

on persist_fx me, ttype
  return 1
end
