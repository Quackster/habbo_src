on construct(me)
  me.updatePurseSaldo()
  me.updatePurseTickets()
  me.updatePurseFilm()
  registerMessage(#updateCreditCount, me.getID(), #updatePurseSaldo)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#updateCreditCount, me.getID())
  exit
end

on updatePurseSaldo(me)
  if not threadExists(#catalogue) then
    return(0)
  end if
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_amount") then
      if getObject(#session).exists("user_walletbalance") then
        tSaldo = getObject(#session).GET("user_walletbalance")
      else
        tSaldo = "-"
      end if
      tWndObj.getElement("purse_amount").setText(tSaldo)
    end if
  end if
  exit
end

on updatePurseTickets(me)
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_info_tickets") then
      tFieldTxt = getObject(#session).GET("user_ph_tickets") && getText("purse_info_tickets")
      tWndObj.getElement("purse_info_tickets").setText(tFieldTxt)
    end if
    return(1)
  end if
  exit
end

on updatePurseFilm(me)
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_info_film") then
      tFieldTxt = getObject(#session).GET("user_photo_film") && getText("purse_info_film")
      tWndObj.getElement("purse_info_film").setText(tFieldTxt)
    end if
    return(1)
  end if
  exit
end

on eventProc(me, tEvent, tSprID, tProp)
  if tEvent = #mouseUp then
    if tSprID = "close" then
      return(0)
    end if
  end if
  if tEvent = #mouseDown then
    tloc = the mouseLoc
    if me = "coins_btn" then
      executeMessage(#externalLinkClick, tloc)
      openNetPage(getText("url_purselink"))
    else
      if me = "vouchers_btn" then
        executeMessage(#externalLinkClick, tloc)
        openNetPage(getText("purse_vouchers_helpurl"))
      else
        return(0)
      end if
    end if
  end if
  return(1)
  exit
end