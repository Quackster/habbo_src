property pConnectionId, pTempPassword

on construct me
  pConnectionId = getVariable("connection.info.id")
  pTempPassword = EMPTY
  return 1
end

on deconstruct me
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return 1
end

on showLogin me
  getObject(#session).set(#userName, EMPTY)
  getObject(#session).set(#Password, EMPTY)
  pTempPassword = EMPTY
  if createWindow(#login_b, "habbo_simple.window", 444, 230) then
    tWndObj = getWindow(#login_b)
    tWndObj.merge("login_b.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #keyDown)
    tWndObj.getElement("login_username").setFocus(1)
    if variableExists("username_input.font.size") then
      tElem = tWndObj.getElement("login_username")
      if tElem = 0 then
        return 0
      end if
      if tElem.pMember = VOID then
        return 0
      end if
      if tElem.pMember.type <> #field then
        return 0
      end if
      tElem.pMember.fontSize = getIntVariable("username_input.font.size")
      tElem = tWndObj.getElement("login_password")
      if tElem = 0 then
        return 0
      end if
      if tElem.pMember = VOID then
        return 0
      end if
      if tElem.pMember.type <> #field then
        return 0
      end if
      tElem.pMember.fontSize = getIntVariable("username_input.font.size")
    end if
  end if
  if variableExists("xxx.username") and variableExists("xxx.password") then
    tUserName = getVariable("xxx.username")
    tPassword = getVariable("xxx.password")
    pTempPassword = tPassword
    tWndObj.getElement("login_username").setText(tUserName)
    setVariable("xxx.username", EMPTY)
    setVariable("xxx.password", EMPTY)
    me.tryLogin()
  end if
  return 1
end

on hideLogin me
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return 1
end

on showDisconnect me
  tList = [:]
  executeMessage(#getHotelClosedDisconnectStatus, tList)
  if tList["retval"] = 1 then
    return 1
  end if
  createWindow(#error, "error.window", 0, 0, #modalcorner)
  tWndObj = getWindow(#error)
  if tWndObj <> 0 then
    tWndObj.getElement("error_title").setText(getText("Alert_ConnectionFailure"))
    tWndObj.getElement("error_text").setText(getText("Alert_ConnectionDisconnected"))
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcDisconnect, me.getID(), #mouseUp)
    the keyboardFocusSprite = 0
  end if
end

on tryLogin me
  if not windowExists(#login_b) then
    return error(me, "Window not found:" && #login_b, #tryLogin, #major)
  end if
  tWndObj = getWindow(#login_b)
  tUserName = tWndObj.getElement("login_username").getText()
  tPassword = pTempPassword
  if tUserName = EMPTY then
    return 0
  end if
  if tPassword = EMPTY then
    return 0
  end if
  getObject(#session).set(#userName, tUserName)
  getObject(#session).set(#Password, tPassword)
  tWndObj.getElement("login_ok").hide()
  tWndObj.getElement("login_connecting").setProperty(#blend, 100)
  me.blinkConnection()
  me.getComponent().setaProp(#pOkToLogin, 1)
  return me.getComponent().connect()
end

on blinkConnection me
  if not windowExists(#login_b) then
    return 0
  end if
  if timeoutExists(#login_blinker) then
    return 0
  end if
  tElem = getWindow(#login_b).getElement("login_connecting")
  if not tElem then
    return 0
  end if
  if getWindow(#login_b).getElement("login_ok").getProperty(#visible) = 1 then
    return 0
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return createTimeout(#login_blinker, 500, #blinkConnection, me.getID(), VOID, 1)
end

on updatePasswordAsterisks me
  if not windowExists(#login_b) then
    return 0
  end if
  tPwdTxt = getWindow(#login_b).getElement("login_password").getText()
  repeat with i = 1 to tPwdTxt.length
    tChar = chars(tPwdTxt, i, i)
    if (tChar <> "*") and (tChar <> " ") then
      pTempPassword = chars(pTempPassword, 1, i - 1) & tChar & chars(pTempPassword, i + 1, i + 1)
    end if
  end repeat
  tStars = EMPTY
  repeat with i = 1 to pTempPassword.length
    tStars = tStars & "*"
  end repeat
  getWindow(#login_b).getElement("login_password").setText(tStars)
end

on eventProcLogin me, tEvent, tSprID, tParam
  tWndObj = getWindow(#login_b)
  if not tWndObj then
    return 0
  end if
  case tEvent of
    #mouseUp:
      case tSprID of
        "login_password":
          tCount = tWndObj.getElement(tSprID).getText().length
          set the selStart to tCount
          set the selEnd to tCount
        "login_ok":
          return me.tryLogin()
      end case
    #keyDown:
      tTimeoutHideName = "pwdhide" & the milliSeconds
      if the keyCode = 36 then
        me.tryLogin()
        return 1
      end if
      case tSprID of
        "login_password":
          case the keyCode of
            48:
              return 0
            49:
              return 1
            51:
              if pTempPassword.length > 0 then
                pTempPassword = chars(pTempPassword, 1, pTempPassword.length - 1)
              end if
            123, 124, 125, 126:
              return 1
            117:
              if windowExists(#login_b) then
                tWndObj.getElement(tSprID).setText(EMPTY)
                pTempPassword = EMPTY
              end if
          end case
          createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), VOID, 1)
      end case
  end case
  return 0
end

on eventProcDisconnect me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    if tElemID = "error_close" then
      removeWindow(#error)
      resetClient()
    end if
  end if
end
