property pWindowID, pPrice, pFurniID

on construct me 
  pWindowID = getText("credit_redeem_window")
  return(1)
end

on deconstruct me 
  tWndObj = getWindow(pWindowID)
  if not tWndObj = void() then
    tWndObj.close()
  end if
  return(1)
end

on Init me, tFurniID, tPrice 
  pPrice = tPrice
  pFurniID = tFurniID
  if not me.createUiWindow() then
    removeObject(me.getID())
    return(0)
  end if
  return(1)
end

on createUiWindow me 
  if not createWindow(pWindowID, "habbo_full.window") then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("credit_redeem.window")
  tWndObj.center()
  tText = replaceChunks(getText("credit_redeem_text"), "%value%", string(pPrice))
  if tWndObj.elementExists("credit_redeem_txt") then
    tWndObj.getElement("credit_redeem_txt").setText(tText)
  end if
  if getText("credit_redeem_url") = "credit_redeem_url" then
    if tWndObj.elementExists("credit_redeem_info") then
      tWndObj.getElement("credit_redeem_info").hide()
    end if
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcMouseUp, me.getID(), #mouseUp)
  return(1)
end

on eventProcMouseUp me, tEvent, tSprID, tParam 
  if tSprID = "credit_redeem" then
    me.sendCreditRedeem()
    removeObject(me.getID())
  else
    if tSprID <> "close" then
      if tSprID = "credit_cancel" then
        removeObject(me.getID())
      else
        if tSprID = "credit_redeem_info" then
          me.openHelpURL()
        end if
      end if
      return(1)
    end if
  end if
end

on sendCreditRedeem me 
  getThread(#room).getComponent().getRoomConnection().send("CONVERT_FURNI_TO_CREDITS", [#integer:integer(pFurniID)])
  return(1)
end

on openHelpURL me 
  executeMessage(#externalLinkClick, the mouseLoc)
  openNetPage("credit_redeem_url")
  return(1)
end
