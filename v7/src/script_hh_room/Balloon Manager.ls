property pMaxBalloons, pScrollStep, pTextMembers, pMoveOffsetV, pBalloonImg, pAvailableBalloons, pVisibleBalloons, pBalloonPulse, pReservedSprites, pMaxCharNum, pMaxWidth, pMarginH, pMarginV, pFirstLocz, pState, pHumanLoc, pStartV, pBalloonColor, pLastBalloonId, pBalloonBuffer, pFastScrollStep, pLastMsg, pBalloonRightMarg, pBalloonLeftMarg, pScrollCounter, pScrollBy, pAutoScrollTime

on construct me 
  pState = #normal
  pScrollCounter = 0
  pVisibleBalloons = [:]
  pAvailableBalloons = [:]
  pBalloonBuffer = []
  pAutoScrollTime = 4000
  pMaxBalloons = 6 + 1
  pFirstLocz = getIntVariable("window.default.locz") - 2000 - pMaxBalloons
  pMoveOffsetV = 21
  pScrollStep = 3
  pMarginH = 8
  pMarginV = 5
  pScrollBy = pScrollStep
  pTextMembers = [:]
  tVariations = ["CHAT":"plain", "SHOUT":"bold", "WHISPER":"italic"]
  i = 1
  repeat while i <= tVariations.count
    tFontStruct = getStructVariable("struct.font." & tVariations.getAt(i))
    tmember = member(createMember("balloon.text." & tVariations.getPropAt(i), #text))
    tmember.wordWrap = 0
    tmember.boxType = #adjust
    tmember.antialias = 0
    tmember.font = tFontStruct.getaProp(#font)
    tmember.fontSize = tFontStruct.getaProp(#fontSize)
    tmember.fontStyle = tFontStruct.getaProp(#fontStyle)
    pTextMembers.setAt(tVariations.getPropAt(i), tmember)
    i = 1 + i
  end repeat
  if pMoveOffsetV mod pScrollStep <> 0 then
    pMoveOffsetV = pMoveOffsetV - pMoveOffsetV mod pScrollStep
  end if
  pFastScrollStep = pMoveOffsetV / pScrollStep
  pStartV = pMaxBalloons - 1 * pMoveOffsetV - 1
  pMaxWidth = the stageRight - the stageLeft - 10
  pMaxCharNum = 400
  pReservedSprites = []
  pBalloonImg = [:]
  #left.addProp(member(getmemnum("balloon.left")), image.duplicate())
  #middle.addProp(member(getmemnum("balloon.middle")), image.duplicate())
  pBalloonImg.addProp(#right, me.flipH(member(getmemnum("balloon.left")).image))
  registerMessage(#leaveRoom, me.getID(), #removeBalloons)
  registerMessage(#changeRoom, me.getID(), #removeBalloons)
  me.resetBalloons()
  return(1)
end

on deconstruct me 
  if timeoutExists(#balloonautoscroll) then
    removeTimeout(#balloonautoscroll)
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
  repeat while pReservedSprites <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr)
  end repeat
  repeat while pReservedSprites <= undefined
    tMem = getAt(undefined, undefined)
    removeMember(tMem.name)
  end repeat
  pReservedSprites = []
  pTextMembers = [:]
  pAvailableBalloons = void()
  pVisibleBalloons = void()
  pBalloonBuffer = void()
  return(1)
end

on createballoonImg me, tName, tText, tBalloonColor, tChatMode 
  if tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue >= 600 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = tBalloonColor.red * 0.9
    tBalloonColorDarken.green = tBalloonColor.green * 0.9
    tBalloonColorDarken.blue = tBalloonColor.blue * 0.9
    tBalloonColor = tBalloonColorDarken
  end if
  if length(tText) > pMaxCharNum then
    tText = tText.getProp(#char, 1, pMaxCharNum)
  end if
  tmember = pTextMembers.getAt(tChatMode)
  tSavedFont = tmember.font
  tSavedStyle = tmember.fontStyle
  tmember.rect = rect(0, 0, pMaxWidth, tmember.height)
  tBoldStruct = getStructVariable("struct.font.bold")
  tmember.text = tName & ":" && tText
  tmember.getPropRef(#char, 1, tName.length + 1).font = tBoldStruct.getaProp(#font)
  tmember.getPropRef(#char, 1, tName.length + 1).fontStyle = tBoldStruct.getaProp(#fontStyle)
  tTextWidth = tmember.charPosToLoc(tmember.count(#char)).locH + pBalloonImg.getAt(#left).width * 4
  if tTextWidth + pMarginH * 2 > pMaxWidth then
    tTextWidth = pMaxWidth - pMarginH * 2 - pBalloonImg.getAt(#left).width
  end if
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = tmember.image
  tTextWidth = tTextImg.width
  tWidth = tTextWidth + pMarginH * 2
  tNewImg = image(tWidth, pBalloonImg.getAt(#left).height, 8)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #middle, #right] <= tText
    i = getAt(tText, tName)
    tStartPointX = tEndPointX
    if [#left, #middle, #right] = #left then
      tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
    else
      if [#left, #middle, #right] = #middle then
        tEndPointX = tEndPointX + tWidth - pBalloonImg.getProp(#left).width - pBalloonImg.getProp(#right).width
      else
        if [#left, #middle, #right] = #right then
          tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
        end if
      end if
    end if
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect, [#color:tBalloonColor])
  end repeat
  tdestrect = tTextImg.rect + rect(pMarginH, pMarginV, pMarginH, pMarginV)
  tdestrect = tdestrect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(tTextWidth / 2, 0, tTextWidth / 2, 0)
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  tmember.font = tSavedFont
  tmember.fontStyle = tSavedStyle
  return(tNewImg)
end

on resetBalloons me 
  pVisibleBalloons = [:]
  pAvailableBalloons = [:]
  tSprNum = reserveSprite(me.getID())
  pReservedSprites.add(tSprNum)
  pBalloonPulse = createObject(#temp, "Balloon pulse Class")
  sprite(tSprNum).locZ = pFirstLocz
  sprite(tSprNum).ink = 8
  pBalloonPulse.set(#sprite, tSprNum)
  pBalloonPulse.set(#manager, me)
  f = 1
  repeat while f <= pMaxBalloons
    tSprNum = reserveSprite(me.getID())
    pReservedSprites.add(tSprNum)
    if tSprNum = 0 then
      pMaxBalloons = f - 1
      return()
    end if
    sprite(tSprNum).locZ = pFirstLocz + f - 1
    sprite(tSprNum).ink = 8
    tBalloonId = "balloon" & f
    tmember = "balloon." & tBalloonId
    if not memberExists(tmember) then
      createMember(tmember, #bitmap)
    end if
    tmember = getmemnum(tmember)
    pAvailableBalloons.addProp(tBalloonId, createObject(#temp, "Balloon Class"))
    pAvailableBalloons.getAt(tBalloonId).setID(tBalloonId)
    pAvailableBalloons.getAt(tBalloonId).set(#sprite, tSprNum)
    pAvailableBalloons.getAt(tBalloonId).set(#member, tmember)
    pAvailableBalloons.getAt(tBalloonId).set(#loc, point(0, -1000))
    pAvailableBalloons.getAt(tBalloonId).set(#manager, me)
    f = 1 + f
  end repeat
end

on hideBalloons me 
  call(#hideBalloon, pVisibleBalloons)
  call(#hideBalloon, pAvailableBalloons)
end

on showBalloons me 
  call(#showBalloon, pVisibleBalloons)
  call(#showBalloon, pAvailableBalloons)
end

on removeBalloons me 
  removePrepare(me.getID())
  if timeoutExists(#balloonautoscroll) then
    removeTimeout(#balloonautoscroll)
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
    f = 1 + f
  end repeat
end

on removeVisibleBalloon me, tid 
  if not voidp(pVisibleBalloons.getAt(tid)) then
    pAvailableBalloons.setAt(tid, pVisibleBalloons.getAt(tid))
    pAvailableBalloons.getAt(tid).set(#loc, point(0, -1000))
    pVisibleBalloons.deleteProp(tid)
    return(1)
  end if
end

on createBalloon me, tMsg 
  if pState = #normal then
    if pAvailableBalloons.count > 0 then
      tUserObj = getThread(#room).getComponent().getUserObject(tMsg.getAt(#id))
      if not tUserObj then
        return(error(me, "User object not found:" && tMsg.getAt(#id), #createBalloon))
      end if
      pBalloonColor = tUserObj.getPartColor("ch")
      pHumanLoc = tUserObj.getPartLocation("hd")
      tMsg.setaProp(#name, tUserObj.getInfo().getaProp(#name))
      pLastBalloonId = pAvailableBalloons.getPropAt(1)
      pLastMsg = tMsg
      pBalloonPulse.set(#humanLoc, pHumanLoc)
      pBalloonPulse.set(#stoploc, point(pHumanLoc.getAt(1), pStartV))
      pBalloonPulse.set(#balloonColor, pBalloonColor)
      pBalloonPulse.set(#BalloonId, pLastBalloonId)
      call(#definePulse, pBalloonPulse)
      pScrollCounter = 0
      pState = #scroll
      if pBalloonBuffer.count() = 0 then
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
      me.createBalloon(tMsg)
    end if
  else
    if pState = #scroll then
      if not pBalloonBuffer.getPos(tMsg) then
        pBalloonBuffer.add(tMsg)
      end if
    end if
  end if
end

on showNewBalloon me 
  tMsg = pLastMsg
  if voidp(pLastBalloonId) then
    return()
  end if
  tNewBalloon = pAvailableBalloons.getAt(1)
  pVisibleBalloons.addProp(pLastBalloonId, tNewBalloon)
  pAvailableBalloons.deleteProp(pLastBalloonId)
  tmember = member(pVisibleBalloons.getAt(pLastBalloonId).get(#member))
  pVisibleBalloons.getAt(pLastBalloonId).set(#balloonColor, pBalloonColor)
  tmember.image = me.createballoonImg(tMsg.getAt(#name), tMsg.getAt(#message), pBalloonColor, tMsg.getAt(#command))
  tmember.regPoint.regPoint = 0 + point(tmember, image.height / 2)
  pBalloonLeftMarg = getIntVariable("balloons.leftmargin", 0)
  pBalloonRightMarg = getIntVariable("balloons.rightmargin", 720)
  if tmember + image.width / 2 > pBalloonRightMarg then
    tStartH = tmember - image.width / 2
  else
    if tmember - image.width / 2 < pBalloonLeftMarg then
      tStartH = tmember + image.width / 2
    else
      tStartH = pHumanLoc.locH
    end if
  end if
  pVisibleBalloons.getAt(pLastBalloonId).set(#loc, point(tStartH, pStartV))
  pVisibleBalloons.getAt(pLastBalloonId).set(#ownerID, tMsg.getAt(#id))
  call(#defineBalloon, pVisibleBalloons.getAt(pLastBalloonId))
end

on prepare me 
  if pState = #scroll then
    if pScrollCounter + pScrollBy <= pMoveOffsetV then
      pScrollCounter = pScrollCounter + pScrollBy
      call(#UpdateBalloonPos, pVisibleBalloons, -pScrollBy)
      if not voidp(pLastBalloonId) then
        call(#OpeningBalloon, pBalloonPulse, -pScrollCounter * pScrollBy * 2)
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
        me.createBalloon(tMsg)
      else
        if timeoutExists(#balloonautoscroll) then
          removeTimeout(#balloonautoscroll)
        end if
        createTimeout(#balloonautoscroll, pAutoScrollTime, #timeToScrollLines, me.getID(), void(), 1)
      end if
    end if
  end if
end

on timeToScrollLines me 
  if pState = #normal and pVisibleBalloons.count() > 0 then
    pLastBalloonId = void()
    pScrollCounter = 0
    pState = #scroll
    receivePrepare(me.getID())
  end if
end

on flipH me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on flipV me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end
