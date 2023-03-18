property pState, pAssetsLoaded, pAssetData, pCurrentLoadedCasts, pUpdateCounter, pCastLoadIdList

on construct me
  pCurrentLoadedCasts = []
  pCastLoadIdList = []
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  pAssetsLoaded = 0
  pState = 0
  return 1
end

on deconstruct me
  unregisterMessage(#leaveRoom, me.getID())
  if pAssetsLoaded then
    me.unloadAssets()
  end if
  pState = 0
  return me.ancestor.deconstruct()
end

on leaveRoom me
  if pAssetsLoaded then
    me.unloadAssets()
  end if
  return 1
end

on update me
  if pState = 0 then
    return removeUpdate(me.getID())
  end if
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter < 5 then
    return 1
  end if
  pUpdateCounter = 0
  me.roomCastsProgress()
  return 1
end

on startCastDownload me, tdata
  put me.getID() && "startCastDownload"
  if not listp(tdata) then
    return 0
  end if
  tGameType = tdata.getaProp(#game_type)
  tGameTypeService = me.getIGComponent("GameTypes")
  if tGameTypeService = 0 then
    return 0
  end if
  tCastList = tGameTypeService.getAction(tGameType, #get_casts)
  if tCastList = 0 then
    return 0
  end if
  tRoomCastVarPrefix = "room.cast."
  tRoomCastList = getObject(#room_component).addToCastDownloadList(tRoomCastVarPrefix)
  if tRoomCastList.count > 0 then
    pAssetsLoaded = 1
    tCastLoadId = startCastLoad(tRoomCastList, 1)
    pCastLoadIdList.append(tCastLoadId)
    pState = #LOADING
    receiveUpdate(me.getID())
  end if
  if not listp(tCastList) then
    tCastList = list(tCastList)
  end if
  if tCastList.count > 0 then
    pAssetsLoaded = 1
    tCastLoadId = startCastLoad(tCastList, 0)
    pCastLoadIdList.append(tCastLoadId)
    registerCastloadCallback(tCastLoadId, #roomCastsLoaded, me.getID())
    pState = #LOADING
    receiveUpdate(me.getID())
  end if
  return 1
end

on roomCastsProgress me, tParam1, tParam2
  tLoadingStatus = me.getLoadingStatus()
  if tLoadingStatus = 1.0 then
    return me.roomCastsLoaded()
  end if
  tHandler = me.getHandler()
  if tHandler = 0 then
    return 0
  end if
  tHandler.send_LOAD_STAGE_READY(tLoadingStatus)
  return 1
end

on roomCastsLoaded me, tParam1, tParam2
  if me.getLoadingStatus() < 1 then
    return 1
  end if
  pState = 0
  removeUpdate(me.getID())
  tHandler = me.getHandler()
  if tHandler = 0 then
    return 0
  end if
  tHandler.send_LOAD_STAGE_READY(1)
  return 1
end

on queueAssetList me, tAssetData
  return 1
end

on cancelLoading me
  if not pAssetsLoaded then
    return 1
  end if
  put "* TODO: IG GameAssetImport Class.cancelLoading"
  return 1
end

on getLoadingStatus me
  if not pAssetsLoaded then
    return 0
  end if
  if pCastLoadIdList.count = 0 then
    return 1
  end if
  tAverage = 0
  repeat with tCastLoadId in pCastLoadIdList
    tAverage = getCastLoadPercent(tCastLoadId) + tAverage
  end repeat
  tAverage = tAverage / pCastLoadIdList.count
  return tAverage
end

on unloadAssets me
  return 1
  if not pAssetsLoaded then
    return 1
  end if
  pAssetsLoaded = 0
  tFinishedList = []
  repeat while pCurrentLoadedCasts.count > 0
    tCastName = pCurrentLoadedCasts[1]
    if tFinishedList.getPos(tCastName) > 0 then
      return error(me, "Unable to unload castlib" && tCastName, #unloadAssets)
    end if
    me.unloadOneCast(tCastName)
    tFinishedList.append(tCastName)
  end repeat
  return 1
end

on unloadOneCast me, tCastName
  put "* unloadOneCast" && tCastName
  tManager = getCastLoadManager()
  if tManager = 0 then
    return 0
  end if
  if not castExists(tCastName) then
    return error(me, "Cast does not exist:" && tCastName, #unloadOneCast)
  end if
  tCastLib = castLib(tCastName)
  tCastNum = tCastLib.number
  if tCastLib.number = 0 then
    return 1
  end if
  tResetOk = tManager.ResetOneDynamicCast(tCastNum)
  if not tResetOk then
    error(me, "Cast reset failed:" && tCastNum, #unloadOneCast, #major)
  end if
  pCurrentLoadedCasts.deleteOne(tCastName)
  if pCurrentLoadedCasts.count = 0 then
    pAssetsLoaded = 0
  end if
  return 1
end

on createLoadingBar me
  return 1
end

on updateLoadingBarOwnDownload me
  tStatus = me.getLoadingStatus()
  put "* updateLoadingBarOwnLownload status:" && tStatus
  return 1
end

on updateLoadingBarOtherItems me
  return 1
end

on removeLoadingBar me
  return 1
end

on sendLoadingStatus me
  return 1
end
