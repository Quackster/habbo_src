property pBounceAnimCount, pBallClass, pLocChange, pDirChange

on construct me
  pBounceAnimCount = 1
  pBallClass = ["Bodypart Class EX", "Bouncing Bodypart Class"]
  me.pDirChange = 1
  me.pLocChange = 1
  if not objectp(me.ancestor) then
    return 0
  end if
  return me.ancestor.construct()
end

on deconstruct me
  if not objectp(me.ancestor) then
    return 1
  end if
  return me.ancestor.deconstruct()
end

on select me
  return 0
end

on prepare me
  tScreenLoc = me.pScreenLoc.duplicate()
  if me.pMoving then
    tFactor = float(the milliSeconds - me.pMoveStart) / me.pMoveTime
    if tFactor > 1.0 then
      tFactor = 1.0
    end if
    me.pScreenLoc = ((me.pDestLScreen - me.pStartLScreen) * tFactor) + me.pStartLScreen
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
    tBounceLocV = [0, -0.5, -1.0, -1.19999999999999996, -1.0, -0.5, -0]
  else
    tBounceLocV = [0, -0.29999999999999999, -0.40000000000000002, -0.5, -0.40000000000000002, -0.10000000000000001]
  end if
  me.pBounceAnimCount = me.pBounceAnimCount + 1
  if me.pBounceAnimCount > tBounceLocV.count then
    me.pBounceAnimCount = 1
  end if
  me.pScreenLoc[2] = me.pScreenLoc[2] + (10 * tBounceLocV[me.pBounceAnimCount])
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
    return 1
  end if
  me.pChanges = 0
  if me.pLocChange and not me.pDirChange then
    me.pLocChange = 0
    return me.setHumanSpriteLoc()
  end if
  if me.pDirChange = 0 then
    return 1
  end if
  me.pDirChange = 0
  tSize = me.pCanvasSize[#std]
  if me.pShadowSpr.member <> me.pDefShadowMem then
    me.pShadowSpr.member = me.pDefShadowMem
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
    me.pMember.regPoint = point(me.pMember.image.width, me.pMember.regPoint[2])
    me.pShadowFix = me.pXFactor
    if not me.pSprite.flipH then
      me.pSprite.flipH = 1
      me.pMatteSpr.flipH = 1
      me.pShadowSpr.flipH = 1
    end if
  else
    me.pMember.regPoint = point(0, me.pMember.regPoint[2])
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
  return 1
end

on setHumanSpriteLoc me
  tOffZ = 2
  me.pSprite.locH = me.pScreenLoc[1]
  me.pSprite.locV = me.pScreenLoc[2]
  me.pSprite.locZ = me.pScreenLoc[3] + tOffZ
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = me.pSprite.locZ + 1
  me.pShadowSpr.loc = me.pSprite.loc + [me.pShadowFix, 0]
  me.pShadowSpr.locZ = me.pSprite.locZ - 3
  return 1
end

on setBallColor me, tColor
  tBallPart = me.pPartList[me.pPartIndex["bl"]]
  if tBallPart <> VOID then
    tBallPart.setColor(tColor)
  end if
  tBallPart.pMemString = EMPTY
  me.pChanges = 1
  me.pDirChange = 1
  me.render()
  return 1
end

on setPartLists me, tmodels
  me.pMainAction = "sit"
  me.pPartList = []
  tPartDefinition = getVariableValue("bouncing.human.parts.sh")
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
    if (tPartSymbol = "fc") and (tmodels[tPartSymbol]["model"] <> "001") and (me.pXFactor < 33) then
      tmodels[tPartSymbol]["model"] = "001"
    end if
    if tPartSymbol = "bl" then
      tPartObj = createObject(#temp, me.pBallClass)
    else
      tPartObj = createObject(#temp, me.pPartClass)
    end if
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
    if ["ls", "lh", "rs", "rh"].getPos(tPartSymbol) = 0 then
      tAction = me.pMainAction
    else
      tAction = "crr"
    end if
    tPartObj.define(tPartSymbol, tmodels[tPartSymbol]["model"], tColor, me.pDirection, tAction, me)
    me.pPartList.add(tPartObj)
    me.pColors.setaProp(tPartSymbol, tColor)
  end repeat
  me.pPartIndex = [:]
  repeat with i = 1 to me.pPartList.count
    me.pPartIndex[me.pPartList[i].pPart] = i
  end repeat
  call(#reset, me.pPartList)
  call(#defineActMultiple, me.pPartList, "sit", ["bd", "lg", "sh"])
  call(#defineActMultiple, me.pPartList, "crr", ["lh", "rh", "ls", "rs"])
  return 1
end

on getPicture me, tImg
  if voidp(tImg) then
    tCanvas = image(32, 62, 32)
  else
    tCanvas = tImg
  end if
  tPartDefinition = getVariableValue("human.parts.sh")
  tTempPartList = []
  repeat with tPartSymbol in tPartDefinition
    if not voidp(me.pPartIndex[tPartSymbol]) then
      tTempPartList.append(me.pPartList[me.pPartIndex[tPartSymbol]])
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas, "2", "sh")
  return tCanvas
end

on Refresh me, tX, tY, tH
  call(#defineDir, me.pPartList, me.pDirection)
  call(#defineDirMultiple, me.pPartList, me.pDirection, ["hd", "hr", "ey", "fc"])
  me.arrangeParts()
  return 1
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
  return 1
end

on action_mv me, tProps
  me.pMainAction = "sit"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  pBounceAnimCount = 1
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = integer(tloc.item[3])
  the itemDelimiter = tDelim
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  call(#defineActMultiple, me.pPartList, "sit", ["bd", "lg", "sh"])
  call(#defineActMultiple, me.pPartList, "crr", ["lh", "rh", "ls", "rs"])
end
