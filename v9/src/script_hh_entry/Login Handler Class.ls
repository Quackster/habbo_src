on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handleDisconnect me, tMsg 
  error(me, "Connection was disconnected:" && tMsg.connection.getID(), #handleMsg)
  return(me.getInterface().showDisconnect())
end

on handleHello me, tMsg 
  return(tMsg.connection.send("GENERATEKEY"))
end

on handleSessionParameters me, tMsg 
  tPairsCount = tMsg.connection.GetIntFrom()
  if integerp(tPairsCount) then
    if tPairsCount > 0 then
      i = 1
      repeat while i <= tPairsCount
        tid = tMsg.connection.GetIntFrom()
        tSession = getObject(#session)
        if (tid = 0) then
          tValue = tMsg.connection.GetIntFrom()
          tSession.set("conf_coppa", tValue > 0)
          tSession.set("conf_strong_coppa_required", tValue > 1)
        else
          if (tid = 1) then
            tValue = tMsg.connection.GetIntFrom()
            tSession.set("conf_voucher", tValue > 0)
          else
            if (tid = 2) then
              tValue = tMsg.connection.GetIntFrom()
              tSession.set("conf_parent_email_request", tValue > 0)
            else
              if (tid = 3) then
                tValue = tMsg.connection.GetIntFrom()
                tSession.set("conf_parent_email_request_reregistration", tValue > 0)
              else
                if (tid = 4) then
                  tValue = tMsg.connection.GetIntFrom()
                  tSession.set("conf_allow_direct_mail", tValue > 0)
                else
                  if (tid = 5) then
                    tValue = tMsg.connection.GetStrFrom()
                    if not objectExists(#dateFormatter) then
                      createObject(#dateFormatter, ["Date Class"])
                    end if
                    tDateForm = getObject(#dateFormatter)
                    if not (tDateForm = 0) then
                      tDateForm.define(tValue)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
        i = (1 + i)
      end repeat
    end if
  end if
  return(me.sendLogin(tMsg.connection))
end

on handleSecretKey me, tMsg 
  tKey = secretDecode(tMsg.content)
  tMsg.connection.setDecoder(createObject(#temp, getClassVariable("connection.decoder.class")))
  tMsg.connection.getDecoder().setKey(tKey)
  tMsg.connection.setEncryption(1)
  tClientURL = getMoviePath() & "habbo.dcr"
  tExtVarsURL = getExtVarPath()
  tHost = tMsg.connection.getProperty(#host)
  if tHost contains deobfuscate("��KfGNuSE��@kLK��KiOIgCW{\\S") then
    tClientURL = ""
  end if
  if tHost contains deobfuscate("8\u0019\u0010<\u001a\u0014��\u0017;\u001e\u000b��\u0015��\b��\u0014") then
    tClientURL = ""
  end if
  tMsg.connection.send("VERSIONCHECK", [#integer:getIntVariable("client.version.id"), #string:tClientURL, #string:tExtVarsURL])
  tMsg.connection.send("UNIQUEID", [#string:getMachineID()])
  tMsg.connection.send("GET_SESSION_PARAMETERS")
  return TRUE
end

on sendLogin me, tConnection 
  if objectExists("nav_problem_obj") then
    removeObject("nav_problem_obj")
  end if
  if me.getComponent().isOkToLogin() then
    tUserName = getObject(#session).get(#userName)
    tPassword = getObject(#session).get(#password)
    if not stringp(tUserName) or not stringp(tPassword) then
      return(removeConnection(tConnection.getID()))
    end if
    if (tUserName = "") or (tPassword = "") then
      return(removeConnection(tConnection.getID()))
    end if
    return(tConnection.send("TRY_LOGIN", [#string:tUserName, #string:tPassword]))
  end if
  return TRUE
end

on handlePing me, tMsg 
  tMsg.connection.send("PONG")
end

on handleRegistrationOK me, tMsg 
  tUserName = getObject(#session).get(#userName)
  tPassword = getObject(#session).get(#password)
  if not stringp(tUserName) or not stringp(tPassword) then
    return(removeConnection(tMsg.connection.getID()))
  end if
  if (tUserName = "") or (tPassword = "") then
    return(removeConnection(tMsg.connection.getID()))
  end if
  return(tMsg.connection.send("TRY_LOGIN", [#string:tUserName, #string:tPassword]))
end

on handleLoginOK me, tMsg 
  tMsg.connection.send("GET_INFO")
  tMsg.connection.send("GET_CREDITS")
  tMsg.connection.send("GETAVAILABLEBADGES")
  if objectExists(#session) then
    getObject(#session).set("userLoggedIn", 1)
  end if
  if not objectExists("loggertool") then
    if memberExists("Debug System Class") then
      createObject("loggertool", "Debug System Class")
      if (getIntVariable("client.debug.window", 0) = 3) then
        getObject("loggertool").initDebug()
      else
        getObject("loggertool").tryAutoStart()
      end if
    end if
  end if
end

on handleUserObj me, tMsg 
  tuser = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  i = 1
  repeat while i <= tMsg.content.count(#line)
    tLine = tMsg.content.getProp(#line, i)
    tuser.setAt(tLine.getProp(#item, 1), tLine.getProp(#item, 2, tLine.count(#item)))
    i = (1 + i)
  end repeat
  if not voidp(tuser.getAt("sex")) then
    if tuser.getAt("sex") contains "F" or tuser.getAt("sex") contains "f" then
      tuser.setAt("sex", "F")
    else
      tuser.setAt("sex", "M")
    end if
  end if
  if objectExists("Figure_System") then
    tuser.setAt("figure", getObject("Figure_System").parseFigure(tuser.getAt("figure"), tuser.getAt("sex"), "user", "USEROBJECT"))
  end if
  the itemDelimiter = tDelim
  tSession = getObject(#session)
  i = 1
  repeat while i <= tuser.count
    tSession.set("user_" & tuser.getPropAt(i), tuser.getAt(i))
    i = (1 + i)
  end repeat
  tSession.set(#userName, tSession.get("user_name"))
  tSession.set("user_password", tSession.get(#password))
  executeMessage(#updateFigureData)
  if getObject(#session).exists("user_logged") then
    return()
  else
    getObject(#session).set("user_logged", 1)
  end if
  if getIntVariable("quickLogin", 0) and the runMode contains "Author" then
    setPref(getVariable("fuse.project.id", "fusepref"), string([getObject(#session).get(#userName), getObject(#session).get(#password)]))
    me.getInterface().hideLogin()
  else
    me.getInterface().showUserFound()
  end if
  executeMessage(#userlogin, "userLogin")
end

on handleUserBanned me, tMsg 
  tBanMsg = getText("Alert_YouAreBanned") & "\r" & tMsg.content
  executeMessage(#openGeneralDialog, #ban, [#id:"BannWarning", #title:"Alert_YouAreBanned_T", #Msg:tBanMsg, #modal:1])
  removeConnection(tMsg.connection.getID())
end

on handleEPSnotify me, tMsg 
  ttype = ""
  tdata = ""
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  f = 1
  repeat while f <= tMsg.content.count(#line)
    tProp = tMsg.content.getPropRef(#line, f).getProp(#item, 1)
    tDesc = tMsg.content.getPropRef(#line, f).getProp(#item, 2)
    if (tProp = "t") then
      ttype = integer(tDesc)
    else
      if (tProp = "p") then
        tdata = tDesc
      end if
    end if
    f = (1 + f)
  end repeat
  the itemDelimiter = tDelim
  if (tProp = 580) then
    if not createObject("lang_test", "CLangTest") then
      return(error(me, "Failed to init lang tester!", #handle_eps_notify))
    else
      return(getObject("lang_test").setWord(tdata))
    end if
  end if
  executeMessage(#notify, ttype, tdata, tMsg.connection.getID())
end

on handleSystemBroadcast me, tMsg 
  tMsg = tMsg.getAt(#content)
  tMsg = replaceChunks(tMsg, "\\r", "\r")
  tMsg = replaceChunks(tMsg, "<br>", "\r")
  executeMessage(#alert, [#Msg:tMsg])
  the keyboardFocusSprite = 0
end

on handleCheckSum me, tMsg 
  getObject(#session).set("user_checksum", tMsg.content)
end

on handleAvailableBadges me, tMsg 
  tBadgeList = []
  tNumber = tMsg.connection.GetIntFrom()
  i = 1
  repeat while i <= tNumber
    tBadgeID = tMsg.connection.GetStrFrom()
    tBadgeList.add(tBadgeID)
    i = (1 + i)
  end repeat
  tChosenBadge = tMsg.connection.GetIntFrom()
  tVisible = tMsg.connection.GetIntFrom()
  tChosenBadge = (tChosenBadge + 1)
  if tChosenBadge < 1 then
    tChosenBadge = 1
  end if
  getObject("session").set("available_badges", tBadgeList)
  getObject("session").set("chosen_badge_index", tChosenBadge)
  getObject("session").set("badge_visible", tVisible)
end

on handleRights me, tMsg 
  tSession = getObject(#session)
  tSession.set("user_rights", [])
  tRights = tSession.get("user_rights")
  tPrivilegeFound = 1
  repeat while (tPrivilegeFound = 1)
    tPrivilege = tMsg.connection.GetStrFrom()
    if (tPrivilege = void()) or (tPrivilege = "") then
      tPrivilegeFound = 0
      next repeat
    end if
    tRights.add(tPrivilege)
  end repeat
  return TRUE
end

on handleErr me, tMsg 
  error(me, "Error from server:" && tMsg.content, #handle_error)
  if tMsg.content contains "login incorrect" then
    removeConnection(tMsg.connection.getID())
    me.getComponent().setaProp(#pOkToLogin, 0)
    if getObject(#session).exists("failed_password") then
      openNetPage(getText("login_forgottenPassword_url"))
      me.getInterface().showLogin()
      return FALSE
    else
      getObject(#session).set("failed_password", 1)
      me.getInterface().showLogin()
      executeMessage(#alert, [#Msg:"Alert_WrongNameOrPassword"])
    end if
  else
    if tMsg.content contains "mod_warn" then
      tDelim = the itemDelimiter
      the itemDelimiter = "/"
      tTextStr = tMsg.content.getProp(#item, 2, tMsg.content.count(#item))
      the itemDelimiter = tDelim
      executeMessage(#alert, [#title:"alert_warning", #Msg:tTextStr, #modal:1])
    else
      if tMsg.content contains "Version not correct" then
        executeMessage(#alert, [#Msg:"Old client version!!!"])
      end if
    end if
  end if
  return TRUE
end

on handleModAlert me, tMsg 
  if not voidp(tMsg.content) then
    executeMessage(#alert, [#title:"alert_warning", #Msg:tMsg.content])
  else
    error(me, "Error in moderator alert:" && tMsg.content, #handleModAlert)
  end if
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(-1, #handleDisconnect)
  tMsgs.setaProp(0, #handleHello)
  tMsgs.setaProp(1, #handleSecretKey)
  tMsgs.setaProp(2, #handleRights)
  tMsgs.setaProp(3, #handleLoginOK)
  tMsgs.setaProp(5, #handleUserObj)
  tMsgs.setaProp(33, #handleErr)
  tMsgs.setaProp(35, #handleUserBanned)
  tMsgs.setaProp(50, #handlePing)
  tMsgs.setaProp(51, #handleRegistrationOK)
  tMsgs.setaProp(52, #handleEPSnotify)
  tMsgs.setaProp(139, #handleSystemBroadcast)
  tMsgs.setaProp(141, #handleCheckSum)
  tMsgs.setaProp(161, #handleModAlert)
  tMsgs.setaProp(229, #handleAvailableBadges)
  tMsgs.setaProp(257, #handleSessionParameters)
  tCmds = [:]
  tCmds.setaProp("TRY_LOGIN", 4)
  tCmds.setaProp("VERSIONCHECK", 5)
  tCmds.setaProp("UNIQUEID", 6)
  tCmds.setaProp("GET_INFO", 7)
  tCmds.setaProp("GET_CREDITS", 8)
  tCmds.setaProp("GET_PASSWORD", 47)
  tCmds.setaProp("LANGCHECK", 58)
  tCmds.setaProp("BTCKS", 105)
  tCmds.setaProp("GETAVAILABLEBADGES", 157)
  tCmds.setaProp("GET_SESSION_PARAMETERS", 181)
  tCmds.setaProp("PONG", 196)
  tCmds.setaProp("GENERATEKEY", 202)
  tConn = getVariable("connection.info.id", #info)
  if tBool then
    registerListener(tConn, me.getID(), tMsgs)
    registerCommands(tConn, me.getID(), tCmds)
  else
    unregisterListener(tConn, me.getID(), tMsgs)
    unregisterCommands(tConn, me.getID(), tCmds)
  end if
  return TRUE
end
