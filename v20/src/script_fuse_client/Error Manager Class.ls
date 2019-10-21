property pErrorDialogLevel, pErrorLevelList, pErrorCache, pCacheSize, pDebugLevel

on construct me 
  if not the runMode contains "Author" then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = ""
  pCacheSize = 30
  pErrorLevelList = [#minor, #major, #critical]
  pErrorDialogLevel = getVariable("client.debug.level")
  if ilk(pErrorDialogLevel) <> #symbol then
    pErrorDialogLevel = pErrorLevelList.getAt(pErrorLevelList.count)
  else
    if (pErrorLevelList.findPos(pErrorDialogLevel) = 0) then
      pErrorDialogLevel = pErrorLevelList.getAt(pErrorLevelList.count)
    end if
  end if
  return TRUE
end

on deconstruct me 
  the alertHook = 0
  return TRUE
end

on error me, tObject, tMsg, tMethod, tErrorLevel 
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.getProp(#word, 2, (tObject.count(#word) - 2))
    tObject = tObject.getProp(#char, 2, (length(tObject) - 1))
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
      i = (1 + i)
    end repeat
  end if
  pErrorCache = pErrorCache & tError
  if pErrorCache.count(#line) > pCacheSize then
    pErrorCache = pErrorCache.getProp(#line, (pErrorCache.count(#line) - pCacheSize), pErrorCache.count(#line))
  end if
  if (pDebugLevel = 1) then
    put("Error:" & tError)
  else
    if (pDebugLevel = 2) then
      put("Error:" & tError)
    else
      if (pDebugLevel = 3) then
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
  return FALSE
end

on SystemAlert me, tObject, tMsg, tMethod 
  return(me.error(tObject, tMsg, tMethod))
end

on setDebugLevel me, tDebugLevel 
  if not integerp(tDebugLevel) then
    return FALSE
  end if
  pDebugLevel = tDebugLevel
  return TRUE
end

on print me 
  put("Errors:" & "\r" & pErrorCache)
  return TRUE
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
  tErrorData.setAt("error", "script_error")
  tErrorData.setAt("hookerror", tErr)
  tErrorData.setAt("hookmsga", tMsgA)
  tErrorData.setAt("hookmsgb", tMsgB)
  tErrorData.setAt("lastexecute", getBrokerManager().getLastExecutedMessageId())
  tErrorData.setAt("lastclick", getWindowManager().getLastEvent())
  tErrorData.setAt("lastmessage", getConnectionManager().getLastMessageData())
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
  return TRUE
end

on handleFatalError me, tErrorData 
  tErrorUrl = ""
  tParams = ""
  if ilk(tErrorData) <> #propList then
    return(error(me, "Invalid error data", #handleFatalError, #critical))
  end if
  tErrorType = tErrorData.getAt("error")
  if (tErrorType = "socket_init") then
    if variableExists("client.connection.failed.url") then
      tErrorUrl = getVariable("client.connection.failed.url")
    end if
  else
    if variableExists("client.fatal.error.url") then
      tErrorUrl = getVariable("client.fatal.error.url")
    end if
  end if
  if tErrorUrl contains "?" then
    tParams = "&"
  else
    tParams = "?"
  end if
  tEnv = the environment
  tErrorData.setAt("version", tEnv.getAt(#productVersion))
  tErrorData.setAt("build", tEnv.getAt(#productBuildVersion))
  tErrorData.setAt("os", tEnv.getAt(#osVersion))
  tItemNo = 1
  repeat while tItemNo <= tErrorData.count
    tKey = string(tErrorData.getPropAt(tItemNo))
    tKey = urlEncode(tKey)
    tValue = string(tErrorData.getAt(tKey))
    tValue = urlEncode(tValue)
    if (tItemNo = 1) then
      tParams = tParams & tKey & "=" & tValue
    else
      tParams = tParams & "&" & tKey & "=" & tValue
    end if
    tItemNo = (1 + tItemNo)
  end repeat
  tPrefTxt = date() && time() & "\r" & replaceChunks(tParams, "&", "\r")
  setPref("ClientFatalParams", tPrefTxt)
  me.showErrorDialog()
  pauseUpdate()
  if tErrorUrl <> "" then
    openNetPage(tErrorUrl & tParams, "self")
  end if
  return TRUE
end

on showErrorDialog me 
  if createWindow(#error, "error.window", 0, 0, #modal) <> 0 then
    getWindow(#error).registerClient(me.getID())
    getWindow(#error).registerProcedure(#eventProcError, me.getID(), #mouseUp)
    return TRUE
  else
    return FALSE
  end if
end

on eventProcError me, tEvent, tSprID, tParam 
  if (tEvent = #mouseUp) and (tSprID = "error_close") then
    resetClient()
  end if
end
