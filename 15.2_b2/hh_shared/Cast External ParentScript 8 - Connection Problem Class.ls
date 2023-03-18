property pTimeOutID, pWindowID, pDelayLength

on construct me
  pTimeOutID = "connection_problem_timeout"
  pWindowID = "connection_problem_window"
  if variableExists("failed.connection.delay") then
    pDelayLength = getIntVariable("failed.connection.delay")
  else
    pDelayLength = 20000
  end if
  registerMessage(#userlogin, me.getID(), #Remove)
  if pDelayLength = 0 then
    return removeObject(me.getID())
  else
    return createTimeout(pTimeOutID, pDelayLength, #showDialog, me.getID(), VOID, 1)
  end if
end

on deconstruct me
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  unregisterMessage(#userlogin, me.getID())
  return 1
end

on Remove me
  return removeObject(me.getID())
end

on showDialog me
  if createWindow(pWindowID) then
    tWndObj = getWindow(pWindowID)
    tWndObj.setProperty(#title, getText("log_problem_title"))
    tWndObj.merge("habbo_basic.window")
    tWndObj.merge("habbo_alert_c.window")
    tWndObj.resizeBy(40, 30)
    tWndObj.center()
    tWndObj.getElement("alert_title").setText(getText("log_problem_title"))
    tWndObj.getElement("alert_text").setText(getText("log_problem_text"))
    tWndObj.getElement("alert_link").setText(getText("log_problem_link"))
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  end if
end

on eventProc me, tEvent, tElemID
  if tEvent = #mouseUp then
    case tElemID of
      "close", "alert_ok":
        return removeObject(me.getID())
      "alert_link":
        return openNetPage(getText("log_problem_url"))
    end case
  end if
end
