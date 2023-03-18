property pDebugLevel, pErrorCache, pCacheSize, pErrorDialogLevel, pErrorLevelList, pFatalReported

on construct me
  if not (the runMode contains "Author") then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = EMPTY
  pCacheSize = 30
  pFatalReported = 0
  pErrorLevelList = [#minor, #major, #critical]
  pErrorDialogLevel = getVariable("client.debug.level")
  if ilk(pErrorDialogLevel) <> #symbol then
    pErrorDialogLevel = pErrorLevelList[pErrorLevelList.count]
  else
    if pErrorLevelList.findPos(pErrorDialogLevel) = 0 then
      pErrorDialogLevel = pErrorLevelList[pErrorLevelList.count]
    end if
  end if
  return 1
end

on deconstruct me
  the alertHook = 0
  return 1
end

on error me, tObject, tMsg, tMethod, tErrorLevel
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.word[2..tObject.word.count - 2]
    tObject = tObject.char[2..length(tObject) - 1]
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
    3:
      executeMessage(#debugdata, "Error: " & tError)
    otherwise:
      put "Error:" & tError
  end case
  if voidp(tErrorLevel) then
    tErrorLevel = pErrorLevelList[1]
  else
    if ilk(tErrorLevel) <> #symbol then
      tErrorLevel = pErrorLevelList[1]
    end if
  end if
  if pErrorLevelList.findPos(tErrorLevel) >= pErrorLevelList.findPos(pErrorDialogLevel) then
    tError = "Method: " && tMethod & RETURN
    tError = tError & "Object: " && tObject & RETURN
    tError = tError & "Message:" && tMsg.line[1] & RETURN
    executeMessage(#showErrorMessage, "client", tError)
  end if
  return 0
end

on SystemAlert me, tObject, tMsg, tMethod
  return me.error(tObject, tMsg, tMethod)
end

on setDebugLevel me, tDebugLevel
  if not integerp(tDebugLevel) then
    return 0
  end if
  pDebugLevel = tDebugLevel
  return 1
end

on print me
  put "Errors:" & RETURN & pErrorCache
  return 1
end

on fatalError me, tErrorData
  if ilk(tErrorData) <> #propList then
    error(me, "Invalid error parameters for fatal error!", #fatalError, #critical)
    tErrorData = [:]
  end if
  me.handleFatalError(tErrorData)
end

on alertHook me, tErr, tMsgA, tMsgB
  tErrorData = [:]
  tErrorData["error"] = "script_error"
  tErrorData["hookerror"] = tErr
  tErrorData["hookmsga"] = tMsgA
  tErrorData["hookmsgb"] = tMsgB
  tErrorData["lastexecute"] = getBrokerManager().getLastExecutedMessageId()
  tErrorData["lastclick"] = getWindowManager().getLastEvent()
  tErrorData["lastmessage"] = getConnectionManager().getLastMessageData()
  tSessionObj = getObject(#session)
  if objectp(tSessionObj) then
    tLastRoom = tSessionObj.GET("lastroom")
    if stringp(tLastRoom) then
      tErrorData["lastroom"] = tLastRoom
    else
      if listp(tLastRoom) then
        tErrorData["lastroom"] = string(tLastRoom[#id])
      end if
    end if
    me.handleFatalError(tErrorData)
  end if
  return 1
end

on handleFatalError me, tErrorData
  tErrorUrl = EMPTY
  tParams = EMPTY
  if ilk(tErrorData) <> #propList then
    return error(me, "Invalid error data", #handleFatalError, #critical)
  end if
  tErrorType = tErrorData["error"]
  case tErrorType of
    "socket_init":
      if variableExists("client.connection.failed.url") then
        tErrorUrl = getVariable("client.connection.failed.url")
      end if
    otherwise:
      if variableExists("client.fatal.error.url") then
        tErrorUrl = getVariable("client.fatal.error.url")
      end if
  end case
  if tErrorUrl contains "?" then
    tParams = "&"
  else
    tParams = "?"
  end if
  tEnv = the environment
  tErrorData["version"] = tEnv[#productVersion]
  tErrorData["build"] = tEnv[#productBuildVersion]
  tErrorData["os"] = tEnv[#osVersion]
  repeat with tItemNo = 1 to tErrorData.count
    tKey = string(tErrorData.getPropAt(tItemNo))
    tKey = urlEncode(tKey)
    tValue = string(tErrorData[tKey])
    tValue = urlEncode(tValue)
    if tItemNo = 1 then
      tParams = tParams & tKey & "=" & tValue
      next repeat
    end if
    tParams = tParams & "&" & tKey & "=" & tValue
  end repeat
  tPrefTxt = date() && time() & RETURN & replaceChunks(tParams, "&", RETURN)
  setPref("ClientFatalParams", tPrefTxt)
  me.showErrorDialog()
  pauseUpdate()
  if (tErrorUrl <> EMPTY) and not pFatalReported then
    openNetPage(tErrorUrl & tParams, "self")
    pFatalReported = 1
  end if
  return 1
end

on showErrorDialog me
  if createWindow(#error, "error.window", 0, 0, #modal) <> 0 then
    getWindow(#error).registerClient(me.getID())
    getWindow(#error).registerProcedure(#eventProcError, me.getID(), #mouseUp)
    return 1
  else
    return 0
  end if
end

on eventProcError me, tEvent, tSprID, tParam
  if (tEvent = #mouseUp) and (tSprID = "error_close") then
    resetClient()
  end if
end
