property pBgSprite, pUserSprite, pLocation, pTextParams, pBalloonImg, pBgMemName, pUserMemName, pItemId, pMargins, tVariations, pUserName, pUserId, pSourceLocation, pBalloonLeftMarg, pBalloonRightMarg

on construct me
  pItemId = VOID
  pBgSprite = sprite(reserveSprite(me.getID()))
  pUserSprite = sprite(reserveSprite(me.getID()))
  pUserName = EMPTY
  pUserId = EMPTY
  pSourceLocation = VOID
  pMargins = [:]
  pMargins[#left] = 5
  pMargins[#right] = 6
  pMargins[#textleft] = 30
  pBgMemName = EMPTY
  pUserMemName = EMPTY
  tVariations = ["CHAT": "plain", "SHOUT": "bold", "WHISPER": "grey", "OBJECT": "plain"]
  pTextParams = [:]
  repeat with i = 1 to tVariations.count
    tFontStruct = getStructVariable("struct.font." & tVariations[i])
    tMemName = "balloon.text." & tVariations.getPropAt(i)
    if not memberExists(tMemName) then
      tmember = member(createMember(tMemName, #text))
    else
      tmember = member(getmemnum(tMemName))
    end if
    tmember.wordWrap = 0
    tmember.boxType = #adjust
    tmember.antialias = 0
    tmember.font = tFontStruct.getaProp(#font)
    tmember.fontSize = tFontStruct.getaProp(#fontSize)
    tmember.fontStyle = tFontStruct.getaProp(#fontStyle)
    tmember.color = tFontStruct.getaProp(#color)
    pTextParams[tVariations.getPropAt(i)] = [#member: tmember, #font: tFontStruct.getaProp(#font), #fontStyle: tFontStruct.getaProp(#fontStyle)]
  end repeat
  pBalloonImg = [:]
  pBalloonImg.addProp(#left, member(getmemnum("chat_bubble_sing_left")).image.duplicate())
  pBalloonImg.addProp(#leftcolor, member(getmemnum("chat_bubble_sing_left_color")).image.duplicate())
  pBalloonImg.addProp(#middle, member(getmemnum("chat_bubble_sing_middle")).image.duplicate())
  pBalloonImg.addProp(#right, member(getmemnum("chat_bubble_sing_right")).image.duplicate())
  pBalloonImg.addProp(#pointer, member(getmemnum("chat_bubble_pointer")).image.duplicate())
  if variableExists("balloons.leftmargin") then
    pBalloonLeftMarg = getIntVariable("balloons.leftmargin", 0)
  else
    pBalloonLeftMarg = 0
  end if
  if variableExists("balloons.rightmargin") then
    pBalloonRightMarg = getIntVariable("balloons.rightmargin", 0)
  else
    pBalloonRightMarg = the stageRight - the stageLeft
  end if
end

on deconstruct me
  if ilk(pBgSprite) = #sprite then
    releaseSprite(pBgSprite.spriteNum)
    pBgSprite = VOID
  end if
  if ilk(pUserSprite) = #sprite then
    releaseSprite(pUserSprite.spriteNum)
    pUserSprite = VOID
  end if
  if memberExists(pBgMemName) then
    removeMember(pBgMemName)
  end if
  if memberExists(pUserMemName) then
    removeMember(pUserMemName)
  end if
end

on defineBalloon me, tMode, tColor, tUserName, tMessage, tItemID, tUserImg, tUserID, tSourceLoc
  tNewBgMemName = "chat_item_sing_background_" & tItemID
  tNewUserMemName = "chat_item_sing_user_" & tUserName & tItemID
  pBgMemName = tNewBgMemName
  if not memberExists(pBgMemName) then
    createMember(pBgMemName, #bitmap)
  end if
  pUserMemName = tNewUserMemName
  if not memberExists(pUserMemName) then
    createMember(pUserMemName, #bitmap)
  end if
  pItemId = tItemID
  tMaxChars = 150
  if tMessage.length > tMaxChars then
    tMessage = chars(tMessage, 0, tMaxChars)
  end if
  tTextImg = me.renderText(tUserName, tMessage, tMode)
  tTextWidth = tTextImg.width
  if ilk(tUserImg) = #image then
    tUserImgWidth = tUserImg.width
  end if
  if ilk(tUserImg) = #image then
    pUserName = tUserName
    pUserId = tUserID
  else
    pUserName = EMPTY
    pUserId = EMPTY
  end if
  tBalloonWidth = pMargins[#textleft] + tTextWidth + pMargins[#right]
  tBackgroundImg = me.renderBackground(tBalloonWidth, tColor)
  tTextOffH = pMargins[#left] + tUserImgWidth + pMargins[#separator]
  tTextOffH = pMargins[#textleft]
  tTextOffV = ((pBalloonImg[#middle].height - tTextImg.height) / 2) + 1
  tTextDestRect = rect(tTextOffH, tTextOffV, tTextOffH + tTextWidth, tTextOffV + tTextImg.height)
  tBackgroundImg.copyPixels(tTextImg, tTextDestRect, tTextImg.rect)
  tBgMem = getMember(pBgMemName)
  tBgMem.image = tBackgroundImg
  tBgMem.regPoint = point(0, 0)
  tUserMem = getMember(pUserMemName)
  if ilk(tUserImg) = #image then
    tUserMem.image = tUserImg
  else
    tUserMem.image = image(1, 1, 8)
  end if
  tUserMem.regPoint = point(0, 0)
  pBgSprite.member = tBgMem
  pUserSprite.member = tUserMem
  pBgSprite.ink = 8
  pUserSprite.ink = 8
  if not voidp(tSourceLoc) then
    tloc = me.setLocation(tSourceLoc)
    me.addPointer(tSourceLoc[1] - tloc[1])
  end if
  setEventBroker(pUserSprite.spriteNum, me.getID())
  pUserSprite.registerProcedure(#eventProcUserSelect, me.getID(), #mouseDown)
  pUserSprite.setcursor("cursor.finger")
  setEventBroker(pBgSprite.spriteNum, me.getID())
  pBgSprite.registerProcedure(#eventProcUserSelect, me.getID(), #mouseDown)
  return 1
end

on eventProcUserSelect me, tEvent, tSprID
  if pUserId <> EMPTY then
    tRoomInterface = getThread(#room).getInterface()
    tRoomInterface.eventProcUserObj(tEvent, pUserId)
  end if
end

on showBalloon me, tVisible
  if voidp(tVisible) then
    tVisible = 1
  end if
  if ilk(pBgSprite) = #sprite then
    pBgSprite.visible = tVisible
  end if
  if ilk(pUserSprite) = #sprite then
    pUserSprite.visible = tVisible
  end if
end

on moveVerticallyBy me, tMoveAmount
  tNewLocation = pLocation + point(0, tMoveAmount)
  me.setLocation(tNewLocation)
  return tNewLocation[2]
end

on setLocation me, tloc
  if (ilk(tloc) <> #point) and (ilk(tloc) <> #list) then
    return 0
  end if
  tMem = getMember(pBgMemName)
  if tMem.type = #bitmap then
    tMemWidth = tMem.image.width
  else
    return 0
  end if
  tRelativeLocH = tloc[1] - (tMemWidth / 2)
  tRelativeLocH = max(tRelativeLocH, pBalloonLeftMarg)
  tRelativeLocH = min(tRelativeLocH, pBalloonRightMarg - pBgSprite.member.image.width)
  pLocation = tloc
  pBgSprite.loc = point(tRelativeLocH, pLocation[2])
  tUserSprOffV = (pUserSprite.member.image.height - pBalloonImg[#middle].height) / 2
  tUserOffH = ((pBalloonImg[#left].width - pUserSprite.member.image.width) / 2) + 1
  pUserSprite.loc = point(tUserOffH + tRelativeLocH, pLocation[2] + (-1 * tUserSprOffV))
  pBgSprite.locZ = getIntVariable("window.default.locz") - 2000 + (pLocation[2] / 10)
  pUserSprite.locZ = pBgSprite.locZ + 100
  return point(tRelativeLocH, pLocation[2])
end

on addPointer me, tPointerOffH
  tBalloonWidth = pBgSprite.member.image.width
  if tPointerOffH < pBalloonImg[#left].width then
    tPointerOffH = pBalloonImg[#left].width
  else
    if tPointerOffH > (tBalloonWidth - pBalloonImg[#right].width) then
      tPointerOffH = tBalloonWidth - pBalloonImg[#right].width
    end if
  end if
  tStartX = tPointerOffH
  tEndX = tStartX + pBalloonImg[#pointer].width
  tStartY = pBalloonImg[#middle].height - 2
  tEndY = tStartY + pBalloonImg[#pointer].height
  tdestrect = rect(tStartX, tStartY, tEndX, tEndY)
  tBgImg = getMember(pBgMemName).image
  tBgImg.copyPixels(pBalloonImg[#pointer], tdestrect, pBalloonImg[#pointer].rect)
end

on getLowPoint me
  return pLocation[2]
end

on getItemId me
  return pItemId
end

on getType me
  return "SING"
end

on renderBackground me, tWidth, tBalloonColor
  if (tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue) >= 600 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = tBalloonColor.red * 0.90000000000000002
    tBalloonColorDarken.green = tBalloonColor.green * 0.90000000000000002
    tBalloonColorDarken.blue = tBalloonColor.blue * 0.90000000000000002
    tBalloonColor = tBalloonColorDarken
  end if
  if (tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue) <= 100 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = tBalloonColor.red * 3
    tBalloonColorDarken.green = tBalloonColor.green * 3
    tBalloonColorDarken.blue = tBalloonColor.blue * 3
    tBalloonColor = tBalloonColorDarken
  end if
  tNewImg = image(tWidth, pBalloonImg[#left].height + pBalloonImg[#pointer].height, 32)
  tStartPointY = 0
  tEndPointY = pBalloonImg[#left].height
  tStartPointX = 0
  tEndPointX = 0
  repeat with i in [#left, #leftcolor, #middle, #right]
    tStartPointX = tEndPointX
    case i of
      #left:
        tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
        tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
        tEndPointX = 1
      #leftcolor:
        tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tStartPointY + pBalloonImg.getProp(i).height) + rect(0, 1, 0, 1)
        tMatte = pBalloonImg.getProp(i).createMatte()
        tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect, [#bgColor: tBalloonColor, #ink: 41, #maskImage: tMatte])
      #middle:
        tEndPointX = tEndPointX + tWidth - pBalloonImg.getProp(#left).width - pBalloonImg.getProp(#right).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
        tSrcWidth = pBalloonImg.getProp(i).width
        repeat with j = 1 to (tdestrect.width / tSrcWidth) + 1
          tTempRect = rect(tStartPointX + (tSrcWidth * (j - 1)), tStartPointY, tStartPointX + (tSrcWidth * j), tEndPointY)
          tSrcRect = pBalloonImg.getProp(i).rect
          if (tStartPointX + (tSrcWidth * j)) > tEndPointX then
            tDiff = tStartPointX + (tSrcWidth * j) - tEndPointX
            tTempRect.right = tTempRect.right - tDiff
            tSrcRect.right = tSrcRect.right - tDiff
          end if
          tNewImg.copyPixels(pBalloonImg.getProp(i), tTempRect, tSrcRect)
        end repeat
      #right:
        tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
        tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
    end case
  end repeat
  return tNewImg
end

on renderText me, tUserName, tChatMessage, tChatMode
  tTextParams = pTextParams[tChatMode]
  tmember = tTextParams[#member]
  tBoldStruct = getStructVariable("struct.font.bold")
  tText = tUserName & ":" && tChatMessage
  tmember.text = tText
  tmember.font = tTextParams[#font]
  tmember.fontStyle = tTextParams[#fontStyle]
  tmember.char[1..tUserName.length + 1].font = tBoldStruct.getaProp(#font)
  tmember.char[1..tUserName.length + 1].fontStyle = tBoldStruct.getaProp(#fontStyle)
  tTextWidth = tmember.charPosToLoc(tmember.char.count).locH + tBoldStruct.getaProp(#fontSize)
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = tmember.image.duplicate()
  return tTextImg
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
