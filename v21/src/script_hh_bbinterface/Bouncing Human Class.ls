on construct me 
  pBounceAnimCount = 1
  pBallClass = ["Bodypart Class EX", "Bouncing Bodypart Class"]
  me.pDirChange = 1
  me.pLocChange = 1
  if not objectp(me.ancestor) then
    return(0)
  end if
  return(me.construct())
end

on deconstruct me 
  if not objectp(me.ancestor) then
    return(1)
  end if
  return(me.deconstruct())
end

on select me 
  return(0)
end

on prepare me 
  tScreenLoc = me.duplicate()
  if me.pMoving then
    tFactor = (float(the milliSeconds - me.pMoveStart) / me.pMoveTime)
    if tFactor > 1 then
      tFactor = 1
    end if
    me.pScreenLoc = (me.pDestLScreen - me.pStartLScreen * tFactor) + me.pStartLScreen
    me.adjustScreenLoc(1)
    me.pChanges = 1
  else
    me.pScreenLoc = me.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
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
  me.pBounceAnimCount = me.pBounceAnimCount + 1
  if me.pBounceAnimCount > tBounceLocV.count then
    me.pBounceAnimCount = 1
  end if
  me.setProp(#pScreenLoc, 2, me.getProp(#pScreenLoc, 2) + (10 * tBounceLocV.getAt(me.pBounceAnimCount)))
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
    return(1)
  end if
  me.pChanges = 0
  if me.pLocChange and not me.pDirChange then
    me.pLocChange = 0
    return(me.setHumanSpriteLoc())
  end if
  if me.pDirChange = 0 then
    return(1)
  end if
  me.pDirChange = 0
  tSize = me.getProp(#pCanvasSize, #std)
  if me.member <> me.pDefShadowMem then
    me.member = me.pDefShadowMem
  end if
  if me.width <> tSize.getAt(1) or me.height <> tSize.getAt(2) then
    me.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    me.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
    me.width = tSize.getAt(1)
    me.height = tSize.getAt(2)
    me.width = tSize.getAt(1)
    me.height = tSize.getAt(2)
    me.pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  end if
  if me.getProp(#pFlipList, me.pDirection + 1) <> me.pDirection or me.pDirection = 3 and me.pHeadDir = 4 or me.pDirection = 7 and me.pHeadDir = 6 then
    me.regPoint = point(image.width, me.getProp(#regPoint, 2))
    me.pShadowFix = me.pXFactor
    if not me.flipH then
      me.flipH = 1
      me.flipH = 1
      me.flipH = 1
    end if
  else
    me.regPoint = point(0, me.getProp(#regPoint, 2))
    me.pShadowFix = 0
    if me.flipH then
      me.flipH = 0
      me.flipH = 0
      me.flipH = 0
    end if
  end if
  me.setHumanSpriteLoc()
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.fill(me.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  return(1)
end

on setHumanSpriteLoc me 
  tOffZ = 2
  me.locH = me.getProp(#pScreenLoc, 1)
  me.locV = me.getProp(#pScreenLoc, 2)
  me.locZ = me.getProp(#pScreenLoc, 3) + tOffZ
  me.loc = me.loc
  me.locZ = me.locZ + 1
  me.loc = me.loc + [me.pShadowFix, 0]
  me.locZ = me.locZ - 3
  return(1)
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
  return(1)
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
    if tPartSymbol = "fc" and tmodels.getAt(tPartSymbol).getAt("model") <> "001" and me.pXFactor < 33 then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if tPartSymbol = "bl" then
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
    if tColor.red + tColor.green + tColor.blue > (238 * 3) then
      tColor = rgb("EEEEEE")
    end if
    if ["ls", "lh", "rs", "rh"].getPos(tPartSymbol) = 0 then
      tAction = me.pMainAction
    else
      tAction = "crr"
    end if
    tPartObj.define(tPartSymbol, tmodels.getAt(tPartSymbol).getAt("model"), tColor, me.pDirection, tAction, me)
    me.add(tPartObj)
    me.setaProp(tPartSymbol, tColor)
    i = 1 + i
  end repeat
  me.pPartIndex = [:]
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  call(#reset, me.pPartList)
  call(#defineActMultiple, me.pPartList, "sit", ["bd", "lg", "sh"])
  call(#defineActMultiple, me.pPartList, "crr", ["lh", "rh", "ls", "rs"])
  return(1)
end

on getPicture me, tImg 
  if voidp(tImg) then
    tCanvas = image(32, 62, 32)
  else
    tCanvas = tImg
  end if
  tPartDefinition = getVariableValue("human.parts.sh")
  tTempPartList = []
  repeat while tPartDefinition <= undefined
    tPartSymbol = getAt(undefined, tImg)
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
  return(1)
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
  me.pScreenLoc = me.getScreenCoordinate(tX, tY, tH)
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
  return(1)
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
  me.pStartLScreen = me.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  call(#defineActMultiple, me.pPartList, "sit", ["bd", "lg", "sh"])
  call(#defineActMultiple, me.pPartList, "crr", ["lh", "rh", "ls", "rs"])
end
