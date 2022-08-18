property pDebugLevel, pErrorCache, pCacheSize, pErrorDialogLevel, pErrorLevelList, pFatalReported, pFatalReportParamOrder, pClientErrorList, pServerErrorList

on construct me
  if not (the runMode contains "Author") then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = EMPTY
  pCacheSize = 30
  pFatalReported = 0
  pClientErrorList = []
  pServerErrorList = []
  pErrorLevelList = [#minor, #major, #critical]
  if not variableExists("client.debug.level") then
    pErrorDialogLevel = pErrorLevelList[pErrorLevelList.count]
  else
    pErrorDialogLevel = getVariable("client.debug.level")
    if (ilk(pErrorDialogLevel) <> #symbol) then
      pErrorDialogLevel = pErrorLevelList[pErrorLevelList.count]
    else
      if (pErrorLevelList.findPos(pErrorDialogLevel) = 0) then
        pErrorDialogLevel = pErrorLevelList[pErrorLevelList.count]
      end if
    end if
  end if
  pFatalReportParamOrder = ["error", "version", "build", "os", "host", "port", "client_version", "mus_errorcode", "error_id"]
  return 1
end

on deconstruct me
  the alertHook = 0
  return 1
end

on error me, tObject, tMsg, tMethod, tErrorLevel
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.word[2]
    tObject = tObject.char[2]
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
  tError = ((((tError & TAB) && "Time:   ") && the long time) & RETURN)
  tError = ((((tError & TAB) && "Method: ") && tMethod) & RETURN)
  tError = ((((tError & TAB) && "Object: ") && tObject) & RETURN)
  tError = ((((tError & TAB) && "Message:") && tMsg.line[1]) & RETURN)
  tErrorStr = ((((((the long time & "-") & tMethod) & "-") & tObject) & "-") & tMsg.line[1])
  pClientErrorList.add(tErrorStr)
  if (tMsg.line.count > 1) then
    repeat with i = 2 to tMsg.line.count
      tError = ((((tError & TAB) && "        ") && tMsg.line[i]) & RETURN)
    end repeat
  end if
  pErrorCache = (pErrorCache & tError)
  if (pErrorCache.line.count > pCacheSize) then
    pErrorCache = pErrorCache.line[(pErrorCache.line.count - pCacheSize)]
  end if
  case pDebugLevel of
    1:
      put ("Error:" & tError)
    2:
      put ("Error:" & tError)
    3:
      executeMessage(#debugdata, ("Error: " & tError))
    otherwise:
      put ("Error:" & tError)
  end case
  if voidp(tErrorLevel) then
    tErrorLevel = pErrorLevelList[1]
  else
    if (ilk(tErrorLevel) <> #symbol) then
      tErrorLevel = pErrorLevelList[1]
    end if
  end if
  if (pErrorLevelList.findPos(tErrorLevel) >= pErrorLevelList.findPos(pErrorDialogLevel)) then
    tError = (("Method: " && tMethod) & RETURN)
    tError = (((tError & "Object: ") && tObject) & RETURN)
    tError = (((tError & "Message:") && tMsg.line[1]) & RETURN)
    executeMessage(#showErrorMessage, "client", tError)
  end if
  return 0
end

on serverError me, tErrorList
  if (ilk(tErrorList) = #propList) then
    tErrorStr = ((((tErrorList[#errorId] & "-") & tErrorList[#errorMsgId]) & "-") & tErrorList[#time])
    pServerErrorList.add(tErrorStr)
  end if
end

on getClientErrors me
  tErrorStr = EMPTY
  repeat with tError in pClientErrorList
    tErrorStr = ((tErrorStr & tError) & ";")
  end repeat
  tMaxLength = 1000
  tErrorStr = chars(tErrorStr, (tErrorStr.length - tMaxLength), tErrorStr.length)
  return tErrorStr
end

on getServerErrors me
  tErrorStr = EMPTY
  repeat with tError in pServerErrorList
    tErrorStr = ((tErrorStr & tError) & ";")
  end repeat
  tMaxLength = 1000
  tErrorStr = chars(tErrorStr, (tErrorStr.length - tMaxLength), tErrorStr.length)
  return tErrorStr
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
  put (("Errors:" & RETURN) & pErrorCache)
  return 1
end

on fatalError me, tErrorData
  if (ilk(tErrorData) <> #propList) then
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

on zeroPadToString tNumber, tCount
  tOut = EMPTY
  if (string(tNumber).length < tCount) then
    repeat with i = 1 to (tCount - string(tNumber).length)
      tOut = (tOut & "0")
    end repeat
  end if
  tOut = (tOut & string(tNumber))
  return tOut
end

on makeErrorId me
  tSrc = (integer(getObject(#session).GET("user_user_id")) mod 10000)
  tSrc2 = (random(10000) mod 10000)
  tDst = (zeroPadToString(tSrc, 4) & zeroPadToString(tSrc2, 4))
  return tDst
end

on handleFatalError me, tErrorData
  tErrorUrl = EMPTY
  tParams = EMPTY
  if (ilk(tErrorData) <> #propList) then
    error(me, "Invalid error data", #handleFatalError, #major)
    tErrorData = [:]
  end if
  tErrorType = tErrorData["error"]
  if variableExists("client.fatal.error.url") then
    tErrorUrl = getVariable("client.fatal.error.url")
  end if
  tConnection = getConnection(getVariable("connection.info.id", #Info))
  if (tConnection <> VOID) then
    tErrorData["host"] = tConnection.getProperty(#host)
    tErrorData["port"] = tConnection.getProperty(#port)
    tErrorData["mus_errorcode"] = tConnection.GetLastError()
  end if
  tErrorData["client_version"] = getMoviePath()
  tErrorData["client_process_list"] = string(getProcessTrackingList())
  tErrorData["client_errors"] = getClientErrors()
  tErrorData["server_errors"] = getServerErrors()
  if (tErrorUrl contains "?") then
    tParams = "&"
  else
    tParams = "?"
  end if
  tEnv = the environment
  tErrorData["version"] = tEnv[#productVersion]
  tErrorData["build"] = tEnv[#productBuildVersion]
  tErrorData["os"] = tEnv[#osVersion]
  tErrorData["neterr_cast"] = getCastLoadManager().GetLastError()
  tErrorData["neterr_res"] = getDownloadManager().GetLastError()
  tErrorData["client_uptime"] = getClientUpTime()
  tErrorData["error_id"] = makeErrorId()
  if variableExists("account_id") then
    tAccountID = getVariable("account_id")
    tAccoutnID = (tAccountID mod 9999)
  else
    tAccountID = 0
  end if
  tNuErrorData = [:]
  repeat with i = 1 to pFatalReportParamOrder.count
    tKey = pFatalReportParamOrder[i]
    tValue = tErrorData.getaProp(tKey)
    if (tErrorData.getaProp(tKey) <> VOID) then
      tNuErrorData.setaProp(tKey, tValue)
    end if
  end repeat
  repeat with k = 1 to tErrorData.count
    tKey = tErrorData.getPropAt(k)
    if (tNuErrorData.getaProp(tKey) = VOID) then
      tNuErrorData.setaProp(tKey, tErrorData.getaProp(tKey))
    end if
  end repeat
  tErrorData = tNuErrorData
  repeat with tItemNo = 1 to tErrorData.count
    tKey = string(tErrorData.getPropAt(tItemNo))
    tKey = urlEncode(tKey)
    tValue = string(tErrorData[tKey])
    tValue = urlEncode(tValue)
    if (tItemNo = 1) then
      tParams = (((tParams & tKey) & "=") & tValue)
      next repeat
    end if
    tParams = ((((tParams & "&") & tKey) & "=") & tValue)
  end repeat
  tPrefTxt = (((date() && time()) & RETURN) & replaceChunks(tParams, "&", RETURN))
  setPref("ClientFatalParams", tPrefTxt)
  me.showErrorDialog()
  pauseUpdate()
  if ((tErrorUrl <> EMPTY) and not pFatalReported) then
    openNetPage((tErrorUrl & tParams), "self")
    pFatalReported = 1
  end if
  return 1
end

on showErrorDialog me
  if (createWindow(#error, "error.window", 0, 0, #modal) <> 0) then
    getWindow(#error).registerClient(me.getID())
    getWindow(#error).registerProcedure(#eventProcError, me.getID(), #mouseUp)
    return 1
  else
    return 0
  end if
end

on eventProcError me, tEvent, tSprID, tParam
  if ((tEvent = #mouseUp) and (tSprID = "error_close")) then
    removeWindow(#error)
  end if
end
