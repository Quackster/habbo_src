on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handleDisconnect(me, tMsg)
  error("Connection was disconnected:", tMsg && connection.getID(), #handleMsg)
  return(me.getInterface().showDisconnect())
  exit
end

on handleHello(me, tMsg)
  tPairsCount = connection.GetIntFrom()
  if integerp(tPairsCount) then
    if tPairsCount > 0 then
      i = 1
      repeat while i <= tPairsCount
        tid = connection.GetIntFrom()
        tValue = connection.GetIntFrom()
        tSession = getObject(#session)
        if me = 0 then
          tSession.set("conf_coppa", tValue > 0)
        else
          if me = 1 then
            tSession.set("conf_voucher", tValue > 0)
          else
            if me = 2 then
              tSession.set("conf_parent_email_request", tValue > 0)
            else
              if me = 3 then
                tSession.set("conf_parent_email_request_reregistration", tValue > 0)
              else
                if me = 4 then
                  tSession.set("conf_allow_direct_mail", tValue > 0)
                end if
              end if
            end if
          end if
        end if
        i = 1 + i
      end repeat
    end if
  end if
  connection.send("CHK_VERSION", [#short:getIntVariable("client.version.id")])
  exit
end

on handleSecretKey(me, tMsg)
  tKey = secretDecode(tMsg.content)
  connection.setDecoder(createObject(#temp, getClassVariable("connection.decoder.class")))
  connection.getDecoder().setKey(tKey)
  connection.setEncryption(1)
  if objectExists("nav_problem_obj") then
    removeObject("nav_problem_obj")
  end if
  if me.getComponent().isOkToLogin() then
    tUserName = getObject(#session).get(#userName)
    tPassword = getObject(#session).get(#password)
    if not stringp(tUserName) or not stringp(tPassword) then
      return(removeConnection(connection.getID()))
    end if
    if tUserName = "" or tPassword = "" then
      return(removeConnection(connection.getID()))
    end if
    connection.send("SET_UID", [#string:getMachineID()])
    connection.send("TRY_LOGIN", [#string:tUserName, #string:tPassword])
  end if
  exit
end

on handleRegistrationOK(me, tMsg)
  tUserName = getObject(#session).get(#userName)
  tPassword = getObject(#session).get(#password)
  if not stringp(tUserName) or not stringp(tPassword) then
    return(removeConnection(connection.getID()))
  end if
  if tUserName = "" or tPassword = "" then
    return(removeConnection(connection.getID()))
  end if
  connection.send("SET_UID", [#string:getMachineID()])
  connection.send("TRY_LOGIN", [#string:tUserName, #string:tPassword])
  exit
end

on handleLoginOK(me, tMsg)
  connection.send("GET_INFO")
  connection.send("GET_CREDITS")
  connection.send("GETAVAILABLEBADGES")
  exit
end

on handleUserObj(me, tMsg)
  tuser = []
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  i = 1
  repeat while tMsg <= content.count(#line)
    tLine = content.getProp(#line, i)
    tuser.setAt(tLine.getProp(#item, 1), tLine.getProp(#item, 2, tLine.count(#item)))
    i = 1 + i
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
    i = 1 + i
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
  exit
end

on handleUserBanned(me, tMsg)
  tBanMsg = getText("Alert_YouAreBanned") & "\r" & tMsg.content
  executeMessage(#openGeneralDialog, #ban, [#id:"BannWarning", #title:"Alert_YouAreBanned_T", #msg:tBanMsg, #modal:1])
  removeConnection(connection.getID())
  exit
end

on handleEPSnotify(me, tMsg)
  ttype = ""
  tdata = ""
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  f = 1
  repeat while tMsg <= content.count(#line)
    tProp = content.getPropRef(#line, f).getProp(#item, 1)
    tDesc = content.getPropRef(#line, f).getProp(#item, 2)
    if me = "t" then
      ttype = integer(tDesc)
    else
      if me = "p" then
        tdata = tDesc
      end if
    end if
    f = 1 + f
  end repeat
  the itemDelimiter = tDelim
  if me = 580 then
    if not createObject("lang_test", "CLangTest") then
      return(error(me, "Failed to init lang tester!", #handle_eps_notify))
    else
      return(getObject("lang_test").setWord(tdata))
    end if
  end if
  executeMessage(ttype, tdata, tMsg, connection.getID())
  exit
end

on handleSystemBroadcast(me, tMsg)
  tMsg = tMsg.getAt(#content)
  tMsg = replaceChunks(tMsg, "\\r", "\r")
  tMsg = replaceChunks(tMsg, "<br>", "\r")
  executeMessage(#alert, [#msg:tMsg])
  the keyboardFocusSprite = 0
  exit
end

on handleCheckSum(me, tMsg)
  getObject(#session).set("user_checksum", tMsg.content)
  exit
end

on handleAvailableBadges(me, tMsg)
  tBadgeList = []
  tNumber = connection.GetIntFrom()
  i = 1
  repeat while i <= tNumber
    tBadgeID = connection.GetStrFrom()
    tBadgeList.add(tBadgeID)
    i = 1 + i
  end repeat
  tChosenBadge = connection.GetIntFrom()
  tVisible = connection.GetIntFrom()
  tChosenBadge = tChosenBadge + 1
  if tChosenBadge < 1 then
    tChosenBadge = 1
  end if
  getObject("session").set("available_badges", tBadgeList)
  getObject("session").set("chosen_badge_index", tChosenBadge)
  getObject("session").set("badge_visible", tVisible)
  exit
end

on handleRights(me, tMsg)
  tSession = getObject(#session)
  tSession.set("user_rights", [])
  tRights = tSession.get("user_rights")
  tPrivilegeFound = 1
  repeat while tPrivilegeFound = 1
    tPrivilege = connection.GetStrFrom()
    if tPrivilege = void() or tPrivilege = "" then
      tPrivilegeFound = 0
      next repeat
    end if
    tRights.add(tPrivilege)
  end repeat
  return(1)
  exit
end

on handleErr(me, tMsg)
  error(me, "Error from server:" && tMsg.content, #handle_error)
  if tMsg.content contains "login incorrect" then
    removeConnection(connection.getID())
    me.getComponent().setaProp(#pOkToLogin, 0)
    if getObject(#session).exists("failed_password") then
      openNetPage(getText("login_forgottenPassword_url"))
      me.getInterface().showLogin()
      return(0)
    else
      getObject(#session).set("failed_password", 1)
      me.getInterface().showLogin()
      executeMessage(#alert, [#msg:"Alert_WrongNameOrPassword"])
    end if
  else
    if tMsg.content contains "mod_warn" then
      tDelim = the itemDelimiter
      the itemDelimiter = "/"
      tTextStr = #item.getProp(2, tMsg, content.count(#item))
      the itemDelimiter = tDelim
      executeMessage(#alert, [#title:"alert_warning", #msg:tTextStr])
    else
      if tMsg.content contains "Version not correct" then
        executeMessage(#alert, [#msg:"Old client version!!!"])
      end if
    end if
  end if
  return(1)
  exit
end

on handleModAlert(me, tMsg)
  if not voidp(tMsg.content) then
    executeMessage(#alert, [#title:"alert_moderator_warning", #msg:tMsg.content])
  else
    error(me, "Error in moderator alert:" && tMsg.content, #handleModAlert)
  end if
  exit
end

on handleAdv(me, tMsg)
  tStr = tMsg.content
  tTxt = replaceChunks(tStr.getProp(#line, 4), "<br>", "\r")
  tTxt = replaceChunks(tTxt, "\\r", "\r")
  tid = tStr.getProp(#line, 1)
  tURL = tStr.getProp(#line, 2)
  tTyp = tStr.getProp(#line, 3)
  tLnk = tStr.getProp(#line, 5)
  if tURL = "" then
    return(0)
  end if
  tMemNum = queueDownload(tURL, "advertisement", #bitmap, 1)
  tSession = getObject(#session)
  tSession.set("ad_id", tid)
  tSession.set("ad_url", tURL)
  tSession.set("ad_text", tTxt)
  tSession.set("ad_type", tTyp)
  tSession.set("ad_memnum", tMemNum)
  if tLnk = "" then
    tSession.set("ad_link", 0)
  else
    tSession.set("ad_link", tLnk)
  end if
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(-1, #handleDisconnect)
  tMsgs.setaProp(0, #handleHello)
  tMsgs.setaProp(1, #handleSecretKey)
  tMsgs.setaProp(2, #handleRights)
  tMsgs.setaProp(3, #handleLoginOK)
  tMsgs.setaProp(5, #handleUserObj)
  tMsgs.setaProp(11, #handleAdv)
  tMsgs.setaProp(33, #handleErr)
  tMsgs.setaProp(35, #handleUserBanned)
  tMsgs.setaProp(51, #handleRegistrationOK)
  tMsgs.setaProp(52, #handleEPSnotify)
  tMsgs.setaProp(139, #handleSystemBroadcast)
  tMsgs.setaProp(141, #handleCheckSum)
  tMsgs.setaProp(161, #handleModAlert)
  tMsgs.setaProp(229, #handleAvailableBadges)
  tCmds = []
  tCmds.setaProp("TRY_LOGIN", 4)
  tCmds.setaProp("CHK_VERSION", 5)
  tCmds.setaProp("SET_UID", 6)
  tCmds.setaProp("GET_INFO", 7)
  tCmds.setaProp("GET_CREDITS", 8)
  tCmds.setaProp("GETAVAILABLEBADGES", 157)
  tCmds.setaProp("GET_PASSWORD", 47)
  tCmds.setaProp("LANGCHECK", 58)
  tConn = getVariable("connection.info.id", #info)
  if tBool then
    registerListener(tConn, me.getID(), tMsgs)
    registerCommands(tConn, me.getID(), tCmds)
  else
    unregisterListener(tConn, me.getID(), tMsgs)
    unregisterCommands(tConn, me.getID(), tCmds)
  end if
  return(1)
  exit
end