property pDebugLevel, pErrorCache, pCacheSize

on construct me
  if not (the runMode contains "Author") then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = EMPTY
  pCacheSize = 30
  return 1
end

on deconstruct me
  the alertHook = 0
  return 1
end

on error me, tObject, tMsg, tMethod
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.word[2..tObject.word.count - 2]
    tObject = tObject.char[2..length(tObject)]
  else
    tObject = "Unknown"
  end if
  if not stringp(tMsg) then
    tMsg = "Unknown"
  end if
  if not symbolp(tMethod) then
    tMethod = "Unknown"
  end if
  tError = RETURN
  tError = tError & TAB && "Time:   " && the long time & RETURN
  tError = tError & TAB && "Method: " && tMethod & RETURN
  tError = tError & TAB && "Object: " && tObject & RETURN
  tError = tError & TAB && "Message:" && tMsg.line[1] & RETURN
  if tMsg.line.count > 1 then
    repeat with i = 2 to tMsg.line.count
      tError = tError & TAB && "        " && tMsg.line[i] & RETURN
    end repeat
  end if
  pErrorCache = pErrorCache & tError
  if pErrorCache.line.count > pCacheSize then
    pErrorCache = pErrorCache.line[pErrorCache.line.count - pCacheSize..pErrorCache.line.count]
  end if
  case pDebugLevel of
    1:
      put "Error:" & tError
    2:
      put "Error:" & tError
    otherwise:
      put "Error:" & tError
  end case
  return 0
end

on SystemAlert me, tObject, tMsg, tMethod
  me.error(tObject, tMsg, tMethod)
  me.SendMailAlert(tObject, tMsg, tMethod)
  return 0
end

