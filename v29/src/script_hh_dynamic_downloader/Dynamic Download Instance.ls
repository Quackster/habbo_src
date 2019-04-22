on construct(me)
  pListenerList = []
  pAssetId = void()
  pDownloadID = void()
  pAllowindexing = 0
  exit
end

on addCallbackListener(me, tObjectId, tHandlerName, tCallbackParams)
  tNewListener = [#objectID:tObjectId, #handlerName:tHandlerName, #callbackParams:tCallbackParams]
  pListenerList.add(tNewListener)
  exit
end

on purgeCallbacks(me, tSuccess)
  tTimeOutName = "dyndownload" & the milliSeconds
  tCounter = 1
  repeat while me <= undefined
    tListener = getAt(undefined, tSuccess)
    tObject = getObject(tListener.getAt(#objectID))
    tHandler = tListener.getAt(#handlerName)
    tCallbackParams = tListener.getAt(#callbackParams)
    if tObject <> 0 and symbolp(tHandler) then
      createTimeout(tTimeOutName & tCounter, 10, #sendTimeoutCallbacks, me.getID(), [tHandler, tObject, pAssetId, tSuccess, tCallbackParams], 1)
    else
      error(me, "Object or handler invalid:" && tObject && tHandler, #purgeCallbacks, #minor)
    end if
    tCounter = tCounter + 1
  end repeat
  pListenerList = []
  exit
end

on setAssetId(me, tAssetId)
  pAssetId = tAssetId
  exit
end

on getAssetId(me)
  return(pAssetId)
  exit
end

on setAssetType(me, tAssetType)
  pAssetType = tAssetType
  exit
end

on getAssetType(me)
  return(pAssetType)
  exit
end

on setDownloadName(me, tURL)
  pDownloadURL = tURL
  exit
end

on getDownloadName(me)
  tOffset = offset("?", pDownloadURL)
  if tOffset then
    tDownloadURLNoParams = pDownloadURL.getProp(#char, 1, tOffset - 1)
  else
    tDownloadURLNoParams = pDownloadURL
  end if
  return(tDownloadURLNoParams)
  exit
end

on setIndexing(me, tAllowIndexing)
  pAllowindexing = tAllowIndexing
  exit
end

on getIndexing(me)
  return(pAllowindexing)
  exit
end

on setParentId(me, tParentId)
  pParentId = tParentId
  exit
end

on getParentId(me)
  return(pParentId)
  exit
end

on sendTimeoutCallbacks(me, tArguments)
  call(tArguments.getAt(1), tArguments.getAt(2), tArguments.getAt(3), tArguments.getAt(4), tArguments.getAt(5))
  exit
end