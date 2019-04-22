on construct(me)
  pPrice = value(getText("habboclub_price1"))
  pDays = value(getText("habboclub_price1.days"))
  pDialogId = "clubinfo1"
  pConnectionId = getVariable("connection.info.id")
  registerMessage(#show_clubinfo, me.getID(), #show_clubinfo)
  registerMessage(#notify, me.getID(), #notify)
  return(1)
  exit
end

on notify(me, ttype)
  if me = 1001 then
    executeMessage(#alert, [#msg:"epsnotify_1001"])
    if connectionExists(pConnectionId) then
      removeConnection(pConnectionId)
    end if
  else
    if me = 550 then
      me.setupWindow()
      tWndObj = getWindow(pDialogId)
      tWndObj.moveTo(200, 200)
      tWndObj.merge("habbo_club_expired.window")
      tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
    end if
  end if
  exit
end

on setupContinueWindow(me)
  tClubInfo = me.getComponent().getStatus()
  tWndObj = getWindow(pDialogId)
  tText1 = getText("club_txt_renew1")
  tText1 = replaceChunks(tText1, "%days%", string(tClubInfo.getAt(#daysLeft)))
  tWndObj.getElement("club_txt_renew1").setText(tText1)
  if not getText("club_paybycash_url") starts "http" then
    tWndObj.getElement("button_paycash").setProperty(#visible, 0)
  end if
  tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  exit
end

on setupInfoWindow(me)
  if not getText("club_paybycash_url") starts "http" then
    getWindow(pDialogId).getElement("club_link_paycash").setProperty(#visible, 0)
  end if
  if not getText("club_info_url") starts "http" then
    getWindow(pDialogId).getElement("club_link_whatis").setProperty(#visible, 0)
  end if
  getWindow(pDialogId).registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  exit
end

on setupRenewWindow(me)
  getWindow(pDialogId).registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
  exit
end

on eventProcDialogMousedown(me, tEvent, tSprID, tParam)
  tClubInfo = me.getComponent().getStatus()
  if me = "club_expired_link" then
    tWndObj = getWindow(pDialogId)
    tWndObj.unmerge()
    tWndObj.merge("habbo_club_activate.window")
  else
    if me = "club_change_subscription" then
      tSession = getObject(#session)
      tURL = getText("club_change_url")
      tURL = tURL & urlEncode(tSession.get("user_name"))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
      end if
      openNetPage(tURL)
    else
      if me = "club_link_whatis" then
        openNetPage("club_info_url")
      else
        if me <> "button_paycash" then
          if me = "club_link_paycash" then
            tSession = getObject(#session)
            tURL = getText("club_paybycash_url")
            tURL = tURL & urlEncode(tSession.get("user_name"))
            if tSession.exists("user_checksum") then
              tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
            end if
            openNetPage(tURL, "_new")
          else
            if me <> "button_buy" then
              if me = "button_paycoins" then
                tWndObj = getWindow(pDialogId)
                tWndObj.unmerge()
                tWndObj.merge("habbo_club_activate.window")
              else
                if me = "habboclub_continue" then
                  if tClubInfo.getAt(#daysLeft) > 62 then
                    executeMessage(#alert, [#msg:"club_timefull"])
                    return(1)
                  end if
                  tSession = getObject(#session)
                  if tSession.exists("user_walletbalance") then
                    if tSession.get("user_walletbalance") < pPrice then
                      executeMessage(#alert, [#msg:"club_price"])
                      return(1)
                    end if
                  end if
                  if tClubInfo.getAt(#status) = "inactive" then
                    me.getComponent().subscribe(me.pDays)
                  else
                    me.getComponent().extendSubscription(me.pDays)
                    removeWindow(pDialogId)
                  end if
                  return(1)
                else
                  if me = "parent_permission_checkbox" then
                    me.setParentPermission(not pParentPermission)
                  else
                    if me <> "button_cancel" then
                      if me = "welcom_club_ok" then
                        removeWindow(me.pDialogId)
                      else
                        if me = "close" then
                          removeWindow(me.pDialogId)
                        end if
                      end if
                      return(1)
                      exit
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

on setupWindow(me)
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  if not createWindow(pDialogId) then
    return(0)
  end if
  tWndObj = getWindow(pDialogId)
  tWndObj.setProperty(#title, getText("club_habbo.window.title"))
  if not tWndObj.merge("habbo_full.window") then
    return(tWndObj.close())
  end if
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
        if not integerp(tClubInfo.getAt(#daysLeft)) then
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
    tWndObj.registerProcedure(#eventProcDialogMousedown, me.getID(), #mouseDown)
    me.getComponent().askforBadgeUpdate()
  end if
  exit
end