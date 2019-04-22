property pMsgStruct, pXtra, pHost, pPort, pLogMode, pConnectionOk, pConnectionSecured, pDecoder, pCommandsPntr, pEncryptionOn, pListenersPntr, pConnectionShouldBeKilled, pLastContent, pLogfield

on construct me 
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me.getID())
  pDecoder = 0
  pLastContent = ""
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  return(1)
end

on deconstruct me 
  return(me.disconnect(1))
end

on connect me, tHost, tPort 
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if tErrCode = 0 then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return(error(me, "Creation of callback failed:" && tErrCode, #connect))
  end if
  pLastContent = ""
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return(1)
end

on disconnect me, tControlled 
  if tControlled <> 1 then
    me.forwardMsg("DISCONNECT")
  else
    me.send(#info, "QUIT")
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
end

on connectionReady me 
  return(pConnectionOk and pConnectionSecured)
end

on setDecoder me, tDecoder 
  if not objectp(tDecoder) then
    return(error(me, "Decoder object expected:" && tDecoder, #setDecoder))
  else
    pDecoder = tDecoder
    return(1)
  end if
end

on getDecoder me 
  return(pDecoder)
end

on setLogMode me, tMode 
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
end

on getLogMode me 
  return(pLogMode)
end

on setEncryption me, tBoolean 
  pEncryptionOn = tBoolean
  pConnectionSecured = 1
  return(1)
end

on send me, tCmd, tMsg 
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send))
  end if
  if tMsg.ilk <> #string then
    tMsg = string(tMsg)
  end if
  if pLogMode > 0 then
    me.log("<--" && tCmd && tMsg)
  end if
  getObject(#session).set("con_lastsend", tCmd && tMsg && "-" && the long time)
  if tCmd.ilk <> #integer then
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tCmd)
  end if
  if tCmd.ilk = #void then
    return(error(me, "Unrecognized command!", #send))
  end if
  if pEncryptionOn and objectp(pDecoder) then
    tMsg = pDecoder.encipher(tMsg)
  else
  end if
  tLength = 0
  tChar = 1
  repeat while tChar <= length(tMsg)
    tCharNum = charToNum(tMsg.char[tChar])
    tLength = tLength + 1 + tCharNum > 255
    tChar = 1 + tChar
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 127), 128))
  tL2 = numToChar(bitOr(bitAnd(tLength / 128, 127), 128))
  tL3 = numToChar(bitOr(bitAnd(tLength / 16384, 127), 128))
  tMsg = tCmd & tL3 & tL2 & tL1 & tMsg
  pXtra.sendNetMessage(0, 0, tMsg)
  return(1)
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
  if tProp = #xtra then
    return(pXtra)
  else
    if tProp = #host then
      return(pHost)
    else
      if tProp = #port then
        return(pPort)
      else
        if tProp = #decoder then
          return(me.getDecoder())
        else
          if tProp = #logmode then
            return(me.getLogMode())
          else
            if tProp = #listener then
              return(pListenersPntr)
            else
              if tProp = #commands then
                return(pCommandsPntr)
              else
                if tProp = #message then
                  return(pMsgStruct)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(0)
end

on setProperty me, tProp, tValue 
  if tProp = #decoder then
    return(me.setDecoder(tValue))
  else
    if tProp = #logmode then
      return(me.setLogMode(tValue))
    else
      if tProp = #listener then
        if tValue.ilk = #struct then
          pListenersPntr = tValue
          return(1)
        else
          return(0)
        end if
      else
        if tProp = #commands then
          if tValue.ilk = #struct then
            pCommandsPntr = tValue
            return(1)
          else
            return(0)
          end if
        end if
      end if
    end if
  end if
  return(0)
end

on print me 
  tStr = ""
  if symbolp(me.getID()) then
  end if
  tMsgsList = pListenersPntr.getaProp(#value)
  if listp(tMsgsList) then
    i = 1
    repeat while i <= count(tMsgsList)
      tCallbackList = tMsgsList.getAt(i)
      repeat while "#" <= undefined
        tCallback = getAt(undefined, undefined)
      end repeat
      i = 1 + i
    end repeat
  end if
  put(tStr & "\r")
  return(1)
end

on xtraMsgHandler me 
  if pConnectionShouldBeKilled <> 0 then
    return(0)
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  if tErrCode <> 0 then
    if pLogMode > 0 then
      me.log("Connection" && me.getID() && "was disconnected")
      me.log("host = " & pHost && ", port = " & pPort)
      me.log(tNewMsg)
    end if
    me.disconnect()
    return(0)
  end if
  if tContent.ilk = #string then
    if not tContent contains "##" then
      pLastContent = pLastContent & tContent
      return(0)
    end if
    if pLastContent <> "" then
      tContent = pLastContent & tContent
    end if
    tDelim = the itemDelimiter
    pContentChunk = ""
    tContentArray = []
    the itemDelimiter = "##"
    tLength = length(tContent)
    tBool = not chars(tContent, tLength - 1, tLength) = "##"
    tCount = tContent.count(#items)
    pLastContent = ""
    i = 1
    repeat while i <= tCount
      tMsgStr = tContent.getProp(#item, i)
      if i < tCount or tBool = 0 then
        if length(tMsgStr) > 1 then
          tContentArray.add(tMsgStr)
        end if
      else
        if tBool = 1 and i = tCount then
          pLastContent = tMsgStr
        end if
      end if
      i = 1 + i
    end repeat
    the itemDelimiter = tDelim
    i = 1
    repeat while i <= tContentArray.count
      me.forwardMsg(tContentArray.getAt(i))
      i = 1 + i
    end repeat
  end if
end

on forwardMsg me, tMessage 
  if pConnectionShouldBeKilled = 1 then
    return(0)
  end if
  if pLogMode > 0 then
    me.log("-->" && tMessage)
  end if
  getObject(#session).set("con_lastreceived", tMessage.getProp(#line, 1) && "-" && the long time)
  tSubject = tMessage.getProp(#word, 1)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if pMsgStruct.ilk <> #struct then
    pMsgStruct = getStructVariable("struct.message")
    pMsgStruct.setaProp(#connection, me.getID())
    error(me, "Connection instance had problems...", #forwardMsg)
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
end

on log me, tMsg 
  if pLogMode = 1 then
    put("[Connection" && me.getID() & "] :" && tMsg)
  else
    if pLogMode = 2 then
      if ilk(pLogfield, #member) then
      end if
    end if
  end if
end
