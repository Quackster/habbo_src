property pSkillLevelChangeNoticeWindowID

on construct me 
  pSkillLevelChangeNoticeWindowID = "gamesys_skilllevel_announcement"
  pTurnManagerState = 0
  pDownloadMgrs = [:]
  registerMessage(#roomReady, me.getID(), #checkIfInGameArea)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#spectatorMode_on, me.getID(), #store_spectatorMode_on)
  registerMessage(#spectatorMode_off, me.getID(), #store_spectatorMode_off)
  return TRUE
end

on deconstruct me 
  if windowExists(pSkillLevelChangeNoticeWindowID) then
    removeWindow(pSkillLevelChangeNoticeWindowID)
  end if
  me.stopTurnManager()
  pDownloadMgrs = [:]
  if memberExists("gsys_tournamentlogo") then
    removeMember("gsys_tournamentlogo")
  end if
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#spectatorMode_on, me.getID())
  unregisterMessage(#spectatorMode_off, me.getID())
  return TRUE
end

on defineClient me, tid 
  me.initVariables()
end

on leaveRoom me 
  me.stopTurnManager()
  me.getMessageSender().setInstanceListUpdates(0)
  me.initVariables()
  return TRUE
end

on initVariables me 
  tVarMgr = me.getVariableManager()
  if (tVarMgr = 0) then
    return TRUE
  end if
  tVarMgr.set(#game_status, #none)
  tVarMgr.set(#game_location, [:])
  tVarMgr.set(#instancelist, [:])
  tVarMgr.set(#observed_instance_data, [:])
  tVarMgr.set(#spectatormode_flag, 0)
  tVarMgr.set(#tournament_flag, 0)
  return TRUE
end

on getGamestatus me 
  tVarMgr = me.getVariableManager()
  if (tVarMgr = 0) then
    return FALSE
  end if
  if (tVarMgr.exists(#game_status) = 0) then
    return FALSE
  end if
  return(tVarMgr.GET(#game_status))
end

on startTurnManager me 
  return(me.getTurnManager().StartMinigameEngine())
end

on stopTurnManager me 
  return(me.getTurnManager().stopMinigameEngine())
end

on cancelCreateGame me 
  me.getVariableManager().set(#game_status, #none)
  return(me.getMessageSender().setInstanceListUpdates(1))
end

on enterLounge me 
  if not getObject(#session).exists(#gamelounge_world_info) then
    return FALSE
  end if
  tLoungeData = getObject(#session).GET(#gamelounge_world_info)
  if not listp(tLoungeData) then
    return FALSE
  end if
  executeMessage(#changeRoom)
  return(me.spaceTravel(tLoungeData.getAt(#unitId), tLoungeData.getAt(#worldId), tLoungeData.getAt(#type)))
end

on checkIfInGameArea me 
  if not getObject(#session).exists("lastroom") then
    return FALSE
  end if
  tRoomData = getObject(#session).GET("lastroom")
  if not getObject(#session).exists(#gamespace_world_info) then
    return FALSE
  end if
  tGameSpaceData = getObject(#session).GET(#gamespace_world_info)
  if (tRoomData.getAt(#port) = tGameSpaceData.getAt(#unitId)) and (tRoomData.getAt(#door) = tGameSpaceData.getAt(#worldId)) then
    return TRUE
  else
    return FALSE
  end if
end

on store_loungeinfo me, tdata 
  if tdata.getAt(#tournament_logo_url) <> void() then
    me.getVariableManager().set(#tournament_flag, 1)
    if memberExists("gsys_tournamentlogo") then
      removeMember("gsys_tournamentlogo")
    end if
    tAdMemNum = queueDownload(tdata.getAt(#tournament_logo_url), "gsys_tournamentlogo", #bitmap, 1)
    registerDownloadCallback(tAdMemNum, #store_tournamentlogo_member, me.getID(), [#member_num:tAdMemNum, #click_url:tdata.getAt(#tournament_logo_click_url)])
    if (tAdMemNum = 0) then
      error(me, "Gamesystem cannot initialize download manager!", #store_loungeinfo)
    end if
  end if
  me.getVariableManager().set(#game_status, #none)
  me.getMessageSender().setInstanceListUpdates(1)
  if (getObject(#session) = 0) then
    return FALSE
  end if
  tWorldData = getObject(#session).GET("lastroom")
  if not listp(tWorldData) then
    return FALSE
  end if
  getObject(#session).set(#gamelounge_world_info, [#unitId:tWorldData.getAt(#port), #worldId:tWorldData.getAt(#door), #type:tWorldData.getAt(#type)])
  getObject(#session).Remove(#gamespace_world_info)
  return TRUE
end

on store_tournamentlogo_member me, tdata 
  me.getProcManager().distributeEvent(#tournamentlogo, tdata)
  return TRUE
end

on store_instancelist me, tList 
  if (tList = 0) then
    tList = [:]
  end if
  tVarMgr = me.getVariableManager()
  if (tVarMgr = 0) then
    return FALSE
  end if
  tVarMgr.set(#instancelist, tList)
  tVarMgr.set(#instancelist_timestamp, the milliSeconds)
end

on store_gameinstance me, tItem 
  me.getMessageSender().setInstanceListUpdates(0)
  me.getVariableManager().set(#observed_instance_data, tItem)
  tInstanceList = me.getVariableManager().GET(#instancelist)
  tInstanceList.setAt(string(tItem.getAt(#id)), tItem)
  me.getVariableManager().set(#instancelist, tInstanceList)
  if (me.getGamestatus() = #watch_requested) then
    me.getVariableManager().set(#game_status, #watch_confirmed)
    return(me.getProcManager().distributeEvent(#watchok))
  end if
  if (me.getGamestatus() = #join_requested) then
    me.getVariableManager().set(#game_status, #join_confirmed)
    return(me.getProcManager().distributeEvent(#joinok))
  end if
  if (me.getGamestatus() = #create_requested) then
    me.getVariableManager().set(#game_status, #create_confirmed)
    return(me.getProcManager().distributeEvent(#createok))
  end if
  return TRUE
end

on store_gameparameters me, tParamList 
  me.getVariableManager().set(#gameparametervalues_format, tParamList)
end

on store_createfailed me, tReason 
  me.getVariableManager().set(#game_status, #none)
  me.getMessageSender().setInstanceListUpdates(1)
end

on store_gamedeleted me, tInstanceId 
  tInstanceList = me.getVariableManager().GET(#instancelist)
  tInstanceList.deleteProp(string(tInstanceId))
  me.getVariableManager().set(#instancelist, tInstanceList)
  me.getVariableManager().set(#observed_instance_data, [:])
  me.getVariableManager().set(#game_status, #none)
  me.getMessageSender().setInstanceListUpdates(1)
end

on store_joinparameters me, tParamList 
  me.getVariableManager().set(#joinparametervalues_format, tParamList)
end

on store_watchfailed me, tParamList 
  me.getVariableManager().set(#game_status, #observe_confirmed)
end

on store_gamelocation me, tParamList 
  executeMessage(#changeRoom)
  tVarMgr = me.getVariableManager()
  tVarMgr.set(#observed_instance_data, [:])
  tVarMgr.set(#game_status, #game_waiting_for_start)
  if (getObject(#session) = 0) then
    return FALSE
  end if
  tParamList.addProp(#tournament_flag, me.getVariableManager().GET(#tournament_flag))
  getObject(#session).set(#gamespace_world_info, tParamList)
  me.getMessageSender().setInstanceListUpdates(0)
  tUnitId = tParamList.getAt(#unitId)
  tWorldId = tParamList.getAt(#worldId)
  me.spaceTravel(tUnitId, tWorldId, #game)
end

on store_gamestatus me, tdata 
  if not listp(tdata) then
    return FALSE
  end if
  i = 1
  repeat while i <= tdata.count
    tElementId = tdata.getPropAt(i)
    me.getProcManager().distributeEvent(tdata.getPropAt(i), tdata.getAt(i))
    i = (1 + i)
  end repeat
  return TRUE
end

on store_gamestatus_turn me, tdata 
  if not objectp(tdata) then
    return FALSE
  end if
  return(me.getTurnManager().addTurnToBuffer(tdata))
end

on store_gamestart me, tdata 
  executeMessage(#game_started)
  return(me.getVariableManager().set(#game_status, #game_started))
end

on store_gameend me, tdata 
  executeMessage(#game_end)
  return(me.getVariableManager().set(#game_status, #game_waiting_for_restart))
end

on store_gamereset me, tdata 
  executeMessage(#game_reset)
  return(me.getVariableManager().set(#game_status, #game_waiting_for_start))
end

on store_spectatorMode_on me 
  return(me.getVariableManager().set(#spectatormode_flag, 1))
end

on store_spectatorMode_off me 
  return(me.getVariableManager().set(#spectatormode_flag, 0))
end

on store_skilllevelchanged me, tProps 
  tLevelName = tProps.getAt(#level)
  createWindow(pSkillLevelChangeNoticeWindowID, "habbo_simple.window")
  tWndObj = getWindow(pSkillLevelChangeNoticeWindowID)
  if (tWndObj = 0) then
    return(error(me, "Cannot create window", #store_skilllevelchanged))
  end if
  if not tWndObj.merge("habbo_games_levelup.window") then
    return(tWndObj.close())
  end if
  tElem = tWndObj.getElement("habbo_games_levelup_a")
  if tElem <> 0 then
    tElem.setText(getText("gs_skill_changed_header"))
  end if
  tElem = tWndObj.getElement("habbo_games_levelup_b")
  if tElem <> 0 then
    tElem.setText(replaceChunks(getText("gs_skill_changed"), "%1", tLevelName))
  end if
  tWndObj.registerProcedure(#eventProcSkillChange, me.getID(), #mouseUp)
  return TRUE
end

on eventProcSkillChange me, tSprID, tPar1, tPar2 
  return(removeWindow(pSkillLevelChangeNoticeWindowID))
end

on spaceTravel me, tUnitId, tWorldId, tWorldType 
  me.getMessageSender().setInstanceListUpdates(0)
  tPresentStruct = getObject(#session).GET("lastroom")
  if (tPresentStruct = 0) then
    tPresentStruct = [#name:tWorldId, #casts:[]]
  end if
  tStruct = [:]
  tStruct.setaProp(#id, tPresentStruct.getAt(#id))
  tStruct.setaProp(#name, tPresentStruct.getAt(#name))
  tStruct.setaProp(#type, tWorldType)
  tStruct.setaProp(#owner, 0)
  tStruct.setaProp(#teleport, 0)
  tStruct.setaProp(#door, tWorldId)
  tStruct.setaProp(#port, tUnitId)
  tStruct.setaProp(#casts, tPresentStruct.getAt(#casts))
  executeMessage(#enterRoomDirect, tStruct)
  return TRUE
end
