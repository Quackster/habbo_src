property pDefaultCallType, pDefaultCallTemplate, pProxy

on construct me 
  pProxy = script("JavaScriptProxy").newJavaScriptProxy()
  if variableExists("stats.tracking.javascript") then
    pDefaultCallType = getVariable("stats.tracking.javascript")
  end if
  if variableExists("stats.tracking.javascript.template") then
    pDefaultCallTemplate = getVariable("stats.tracking.javascript.template")
  end if
  registerListener(getVariable("connection.info.id", #info), me.getID(), [166:#handle_update_stats])
  registerMessage(#sendTrackingData, me.getID(), #handle_update_stats)
  registerMessage(#sendTrackingPoint, me.getID(), #sendTrackingPoint)
  return TRUE
end

on deconstruct me 
  unregisterListener(getVariable("connection.info.id", #info), me.getID(), [166:#updateStats])
  unregisterMessage(#sendTrackingData, me.getID())
  unregisterMessage(#sendTrackingPoint, me.getID())
  pProxy = void()
  return TRUE
end

on sendJsMessage me, tMsg, tMsgType 
  if (the runMode = "Author") then
    return FALSE
  end if
  if voidp(tMsgType) then
    tMsgType = pDefaultCallType
  end if
  tMsgContent = tMsg
  if tMsgType <> "hello" and not voidp(pDefaultCallTemplate) then
    tMsgContent = replaceChunks(pDefaultCallTemplate, "\\TCODE", tMsg)
  end if
  tCallString = "\"" & tMsgType & "\"" & ", " & "\"" & tMsgContent & "\""
  pProxy.call(tCallString)
end

on sendTrackingPoint me, tPointStr 
  tTrackingHeader = getObject(#session).GET("tracking_header")
  if (tTrackingHeader = 0) then
    return(error(me, "Tracking header not in session.", #sendTrackingCall, #minor))
  end if
  if chars(tPointStr, 1, 1) <> "/" then
    tPointStr = "/" & tPointStr
  end if
  tTrackStr = tTrackingHeader & tPointStr
  me.sendJsMessage(tTrackStr)
end

on handle_update_stats me, tMsg 
  tContent = tMsg.content
  me.sendJsMessage(tContent)
end
