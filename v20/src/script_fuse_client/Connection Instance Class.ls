property pMsgStruct, pXtra, pHost, pPort, pLogMode, pConnectionOk, pConnectionSecured, pDecoder, pEncoder, pConnectionShouldBeKilled, pCommandsPntr, pEncryptionOn, pListenersPntr, pDecipherOn, pLastContent, pD, pLogfield

on construct me 
  pDecipherOn = 0
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me)
  pDecoder = 0
  pEncoder = 0
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
  sendProcessTracking(30)
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if tErrCode = 0 then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return(error(me, "Creation of callback failed:" && tErrCode, #connect, #major))
  end if
  pLastContent = ""
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return(1)
end

on disconnect me, tControlled 
  if tControlled <> 1 then
    me.forwardMsg(-1)
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
  return(1)
end

on connectionReady me 
  return(pConnectionOk and pConnectionSecured)
end

on setDecoder me, tDecoder 
  if not objectp(tDecoder) then
    return(error(me, "Decoder object expected:" && tDecoder, #setDecoder, #major))
  else
    pDecoder = tDecoder
    return(1)
  end if
end

on getDecoder me 
  return(pDecoder)
end

on setEncoder me, tEncoder 
  if not objectp(tEncoder) then
    return(error(me, "Encoder object expected:" && tEncoder, #setEncoder, #major))
  else
    pEncoder = tEncoder
    return(1)
  end if
end

on getEncoder me 
  return(pEncoder)
end

on setLogMode me, tMode 
  if tMode.ilk <> #integer then
    return(error(me, "Invalid argument:" && tMode, #setLogMode, #minor))
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
  if pConnectionShouldBeKilled then
    return(0)
  end if
  if tMsg.ilk = #propList then
    return(me.sendNew(tCmd, tMsg))
  end if
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send, #major))
  end if
  if tMsg.ilk <> #string then
    tMsg = string(tMsg)
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if tCmd.ilk = #void then
    return(error(me, "Unrecognized command!", #send, #major))
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  tMsg = tCmd & tMsg
  tLength = 0
  tChar = 1
  repeat while tChar <= length(tMsg)
    tCharNum = charToNum(tMsg.char[tChar])
    tLength = tLength + 1 + tCharNum > 255
    tChar = 1 + tChar
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd(tLength / 64, 63), 64))
  tL3 = numToChar(bitOr(bitAnd(tLength / 4096, 63), 64))
  tMsg = tL3 & tL2 & tL1 & tMsg
  if pEncryptionOn and objectp(pEncoder) then
    tMsg = pEncoder.encipher(tMsg)
  end if
  pXtra.sendNetMessage(0, 0, tMsg)
  return(1)
end

on sendNew me, tCmd, tParmArr 
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send, #major))
  end if
  tMsg = ""
  tLength = 2
  if listp(tParmArr) then
    i = 1
    repeat while i <= tParmArr.count
      ttype = tParmArr.getPropAt(i)
      tParm = tParmArr.getAt(i)
      if ttype = #string then
        tLen = 0
        tChar = 1
        repeat while tChar <= length(tParm)
          tNum = charToNum(tParm.char[tChar])
          tLen = tLen + 1 + tNum > 255
          tChar = 1 + tChar
        end repeat
        tBy1 = numToChar(bitOr(64, tLen / 64))
        tBy2 = numToChar(bitOr(64, bitAnd(63, tLen)))
        tMsg = tMsg & tBy1 & tBy2 & tParm
        tLength = tLength + tLen + 2
      else
        if ttype = #short then
          tBy1 = numToChar(bitOr(64, tParm / 64))
          tBy2 = numToChar(bitOr(64, bitAnd(63, tParm)))
          tMsg = tMsg & tBy1 & tBy2
          tLength = tLength + 2
        else
          if ttype = #integer then
            if tParm < 0 then
              tNegMask = 4
              tParm = -tParm
            else
              tNegMask = 0
            end if
            tStr = numToChar(64 + bitAnd(tParm, 3))
            tBytes = 1
            tParm = tParm / 4
            repeat while tParm <> 0
              tBytes = tBytes + 1
              tParm = tParm / 64
            end repeat
            tLength = tLength + tBytes
          else
            if ttype = #boolean then
              tParm = tParm <> 0
              tBy1 = numToChar(bitOr(64, bitAnd(63, tParm)))
              tMsg = tMsg & tBy1
              tLength = tLength + 1
            else
              error(me, "Unsupported param type:" && ttype, #send, #major)
            end if
          end if
        end if
      end if
      i = 1 + i
    end repeat
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if tCmd.ilk = #void then
    return(error(me, "Unrecognized command!", #send, #major))
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  tMsg = tCmd & tMsg
  tL1 = numToChar(bitOr(bitAnd(tLength, 63), 64))
  tL2 = numToChar(bitOr(bitAnd(tLength / 64, 63), 64))
  tL3 = numToChar(bitOr(bitAnd(tLength / 4096, 63), 64))
  tMsg = tL3 & tL2 & tL1 & tMsg
  if pEncryptionOn and objectp(pEncoder) then
    tMsg = pEncoder.encipher(tMsg)
  end if
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
          if tProp = #encoder then
            return(me.getEncoder())
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
                  else
                    if tProp = #deciphering then
                      return(pDecipherOn)
                    end if
                  end if
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
    if tProp = #encoder then
      return(me.setEncoder(tValue))
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
          else
            if tProp = #deciphering then
              pDecipherOn = tValue
            end if
          end if
        end if
      end if
    end if
  end if
  return(0)
end

on GetBoolFrom me 
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  pMsgStruct.setaProp(#content, tByteStr.getProp(#char, 2, length(tByteStr)))
  return(tByte <> 0)
end

on GetByteFrom me 
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  pMsgStruct.setaProp(#content, tByteStr.getProp(#char, 2, length(tByteStr)))
  return(tByte)
end

on GetIntFrom me 
  tByteStr = pMsgStruct.getaProp(#content)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  tByCnt = bitOr(bitAnd(tByte, 56) / 8, 0)
  tNeg = bitAnd(tByte, 4)
  tInt = bitAnd(tByte, 3)
  if tByCnt > 1 then
    tPowTbl = [4, 256, 16384, 1048576, 67108864]
    i = 2
    repeat while i <= tByCnt
      tByte = bitAnd(charToNum(tByteStr.char[i]), 63)
      tInt = bitOr(tByte * tPowTbl.getAt(i - 1), tInt)
      i = 1 + i
    end repeat
  end if
  if tNeg then
    tInt = -tInt
  end if
  pMsgStruct.setaProp(#content, tByteStr.getProp(#char, tByCnt + 1, length(tByteStr)))
  return(tInt)
end

on GetStrFrom me 
  tArr = pMsgStruct.getaProp(#content)
  tLen = offset(numToChar(2), tArr)
  if tLen > 1 then
    tStr = tArr.char[1..tLen - 1]
  else
    tStr = ""
  end if
  pMsgStruct.setaProp(#content, tArr.char[tLen + 1..length(tArr)])
  return(tStr)
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
  if pEncryptionOn and pDecipherOn then
    tContent = pDecoder.decipher(tContent)
  end if
  me.msghandler(tContent)
end

on msghandler me, tContent 
  if tContent.ilk <> #string then
    return(0)
  end if
  if pLastContent.length > 0 then
    tContent = pLastContent & tContent
    pLastContent = ""
  end if
  if tContent.length < 3 then
    pLastContent = pLastContent & tContent
    return()
  end if
  tByte1 = bitAnd(charToNum(tContent.char[2]), 63)
  tByte2 = bitAnd(charToNum(tContent.char[1]), 63)
  tMsgType = bitOr(tByte2 * 64, tByte1)
  tLength = offset(numToChar(1), tContent)
  if tLength = 0 then
    pLastContent = tContent
    return()
  end if
  tParams = tContent.char[3..tLength - 1]
  tContent = tContent.char[tLength + 1..tContent.length]
  me.forwardMsg(tMsgType, tParams)
  if tContent.length > 0 then
    me.msghandler(tContent)
  end if
end

on forwardMsg me, tSubject, tParams 
  if pLogMode > 0 then
    me.log("-->" && tSubject & "\r" & tParams)
  end if
  tParams = getStringServices().convertSpecialChars(tParams)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if tCallbackList.ilk <> #list then
    return(error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg, #minor))
  end if
  tObjMgr = getObjectManager()
  i = 1
  repeat while i <= count(tCallbackList)
    tCallback = tCallbackList.getAt(i)
    tObject = tObjMgr.GET(tCallback.getAt(1))
    if tObject <> 0 then
      pMsgStruct.setaProp(#subject, tSubject)
      pMsgStruct.setaProp(#content, tParams)
      getConnectionManager().registerLastMessage(tSubject, tParams)
      call(tCallback.getAt(2), tObject, pMsgStruct)
    else
      error(me, "Listening obj not found, removed:" && tCallback.getAt(1), #forwardMsg, #minor)
      tCallbackList.deleteAt(1)
      i = i - 1
    end if
    i = 1 + i
  end repeat
end

on log me, tMsg 
  if not pD then
    the debugPlaybackEnabled = 0
    if not the runMode contains "Author" then
      return(1)
    end if
  end if
  if pLogMode = 1 then
    put("[Connection" && me.getID() & "] :" && tMsg)
  else
    if pLogMode = 2 then
      if not the runMode contains "Author" then
        return(1)
      end if
      if ilk(pLogfield, #member) then
      end if
    else
      if pLogMode = 3 then
        executeMessage(#logdata, tMsg)
      end if
    end if
  end if
end
