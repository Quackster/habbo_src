property pHost, pPort, pXtra, pMsgStruct, pConnectionOk, pConnectionSecured, pConnectionShouldBeKilled, pLastContent, pContentChunk, pCommandsPntr, pListenersPntr, pBinDataCallback, pLogMode, pLogfield

on construct me
  pDecoder = 0
  pBinDataCallback = [#client: EMPTY, #method: VOID]
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  pMsgStruct = getStructVariable("struct.message")
  return 1
end

on deconstruct me
  return me.disconnect(1)
end

on connect me, tHost, tPort
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if tErrCode = 0 then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 0)
  else
    return error(me, "Creation of callback failed:" && tErrCode, #connect)
  end if
  return 1
end

on disconnect me, tControlled
  if tControlled <> 1 then
    me.forwardMsg("DISCONNECT")
  else
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(VOID, VOID)
  end if
  pXtra = VOID
  if not tControlled then
    error(me, "Connection disconnected:" && me.getID(), #disconnect)
  end if
  return 1
end

on connectionReady me
  return pConnectionOk
end

on send me, tMsg
  if pConnectionOk and objectp(pXtra) then
    if pLogMode > 0 then
      me.log("<--" && tMsg)
    end if
    tLength = string(tMsg.length)
    repeat while tLength.length < 4
      tLength = tLength & SPACE
    end repeat
    pXtra.sendNetMessage("*", tMsg.word[1], tMsg.word[2..tMsg.word.count])
  else
    return error(me, "Connection not ready:" && me.getID(), #send)
  end if
  return 1
end

on sendBinary me, tObject
  if pConnectionOk and objectp(pXtra) then
    return pXtra.sendNetMessage("*", "BINDATA", tObject)
  end if
end

on registerBinaryDataHandler me, tObjID, tMethod
  pBinDataCallback.client = tObjID
  pBinDataCallback.method = tMethod
  return 1
end

on getWaitingMessagesCount me
  return pXtra.getNumberWaitingNetMessages()
end

on processWaitingMessages me, tCount
  if voidp(tCount) then
    tCount = 1
  end if
  return pXtra.checkNetMessages(tCount)
end

on getProperty me, tProp
  case tProp of
    #host:
      return pHost
    #port:
      return pPort
    #listener:
      return pListenersPntr
    #commands:
      return pCommandsPntr
    #message:
      return pMsgStruct
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #listener:
      if tValue.ilk = #struct then
        pListenersPntr = tValue
        return 1
      else
        return 0
      end if
    #commands:
      if tValue.ilk = #struct then
        pCommandsPntr = tValue
        return 1
      else
        return 0
      end if
    otherwise:
      return 0
  end case
  return 0
end

on setLogMode me, tMode
  if tMode.ilk <> #integer then
    return error(me, "Invalid argument:" && tMode, #setLogMode)
  end if
  pLogMode = tMode
  if pLogMode = 2 then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = VOID
      pLogMode = 1
    end if
  end if
  return 1
end

on xtraMsgHandler me
  if pConnectionShouldBeKilled <> 0 then
    return 0
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  if tNewMsg = VOID then
    me.disconnect()
    return error(me, "getNetMessage() returned VOID.", #xtraMsgHandler)
  end if
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  tSubject = tNewMsg.getaProp(#subject)
  if tErrCode <> 0 then
    me.disconnect()
    return 0
  end if
  if pLogMode > 0 then
    me.log("-->" && tNewMsg.subject & RETURN && tContent)
  end if
  case tContent.ilk of
    #string:
      me.forwardMsg(tNewMsg.subject & RETURN & tContent)
    #void:
      if tSubject <> "ConnectToNetServer" then
        error(me, "Message content is VOID!!!", #xtraMsgHandler)
      end if
    otherwise:
      if voidp(pBinDataCallback.method) then
        return error(me, "No callback registered!", #xtraMsgHandler)
      end if
      if not objectExists(pBinDataCallback.client) then
        return error(me, "Callback client not found!", #xtraMsgHandler)
      end if
      call(pBinDataCallback.method, getObject(pBinDataCallback.client), tContent)
  end case
end

on forwardMsg me, tMessage
  if pConnectionShouldBeKilled = 1 then
    return 0
  end if
  tMessage = getStringServices().convertSpecialChars(tMessage)
  tSubject = tMessage.word[1]
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if pMsgStruct.ilk <> #struct then
    pMsgStruct = getStructVariable("struct.message")
    pMsgStruct.setaProp(#connection, me)
    error(me, "Multiuser instance had problems...", #forwardMsg)
  end if
  if listp(tCallbackList) then
    tObjMngr = getObjectManager()
    repeat with i = 1 to count(tCallbackList)
      tCallback = tCallbackList[i]
      tObject = tObjMngr.GET(tCallback[1])
      if tObject <> 0 then
        pMsgStruct.setaProp(#message, tMessage)
        pMsgStruct.setaProp(#subject, tSubject)
        pMsgStruct.setaProp(#content, tMessage.word[2..tMessage.word.count])
        call(tCallback[2], tObject, pMsgStruct)
        next repeat
      end if
      error(me, "Listening obj not found, removed:" && tCallback[1], #forwardMsg)
      tCallbackList.deleteAt(1)
      i = i - 1
    end repeat
  else
    error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg)
  end if
end

on log me, tMsg
  if not (the runMode contains "Author") then
    return 1
  end if
  case pLogMode of
    1:
      put "[Connection" && me.getID() & "] :" && tMsg
    2:
      if ilk(pLogfield, #member) then
        put RETURN & "[Connection" && me.getID() & "] :" && tMsg after pLogfield
      end if
  end case
end
