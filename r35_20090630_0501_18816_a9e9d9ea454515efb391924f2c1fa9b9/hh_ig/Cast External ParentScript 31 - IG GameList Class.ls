property pListMaxCount, pObservedGameObj, pJoinedGameObj, pPendingObservedGameId

on construct me
  pListMaxCount = 50
  pObservedGameObj = VOID
  pJoinedGameObj = VOID
  pPendingObservedGameId = -1
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG GameInstanceData Class"]
  me.pTimeoutUpdates = 1
  me.pHiddenUpdates = 0
  return 1
end

on deconstruct me
  pObservedGameObj = VOID
  pJoinedGameObj = VOID
  return me.ancestor.deconstruct()
end

on Initialize me
  me.pollContentUpdate()
  return me.registerForIGComponentUpdates("LevelList")
end

on storeGameInstance me, tInstanceData
  if not listp(tInstanceData) then
    return 0
  end if
  if tInstanceData.findPos(#id) = 0 then
    return 0
  end if
  tGameId = tInstanceData.getaProp(#id)
  if tGameId = me.getJoinedGameId() then
    me.storeJoinedGameInstance(tInstanceData)
  else
    me.storeObservedGameInstance(tInstanceData)
  end if
  if tGameId = pPendingObservedGameId then
    pPendingObservedGameId = -1
  end if
  return 1
end

on storeObservedGameInstance me, tdata
  if not listp(tdata) then
    return me.setObservedGameId(-1)
  end if
  tGameId = tdata.getaProp(#id)
  tGameRef = me.getGameEntry(tGameId)
  if objectp(tGameRef) then
    pObservedGameObj = tGameRef
    pObservedGameObj.Refresh(tdata)
  else
    if pObservedGameObj = 0 then
      pObservedGameObj = me.getNewListItemObject()
      if pObservedGameObj = 0 then
        return 0
      end if
    end if
    pObservedGameObj.Refresh(tdata)
  end if
  if pObservedGameObj <> 0 then
    me.announceUpdate(tGameId)
  end if
  if me.getActiveFlag() then
    if pPendingObservedGameId > -1 then
      me.renderUI("List")
    end if
  end if
  return 1
end

on addUserToGame me, tdata
  tGameId = tdata.getaProp(#game_id)
  tGameRef = me.getGameEntry(tGameId)
  if tGameRef = 0 then
    return 0
  end if
  if tGameRef.addUserToGame(tdata) then
    if tdata.getaProp(#name) = me.getOwnPlayerName() then
      pJoinedGameObj = tGameRef
    end if
  end if
  return 1
end

on storeJoinedGameInstance me, tdata
  if objectp(pJoinedGameObj) then
    tNotOwnerAlready = not pJoinedGameObj.checkIfOwnerOfGame()
  end if
  if listp(tdata) then
    tGameId = tdata.getaProp(#id)
    tGameRef = me.getGameEntry(tGameId)
    if objectp(tGameRef) then
      pJoinedGameObj = tGameRef
    else
      if pJoinedGameObj = 0 then
        pJoinedGameObj = me.getNewListItemObject()
        if pJoinedGameObj = 0 then
          return 0
        end if
      end if
    end if
    if pJoinedGameObj <> 0 then
      pJoinedGameObj.Refresh(tdata)
      me.announceUpdate(tGameId)
    end if
  else
    pJoinedGameObj = 0
  end if
  tComponent = me.getComponent()
  if tComponent.getSystemState() <> #ready then
    return 1
  end if
  if not objectp(pJoinedGameObj) then
    me.getInterface().resetToDefaultAndHide()
    me.getHandler().send_ROOM_GAME_STATUS(0)
  else
    tActiveMode = tComponent.getActiveIGComponentId()
    if (tNotOwnerAlready = 1) and pJoinedGameObj.checkIfOwnerOfGame() then
      me.announceUpdate(#owner_of_game)
    end if
  end if
  return 1
end

on removeGameInstance me, tGameId
  if voidp(tGameId) then
    return 0
  end if
  if tGameId = pPendingObservedGameId then
    pPendingObservedGameId = -1
  end if
  me.removeListEntry(tGameId)
  if objectp(pJoinedGameObj) then
    if pJoinedGameObj.getItemId() = tGameId then
      me.storeJoinedGameInstance(0)
      if not objectp(pObservedGameObj) then
        me.setObservedGameId(-1)
      end if
    end if
  end if
  if objectp(pObservedGameObj) then
    if pObservedGameObj.getItemId() = tGameId then
      pObservedGameObj = 0
      me.setObservedGameId(-1)
    end if
  end if
  return 1
end

on storeGameList me, tdata
  tdata = tdata.getaProp(#list)
  if not listp(tdata) then
    return 0
  end if
  tPurgeList = me.pListIndex.duplicate()
  repeat with i = 1 to tdata.count
    tPurgeList.deleteOne(tdata[i].getaProp(#id))
  end repeat
  repeat with tID in tPurgeList
    me.removeListEntry(tID)
  end repeat
  me.pListIndex = []
  repeat with tInstanceData in tdata
    tItemID = tInstanceData.getaProp(#id)
    if me.pListIndex.findPos(tItemID) = 0 then
      me.pListIndex.append(tItemID)
    end if
    if me.pListData.findPos(tItemID) = 0 then
      if tItemID = me.getJoinedGameId() then
        me.pJoinedGameObj.Refresh(tInstanceData)
        me.pListData.setaProp(tItemID, me.pJoinedGameObj)
        next repeat
      end if
      if tItemID = me.getObservedGameId() then
        me.pObservedGameObj.Refresh(tInstanceData)
        me.pListData.setaProp(tItemID, me.pObservedGameObj)
        next repeat
      end if
      me.updateListItemObject(tInstanceData)
    end if
  end repeat
  me.setUpdateTimestamp()
  me.announceUpdate(me.pListIndex)
  if me.getObservedGameId() = -1 then
    me.setObservedGameId(-1)
  end if
  return me.renderUI("List")
end

on removeUserFromGame me, tdata
  tGameId = tdata.getaProp(#game_id)
  tPlayerId = tdata.getaProp(#id)
  tGameRef = me.getGameEntry(tGameId)
  if tGameRef = 0 then
    return 0
  end if
  tPlayer = tGameRef.getPlayerById(tPlayerId)
  if tPlayer = 0 then
    return 0
  end if
  tGameRef.removeUserFromGame(tdata)
  if tPlayer.getaProp(#name) = me.getOwnPlayerName() then
    me.storeJoinedGameInstance(0)
    pObservedGameObj = VOID
    me.setObservedGameId(tGameId)
    if me.getComponent().getSystemState() = #ready then
      me.getInterface().ChangeWindowView("GameList")
    end if
    if tdata.getaProp(#was_kicked) then
      me.getInterface().showBasicAlert("ig_error_kicked")
    end if
  end if
  return 1
end

on getJoinedGame me
  return pJoinedGameObj
end

on getJoinedGameId me
  if pJoinedGameObj = 0 then
    return -1
  end if
  return pJoinedGameObj.getItemId()
end

on joinTeamWithLeastMembers me, tGameId
  if me.getHandler().send_JOIN_GAME(tGameId, -1) then
    pJoinedGameObj = me.getGameEntry(tGameId)
    return 1
  else
    return 0
  end if
end

on leaveJoinedGame me, tKeepObserving
  if not tKeepObserving then
    me.getInterface().resetToDefaultAndHide()
  end if
  if objectp(pJoinedGameObj) then
    if pJoinedGameObj.getPlayerCount() = 1 then
    else
      if tKeepObserving = 1 then
        me.setObservedGameId(pJoinedGameObj.getProperty(#id))
      end if
    end if
    me.getHandler().send_LEAVE_GAME()
  end if
  return 1
end

on setJoinedGameId me, tGameId, tTeamIndex
  if voidp(tGameId) or (tGameId = -1) then
    return 0
  end if
  if me.getHandler().send_JOIN_GAME(tGameId, tTeamIndex) then
    pJoinedGameObj = me.getGameEntry(tGameId)
    return 1
  else
    return 0
  end if
end

on setNextTeamInJoinedGame me
  tGameRef = me.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tTeamIndex = tGameRef.getOwnPlayerTeam()
  tTeamCount = tGameRef.getTeamCount()
  if tTeamIndex < tTeamCount then
    tTeamIndex = tTeamIndex + 1
  else
    tTeamIndex = 1
  end if
  return me.getHandler().send_JOIN_GAME(tGameRef.getItemId(), tTeamIndex)
end

on getObservedGame me
  return pObservedGameObj
end

on getObservedGameId me
  if pObservedGameObj = 0 then
    return -1
  end if
  return pObservedGameObj.getItemId()
end

on setObservedGameId me, tGameId
  tCurrentId = me.getObservedGameId()
  if voidp(tGameId) or (tGameId = -1) then
    pObservedGameObj = 0
    if me.getActiveFlag() then
      tNewDefault = me.getObservedGameDefault()
      if (tCurrentId = -1) and (tNewDefault = -1) then
        me.renderUI()
        return 1
      end if
      if tCurrentId = -1 then
        return me.setObservedGameId(tNewDefault)
      end if
      me.renderUI()
    else
      if tCurrentId = -1 then
        return 1
      end if
    end if
    return me.getHandler().send_STOP_OBSERVING_GAME(tCurrentId)
  else
    if not me.getActiveFlag() then
      return 1
    end if
    if tGameId = pPendingObservedGameId then
      return 1
    end if
    pObservedGameObj = me.getGameEntry(tGameId)
    pPendingObservedGameId = tGameId
    return me.getHandler().send_START_OBSERVING_GAME(tGameId, 1)
  end if
end

on setObservedGameIdExplicit me, tGameId
  tCurrentId = me.getObservedGameId()
  if tGameId = tCurrentId then
    return 1
  end if
  if tGameId = pPendingObservedGameId then
    return 1
  end if
  pObservedGameObj = me.getGameEntry(tGameId)
  pPendingObservedGameId = tGameId
  return me.getHandler().send_START_OBSERVING_GAME(tGameId, 1)
end

on pollContentUpdate me, tForced
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return 0
  end if
  if not tForced and not me.isUpdateTimestampExpired() then
    return 0
  end if
  me.setUpdateTimestamp()
  return tMainThread.getHandler().send_GET_GAME_LIST(0, pListMaxCount)
end

on handleUpdate me, tUpdateId, tSenderId
  case tSenderId of
    "LevelList":
      tItemRef = me.getObservedGame()
      if tItemRef <> 0 then
        if tUpdateId = tItemRef.getProperty(#level_id) then
          return me.renderUI()
        end if
      end if
    "GameList":
      if tUpdateId = me.getObservedGameId() then
        return me.resetSubComponent("Details")
      else
        return me.renderUI("List")
      end if
  end case
  return 1
end

on setActiveFlag me, tstate, tHoldUpdates
  me.ancestor.setActiveFlag(tstate, tHoldUpdates)
  if me.getActiveFlag() then
    me.setObservedGameId(me.getObservedGameId())
  else
    me.setObservedGameId(-1)
  end if
  return 1
end

on getGameEntry me, tID
  tItemRef = me.ancestor.getListEntry(tID)
  if tItemRef <> 0 then
    return tItemRef
  end if
  if me.getJoinedGameId() = tID then
    return me.getJoinedGame()
  end if
  if me.getObservedGameId() = tID then
    return me.getObservedGame()
  end if
  return 0
end

on getObservedGameDefault me
  if me.getJoinedGameId() = -1 then
    return me.getListIdByIndex(1)
  else
    return me.getJoinedGameId()
  end if
end

on getMainListIds me, tPageSize
  tJoinedGameId = me.getJoinedGameId()
  tFirst = 1
  tLast = tFirst + tPageSize - 1
  tList = []
  if tJoinedGameId > -1 then
    tList.append(tJoinedGameId)
    tLast = tLast - 1
  end if
  repeat with i = tFirst to tLast
    if i <= me.pListData.count then
      tGameId = me.pListData.getPropAt(i)
      if tGameId <> tJoinedGameId then
        tList.append(me.pListData.getPropAt(i))
        next repeat
      end if
      tLast = tLast + 1
    end if
  end repeat
  return tList
end
