property pWindowTitle, pVoucherWindowTitle, pVoucherInputState, pOpenWindow, pPageView, pPages, pPageList, pPurseWriterID, pPageLineHeight, pPurseBigTextWriterID, pPurseBigTextWriter2ID, pItemObjList, pClickURL, pAdMemNum, pFrameCounter, pQuad, pAnimImage, pState, pValueField, pDataReceived

on construct me
  pWindowTitle = getText("win_purse", "Habbo Purse")
  pVoucherWindowTitle = getText("win_voucher", "Habbo Credit Code")
  pVoucherInputState = 1
  pPageView = 1
  pPageLineHeight = 20
  pPageList = []
  pPurseWriterID = getUniqueID()
  pPurseBigTextWriterID = getUniqueID()
  pPurseBigTextWriter2ID = getUniqueID()
  pItemObjList = []
  pFrameCounter = 0
  pDataReceived = 0
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#000000")]
  createWriter(pPurseWriterID, tMetrics)
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE"), #bgColor: rgb("#AF8349"), #fontSize: 18, #topSpacing: 3, #fixedLineSpace: 25]
  createWriter(pPurseBigTextWriterID, tMetrics)
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#000000"), #bgColor: rgb("#6E6E6E"), #fontSize: 18, #topSpacing: 3, #fixedLineSpace: 21]
  createWriter(pPurseBigTextWriter2ID, tMetrics)
  if textExists("purse_ad_url") then
    tClickURL = getText("purse_Click_url", VOID)
    tAdURL = getText("purse_ad_url", VOID)
    me.getPurseAd(tAdURL, tClickURL)
  end if
  if variableExists("purse.transactions.active") then
    tActive = getVariable("purse.transactions.active")
    getObject(#session).set("purse_transactions", tActive)
  else
    getObject(#session).set("purse_transactions", 1)
  end if
  if variableExists("purse.valuefield.active") then
    pValueField = getVariable("purse.valuefield.active")
  else
    pValueField = 0
  end if
  registerMessage(#updateFilmCount, me.getID(), #updatePurseFilm)
  return 1
end

on deconstruct me
  unregisterMessage(#updateFilmCount, me.getID())
  removeUpdate(me.getID())
  removeWindow(pWindowTitle)
  removeWindow(pVoucherWindowTitle)
  removeWriter(pPurseWriterID)
  if timeoutExists("flyTimer") then
    removeTimeout("flyTimer")
  end if
  return 1
end

on showHidePurse me, tHideOrRemove
  if windowExists(pWindowTitle) then
    me.hidePurse()
  else
    me.showPurse()
  end if
end

on showPurse me
  if not windowExists(pWindowTitle) then
    me.changePurseWindowView("purse.window")
    return 1
  else
    return 0
  end if
end

on hidePurse me, tHideOrRemove
  if voidp(tHideOrRemove) then
    tHideOrRemove = #Remove
  end if
  if windowExists(pWindowTitle) then
    if tHideOrRemove = #Remove then
      removeWindow(pWindowTitle)
    else
      getWindow(pWindowTitle).hide()
    end if
  end if
  if timeoutExists("flyTimer") then
    removeTimeout("flyTimer")
  end if
  return 1
end

on showPurseLoader me, tdata
  tWndObj = getWindow(pWindowTitle)
  tBg = tWndObj.getElement("loading_bg")
  tAnim = tWndObj.getElement("loading_anim")
  tText = tWndObj.getElement("loading")
  tPrev = tWndObj.getElement("taction_prev")
  tPages = tWndObj.getElement("taction_pages")
  tNext = tWndObj.getElement("taction_next")
  case tdata of
    0:
      tBg.setProperty(#blend, 0)
      tAnim.setProperty(#blend, 0)
      tText.setProperty(#blend, 0)
      removeUpdate(me.getID())
      pState = 0
    1:
      tBg.setProperty(#blend, 90)
      tAnim.setProperty(#blend, 100)
      tText.setProperty(#blend, 100)
      tPrev.setProperty(#blend, 0)
      tPages.setProperty(#blend, 0)
      tNext.setProperty(#blend, 0)
      me.showLoading()
      pState = 1
  end case
end

on showLoading me
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj then
    return 0
  end if
  if tWndObj.elementExists("loading_anim") then
    pAnimImage = member(getmemnum("loading_icon")).image
    pQuad = [point(0, 0), point(pAnimImage.width, 0), point(pAnimImage.width, pAnimImage.height), point(0, pAnimImage.height)]
  end if
  update(me)
  receiveUpdate(me.getID())
end

on setVoucherInput me, tstate
  pVoucherInputState = tstate
  if not windowExists(pVoucherWindowTitle) then
    return 1
  end if
  tWndObj = getWindow(pVoucherWindowTitle)
  if pVoucherInputState then
    tWndObj.getElement("voucher_statustext").setText(getText("purse_vouchers_entercode"))
    tWndObj.getElement("loading_bg").hide()
    tCursor = "cursor.finger"
  else
    tWndObj.getElement("voucher_statustext").setText(getText("purse_vouchers_checking"))
    tWndObj.getElement("loading_bg").show()
    tCursor = 0
  end if
  tWndObj.getElement("voucher_code").setEdit(pVoucherInputState)
  tWndObj.getElement("voucher_exit").setProperty(#cursor, tCursor)
  tWndObj.getElement("voucher_send").setProperty(#cursor, tCursor)
  return 1
end

on showVoucherWindow me
  if not windowExists(pVoucherWindowTitle) then
    createWindow(pVoucherWindowTitle, "habbo_basic.window")
    tWndObj = getWindow(pVoucherWindowTitle)
    if not tWndObj then
      return 0
    end if
    if not tWndObj.merge("PurseVouchers.window") then
      return tWndObj.close()
    end if
    tWndObj.center()
    tWndObj.moveBy(80, 50)
    if not (getText("purse_vouchers_helpurl") starts "http") then
      tWndObj.getElement("voucher_help").hide()
    end if
    me.setVoucherInput(pVoucherInputState)
    if tWndObj.elementExists("voucher_code") then
      tWndObj.getElement("voucher_code").setFocus(1)
    end if
    tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseUp)
  end if
end

on hideVoucherWindow me
  if windowExists(pVoucherWindowTitle) then
    removeWindow(pVoucherWindowTitle)
  end if
  return 1
end

on update me
  if not pState then
    return 
  end if
  if pFrameCounter > 0 then
    tWinObj = getWindow(pWindowTitle)
    if not tWinObj then
      removeUpdate(me.getID())
    end if
    if not tWinObj then
      return 0
    end if
    tid = "loading_anim"
    if tWinObj.elementExists(tid) then
      t1 = pQuad[1]
      t2 = pQuad[2]
      t3 = pQuad[3]
      t4 = pQuad[4]
      pQuad = [t2, t3, t4, t1]
      tImage = tWinObj.getElement(tid).getProperty(#image)
      tImage.copyPixels(pAnimImage, pQuad, pAnimImage.rect)
      tWinObj.getElement(tid).feedImage(tImage)
    else
      removeUpdate(me.getID())
    end if
    pFrameCounter = 1
  end if
  pFrameCounter = pFrameCounter + 1
end

on showPages me, tList
  if not voidp(tList) then
    pPageList = tList
    pPages = count(pPageList)
    me.drawPage(1)
    me.showPurseLoader(0)
  else
    me.changePurseWindowView("PurseNoTransactions.window")
    me.showPurseLoader(0)
  end if
end

on drawPage me, tPageNo
  if (tPageNo <= pPages) and (tPageNo > 0) then
    tWndObj = getWindow(pWindowTitle)
    tDate = []
    tTime = []
    tEvent = []
    tDesc = []
    tValue = []
    tList = pPageList[tPageNo]
    tLista = []
    repeat with i = 1 to count(tList)
      tTxt = replaceChunks(tList[i]["date"], "-", ".")
      tDate.add(tTxt)
      tTime.add(tList[i]["time"])
      tEvent.add(tList[i]["credit_value"])
      tText = tList[i]["transaction_system_name"]
      tDesc.add(getText("transaction_system_" & tText))
      tValue.add(tList[i]["real_value"])
    end repeat
    me.drawColumns("purse_field1", tDate, 8)
    me.drawColumns("purse_field2", tTime, 8)
    me.drawColumns("purse_field3", tEvent, 20)
    me.drawColumns("purse_field4", tDesc, 8)
    if pValueField then
      me.drawColumns("purse_field5", tValue, 20)
    end if
    pPageView = tPageNo
    tPrev = tWndObj.getElement("taction_prev")
    tPages = tWndObj.getElement("taction_pages")
    tNext = tWndObj.getElement("taction_next")
    tPAgesTxt = pPageView & "/" & pPages
    tPages.setProperty(#blend, 100)
    tPages.setText(tPAgesTxt)
    tPrevTtx = getText("previous_onearrowed", "< Previous")
    tPrev.setText(tPrevTtx)
    tNextTtx = getText("next_onearrowed", "Next >")
    tNext.setText(tNextTtx)
    case 1 of
      (pPages = 1):
        tPrev.setProperty(#blend, 50)
        tPrev.setProperty(#cursor, 0)
        tNext.setProperty(#blend, 50)
        tNext.setProperty(#cursor, 0)
        return 1
      ((pPageView < pPages) and (pPageView > 1)):
        tPrev.setProperty(#blend, 100)
        tPrev.setProperty(#cursor, "cursor.finger")
        tNext.setProperty(#blend, 100)
        tNext.setProperty(#cursor, "cursor.finger")
        return 1
      ((pPageView < pPages) and (pPageView = 1)):
        tPrev.setProperty(#blend, 50)
        tPrev.setProperty(#cursor, 0)
        tNext.setProperty(#blend, 100)
        tNext.setProperty(#cursor, "cursor.finger")
        return 1
      (pPageView = pPages):
        tPrev.setProperty(#blend, 100)
        tPrev.setProperty(#cursor, "cursor.finger")
        tNext.setProperty(#blend, 50)
        tNext.setProperty(#cursor, 0)
        return 1
    end case
  else
    return 0
  end if
end

on drawColumns me, tElementName, tList, tLeftMarg
  tWndObj = getWindow(pWindowTitle)
  tWriteObj = getWriter(pPurseWriterID)
  if tWndObj.elementExists(tElementName) then
    tElem = tWndObj.getElement(tElementName)
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tVerticMarg = (pPageLineHeight - tWriteObj.getFont()[#lineHeight]) / 2
    if voidp(tLeftMarg) then
      tLeftMarg = 8
    end if
    tPageCounter = tList.count
    tImgHeight = (pPageLineHeight * tPageCounter) + 1
    tPageListImg = image(tWidth - tLeftMarg, tImgHeight, 8)
    repeat with f = 1 to tList.count
      tText = tList[f]
      tPageImg = tWriteObj.render(tText)
      tMarg = tLeftMarg
      if (value(tText) < 0) and (tElementName = "purse_field3") then
        tLeftMarg = tLeftMarg - 5
      end if
      tX1 = tLeftMarg
      tX2 = tX1 + tPageImg.width
      tY1 = tVerticMarg + (pPageLineHeight * (f - 1))
      tY2 = tY1 + tPageImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      tPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect)
      tLeftMarg = tMarg
    end repeat
    tElem.feedImage(tPageListImg.duplicate())
  end if
end

on getPurseAd me, tSourceURL, tClickURL
  if tSourceURL = EMPTY then
    tSourceURL = VOID
  end if
  if not voidp(tSourceURL) then
    if not (tSourceURL starts "http") then
      return error(me, "Incorrect URL!", #getPurseAd)
    end if
    if not memberExists("purse-ad") then
      pAdMemNum = queueDownload(tSourceURL, "purse-ad", #bitmap, 1)
    end if
    if not (tClickURL starts "http") then
      pClickURL = VOID
    else
      pClickURL = tClickURL
    end if
  end if
end

on showPurseAd me
  tWndObj = getWindow(pWindowTitle)
  if memberExists("purse-ad") and tWndObj.elementExists("trans_ad") then
    tWndObj = getWindow(pWindowTitle)
    tElem = tWndObj.getElement("trans_ad")
    tSourceImg = member(pAdMemNum).image
    tDestImg = tElem.getProperty(#image)
    tdestrect = tDestImg.rect
    tSourceRect = tSourceImg.rect
    tRectList = rect(tdestrect[1], tdestrect[2], tdestrect[3], tdestrect[4])
    tSrcWidth = tSourceImg.width
    tDestWidth = tDestImg.width
    tSrcHeight = tSourceImg.height
    tDestHeight = tDestImg.height
    if tSrcWidth < tDestWidth then
      tRectList[1] = (tDestWidth - tSrcWidth) / 2
      tRectList[3] = tDestWidth - ((tDestWidth - tSrcWidth) / 2)
    else
      if tSrcWidth > tDestWidth then
        tSourceRect[1] = tdestrect[1]
        tSourceRect[3] = tdestrect[3]
      end if
    end if
    if tSrcHeight < tDestHeight then
      tRectList[2] = (tDestHeight - tSrcHeight) / 2
      tRectList[4] = tDestHeight - ((tDestHeight - tSrcHeight) / 2)
    else
      if tSrcHeight > tDestHeight then
        tSourceRect[2] = tdestrect[2]
        tSourceRect[4] = tdestrect[4]
      end if
    end if
    tDestImg.copyPixels(tSourceImg, tRectList, tSourceRect)
    tElem.feedImage(tDestImg)
  else
    return 0
  end if
end

on changePurseWindowView me, tWindowName
  if tWindowName = "purse.window" then
    if not createWindow(pWindowTitle, tWindowName) then
      return 0
    end if
  else
    if not createWindow(pWindowTitle, "habbo_full.window") then
      return 0
    end if
  end if
  tWndObj = getWindow(pWindowTitle)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseDown)
  tWndObj.center()
  pOpenWindow = tWindowName
  case tWindowName of
    "purse.window":
      i = 1
      repeat while 1
        if tWndObj.elementExists("fly_" & i) then
          tElement = tWndObj.getElement("fly_" & i)
          tElement.setProperty(#visible, 0)
          i = i + 1
          next repeat
        end if
        exit repeat
      end repeat
      tTxt1 = getText("purse_youhave", "You have")
      if tWndObj.elementExists("youhave") then
        tWndObj.getElement("youhave").setText(tTxt1)
      end if
      tSaldo = me.checkSaldo("purse_amount")
      tTxt1 = getText("purse_coins", "Habbo credits")
      if tWndObj.elementExists("coins") then
        tWndObj.getElement("coins").setText(tTxt1)
      end if
      tMyName = getObject(#session).GET(#userName)
      if tWndObj.elementExists("purse_name") then
        tWndObj.getElement("purse_name").setText(tMyName)
      end if
      if not getObject(#session).GET("conf_voucher") then
        tWndObj.getElement("purse_voucher").setProperty(#blend, 50)
        tWndObj.getElement("purse_voucher").setProperty(#cursor, 0)
      end if
      me.drawPurseCoins(tSaldo)
      me.updatePurseTickets()
      me.updatePurseFilm()
      return 1
    "PurseTransactions2.window":
      if not tWndObj.merge("PurseTransactions2.window") then
        return tWndObj.close()
      end if
      tWndObj.center()
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseLeave)
      me.showPurseAd()
      if objectExists("Figure_Preview") then
        getObject("Figure_Preview").createHumanPartPreview(pWindowTitle, "habbo_head", ["hd", "fc", "ey", "hr"])
      end if
      if tWndObj.elementExists("header_name") then
        tWndObj.getElement("header_name").setText(getObject(#session).GET("user_name"))
      end if
      tTxt1 = getText("purse_date", "DATE")
      if tWndObj.elementExists("taction_date") then
        tWndObj.getElement("taction_date").setText(tTxt1)
      end if
      tTxt1 = getText("purse_time", "TIME")
      if tWndObj.elementExists("taction_time") then
        tWndObj.getElement("taction_time").setText(tTxt1)
      end if
      tTxt1 = getText("purse_event", "EVENT")
      if tWndObj.elementExists("taction_event") then
        tWndObj.getElement("taction_event").setText(tTxt1)
      end if
      tTxt1 = getText("purse_info", "DESCRIPTION")
      if tWndObj.elementExists("taction_info") then
        tWndObj.getElement("taction_info").setText(tTxt1)
      end if
      tTxt1 = getText("purse_value", "VALUE")
      if tWndObj.elementExists("taction_value") then
        tWndObj.getElement("taction_value").setText(tTxt1)
      end if
      tMyName = getObject(#session).GET(#userName)
      if tWndObj.elementExists("taction_name") then
        tWriteObj = getWriter(pPurseBigTextWriterID)
        tElem = tWndObj.getElement("taction_name")
        tWidth = tElem.getProperty(#width)
        tHeight = tElem.getProperty(#height)
        tText = tMyName
        tPageImg = tWriteObj.render(tText)
        tImgHeight = tPageImg.height
        tPageListImg = image(tWidth, tImgHeight, 8)
        tX2 = tPageImg.width
        tY1 = (tHeight - tPageImg.height) / 2
        tY2 = tY1 + tPageImg.height
        tDstRect = rect(0, tY1, tX2, tY2)
        tPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect, [#ink: 36])
        tElem.feedImage(tPageListImg.duplicate())
      end if
      tTxt1 = getText("purse_note", "Note this!")
      if tWndObj.elementExists("tactions_note") then
        tWndObj.getElement("tactions_note").setText(tTxt1)
      end if
      tTxt1 = getText("loading", "loading")
      if tWndObj.elementExists("loading") then
        tWndObj.getElement("loading").setText(tTxt1)
      end if
    "PurseTransactions.window":
      if not tWndObj.merge("PurseTransactions.window") then
        return tWndObj.close()
      end if
      tWndObj.center()
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseLeave)
      me.showPurseAd()
      tTxt1 = getText("purse_head", "ACCOUNT TRANSACTIONS")
      if tWndObj.elementExists("header2") then
        tWndObj.getElement("header2").setText(tTxt1)
      end if
      tTxt1 = getText("purse_date", "DATE")
      if tWndObj.elementExists("taction_date") then
        tWndObj.getElement("taction_date").setText(tTxt1)
      end if
      tTxt1 = getText("purse_time", "TIME")
      if tWndObj.elementExists("taction_time") then
        tWndObj.getElement("taction_time").setText(tTxt1)
      end if
      tTxt1 = getText("purse_event", "EVENT")
      if tWndObj.elementExists("taction_event") then
        tWndObj.getElement("taction_event").setText(tTxt1)
      end if
      tTxt1 = getText("purse_info", "DESCRIPTION")
      if tWndObj.elementExists("taction_info") then
        tWndObj.getElement("taction_info").setText(tTxt1)
      end if
      tMyName = getObject(#session).GET(#userName)
      if tWndObj.elementExists("taction_name") then
        tWriteObj = getWriter(pPurseBigTextWriterID)
        tElem = tWndObj.getElement("taction_name")
        tWidth = tElem.getProperty(#width)
        tHeight = tElem.getProperty(#height)
        tText = tMyName
        tPageImg = tWriteObj.render(tText)
        tImgHeight = tPageImg.height
        tPageListImg = image(tWidth, tImgHeight, 8)
        tX2 = tPageImg.width
        tY1 = (tHeight - tPageImg.height) / 2
        tY2 = tY1 + tPageImg.height
        tDstRect = rect(0, tY1, tX2, tY2)
        tPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect, [#ink: 36])
        tElem.feedImage(tPageListImg.duplicate())
      end if
      tTxt1 = getText("purse_note", "Note this!")
      if tWndObj.elementExists("tactions_note") then
        tWndObj.getElement("tactions_note").setText(tTxt1)
      end if
      tTxt1 = getText("loading", "loading")
      if tWndObj.elementExists("loading") then
        tWndObj.getElement("loading").setText(tTxt1)
      end if
    "PurseNoTransactions.window":
      if not tWndObj.merge("PurseNoTransactions.window") then
        return tWndObj.close()
      end if
      tWndObj.center()
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcPurse, me.getID(), #mouseLeave)
      me.showPurseAd()
      tTxt1 = getText("purse_head", "ACCOUNT TRANSACTIONS")
      if tWndObj.elementExists("header2") then
        tWndObj.getElement("header2").setText(tTxt1)
      end if
      tMyName = getObject(#session).GET(#userName)
      if tWndObj.elementExists("taction_name") then
        tWriteObj = getWriter(pPurseBigTextWriterID)
        tElem = tWndObj.getElement("taction_name")
        tWidth = tElem.getProperty(#width)
        tHeight = tElem.getProperty(#height)
        tText = tMyName
        tPageImg = tWriteObj.render(tText)
        tImgHeight = tPageImg.height
        tPageListImg = image(tWidth, tImgHeight, 8)
        tX2 = tPageImg.width
        tY1 = (tHeight - tPageImg.height) / 2
        tY2 = tY1 + tPageImg.height
        tDstRect = rect(0, tY1, tX2, tY2)
        tPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect, [#ink: 36])
        tElem.feedImage(tPageListImg.duplicate())
      end if
      tTxt1 = getText("purse_buy_coins", "Buy Coins")
      if tWndObj.elementExists("purse_buy") then
        tWndObj.getElement("purse_buy").prepare()
      end if
      tTxt1 = getText("purse_noevents", "Text.....")
      if tWndObj.elementExists("no_tactions") then
        tTxt1 = replaceChunks(tTxt1, "\r", RETURN)
        tWndObj.getElement("no_tactions").setText(tTxt1)
      end if
  end case
end

on drawPurseCoins me, tCoinAmount
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElemID = "purse_main"
  tImage = "purse_coin"
  tImage1 = "purse_coin_sd"
  tImage2 = "purse_coins"
  tElem = tWndObj.getElement(tElemID)
  tDestImg = tElem.getProperty(#image)
  tSourceImg = member(getmemnum(tImage)).image
  tSourceImg1 = member(getmemnum(tImage1)).image
  tSourceImg2 = member(getmemnum(tImage2)).image
  tdestrect = tDestImg.rect
  case 1 of
    (tCoinAmount = 0), (tCoinAmount = VOID):
      tElem.clearBuffer()
      tElem.clearImage()
      me.drawFlies()
    (tCoinAmount > 100):
      if timeoutExists("flyTimer") then
        removeTimeout("flyTimer")
        call(#hideFlies, pItemObjList)
      end if
      tElem.clearBuffer()
      tElem.clearImage()
      tRect = tSourceImg2.rect
      tRectList = rect(tdestrect[1], tdestrect[2], tRect[3], tRect[4])
      tDestImg.copyPixels(tSourceImg2, tRectList, tRect)
      tElem.feedImage(tDestImg)
    ((tCoinAmount > 0) and (tCoinAmount <= 100)):
      tElem.clearBuffer()
      tElem.clearImage()
      if timeoutExists("flyTimer") then
        removeTimeout("flyTimer")
        call(#hideFlies, pItemObjList)
      end if
      tStackCount = 0
      tV = 10
      tW = 31
      tDestImg.copyPixels(tSourceImg1, rect(tV, 80, tW, 92), tSourceImg1.rect, [#blend: 70])
      repeat with i = 1 to tCoinAmount
        tX = 82
        tY = 97
        tStackCount = tStackCount + 1
        if tStackCount = 11 then
          tV = tV + 25
          tW = tW + 25
          tX = 82
          tY = 97
          tStackCount = 1
          tDestImg.copyPixels(tSourceImg1, rect(tV, tX - 2, tW, tY - 5), tSourceImg1.rect, [#blend: 70])
        end if
        tX = tX - (7 * tStackCount)
        tY = tY - (7 * tStackCount)
        tDestImg.copyPixels(tSourceImg, rect(tV, tX, tW, tY), tSourceImg.rect, [#ink: 36])
      end repeat
      tElem.feedImage(tDestImg)
  end case
end

on drawFlies me
  tWndObj = getWindow(pWindowTitle)
  pItemObjList = []
  i = 1
  repeat while 1
    tSpr = tWndObj.getElement("fly_" & i)
    if tSpr <> 0 then
      tObj = createObject(#temp, "Purse Fly Class")
      tObj.define(tSpr, i)
      pItemObjList.add(tObj)
    else
      exit repeat
    end if
    i = i + 1
  end repeat
  if not timeoutExists("flyTimer") then
    createTimeout("flyTimer", 120, #fliesFly, me.getID(), VOID, 0)
  end if
end

on fliesFly me
  if pOpenWindow = "purse.window" then
    call(#animateFly, pItemObjList)
  end if
end

on checkSaldo me, tElement
  if getObject(#session).exists("user_walletbalance") then
    tSaldo = getObject(#session).GET("user_walletbalance")
  else
    tSaldo = VOID
  end if
  if windowExists(pWindowTitle) then
    tWndObj = getWindow(pWindowTitle)
    if tWndObj.elementExists(tElement) then
      tWriteObj = getWriter(pPurseBigTextWriter2ID)
      tElem = tWndObj.getElement(tElement)
      tWidth = tElem.getProperty(#width)
      tHeight = tElem.getProperty(#height)
      tText = string(tSaldo)
      tPageImg = tWriteObj.render(tText)
      tImgHeight = tPageImg.height
      tPageListImg = image(tWidth, tImgHeight, 8)
      tX1 = (tWidth - tPageImg.width) / 2
      tX2 = tX1 + tPageImg.width
      tY1 = (tHeight - tPageImg.height) / 2
      tY2 = tY1 + tPageImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      tPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect, [#ink: 36])
      tElem.feedImage(tPageListImg.duplicate())
    end if
  end if
  return tSaldo
end

on dataReceived me
  pDataReceived = 1
end

on updatePurseSaldo me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  if pOpenWindow <> "purse.window" then
    return 0
  end if
  tSaldo = me.checkSaldo("purse_amount")
  me.drawPurseCoins(tSaldo)
  return 1
end

on updatePurseTickets me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  if tWndObj.elementExists("purse_info_tickets") then
    tFieldTxt = getObject(#session).GET("user_ph_tickets") && getText("purse_info_tickets")
    tWndObj.getElement("purse_info_tickets").setText(tFieldTxt)
  end if
  return 1
end

on updatePurseFilm me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  if tWndObj.elementExists("purse_info_film") then
    tFieldTxt = getObject(#session).GET("user_photo_film") && getText("purse_info_film")
    tWndObj.getElement("purse_info_film").setText(tFieldTxt)
  end if
  return 1
end

on eventProcPurse me, tEvent, tElemID, tParm
  if not voidp(pClickURL) then
    tWndObj = getWindow(pWindowTitle)
    tElem = tWndObj.getElement("trans_ad")
    if (tEvent = #mouseEnter) or (tEvent = #mouseWithin) then
      if tElemID = "trans_ad" then
        tElem.setProperty(#cursor, "cursor.finger")
      end if
    end if
    if tEvent = #mouseLeave then
      if tElemID = "trans_ad" then
        tElem.setProperty(#cursor, 0)
      end if
    end if
  end if
  if tEvent = #mouseUp then
    case tElemID of
      "trans_ad":
        if not voidp(pClickURL) then
          openNetPage(pClickURL)
        end if
      "purse_view":
        if pValueField then
          tWnd = "PurseTransactions.window"
        else
          tWnd = "PurseTransactions2.window"
        end if
        if (count(pPageList) = 0) and (pDataReceived = 0) then
          me.changePurseWindowView(tWnd)
          me.showPurseLoader(1)
          getConnection(getVariableValue("connection.info.id")).send("GETUSERCREDITLOG")
        else
          if count(pPageList) = 0 then
            tWnd = "PurseNoTransactions.window"
          end if
          me.changePurseWindowView(tWnd)
          me.showPages(pPageList)
        end if
        if timeoutExists("flyTimer") then
          removeTimeout("flyTimer")
        end if
      "show_credits":
        me.changePurseWindowView("purse.window")
      "taction_next":
        me.drawPage(pPageView + 1)
      "taction_prev":
        me.drawPage(pPageView - 1)
      "purse_buy":
        tSession = getObject(#session)
        if tSession.GET("user_rights").getOne("can_buy_credits") then
          tURL = getText("url_purselink")
        else
          tURL = getText("url_purse_subscribe")
        end if
        tURL = tURL & urlEncode(tSession.GET("user_name"))
        if tSession.exists("user_checksum") then
          tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
        end if
        openNetPage(tURL)
      "purse_voucher":
        if getObject(#session).GET("conf_voucher") then
          me.showVoucherWindow()
        end if
      "voucher_send":
        if not pVoucherInputState then
          return 0
        end if
        if not getWindow(pVoucherWindowTitle).getElement("voucher_code") then
          return 0
        end if
        tCode = getWindow(pVoucherWindowTitle).getElement("voucher_code").getText()
        if tCode.length = 0 then
          return 0
        end if
        me.setVoucherInput(0)
        me.getComponent().sendVoucherCode(tCode)
      "voucher_help":
        openNetPage(getText("purse_vouchers_helpurl"))
      "voucher_exit":
        me.hideVoucherWindow()
      "close":
        me.hidePurse()
    end case
  end if
end
