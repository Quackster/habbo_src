property pProxy, pDefaultCallType, pDefaultCallTemplate

on construct me
  pProxy = script("JavaScriptProxy").newJavaScriptProxy()
  if variableExists("stats.tracking.javascript") then
    pDefaultCallType = getVariable("stats.tracking.javascript")
  end if
  if variableExists("stats.tracking.javascript.template") then
    pDefaultCallTemplate = getVariable("stats.tracking.javascript.template")
  end if
  registerListener(getVariable("connection.info.id", #info), me.getID(), [166: #handle_update_stats])
  registerMessage(#sendTrackingData, me.getID(), #handle_update_stats)
  return 1
end

on deconstruct me
  unregisterListener(getVariable("connection.info.id", #info), me.getID(), [166: #updateStats])
  unregisterMessage(#sendTrackingData, me.getID())
  pProxy = VOID
  return 1
end

on sendJsMessage me, tMsg, tMsgType
  if the runMode = "Author" then
    return 0
  end if
  if voidp(tMsgType) then
    tMsgType = pDefaultCallType
  end if
  tMsgContent = tMsg
  if (tMsgType <> "hello") and not voidp(pDefaultCallTemplate) then
    tMsgContent = replaceChunks(pDefaultCallTemplate, "\TCODE", tMsg)
  end if
  tCallString = "ClientMessageHandler.call('" & tMsgType & "', '" & tMsgContent & "')"
  pProxy.call(tCallString)
end

on handle_update_stats me, tMsg
  tContent = tMsg.content
  me.sendJsMessage(tContent)
end
