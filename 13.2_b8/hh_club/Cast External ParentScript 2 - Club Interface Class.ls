property pDialogId, pGiftDialogID, pConnectionId, pChosenLength, pSubscribeFromHotel

on construct me
  pGiftDialogID = "window_clubgift"
  pDialogId = "window_clubinfo1"
  pConnectionId = getVariable("connection.info.id")
  pChosenLength = 1
  if variableExists("club.subscription.disabled") then
    pSubscribeFromHotel = not getVariable("club.subscription.disabled") > 0
  else
    pSubscribeFromHotel = 1
  end if
  registerMessage(#show_clubinfo, me.getID(), #show_clubinfo)
  registerMessage(#notify, me.getID(), #notify)
  return 1
end

on deconstruct me
  unregisterMessage(#show_clubinfo, me.getID())
  unregisterMessage(#notify, me.getID())
  return 1
end

on show_giftinfo me
  if windowExists(pGiftDialogID) then
    return 0
  end if
  me.setupWindow(pGiftDialogID, #modal)
  tWndObj = getWindow(pGiftDialogID)
  if not objectp(tWndObj) then
    return 0
  end if
  tWndObj.merge("habbo_club_confirm.window")
  tWndObj.center()
  tWndObj.getElement("club_confirm_title").setText(getText("club_confirm_gift_title"))
  tWndObj.getElement("club_confirm_text").setText(getText("club_confirm_gift_text"))
  tWndObj.registerProcedure(#eventProcGiftDialogMousedown, me.getID(), #mouseDown)
  return 1
end

on notify me, ttype
  case ttype of
    1001:
      executeMessage(#alert, [#Msg: "epsnotify_1001"])
      if connectionExists(pConnectionId) then
        removeConnection(pConnectionId)
      end if
    551:
      executeMessage(#alert, [#Msg: getText("club_extend_failed")])
    552:
      executeMessage(#alert, [#Msg: getText("Alert_no_credits")])
  end case
end

on setupEndedWindow me
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  if not objectp(tWndObj) then
    return 0
  end if
  tElapsed = tClubInfo[#ElapsedPeriods]
  tElem = tWndObj.getElement("club_elapsed_periods")
  tElem.setText(string(tElapsed))
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  return 1
end

on setupStatusWindow me, ttype
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  if not objectp(tWndObj) then
    return 0
  end if
  tDaysLeft = tClubInfo[#daysLeft]
  tElapsed = tClubInfo[#ElapsedPeriods]
  tPrepaid = tClubInfo[#PrepaidPeriods]
  tArrowElem = tWndObj.getElement("club_arrow")
  tLocH = tArrowElem.getProperty(#locH)
  tLocH = tLocH + ((31 - tDaysLeft) * 5)
  tArrowElem.setProperty(#locH, tLocH)
  tElem = tWndObj.getElement("club_elapsed_periods")
  tElem.setText(string(tElapsed))
  if ttype = #FirstTimer then
    tElem = tWndObj.getElement("club_status_title")
    tElem.setText(getText("club_thanks_title"))
    tElem = tWndObj.getElement("club_status_text")
    tElem.setText(getText("club_thanks_text"))
  end if
  if tClubInfo[#PrepaidPeriods] = -1 then
    tElem = tWndObj.getElement("club_button_extend")
    tElem.hide()
  else
    tElem = tWndObj.getElement("club_isp_change")
    tElem.hide()
    tElem = tWndObj.getElement("club_isp_icon")
    tElem.hide()
    tElem = tWndObj.getElement("club_prepaid_periods")
    tElem.setText(string(tClubInfo[#PrepaidPeriods]))
  end if
  if tElapsed = 0 then
    tElem = tWndObj.getElement("club_elapsed_periods")
    tElem.hide()
    tElem = tWndObj.getElement("club_elapsed")
    tElem.hide()
  end if
  if tPrepaid = 0 then
    tElem = tWndObj.getElement("club_prepaid_periods")
    tElem.hide()
    tElem = tWndObj.getElement("club_prepaid")
    tElem.hide()
  end if
  if not (getText("club_info_url") starts "http") then
    getWindow(pDialogId).getElement("club_general_infolink").setProperty(#visible, 0)
  end if
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  return 1
end

on changeTextsToExtend me
  tWndObj = getWindow(pDialogId)
  if not objectp(tWndObj) then
    return 0
  end if
  tHeaderText = getText("club_extend_title")
  tText = getText("club_extend_text")
  tWndObj.getElement("club_intro_header").setText(tHeaderText)
  tWndObj.getElement("club_intro_text").setText(tText)
  return 1
end

on setupBuyWindow me
  if not (getText("club_info_url") starts "http") then
    getWindow(pDialogId).getElement("club_intro_link").setProperty(#visible, 0)
  end if
  getWindow(pDialogId).registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
end

on replaceCreditsText me
  tCredits = getObject(#session).GET("user_walletbalance")
  tWndObj = getWindow(pDialogId)
  tText = getText("club_confirm_text" & pChosenLength)
  tText = replaceChunks(tText, "%credits%", string(tCredits))
  tWndObj.getElement("club_confirm_text").setText(tText)
  return 1
end

on setupWindow me, tWindowID, ttype
  if windowExists(tWindowID) then
    removeWindow(tWindowID)
  end if
  if ttype = #modal then
    if not createWindow(tWindowID, VOID, 0, 0, #modal) then
      return 0
    end if
  else
    if not createWindow(tWindowID) then
      return 0
    end if
  end if
  tWndObj = getWindow(tWindowID)
  tWndObj.setProperty(#title, getText("club_habbo.window.title"))
  if not tWndObj.merge("habbo_full.window") then
    return tWndObj.close()
  end if
  return 1
end

on show_clubinfo me
  tClubInfo = me.getComponent().getStatus()
  if tClubInfo <> 0 then
    if not windowExists(pDialogId) then
      tList = [:]
      tList["showDialog"] = 1
      executeMessage(#getHotelClosingStatus, tList)
      if tList["retval"] = 1 then
        return 1
      end if
      me.setupWindow(pDialogId)
      tWndObj = getWindow(pDialogId)
      if (tClubInfo[#daysLeft] = 0) and (tClubInfo[#ElapsedPeriods] = 0) then
        if not pSubscribeFromHotel then
          me.openBuyInHabboWeb()
          tWndObj.close()
          return 1
        end if
        if not (getText("club_paybycash_url") starts "http") then
          tWndObj.merge("habbo_club_buy.window")
        else
          tWndObj.merge("habbo_club_buy_jp.window")
        end if
        me.setupBuyWindow("intro")
      else
        if (tClubInfo[#daysLeft] = 0) and (tClubInfo[#ElapsedPeriods] > 0) then
          tWndObj.merge("habbo_club_ended.window")
          tWndObj.center()
          me.setupEndedWindow()
        else
          tWndObj.merge("habbo_club_status.window")
          me.setupStatusWindow()
        end if
      end if
      tWndObj.center()
    else
      removeWindow(pDialogId)
    end if
  end if
  return 1
end

on updateClubStatus me, tStatus, tResponseFlag, tOldClubStatus
  if tResponseFlag = 2 then
    me.setupWindow(pDialogId)
    tWndObj = getWindow(pDialogId)
    if not objectp(tWndObj) then
      return 0
    end if
    tWndObj.merge("habbo_club_status.window")
    tWndObj.center()
    if (tOldClubStatus[#ElapsedPeriods] = 0) and (tOldClubStatus[#daysLeft] = 0) then
      me.setupStatusWindow(#FirstTimer)
    else
      me.setupStatusWindow(#BeenHcBefore)
    end if
  end if
  if tResponseFlag = 3 then
    me.setupWindow(pDialogId, #modal)
    tWndObj = getWindow(pDialogId)
    tWndObj.merge("habbo_club_ended.window")
    tWndObj.center()
    me.setupEndedWindow()
  end if
  return 1
end

on openBuyInHabboWeb me
  if getText("club_buy_url") = "club_buy_url" then
    return error(me, "key club_buy_url not defined!", #eventProcDialogMousedown)
  else
    openNetPage("club_buy_url")
  end if
  return 1
end

on eventProcDialogMousedown me, tEvent, tSprID, tParam
  tClubInfo = me.getComponent().getStatus()
  case tSprID of
    "club_button_extend":
      tWndObj = getWindow(pDialogId)
      if not objectp(tWndObj) then
        return 0
      end if
      tWndObj.unmerge()
      if not pSubscribeFromHotel then
        me.openBuyInHabboWeb()
        tWndObj.close()
        return 1
      end if
      if getText("club_paybycash_url") starts "http" then
        tWndObj.merge("habbo_club_buy_jp.window")
      else
        tWndObj.merge("habbo_club_buy.window")
      end if
      me.changeTextsToExtend()
    "club_isp_change":
      tSession = getObject(#session)
      tURL = getText("club_change_url")
      tURL = tURL & urlEncode(tSession.GET("user_name"))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
      end if
      openNetPage(tURL)
    "club_intro_link", "club_general_infolink":
      openNetPage("club_info_url")
    "club_isp_buy":
      tSession = getObject(#session)
      tURL = getText("club_paybycash_url")
      tURL = tURL & urlEncode(tSession.GET("user_name"))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
      end if
      openNetPage(tURL, "_new")
    "club_button_1_period":
      tWndObj = getWindow(pDialogId)
      if not objectp(tWndObj) then
        return 0
      end if
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_confirm.window")
      pChosenLength = 1
      me.replaceCreditsText()
    "club_button_2_period":
      tWndObj = getWindow(pDialogId)
      if not objectp(tWndObj) then
        return 0
      end if
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_confirm.window")
      pChosenLength = 2
      me.replaceCreditsText()
    "club_button_3_period":
      tWndObj = getWindow(pDialogId)
      if not objectp(tWndObj) then
        return 0
      end if
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_confirm.window")
      pChosenLength = 3
      me.replaceCreditsText()
    "club_confirm_ok":
      me.getComponent().subscribe(pChosenLength)
      removeWindow(pDialogId)
    "club_confirm_cancel", "club_button_close":
      removeWindow(me.pDialogId)
    "close":
      removeWindow(me.pDialogId)
  end case
  return 1
end

on eventProcGiftDialogMousedown me, tEvent, tSprID, tParam
  case tSprID of
    "club_confirm_ok":
      removeWindow(pGiftDialogID)
      me.getComponent().acceptGift()
    "club_confirm_cancel", "club_button_close":
      removeWindow(pGiftDialogID)
      me.getComponent().rejectGift()
    "close":
      me.getComponent().resetGiftList()
  end case
  return 1
end
