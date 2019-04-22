property pTempPassword

on construct me 
  pConnectionId = getVariable("connection.info.id")
  pTempPassword = []
  return(1)
end

on deconstruct me 
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return(1)
end

on showLogin me 
  getObject(#session).set(#userName, "")
  getObject(#session).set(#password, "")
  pTempPassword = []
  if createWindow(#login_a, "habbo_simple.window", 444, 100) then
    tWndObj = getWindow(#login_a)
    tWndObj.merge("login_a.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
  end if
  if createWindow(#login_b, "habbo_simple.window", 444, 230) then
    tWndObj = getWindow(#login_b)
    tWndObj.merge("login_b.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #keyDown)
    tWndObj.getElement("login_username").setFocus(1)
  end if
  return(1)
end

on hideLogin me 
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return(1)
end

on showDisconnect me 
  createWindow(#error, "error.window", 0, 0, #modal)
  tWndObj = getWindow(#error)
  tWndObj.getElement("error_title").setText(getText("Alert_ConnectionFailure"))
  tWndObj.getElement("error_text").setText(getText("Alert_ConnectionDisconnected"))
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDisconnect, me.getID(), #mouseUp)
  the keyboardFocusSprite = 0
end

on tryLogin me 
  if not windowExists(#login_b) then
    return(error(me, "Window not found:" && #login_b, #eventProcLogin))
  end if
  tWndObj = getWindow(#login_b)
  tUserName = tWndObj.getElement("login_username").getText()
  tPassword = ""
  repeat while pTempPassword <= undefined
    tChar = getAt(undefined, undefined)
  end repeat
  if tUserName = "" then
    return(0)
  end if
  if tPassword = "" then
    return(0)
  end if
  getObject(#session).set(#userName, tUserName)
  getObject(#session).set(#password, tPassword)
  tWndObj.getElement("login_ok").hide()
  tWndObj.getElement("login_connecting").setProperty(#blend, 100)
  tElem = tWndObj.getElement("login_forgotten")
  tElem.setProperty(#blend, 99)
  tElem.setProperty(#cursor, 0)
  tElem = getWindow(#login_a).getElement("login_createUser")
  tElem.setProperty(#blend, 99)
  tElem.setProperty(#cursor, 0)
  me.blinkConnection()
  me.getComponent().setaProp(#pOkToLogin, 1)
  return(me.getComponent().connect())
end

on blinkConnection me 
  if not windowExists(#login_b) then
    return(0)
  end if
  if timeoutExists(#login_blinker) then
    return(0)
  end if
  tElem = getWindow(#login_b).getElement("login_connecting")
  if not tElem then
    return(0)
  end if
  if getWindow(#login_b).getElement("login_ok").getProperty(#visible) = 1 then
    return(0)
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return(createTimeout(#login_blinker, 500, #blinkConnection, me.getID(), void(), 1))
end

on showUserFound me 
  if windowExists(#login_b) then
    getWindow(#login_b).unmerge()
  else
    createWindow(#login_b, "habbo_simple.window", 444, 230)
  end if
  tWndObj = getWindow(#login_b)
  tWndObj.merge("login_c.window")
  tTxt = tWndObj.getElement("login_c_welcome").getText()
  tTxt = tTxt && getObject(#session).get("user_name")
  tWndObj.getElement("login_c_welcome").setText(tTxt)
  if objectExists("Figure_Preview") then
    tBuffer = getObject("Figure_Preview").createTemplateHuman("h", 3, "wave")
    tWndObj.getElement("login_preview").setProperty(#buffer, tBuffer)
    me.delay(800, #myHabboSmile)
  else
    me.hideLogin()
  end if
  return(1)
end

on myHabboSmile me 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createTemplateHuman("h", 3, "gest", "temp sml")
  end if
  me.delay(1200, #stopWaving)
end

on stopWaving me 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createTemplateHuman("h", 3, "reset")
    getObject("Figure_Preview").createTemplateHuman("h", 3, "gest", "temp sml")
    getObject("Figure_Preview").createTemplateHuman("h", 3, "remove")
  end if
  me.delay(400, #hideLogin)
end

on eventProcLogin me, tEvent, tSprID, tParam 
  if tEvent = #mouseUp then
    if tEvent = "login_ok" then
      return(me.tryLogin())
    else
      if tEvent = "login_createUser" then
        if getWindow(#login_a).getElement(tSprID).getProperty(#blend) = 100 then
          if windowExists(#login_a) then
            removeWindow(#login_a)
          end if
          if windowExists(#login_b) then
            removeWindow(#login_b)
          end if
          executeMessage(#show_registration)
          return(1)
        end if
      else
        if tEvent = "login_forgotten" then
          if getWindow(#login_b).getElement(tSprID).getProperty(#blend) = 100 then
            openNetPage(getText("login_forgottenPassword_url"))
          end if
        end if
      end if
    end if
  else
    if tEvent = #keyDown then
      if the keyCode = 36 then
        me.tryLogin()
        return(1)
      end if
      if tEvent = "login_password" then
        if tEvent = 48 then
          return(0)
        else
          if tEvent = 49 then
            return(1)
          else
            if tEvent = 51 then
              if pTempPassword.count > 0 then
                pTempPassword.deleteAt(pTempPassword.count)
              end if
            else
              if tEvent = 117 then
                pTempPassword = []
              else
                tASCII = charToNum(the key)
                if tASCII > 31 and tASCII < 128 then
                  if pTempPassword.count < getIntVariable("pass.length.max", 36) then
                    pTempPassword.append(the key)
                  end if
                end if
              end if
            end if
          end if
        end if
        tStr = ""
        repeat while tEvent <= tSprID
          tChar = getAt(tSprID, tEvent)
        end repeat
        getWindow(#login_b).getElement(tSprID).setText(tStr)
        the selStart = pTempPassword.count
        the selEnd = pTempPassword.count
        return(1)
      end if
    end if
  end if
  return(0)
end

on eventProcDisconnect me, tEvent, tElemID, tParam 
  if tEvent = #mouseUp then
    if tElemID = "error_close" then
      removeWindow(#error)
      resetClient()
    end if
  end if
end