on SendMailAlert me, tErr, tMsgA, tMsgB
  if the runMode = "Author" then
    return 0
  end if
  if getVariable("server.mail.address") = EMPTY then
    return 0
  end if
  if connectionExists(getVariableValue("server.mail.connection")) then
    tEndTime = the long time
    tEnvironment = EMPTY
    repeat with i = 1 to (the environment).count
      tEnvironment = tEnvironment & TAB & (the environment).getPropAt(i) & ":" && (the environment)[i] & RETURN
    end repeat
    tEnvironment = tEnvironment & TAB & "Memory:" && the memorysize / 1024 / 1024 & RETURN & RETURN
    if objectExists(#session) then
      tClientVer = getObject(#session).get("client_version")
      tStartDate = getObject(#session).get("client_startdate")
      tStartTime = getObject(#session).get("client_starttime")
      tLastClick = getObject(#session).get("client_lastclick")
      tSession = EMPTY
      tVarList = getObject(#session).pItemList
      repeat with j = 1 to tVarList.count
        if not (string(tVarList.getPropAt(j)) contains "password") then
          tSession = tSession & TAB & tVarList.getPropAt(j) & ":" && tVarList[j] & RETURN
        end if
      end repeat
      if getObject(#session).exists("mailed_error") then
        return 0
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
    tCastlibs = RETURN
    tCastList = getCastLoadManager().pLoadedCasts
    repeat with i = 1 to tCastList.count
      tCastlibs = tCastlibs & tCastList[i] && tCastList.getPropAt(i) & RETURN
    end repeat
    tErrMsg = tErrMsg & TAB & "Error:" && tErr & RETURN
    tErrMsg = tErrMsg & TAB & "Message:" && tMsgA & "," && tMsgB & RETURN
    tErrMsg = tErrMsg & TAB & "Date:" && tStartDate & RETURN
    tErrMsg = tErrMsg & TAB & "Client:" && tClientVer & RETURN
    tErrMsg = tErrMsg & TAB & "Start time:" && tStartTime & RETURN
    tErrMsg = tErrMsg & TAB & "End time:" && tEndTime & RETURN
    tErrMsg = tErrMsg & TAB & "Last click:" && tLastClick & RETURN
    tErrMsg = tErrMsg & TAB & "Free sprs:" && tSprCount & RETURN
    tMailMsg = getVariable("author.mail.address") & RETURN & getVariable("server.mail.address") & RETURN
    tMailMsg = tMailMsg & "Error Manager Alert" & RETURN & RETURN
    tMailMsg = tMailMsg & "Info:" & RETURN & RETURN & tErrMsg & RETURN & RETURN
    tMailMsg = tMailMsg & "Session:" & RETURN & RETURN & tSession & RETURN & RETURN
    tMailMsg = tMailMsg & "CastLibs:" & RETURN & RETURN & tCastlibs & RETURN & RETURN
    tMailMsg = tMailMsg & "Environment:" & RETURN & RETURN & tEnvironment & RETURN & RETURN
    tMailMsg = tMailMsg & "Error cache:" & RETURN & RETURN & getErrorManager().pErrorCache & RETURN
    getConnection(getVariableValue("server.mail.connection")).send("SENDEMAIL" & RETURN & tMailMsg)
  end if
  return 0
end

on sendErrorReport me, tErr, tMsgA, tMsgB
  if not objectExists(#session) then
    return 0
  end if
  if getObject(#session).exists("sended_error_report") then
    return 0
  else
    getObject(#session).set("sended_error_report", 1)
  end if
  tCastlibs = EMPTY
  tCastList = getCastLoadManager().pLoadedCasts
  repeat with i = 1 to tCastList.count
    tCastlibs = tCastlibs & tCastList[i] && tCastList.getPropAt(i) & RETURN
  end repeat
  tEndTime = the long time
  tStartDate = getObject(#session).get("client_startdate")
  tStartTime = getObject(#session).get("client_starttime")
  tVarList = getObject(#session).pItemList.duplicate()
  if tVarList["con_lastreceived"].ilk = #void then
    tVarList["con_lastreceived"] = "Not defined"
  end if
  if tVarList["con_lastsend"].ilk = #void then
    tVarList["con_lastsend"] = "Not defined"
  end if
  if tVarList["lastroom"].ilk <> #propList then
    tVarList["lastroom"] = [#name: "Not defined", #marker: "Not defined"]
  end if
  if tVarList["moderator"].ilk = #void then
    tVarList["moderator"] = "Not defined"
  end if
  if tVarList["room_controller"].ilk = #void then
    tVarList["room_controller"] = "Not defined"
  end if
  if tVarList["room_owner"].ilk = #void then
    tVarList["room_owner"] = "Not defined"
  end if
  if tVarList["user_has_special_rights"].ilk = #void then
    tVarList["user_has_special_rights"] = "Not defined"
  end if
  if tVarList["user_access_count"].ilk = #void then
    tVarList["user_access_count"] = "Not defined"
  end if
  if tVarList["user_sex"].ilk = #void then
    tVarList["user_sex"] = "Not defined"
  end if
  if tVarList["user_walletbalance"].ilk = #void then
    tVarList["user_walletbalance"] = "Not defined"
  end if
  if tVarList["user_name"].ilk = #void then
    tVarList["user_name"] = "Not defined"
  end if
  if tVarList["user_walletbalance"].ilk = #void then
    tVarList["user_walletbalance"] = "Not defined"
  end if
  tErrProps = [:]
  tErrProps["ie"] = tErr
  tErrProps["im"] = tMsgA & "," && tMsgB
  tErrProps["ic"] = getObject(#session).get("client_version")
  tErrProps["ist"] = getObject(#session).get("client_starttime")
  tErrProps["iet"] = tEndTime
  tErrProps["il"] = getObject(#session).get("client_lastclick")
  tErrProps["is"] = getSpriteManager().getProperty(#freeSprCount) && "/" && getSpriteManager().getProperty(#totalSprCount)
  tErrProps["slr"] = tVarList["con_lastreceived"]
  tErrProps["sls"] = tVarList["con_lastsend"]
  tErrProps["slrm"] = tVarList["lastroom"][#name] & "," && tVarList["lastroom"][#marker]
  tErrProps["sud1"] = tVarList["moderator"] & "," && tVarList["room_controller"] & "," && tVarList["room_owner"] & "," && tVarList["user_has_special_rights"]
  tErrProps["sud2"] = tVarList["user_access_count"] & "," && tVarList["user_sex"] & "," && tVarList["user_walletbalance"]
  tErrProps["sun"] = tVarList["user_name"]
  tErrProps["ep"] = (the environment)[#platform]
  tErrProps["ec"] = (the environment)[#colorDepth]
  tErrProps["el"] = (the environment)[#uiLanguage] & "," && (the environment)[#osLanguage]
  tErrProps["ee"] = (the environment)[#productBuildVersion]
  tErrProps["em"] = the memorysize / 1024 / 1024
  tErrProps["cl"] = tCastlibs
  tErrProps["rt"] = getThreadManager().getaProp(#pThreadList)
  tErrProps["err"] = pErrorCache
  tCheckSum1 = value(tStartTime.char[1..2] & tStartTime.char[4..5] & tStartTime.char[7..8])
  tCheckSum2 = value(tEndTime.char[1..2] & tEndTime.char[4..5] & tEndTime.char[7..8])
  tErrProps["cs"] = (tCheckSum1 + tCheckSum2) / (value(tEndTime.char[8]) + 1)
  put tErrProps
  return 0
end

on setDebugLevel me, tDebugLevel
  if not integerp(tDebugLevel) then
    return 0
  end if
  pDebugLevel = tDebugLevel
  if float((the productVersion).char[1..3]) >= 8.5 then
    if pDebugLevel > 0 then
      the debugPlaybackEnabled = 1
    end if
  end if
  return 1
end

on setErrorEmailAddress me, tMailAddress
  if not stringp(tMailAddress) then
    return 0
  end if
  if not (tMailAddress contains "@") then
    return 0
  end if
  pAuthorAddress = tMailAddress
  return 1
end

on print me
  put "Errors:" & RETURN & pErrorCache
  return 1
end

on alertHook me, tErr, tMsgA, tMsgB
  me.SendMailAlert(tErr, tMsgA, tMsgB)
  me.sendErrorReport(tErr, tMsgA, tMsgB)
  me.showErrorDialog()
  pauseUpdate()
  return 1
end

on showErrorDialog me
  createWindow(#error, "error.window", 0, 0, #modal)
  registerClient(#error, me.getID())
  registerProcedure(#error, #eventProcError, me.getID(), #mouseUp)
  return 1
end

on eventProcError me, tEvent, tSprID, tParam
  if (tEvent = #mouseUp) and (tSprID = "error_close") then
    resetClient()
  end if
end
