property pGiftDialogID, pConnectionId, pDialogId, pChosenLength, pSubscribeFromHotel

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
  return(1)
end

on deconstruct me 
  unregisterMessage(#show_clubinfo, me.getID())
  unregisterMessage(#notify, me.getID())
  return(1)
end

on show_giftinfo me 
  if windowExists(pGiftDialogID) then
    return(0)
  end if
  me.setupWindow(pGiftDialogID, #modal)
  tWndObj = getWindow(pGiftDialogID)
  if not objectp(tWndObj) then
    return(0)
  end if
  tWndObj.merge("habbo_club_confirm.window")
  tWndObj.center()
  tWndObj.getElement("club_confirm_title").setText(getText("club_confirm_gift_title"))
  tWndObj.getElement("club_confirm_text").setText(getText("club_confirm_gift_text"))
  tWndObj.registerProcedure(#eventProcGiftDialogMousedown, me.getID(), #mouseDown)
  return(1)
end

on notify me, ttype 
  if ttype = 1001 then
    executeMessage(#alert, [#Msg:"epsnotify_1001"])
    if connectionExists(pConnectionId) then
      removeConnection(pConnectionId)
    end if
  else
    if ttype = 551 then
      executeMessage(#alert, [#Msg:getText("club_extend_failed")])
    else
      if ttype = 552 then
        executeMessage(#alert, [#Msg:getText("Alert_no_credits")])
      end if
    end if
  end if
end

on setupEndedWindow me 
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  if not objectp(tWndObj) then
    return(0)
  end if
  tElapsed = tClubInfo.getAt(#ElapsedPeriods)
  tElem = tWndObj.getElement("club_elapsed_periods")
  tElem.setText(string(tElapsed))
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  return(1)
end

on setupStatusWindow me, ttype 
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  if not objectp(tWndObj) then
    return(0)
  end if
  tDaysLeft = tClubInfo.getAt(#daysLeft)
  tElapsed = tClubInfo.getAt(#ElapsedPeriods)
  tPrepaid = tClubInfo.getAt(#PrepaidPeriods)
  tArrowElem = tWndObj.getElement("club_arrow")
  tLocH = tArrowElem.getProperty(#locH)
  tLocH = tLocH + 31 - tDaysLeft * 5
  tArrowElem.setProperty(#locH, tLocH)
  tElem = tWndObj.getElement("club_elapsed_periods")
  tElem.setText(string(tElapsed))
  if ttype = #FirstTimer then
    tElem = tWndObj.getElement("club_status_title")
    tElem.setText(getText("club_thanks_title"))
    tElem = tWndObj.getElement("club_status_text")
    tElem.setText(getText("club_thanks_text"))
  end if
  if tClubInfo.getAt(#PrepaidPeriods) = -1 then
    tElem = tWndObj.getElement("club_button_extend")
    tElem.hide()
  else
    tElem = tWndObj.getElement("club_isp_change")
    tElem.hide()
    tElem = tWndObj.getElement("club_isp_icon")
    tElem.hide()
    tElem = tWndObj.getElement("club_prepaid_periods")
    tElem.setText(string(tClubInfo.getAt(#PrepaidPeriods)))
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
  if not getText("club_info_url") starts "http" then
    getWindow(pDialogId).getElement("club_general_infolink").setProperty(#visible, 0)
  end if
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  return(1)
end

on changeTextsToExtend me 
  tWndObj = getWindow(pDialogId)
  if not objectp(tWndObj) then
    return(0)
  end if
  tHeaderText = getText("club_extend_title")
  tText = getText("club_extend_text")
  tWndObj.getElement("club_intro_header").setText(tHeaderText)
  tWndObj.getElement("club_intro_text").setText(tText)
  return(1)
end

on setupBuyWindow me 
  if not getText("club_info_url") starts "http" then
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
  return(1)
end

on setupWindow me, tWindowID, ttype 
  if windowExists(tWindowID) then
    removeWindow(tWindowID)
  end if
  if ttype = #modal then
    if not createWindow(tWindowID, void(), 0, 0, #modal) then
      return(0)
    end if
  else
    if not createWindow(tWindowID) then
      return(0)
    end if
  end if
  tWndObj = getWindow(tWindowID)
  tWndObj.setProperty(#title, getText("club_habbo.window.title"))
  if not tWndObj.merge("habbo_full.window") then
    return(tWndObj.close())
  end if
  return(1)
end

on show_clubinfo me 
  tClubInfo = me.getComponent().getStatus()
  if tClubInfo <> 0 then
    if not windowExists(pDialogId) then
      tList = [:]
      tList.setAt("showDialog", 1)
      executeMessage(#getHotelClosingStatus, tList)
      if tList.getAt("retval") = 1 then
        return(1)
      end if
      me.setupWindow(pDialogId)
      tWndObj = getWindow(pDialogId)
      if tClubInfo.getAt(#daysLeft) = 0 and tClubInfo.getAt(#ElapsedPeriods) = 0 then
        if not pSubscribeFromHotel then
          me.openBuyInHabboWeb()
          tWndObj.close()
          return(1)
        end if
        if not getText("club_paybycash_url") starts "http" then
          tWndObj.merge("habbo_club_buy.window")
        else
          tWndObj.merge("habbo_club_buy_jp.window")
        end if
        me.setupBuyWindow("intro")
      else
        if tClubInfo.getAt(#daysLeft) = 0 and tClubInfo.getAt(#ElapsedPeriods) > 0 then
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
  return(1)
end

on updateClubStatus me, tStatus, tResponseFlag, tOldClubStatus 
  if tResponseFlag = 2 then
    me.setupWindow(pDialogId)
    tWndObj = getWindow(pDialogId)
    if not objectp(tWndObj) then
      return(0)
    end if
    tWndObj.merge("habbo_club_status.window")
    tWndObj.center()
    if tOldClubStatus.getAt(#ElapsedPeriods) = 0 and tOldClubStatus.getAt(#daysLeft) = 0 then
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
  return(1)
end

on openBuyInHabboWeb me 
  if getText("club_buy_url") = "club_buy_url" then
    return(error(me, "key club_buy_url not defined!", #eventProcDialogMousedown, #major))
  else
    executeMessage(#externalLinkClick, the mouseLoc)
    openNetPage("club_buy_url")
  end if
  return(1)
end

on eventProcDialogMousedown me, tEvent, tSprID, tParam 
  tClubInfo = me.getComponent().getStatus()
  if tSprID = "club_button_extend" then
    tWndObj = getWindow(pDialogId)
    if not objectp(tWndObj) then
      return(0)
    end if
    tWndObj.unmerge()
    if not pSubscribeFromHotel then
      me.openBuyInHabboWeb()
      tWndObj.close()
      return(1)
    end if
    if getText("club_paybycash_url") starts "http" then
      tWndObj.merge("habbo_club_buy_jp.window")
    else
      tWndObj.merge("habbo_club_buy.window")
    end if
    me.changeTextsToExtend()
  else
    if tSprID = "club_isp_change" then
      tSession = getObject(#session)
      tURL = getText("club_change_url")
      tURL = tURL & urlEncode(tSession.GET("user_name"))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
      end if
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tURL)
    else
      if tSprID <> "club_intro_link" then
        if tSprID = "club_general_infolink" then
          executeMessage(#externalLinkClick, the mouseLoc)
          openNetPage("club_info_url")
        else
          if tSprID = "club_isp_buy" then
            tSession = getObject(#session)
            tURL = getText("club_paybycash_url")
            tURL = tURL & urlEncode(tSession.GET("user_name"))
            if tSession.exists("user_checksum") then
              tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
            end if
            executeMessage(#externalLinkClick, the mouseLoc)
            openNetPage(tURL, "_new")
          else
            if tSprID = "club_button_1_period" then
              tWndObj = getWindow(pDialogId)
              if not objectp(tWndObj) then
                return(0)
              end if
              tWndObj.unmerge()
              tWndObj.merge("habbo_club_confirm.window")
              pChosenLength = 1
              me.replaceCreditsText()
            else
              if tSprID = "club_button_2_period" then
                tWndObj = getWindow(pDialogId)
                if not objectp(tWndObj) then
                  return(0)
                end if
                tWndObj.unmerge()
                tWndObj.merge("habbo_club_confirm.window")
                pChosenLength = 2
                me.replaceCreditsText()
              else
                if tSprID = "club_button_3_period" then
                  tWndObj = getWindow(pDialogId)
                  if not objectp(tWndObj) then
                    return(0)
                  end if
                  tWndObj.unmerge()
                  tWndObj.merge("habbo_club_confirm.window")
                  pChosenLength = 3
                  me.replaceCreditsText()
                else
                  if tSprID = "club_confirm_ok" then
                    me.getComponent().subscribe(pChosenLength)
                    removeWindow(pDialogId)
                  else
                    if tSprID <> "club_confirm_cancel" then
                      if tSprID = "club_button_close" then
                        removeWindow(me.pDialogId)
                      else
                        if tSprID = "close" then
                          removeWindow(me.pDialogId)
                        end if
                      end if
                      return(1)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcGiftDialogMousedown me, tEvent, tSprID, tParam 
  if tSprID = "club_confirm_ok" then
    removeWindow(pGiftDialogID)
    me.getComponent().acceptGift()
  else
    if tSprID <> "club_confirm_cancel" then
      if tSprID = "club_button_close" then
        removeWindow(pGiftDialogID)
        me.getComponent().rejectGift()
      else
        if tSprID = "close" then
          me.getComponent().resetGiftList()
        end if
      end if
      return(1)
    end if
  end if
end
