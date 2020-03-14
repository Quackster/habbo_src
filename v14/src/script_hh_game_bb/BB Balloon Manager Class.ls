property pMaxBalloons, pScrollStep, pTextMember, pMoveOffsetV, pBalloonImg, pAvailableBalloons, pVisibleBalloons, pBalloonPulse, pReservedSprites, pState, pStartV, pLastBalloonId, pBalloonBuffer, pFastScrollStep, pFirstLocz, pMaxWidth, pDefaultTextColor, pMarginH, pMarginV, pLastMsg, pBalloonColor, pScrollCounter, pScrollBy, pAutoScrollTime

on construct me 
  pAutoScrollTime = 140
  if variableExists("chat.balloon.scrollstep") then
    pScrollStep = getIntVariable("chat.balloon.scrollstep")
  else
    pScrollStep = 3
  end if
  pState = #normal
  pScrollCounter = 0
  pVisibleBalloons = [:]
  pAvailableBalloons = [:]
  pBalloonBuffer = []
  pMaxBalloons = (6 + 1)
  pFirstLocz = ((getIntVariable("window.default.locz") + 2000) - pMaxBalloons)
  pMoveOffsetV = 21
  pMarginH = 20
  pMarginV = 11
  pScrollBy = pScrollStep
  pDefaultTextColor = rgb(254, 254, 254)
  pBalloonColor = paletteIndex(255)
  tFontStruct = getStructVariable("struct.font.plain")
  pTextMember = member(createMember("bb.balloon.text", #text))
  pTextMember.wordWrap = 0
  pTextMember.boxType = #adjust
  pTextMember.antialias = 0
  pTextMember.font = tFontStruct.getaProp(#font)
  pTextMember.fontSize = tFontStruct.getaProp(#fontSize)
  pTextMember.fontStyle = tFontStruct.getaProp(#fontStyle)
  if (pMoveOffsetV mod pScrollStep) <> 0 then
    pMoveOffsetV = (pMoveOffsetV - (pMoveOffsetV mod pScrollStep))
  end if
  pFastScrollStep = (pMoveOffsetV / pScrollStep)
  pStartV = (((pMaxBalloons - 1) * pMoveOffsetV) - 1)
  pMaxWidth = ((the stageRight - the stageLeft) - 10)
  pReservedSprites = []
  pBalloonImg = [:]
  pBalloonImg.addProp(#middle, member(getmemnum("bb2_pwrupbubble.middle")).image.duplicate())
  pBalloonImg.addProp(#right, member(getmemnum("bb2_pwrupbubble.right")).image)
  registerMessage(#leaveRoom, me.getID(), #removeBalloons)
  registerMessage(#changeRoom, me.getID(), #removeBalloons)
  me.resetBalloons()
  return TRUE
end

on deconstruct me 
  if timeoutExists(#bbballoonautoscroll) then
    removeTimeout(#bbballoonautoscroll)
  end if
  removePrepare(me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  pBalloonBuffer = []
  if not voidp(pAvailableBalloons) then
    call(#deconstruct, pAvailableBalloons)
  end if
  if not voidp(pVisibleBalloons) then
    call(#deconstruct, pVisibleBalloons)
  end if
  if not voidp(pBalloonPulse) then
    call(#deconstruct, pBalloonPulse)
  end if
  repeat while pReservedSprites <= 1
    tSpr = getAt(1, count(pReservedSprites))
    releaseSprite(tSpr)
  end repeat
  removeMember(pTextMember.name)
  pReservedSprites = []
  pTextMembers = [:]
  pAvailableBalloons = void()
  pVisibleBalloons = void()
  pBalloonBuffer = void()
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #bb_event_5) then
    me.createBalloon(tdata.getAt(#playerId), tdata.getAt(#powerupType), tdata.getAt(#playerId))
  else
    if (tTopic = #gameend) then
      me.removeBalloons()
    end if
  end if
  return TRUE
end

on createBalloon me, tLocRefObjId, tPowerupType, tOwnerId 
  if (pState = #normal) then
    if pAvailableBalloons.count > 0 then
      tGameSystem = me.getGameSystem()
      if (tGameSystem = 0) then
        return FALSE
      end if
      tLocRefObj = tGameSystem.getGameObject(tLocRefObjId)
      if (tLocRefObj = 0) then
        return(error(me, "Cannot find game object by id:" && tLocRefObjId, #createNewBalloon))
      end if
      tTileLocation = tLocRefObj.getLocation().getLocation()
      tWorldLocation = tGameSystem.convertTileToWorldCoordinate(tTileLocation.getAt(#x), tTileLocation.getAt(#y), tTileLocation.getAt(#z))
      tlocation = tGameSystem.convertWorldToScreenCoordinate(tWorldLocation.getAt(#x), tWorldLocation.getAt(#y), tWorldLocation.getAt(#z))
      tlocation = point(tlocation.getAt(1), tlocation.getAt(2))
      tText = getText("bb_powerup_" & tPowerupType)
      tMsg = [:]
      tMsg.addProp(#text, tText)
      tMsg.addProp(#location, tlocation)
      tMsg.addProp(#id, string(tLocRefObjId))
      if (tPowerupType = 6) then
        tMsg.addProp(#type, "6_" & (me.getGameSystem().getGameObjectProperty(tOwnerId, #teamId) + 1))
      else
        tMsg.addProp(#type, tPowerupType)
      end if
      pLastBalloonId = pAvailableBalloons.getPropAt(1)
      pLastMsg = tMsg
      pBalloonPulse.set(#humanLoc, tlocation)
      pBalloonPulse.set(#stoploc, point(tlocation.locH, pStartV))
      pBalloonPulse.set(#balloonColor, rgb(0, 0, 0))
      pBalloonPulse.set(#BalloonId, pLastBalloonId)
      call(#definePulse, pBalloonPulse)
      pScrollCounter = 0
      pState = #scroll
      if (pBalloonBuffer.count() = 0) then
        pScrollBy = pScrollStep
      else
        if pBalloonBuffer.count() < 2 then
          pScrollBy = pFastScrollStep
        else
          pScrollBy = pMoveOffsetV
        end if
      end if
      receivePrepare(me.getID())
    else
      if pVisibleBalloons.count() > 0 then
        me.removeVisibleBalloon(pVisibleBalloons.getPropAt(1))
      end if
      me.createBalloon(tLocRefObjId, tPowerupType, tOwnerId)
    end if
  else
    if (pState = #scroll) then
      tMsg = [tLocRefObjId, tPowerupType, tOwnerId]
      if not pBalloonBuffer.getPos(tMsg) then
        pBalloonBuffer.add(tMsg)
      end if
    end if
  end if
  return TRUE
end

on resetBalloons me 
  pVisibleBalloons = [:]
  pAvailableBalloons = [:]
  tSprNum = reserveSprite(me.getID())
  pReservedSprites.add(tSprNum)
  pBalloonPulse = createObject(#temp, "BB Balloon Pulse Class")
  if (pBalloonPulse = 0) then
    return(error(me, "Cannot create Balloon Pulse controller.", #resetBalloons))
  end if
  sprite(tSprNum).locZ = pFirstLocz
  sprite(tSprNum).ink = 8
  pBalloonPulse.set(#sprite, tSprNum)
  pBalloonPulse.set(#manager, me)
  f = 1
  repeat while f <= pMaxBalloons
    tSprNum = reserveSprite(me.getID())
    pReservedSprites.add(tSprNum)
    if (tSprNum = 0) then
      pMaxBalloons = (f - 1)
      return()
    end if
    sprite(tSprNum).locZ = ((pFirstLocz + f) - 1)
    sprite(tSprNum).ink = 8
    tBalloonId = "bb.balloon" & f
    tmember = "bb.balloon." & tBalloonId
    if not memberExists(tmember) then
      createMember(tmember, #bitmap)
    end if
    tmember = getmemnum(tmember)
    pAvailableBalloons.addProp(tBalloonId, createObject(#temp, "BB Balloon Class"))
    pAvailableBalloons.getAt(tBalloonId).setID(tBalloonId)
    pAvailableBalloons.getAt(tBalloonId).set(#sprite, tSprNum)
    pAvailableBalloons.getAt(tBalloonId).set(#member, tmember)
    pAvailableBalloons.getAt(tBalloonId).set(#loc, point(0, -1000))
    pAvailableBalloons.getAt(tBalloonId).set(#manager, me)
    f = (1 + f)
  end repeat
end

on removeBalloons me 
  removePrepare(me.getID())
  if timeoutExists(#bbballoonautoscroll) then
    removeTimeout(#bbballoonautoscroll)
  end if
  pBalloonBuffer = []
  pLastBalloonId = void()
  pState = #normal
  call(#removePulse, pBalloonPulse)
  call(#removeBalloon, pVisibleBalloons)
  call(#removeBalloon, pAvailableBalloons)
  call(#showBalloon, pVisibleBalloons)
  call(#showBalloon, pAvailableBalloons)
  tTempRemoveVisible = pVisibleBalloons.duplicate()
  f = 1
  repeat while f <= tTempRemoveVisible.count
    me.removeVisibleBalloon(tTempRemoveVisible.getPropAt(f))
    f = (1 + f)
  end repeat
end

on removeVisibleBalloon me, tID 
  if not voidp(pVisibleBalloons.getAt(tID)) then
    pAvailableBalloons.setAt(tID, pVisibleBalloons.getAt(tID))
    pAvailableBalloons.getAt(tID).set(#loc, point(0, -1000))
    pVisibleBalloons.deleteProp(tID)
    return TRUE
  end if
end

on createballoonImg me, tText, ttype 
  tmember = pTextMember
  tSavedFont = tmember.font
  tSavedStyle = tmember.fontStyle
  tmember.rect = rect(0, 0, pMaxWidth, tmember.height)
  tBoldStruct = getStructVariable("struct.font.bold")
  tmember.text = tText
  tSavedColor = tmember.color
  tmember.color = pDefaultTextColor
  tLeftImageMemNum = getmemnum("bb2_pwrupbubble.left_" & ttype)
  if tLeftImageMemNum <= 0 then
    return(error(me, "Cannot create bubble for powerup type" && ttype, #createballoonImg))
  end if
  tLeftMember = member(tLeftImageMemNum)
  tLeftImage = tLeftMember.image
  tTextWidth = ((tmember.charPosToLoc(tmember.count(#char)).locH * 2) + 10)
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = tmember.image
  tWidth = ((tTextWidth + (pMarginH * 2)) + tLeftMember.regPoint.locH)
  tHeight = (tLeftImage.height + tLeftMember.regPoint.locV)
  tNewImg = image(tWidth, tHeight, 8)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #middle, #right] <= 1
    i = getAt(1, count([#left, #middle, #right]))
    tStartPointX = tEndPointX
    if ([#left, #middle, #right] = #left) then
      tStartPointY = 0
      tEndPointX = (tEndPointX + tLeftImage.width)
      tEndPointY = tLeftImage.height
    else
      if ([#left, #middle, #right] = #middle) then
        tStartPointY = (6 + tLeftMember.regPoint.locV)
        tEndPointX = (((tEndPointX + tWidth) - tLeftImage.width) - pBalloonImg.getProp(#right).width)
        tEndPointY = (pBalloonImg.getProp(i).height + tStartPointY)
      else
        if ([#left, #middle, #right] = #right) then
          tStartPointY = (6 + tLeftMember.regPoint.locV)
          tEndPointX = (tEndPointX + pBalloonImg.getProp(i).width)
          tEndPointY = (pBalloonImg.getProp(i).height + tStartPointY)
        end if
      end if
    end if
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    if (i = #left) then
      tNewImg.copyPixels(tLeftImage, tdestrect, tLeftImage.rect)
    else
      tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
    end if
  end repeat
  tdestrect = (tTextImg.rect + rect(pMarginH, (pMarginV + tLeftMember.regPoint.locV), pMarginH, (pMarginV + tLeftMember.regPoint.locV)))
  tdestrect = ((tdestrect + rect((tNewImg.width / 2), 0, (tNewImg.width / 2), 0)) - rect((tTextWidth / 2), 0, (tTextWidth / 2), 0))
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  tmember.font = tSavedFont
  tmember.fontStyle = tSavedStyle
  tmember.color = tSavedColor
  return(tNewImg)
end

on showNewBalloon me 
  tMsg = pLastMsg
  if voidp(pLastBalloonId) then
    return()
  end if
  tNewBalloon = pAvailableBalloons.getAt(1)
  pVisibleBalloons.addProp(pLastBalloonId, tNewBalloon)
  pAvailableBalloons.deleteProp(pLastBalloonId)
  tmember = member(pVisibleBalloons.getAt(pLastBalloonId).GET(#member))
  pVisibleBalloons.getAt(pLastBalloonId).set(#balloonColor, pBalloonColor)
  tBalloonImage = me.createballoonImg(tMsg.getAt(#text), tMsg.getAt(#type))
  if (tBalloonImage = 0) then
    me.removeVisibleBalloon(tMsg.getAt(#id))
    return(error(me, "No image for balloon.", #showNewBalloon))
  end if
  tmember.image = tBalloonImage
  tmember.regPoint = (tmember.regPoint + point(0, (tmember.image.height / 2)))
  pBalloonLeftMarg = getIntVariable("balloons.leftmargin", 0)
  pBalloonRightMarg = getIntVariable("balloons.rightmargin", 720)
  if (tMsg.getAt(#location).getAt(1) + (tmember.image.width / 2)) > pBalloonRightMarg then
    tStartH = (pBalloonRightMarg - (tmember.image.width / 2))
  else
    if (tMsg.getAt(#location).getAt(1) - (tmember.image.width / 2)) < pBalloonLeftMarg then
      tStartH = (pBalloonLeftMarg + (tmember.image.width / 2))
    else
      tStartH = tMsg.getAt(#location).getAt(1)
    end if
  end if
  pVisibleBalloons.getAt(pLastBalloonId).set(#loc, point(tStartH, pStartV))
  pVisibleBalloons.getAt(pLastBalloonId).set(#ownerID, tMsg.getAt(#id))
  call(#defineBalloon, pVisibleBalloons.getAt(pLastBalloonId))
end

on prepare me 
  if (pState = #scroll) then
    if (pScrollCounter + pScrollBy) <= pMoveOffsetV then
      pScrollCounter = (pScrollCounter + pScrollBy)
      call(#UpdateBalloonPos, pVisibleBalloons, -pScrollBy)
      if not voidp(pLastBalloonId) then
        call(#OpeningBalloon, pBalloonPulse, (-pScrollCounter * (pScrollBy * 2)))
      end if
    else
      if not voidp(pLastBalloonId) then
        me.showNewBalloon()
      end if
      removePrepare(me.getID())
      pScrollCounter = 0
      pState = #normal
      if pBalloonBuffer.count() > 0 then
        tMsg = pBalloonBuffer.getAt(1)
        pBalloonBuffer.deleteAt(1)
        me.createBalloon(tMsg.getAt(1), tMsg.getAt(2), tMsg.getAt(3))
      else
        if timeoutExists(#bbballoonautoscroll) then
          removeTimeout(#bbballoonautoscroll)
        end if
        createTimeout(#bbballoonautoscroll, pAutoScrollTime, #timeToScrollLines, me.getID(), void(), 1)
      end if
    end if
  end if
end

on timeToScrollLines me 
  if (pState = #normal) and pVisibleBalloons.count() > 0 then
    pLastBalloonId = void()
    pScrollCounter = 0
    pState = #scroll
    receivePrepare(me.getID())
  end if
end
