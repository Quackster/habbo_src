on construct(me)
  pPrice = value(getText("habboclub_price1"))
  pDays = value(getText("habboclub_price1.days"))
  pDialogId = "clubinfo1"
  pConnectionId = getVariable("connection.info.id")
  pConfirmDialogId = "clubconfirmdialog"
  registerMessage(#show_clubinfo, me.getID(), #show_clubinfo)
  registerMessage(#notify, me.getID(), #notify)
  return(1)
  exit
end

on notify(me, ttype)
  if me = "1001" then
    executeMessage(#alert, [#msg:"epsnotify_1001"])
    if connectionExists(pConnectionId) then
      removeConnection(pConnectionId)
    end if
  else
    if me = "550" then
      me.setupWindow()
      tWndObj = getWindow(pDialogId)
      tWndObj.moveTo(200, 200)
      tWndObj.merge("habbo_club_expired.window")
      me.setupInfoWindow()
    end if
  end if
  exit
end

on setupContinueWindow(me)
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  tText1 = getText("habboclub_txt1.member")
  tText1 = replaceChunks(tText1, "%days%", string(tClubInfo.getAt(#daysLeft)))
  tWndObj.getElement("habboclub_txt1").setText(tText1)
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  if tClubInfo.getAt(#daysLeft) > 59 then
    tWndObj.getElement("parent_permission_checkbox").setProperty(#blend, 30)
    tWndObj.getElement("habboclub_continue").setProperty(#blend, 30)
    tWndObj.getElement("habboclub_txt3").setProperty(#blend, 30)
  end if
  me.setParentPermission(0)
  exit
end

on setupInfoWindow(me)
  getWindow(pDialogId).registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  exit
end

on setParentPermission(me, tBool)
  if tBool then
    tImage = member(getmemnum("button.checkbox.on")).image
  else
    tImage = member(getmemnum("button.checkbox.off")).image
  end if
  getWindow(pDialogId).getElement("parent_permission_checkbox").setProperty(#image, tImage)
  pParentPermission = tBool
  return(1)
  exit
end

on openConfirmDialog(me, tMode)
  pPurchaseMode = tMode
  if windowExists(pConfirmDialogId) then
    removeWindow(pConfirmDialogId)
  end if
  if not createWindow(pConfirmDialogId, "habbo_simple.window", 250, 200) then
    return(0)
  end if
  tWndObj = getWindow(pConfirmDialogId)
  tWndObj.merge("habbo_club_confirm_purchase.window")
  tText1 = getText("habboclub_confirm_header")
  tText2 = getText("habboclub_confirm_body")
  tText1 = replaceChunks(tText1, "%price%", pPrice)
  tText2 = replaceChunks(tText2, "%credits%", getObject(#session).get("user_walletbalance"))
  tWndObj.getElement("habboclub_confirm_header").setText(tText1)
  tWndObj.getElement("habboclub_confirm_body").setText(tText2)
  tWndObj.registerProcedure(#eventProcConfirmMousedown, me.getID(), #mouseDown)
  return(1)
  exit
end

on eventProcConfirmMousedown(me, tEvent, tSprID, tParam)
  if me = "button_ok" then
    if pPurchaseMode = #subscribe then
      me.getComponent().subscribe(me.pDays)
    else
      if pPurchaseMode = #extend then
        me.getComponent().extendSubscription(me.pDays)
      end if
    end if
    removeWindow(pConfirmDialogId)
    return(1)
  else
    if me = "button_cancel" then
      removeWindow(pConfirmDialogId)
      return(1)
    end if
  end if
  exit
end

on eventProcDialogMousedown(me, tEvent, tSprID, tParam)
  tClubInfo = me.getComponent().getStatus()
  if me = "club_txt_intro2" then
    tWndObj = getWindow(pDialogId)
    tWndObj.unmerge()
    tWndObj.merge("habbo_club_activation.window")
    me.setParentPermission(0)
  else
    if me = "parent_permission_checkbox" then
      me.setParentPermission(not pParentPermission)
    else
      if me = "habboclub_continue" then
        if tClubInfo.getAt(#daysLeft) > 59 then
          return(1)
        end if
        if pParentPermission = 0 then
          executeMessage(#alert, [#msg:"habboclub_require_parent_permission"])
        else
          me.openConfirmDialog(#extend)
        end if
      else
        if me = "habboclub_activate" then
          if pParentPermission = 0 then
            executeMessage(#alert, [#msg:"habboclub_require_parent_permission"])
          else
            me.openConfirmDialog(#subscribe)
          end if
        else
          if me = "close" then
            removeWindow(me.pDialogId)
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on setupWindow(me)
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  createWindow(pDialogId)
  tWndObj = getWindow(pDialogId)
  tWndObj.setProperty(#title, getText("club_habbo.window.title"))
  tWndObj.merge("habbo_full.window")
  exit
end

on show_clubinfo(me)
  tClubInfo = me.getComponent().getStatus()
  if tClubInfo <> 0 then
    if not windowExists(pDialogId) then
      me.setupWindow()
      tWndObj = getWindow(pDialogId)
      tWndObj.moveTo(200, 200)
      if tClubInfo.getAt(#status) = "inactive" then
        tWndObj.merge("habbo_club_intro.window")
        me.setupInfoWindow()
      else
        tWndObj.merge("habbo_club_continue.window")
        me.setupContinueWindow()
      end if
    else
      removeWindow(pDialogId)
    end if
  end if
  return(1)
  exit
end

on updateClubStatus(me, tStatus)
  if tStatus.getAt(#status) = "active" then
    if windowExists(pDialogId) then
      removeWindow(pDialogId)
      me.show_clubinfo()
    end if
  end if
  exit
end

on subscriptionOkConfirmed(me)
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
    me.setupWindow()
    tWndObj = getWindow(pDialogId)
    tWndObj.merge("habbo_club_thanks.window")
    tEmail = getObject(#session).get("user_email")
    tTxt = getText("habboclub_thanks")
    tTxt = replaceChunks(tTxt, "%email%", tEmail)
    tWndObj.getElement("club_txt_thanks").setText(tTxt)
  end if
  exit
end