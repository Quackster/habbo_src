property pState, pTextMembers, pScrollCounter, pAvailableBalloons, pVisibleBalloons, pMaxBalloons, pBalloonPulse, pBalloonBuffer, pBalloonImg, pMarginH, pMarginV, pMaxWidth, pMaxCharNum, pAutoScrollTime, pScrollStep, pFastScrollStep, pStartV, pFirstLocz, pMoveOffsetV, pLastBalloonId, pScrollBy, pBalloonColor, pHumanLoc, pLastMsg, pBalloonLeftMarg, pBalloonRightMarg, pReservedSprites, pDefaultTextColor

on construct me
  if variableExists("chat.balloon.scrolltime") then
    pAutoScrollTime = getIntVariable("chat.balloon.scrolltime")
  else
    pAutoScrollTime = 4000
  end if
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
  pMaxBalloons = 6 + 1
  pFirstLocz = getIntVariable("window.default.locz") - 2000 - pMaxBalloons
  pMoveOffsetV = 21
  pMarginH = 8
  pMarginV = 5
  pScrollBy = pScrollStep
  pTextMembers = [:]
  pDefaultTextColor = rgb(0, 0, 0)
  if variableExists("balloon.margin.offset.v") then
    pMarginV = pMarginV + getVariable("balloon.margin.offset.v")
  end if
  tVariations = ["CHAT": "plain", "SHOUT": "bold", "WHISPER": "italic"]
  repeat with i = 1 to tVariations.count
    tFontStruct = getStructVariable("struct.font." & tVariations[i])
    tmember = member(createMember("balloon.text." & tVariations.getPropAt(i), #text))
    tmember.wordWrap = 0
    tmember.boxType = #adjust
    tmember.antialias = 0
    tmember.font = tFontStruct.getaProp(#font)
    tmember.fontSize = tFontStruct.getaProp(#fontSize)
    tmember.fontStyle = tFontStruct.getaProp(#fontStyle)
    pTextMembers[tVariations.getPropAt(i)] = tmember
  end repeat
  if (pMoveOffsetV mod pScrollStep) <> 0 then
    pMoveOffsetV = pMoveOffsetV - (pMoveOffsetV mod pScrollStep)
  end if
  pFastScrollStep = pMoveOffsetV / pScrollStep
  pStartV = ((pMaxBalloons - 1) * pMoveOffsetV) - 1
  pMaxWidth = the stageRight - the stageLeft - 10
  pMaxCharNum = 400
  pReservedSprites = []
  pBalloonImg = [:]
  pBalloonImg.addProp(#left, member(getmemnum("balloon.left")).image.duplicate())
  pBalloonImg.addProp(#middle, member(getmemnum("balloon.middle")).image.duplicate())
  pBalloonImg.addProp(#right, me.flipH(member(getmemnum("balloon.left")).image))
  registerMessage(#leaveRoom, me.getID(), #removeBalloons)
  registerMessage(#changeRoom, me.getID(), #removeBalloons)
  executeMessage(#BalloonManagerCreated, [#objectPointer: me])
  me.resetBalloons()
  return 1
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
  repeat with tSpr in pReservedSprites
    releaseSprite(tSpr)
  end repeat
  repeat with tMem in pTextMembers
    removeMember(tMem.name)
  end repeat
  pReservedSprites = []
  pTextMembers = [:]
  pAvailableBalloons = VOID
  pVisibleBalloons = VOID
  pBalloonBuffer = VOID
  return 1
end

on createballoonImg me, tName, tText, tBalloonColor, tChatMode
  if (tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue) >= 600 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = tBalloonColor.red * 0.90000000000000002
    tBalloonColorDarken.green = tBalloonColor.green * 0.90000000000000002
    tBalloonColorDarken.blue = tBalloonColor.blue * 0.90000000000000002
    tBalloonColor = tBalloonColorDarken
  end if
  if length(tText) > pMaxCharNum then
    tText = tText.char[1..pMaxCharNum]
  end if
  tmember = pTextMembers[tChatMode]
  tSavedFont = tmember.font
  tSavedStyle = tmember.fontStyle
  tmember.rect = rect(0, 0, pMaxWidth, tmember.height)
  tBoldStruct = getStructVariable("struct.font.bold")
  tmember.text = tName & ":" && tText
  tmember.char[1..tName.length + 1].font = tBoldStruct.getaProp(#font)
  tmember.char[1..tName.length + 1].fontStyle = tBoldStruct.getaProp(#fontStyle)
  tSavedColor = tmember.color
  tmember.char[1..tName.length + 1].color = pDefaultTextColor
  tTextWidth = tmember.charPosToLoc(tmember.char.count).locH + (pBalloonImg[#left].width * 4)
  if (tTextWidth + (pMarginH * 2)) > pMaxWidth then
    tTextWidth = pMaxWidth - (pMarginH * 2) - pBalloonImg[#left].width
  end if
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = tmember.image
  tTextWidth = tTextImg.width
  tWidth = tTextWidth + (pMarginH * 2)
  tNewImg = image(tWidth, pBalloonImg[#left].height, 8)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat with i in [#left, #middle, #right]
    tStartPointX = tEndPointX
    case i of
      #left:
        tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
      #middle:
        tEndPointX = tEndPointX + tWidth - pBalloonImg.getProp(#left).width - pBalloonImg.getProp(#right).width
      #right:
        tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
    end case
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect, [#color: tBalloonColor])
  end repeat
  tdestrect = tTextImg.rect + rect(pMarginH, pMarginV, pMarginH, pMarginV)
  tdestrect = tdestrect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(tTextWidth / 2, 0, tTextWidth / 2, 0)
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  tmember.font = tSavedFont
  tmember.fontStyle = tSavedStyle
  tmember.color = tSavedColor
  return tNewImg
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
  repeat with f = 1 to pMaxBalloons
    tSprNum = reserveSprite(me.getID())
    pReservedSprites.add(tSprNum)
    if tSprNum = 0 then
      pMaxBalloons = f - 1
      return 
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
    pAvailableBalloons[tBalloonId].setID(tBalloonId)
    pAvailableBalloons[tBalloonId].set(#sprite, tSprNum)
    pAvailableBalloons[tBalloonId].set(#member, tmember)
    pAvailableBalloons[tBalloonId].set(#loc, point(0, -1000))
    pAvailableBalloons[tBalloonId].set(#manager, me)
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
  pLastBalloonId = VOID
  pState = #normal
  call(#removePulse, pBalloonPulse)
  call(#removeBalloon, pVisibleBalloons)
  call(#removeBalloon, pAvailableBalloons)
  call(#showBalloon, pVisibleBalloons)
  call(#showBalloon, pAvailableBalloons)
  tTempRemoveVisible = pVisibleBalloons.duplicate()
  repeat with f = 1 to tTempRemoveVisible.count
    me.removeVisibleBalloon(tTempRemoveVisible.getPropAt(f))
  end repeat
end

on removeVisibleBalloon me, tid
  if not voidp(pVisibleBalloons[tid]) then
    pAvailableBalloons[tid] = pVisibleBalloons[tid]
    pAvailableBalloons[tid].set(#loc, point(0, -1000))
    pVisibleBalloons.deleteProp(tid)
    return 1
  end if
end

on createBalloon me, tMsg
  if pState = #normal then
    if pAvailableBalloons.count > 0 then
      tUserObj = getThread(#room).getComponent().getUserObject(tMsg[#id])
      if not tUserObj then
        return error(me, "User object not found:" && tMsg[#id], #createBalloon)
      end if
      pBalloonColor = tUserObj.getPartColor("ch")
      if ilk(pBalloonColor) <> #color then
        pBalloonColor = rgb(232, 177, 55)
      end if
      pHumanLoc = tUserObj.getPartLocation("hd")
      tMsg.setaProp(#name, tUserObj.getInfo().getaProp(#name))
      pLastBalloonId = pAvailableBalloons.getPropAt(1)
      pLastMsg = tMsg
      pBalloonPulse.set(#humanLoc, pHumanLoc)
      pBalloonPulse.set(#stoploc, point(pHumanLoc[1], pStartV))
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
    return 
  end if
  tNewBalloon = pAvailableBalloons[1]
  pVisibleBalloons.addProp(pLastBalloonId, tNewBalloon)
  pAvailableBalloons.deleteProp(pLastBalloonId)
  tmember = member(pVisibleBalloons[pLastBalloonId].GET(#member))
  pVisibleBalloons[pLastBalloonId].set(#balloonColor, pBalloonColor)
  tmember.image = me.createballoonImg(tMsg[#name], tMsg[#message], pBalloonColor, tMsg[#command])
  tmember.regPoint = tmember.regPoint + point(0, tmember.image.height / 2)
  pBalloonLeftMarg = getIntVariable("balloons.leftmargin", 0)
  pBalloonRightMarg = getIntVariable("balloons.rightmargin", 720)
  if (pHumanLoc.locH + (tmember.image.width / 2)) > pBalloonRightMarg then
    tStartH = pBalloonRightMarg - (tmember.image.width / 2)
  else
    if (pHumanLoc.locH - (tmember.image.width / 2)) < pBalloonLeftMarg then
      tStartH = pBalloonLeftMarg + (tmember.image.width / 2)
    else
      tStartH = pHumanLoc.locH
    end if
  end if
  pVisibleBalloons[pLastBalloonId].set(#loc, point(tStartH, pStartV))
  pVisibleBalloons[pLastBalloonId].set(#ownerID, tMsg[#id])
  call(#defineBalloon, pVisibleBalloons[pLastBalloonId])
end

on prepare me
  if pState = #scroll then
    if (pScrollCounter + pScrollBy) <= pMoveOffsetV then
      pScrollCounter = pScrollCounter + pScrollBy
      call(#UpdateBalloonPos, pVisibleBalloons, -pScrollBy)
      if not voidp(pLastBalloonId) then
        call(#OpeningBalloon, pBalloonPulse, -pScrollCounter * (pScrollBy * 2))
      end if
    else
      if not voidp(pLastBalloonId) then
        me.showNewBalloon()
      end if
      removePrepare(me.getID())
      pScrollCounter = 0
      pState = #normal
      if pBalloonBuffer.count() > 0 then
        tMsg = pBalloonBuffer[1]
        pBalloonBuffer.deleteAt(1)
        me.createBalloon(tMsg)
      else
        if timeoutExists(#balloonautoscroll) then
          removeTimeout(#balloonautoscroll)
        end if
        createTimeout(#balloonautoscroll, pAutoScrollTime, #timeToScrollLines, me.getID(), VOID, 1)
      end if
    end if
  end if
end

on timeToScrollLines me
  if (pState = #normal) and (pVisibleBalloons.count() > 0) then
    pLastBalloonId = VOID
    pScrollCounter = 0
    pState = #scroll
    receivePrepare(me.getID())
  end if
end

on setProperty me, tMode, tProp, tValue
  if pTextMembers[tMode] < 1 then
    return 0
  end if
  tmember = pTextMembers[tMode]
  case tProp of
    #wordWrap:
      tmember.wordWrap = tValue
    #boxType:
      tmember.boxType = tValue
    #antialias:
      tmember.antialias = tValue
    #font:
      tmember.font = tValue
    #fontSize:
      tmember.fontSize = tValue
    #fontStyle:
      tmember.fontStyle = tValue
    #color:
      tmember.color = tValue
    otherwise:
      return 0
  end case
end

on flipH me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on flipV me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end
