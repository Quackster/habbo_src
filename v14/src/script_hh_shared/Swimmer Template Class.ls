property pPelleFigure, pFigure, pPhFigure, pSwim, pSwimAnimCount, pSwimAndStay

on define me, tdata 
  pValid = 1
  pPhFigure = tdata.getAt(#phfigure)
  pFigure = tdata.getAt(#figure)
  pSwimAnimCount = 0
  pSwimAndStay = 0
  me.pClass = tdata.getAt(#class)
  me.pSex = tdata.getAt(#sex)
  me.pDirection = tdata.getAt(#direction).getAt(1)
  me.pLastDir = me.pDirection
  me.pLocX = tdata.getAt(#x)
  me.pLocY = tdata.getAt(#y)
  me.pLocH = tdata.getAt(#h)
  me.pPeopleSize = getVariable("human.size." & integer(me.pXFactor))
  if not me.pPeopleSize then
    error(me, "People size not found, using default!", #define, #minor)
    me.pPeopleSize = "sh"
  end if
  me.pCanvasSize = value(getVariable("human.canvas." & me.pPeopleSize))
  me.pCanvasSize.addProp(#swm, [60, 60, 32, -8])
  if not me.pCanvasSize then
    error(me, "Canvas size not found, using default!", #define, #minor)
    me.pCanvasSize = [#std:[64, 102, 32, -8], #lay:[89, 102, 32, -4]]
  end if
  if (me.pCanvasName = void()) then
    me.pCanvasName = me.pClass && me.pName && me.getID() && "Canvas"
  end if
  if not memberExists(me.pCanvasName) then
    createMember(me.pCanvasName, #bitmap)
  end if
  tSize = me.getProp(#pCanvasSize, #std)
  me.pMember = member(getmemnum(me.pCanvasName))
  me.pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  me.pMember.regPoint = point(0, (me.pMember.image.height + tSize.getAt(4)))
  me.pBuffer = me.pMember.image
  me.pSprite = sprite(reserveSprite(me.getID()))
  me.pSprite.member = me.pMember
  me.pSprite.ink = 36
  me.pMatteSpr = sprite(reserveSprite(me.getID()))
  me.pMatteSpr.member = me.pMember
  me.pMatteSpr.ink = 8
  me.pMatteSpr.blend = 0
  me.pShadowSpr = sprite(reserveSprite(me.getID()))
  me.pShadowSpr.blend = 10
  me.pShadowSpr.ink = 8
  me.pShadowFix = 0
  me.pDefShadowMem = member(getmemnum(me.pPeopleSize & "_std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(me.pMatteSpr.spriteNum, me.getID())
  call(#registerProcedure, me.pMatteSpr.scriptInstanceList, #eventProcUserObj, tTargetID, #mouseDown)
  call(#registerProcedure, me.pMatteSpr.scriptInstanceList, #eventProcUserRollOver, tTargetID, #mouseEnter)
  call(#registerProcedure, me.pMatteSpr.scriptInstanceList, #eventProcUserRollOver, tTargetID, #mouseLeave)
  tPartSymbols = tdata.getAt(#parts)
  if not setPartLists(me, tdata.getAt(#figure)) then
    return(error(me, "Couldn't create part lists!", #define, #major))
  end if
  me.arrangeParts()
  me.Refresh(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
  return TRUE
end

on getPelleFigure me 
  return(pPelleFigure)
end

on getFigure me 
  return(pFigure)
end

on Refresh me, tX, tY, tH, tDirHead, tDirBody 
  me.pMoving = 0
  me.pDancing = 0
  me.pTalking = 0
  me.pCarrying = 0
  me.pWaving = 0
  me.pTrading = 0
  me.pCtrlType = 0
  me.pAnimating = 0
  me.pModState = 0
  pSwim = 0
  pSwimAndStay = 0
  pSign = 0
  me.pLocFix = point(0, 0)
  call(#reset, me.pPartList)
  if (me.pMainAction = "sit") then
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, me.pRestingHeight)
  else
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  call(#defineDir, me.pPartList, tDirBody)
  me.pMainAction = "std"
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  me.pRestingHeight = 0
  me.pDirection = tDirBody
  me.arrangeParts()
  if me.count(#pExtraObjs) > 0 then
    call(#Refresh, me.pExtraObjs)
  end if
  me.pSync = 0
end

on setPartLists me, tmodels 
  tAction = me.pMainAction
  me.pPartList = []
  if (me.pSex = "F") then
    tphModel = "s01"
  else
    tphModel = "s02"
  end if
  tColor = pPhFigure.getAt("color")
  tmodels.setAt("ch", ["model":tphModel, "color":tColor])
  repeat while ["bd", "lh", "rh"] <= 1
    f = getAt(1, count(["bd", "lh", "rh"]))
    if voidp(tmodels.getAt(f)) then
      tmodels.setAt(f, ["model":"001", "color":rgb("#EEEEEE")])
    end if
  end repeat
  tmodels.getAt("bd").setAt("model", "s" & tmodels.getAt("bd").getAt("model").getProp(#char, 2, 3))
  tmodels.getAt("lh").setAt("model", "s" & tmodels.getAt("bd").getAt("model").getProp(#char, 2, 3))
  tmodels.getAt("rh").setAt("model", "s" & tmodels.getAt("bd").getAt("model").getProp(#char, 2, 3))
  pPelleFigure = tmodels
  tPartDefinition = ["li", "lh", "bd", "ch", "hd", "fc", "ey", "hr", "ri", "rh"]
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    if voidp(tmodels.getAt(tPartSymbol)) then
      tmodels.setAt(tPartSymbol, [:])
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("model")) then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tmodels.getAt(tPartSymbol).setAt("color", rgb("#EEEEEE"))
    end if
    if (tPartSymbol = "fc") or (tPartSymbol = "hd") and (tmodels.getAt(tPartSymbol).getAt("model") = "002") and me.pXFactor < 33 then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    tPartCls = value(getThread(#room).getComponent().getClassContainer().GET("swimpart"))
    tPartObj = createObject(#temp, tPartCls)
    if stringp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tColor = value("rgb(" & tmodels.getAt(tPartSymbol).getAt("color") & ")")
    end if
    if tmodels.getAt(tPartSymbol).getAt("color").ilk <> #color then
      tColor = rgb(tmodels.getAt(tPartSymbol).getAt("color"))
    else
      tColor = tmodels.getAt(tPartSymbol).getAt("color")
    end if
    if ((tColor.red + tColor.green) + tColor.blue) > (238 * 3) then
      tColor = rgb("EEEEEE")
    end if
    tPartObj.define(tPartSymbol, tmodels.getAt(tPartSymbol).getAt("model"), tColor, me.pDirection, tAction, me)
    me.pPartList.add(tPartObj)
    me.pColors.setaProp(tPartSymbol, tColor)
    i = (1 + i)
  end repeat
  me.pPartIndex = [:]
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = (1 + i)
  end repeat
  return TRUE
end

on arrangeParts me 
  tRH = me.getProp(#pPartList, me.getProp(#pPartIndex, "rh"))
  tRI = me.getProp(#pPartList, me.getProp(#pPartIndex, "ri"))
  me.pPartList.deleteAt(me.getProp(#pPartIndex, "rh"))
  me.pPartList.deleteAt(me.getProp(#pPartIndex, "ri"))
  if (tRH.pActionRh = "drk") and [0, 6].getPos(me.pDirection) <> 0 then
    me.pPartList.addAt(8, tRI)
    me.pPartList.addAt(9, tRH)
  else
    if (me.pDirection = 7) then
      me.pPartList.addAt(1, tRI)
      me.pPartList.addAt(2, tRH)
    else
      me.pPartList.append(tRI)
      me.pPartList.append(tRH)
    end if
  end if
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = (1 + i)
  end repeat
  if (me.pLastDir = me.pDirection) then
    return()
  end if
  me.pLastDir = me.pDirection
  tLH = me.getProp(#pPartList, me.getProp(#pPartIndex, "lh"))
  tLI = me.getProp(#pPartList, me.getProp(#pPartIndex, "li"))
  me.pPartList.deleteAt(me.getProp(#pPartIndex, "lh"))
  me.pPartList.deleteAt(me.getProp(#pPartIndex, "li"))
  if (me.pDirection = 3) then
    me.pPartList.addAt(8, tLI)
    me.pPartList.addAt(9, tLH)
  else
    me.pPartList.addAt(1, tLI)
    me.pPartList.addAt(2, tLH)
  end if
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = (1 + i)
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
    pSwimAnimCount = (pSwimAnimCount + 1)
    if pSwimAnimCount > tSwimAnim.count then
      pSwimAnimCount = 1
    end if
    me.pAnimCounter = tSwimAnim.getAt(pSwimAnimCount)
    if objectExists(#waterripples) and (random(2) = 1) then
      tPos = me.getTileCenter()
      tPos.setAt(1, (tPos.getAt(1) - me.pXFactor))
      tPos.setAt(2, (tPos.getAt(2) - me.pXFactor))
      getObject(#waterripples).NewRipple(tPos)
    end if
    me.pChanges = 1
  else
    if me.pMoving then
      call(#defineActMultiple, me.pPartList, "wlk", ["bd", "lh", "rh"])
    end if
    me.pAnimCounter = ((me.pAnimCounter + 1) mod 4)
  end if
  if me.pEyesClosed and not me.pSleeping then
    me.openEyes()
  else
    if (random(30) = 3) then
      me.closeEyes()
    end if
  end if
  if me.pTalking and random(3) > 1 then
    if (me.pMainAction = "lay") then
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
    tFactor = (float((the milliSeconds - me.pMoveStart)) / (me.pMoveTime * 1))
    if tFactor > 1 then
      tFactor = 1
    end if
    me.pScreenLoc = ((((me.pDestLScreen - me.pStartLScreen) * 1) * tFactor) + me.pStartLScreen)
    me.pChanges = 1
  end if
  if me.pWaving then
    call(#doHandWorkLeft, me.pPartList, "wav")
    me.pChanges = 1
  end if
  if me.pDancing then
    me.pAnimating = 1
    me.pChanges = 1
  end if
end

on render me 
  if not me.pChanges then
    return()
  end if
  me.pChanges = 0
  if (me.pMainAction = "sit") then
    me.pShadowSpr.member = member(getmemnum(me.pPeopleSize & "_sit_sd_001_" & me.getProp(#pFlipList, (me.pDirection + 1)) & "_0"))
  else
    if me.pShadowSpr.member <> me.pDefShadowMem then
      me.pShadowSpr.member = me.pDefShadowMem
    end if
  end if
  if (me.pMainAction = "swm") then
    tSize = me.getProp(#pCanvasSize, #swm)
  else
    tSize = me.getProp(#pCanvasSize, #std)
  end if
  if me.pBuffer.width <> tSize.getAt(1) or me.pBuffer.height <> tSize.getAt(2) then
    me.pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    me.pMember.regPoint = point(0, (tSize.getAt(2) + tSize.getAt(4)))
    me.pSprite.width = tSize.getAt(1)
    me.pSprite.height = tSize.getAt(2)
    me.pMatteSpr.width = tSize.getAt(1)
    me.pMatteSpr.height = tSize.getAt(2)
    me.pBuffer = me.pMember.image
  end if
  if me.getProp(#pFlipList, (me.pDirection + 1)) <> me.pDirection then
    if not me.pSprite.flipH then
      me.pSprite.flipH = 1
      me.pMatteSpr.flipH = 1
      me.pShadowSpr.flipH = 1
      me.pShadowFix = me.pXFactor
    end if
    me.pMember.regPoint = point(me.pMember.image.width, me.pMember.getProp(#regPoint, 2))
  else
    if me.pSprite.flipH then
      me.pSprite.flipH = 0
      me.pMatteSpr.flipH = 0
      me.pShadowSpr.flipH = 0
      me.pShadowFix = 0
    end if
    me.pMember.regPoint = point(0, me.pMember.getProp(#regPoint, 2))
  end if
  me.pSprite.locH = me.getProp(#pScreenLoc, 1)
  me.pSprite.locV = me.getProp(#pScreenLoc, 2)
  me.pSprite.locZ = (me.getProp(#pScreenLoc, 3) + 2)
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = (me.pSprite.locZ + 1)
  me.pShadowSpr.loc = (me.pSprite.loc + [me.pShadowFix, 0])
  me.pShadowSpr.locZ = (me.pSprite.locZ - 3)
  if (me.pMainAction = "swm") then
    me.pSprite.locH = (me.pSprite.locH - 12)
    me.pMatteSpr.locH = me.pSprite.locH
  end if
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
end

on action_mv me, tProps 
  me.pMoving = 1
  tTempDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tX = integer(tloc.getProp(#item, 1))
  tY = integer(tloc.getProp(#item, 2))
  tH = integer(tloc.getProp(#item, 3))
  if tH < 7 then
    pSwimShadowH = tH
    tH = 4
  end if
  the itemDelimiter = tTempDelim
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.pMoveStart = the milliSeconds
end

on action_swim me, props 
  pSwim = 1
end

on action_wave me, tProps 
  me.pWaving = 1
end

on action_sign me, props 
  if pSwim then
    return()
  end if
  tSignMem = "sign" & props.getProp(#word, 2)
  call(#doHandWorkLeft, me.pPartList, "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(me.getProp(#pExtraObjs, tSignObjID)) then
    me.pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, me.pExtraObjs, ["sprite":me.pSprite, "direction":me.pDirection, "signmember":tSignMem])
end
