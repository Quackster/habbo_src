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
    3:
      executeMessage(#debugdata, "Error: " & tError)
    otherwise:
      put "Error:" & tError
  end case
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

on alertHook me, tErr, tMsgA, tMsgB
  me.showErrorDialog()
  pauseUpdate()
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
