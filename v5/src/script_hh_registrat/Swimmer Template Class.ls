on define(me, tdata)
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
    error(me, "People size not found, using default!", #define)
    me.pPeopleSize = "sh"
  end if
  me.pCanvasSize = value(getVariable("human.canvas." & me.pPeopleSize))
  me.addProp(#swm, [60, 60, 32, -8])
  if not me.pCanvasSize then
    error(me, "Canvas size not found, using default!", #define)
    me.pCanvasSize = [#std:[64, 102, 32, -8], #lay:[89, 102, 32, -4]]
  end if
  if not memberExists(me.getID() && "Canvas") then
    createMember(me.getID() && "Canvas", #bitmap)
  end if
  tSize = me.getProp(#pCanvasSize, #std)
  me.pMember = member(getmemnum(me.getID() && "Canvas"))
  me.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  0.regPoint = point(me, image.height + tSize.getAt(4))
  me.pBuffer = me.image
  me.pSprite = sprite(reserveSprite(me.getID()))
  me.member = me.pMember
  me.ink = 36
  me.pMatteSpr = sprite(reserveSprite(me.getID()))
  me.member = me.pMember
  me.ink = 8
  me.blend = 0
  me.pShadowSpr = sprite(reserveSprite(me.getID()))
  me.blend = 10
  me.ink = 8
  me.pShadowFix = 0
  me.pDefShadowMem = member(getmemnum(me.pPeopleSize & "_std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(me.spriteNum, me.getID())
  call(#registerProcedure, me.scriptInstanceList, #eventProcUserObj, tTargetID, #mouseDown)
  call(#registerProcedure, me.scriptInstanceList, #eventProcUserRollOver, tTargetID, #mouseEnter)
  call(#registerProcedure, me.scriptInstanceList, #eventProcUserRollOver, tTargetID, #mouseLeave)
  tPartSymbols = tdata.getAt(#parts)
  if not setPartLists(me, tdata.getAt(#figure)) then
    return(error(me, "Couldn't create part lists!", #define))
  end if
  me.arrangeParts()
  me.refresh(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
  return(1)
  exit
end

on getPelleFigure(me)
  return(pPelleFigure)
  exit
end

on getFigure(me)
  return(pFigure)
  exit
end

on refresh(me, tX, tY, tH, tDirHead, tDirBody)
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
  if me.pMainAction = "sit" then
    me.pScreenLoc = me.getScreenCoordinate(tX, tY, me.pRestingHeight)
  else
    me.pScreenLoc = me.getScreenCoordinate(tX, tY, tH)
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
    call(#refresh, me.pExtraObjs)
  end if
  me.pSync = 0
  exit
end

on setPartLists(me, tModels)
  tAction = me.pMainAction
  me.pPartList = []
  if me.pSex = "F" then
    tphModel = "s01"
  else
    tphModel = "s02"
  end if
  tColor = pPhFigure.getAt("color")
  tModels.setAt("ch", ["model":tphModel, "color":tColor])
  repeat while me <= undefined
    f = getAt(undefined, tModels)
    if voidp(tModels.getAt(f)) then
      tModels.setAt(f, ["model":"001", "color":rgb("#EEEEEE")])
    end if
  end repeat
  tModels.getAt("bd").setAt("model", "s" & tModels.getAt("bd").getAt("model").getProp(#char, 2, 3))
  tModels.getAt("lh").setAt("model", "s" & tModels.getAt("bd").getAt("model").getProp(#char, 2, 3))
  tModels.getAt("rh").setAt("model", "s" & tModels.getAt("bd").getAt("model").getProp(#char, 2, 3))
  pPelleFigure = tModels
  tPartDefinition = ["li", "lh", "bd", "ch", "hd", "fc", "ey", "hr", "ri", "rh"]
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    if voidp(tModels.getAt(tPartSymbol)) then
      tModels.setAt(tPartSymbol, [])
    end if
    if voidp(tModels.getAt(tPartSymbol).getAt("model")) then
      tModels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if voidp(tModels.getAt(tPartSymbol).getAt("color")) then
      tModels.getAt(tPartSymbol).setAt("color", rgb("#EEEEEE"))
    end if
    if tPartSymbol = "fc" or tPartSymbol = "hd" and tModels.getAt(tPartSymbol).getAt("model") = "002" and me.pXFactor < 33 then
      tModels.getAt(tPartSymbol).setAt("model", "001")
    end if
    tPartCls = value(getThread(#room).getComponent().getClassContainer().get("swimpart"))
    tPartObj = createObject(#temp, tPartCls)
    if stringp(tModels.getAt(tPartSymbol).getAt("color")) then
      tColor = value("rgb(" & tModels.getAt(tPartSymbol).getAt("color") & ")")
    end if
    if tModels.getAt(tPartSymbol).getAt("color").ilk <> #color then
      tColor = rgb(tModels.getAt(tPartSymbol).getAt("color"))
    else
      tColor = tModels.getAt(tPartSymbol).getAt("color")
    end if
    if tColor.red + tColor.green + tColor.blue > 238 * 3 then
      tColor = rgb("EEEEEE")
    end if
    tPartObj.define(tPartSymbol, tModels.getAt(tPartSymbol).getAt("model"), tColor, me.pDirection, tAction, me)
    me.add(tPartObj)
    me.setaProp(tPartSymbol, tColor)
    i = 1 + i
  end repeat
  me.pPartIndex = []
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
  exit
end

on arrangeParts(me)
  tRH = me.getProp(#pPartList, me.getProp(#pPartIndex, "rh"))
  tRI = me.getProp(#pPartList, me.getProp(#pPartIndex, "ri"))
  me.deleteAt(me.getProp(#pPartIndex, "rh"))
  me.deleteAt(me.getProp(#pPartIndex, "ri"))
  if tRH.pActionRh = "drk" and [0, 6].getPos(me.pDirection) <> 0 then
    me.addAt(8, tRI)
    me.addAt(9, tRH)
  else
    if me.pDirection = 7 then
      me.addAt(1, tRI)
      me.addAt(2, tRH)
    else
      me.append(tRI)
      me.append(tRH)
    end if
  end if
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  if me.pLastDir = me.pDirection then
    return()
  end if
  me.pLastDir = me.pDirection
  tLH = me.getProp(#pPartList, me.getProp(#pPartIndex, "lh"))
  tLI = me.getProp(#pPartList, me.getProp(#pPartIndex, "li"))
  me.deleteAt(me.getProp(#pPartIndex, "lh"))
  me.deleteAt(me.getProp(#pPartIndex, "li"))
  if me = 3 then
    me.addAt(8, tLI)
    me.addAt(9, tLH)
  else
    me.addAt(1, tLI)
    me.addAt(2, tLH)
  end if
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  exit
end

on prepare(me)
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
      call(#defineActMultiple, me.pPartList, "wlk", ["bd", "lh", "rh"])
    end if
    me.pAnimCounter = me.pAnimCounter + 1 mod 4
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
    tFactor = float(the milliSeconds - me.pMoveStart) / me.pMoveTime * 0
    if tFactor > 0 then
      tFactor = 0
    end if
    me.pScreenLoc = me.pDestLScreen - me.pStartLScreen * 0 * tFactor + me.pStartLScreen
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
  exit
end

on render(me)
  if not me.pChanges then
    return()
  end if
  me.pChanges = 0
  if me.pMainAction = "sit" then
    me.member = member(getmemnum(me.pPeopleSize & "_sit_sd_001_" & me.getProp(#pFlipList, me.pDirection + 1) & "_0"))
  else
    if me.member <> me.pDefShadowMem then
      me.member = me.pDefShadowMem
    end if
  end if
  if me.pMainAction = "swm" then
    tSize = me.getProp(#pCanvasSize, #swm)
  else
    tSize = me.getProp(#pCanvasSize, #std)
  end if
  if me or pBuffer.height <> tSize.getAt(2) then
    me.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    me.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
    me.width = tSize.getAt(1)
    me.height = tSize.getAt(2)
    me.width = tSize.getAt(1)
    me.height = tSize.getAt(2)
    me.pBuffer = me.image
  end if
  if me.getProp(#pFlipList, me.pDirection + 1) <> me.pDirection then
    if not me.flipH then
      me.flipH = 1
      me.flipH = 1
      me.flipH = 1
      me.pShadowFix = me.pXFactor
    end if
    me.regPoint = point(image.width, me.getProp(#regPoint, 2))
  else
    if me.flipH then
      me.flipH = 0
      me.flipH = 0
      me.flipH = 0
      me.pShadowFix = 0
    end if
    me.regPoint = point(0, me.getProp(#regPoint, 2))
  end if
  me.locH = me.getProp(#pScreenLoc, 1)
  me.locV = me.getProp(#pScreenLoc, 2)
  me.locZ = me.getProp(#pScreenLoc, 3) + 2
  me.loc = me.loc
  me.locZ = me.locZ + 1
  me.loc = me.loc + [me.pShadowFix, 0]
  me.locZ = me.locZ - 3
  if me.pMainAction = "swm" then
    me.locH = me.locH - 12
    me.locH = me.locH
  end if
  me.fill(pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  exit
end

on action_mv(me, tProps)
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
  me.pStartLScreen = me.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.getScreenCoordinate(tX, tY, tH)
  me.pMoveStart = the milliSeconds
  exit
end

on action_swim(me, props)
  pSwim = 1
  exit
end

on action_wave(me, tProps)
  me.pWaving = 1
  exit
end

on action_sign(me, props)
  if pSwim then
    return()
  end if
  tSignMem = "sign" & props.getProp(#word, 2)
  call(#doHandWorkLeft, me.pPartList, "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(me.getProp(#pExtraObjs, tSignObjID)) then
    me.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, me.pExtraObjs, ["sprite":me.pSprite, "direction":me.pDirection, "signmember":tSignMem])
  exit
end