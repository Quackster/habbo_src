property pErrorCache, pCacheSize, pDebugLevel

on construct me 
  if not the runMode contains "Author" then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = ""
  pCacheSize = 30
  return(1)
end

on deconstruct me 
  the alertHook = 0
  return(1)
end

on error me, tObject, tMsg, tMethod 
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.getProp(#word, 2, tObject.count(#word) - 2)
    tObject = tObject.getProp(#char, 2, length(tObject))
  else
    tObject = "Unknown"
  end if
  if not stringp(tMsg) then
    tMsg = "Unknown"
  end if
  if not symbolp(tMethod) then
    tMethod = "Unknown"
  end if
  tError = "\r"
  tError = tError & "\t" && "Time:   " && the long time & "\r"
  tError = tError & "\t" && "Method: " && tMethod & "\r"
  tError = tError & "\t" && "Object: " && tObject & "\r"
  tError = tError & "\t" && "Message:" && tMsg.getProp(#line, 1) & "\r"
  if tMsg.count(#line) > 1 then
    i = 2
    repeat while i <= tMsg.count(#line)
      tError = tError & "\t" && "        " && tMsg.getProp(#line, i) & "\r"
      i = 1 + i
    end repeat
  end if
  pErrorCache = pErrorCache & tError
  if pErrorCache.count(#line) > pCacheSize then
    pErrorCache = pErrorCache.getProp(#line, pErrorCache.count(#line) - pCacheSize, pErrorCache.count(#line))
  end if
  if pDebugLevel = 1 then
    put("Error:" & tError)
  else
    if pDebugLevel = 2 then
      put("Error:" & tError)
    else
      put("Error:" & tError)
    end if
  end if
  return(0)
end

on SystemAlert me, tObject, tMsg, tMethod 
  me.error(tObject, tMsg, tMethod)
  me.SendMailAlert(tObject, tMsg, tMethod)
  return(0)
end

on SendMailAlert me, tErr, tMsgA, tMsgB 
  if the runMode = "Author" then
    return(0)
  end if
  if getVariable("server.mail.address") = "" then
    return(0)
  end if
  if connectionExists(getVariableValue("server.mail.connection")) then
    tEndTime = the long time
    tEnvironment = ""
    i = 1
    repeat while i <= the environment.count
      tEnvironment = tEnvironment & "\t" & the environment.getPropAt(i) & ":" && the environment.getAt(i) & "\r"
      i = 1 + i
    end repeat
    tEnvironment = tEnvironment & "\t" & "Memory:" && ((the memorysize / 1024) / 1024) & "\r" & "\r"
    if objectExists(#session) then
      tClientVer = getObject(#session).get("client_version")
      tStartDate = getObject(#session).get("client_startdate")
      tStartTime = getObject(#session).get("client_starttime")
      tLastClick = getObject(#session).get("client_lastclick")
      tSession = ""
      tVarList = getObject(#session).pItemList
      j = 1
      repeat while j <= tVarList.count
        if not string(tVarList.getPropAt(j)) contains "password" then
          tSession = tSession & "\t" & tVarList.getPropAt(j) & ":" && tVarList.getAt(j) & "\r"
        end if
        j = 1 + j
      end repeat
      if getObject(#session).exists("mailed_error") then
        return(0)
      else
        getObject(#session).set("mailed_error", 1)
      end if
    else
      tSession = "Not defined"
      tClientVer = "Not defined"
      tStartTime = "Not defined"
      tStartDate = "Not defined"
      tLastClick = "not defined"
    end if
    tSprCount = getSpriteManager().getProperty(#freeSprCount) && "/" && getSpriteManager().getProperty(#totalSprCount)
    tCastlibs = "\r"
    tCastList = getCastLoadManager().pLoadedCasts
    i = 1
    repeat while i <= tCastList.count
      tCastlibs = tCastlibs & tCastList.getAt(i) && tCastList.getPropAt(i) & "\r"
      i = 1 + i
    end repeat
    tErrMsg = tErrMsg & "\t" & "Error:" && tErr & "\r"
    tErrMsg = tErrMsg & "\t" & "Message:" && tMsgA & "," && tMsgB & "\r"
    tErrMsg = tErrMsg & "\t" & "Date:" && tStartDate & "\r"
    tErrMsg = tErrMsg & "\t" & "Client:" && tClientVer & "\r"
    tErrMsg = tErrMsg & "\t" & "Start time:" && tStartTime & "\r"
    tErrMsg = tErrMsg & "\t" & "End time:" && tEndTime & "\r"
    tErrMsg = tErrMsg & "\t" & "Last click:" && tLastClick & "\r"
    tErrMsg = tErrMsg & "\t" & "Free sprs:" && tSprCount & "\r"
    tMailMsg = getVariable("author.mail.address") & "\r" & getVariable("server.mail.address") & "\r"
    tMailMsg = tMailMsg & "Error Manager Alert" & "\r" & "\r"
    tMailMsg = tMailMsg & "Info:" & "\r" & "\r" & tErrMsg & "\r" & "\r"
    tMailMsg = tMailMsg & "Session:" & "\r" & "\r" & tSession & "\r" & "\r"
    tMailMsg = tMailMsg & "CastLibs:" & "\r" & "\r" & tCastlibs & "\r" & "\r"
    tMailMsg = tMailMsg & "Environment:" & "\r" & "\r" & tEnvironment & "\r" & "\r"
    tMailMsg = tMailMsg & "Error cache:" & "\r" & "\r" & getErrorManager().pErrorCache & "\r"
    getConnection(getVariableValue("server.mail.connection")).send("SENDEMAIL" & "\r" & tMailMsg)
  end if
  return(0)
end

on sendErrorReport me, tErr, tMsgA, tMsgB 
  if not objectExists(#session) then
    return(0)
  end if
  if getObject(#session).exists("sended_error_report") then
    return(0)
  else
    getObject(#session).set("sended_error_report", 1)
  end if
  tCastlibs = ""
  tCastList = getCastLoadManager().pLoadedCasts
  i = 1
  repeat while i <= tCastList.count
    tCastlibs = tCastlibs & tCastList.getAt(i) && tCastList.getPropAt(i) & "\r"
    i = 1 + i
  end repeat
  tEndTime = the long time
  tStartDate = getObject(#session).get("client_startdate")
  tStartTime = getObject(#session).get("client_starttime")
  tVarList = undefined.duplicate()
  if tVarList.getAt("con_lastreceived").ilk = #void then
    tVarList.setAt("con_lastreceived", "Not defined")
  end if
  if tVarList.getAt("con_lastsend").ilk = #void then
    tVarList.setAt("con_lastsend", "Not defined")
  end if
  if tVarList.getAt("lastroom").ilk <> #propList then
    tVarList.setAt("lastroom", [#name:"Not defined", #marker:"Not defined"])
  end if
  if tVarList.getAt("moderator").ilk = #void then
    tVarList.setAt("moderator", "Not defined")
  end if
  if tVarList.getAt("room_controller").ilk = #void then
    tVarList.setAt("room_controller", "Not defined")
  end if
  if tVarList.getAt("room_owner").ilk = #void then
    tVarList.setAt("room_owner", "Not defined")
  end if
  if tVarList.getAt("user_has_special_rights").ilk = #void then
    tVarList.setAt("user_has_special_rights", "Not defined")
  end if
  if tVarList.getAt("user_access_count").ilk = #void then
    tVarList.setAt("user_access_count", "Not defined")
  end if
  if tVarList.getAt("user_sex").ilk = #void then
    tVarList.setAt("user_sex", "Not defined")
  end if
  if tVarList.getAt("user_walletbalance").ilk = #void then
    tVarList.setAt("user_walletbalance", "Not defined")
  end if
  if tVarList.getAt("user_name").ilk = #void then
    tVarList.setAt("user_name", "Not defined")
  end if
  if tVarList.getAt("user_walletbalance").ilk = #void then
    tVarList.setAt("user_walletbalance", "Not defined")
  end if
  tErrProps = [:]
  tErrProps.setAt("ie", tErr)
  tErrProps.setAt("im", tMsgA & "," && tMsgB)
  tErrProps.setAt("ic", getObject(#session).get("client_version"))
  tErrProps.setAt("ist", getObject(#session).get("client_starttime"))
  tErrProps.setAt("iet", tEndTime)
  tErrProps.setAt("il", getObject(#session).get("client_lastclick"))
  tErrProps.setAt("is", getSpriteManager().getProperty(#freeSprCount) && "/" && getSpriteManager().getProperty(#totalSprCount))
  tErrProps.setAt("slr", tVarList.getAt("con_lastreceived"))
  tErrProps.setAt("sls", tVarList.getAt("con_lastsend"))
  tErrProps.setAt("slrm", tVarList.getAt("lastroom").getAt(#name) & "," && tVarList.getAt("lastroom").getAt(#marker))
  tErrProps.setAt("sud1", tVarList.getAt("moderator") & "," && tVarList.getAt("room_controller") & "," && tVarList.getAt("room_owner") & "," && tVarList.getAt("user_has_special_rights"))
  tErrProps.setAt("sud2", tVarList.getAt("user_access_count") & "," && tVarList.getAt("user_sex") & "," && tVarList.getAt("user_walletbalance"))
  tErrProps.setAt("sun", tVarList.getAt("user_name"))
  tErrProps.setAt("ep", the environment.getAt(#platform))
  tErrProps.setAt("ec", the environment.getAt(#colorDepth))
  tErrProps.setAt("el", the environment.getAt(#uiLanguage) & "," && the environment.getAt(#osLanguage))
  tErrProps.setAt("ee", the environment.getAt(#productBuildVersion))
  tErrProps.setAt("em", ((the memorysize / 1024) / 1024))
  tErrProps.setAt("cl", tCastlibs)
  tErrProps.setAt("rt", getThreadManager().getaProp(#pThreadList))
  tErrProps.setAt("err", pErrorCache)
  tCheckSum1 = value(tStartTime.getProp(#char, 1, 2) & tStartTime.getProp(#char, 4, 5) & tStartTime.getProp(#char, 7, 8))
  tCheckSum2 = value(tEndTime.getProp(#char, 1, 2) & tEndTime.getProp(#char, 4, 5) & tEndTime.getProp(#char, 7, 8))
  tErrProps.setAt("cs", (tCheckSum1 + tCheckSum2 / value(tEndTime.getProp(#char, 8)) + 1))
  put(tErrProps)
  return(0)
end

on setDebugLevel me, tDebugLevel 
  if not integerp(tDebugLevel) then
    return(0)
  end if
  pDebugLevel = tDebugLevel
  if float(the productVersion.getProp(#char, 1, 3)) >= 8.5 then
    if pDebugLevel > 0 then
      the debugPlaybackEnabled = 1
    end if
  end if
  return(1)
end

on setErrorEmailAddress me, tMailAddress 
  if not stringp(tMailAddress) then
    return(0)
  end if
  if not tMailAddress contains "@" then
    return(0)
  end if
  pAuthorAddress = tMailAddress
  return(1)
end

on print me 
  put("Errors:" & "\r" & pErrorCache)
  return(1)
end

on alertHook me, tErr, tMsgA, tMsgB 
  me.SendMailAlert(tErr, tMsgA, tMsgB)
  me.sendErrorReport(tErr, tMsgA, tMsgB)
  me.showErrorDialog()
  pauseUpdate()
  return(1)
end

on showErrorDialog me 
  createWindow(#error, "error.window", 0, 0, #modal)
  registerClient(#error, me.getID())
  registerProcedure(#error, #eventProcError, me.getID(), #mouseUp)
  return(1)
end

on eventProcError me, tEvent, tSprID, tParam 
  if tEvent = #mouseUp and tSprID = "error_close" then
    resetClient()
  end if
end
