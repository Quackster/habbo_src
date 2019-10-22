on construct me 
  me.updatePurseSaldo()
  me.updatePurseFilm()
  registerMessage(#updateCreditCount, me.getID(), #updatePurseSaldo)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#updateCreditCount, me.getID())
end

on updatePurseSaldo me 
  if not threadExists(#catalogue) then
    return FALSE
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
end

on updatePurseFilm me 
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_info_film") then
      tFieldTxt = getObject(#session).GET("user_photo_film") && getText("purse_info_film")
      tWndObj.getElement("purse_info_film").setText(tFieldTxt)
    end if
    return TRUE
  end if
end

on eventProc me, tEvent, tSprID, tProp 
  if (tEvent = #mouseUp) then
    if (tSprID = "close") then
      return FALSE
    end if
  end if
  if (tEvent = #mouseDown) then
    tloc = the mouseLoc
    if (tSprID = "coins_btn") then
      executeMessage(#externalLinkClick, tloc)
      openNetPage(getText("url_purselink"))
    else
      if (tSprID = "vouchers_btn") then
        executeMessage(#externalLinkClick, tloc)
        openNetPage(getText("purse_vouchers_helpurl"))
      else
        return FALSE
      end if
    end if
  end if
  return TRUE
end
