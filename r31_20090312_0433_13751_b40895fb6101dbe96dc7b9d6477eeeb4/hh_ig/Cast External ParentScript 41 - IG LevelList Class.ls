property pSelectedLevelId, pInviteMaxCount, pInviteSentData

on construct me
  pSelectedLevelId = -1
  pInviteMaxCount = 5
  pInviteSentData = [:]
  me.pTimeoutUpdates = 0
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on Initialize me
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG LevelInstanceData Class"]
  me.pollContentUpdate()
end

on storeLevelListInfo me, tLevelData
  me.storeNewList(tLevelData, 0)
  if me.getSelectedLevelId() = -1 then
    me.selectLevel(me.getListIdByIndex(1), 1)
  end if
  return 1
end

on getMainListIds me, tPageSize
  tFirst = 1
  tLast = tFirst + tPageSize - 1
  tList = []
  repeat with i = tFirst to tLast
    if i <= me.pListIndex.count then
      tList.append(me.pListIndex[i])
    end if
  end repeat
  return tList
end

on createGame me
  tLevelItem = me.getSelectedLevel()
  if tLevelItem = 0 then
    return 0
  end if
  tTypeService = me.getIGComponent("GameTypes")
  tGameParams = tTypeService.convertGamePropsForCreate(tLevelItem.getProperty(#game_type), tLevelItem.dump())
  if tGameParams = 0 then
    return 0
  end if
  executeMessage(#sendTrackingPoint, "/game/created")
  put pSelectedLevelId && tGameParams
  return me.getHandler().send_CREATE_GAME(string(pSelectedLevelId), tGameParams)
end

on selectLevel me, tLevelId, tRenderFlag
  if voidp(tLevelId) then
    tLevelId = -1
  end if
  pSelectedLevelId = tLevelId
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.resetSubComponent("Details")
  tRenderObj.setViewMode(#Info)
  return 1
end

on getSelectedLevelId me
  return pSelectedLevelId
end

on getSelectedLevel me
  tItemRef = me.getListEntry(pSelectedLevelId)
  if tItemRef = 0 then
    return error(me, "No selected level item!" && pSelectedLevelId, #getSelectedLevel)
  end if
  return tItemRef
end

on getRemInviteCount me
  return pInviteMaxCount - pInviteSentData.count
end

on setProperty me, tKey, tValue
  tLevelRef = me.getSelectedLevel()
  if tLevelRef = 0 then
    return 0
  end if
  tLevelRef.setProperty(tKey, tValue)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.renderProperty(tKey, tLevelRef.getProperty(tKey))
  return 1
end

on handleUpdate me, tUpdateId, tSenderId
  case tSenderId of
    "LevelList":
      tItemRef = me.getSelectedLevel()
      if tItemRef <> 0 then
        if tUpdateId = tItemRef.getProperty(#id) then
          return me.renderUI()
        end if
      end if
  end case
  return 1
end

on pollContentUpdate me, tForced
  if not tForced and not me.isUpdateTimestampExpired() then
    return 0
  end if
  me.setUpdateTimestamp()
  return me.getHandler().send_GET_CREATE_GAME_INFO()
end
