on construct(me)
  pDecoder = 0
  pBinDataCallback = [#client:"", #method:void()]
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  return(1)
  exit
end

on deconstruct(me)
  return(me.disconnect(1))
  exit
end

on connect(me, tHost, tPort)
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if tErrCode = 0 then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 0)
  else
    return(error(me, "Creation of callback failed:" && tErrCode, #connect))
  end if
  return(1)
  exit
end

on disconnect(me, tControlled)
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
    error(me, "Connection disconnected:" && me.getID(), #disconnect)
  end if
  return(1)
  exit
end

on connectionReady(me)
  return(pConnectionOk)
  exit
end

on send(me, tMsg)
  if pConnectionOk and objectp(pXtra) then
    if pLogMode > 0 then
      me.log("<--" && tMsg)
    end if
    tLength = string(tMsg.length)
    repeat while tLength.length < 4
      tLength = tLength & space()
    end repeat
    pXtra.sendNetMessage("*", tMsg.getProp(#word, 1), tMsg.getProp(#word, 2, tMsg.count(#word)))
  else
    return(error(me, "Connection not ready:" && me.getID(), #send))
  end if
  return(1)
  exit
end

on sendBinary(me, tObject)
  if pConnectionOk and objectp(pXtra) then
    return(pXtra.sendNetMessage("*", "BINDATA", tObject))
  end if
  exit
end

on registerBinaryDataHandler(me, tObjID, tMethod)
  pBinDataCallback.client = tObjID
  pBinDataCallback.method = tMethod
  return(1)
  exit
end

on getWaitingMessagesCount(me)
  return(pXtra.getNumberWaitingNetMessages())
  exit
end

on processWaitingMessages(me, tCount)
  if voidp(tCount) then
    tCount = 1
  end if
  return(pXtra.checkNetMessages(tCount))
  exit
end

on getProperty(me, tProp)
  if me = #host then
    return(pHost)
  else
    if me = #port then
      return(pPort)
    else
      if me = #listener then
        return(pListenersPntr)
      else
        if me = #commands then
          return(pCommandsPntr)
        else
          if me = #message then
            return(pMsgStruct)
          end if
        end if
      end if
    end if
  end if
  return(0)
  exit
end

on setProperty(me, tProp, tValue)
  if me = #listener then
    if tValue.ilk = #struct then
      pListenersPntr = tValue
      return(1)
    else
      return(0)
    end if
  else
    if me = #commands then
      if tValue.ilk = #struct then
        pCommandsPntr = tValue
        return(1)
      else
        return(0)
      end if
    else
      return(0)
    end if
  end if
  return(0)
  exit
end

on setLogMode(me, tMode)
  if tMode.ilk <> #integer then
    return(error(me, "Invalid argument:" && tMode, #setLogMode))
  end if
  pLogMode = tMode
  if pLogMode = 2 then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = void()
      pLogMode = 1
    end if
  end if
  return(1)
  exit
end

on xtraMsgHandler(me)
  if pConnectionShouldBeKilled <> 0 then
    return(0)
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  if tErrCode <> 0 then
    me.disconnect()
    return(0)
  end if
  if pLogMode > 0 then
    me.log("-->" && tNewMsg.subject & "\r" && tContent)
  end if
  if me = #string then
    me.forwardMsg(tNewMsg.subject & "\r" & tContent)
  else
    if me = #void then
      error(me, "Message content is VOID!!!", #xtraMsgHandler)
    else
      if voidp(pBinDataCallback.method) then
        return(error(me, "No callback registered!", #xtraMsgHandler))
      end if
      if not objectExists(pBinDataCallback.client) then
        return(error(me, "Callback client not found!", #xtraMsgHandler))
      end if
      call(pBinDataCallback.method, getObject(pBinDataCallback.client), tContent)
    end if
  end if
  exit
end

on forwardMsg(me, tMessage)
  if pConnectionShouldBeKilled = 1 then
    return(0)
  end if
  tMessage = getStringServices().convertSpecialChars(tMessage)
  tSubject = tMessage.getProp(#word, 1)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if pMsgStruct.ilk <> #struct then
    pMsgStruct = getStructVariable("struct.message")
    pMsgStruct.setaProp(#connection, me.getID())
    error(me, "Multiuser instance had problems...", #forwardMsg)
  end if
  if listp(tCallbackList) then
    tObjMngr = getObjectManager()
    i = 1
    repeat while i <= count(tCallbackList)
      tCallback = tCallbackList.getAt(i)
      tObject = tObjMngr.get(tCallback.getAt(1))
      if tObject <> 0 then
        pMsgStruct.setaProp(#message, tMessage)
        pMsgStruct.setaProp(#subject, tSubject)
        pMsgStruct.setaProp(#content, tMessage.getProp(#word, 2, tMessage.count(#word)))
        call(tCallback.getAt(2), tObject, pMsgStruct)
      else
        error(me, "Listening obj not found, removed:" && tCallback.getAt(1), #forwardMsg)
        tCallbackList.deleteAt(1)
        i = i - 1
      end if
      i = 1 + i
    end repeat
    exit repeat
  end if
  error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg)
  exit
end

on log(me, tMsg)
  if me = 1 then
    put("[Connection" && me.getID() & "] :" && tMsg)
  else
    if me = 2 then
      if ilk(pLogfield, #member) then
      end if
    end if
  end if
  exit
end