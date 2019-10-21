property pListenerList, pAssetId, pAssetType, pDownloadURL, pAllowindexing

on construct me 
  pListenerList = []
  pAssetId = void()
  pDownloadID = void()
  pAllowindexing = 0
end

on addCallbackListener me, tObjectID, tHandlerName, tCallbackParams 
  tNewListener = [#objectID:tObjectID, #handlerName:tHandlerName, #callbackParams:tCallbackParams]
  pListenerList.add(tNewListener)
end

on purgeCallbacks me, tSuccess 
  tTimeoutName = "dyndownload" & the milliSeconds
  tCounter = 1
  repeat while pListenerList <= undefined
    tListener = getAt(undefined, tSuccess)
    tObject = getObject(tListener.getAt(#objectID))
    tHandler = tListener.getAt(#handlerName)
    tCallbackParams = tListener.getAt(#callbackParams)
    if tObject <> 0 and symbolp(tHandler) then
      createTimeout(tTimeoutName & tCounter, 10, #sendTimeoutCallbacks, me.getID(), [tHandler, tObject, pAssetId, tSuccess, tCallbackParams], 1)
    else
      error(me, "Object or handler invalid:" && tObject && tHandler, #purgeCallbacks)
    end if
    tCounter = (tCounter + 1)
  end repeat
  pListenerList = []
end

on setAssetId me, tAssetId 
  pAssetId = tAssetId
end

on getAssetId me 
  return(pAssetId)
end

on setAssetType me, tAssetType 
  pAssetType = tAssetType
end

on getAssetType me 
  return(pAssetType)
end

on setDownloadName me, tURL 
  pDownloadURL = tURL
end

on getDownloadName me 
  tOffset = offset("?", pDownloadURL)
  if tOffset then
    tDownloadURLNoParams = pDownloadURL.getProp(#char, 1, (tOffset - 1))
  else
    tDownloadURLNoParams = pDownloadURL
  end if
  return(tDownloadURLNoParams)
end

on setIndexing me, tAllowIndexing 
  pAllowindexing = tAllowIndexing
end

on getIndexing me 
  return(pAllowindexing)
end

on sendTimeoutCallbacks me, tArguments 
  call(tArguments.getAt(1), tArguments.getAt(2), tArguments.getAt(3), tArguments.getAt(4), tArguments.getAt(5))
end
