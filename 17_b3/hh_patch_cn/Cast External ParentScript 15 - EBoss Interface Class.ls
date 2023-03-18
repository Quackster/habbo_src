property pWindowTitle

on construct me
  pWindowTitle = getText("win_partner_registration", "win_partner_registration")
  return 1
end

on deconstruct me
  me.hideDialog()
  return 1
end

on showDialog me
  me.hideDialog()
  if not createWindow(pWindowTitle, "habbo_basic.window", 0, 0, #modal) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if not objectp(tWndObj) then
    return 0
  end if
  if not tWndObj.merge("cn_partner_registration.window") then
    tWndObj.close()
  end if
  tWndObj.center()
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseDown)
end

on hideDialog me
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
end

on openEBossPopup me
  tUserID = me.getComponent().userID()
  tPartnerURL = getVariable("partner.registration.url")
  tPartnerURL = tPartnerURL & string(tUserID)
  openNetPage(tPartnerURL)
end

on eventProc me, tEvent, tElemID, tParm
  if tEvent = #mouseDown then
    case tElemID of
      "close":
        me.getComponent().login()
        me.hideDialog()
    end case
  end if
  if tEvent = #mouseUp then
    case tElemID of
      "cn_partner_enter":
        me.getComponent().login()
        me.hideDialog()
      "cn_partner_link":
        me.openEBossPopup()
    end case
  end if
end
