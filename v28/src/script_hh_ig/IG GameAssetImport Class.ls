property pAssetsLoaded, pState, pUpdateCounter, pCastLoadIdList, pCurrentLoadedCasts

on construct me 
  pCurrentLoadedCasts = []
  pCastLoadIdList = []
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  pAssetsLoaded = 0
  pState = 0
  return TRUE
end

on deconstruct me 
  unregisterMessage(#leaveRoom, me.getID())
  if pAssetsLoaded then
    me.unloadAssets()
  end if
  pState = 0
  return(me.ancestor.deconstruct())
end

on leaveRoom me 
  if pAssetsLoaded then
    me.unloadAssets()
  end if
  return TRUE
end

on update me 
  if (pState = 0) then
    return(removeUpdate(me.getID()))
  end if
  pUpdateCounter = (pUpdateCounter + 1)
  if pUpdateCounter < 5 then
    return TRUE
  end if
  pUpdateCounter = 0
  me.roomCastsProgress()
  return TRUE
end

on startCastDownload me, tdata 
  put(me.getID() && "startCastDownload")
  if not listp(tdata) then
    return FALSE
  end if
  tGameType = tdata.getaProp(#game_type)
  tGameTypeService = me.getIGComponent("GameTypes")
  if (tGameTypeService = 0) then
    return FALSE
  end if
  tCastList = tGameTypeService.getAction(tGameType, #get_casts)
  if (tCastList = 0) then
    return FALSE
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
  return TRUE
end

on roomCastsProgress me, tParam1, tParam2 
  tLoadingStatus = me.getLoadingStatus()
  if (tLoadingStatus = 1) then
    return(me.roomCastsLoaded())
  end if
  tHandler = me.getHandler()
  if (tHandler = 0) then
    return FALSE
  end if
  tHandler.send_LOAD_STAGE_READY(tLoadingStatus)
  return TRUE
end

on roomCastsLoaded me, tParam1, tParam2 
  if me.getLoadingStatus() < 1 then
    return TRUE
  end if
  pState = 0
  removeUpdate(me.getID())
  tHandler = me.getHandler()
  if (tHandler = 0) then
    return FALSE
  end if
  tHandler.send_LOAD_STAGE_READY(1)
  return TRUE
end

on queueAssetList me, tAssetData 
  return TRUE
end

on cancelLoading me 
  if not pAssetsLoaded then
    return TRUE
  end if
  put("* TODO: IG GameAssetImport Class.cancelLoading")
  return TRUE
end

on getLoadingStatus me 
  if not pAssetsLoaded then
    return FALSE
  end if
  if (pCastLoadIdList.count = 0) then
    return TRUE
  end if
  tAverage = 0
  repeat while pCastLoadIdList <= undefined
    tCastLoadId = getAt(undefined, undefined)
    tAverage = (getCastLoadPercent(tCastLoadId) + tAverage)
  end repeat
  tAverage = (tAverage / pCastLoadIdList.count)
  return(tAverage)
end

on unloadAssets me 
  return TRUE
  if not pAssetsLoaded then
    return TRUE
  end if
  pAssetsLoaded = 0
  tFinishedList = []
  repeat while pCurrentLoadedCasts.count > 0
    tCastName = pCurrentLoadedCasts.getAt(1)
    if tFinishedList.getPos(tCastName) > 0 then
      return(error(me, "Unable to unload castlib" && tCastName, #unloadAssets))
    end if
    me.unloadOneCast(tCastName)
    tFinishedList.append(tCastName)
  end repeat
  return TRUE
end

on unloadOneCast me, tCastName 
  put("* unloadOneCast" && tCastName)
  tManager = getCastLoadManager()
  if (tManager = 0) then
    return FALSE
  end if
  if not castExists(tCastName) then
    return(error(me, "Cast does not exist:" && tCastName, #unloadOneCast))
  end if
  tCastLib = castLib(tCastName)
  tCastNum = tCastLib.number
  if (tCastLib.number = 0) then
    return TRUE
  end if
  tResetOk = tManager.ResetOneDynamicCast(tCastNum)
  if not tResetOk then
    error(me, "Cast reset failed:" && tCastNum, #unloadOneCast, #major)
  end if
  pCurrentLoadedCasts.deleteOne(tCastName)
  if (pCurrentLoadedCasts.count = 0) then
    pAssetsLoaded = 0
  end if
  return TRUE
end

on createLoadingBar me 
  return TRUE
end

on updateLoadingBarOwnDownload me 
  tStatus = me.getLoadingStatus()
  put("* updateLoadingBarOwnLownload status:" && tStatus)
  return TRUE
end

on updateLoadingBarOtherItems me 
  return TRUE
end

on removeLoadingBar me 
  return TRUE
end

on sendLoadingStatus me 
  return TRUE
end
