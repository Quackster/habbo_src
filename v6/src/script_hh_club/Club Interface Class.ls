property pDialogId, pConnectionId, pConfirmDialogId, pCannotEnterWindow, pParentPermission, pPrice, pDays, pPurchaseMode

on construct me
  pPrice = value(getText("habboclub_price1"))
  pDays = value(getText("habboclub_price1.days"))
  pDialogId = "clubinfo1"
  pConnectionId = getVariable("connection.info.id")
  pConfirmDialogId = "clubconfirmdialog"
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

on setParentPermission me, tBool
  if tBool then
    tImage = member(getmemnum("button.checkbox.on")).image
  else
    tImage = member(getmemnum("button.checkbox.off")).image
  end if
  getWindow(pDialogId).getElement("parent_permission_checkbox").setProperty(#image, tImage)
  pParentPermission = tBool
  return 1
end

on openConfirmDialog me, tMode
  pPurchaseMode = tMode
  if windowExists(pConfirmDialogId) then
    removeWindow(pConfirmDialogId)
  end if
  if not createWindow(pConfirmDialogId, "habbo_simple.window", 250, 200) then
    return 0
  end if
  tWndObj = getWindow(pConfirmDialogId)
  tWndObj.merge("habbo_club_confirm.window")
  tText1 = getText("habboclub_confirm_header")
  tText2 = getText("habboclub_confirm_body")
  tText1 = replaceChunks(tText1, "%price%", pPrice)
  tText2 = replaceChunks(tText2, "%credits%", getObject(#session).get("user_walletbalance"))
  tWndObj.getElement("habboclub_confirm_header").setText(tText1)
  tWndObj.getElement("habboclub_confirm_body").setText(tText2)
  tWndObj.registerProcedure(#eventProcConfirmMousedown, me.getID(), #mouseDown)
  return 1
end

on eventProcConfirmMousedown me, tEvent, tSprID, tParam
  case tSprID of
    "button_ok":
      if (pPurchaseMode = #subscribe) then
        me.getComponent().subscribe(me.pDays)
      else
        if (pPurchaseMode = #extend) then
          me.getComponent().extendSubscription(me.pDays)
          removeWindow(me.pDialogId)
        end if
      end if
      removeWindow(pConfirmDialogId)
      return 1
    "button_cancel":
      removeWindow(pConfirmDialogId)
      return 1
  end case
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
      tURL = (tURL & urlEncode(tSession.get("user_name")))
      if tSession.exists("user_checksum") then
        tURL = ((tURL & "&sum=") & urlEncode(tSession.get("user_checksum")))
      end if
      openNetPage(tURL)
    "club_link_whatis":
      openNetPage("club_info_url")
    "button_paycash", "club_link_paycash":
      tSession = getObject(#session)
      tURL = getText("club_paybycash_url")
      tURL = (tURL & urlEncode(tSession.get("user_name")))
      if tSession.exists("user_checksum") then
        tURL = ((tURL & "&sum=") & urlEncode(tSession.get("user_checksum")))
      end if
      openNetPage(tURL, "_new")
    "button_buy", "button_paycoins":
      if (tClubInfo[#daysLeft] > 62) then
        executeMessage(#alert, [#msg: "club_timefull"])
        return 1
      end if
      tSession = getObject(#session)
      if tSession.exists("user_walletbalance") then
        if (tSession.get("user_walletbalance") < pPrice) then
          executeMessage(#alert, [#msg: "club_price"])
          return 1
        end if
      end if
      tWndObj = getWindow(pDialogId)
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_activate.window")
    "habboclub_continue":
      tWndObj = getWindow(pDialogId)
      tWndObj.unmerge()
      tWndObj.merge("habbo_club_permission.window")
      me.setParentPermission(0)
    "parent_permission_checkbox":
      me.setParentPermission(not pParentPermission)
    "button_cancel", "welcom_club_ok":
      removeWindow(me.pDialogId)
    "button_ok":
      if (pParentPermission = 0) then
        executeMessage(#alert, [#msg: "habboclub_require_parent_permission", #id: "club_require_permission"])
      else
        if (tClubInfo[#status] = "inactive") then
          tMode = #subscribe
        else
          tMode = #extend
        end if
        me.openConfirmDialog(tMode)
      end if
    "close":
      removeWindow(me.pDialogId)
  end case
  return 1
end

on setupWindow me
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  createWindow(pDialogId)
  tWndObj = getWindow(pDialogId)
  tWndObj.setProperty(#title, getText("club_habbo.window.title"))
  tWndObj.merge("habbo_full.window")
end

on show_clubinfo me
  tClubInfo = me.getComponent().getStatus()
  if (tClubInfo <> 0) then
    if not windowExists(pDialogId) then
      me.setupWindow()
      tWndObj = getWindow(pDialogId)
      tWndObj.moveTo(200, 200)
      if (tClubInfo[#status] = "inactive") then
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
  if (tStatus[#status] = "active") then
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
  end if
end
