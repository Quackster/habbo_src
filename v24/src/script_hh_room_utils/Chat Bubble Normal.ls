property pMargins, tVariations, pTextParams, pBalloonImg, pUserSprite, pBgSprite, pBgMemName, pUserMemName, pUserId, pLocation, pBalloonLeftMarg, pBalloonRightMarg, pItemId

on construct me 
  pItemId = void()
  pBgSprite = sprite(reserveSprite(me.getID()))
  pUserSprite = sprite(reserveSprite(me.getID()))
  pUserName = ""
  pUserId = ""
  pSourceLocation = void()
  pMargins = [:]
  pMargins.setAt(#left, 5)
  pMargins.setAt(#right, 6)
  pMargins.setAt(#textleft, 30)
  pBgMemName = ""
  pUserMemName = ""
  tVariations = ["CHAT":"plain", "SHOUT":"bold", "WHISPER":"italic", "OBJECT":"plain"]
  pTextParams = [:]
  i = 1
  repeat while i <= tVariations.count
    tFontStruct = getStructVariable("struct.font." & tVariations.getAt(i))
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
    pTextParams.setAt(tVariations.getPropAt(i), [#member:tmember, #font:tFontStruct.getaProp(#font), #fontStyle:tFontStruct.getaProp(#fontStyle)])
    i = 1 + i
  end repeat
  pBalloonImg = [:]
  #left.addProp(member(getmemnum("chat_bubble_left")), image.duplicate())
  #leftcolor.addProp(member(getmemnum("chat_bubble_left_color")), image.duplicate())
  #middle.addProp(member(getmemnum("chat_bubble_middle")), image.duplicate())
  #right.addProp(member(getmemnum("chat_bubble_right")), image.duplicate())
  #pointer.addProp(member(getmemnum("chat_bubble_pointer")), image.duplicate())
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
  if ilk(pUserSprite) = #sprite then
    removeEventBroker(pUserSprite.spriteNum)
  end if
  if ilk(pBgSprite) = #sprite then
    releaseSprite(pBgSprite.spriteNum)
    pBgSprite = void()
  end if
  if ilk(pUserSprite) = #sprite then
    releaseSprite(pUserSprite.spriteNum)
    pUserSprite = void()
  end if
  if memberExists(pBgMemName) then
    removeMember(pBgMemName)
  end if
  if memberExists(pUserMemName) then
    removeMember(pUserMemName)
  end if
end

on defineBalloon me, tMode, tColor, tUserName, tMessage, tItemID, tUserImg, tUserID, tSourceLoc 
  tNewBgMemName = "chat_item_background_" & tItemID
  tNewUserMemName = "chat_item_user_" & tUserName
  pBgMemName = tNewBgMemName
  if not memberExists(pBgMemName) then
    createMember(pBgMemName, #bitmap)
  end if
  pUserMemName = tNewUserMemName
  if not memberExists(pUserMemName) then
    createMember(pUserMemName, #bitmap)
  end if
  pItemId = tItemID
  tTextImg = me.renderText(tUserName, tMessage, tMode)
  tTextWidth = tTextImg.width
  if ilk(tUserImg) = #image then
    tUserImgWidth = tUserImg.width
  end if
  if ilk(tUserImg) = #image then
    pUserName = tUserName
    pUserId = tUserID
  else
    pUserName = ""
    pUserId = ""
  end if
  tBalloonWidth = pMargins.getAt(#textleft) + tTextWidth + pMargins.getAt(#right)
  tBackgroundImg = me.renderBackground(tBalloonWidth, tColor)
  tTextOffH = pMargins.getAt(#left) + tUserImgWidth + pMargins.getAt(#separator)
  tTextOffH = pMargins.getAt(#textleft)
  tTextOffV = (pBalloonImg.getAt(#middle).height - tTextImg.height / 2) + 1
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
    me.addPointer(tSourceLoc.getAt(1) - tloc.getAt(1))
  end if
  setEventBroker(pUserSprite.spriteNum, me.getID())
  pUserSprite.registerProcedure(#eventProcUserSelect, me.getID(), #mouseDown)
  pUserSprite.setcursor("cursor.finger")
  setEventBroker(pBgSprite.spriteNum, me.getID())
  pBgSprite.registerProcedure(#eventProcUserSelect, me.getID(), #mouseDown)
  return(1)
end

on eventProcUserSelect me, tEvent, tSprID 
  if pUserId <> "" then
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
  return(tNewLocation.getAt(2))
end

on setLocation me, tloc 
  if ilk(tloc) <> #point and ilk(tloc) <> #list then
    return(0)
  end if
  tMem = getMember(pBgMemName)
  if tMem.type = #bitmap then
    tMemWidth = image.width
  else
    return(0)
  end if
  tRelativeLocH = tloc.getAt(1) - (tMemWidth / 2)
  tRelativeLocH = max(tRelativeLocH, pBalloonLeftMarg)
  tRelativeLocH = min(pBgSprite, member - image.width)
  pLocation = tloc
  pBgSprite.loc = point(tRelativeLocH, pLocation.getAt(2))
  tUserSprOffV = (image.height - pBalloonImg.getAt(#middle).height / 2)
  tUserOffH = (member - image.width / 2) + 1
  pUserSprite.loc = point(tUserOffH + tRelativeLocH, pLocation.getAt(2) + (-1 * tUserSprOffV))
  pBgSprite.locZ = getIntVariable("window.default.locz") - 2000 + (pLocation.getAt(2) / 10)
  pUserSprite.locZ = pBgSprite.locZ + 100
  return(point(tRelativeLocH, pLocation.getAt(2)))
end

on addPointer me, tPointerOffH 
  tBalloonWidth = image.width
  if tPointerOffH < pBalloonImg.getAt(#left).width then
    tPointerOffH = pBalloonImg.getAt(#left).width
  else
    if tPointerOffH > tBalloonWidth - pBalloonImg.getAt(#right).width then
      tPointerOffH = tBalloonWidth - pBalloonImg.getAt(#right).width
    end if
  end if
  tStartX = tPointerOffH
  tEndX = tStartX + pBalloonImg.getAt(#pointer).width
  tStartY = pBalloonImg.getAt(#middle).height - 1
  tEndY = tStartY + pBalloonImg.getAt(#pointer).height
  tdestrect = rect(tStartX, tStartY, tEndX, tEndY)
  tBgImg = getMember(pBgMemName).image
  tBgImg.copyPixels(pBalloonImg.getAt(#pointer), tdestrect, pBalloonImg.getAt(#pointer).rect)
end

on getLowPoint me 
  return(pLocation.getAt(2))
end

on getItemId me 
  return(pItemId)
end

on getType me 
  return("NORMAL")
end

on renderBackground me, tWidth, tBalloonColor 
  if tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue >= 600 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = (tBalloonColor.red * 0.9)
    tBalloonColorDarken.green = (tBalloonColor.green * 0.9)
    tBalloonColorDarken.blue = (tBalloonColor.blue * 0.9)
    tBalloonColor = tBalloonColorDarken
  end if
  if tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue <= 100 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = (tBalloonColor.red * 3)
    tBalloonColorDarken.green = (tBalloonColor.green * 3)
    tBalloonColorDarken.blue = (tBalloonColor.blue * 3)
    tBalloonColor = tBalloonColorDarken
  end if
  tNewImg = image(tWidth, pBalloonImg.getAt(#left).height + pBalloonImg.getAt(#pointer).height, 32)
  tStartPointY = 0
  tEndPointY = pBalloonImg.getAt(#left).height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #leftcolor, #middle, #right] <= tBalloonColor
    i = getAt(tBalloonColor, tWidth)
    tStartPointX = tEndPointX
    if [#left, #leftcolor, #middle, #right] = #left then
      tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
      tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
      tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
      tEndPointX = 1
    else
      if [#left, #leftcolor, #middle, #right] = #leftcolor then
        tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tStartPointY + pBalloonImg.getProp(i).height) + rect(0, 1, 0, 1)
        tMatte = pBalloonImg.getProp(i).createMatte()
        tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect, [#bgColor:tBalloonColor, #ink:41, #maskImage:tMatte])
      else
        if [#left, #leftcolor, #middle, #right] = #middle then
          tEndPointX = tEndPointX + tWidth - pBalloonImg.getProp(#left).width - pBalloonImg.getProp(#right).width
          tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
          tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
        else
          if [#left, #leftcolor, #middle, #right] = #right then
            tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
            tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
            tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
          end if
        end if
      end if
    end if
  end repeat
  return(tNewImg)
end

on renderText me, tUserName, tChatMessage, tChatMode 
  tTextParams = pTextParams.getAt(tChatMode)
  tmember = tTextParams.getAt(#member)
  tBoldStruct = getStructVariable("struct.font.bold")
  tText = tUserName & ":" && tChatMessage
  tmember.text = tText
  tmember.font = tTextParams.getAt(#font)
  tmember.fontStyle = tTextParams.getAt(#fontStyle)
  tmember.getPropRef(#char, 1, tUserName.length + 1).font = tBoldStruct.getaProp(#font)
  tmember.getPropRef(#char, 1, tUserName.length + 1).fontStyle = tBoldStruct.getaProp(#fontStyle)
  tTextWidth = tmember.charPosToLoc(tmember.count(#char)).locH + tBoldStruct.getaProp(#fontSize)
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = image.duplicate()
  return(tTextImg)
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
