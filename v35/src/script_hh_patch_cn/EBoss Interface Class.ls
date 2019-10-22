property pWindowTitle

on construct me 
  pWindowTitle = getText("win_partner_registration", "win_partner_registration")
  return TRUE
end

on deconstruct me 
  me.hideDialog()
  return TRUE
end

on showDialog me 
  me.hideDialog()
  if not createWindow(pWindowTitle, "habbo_basic.window", 0, 0, #modal) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowTitle)
  if not objectp(tWndObj) then
    return FALSE
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
  if (tEvent = #mouseDown) then
    if (tElemID = "close") then
      me.getComponent().login()
      me.hideDialog()
    end if
  end if
  if (tEvent = #mouseUp) then
    if (tElemID = "cn_partner_enter") then
      me.getComponent().login()
      me.hideDialog()
    else
      if (tElemID = "cn_partner_link") then
        me.openEBossPopup()
      end if
    end if
  end if
end
