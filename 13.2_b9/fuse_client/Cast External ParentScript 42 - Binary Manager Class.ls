property pConnectionId, pTimeOutID, pQueue, pCrypto, pUseCrypto, pHandshakeFinished

on construct me
  pConnectionId = getVariable("connection.mus.id", #mus)
  pTimeOutID = "mus_close_delay"
  pCallBacks = [:]
  pQueue = []
  pCrypto = createObject(#temp, getClassVariable("connection.decoder.class"))
  pUseCrypto = 0
  pHandshakeFinished = 0
  return me.registerCmds(1)
end

on deconstruct me
  me.registerCmds(0)
  pHandshakeFinished = 0
  pUseCrypto = 0
  return removeMultiuser(pConnectionId)
end

on retrieveData me, tid, tAuth, tCallBackObj
  pQueue.add([#type: #retrieve, #id: tid, #auth: tAuth, #callback: tCallBackObj])
  if (count(pQueue) = 1) or not multiuserExists(pConnectionId) then
    me.next()
  end if
end

on storeData me, tdata, tCallBackObj
  pQueue.add([#type: #store, #data: tdata, #callback: tCallBackObj])
  if (count(pQueue) = 1) or not multiuserExists(pConnectionId) then
    me.next()
  end if
end

on addMessageToQueue me, tMsg
  pQueue.add([#type: #fusemsg, #message: tMsg])
  if (count(pQueue) = 1) or not multiuserExists(pConnectionId) then
    me.next()
  end if
end

on checkConnection me
  if not multiuserExists(pConnectionId) then
    return error(me, "MUS connection not found:" && pConnectionId, #checkConnection)
  end if
  if getMultiuser(pConnectionId).connectionReady() and pHandshakeFinished then
    tUserID = getObject(#session).GET(#user_user_id)
    tMachineID = getSpecialServices().getMachineID()
    if pUseCrypto then
      tUserID = pCrypto.encipher(tUserID)
      tMachineID = pCrypto.encipher(tMachineID)
    end if
    getMultiuser(pConnectionId).send("LOGIN" && tUserID && tMachineID)
    me.next()
  else
    me.delay(1000, #checkConnection)
  end if
end

on next me
  if not multiuserExists(pConnectionId) then
    createMultiuser(pConnectionId, getVariable("connection.mus.host"), getIntVariable("connection.mus.port"))
    getMultiuser(pConnectionId).registerBinaryDataHandler(me.getID(), #binaryDataReceived)
    me.delay(1000, #checkConnection)
  else
    if getMultiuser(pConnectionId).connectionReady() then
      if timeoutExists(pTimeOutID) then
        removeTimeout(pTimeOutID)
      end if
      if count(pQueue) > 0 then
        tTask = pQueue[1]
        case tTask.type of
          #store:
            return getMultiuser(pConnectionId).sendBinary(tTask.data)
          #retrieve:
            return getMultiuser(pConnectionId).send("GETBINDATA" && tTask.id && tTask.auth)
          #fusemsg:
            pQueue.deleteAt(1)
            getMultiuser(pConnectionId).send(tTask.message)
            me.next()
            return 1
        end case
      else
        createTimeout(pTimeOutID, 30000, #delayedClosing, me.getID(), VOID, 1)
      end if
    end if
  end if
end

on binaryDataStored me, tMsg
  tTask = pQueue[1]
  if tTask[#callback] <> VOID then
    tObject = getObject(tTask[#callback])
    if tObject.ilk = #instance then
      call(#binaryDataStored, tObject, tMsg.getaProp(#content))
    end if
  end if
  pQueue.deleteAt(1)
  me.next()
end

on binaryDataAuthKeyError me
  pQueue.deleteAt(1)
  me.next()
end

on binaryDataReceived me, tdata
  tTask = pQueue[1]
  pQueue.deleteAt(1)
  if tTask[#callback] <> VOID then
    tObject = getObject(tTask[#callback])
    if tObject.ilk = #instance then
      call(#binaryDataReceived, tObject, tdata, tTask[#id])
    end if
  end if
  me.next()
end

on delayedClosing me
  if multiuserExists(pConnectionId) and (count(pQueue) = 0) then
    removeMultiuser(pConnectionId)
  end if
end

on registerCmds me, tBool
  tList = [:]
  tList["BINDATA_SAVED"] = #binaryDataStored
  tList["BINDATA_AUTHKEYERROR"] = #binaryDataAuthKeyError
  tList["DISCONNECT"] = #deconstruct
  tList["HELLO"] = #helloReply
  tList["U_RTS"] = #foo
  if tBool then
    return getMultiuserManager().registerListener(pConnectionId, me.getID(), tList)
  else
    return getMultiuserManager().unregisterListener(pConnectionId, me.getID(), tList)
  end if
end

on foo me
end

on helloReply me, tMsg
  tSecretKey = tMsg[#content]
  tSecretKey = integer(tSecretKey)
  if voidp(tSecretKey) or (tSecretKey = EMPTY) or (tSecretKey = 0) then
    pUseCrypto = 0
  else
    pCrypto.setKey(tSecretKey)
    tPremixString = "j5bty8i7s0gkca3m53z7b0bh3xonkxpun0s5qjn0gkntvqzzpwi1nqagpa7tjopes0hm5t870kam370hxnxu05j0ktqzw1qgatoe0mf"
    pCrypto.preMixEncodeSbox(tPremixString, 17)
    pUseCrypto = 1
  end if
  pHandshakeFinished = 1
end
