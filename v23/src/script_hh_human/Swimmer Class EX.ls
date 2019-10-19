property pPelleFigure, pFigure, pSwim, pSwimAnimCount, pSwimAndStay, pPhFigure

on define me, tdata 
  me.pPartClass = value(getThread(#room).getComponent().getClassContainer().GET("swimpart"))
  pPhFigure = tdata.getAt(#phfigure)
  pFigure = tdata.getAt(#figure)
  pSwimAnimCount = 0
  pSwimAndStay = 0
  callAncestor(#define, [me], tdata)
  if voidp(me.getProp(#pCanvasSize, #swm)) then
    me.setProp(#pCanvasSize, #swm, [60, 60, 32, -8])
  end if
  tSubSetList = ["swim"]
  if voidp(me.pPartListSubSet) then
    me.pPartListSubSet = [:]
  end if
  repeat while tSubSetList <= undefined
    tSubSet = getAt(undefined, tdata)
    tSetName = "human.partset." & tSubSet & "." & me.pPeopleSize
    if not variableExists(tSetName) then
      me.setProp(#pPartListSubSet, tSubSet, [])
      error(me, tSetName && "not found!", #define, #major)
    else
      me.setProp(#pPartListSubSet, tSubSet, getVariableValue(tSetName))
    end if
  end repeat
  return(1)
end

on changeFigureAndData me, tdata 
  tdata.setAt(#figure, me.fixSwimmerFigure(tdata.getAt(#figure)))
  callAncestor(#changeFigureAndData, [me], tdata)
end

on getPelleFigure me 
  return(pPelleFigure)
end

on getFigure me 
  return(pFigure)
end

on isSwimming me 
  return(pSwim)
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
    me.pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, me.pRestingHeight)
  else
    me.pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  call(#defineDir, me.pPartList, tDirBody)
  call(#defineDirMultiple, me.pPartList, tDirHead, me.getProp(#pPartListSubSet, "head"))
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  me.pRestingHeight = 0
  me.resetAction()
  if me.count(#pExtraObjs) > 0 then
    call(#Refresh, me.pExtraObjs)
  end if
  return(1)
end

on Refresh me, tX, tY, tH 
  me.arrangeParts()
  me.pSync = 0
  me.pChanges = 1
end

on getPartListNameBase me 
  return("swimmer.parts")
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
  i = 1
  repeat while i <= me.count(#pPartList)
    tPartObj = me.getProp(#pPartList, i)
    tPartSymbol = tPartObj.pPart
    tPartModel = tPartObj.getModel()
    tPartColor = tPartObj.getColor()
    if tPartModel.count >= 1 then
      pPelleFigure.addProp(tPartSymbol, ["model":tPartModel.getAt(1), "color":tPartColor])
    end if
    if me.getPropRef(#pPartListSubSet, "head").findPos(tPartSymbol) then
      tPartObj.setUnderWater(0)
    else
      tPartObj.setUnderWater(1)
    end if
    i = 1 + i
  end repeat
  me.pDirection = tDirectionOld
  me.pMainAction = tActionOld
  me.arrangeParts()
  if not me.isSwimming() then
    me.resumeAnimation()
  end if
  return(1)
end

on prepare me 
  if pSwim then
    if me.pMoving then
      pSwimAndStay = 0
      me.pMainAction = "swm"
      me.definePartListAction(me.getProp(#pPartListSubSet, "swim"), "swm")
    else
      pSwimAndStay = 1
      me.pMainAction = "sws"
      me.definePartListAction(me.getProp(#pPartListSubSet, "swim"), "sws")
    end if
    tSwimAnim = [0, 1, 2, 3, 2, 1]
    pSwimAnimCount = pSwimAnimCount + 1
    if pSwimAnimCount > tSwimAnim.count then
      pSwimAnimCount = 1
    end if
    me.pAnimCounter = tSwimAnim.getAt(pSwimAnimCount)
    if objectExists(#waterripples) and random(2) = 1 then
      tPos = me.getTileCenter()
      tPos.setAt(1, tPos.getAt(1) - me.pXFactor)
      tPos.setAt(2, tPos.getAt(2) - me.pXFactor)
      getObject(#waterripples).NewRipple(tPos)
    end if
    me.pChanges = 1
  else
    if me.pMoving then
      me.definePartListAction(me.getProp(#pPartListSubSet, "walk"), "wlk")
    end if
    me.pAnimCounter = (me.pAnimCounter + 1 mod 4)
  end if
  if me.pEyesClosed and not me.pSleeping then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if me.pTalking and random(3) > 1 then
    if me.pMainAction = "lay" then
      me.definePartListAction(me.getProp(#pPartListSubSet, "speak"), "lsp")
    else
      me.definePartListAction(me.getProp(#pPartListSubSet, "speak"), "spk")
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
    tFactor = (float(the milliSeconds - me.pMoveStart) / (me.pMoveTime * 1))
    if tFactor > 1 then
      tFactor = 1
    end if
    me.pScreenLoc = ((me.pDestLScreen - me.pStartLScreen * 1) * tFactor) + me.pStartLScreen
    me.pChanges = 1
  end if
  if me.pWaving then
    me.definePartListAction(me.getProp(#pPartListSubSet, "handLeft"), "wav")
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
    return()
  end if
  me.pChanges = 0
  if me.pMainAction = "sit" then
    pShadowSpr.castNum = getmemnum(me.pPeopleSize & "_sit_sd_1_" & me.getProp(#pFlipList, me.pDirection + 1) & "_0")
  else
    if pShadowSpr.member <> me.pDefShadowMem then
      me.castNum = pDefShadowMem.number
    end if
  end if
  if me.pMainAction = "swm" then
    tSize = me.getProp(#pCanvasSize, #swm)
  else
    tSize = me.getProp(#pCanvasSize, #std)
  end if
  if me or pBuffer.height <> tSize.getAt(2) then
    pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    pMember.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
    pSprite.width = tSize.getAt(1)
    pSprite.height = tSize.getAt(2)
    pMatteSpr.width = tSize.getAt(1)
    pMatteSpr.height = tSize.getAt(2)
    me.pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  end if
  pSprite.flipH = 0
  pMatteSpr.flipH = 0
  pShadowSpr.flipH = 0
  me.pShadowFix = 0
  0.regPoint = point(me, pMember.getProp(#regPoint, 2))
  pSprite.locH = me.getProp(#pScreenLoc, 1)
  pSprite.locV = me.getProp(#pScreenLoc, 2)
  pSprite.locZ = me.getProp(#pScreenLoc, 3) + 2
  me.updateTypingSpriteLoc()
  me.loc = pSprite.loc
  me.locZ = pSprite.locZ + 1
  me.loc = pSprite.loc + [me.pShadowFix, 0]
  me.locZ = pSprite.locZ - 3
  if me.pMainAction = "swm" then
    me.locH = pSprite.locH - 12
    me.locH = pSprite.locH
  end if
  pUpdateRect = rect(0, 0, 0, 0)
  me.fill(pBuffer.rect, me.pAlphaColor)
  if me.pMainAction = "swm" then
    tRectMod = rect(14, 0, 14, 0)
  else
    tRectMod = rect(0, 0, 0, 0)
  end if
  call(#update, me.pPartList, 0, tRectMod)
  image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
end

on isInSwimsuit me 
  return(1)
end

on fixSwimmerFigure me, tFigure 
  tPredefinedParts = ["rh", "lh", "ch", "bd"]
  repeat while tPredefinedParts <= undefined
    tPrePart = getAt(undefined, tFigure)
    tOccurrenceCount = 0
    tItemNo = 1
    repeat while tItemNo <= tFigure.count
      tPartType = tFigure.getPropAt(tItemNo)
      if tPartType = tPrePart then
        tOccurrenceCount = tOccurrenceCount + 1
        if tOccurrenceCount > 1 then
          tFigure.deleteAt(tItemNo)
          tItemNo = tItemNo - 1
        end if
      end if
      tItemNo = 1 + tItemNo
    end repeat
  end repeat
  if me.pSex = "F" then
    tphModel = "s01"
  else
    tphModel = "s02"
  end if
  tColor = pPhFigure.getAt("color")
  tFigure.setAt("ch", ["model":tphModel, "color":tColor])
  repeat while tPredefinedParts <= undefined
    f = getAt(undefined, tFigure)
    if voidp(tFigure.getAt(f)) then
      tFigure.setAt(f, ["model":"1", "color":rgb("#EEEEEE")])
    end if
  end repeat
  tBodyModel = tFigure.getAt("bd").getAt("model")
  if ilk(tBodyModel) <> #string then
    tBodyModel = ""
  end if
  repeat while tBodyModel.length < 3
    tBodyModel = "0" & tBodyModel
  end repeat
  tFigure.getAt("bd").setAt("model", "s" & tBodyModel.getProp(#char, 2, 3))
  tFigure.getAt("lh").setAt("model", "s" & tBodyModel.getProp(#char, 2, 3))
  tFigure.getAt("rh").setAt("model", "s" & tBodyModel.getProp(#char, 2, 3))
  return(tFigure)
end

on action_swim me, props 
  me.stopAnimation()
  pSwim = 1
end

on action_mv me, tProps 
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = getLocalFloat(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  me.pStartLScreen = pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
end
