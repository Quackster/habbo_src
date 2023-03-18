property pWindowID, pFurniID, pPrice

on construct me
  registerMessage(#openOneClickGameBuyWindow, me.getID(), #createUiWindow)
  pWindowID = getText("notickets_window_header")
  return 1
end

on deconstruct me
  unregisterMessage(#openOneClickGameBuyWindow, me.getID())
  me.closeUiWindow()
  return 1
end

on Init me
end

on createUiWindow me
  if not createWindow(pWindowID, "habbo_full.window") then
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("habbo_games_notickets.window")
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcMouseUp, me.getID(), #mouseUp)
  return 1
end

on closeUiWindow me
  tWndObj = getWindow(pWindowID)
  if not tWndObj = VOID then
    tWndObj.close()
  end if
  return 1
end

on eventProcMouseUp me, tEvent, tSprID, tParam
  case tSprID of
    "notickets_buygame":
      me.sendBuyTwoCredits()
      me.closeUiWindow()
    "close", "notickets_cancel":
      me.closeUiWindow()
    "notickets_store_link":
      executeMessage(#show_ticketWindow)
      me.closeUiWindow()
  end case
  return 1
end

on sendBuyTwoCredits me
  tMyName = getObject(#session).GET("user_name")
  tAmount = 1
  tParams = [#integer: tAmount, #string: tMyName]
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("BTCKS", tParams)
  end if
  return 1
end
