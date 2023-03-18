property pWindowList, pAlertList, pDefWndType, pWriterPlain, pWriterLink, pWriterBold, pReadyFlag, pChosenHelpRadio, pHelpChoiceCount, pCfhType, pUrlList, pHelpWindowID

on construct me
  pWindowList = []
  pAlertList = []
  pUrlList = [:]
  pDefWndType = "habbo_basic.window"
  pReadyFlag = 0
  registerMessage(#openGeneralDialog, me.getID(), #showDialog)
  registerMessage(#alert, me.getID(), #ShowAlert)
  pHelpChoiceCount = me.countHelpChoices()
  pChosenHelpRadio = 0
  pCfhType = #none
  pHelpWindowID = getText("win_help", "Help")
  return 1
end

on deconstruct me
  if pReadyFlag then
    repeat with tID in pWindowList
      if windowExists(tID) then
        removeWindow(tID)
      end if
    end repeat
    repeat with tID in pAlertList
      if windowExists(tID) then
        removeWindow(tID)
      end if
    end repeat
    if writerExists(pWriterPlain) then
      removeWriter(pWriterPlain)
    end if
    if writerExists(pWriterLink) then
      removeWriter(pWriterLink)
    end if
    if writerExists(pWriterBold) then
      removeWriter(pWriterBold)
    end if
  end if
  pWindowList = []
  pAlertList = []
  pUrlList = [:]
  pReadyFlag = 0
  unregisterMessage(#openGeneralDialog, me.getID())
  unregisterMessage(#alert, me.getID())
  return 1
end

on countHelpChoices me
  if not textExists("help_pointer_1") then
    error(me, "No help choices defined. All go to emergency help.", #countHelpChoices, #minor)
    return 0
  end if
  repeat with i = 2 to 7
    if not textExists("help_pointer_" & i) then
      return i - 1
    end if
  end repeat
  return 7
end

on ShowAlert me, tProps
  if not pReadyFlag then
    me.buildResources()
  end if
  if voidp(tProps) then
    return error(me, "Properties for window expected!", #showHideWindow, #minor)
  end if
  if stringp(tProps) then
    tProps = [#Msg: tProps]
  end if
  if voidp(tProps[#id]) then
    tActualID = "alert" && the milliSeconds
  else
    tActualID = "alert" && tProps[#id]
  end if
  if tProps[#modal] = 1 then
    tSpecial = #modal
  else
    tSpecial = VOID
  end if
  if stringp(tProps[#title]) then
    tTitle = getText(tProps[#title])
    getWriter(pWriterBold).define([#color: rgb(0, 0, 0)])
    tTitleImg = getWriter(pWriterBold).render(tTitle).duplicate()
  end if
  if textExists(tProps[#Msg]) then
    tText = getText(tProps[#Msg])
  else
    tText = tProps[#Msg]
  end if
  tTextImg = getWriter(pWriterPlain).render(tText).duplicate()
  tURL = me.retrieveURL(tProps)
  if not voidp(tURL) then
    pUrlList.setaProp(tActualID, tURL)
    tLinkLabel = getText("more_info_link")
    tLinkImg = getWriter(pWriterLink).render(tLinkLabel).duplicate()
  end if
  if pAlertList.getOne(tActualID) then
    me.removeDialog(tActualID, pAlertList)
  end if
  if not createWindow(tActualID, VOID, VOID, VOID, tSpecial) then
    return 0
  end if
  tWndTitle = getText("win_error", "Notice!")
  tWndObj = getWindow(tActualID)
  tWndObj.setProperty(#title, tWndTitle)
  tWndObj.merge(pDefWndType)
  tWndObj.merge("habbo_alert_a.window")
  tTitleElem = tWndObj.getElement("alert_title")
  tTextElem = tWndObj.getElement("alert_text")
  tLinkElem = tWndObj.getElement("alert_link")
  tOffsetH = 0
  tOffsetW = 0
  if voidp(tTitle) then
    tTitleElem.hide()
  else
    tTitleElem.feedImage(tTitleImg)
    tOffsetH = tOffsetH + tTitleImg.height - tTitleElem.getProperty(#height)
    tWidth = tTitleImg.width - tTitleElem.getProperty(#width)
    if (tWidth > 0) and (tWidth > tOffsetW) then
      tOffsetW = tWidth
    end if
  end if
  if voidp(tText) then
    tTextElem.hide()
  else
    tTextElem.feedImage(tTextImg)
    tTextElem.moveBy(0, tOffsetH)
    tOffsetH = tOffsetH + tTextImg.height - tTextElem.getProperty(#height)
    tWidth = tTextImg.width - tTextElem.getProperty(#width)
    if (tWidth > 0) and (tWidth > tOffsetW) then
      tOffsetW = tWidth
    end if
  end if
  if voidp(tURL) then
    tLinkElem.hide()
  else
    tLinkElem.feedImage(tLinkImg)
    tLinkElem.moveBy(0, tOffsetH)
    tOffsetH = tOffsetH + tLinkImg.height - tLinkElem.getProperty(#height)
    tWidth = tLinkImg.width - tLinkElem.getProperty(#width)
    if (tWidth > 0) and (tWidth > tOffsetW) then
      tOffsetW = tWidth
    end if
  end if
  tWndObj.resizeBy(tOffsetW, tOffsetH)
  if not voidp(tTitle) then
    tLocV = tTitleElem.getProperty(#locV)
    tLocH = tTitleElem.getProperty(#locH)
    tTitleElem.moveTo(((tWndObj.getProperty(#width) - tTitleImg.width) / 2) - tLocH, tLocV)
  end if
  if not voidp(tText) then
    tLocV = tTextElem.getProperty(#locV)
    tLocH = tTextElem.getProperty(#locH)
    tTextElem.moveTo(((tWndObj.getProperty(#width) - tTextImg.width) / 2) - tLocH, tLocV)
  end if
  if not voidp(tURL) then
    tLocV = tLinkElem.getProperty(#locV)
    tLocH = tLinkElem.getProperty(#locH)
    tLinkElem.moveTo(((tWndObj.getProperty(#width) - tLinkImg.width) / 2) - tLocH, tLocV)
  end if
  tWndObj.center()
  tLocOff = pAlertList.count * 10
  tWndObj.moveBy(tLocOff, tLocOff)
  tWndObj.registerClient(me.getID())
  if symbolp(tProps[#registerProcedure]) then
    tWndObj.registerProcedure(tProps[#registerProcedure], me.getID(), #mouseUp)
  else
    tWndObj.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
  end if
  pAlertList.add(tActualID)
  return 1
end

on showDialog me, tWndID, tProps
  if not pReadyFlag then
    me.buildResources()
  end if
  case tWndID of
    #alert, "alert", #modal_alert, "modal_alert":
      return me.ShowAlert(tProps)
    #purse, "purse":
      return executeMessage(#show_hide_purse)
    #help, "help":
      me.showHelpWindow()
    #call_for_help, "call_for_help":
      tConnection = getConnection(getVariable("connection.info.id"))
      if not tConnection then
        error(me, "Connection not found.", #showDialog, #major)
      end if
      tConnection.send("GET_PENDING_CALLS_FOR_HELP")
    #help_choice, "help_choice":
      me.openHelpChoiceWindow()
    #ban, "ban":
      tProps[#registerProcedure] = #eventProcBan
      return me.ShowAlert(tProps)
  end case
end

on retrieveURL me, tProps
  if not voidp(tProps.getaProp(#url)) then
    tURL = tProps.getaProp(#url)
  end if
  tPostfixList = ["_url", "_URL", "_Url"]
  repeat with tPostfix in tPostfixList
    tKey = tProps[#Msg] & tPostfix
    if textExists(tKey) then
      tURL = getText(tKey)
      exit repeat
    end if
  end repeat
  if (tURL starts "http://") or (tURL starts "https://") then
    return tURL
  end if
  return VOID
end

on buildResources me
  pWriterPlain = "dialog_writer_plain"
  pWriterLink = "dialog_writer_link"
  pWriterBold = "dialog_writer_bold"
  tFontPlain = getStructVariable("struct.font.plain")
  tFontLink = getStructVariable("struct.font.link")
  tFontBold = getStructVariable("struct.font.bold")
  tFontPlain.setaProp(#lineHeight, 14)
  tFontLink.setaProp(#lineHeight, 14)
  tFontBold.setaProp(#lineHeight, 14)
  createWriter(pWriterPlain, tFontPlain)
  createWriter(pWriterLink, tFontLink)
  createWriter(pWriterBold, tFontBold)
  pReadyFlag = 1
  return 1
end

on createDialog me, tWndTitle, tWndType, tContentType, tEventProc
  if not createWindow(tWndTitle, tWndType) then
    return 0
  end if
  tWndObj = getWindow(tWndTitle)
  tWndObj.merge(tContentType)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(tEventProc, me.getID(), #mouseUp)
  pWindowList.add(tWndTitle)
  return 1
end

on removeDialog me, tWndTitle, tWndList
  if not listp(tWndList) then
    return 0
  end if
  if tWndList.getOne(tWndTitle) then
    tWndList.deleteOne(tWndTitle)
    if pUrlList.ilk = #propList then
      if not voidp(pUrlList.getaProp(tWndTitle)) then
        pUrlList.deleteProp(tWndTitle)
      end if
    end if
    return removeWindow(tWndTitle)
  else
    return error(me, "Attempted to remove unknown dialog:" && tWndTitle, #removeDialog, #minor)
  end if
end

on showAlertSentWindow me, tWndObj
  tWndObj = getWindow(pHelpWindowID)
  tWndObj.unmerge()
  tWndObj.merge("habbo_hobba_alertsent.window")
  if pCfhType = #habbo_helpers then
    tHeader = getText("callhelp_sent")
    tText = getText("callhelp_allwillreceive")
  else
    tHeader = getText("help_emergency_sent")
    tText = getText("help_emergency_whathappens")
  end if
  tWndObj.getElement("alertsent_header").setText(tHeader)
  tWndObj.getElement("alertsent_text").setText(tText)
  return 1
end

on openCfhWindow me
  tWndTitle = getText("win_callforhelp")
  me.pHelpWindowID = tWndTitle
  if windowExists(tWndTitle) then
    me.removeDialog(tWndTitle, pWindowList)
  end if
  me.createDialog(tWndTitle, pDefWndType, "habbo_hobba_compose.window", #eventProcCallHelp)
  tWndObj = getWindow(tWndTitle)
  if pCfhType = #habbo_helpers then
    tTopText = getText("callhelp_explanation")
    tMidText = getText("callhelp_writeyour")
    tBotText = getText("callhelp_example")
  else
    tTopText = getText("help_emergency_explanation")
    tMidText = getText("help_emergency_writeyour")
    tBotText = getText("help_emergency_example")
  end if
  tWndObj.getElement("hobbaalert_top").setText(tTopText)
  tWndObj.getElement("hobbaalert_mid").setText(tMidText)
  tWndObj.getElement("hobbaalert_bottom").setText(tBotText)
  return 1
end

on openPendingCFHWindow me, tMsg
  tConn = tMsg.getaProp(#connection)
  if voidp(tConn) then
    return error(me, "Invalid message.", #openPendingCFHWindow, #major)
  end if
  tID = tConn.GetStrFrom()
  tTimestamp = tConn.GetStrFrom()
  tCFH = tConn.GetStrFrom()
  tWindowTitle = getText("win_callforhelp")
  if windowExists(tWindowTitle) then
    me.removeDialog(tWindowTitle, pWindowList)
  end if
  me.createDialog(tWindowTitle, pDefWndType, "habbo_pending_cfh.window", #eventProcCallHelp)
  tWindowObj = getWindow(tWindowTitle)
  tTopText = getText("you_have_pending_cfh")
  tMiddleText = getText("pending_cfh_title")
  tWindowObj.getElement("pending_cfh_top").setText(tTopText)
  tWindowObj.getElement("pending_cfh_mid").setText(tMiddleText)
  tWindowObj.getElement("pending_cfh_text").setText(tCFH)
end

on openHelpChoiceWindow me
  if windowExists(pHelpWindowID) then
    me.removeDialog(pHelpWindowID, pWindowList)
  end if
  if pHelpChoiceCount = 0 then
    pCfhType = #emergency
    return me.showDialog("call_for_help")
  end if
  tWndTitle = getText("win_callforhelp")
  me.pHelpWindowID = tWndTitle
  if windowExists(tWndTitle) then
    return me.removeDialog(tWndTitle, pWindowList)
  end if
  me.createDialog(tWndTitle, "habbo_full.window", "habbo_help_choise.window", #eventProcHelp)
  tWndObj = getWindow(tWndTitle)
  if getMember("button.radio.off").type <> #bitmap then
    return 0
  end if
  repeat with i = 1 to pHelpChoiceCount
    tRadioImg = getMember("button.radio.off").image
    tText = getText("help_option_" & i)
    if tText <> ("help_option_" & i) then
      tWndObj.getElement("help_option_" & i).setText(tText)
      tWndObj.getElement("help_radio_" & i).feedImage(tRadioImg)
    end if
  end repeat
  tWndObj.getElement("help_choise_ok").deactivate()
  return 1
end

on helpChoiceMade me
  if pChosenHelpRadio = 0 then
    return 0
  end if
  tAction = getText("help_pointer_" & pChosenHelpRadio)
  if tAction starts "http" then
    openNetPage(tAction)
    tValue = me.removeDialog(getText("win_callforhelp"), pWindowList)
    executeMessage(#externalLinkClick, the mouseLoc)
    return tValue
  end if
  if tAction = "hotel_help" then
    pCfhType = #habbo_helpers
  else
    if tAction = "emergency_help" then
      pCfhType = #emergency
    end if
  end if
  if (tAction = "hotel_help") or (tAction = "emergency_help") then
    tConnection = getConnection(getVariable("connection.info.id"))
    if not tConnection then
      error(me, "Connection not found.", #helpChoiceMade, #major)
    end if
    tConnection.send("GET_PENDING_CALLS_FOR_HELP")
    return 1
  end if
  return error(me, "Help pointer " & pChosenHelpRadio & " not working, check syntax.", #helpChoiceMade, #major)
end

on helpRadioClicked me, tChoiceNum, tWndID
  if not memberExists("button.radio.on") then
    return 0
  end if
  tRadioOnImg = getMember("button.radio.on").image
  tRadioOffImg = getMember("button.radio.off").image
  tWnd = getWindow(tWndID)
  if not tWnd.elementExists("help_radio_" & pHelpChoiceCount) then
    return 0
  end if
  repeat with i = 1 to pHelpChoiceCount
    tElem = tWnd.getElement("help_radio_" & i)
    if i = tChoiceNum then
      tElem.feedImage(tRadioOnImg)
      next repeat
    end if
    tElem.feedImage(tRadioOffImg)
  end repeat
  tWnd.getElement("help_choise_ok").Activate()
  pChosenHelpRadio = tChoiceNum
  return 1
end

on showHelpWindow me
  if windowExists(pHelpWindowID) then
    me.removeDialog(pHelpWindowID, pWindowList)
  end if
  me.createDialog(pHelpWindowID, pDefWndType, "habbo_help.window", #eventProcHelp)
  tWndObj = getWindow(pHelpWindowID)
  tStr = EMPTY
  i = 0
  repeat while 1
    i = i + 1
    if textExists("help_txt_" & i) then
      tStr = tStr & getText("help_txt_" & i) & RETURN
      next repeat
    end if
    exit repeat
  end repeat
  tStr = tStr.line[1..tStr.line.count - 1]
  tLinkImg = getWriter(pWriterLink).render(tStr).duplicate()
  tWndObj.getElement("link_list").feedImage(tLinkImg)
  if threadExists(#room) then
    if getThread(#room).getComponent().getRoomID() = EMPTY then
      tWndObj.getElement("help_callforhelp_textlink").hide()
    end if
  end if
  if tWndObj.elementExists("help_tutorial_link") then
    tLinkURL = getText("reg_tutorial_url", EMPTY)
    if not stringp(tLinkURL) or (tLinkURL.length < 10) then
      tWndObj.getElement("help_tutorial_link").setProperty(#visible, 0)
    else
      tWndObj.getElement("help_tutorial_link").setText(getText("reg_tutorial_txt") && ">>")
    end if
  end if
  tTutorialEnabled = getObject(#session).GET("tutorial_enabled", 0)
  if not tTutorialEnabled then
    tWndObj.getElement("help_restart_tutorial").hide()
  end if
end

on eventProcAlert me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "alert_ok", "close":
        return me.removeDialog(tWndID, pAlertList)
      "alert_link":
        tURL = pUrlList.getaProp(tWndID)
        executeMessage(#externalLinkClick, the mouseLoc)
        return openNetPage(tURL)
    end case
  end if
end

on eventProcPurse me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "close", "purse_close":
        return executeMessage(#hide_purse)
      "purse_link_text":
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
        executeMessage(#externalLinkClick, the mouseLoc)
        openNetPage(tURL)
    end case
  end if
end

on eventProcHelp me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "link_list":
        if tParam.ilk <> #point then
          return 0
        end if
        tLineNum = (tParam[2] / 14) + 1
        if textExists("url_help_" & tLineNum) then
          tSession = getObject(#session)
          tURL = getText("url_help_" & tLineNum)
          tName = urlEncode(tSession.GET("user_name"))
          if tURL = EMPTY then
            return 1
          end if
          if tURL contains "\user_name" then
            tURL = replaceChunks(tURL, "\user_name", tName)
            if tSession.exists("user_checksum") then
              tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
            end if
          end if
          executeMessage(#externalLinkClick, the mouseLoc)
          openNetPage(tURL)
        end if
        return 1
      "close", "help_ok", "help_choise_cancel":
        return me.removeDialog(tWndID, pWindowList)
      "help_tutorial_link":
        executeMessage(#externalLinkClick, the mouseLoc)
        openNetPage(getText("reg_tutorial_url"))
      "help_callforhelp_textlink":
        me.openHelpChoiceWindow()
      "help_choise_ok":
        me.helpChoiceMade()
      "help_restart_tutorial":
        executeMessage(#restart_tutorial)
        return me.removeDialog(tWndID, pWindowList)
      otherwise:
        if stringp(tElemID) then
          if tElemID.char[1..11] = "help_radio_" then
            me.helpRadioClicked(tElemID.char[12], tWndID)
          end if
        end if
    end case
  end if
end

on eventProcCallHelp me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "close", "callhelp_cancel", "alertsent_ok", "pending_cfh_cancel":
        return me.removeDialog(tWndID, pWindowList)
      "callhelp_send":
        tWndObj = getWindow(tWndID)
        executeMessage(#sendCallForHelp, tWndObj.getElement("callhelp_text").getText(), pCfhType)
        return 1
      "pending_cfh_delete":
        tConnection = getConnection(getVariable("connection.info.id"))
        if not tConnection then
          error(me, "Connection not found.", #showDialog, #major)
        end if
        tConnection.send("DELETE_PENDING_CALLS_FOR_HELP")
    end case
  end if
end

on eventProcBan me, tEvent, tElemID, tParam, tWndID
  if tEvent = #mouseUp then
    case tElemID of
      "alert_ok", "close":
        if variableExists("use.sso.ticket") then
          if getVariable("use.sso.ticket") = "1" then
            openNetPage(getText("url_logged_out"), "self")
            return 1
          end if
        end if
        me.removeDialog(tWndID, pAlertList)
        resetClient()
    end case
  end if
end
