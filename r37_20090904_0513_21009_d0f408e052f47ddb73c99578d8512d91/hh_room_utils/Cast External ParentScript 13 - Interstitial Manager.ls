property pClickURL, pToolTipSpr, pSprite, pShowTimeOutID, pDownloadTimeOutID, pAdFinished, pAdError, pMemberID, pMemberIDBase, pAdLoaded, pShowAdTime, pDLCounter, pShowCounter

on construct me
  pAdFinished = 0
  pShowTimeOutID = "InterstitialShowTime"
  pDownloadTimeOutID = "InterstitialDownTime"
  pClickURL = EMPTY
  pAdError = 0
  pMemberIDBase = "interstitial-system"
  pMemberID = pMemberIDBase
  pAdLoaded = 0
  pDLCounter = 1
  pShowCounter = 0
  if variableExists("interstitial_ad_show_delay") then
    pShowAdTime = getVariable("interstitial_ad_show_delay")
  else
    pShowAdTime = 4000
  end if
  return 1
end

on deconstruct me
  me.hideTooltip()
  if timeoutExists(pShowTimeOutID) then
    removeTimeout(pShowTimeOutID)
  end if
  if timeoutExists(pDownloadTimeOutID) then
    removeTimeout(pDownloadTimeOutID)
  end if
  if pToolTipSpr.ilk = #sprite then
    releaseSprite(pToolTipSpr.spriteNum)
    pToolTipSpr = VOID
  end if
  return 1
end

on Init me, tSourceURL, tClickURL
  tShowlimit = getVariable("interstitial.max.displays", 5)
  if pShowCounter >= tShowlimit then
    pAdError = 1
    me.adFinished()
    return 0
  end if
  if (tSourceURL = 0) or not (tSourceURL starts "http") then
    pAdError = 1
    me.adFinished()
    return 0
  end if
  pAdError = 0
  pAdLoaded = 0
  if memberExists(pMemberID) then
    removeMember(pMemberID)
  end if
  pDLCounter = pDLCounter + 1
  pMemberID = pMemberIDBase & pDLCounter
  tAdMemNum = queueDownload(tSourceURL, pMemberID, #bitmap, 1, #httpcookie)
  if tAdMemNum < 1 then
    me.adFinished()
    return error(me, "Member not found", #Init, #major)
  end if
  createTimeout(pDownloadTimeOutID, 15000, #adDownloadError, me.getID(), #error, 1)
  registerDownloadCallback(tAdMemNum, #adLoaded, me.getID())
  if not (tClickURL starts "http") then
    pClickURL = VOID
  else
    pClickURL = tClickURL
  end if
end

on getInterstitialMemNum me
  if pAdLoaded then
    return getmemnum(pMemberID)
  else
    return 0
  end if
end

on getInterstitialLink me
  return pClickURL
end

on isAdFinished me
  return pAdFinished
end

on adRequested me
  pClickURL = EMPTY
  pAdFinished = 0
  pAdLoaded = 0
end

on hideTooltip me
  if pToolTipSpr.ilk = #sprite then
    releaseSprite(pToolTipSpr.spriteNum)
    pToolTipSpr = VOID
  end if
end

on adClosed me
  me.hideTooltip()
end

on adLoaded me
  if timeoutExists(pDownloadTimeOutID) then
    removeTimeout(pDownloadTimeOutID)
  end if
  if pAdError = 1 then
    return 0
  end if
  if getMember(pMemberID).type = #empty then
    return me.adImportError()
  end if
  pAdLoaded = 1
  tThread = getThread(#room)
  if tThread = 0 then
    return 0
  end if
  tRoomInt = tThread.getInterface()
  if tRoomInt = 0 then
    return 0
  end if
  tRoomInt.resizeInterstitialWindow()
  createTimeout(pShowTimeOutID, pShowAdTime, #adFinished, me.getID(), VOID, 1)
  pShowCounter = pShowCounter + 1
end

on adImportError me
  error(me, "Interstitial resource error", #adImportError, #minor)
  unregisterMember(pMemberID)
  pAdError = 1
  me.adFinished()
  return 0
end

on adDownloadError me
  error(me, "Interstitial download timeout", #adDownloadError, #minor)
  pAdError = 1
  me.adFinished()
end

on adFinished me
  pAdFinished = 1
  tThread = getThread(#room)
  if tThread = 0 then
    return 0
  end if
  tRoomComp = tThread.getComponent()
  if tRoomComp = 0 then
    return 0
  end if
  tRoomComp.roomPrePartFinished()
end

on ShowToolTip me
  if pToolTipSpr.ilk <> #sprite then
    pToolTipSpr = sprite(reserveSprite(me.getID()))
    pToolTipSpr.ink = 8
    if not memberExists("inttooltip") then
      createToolTipMember(me)
    end if
    pToolTipSpr.member = member(getmemnum("inttooltip"))
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
  pToolTipSpr.locZ = 100000000
end

on createToolTipMember me
  createMember("inttooltip", #bitmap)
  tText = getText("ad_note", "Clicking this advertisement will open a new window")
  tFontStruct = getStructVariable("struct.font.bold")
  tmember = member(createMember("inttooltiptext", #text))
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
  member(getmemnum("inttooltip")).image = tNewImg
  removeMember("inttooltiptext")
end

on eventProc me, tEvent, tSprID, tParm
  if tEvent = #mouseUp then
    if not voidp(pClickURL) then
      if variableExists("interstitial.target") then
        tInterstitialTarget = getVariable("interstitial.target")
      else
        tInterstitialTarget = "external"
      end if
      if tInterstitialTarget = "external" then
        queueDownload(pClickURL, "temp" & the milliSeconds, #text, 1, #httpcookie, #openredirect)
      else
        queueDownload(pClickURL, "temp" & the milliSeconds, #text, 1, #httpcookie, #openredirect, "habboMain")
      end if
    end if
  else
    if (tEvent = #mouseEnter) or (tEvent = #mouseWithin) then
      if not voidp(pClickURL) then
        ShowToolTip(me)
      end if
    else
      if tEvent = #mouseLeave then
        me.hideTooltip()
      end if
    end if
  end if
end
