property pXtra, pHost, pPort, pConnectionOk, pLogMode, pUnicodeDirector, pBinDataCallback, pListenersPntr, pCommandsPntr, pMsgStruct, pConnectionShouldBeKilled, pLogfield

on construct me 
  if value(_player.productVersion) >= 11 then
    pUnicodeDirector = 1
  else
    pUnicodeDirector = 0
  end if
  pDecoder = 0
  pBinDataCallback = [#client:"", #method:void()]
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  pMsgStruct = getStructVariable("struct.message")
  return TRUE
end

on deconstruct me 
  return(me.disconnect(1))
end

on connect me, tHost, tPort 
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits((16 * 1024), (100 * 1024), 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if (tErrCode = 0) then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 0)
  else
    return(error(me, "Creation of callback failed:" && tErrCode, #connect, #major))
  end if
  return TRUE
end

on disconnect me, tControlled 
  if tControlled <> 1 then
    me.forwardMsg("DISCONNECT")
  else
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(void(), void())
  end if
  pXtra = void()
  if not tControlled then
    error(me, "Connection disconnected:" && me.getID(), #disconnect, #minor)
  end if
  return TRUE
end

on connectionReady me 
  return(pConnectionOk)
end

on send me, tMsg 
  if pConnectionOk and objectp(pXtra) then
    if pLogMode > 0 then
      me.log("<--" && tMsg)
    end if
    tLength = string(tMsg.length)
    repeat while tLength.length < 4
      tLength = tLength & space()
    end repeat
    tPartOne = tMsg.getProp(#word, 1)
    tPartTwo = tMsg.getProp(#word, 2, tMsg.count(#word))
    if not pUnicodeDirector then
      tPartOne = encodeUTF8(tPartOne)
      tPartTwo = encodeUTF8(tPartTwo)
    end if
    pXtra.sendNetMessage("*", tPartOne, tPartTwo)
  else
    return(error(me, "Connection not ready:" && me.getID(), #send, #major))
  end if
  return TRUE
end

on sendBinary me, tObject 
  if pConnectionOk and objectp(pXtra) then
    return(pXtra.sendNetMessage("*", "BINDATA", tObject))
  end if
end

on registerBinaryDataHandler me, tObjID, tMethod 
  pBinDataCallback.client = tObjID
  pBinDataCallback.method = tMethod
  return TRUE
end

on getWaitingMessagesCount me 
  return(pXtra.getNumberWaitingNetMessages())
end

on processWaitingMessages me, tCount 
  if voidp(tCount) then
    tCount = 1
  end if
  return(pXtra.checkNetMessages(tCount))
end

on getProperty me, tProp 
  if (tProp = #host) then
    return(pHost)
  else
    if (tProp = #port) then
      return(pPort)
    else
      if (tProp = #listener) then
        return(pListenersPntr)
      else
        if (tProp = #commands) then
          return(pCommandsPntr)
        else
          if (tProp = #message) then
            return(pMsgStruct)
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on setProperty me, tProp, tValue 
  if (tProp = #listener) then
    if (tValue.ilk = #struct) then
      pListenersPntr = tValue
      return TRUE
    else
      return FALSE
    end if
  else
    if (tProp = #commands) then
      if (tValue.ilk = #struct) then
        pCommandsPntr = tValue
        return TRUE
      else
        return FALSE
      end if
    else
      return FALSE
    end if
  end if
  return FALSE
end

on setLogMode me, tMode 
  if tMode.ilk <> #integer then
    return(error(me, "Invalid argument:" && tMode, #setLogMode, #minor))
  end if
  pLogMode = tMode
  if (pLogMode = 2) then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = void()
      pLogMode = 1
    end if
  end if
  return TRUE
end

on xtraMsgHandler me 
  if pConnectionShouldBeKilled <> 0 then
    return FALSE
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  if (tNewMsg = void()) then
    me.disconnect()
    return(error(me, "getNetMessage() returned VOID.", #xtraMsgHandler, #major))
  end if
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  tSubject = tNewMsg.getaProp(#subject)
  if tErrCode <> 0 then
    me.disconnect()
    return FALSE
  end if
  if pLogMode > 0 then
    me.log("-->" && tNewMsg.subject & "\r" && tContent)
  end if
  if (tContent.ilk = #string) then
    me.forwardMsg(tNewMsg.subject & "\r" & tContent)
  else
    if (tContent.ilk = #void) then
      if tSubject <> "ConnectToNetServer" then
        error(me, "Message content is VOID!!!", #xtraMsgHandler, #major)
      end if
    else
      if voidp(pBinDataCallback.method) then
        return(error(me, "No callback registered!", #xtraMsgHandler, #major))
      end if
      if not objectExists(pBinDataCallback.client) then
        return(error(me, "Callback client not found!", #xtraMsgHandler, #major))
      end if
      call(pBinDataCallback.method, getObject(pBinDataCallback.client), tContent)
    end if
  end if
end

on forwardMsg me, tMessage 
  if (pConnectionShouldBeKilled = 1) then
    return FALSE
  end if
  tMessage = getStringServices().convertSpecialChars(tMessage)
  tSubject = tMessage.getProp(#word, 1)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if pMsgStruct.ilk <> #struct then
    pMsgStruct = getStructVariable("struct.message")
    pMsgStruct.setaProp(#connection, me)
    error(me, "Multiuser instance had problems...", #forwardMsg, #major)
  end if
  if listp(tCallbackList) then
    tObjMngr = getObjectManager()
    i = 1
    repeat while i <= count(tCallbackList)
      tCallback = tCallbackList.getAt(i)
      tObject = tObjMngr.GET(tCallback.getAt(1))
      if tObject <> 0 then
        pMsgStruct.setaProp(#message, tMessage)
        pMsgStruct.setaProp(#subject, tSubject)
        pMsgStruct.setaProp(#content, tMessage.getProp(#word, 2, tMessage.count(#word)))
        call(tCallback.getAt(2), tObject, pMsgStruct)
      else
        error(me, "Listening obj not found, removed:" && tCallback.getAt(1), #forwardMsg, #minor)
        tCallbackList.deleteAt(1)
        i = (i - 1)
      end if
      i = (1 + i)
    end repeat
    exit repeat
  end if
  error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg, #minor)
end

on log me, tMsg 
  if not the runMode contains "Author" then
    return TRUE
  end if
  if (pLogMode = 1) then
    put("[Connection" && me.getID() & "] :" && tMsg)
  else
    if (pLogMode = 2) then
      if ilk(pLogfield, #member) then
      end if
    end if
  end if
end
