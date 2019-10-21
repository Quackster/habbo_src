on construct(me)
  if not the runMode contains "Author" then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = ""
  pCacheSize = 30
  pFatalReported = 0
  pClientErrorList = []
  pServerErrorList = []
  pErrorLevelList = [#minor, #major, #critical]
  if not variableExists("client.debug.level") then
    pErrorDialogLevel = pErrorLevelList.getAt(pErrorLevelList.count)
  else
    pErrorDialogLevel = getVariable("client.debug.level")
    if ilk(pErrorDialogLevel) <> #symbol then
      pErrorDialogLevel = pErrorLevelList.getAt(pErrorLevelList.count)
    else
      if pErrorLevelList.findPos(pErrorDialogLevel) = 0 then
        pErrorDialogLevel = pErrorLevelList.getAt(pErrorLevelList.count)
      end if
    end if
  end if
  pFatalReportParamOrder = ["error", "version", "build", "os", "host", "port", "client_version", "mus_errorcode", "error_id"]
  return(1)
  exit
end

on deconstruct(me)
  the alertHook = 0
  return(1)
  exit
end

on error(me, tObject, tMsg, tMethod, tErrorLevel)
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.getProp(#word, 2, tObject.count(#word) - 2)
    tObject = tObject.getProp(#char, 2, length(tObject) - 1)
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
  tErrorStr = the long time & "-" & tMethod & "-" & tObject & "-" & tMsg.getProp(#line, 1)
  pClientErrorList.add(tErrorStr)
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
  if me = 1 then
    put("Error:" & tError)
  else
    if me = 2 then
      put("Error:" & tError)
    else
      if me = 3 then
        executeMessage(#debugdata, "Error: " & tError)
      else
        put("Error:" & tError)
      end if
    end if
  end if
  if voidp(tErrorLevel) then
    tErrorLevel = pErrorLevelList.getAt(1)
  else
    if ilk(tErrorLevel) <> #symbol then
      tErrorLevel = pErrorLevelList.getAt(1)
    end if
  end if
  if pErrorLevelList.findPos(tErrorLevel) >= pErrorLevelList.findPos(pErrorDialogLevel) then
    tError = "Method: " && tMethod & "\r"
    tError = tError & "Object: " && tObject & "\r"
    tError = tError & "Message:" && tMsg.getProp(#line, 1) & "\r"
    executeMessage(#showErrorMessage, "client", tError)
  end if
  return(0)
  exit
end

on serverError(me, tErrorList)
  if ilk(tErrorList) = #propList then
    tErrorStr = tErrorList.getAt(#errorId) & "-" & tErrorList.getAt(#errorMsgId) & "-" & tErrorList.getAt(#time)
    pServerErrorList.add(tErrorStr)
  end if
  exit
end

on getClientErrors(me)
  tErrorStr = ""
  repeat while me <= undefined
    tError = getAt(undefined, undefined)
    tErrorStr = tErrorStr & tError & ";"
  end repeat
  tMaxLength = 1000
  tErrorStr = chars(tErrorStr, tErrorStr.length - tMaxLength, tErrorStr.length)
  return(tErrorStr)
  exit
end

on getServerErrors(me)
  tErrorStr = ""
  repeat while me <= undefined
    tError = getAt(undefined, undefined)
    tErrorStr = tErrorStr & tError & ";"
  end repeat
  tMaxLength = 1000
  tErrorStr = chars(tErrorStr, tErrorStr.length - tMaxLength, tErrorStr.length)
  return(tErrorStr)
  exit
end

on SystemAlert(me, tObject, tMsg, tMethod)
  return(me.error(tObject, tMsg, tMethod))
  exit
end

on setDebugLevel(me, tDebugLevel)
  if not integerp(tDebugLevel) then
    return(0)
  end if
  pDebugLevel = tDebugLevel
  return(1)
  exit
end

on print(me)
  put("Errors:" & "\r" & pErrorCache)
  return(1)
  exit
end

on fatalError(me, tErrorData)
  if ilk(tErrorData) <> #propList then
    tErrorData = []
  end if
  me.handleFatalError(tErrorData)
  exit
end

on alertHook(me, tErr, tMsgA, tMsgB)
  tErrorData = []
  tErrorData.setAt("error", "script_error")
  tErrorData.setAt("hookerror", tErr)
  tErrorData.setAt("hookmsga", tMsgA)
  tErrorData.setAt("hookmsgb", tMsgB)
  tErrorData.setAt("lastexecute", getBrokerManager().getLastExecutedMessageId())
  tErrorData.setAt("lastclick", getWindowManager().getLastEvent())
  tErrorData.setAt("lastclick_time", getWindowManager().getLastEventTime())
  tErrorData.setAt("eventbrokerclick", getObject(#session).GET("client_lastclick"))
  tErrorData.setAt("eventbrokerclick_time", getObject(#session).GET("client_lastclick_time"))
  tLastMessageData = getConnectionManager().getLastMessageData()
  if listp(tLastMessageData) then
    tErrorData.setAt("lastmessage", tLastMessageData.getAt(#id))
    tLastMessageData = tLastMessageData.getAt(#message) & "-" & tLastMessageData.getAt(#isParsed)
    tErrorData.setAt("server_errors", tLastMessageData)
  end if
  tSessionObj = getObject(#session)
  if objectp(tSessionObj) then
    tLastRoom = tSessionObj.GET("lastroom")
    if stringp(tLastRoom) then
      tErrorData.setAt("lastroom", tLastRoom)
    else
      if listp(tLastRoom) then
        tErrorData.setAt("lastroom", string(tLastRoom.getAt(#id)))
      end if
    end if
    me.handleFatalError(tErrorData)
  end if
  return(1)
  exit
end

on zeroPadToString(tNumber, tCount)
  tOut = ""
  if string(tNumber).length < tCount then
    i = 1
    repeat while i <= tCount - string(tNumber).length
      tOut = tOut & "0"
      i = 1 + i
    end repeat
  end if
  tOut = tOut & string(tNumber)
  return(tOut)
  exit
end

on makeErrorId(me)
  tSrc = integer(getVariable("account_id")) mod 10000
  tSrc2 = random(10000) mod 10000
  tDst = zeroPadToString(tSrc, 4) & zeroPadToString(tSrc2, 4)
  return(tDst)
  exit
end

on handleFatalError(me, tErrorData)
  tErrorUrl = ""
  tParams = ""
  if ilk(tErrorData) <> #propList then
    error(me, "Invalid error data", #handleFatalError, #major)
    tErrorData = []
  end if
  tErrorType = tErrorData.getAt("error")
  if variableExists("client.fatal.error.url") then
    tErrorUrl = getVariable("client.fatal.error.url")
  end if
  tConnection = getConnection(getVariable("connection.info.id", #info))
  if tConnection <> void() then
    tErrorData.setAt("host", tConnection.getProperty(#host))
    tErrorData.setAt("port", tConnection.getProperty(#port))
    tErrorData.setAt("mus_errorcode", tConnection.GetLastError())
  end if
  tErrorData.setAt("client_version", getMoviePath())
  tErrorData.setAt("client_process_list", string(getProcessTrackingList()))
  tErrorData.setAt("client_errors", getClientErrors() & "T=" & the long time)
  tErrorData.setAt("server_errors", getServerErrors() & "-" & tErrorData.getAt("server_errors"))
  if tErrorUrl contains "?" then
    tParams = "&"
  else
    tParams = "?"
  end if
  tEnv = the environment
  tErrorData.setAt("version", tEnv.getAt(#productVersion))
  tErrorData.setAt("build", tEnv.getAt(#productBuildVersion))
  tErrorData.setAt("os", tEnv.getAt(#osVersion))
  if getCastLoadManager() <> 0 then
    tErrorData.setAt("neterr_cast", getCastLoadManager().GetLastError())
  end if
  if getDownloadManager() <> 0 then
    tErrorData.setAt("neterr_res", getDownloadManager().GetLastError())
  end if
  tErrorData.setAt("client_uptime", getClientUpTime())
  tErrorData.setAt("error_id", makeErrorId())
  if variableExists("account_id") then
    tAccountID = getVariable("account_id")
    tAccoutnID = tAccountID mod 9999
  else
    tAccountID = 0
  end if
  tNuErrorData = []
  i = 1
  repeat while i <= pFatalReportParamOrder.count
    tKey = pFatalReportParamOrder.getAt(i)
    tValue = tErrorData.getaProp(tKey)
    if tErrorData.getaProp(tKey) <> void() then
      tNuErrorData.setaProp(tKey, tValue)
    end if
    i = 1 + i
  end repeat
  k = 1
  repeat while k <= tErrorData.count
    tKey = tErrorData.getPropAt(k)
    if tNuErrorData.getaProp(tKey) = void() then
      tNuErrorData.setaProp(tKey, tErrorData.getaProp(tKey))
    end if
    k = 1 + k
  end repeat
  tErrorData = tNuErrorData
  tItemNo = 1
  repeat while tItemNo <= tErrorData.count
    tKey = string(tErrorData.getPropAt(tItemNo))
    tKey = urlEncode(tKey)
    tValue = string(tErrorData.getAt(tKey))
    tValue = urlEncode(tValue)
    if tItemNo = 1 then
      tParams = tParams & tKey & "=" & tValue
    else
      tParams = tParams & "&" & tKey & "=" & tValue
    end if
    tItemNo = 1 + tItemNo
  end repeat
  tPrefTxt = date() && time() & "\r" & replaceChunks(tParams, "&", "\r")
  setPref("ClientFatalParams", tPrefTxt)
  me.showErrorDialog()
  pauseUpdate()
  if tErrorUrl <> "" and not pFatalReported then
    openNetPage(tErrorUrl & tParams, "self")
    pFatalReported = 1
  end if
  return(1)
  exit
end

on showErrorDialog(me)
  if createWindow(#error, "error.window", 0, 0, #modal) <> 0 then
    getWindow(#error).registerClient(me.getID())
    getWindow(#error).registerProcedure(#eventProcError, me.getID(), #mouseUp)
    return(1)
  else
    return(0)
  end if
  exit
end

on eventProcError(me, tEvent, tSprID, tParam)
  if tEvent = #mouseUp and tSprID = "error_close" then
    removeWindow(#error)
  end if
  exit
end