property pAdMemNum, pClickURL, pSprite, pState, pFrame, pTimeOutID, pToolTipSpr, pBlendFlag, pRegisteredLayout, pDLCounter, pMemberID, pMemberIDBase

on construct me
  pState = 0
  pFrame = 0
  pTimeOutID = "showAdTimeOut"
  pBlendFlag = 0
  pDLCounter = 0
  pMemberIDBase = "billboard-image"
  pMemberID = pMemberIDBase & pDLCounter
  registerMessage(#leaveRoom, me.getID(), #removeAd)
  registerMessage(#changeRoom, me.getID(), #removeAd)
  registerMessage(#takingPhoto, me.getID(), #hideAd)
  registerMessage(#photoTaken, me.getID(), #showAd)
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if pToolTipSpr.ilk = #sprite then
    releaseSprite(pToolTipSpr.spriteNum)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#takingPhoto, me.getID())
  unregisterMessage(#photoTaken, me.getID())
  me.removeAd()
  return 1
end

on hideAd me
  tThread = getThread(#room)
  if tThread = 0 then
    return 0
  end if
  tVisObj = tThread.getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  if tVisObj.spriteExists("billboard_img") then
    tSpr = tVisObj.getSprById("billboard_img")
    tSpr.visible = 0
  end if
end

on showAd me
  tThread = getThread(#room)
  if tThread = 0 then
    return 0
  end if
  tVisObj = tThread.getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  if tVisObj.spriteExists("billboard_img") then
    tSpr = tVisObj.getSprById("billboard_img")
    tSpr.visible = 1
  end if
end

on Init me, tSourceURL, tClickURL, tRegisteredLayout
  if tSourceURL <> 0 then
    if not (tSourceURL starts "http") then
      pState = 0
      return error(me, "Incorrect URL!", #Init, #minor)
    end if
    pDLCounter = pDLCounter + 1
    pMemberID = pMemberIDBase & pDLCounter
    pAdMemNum = queueDownload(tSourceURL, pMemberID, #bitmap, 1, #httpcookie)
    if not (pAdMemNum > 0) then
      pState = 0
      return error(me, "Incorrect URL!", #Init, #major)
    end if
    pRegisteredLayout = tRegisteredLayout
    member(pAdMemNum).image = image(1, 1, 32)
    member(pAdMemNum).trimWhiteSpace = 0
    registerDownloadCallback(pAdMemNum, #adLoaded, me.getID())
    if not (tClickURL starts "http") then
      pClickURL = VOID
    else
      pClickURL = tClickURL
    end if
    tThread = getThread(#room)
    if tThread = 0 then
      return 0
    end if
    tVisObj = tThread.getInterface().getRoomVisualizer()
    if tVisObj = 0 then
      return 0
    end if
    if tVisObj.spriteExists("billboard_bg") then
      tSprBg = tVisObj.getSprById("billboard_bg")
      tSprImg = tVisObj.getSprById("billboard_img")
      tSprBg.member.paletteRef = member(getmemnum("adframe_palette1"))
      if tSprBg.member.name contains "left" then
        tSprImg.setMember(member(getmemnum("ad_warning_L")))
      else
        tSprImg.setMember(member(getmemnum("ad_warning_R")))
      end if
      tSprBg.blend = 100
      tSprImg.blend = 100
    end if
  else
    pState = 0
    pClickURL = VOID
  end if
end

on adLoaded me
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 5000, #adReady, me.getID(), VOID, 1)
end

on adReady me
  tThread = getThread(#room)
  if tThread = 0 then
    return 0
  end if
  tVisObj = tThread.getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  if member(pAdMemNum).type = #empty then
    unregisterMember(pMemberID)
    return 0
  end if
  if tVisObj.spriteExists("billboard_img") then
    if tVisObj.pLayout <> pRegisteredLayout then
      return 0
    end if
    tSpr = tVisObj.getSprById("billboard_img")
    pSprite = tSpr
    tSpr.setMember(member(pAdMemNum))
    tSpr.width = member(pAdMemNum).width
    tSpr.height = member(pAdMemNum).height
    member(pAdMemNum).trimWhiteSpace = 0
    if pBlendFlag then
      tSpr.blend = 0
      pState = "fadein"
      receiveUpdate(me.getID())
    else
      pState = 0
      tSpr.blend = 100
    end if
    if tVisObj.spriteExists("billboard_bg") then
      tSpr = tVisObj.getSprById("billboard_bg")
      tSpr.member.paletteRef = member(getmemnum("adframe_palette2"))
    end if
    if not voidp(pClickURL) then
      pSprite.setcursor("cursor.finger")
    end if
    pSprite.registerProcedure(#eventProc, me.getID(), #mouseUp)
    pSprite.registerProcedure(#eventProc, me.getID(), #mouseEnter)
    pSprite.registerProcedure(#eventProc, me.getID(), #mouseLeave)
    pSprite.registerProcedure(#eventProc, me.getID(), #mouseWithin)
  end if
end

on removeAd me
  pState = 0
  pSprite = 0
  if pToolTipSpr.ilk = #sprite then
    releaseSprite(pToolTipSpr.spriteNum)
    pToolTipSpr = VOID
  end if
  if memberExists(pMemberID) then
    removeMember(pMemberID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  removeUpdate(me.getID())
end

on ShowToolTip me
  if pToolTipSpr.ilk <> #sprite then
    pToolTipSpr = sprite(reserveSprite(me.getID()))
    pToolTipSpr.ink = 8
    if not memberExists("adtooltip") then
      createToolTipMember(me)
    end if
    pToolTipSpr.member = member(getmemnum("adtooltip"))
  end if
  tNewLoc = the mouseLoc + point(0, 30)
  if (tNewLoc.locV - (pToolTipSpr.height / 2)) < 10 then
    tNewLoc.locV = 10 + (pToolTipSpr.height / 2)
  end if
  if (tNewLoc.locH - (pToolTipSpr.width / 2)) < 10 then
    tNewLoc.locH = 10 + (pToolTipSpr.width / 2)
  end if
  if (tNewLoc.locH + (pToolTipSpr.width / 2)) > ((the stage).rect.width - 10) then
    tNewLoc.locH = (the stage).rect.width - 10 - (pToolTipSpr.width / 2)
  end if
  pToolTipSpr.loc = tNewLoc
end

on createToolTipMember me
  createMember("adtooltip", #bitmap)
  tText = getText("ad_note", "Clicking this advertisement will open a new window")
  tFontStruct = getStructVariable("struct.font.bold")
  tmember = member(createMember("adtooltiptext", #text))
  tmember.wordWrap = 0
  tmember.boxType = #adjust
  tmember.antialias = 0
  tmember.font = tFontStruct.getaProp(#font)
  tmember.fontSize = tFontStruct.getaProp(#fontSize)
  tmember.fontStyle = tFontStruct.getaProp(#fontStyle)
  tmember.text = tText
  tList = ["left": "ad.tooltip.left", "middle": "ad.tooltip.middle", "right": "ad.tooltip.right"]
  tImgs = [:]
  repeat with i in ["left", "middle", "right"]
    tImgs.addProp(i, member(getmemnum(tList[i])).image)
  end repeat
  tTextWidth = tmember.charPosToLoc(tmember.char.count).locH + (tImgs["left"].width * 2)
  tWidth = tTextWidth + 9
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = tmember.image
  tNewImg = image(tWidth, tImgs["left"].height, 8)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat with i in ["left", "middle", "right"]
    tStartPointX = tEndPointX
    case i of
      "left":
        tEndPointX = tEndPointX + tImgs.getProp(i).width
      "middle":
        tEndPointX = tEndPointX + tWidth - tImgs.getProp("left").width - tImgs.getProp("right").width
      "right":
        tEndPointX = tEndPointX + tImgs.getProp(i).width
    end case
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(tImgs.getProp(i), tdestrect, tImgs.getProp(i).rect)
  end repeat
  tMarginH = tImgs.getProp("left").width + 8
  tMarginV = (tNewImg.height - tTextImg.height) / 2
  tdestrect = tTextImg.rect + rect(tMarginH, tMarginV, tMarginH, tMarginV)
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  member(getmemnum("adtooltip")).image = tNewImg
  removeMember("adtooltiptext")
end

on update me
  if pState = 0 then
    removeUpdate(me.getID())
    return 
  end if
  pFrame = not pFrame
  if pFrame then
    return 
  end if
  case pState of
    "fadein":
      if pSprite.blend < 100 then
        pSprite.blend = pSprite.blend + 10
      else
        pState = 0
      end if
  end case
end

on eventProc me, tEvent, tSprID, tParm
  if stringp(tParm) then
    tClickURL = tParm
  else
    tClickURL = pClickURL
  end if
  if tEvent = #mouseUp then
    if not voidp(tClickURL) then
      queueDownload(tClickURL, "temp" & the milliSeconds, #text, 1, #httpcookie, #openredirect)
    end if
  else
    if (tEvent = #mouseEnter) or (tEvent = #mouseWithin) then
      if not voidp(tClickURL) then
        ShowToolTip(me)
      end if
    else
      if tEvent = #mouseLeave then
        if pToolTipSpr.ilk = #sprite then
          pToolTipSpr.locH = the stageRight + 1000
        end if
      end if
    end if
  end if
end
