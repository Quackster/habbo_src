property pCallbackObj, pCallbackMethod, pCallbackList, pDynamicDownloader, pImageLibraryURL, pAssetLoadingList

on construct me
  pCallbackObj = VOID
  pCallbackMethod = VOID
  pDynamicDownloader = VOID
  pImageLibraryURL = getVariable("image.library.url")
  pCallbackList = []
  pAssetLoadingList = []
end

on deconstruct me
end

on isAssetDownloading me, tAssetId
  return pAssetLoadingList.getPos(tAssetId) <> 0
end

on defineCallback me, tCallBackObj, tMethod
  tCallbackObjId = tCallBackObj.getID()
  tCallbackReg = 1
  repeat with tCallback in pCallbackList
    if (tCallback[#obj] = tCallbackObjId) and (tCallback[#method] = tMethod) then
      tCallbackReg = 0
    end if
  end repeat
  if tCallbackReg then
    pCallbackList.add([#obj: tCallbackObjId, #method: tMethod])
  end if
end

on removeCallback me, tCallBackObj, tMethod
  tCallbackObjId = tCallBackObj.getID()
  i = 1
  repeat while i <= pCallbackList.count
    tCallback = pCallbackList[i]
    if (tCallback[#obj] = tCallbackObjId) and (tCallback[#method] = tMethod) then
      pCallbackList.deleteAt(i)
      next repeat
    end if
    i = i + 1
  end repeat
end

on callbackExists me, tCallBackObj, tMethod
  tCallbackObjId = tCallBackObj.getID()
  repeat with tCallback in pCallbackList
    if (tCallback[#obj] = tCallbackObjId) and (tCallback[#method] = tMethod) then
      return 1
    end if
  end repeat
  return 0
end

on registerDownload me, ttype, tAssetId, tProps
  if voidp(pDynamicDownloader) then
    pDynamicDownloader = getThread(#dynamicdownloader).getComponent()
  end if
  tProps = [#type: ttype, #assetId: tAssetId, #props: tProps]
  if ttype = #bitmap then
    tSourceURL = pImageLibraryURL & "catalogue/" & tAssetId & ".gif"
    tMemNum = queueDownload(tSourceURL, tAssetId, #bitmap, 1)
    if tMemNum > 0 then
      registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tProps)
      pAssetLoadingList.add(tAssetId)
    end if
  else
    if ttype = #topStoryImage then
      tSourceURL = pImageLibraryURL & "Top_Story_Images/" & tAssetId & ".gif"
      tMemNum = queueDownload(tSourceURL, tAssetId, #bitmap, 1)
      if tMemNum > 0 then
        registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tProps)
        pAssetLoadingList.add(tAssetId)
      end if
    else
      if ttype = #furni then
        pDynamicDownloader.downloadCastDynamically(tAssetId, #Active, me.getID(), #downloadCallback, 1, tProps)
        pAssetLoadingList.add(tAssetId)
      else
        if ttype = #soundset then
        end if
      end if
    end if
  end if
end

on downloadCallback me, tName, tSuccess, tProps
  if tSuccess then
    if ilk(tName) = #propList then
      tProps = tName
    end if
    repeat with tCallback in pCallbackList
      if objectExists(tCallback[#obj]) then
        call(tCallback[#method], getObject(tCallback[#obj]), tProps)
      end if
    end repeat
    pAssetLoadingList.deleteOne(tProps[#assetId])
  end if
end
