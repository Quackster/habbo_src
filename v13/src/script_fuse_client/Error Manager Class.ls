property pErrorCache, pCacheSize, pDebugLevel

on construct me 
  if not the runMode contains "Author" then
    the alertHook = me
  end if
  pDebugLevel = 1
  pErrorCache = ""
  pCacheSize = 30
  return TRUE
end

on deconstruct me 
  the alertHook = 0
  return TRUE
end

on error me, tObject, tMsg, tMethod 
  if objectp(tObject) then
    tObject = string(tObject)
    tObject = tObject.getProp(#word, 2, (tObject.count(#word) - 2))
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

on alertHook me, tErr, tMsgA, tMsgB 
  me.showErrorDialog()
  pauseUpdate()
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
