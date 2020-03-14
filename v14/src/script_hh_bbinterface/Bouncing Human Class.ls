on construct me 
  pBounceAnimCount = 1
  pBallClass = ["Bodypart Class EX", "Bouncing Bodypart Class"]
  me.pDirChange = 1
  me.pLocChange = 1
  if not objectp(me.ancestor) then
    return FALSE
  end if
  return(me.ancestor.construct())
end

on deconstruct me 
  if not objectp(me.ancestor) then
    return TRUE
  end if
  return(me.ancestor.deconstruct())
end

on select me 
  return FALSE
end

on prepare me 
  tScreenLoc = me.pScreenLoc.duplicate()
  if me.pMoving then
    tFactor = (float((the milliSeconds - me.pMoveStart)) / me.pMoveTime)
    if tFactor > 1 then
      tFactor = 1
    end if
    me.pScreenLoc = (((me.pDestLScreen - me.pStartLScreen) * tFactor) + me.pStartLScreen)
    me.adjustScreenLoc(1)
    me.pChanges = 1
  else
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
    me.adjustScreenLoc(0)
    me.pChanges = not me.pChanges
  end if
  if tScreenLoc <> me.pScreenLoc then
    me.pLocChange = 1
  end if
end

on adjustScreenLoc me, tBouncing 
  if tBouncing then
    tBounceLocV = [0, -0.5, -1, -1.2, -1, -0.5, -0]
  else
    tBounceLocV = [0, -0.3, -0.4, -0.5, -0.4, -0.1]
  end if
  me.pBounceAnimCount = (me.pBounceAnimCount + 1)
  if me.pBounceAnimCount > tBounceLocV.count then
    me.pBounceAnimCount = 1
  end if
  me.setProp(#pScreenLoc, 2, (me.getProp(#pScreenLoc, 2) + (10 * tBounceLocV.getAt(me.pBounceAnimCount))))
end

on update me 
  me.pSync = not me.pSync
  if me.pSync then
    me.prepare()
  else
    me.render()
  end if
end

on render me 
  if not me.pChanges then
    return TRUE
  end if
  me.pChanges = 0
  if me.pLocChange and not me.pDirChange then
    me.pLocChange = 0
    return(me.setHumanSpriteLoc())
  end if
  if (me.pDirChange = 0) then
    return TRUE
  end if
  me.pDirChange = 0
  tSize = me.getProp(#pCanvasSize, #std)
  if me.pShadowSpr.member <> me.pDefShadowMem then
    me.pShadowSpr.member = me.pDefShadowMem
  end if
  if me.pBuffer.width <> tSize.getAt(1) or me.pBuffer.height <> tSize.getAt(2) then
    me.pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    me.pMember.regPoint = point(0, (tSize.getAt(2) + tSize.getAt(4)))
    me.pSprite.width = tSize.getAt(1)
    me.pSprite.height = tSize.getAt(2)
    me.pMatteSpr.width = tSize.getAt(1)
    me.pMatteSpr.height = tSize.getAt(2)
    me.pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  end if
  if me.getProp(#pFlipList, (me.pDirection + 1)) <> me.pDirection or (me.pDirection = 3) and (me.pHeadDir = 4) or (me.pDirection = 7) and (me.pHeadDir = 6) then
    me.pMember.regPoint = point(me.pMember.image.width, me.pMember.getProp(#regPoint, 2))
    me.pShadowFix = me.pXFactor
    if not me.pSprite.flipH then
      me.pSprite.flipH = 1
      me.pMatteSpr.flipH = 1
      me.pShadowSpr.flipH = 1
    end if
  else
    me.pMember.regPoint = point(0, me.pMember.getProp(#regPoint, 2))
    me.pShadowFix = 0
    if me.pSprite.flipH then
      me.pSprite.flipH = 0
      me.pMatteSpr.flipH = 0
      me.pShadowSpr.flipH = 0
    end if
  end if
  me.setHumanSpriteLoc()
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  me.pMember.image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  return TRUE
end

on setHumanSpriteLoc me 
  tOffZ = 2
  me.pSprite.locH = me.getProp(#pScreenLoc, 1)
  me.pSprite.locV = me.getProp(#pScreenLoc, 2)
  me.pSprite.locZ = (me.getProp(#pScreenLoc, 3) + tOffZ)
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = (me.pSprite.locZ + 1)
  me.pShadowSpr.loc = (me.pSprite.loc + [me.pShadowFix, 0])
  me.pShadowSpr.locZ = (me.pSprite.locZ - 3)
  return TRUE
end

on setBallColor me, tColor 
  tBallPart = me.getProp(#pPartList, me.getProp(#pPartIndex, "bl"))
  if tBallPart <> void() then
    tBallPart.setColor(tColor)
  end if
  tBallPart.pMemString = ""
  me.pChanges = 1
  me.pDirChange = 1
  me.render()
  return TRUE
end

on setPartLists me, tmodels 
  me.pMainAction = "sit"
  me.pPartList = []
  tPartDefinition = getVariableValue("bouncing.human.parts.sh")
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
      tmodels.getAt(tPartSymbol).setAt("color", rgb("EEEEEE"))
    end if
    if (tPartSymbol = "fc") and tmodels.getAt(tPartSymbol).getAt("model") <> "001" and me.pXFactor < 33 then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if (tPartSymbol = "bl") then
      tPartObj = createObject(#temp, me.pBallClass)
    else
      tPartObj = createObject(#temp, me.pPartClass)
    end if
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
    if (["ls", "lh", "rs", "rh"].getPos(tPartSymbol) = 0) then
      tAction = me.pMainAction
    else
      tAction = "crr"
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
  call(#reset, me.pPartList)
  call(#defineActMultiple, me.pPartList, "sit", ["bd", "lg", "sh"])
  call(#defineActMultiple, me.pPartList, "crr", ["lh", "rh", "ls", "rs"])
  return TRUE
end

on getPicture me, tImg 
  if voidp(tImg) then
    tCanvas = image(32, 62, 32)
  else
    tCanvas = tImg
  end if
  tPartDefinition = getVariableValue("human.parts.sh")
  tTempPartList = []
  repeat while tPartDefinition <= 1
    tPartSymbol = getAt(1, count(tPartDefinition))
    if not voidp(me.getProp(#pPartIndex, tPartSymbol)) then
      tTempPartList.append(me.getProp(#pPartList, me.getProp(#pPartIndex, tPartSymbol)))
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas, "2", "sh")
  return(tCanvas)
end

on Refresh me, tX, tY, tH 
  call(#defineDir, me.pPartList, me.pDirection)
  call(#defineDirMultiple, me.pPartList, me.pDirection, ["hd", "hr", "ey", "fc"])
  me.arrangeParts()
  return TRUE
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody 
  tDirHead = tDirBody
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
  me.pLocFix = point(-1, 2)
  me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.adjustScreenLoc()
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  if me.pDirection <> tDirBody then
    me.pDirChange = 1
  end if
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pChanges = 1
  return TRUE
end

on action_mv me, tProps 
  me.pMainAction = "sit"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  pBounceAnimCount = 1
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = integer(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  call(#defineActMultiple, me.pPartList, "sit", ["bd", "lg", "sh"])
  call(#defineActMultiple, me.pPartList, "crr", ["lh", "rh", "ls", "rs"])
end
