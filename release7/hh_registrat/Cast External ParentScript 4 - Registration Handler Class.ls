on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_ok me, tMsg
  if me.getComponent().pState = "openFigureCreator" then
    me.getComponent().updateState("openFigureCreator")
  end if
end

on handle_login_ok me, tMsg
  if getObject(#session).exists("conf_parent_email_request") then
    if getObject(#session).get("conf_parent_email_request") then
      me.getComponent().sendParentEmail()
    end if
  end if
end

on handle_regok me, tMsg
  me.getComponent().newFigureReady()
end

on handle_updateok me, tMsg
  me.getComponent().figureUpdateReady()
end

on handle_nameapproved me, tMsg
  tParm = tMsg.connection.GetIntFrom(tMsg)
  if tParm = 0 then
    me.getComponent().checkIsNameAvailable()
  end if
end

on handle_nameunacceptable me, tMsg
  tParm = tMsg.connection.GetIntFrom(tMsg)
  if tParm = 0 then
    me.getInterface().userNameUnacceptable()
  end if
end

on handle_nametoolong me, tMsg
  me.getInterface().userNameTooLong()
end

on handle_availablesets me, tMsg
  tSets = value(tMsg.content)
  if not listp(tSets) then
    tSets = []
  end if
  if count(tSets) < 2 then
    tSets = VOID
  end if
  if objectExists("Figure_System") then
    getObject("Figure_System").setAvailableSetList(tSets)
  end if
end

on handle_memberinfo me, tMsg
  case tMsg.content.line[1].word[1] of
    "REGNAME":
      me.getInterface().userNameAlreadyReserved()
  end case
end

on handle_nosuchuser me, tMsg
  case tMsg.content.line[1].word[1] of
    "REGNAME":
      me.getInterface().userNameOk()
  end case
end

on handle_acr me, tMsg
  me.getComponent().setAgeCheckResult(tMsg.content)
end

on handle_reregistrationrequired me, tMsg
  me.getComponent().reRegistrationRequired()
end

on handle_coppa_checktime me, tMsg
  tParm = tMsg.connection.GetIntFrom(tMsg)
  if tParm then
    me.getComponent().resetBlockTime()
  else
    me.getComponent().continueBlocking()
  end if
end

on handle_coppa_getrealtime me, tMsg
  tdata = tMsg.content
  if not voidp(tdata) then
    me.getComponent().setBlockTime(tdata)
  end if
end

on handle_parent_email_requred me, tMsg
  tFlag = tMsg.connection.GetIntFrom(tMsg)
  me.getComponent().parentEmailNeedGueryResult(tFlag)
end

on handle_parent_email_validated me, tMsg
  tFlag = tMsg.connection.GetIntFrom(tMsg)
  me.getComponent().parentEmailValidated(tFlag)
end

on handle_update_account me, tMsg
  tFlag = tMsg.connection.GetIntFrom(tMsg)
  me.getInterface().responseToAccountUpdate(tFlag)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(1, #handle_ok)
  tMsgs.setaProp(3, #handle_login_ok)
  tMsgs.setaProp(8, #handle_availablesets)
  tMsgs.setaProp(36, #handle_nameapproved)
  tMsgs.setaProp(37, #handle_nameunacceptable)
  tMsgs.setaProp(51, #handle_regok)
  tMsgs.setaProp(128, #handle_memberinfo)
  tMsgs.setaProp(147, #handle_nosuchuser)
  tMsgs.setaProp(164, #handle_acr)
  tMsgs.setaProp(211, #handle_updateok)
  tMsgs.setaProp(167, #handle_reregistrationrequired)
  tMsgs.setaProp(168, #handle_nametoolong)
  tMsgs.setaProp(214, #handle_coppa_checktime)
  tMsgs.setaProp(215, #handle_coppa_getrealtime)
  tMsgs.setaProp(217, #handle_parent_email_requred)
  tMsgs.setaProp(218, #handle_parent_email_validated)
  tMsgs.setaProp(169, #handle_update_account)
  tCmds = [:]
  tCmds.setaProp("INFORETRIEVE", 7)
  tCmds.setaProp("APPROVENAME", 42)
  tCmds.setaProp("REGISTER", 43)
  tCmds.setaProp("UPDATE", 44)
  tCmds.setaProp("AC", 46)
  tCmds.setaProp("COPPA_REG_CHECKTIME", 130)
  tCmds.setaProp("COPPA_REG_GETREALTIME", 131)
  tCmds.setaProp("PARENT_EMAIL_REQUIRED", 146)
  tCmds.setaProp("VALIDATE_PARENT_EMAIL", 147)
  tCmds.setaProp("SEND_PARENT_EMAIL", 148)
  tCmds.setaProp("UPDATE_ACCOUNT", 149)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
end
