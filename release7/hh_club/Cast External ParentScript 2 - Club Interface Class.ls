property pDialogId, pConnectionId, pCannotEnterWindow, pParentPermission, pPrice, pDays

on construct me
  pPrice = value(getText("habboclub_price1"))
  pDays = value(getText("habboclub_price1.days"))
  pDialogId = "clubinfo1"
  pConnectionId = getVariable("connection.info.id")
  registerMessage(#show_clubinfo, me.getID(), #show_clubinfo)
  registerMessage(#notify, me.getID(), #notify)
  return 1
end

on notify me, ttype
  case ttype of
    1001:
      executeMessage(#alert, [#msg: "epsnotify_1001"])
      if connectionExists(pConnectionId) then
        removeConnection(pConnectionId)
      end if
    550:
      me.setupWindow()
      tWndObj = getWindow(pDialogId)
      tWndObj.moveTo(200, 200)
      tWndObj.merge("habbo_club_expired.window")
      tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  end case
end

on setupContinueWindow me
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  tText1 = getText("club_txt_renew1")
  tText1 = replaceChunks(tText1, "%days%", string(tClubInfo[#daysLeft]))
  tWndObj.getElement("club_txt_renew1").setText(tText1)
  if not (getText("club_paybycash_url") starts "http") then
    tWndObj.getElement("button_paycash").setProperty(#visible, 0)
  end if
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
end

on setupInfoWindow me
  if not (getText("club_paybycash_url") starts "http") then
    getWindow(pDialogId).getElement("club_link_paycash").setProperty(#visible, 0)
  end if
  if not (getText("club_info_url") starts "http") then
    getWindow(pDialogId).getElement("club_link_whatis").setProperty(#visible, 0)
  end if
  getWindow(pDialogId).registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
end

on setupRenewWindow me
  getWindow(pDialogId).registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
end

on eventProcDialogMousedown me, tEvent, tSprID, tParam
  tClubInfo = me.getComponent().getStatus()
  case tSprID of
    "club_expired_link":
      tWndObj = getWindow(pDialogId)
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_activate.window")
    "club_change_subscription":
      tSession = getObject(#session)
      tURL = getText("club_change_url")
      tURL = tURL & urlEncode(tSession.get("user_name"))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
      end if
      openNetPage(tURL)
    "club_link_whatis":
      openNetPage("club_info_url")
    "button_paycash", "club_link_paycash":
      tSession = getObject(#session)
      tURL = getText("club_paybycash_url")
      tURL = tURL & urlEncode(tSession.get("user_name"))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
      end if
      openNetPage(tURL, "_new")
    "button_buy", "button_paycoins":
      tWndObj = getWindow(pDialogId)
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_activate.window")
    "habboclub_continue":
      if tClubInfo[#daysLeft] > 62 then
        executeMessage(#alert, [#msg: "club_timefull"])
        return 1
      end if
      tSession = getObject(#session)
      if tSession.exists("user_walletbalance") then
        if tSession.get("user_walletbalance") < pPrice then
          executeMessage(#alert, [#msg: "club_price"])
          return 1
        end if
      end if
      if tClubInfo[#status] = "inactive" then
        me.getComponent().subscribe(me.pDays)
      else
        me.getComponent().extendSubscription(me.pDays)
        removeWindow(pDialogId)
      end if
      return 1
    "parent_permission_checkbox":
      me.setParentPermission(not pParentPermission)
    "button_cancel", "welcom_club_ok":
      removeWindow(me.pDialogId)
    "close":
      removeWindow(me.pDialogId)
  end case
  return 1
end

on setupWindow me
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  if not createWindow(pDialogId) then
    return 0
  end if
  tWndObj = getWindow(pDialogId)
  tWndObj.setProperty(#title, getText("club_habbo.window.title"))
  if not tWndObj.merge("habbo_full.window") then
    return tWndObj.close()
  end if
end

on show_clubinfo me
  tClubInfo = me.getComponent().getStatus()
  if tClubInfo <> 0 then
    if not windowExists(pDialogId) then
      me.setupWindow()
      tWndObj = getWindow(pDialogId)
      tWndObj.moveTo(200, 200)
      if tClubInfo[#status] = "inactive" then
        tWndObj.merge("habbo_club_intro.window")
        me.setupInfoWindow()
      else
        if not integerp(tClubInfo[#daysLeft]) then
          tWndObj.merge("habbo_club_renew2.window")
          me.setupRenewWindow()
        else
          tWndObj.merge("habbo_club_renew1.window")
          me.setupContinueWindow()
        end if
      end if
    else
      removeWindow(pDialogId)
    end if
  end if
  return 1
end

on updateClubStatus me, tStatus
  if tStatus[#status] = "active" then
    if windowExists(pDialogId) then
      removeWindow(pDialogId)
      me.show_clubinfo()
    end if
  end if
end

on subscriptionOkConfirmed me
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
    me.setupWindow()
    tWndObj = getWindow(pDialogId)
    tWndObj.merge("habbo_club_thanks.window")
    tEmail = getObject(#session).get("user_email")
    tTxt = getText("habboclub_thanks")
    tTxt = replaceChunks(tTxt, "%email%", tEmail)
    tWndObj.getElement("club_txt_thanks").setText(tTxt)
    tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
    me.getComponent().askforBadgeUpdate()
  end if
end
