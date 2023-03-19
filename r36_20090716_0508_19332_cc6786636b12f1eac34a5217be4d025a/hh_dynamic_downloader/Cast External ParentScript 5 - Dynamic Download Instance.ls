property pListenerList, pAssetId, pDownloadURL, pAllowindexing, pAssetType, pParentId

on construct me
  pListenerList = []
  pAssetId = VOID
  pDownloadID = VOID
  pAllowindexing = 0
end

on addCallbackListener me, tObjectId, tHandlerName, tCallbackParams
  tNewListener = [#objectID: tObjectId, #handlerName: tHandlerName, #callbackParams: tCallbackParams]
  pListenerList.add(tNewListener)
end

on purgeCallbacks me, tSuccess
  tTimeoutName = "dyndownload" & the milliSeconds
  tCounter = 1
  repeat with tListener in pListenerList
    tObject = getObject(tListener[#objectID])
    tHandler = tListener[#handlerName]
    tCallbackParams = tListener[#callbackParams]
    if (tObject <> 0) and symbolp(tHandler) then
      createTimeout(tTimeoutName & tCounter, 10, #sendTimeoutCallbacks, me.getID(), [tHandler, tObject, pAssetId, tSuccess, tCallbackParams], 1)
    else
      error(me, "Object or handler invalid:" && tObject && tHandler, #purgeCallbacks, #minor)
    end if
    tCounter = tCounter + 1
  end repeat
  pListenerList = []
end

on setAssetId me, tAssetId
  pAssetId = tAssetId
end

on getAssetId me
  return pAssetId
end

on setAssetType me, tAssetType
  pAssetType = tAssetType
end

on getAssetType me
  return pAssetType
end

on setDownloadName me, tURL
  pDownloadURL = tURL
end

on getDownloadName me
  tOffset = offset("?", pDownloadURL)
  if tOffset then
    tDownloadURLNoParams = pDownloadURL.char[1..tOffset - 1]
  else
    tDownloadURLNoParams = pDownloadURL
  end if
  return tDownloadURLNoParams
end

on setIndexing me, tAllowIndexing
  pAllowindexing = tAllowIndexing
end

on getIndexing me
  return pAllowindexing
end

on setParentId me, tParentId
  pParentId = tParentId
end

on getParentId me
  return pParentId
end

on sendTimeoutCallbacks me, tArguments
  call(tArguments[1], tArguments[2], tArguments[3], tArguments[4], tArguments[5])
end
