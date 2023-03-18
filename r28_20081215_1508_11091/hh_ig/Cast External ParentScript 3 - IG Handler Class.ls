on construct me
  me.regMsgList(1)
  return 1
end

on deconstruct me
  me.regMsgList(0)
  return 1
end

on send_CHECK_DIRECTORY_STATUS me
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  return tConn.send("IG_CHECK_DIRECTORY_STATUS")
end

on send_ROOM_GAME_STATUS me, tJoinedFlag, tGameId, tGameType
  if me.getComponent().getSystemState() <> #ready then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  if tJoinedFlag = 1 then
    return tConn.send("IG_ROOM_GAME_STATUS", [#integer: 1, #integer: tGameId, #integer: tGameType])
  else
    return tConn.send("IG_ROOM_GAME_STATUS", [#integer: 0])
  end if
end

on send_PLAY_AGAIN me
  tList = [:]
  tList["showDialog"] = 1
  executeMessage(#getHotelClosingStatus, tList)
  if tList["retval"] = 1 then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  return tConn.send("IG_PLAY_AGAIN")
end

on send_GET_LEVEL_HALL_OF_FAME me, tLevelId
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tLevelId = integer(tLevelId)
  if not integerp(tLevelId) then
    return 0
  end if
  return tConn.send("IG_GET_LEVEL_HALL_OF_FAME", [#integer: tLevelId])
end

on send_CREATE_GAME me, tLevelId, tGameParams
  tList = [:]
  tList["showDialog"] = 1
  executeMessage(#getHotelClosingStatus, tList)
  if tList["retval"] = 1 then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tParamList = [#string: tLevelId]
  repeat with i = 1 to tGameParams.count
    tValue = tGameParams[i]
    tParamList.addProp(ilk(tValue), tValue)
  end repeat
  return tConn.send("IG_CREATE_GAME", tParamList)
end

on send_GET_GAME_LIST me, tStartObservingFirstGame, tMaxResultCount
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tParams = [:]
  if tStartObservingFirstGame = VOID then
    tStartObservingFirstGame = 0
  end if
  tStartObservingFirstGame = tStartObservingFirstGame and (me.getComponent().getSystemState() = #ready)
  tParams.addProp(#integer, integer(tStartObservingFirstGame))
  tParams.addProp(#integer, integer(tMaxResultCount))
  tConn.send("IG_GET_GAME_LIST", tParams)
  return 1
end

on send_GET_CREATE_GAME_INFO me
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_GET_CREATE_GAME_INFO")
  return 1
end

on send_LIST_POSSIBLE_INVITEES me, tQuery
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tDefaultInviteMax = 10
  tConn.send("IG_LIST_POSSIBLE_INVITEES", [#integer: tQuery - 1, #integer: tDefaultInviteMax])
end

on send_INVITE_USER me, tUserName, tMessage
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_INVITE_USER", [#string: tUserName, #string: tMessage])
end

on send_KICK_USER me, tUserID
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_KICK_USER", [#integer: tUserID])
  return 1
end

on send_START_GAME me
  tList = [:]
  tList["showDialog"] = 1
  executeMessage(#getHotelClosingStatus, tList)
  if tList["retval"] = 1 then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_START_GAME")
  return 1
end

on send_JOIN_GAME me, tGameId, tTeamId
  tList = [:]
  tList["showDialog"] = 1
  executeMessage(#getHotelClosingStatus, tList)
  if tList["retval"] = 1 then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_JOIN_GAME", [#integer: tGameId, #integer: tTeamId])
  return 1
end

on send_LEAVE_GAME me
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_LEAVE_GAME")
  return 1
end

on send_START_OBSERVING_GAME me, tGameId, tLongData
  if me.getComponent().getSystemState() <> #ready then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_START_OBSERVING_GAME", [#integer: tGameId, #integer: tLongData])
  return 1
end

on send_STOP_OBSERVING_GAME me, tGameId
  if me.getComponent().getSystemState() <> #ready then
    return 0
  end if
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  if voidp(tGameId) then
    tGameId = me.getComponent().getIGComponent("GameList").getObservedGameId()
  end if
  if tGameId = -1 then
    return 0
  end if
  tConn.send("IG_STOP_OBSERVING_GAME", [#integer: tGameId])
  return 1
end

on send_ACCEPT_INVITE_REQUEST me, tGameId
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_ACCEPT_INVITE_REQUEST", [#integer: tGameId])
  return 1
end

on send_DECLINE_INVITE_REQUEST me, tGameId
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tConn.send("IG_DECLINE_INVITE_REQUEST", [#integer: tGameId])
  return 1
end

on send_LOAD_STAGE_READY me, tPercentage
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  tPercentage = integer(tPercentage * 100)
  tConn.send("IG_LOAD_STAGE_READY", [#integer: tPercentage])
  return 1
end

on send_EXIT_GAME me, tRedirectFlag
  executeMessage(#ig_clear_game_info)
  tConn = me.getGameConnection()
  if tConn = 0 then
    return 0
  end if
  if voidp(tRedirectFlag) then
    tRedirectFlag = 1
  end if
  tConn.send("IG_EXIT_GAME", [#integer: integer(tRedirectFlag)])
  return 1
end

on handle_directory_status me, tMsg
  tConn = tMsg.connection
  tCode = tConn.GetIntFrom()
  if tCode = 0 then
    return me.getComponent().getInitialData()
  end if
  error(me, "TODO: Directory not available, code:" && tCode, #handle_directory_status)
  return 1
end

on handle_ENTER_ARENA_FAILED me, tMsg
  tConn = tMsg.connection
  tCode = tConn.GetIntFrom()
  me.getInterface().showBasicAlert("ig_error_enter_arena_" & tCode)
  return 1
end

on handle_GAME_REJOIN me, tMsg
  tConn = tMsg.connection
  tTimeLeft = tConn.GetIntFrom()
  me.getComponent().displayIGComponentEvent("AfterGame", #time_to_next_state, tTimeLeft)
  return 1
end

on handle_player_exited_game_arena me, tMsg
  tConn = tMsg.connection
  tRoomIndex = tConn.GetIntFrom()
  tActiveMode = me.getComponent().getActiveIGComponentId()
  tGameDataService = me.getComponent().getIGComponent("GameData")
  if tGameDataService = 0 then
    return error(me, "Game data IGComponent not found.", #handle_game_ending)
  end if
  case tActiveMode of
    "PreGame":
      me.getComponent().displayIGComponentEvent(tActiveMode, #user_left_game, tRoomIndex)
    "AfterGame":
      tPlayerId = tGameDataService.getPlayerIdByRoomIndex(tRoomIndex)
      me.getComponent().displayIGComponentEvent(tActiveMode, #user_left_game, tPlayerId)
  end case
  tPlayerId = tGameDataService.getPlayerIdByRoomIndex(tRoomIndex)
  if tPlayerId <> -1 then
    executeMessage(#gamesystem_sendevent, #remove_game_object, [#id: tPlayerId])
  end if
  executeMessage(#ig_user_left_game, tRoomIndex)
  return 1
end

on handle_level_hall_of_fame me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#id, tConn.GetIntFrom())
  tdata.setaProp(#name, tConn.GetStrFrom())
  tNumTopLevelScores = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumTopLevelScores
    tPlayer = [:]
    tPlayer.setaProp(#name, tConn.GetStrFrom())
    tPlayer.setaProp(#score, tConn.GetIntFrom())
    tList.append(tPlayer)
  end repeat
  tdata.setaProp(#top_level_scores, tList)
  tNumLevelTeamScores = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumLevelTeamScores
    tItem = [:]
    tItem.setaProp(#score, tConn.GetIntFrom())
    tNumPlayers = tConn.GetIntFrom()
    tPlayers = []
    repeat with j = 1 to tNumPlayers
      tPlayers.append(tConn.GetStrFrom())
    end repeat
    tItem.setaProp(#players, tPlayers)
    tList.append(tItem)
  end repeat
  tdata.setaProp(#level_team_scores, tList)
  tdata.setaProp(#score_data_pending, 0)
  tService = me.getComponent().getIGComponent("LevelList")
  if tService = 0 then
    return 0
  end if
  tService.updateEntry(tdata)
  return 1
end

on handle_start_failed me, tMsg
  tConn = tMsg.connection
  tCode = tConn.GetIntFrom()
  me.getInterface().showBasicAlert("ig_error_start_failed_" & tCode)
  return 1
end

on handle_join_failed me, tMsg
  tConn = tMsg.connection
  tCode = tConn.GetIntFrom()
  me.getInterface().showBasicAlert("ig_error_join_failed_" & tCode)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.storeJoinedGameInstance(0)
  return 1
end

on handle_in_arena_queue me, tMsg
  me.getComponent().removeIGComponent("JoinedGame")
  me.getComponent().setSystemState(#pre_game)
  me.getInterface().resetToDefaultAndHide()
  tConn = tMsg.connection
  tQueuePos = tConn.GetIntFrom()
  return me.getInterface().showArenaQueue(tQueuePos)
end

on handle_stage_still_loading me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#progress, tConn.GetIntFrom())
  tFinishedPlayers = []
  tNumItems = tConn.GetIntFrom()
  repeat with i = 1 to tNumItems
    tFinishedPlayers.append(tConn.GetIntFrom())
  end repeat
  tdata.setaProp(#finished_players, tFinishedPlayers)
  me.getComponent().displayIGComponentEvent("PreGame", #still_loading, tdata)
  return 1
end

on handle_game_not_found me, tMsg
  tConn = tMsg.connection
  tGameId = tConn.GetIntFrom()
  tObserving = tConn.GetIntFrom()
  if not tObserving and (me.getComponent().getSystemState() = #ready) then
    error(me, "Game not found, id:" && tGameId, #handle_game_not_found)
    me.getInterface().showBasicAlert("ig_error_game_deleted")
  end if
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  return tService.removeGameInstance(tGameId)
end

on handle_game_chat me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#id, tConn.GetIntFrom())
  tdata.setaProp(#message, tConn.GetStrFrom())
  tService = me.getComponent().getIGComponent("GameChat")
  if tService = 0 then
    return 0
  end if
  tService.executeGameChat(tdata)
  return 1
end

on handle_enter_arena me, tMsg
  tConn = tMsg.connection
  me.getComponent().removeIGComponent("JoinedGame")
  me.getComponent().removeIGComponent("ArenaQueue")
  tdata = [:]
  tdata.setaProp(#game_type, tConn.GetIntFrom())
  tdata.setaProp(#level_id, tConn.GetIntFrom())
  tdata.setaProp(#number_of_teams, tConn.GetIntFrom())
  executeMessage(#sendTrackingPoint, "/game/started/" & tdata.getaProp(#game_type) & "/" & tdata.getaProp(#level_id))
  tUserCount = tConn.GetIntFrom()
  tTeamList = [:]
  repeat with i = 1 to tUserCount
    tuser = [:]
    tID = tConn.GetIntFrom()
    tuser.setaProp(#id, tID)
    tuser.setaProp(#name, tConn.GetStrFrom())
    tuser.setaProp(#figure, tConn.GetStrFrom())
    tuser.setaProp(#sex, tConn.GetStrFrom())
    tTeamId = tConn.GetIntFrom()
    tuser.setaProp(#team_id, tTeamId)
    if tTeamList.findPos(tTeamId) = 0 then
      tTeamList.setaProp(tTeamId, [#players: [:]])
    end if
    tTeam = tTeamList.getaProp(tTeamId).getaProp(#players)
    tTeam.setaProp(tID, tuser)
    executeMessage(#ig_store_gameplayer_info, tdata)
  end repeat
  tdata.setaProp(#teams, tTeamList)
  me.getComponent().setSystemState(#enter_arena)
  executeMessage(#changeRoom)
  tConnection = getConnection(#Info)
  if tConnection <> 0 then
    tConnection.send("QUIT")
  end if
  if threadExists(#entry) then
    getThread(#entry).getComponent().leaveEntry()
  end if
  getObject(#session).set("lastroom", EMPTY)
  executeMessage(#hide_navigator)
  executeMessage(#ig_clear_game_info)
  executeMessage(#ig_store_game_info, tdata)
  me.getComponent().setSystemState(#pre_game)
  me.getComponent().displayIGComponentEvent("PreGame", #pre_game, tdata, 1)
  tService = me.getComponent().getIGComponent("BottomBar")
  if tService = 0 then
    return 0
  end if
  tService.setActiveFlag(1)
  tService.displayEvent(#stage_starting, tdata)
  return 1
end

on handle_arena_entered me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  me.parse_player(tdata, tConn)
  tdata.setaProp(#team_id, tConn.GetIntFrom())
  me.getComponent().displayIGComponentEvent("PreGame", #arena_entered, tdata)
  return 1
end

on handle_load_stage me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#game_type, tConn.GetIntFrom())
  tService = me.getComponent().getIGComponent("GameAssetImport")
  if tService = 0 then
    return 0
  end if
  tService.startCastDownload(tdata)
  return 1
end

on handle_stage_starting me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#game_type, tConn.GetIntFrom())
  tdata.setaProp(#room_marker, tConn.GetStrFrom())
  tdata.setaProp(#state, #created)
  tTypeService = me.getComponent().getIGComponent("GameTypes")
  if tTypeService = 0 then
    return 0
  end if
  tdata.setaProp(#room_program_class, tTypeService.getAction(tdata.getaProp(#game_type), #get_room_class))
  tdata.setaProp(#time_to_stage_running, tConn.GetIntFrom())
  tService = me.getComponent().getIGComponent("RoomLoader")
  if tService = 0 then
    return 0
  end if
  tService.constructArena(tdata, tMsg)
  executeMessage(#ig_store_game_info, tdata)
  me.getComponent().displayIGComponentEvent("PreGame", #stage_starting, tdata)
  return 1
end

on handle_stage_running me, tMsg
  tConn = tMsg.connection
  me.getComponent().removeIGComponent("GameAssetImport")
  me.getComponent().removeIGComponent("RoomLoader")
  me.getComponent().removeIGComponent("PreGame")
  tdata = [:]
  tdata.addProp(#state, #started)
  tTimer = tConn.GetIntFrom()
  tdata.addProp(#state_duration, tTimer)
  tdata.addProp(#time_to_next_state, tTimer)
  tdata.addProp(#time_until_game_end, tTimer)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.storeJoinedGameInstance(0)
  me.getComponent().setSystemState(#in_game)
  me.getInterface().resetToDefaultAndHide()
  executeMessage(#gamesystem_sendevent, #gamestart, tdata)
  tService = me.getComponent().getIGComponent("BottomBar")
  if tService = 0 then
    return 0
  end if
  tService.setActiveFlag(1)
  tService.displayEvent(#stage_running, tdata)
  return 1
end

on handle_stage_ending me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#time_to_next_state, tConn.GetIntFrom())
  executeMessage(#gamesystem_sendevent, #gameend, tdata)
  return 1
end

on handle_game_ending me, tMsg
  tConn = tMsg.connection
  put "* received game_ending"
  tGameDataService = me.getComponent().getIGComponent("GameData")
  if tGameDataService = 0 then
    return error(me, "Game data IGComponent not found.", #handle_game_ending)
  end if
  tGameType = tGameDataService.getProperty(#game_type)
  tLevelId = tGameDataService.getProperty(#level_id)
  executeMessage(#sendTrackingPoint, "/game/ended/" & tGameType & "/" & tLevelId)
  tdata = [:]
  tdata.setaProp(#time_to_next_state, tConn.GetIntFrom())
  tMaxNumPlayers = 0
  tNumTeams = tConn.GetIntFrom()
  tTeams = [:]
  repeat with i = 1 to tNumTeams
    tTeam = [:]
    tTeam.setaProp(#id, tConn.GetIntFrom())
    tTeam.setaProp(#pos, i)
    tTeam.setaProp(#score, tConn.GetIntFrom())
    tTeam.setaProp(#is_highscore, tConn.GetIntFrom())
    tPlayers = [:]
    tNumPlayers = tConn.GetIntFrom()
    if tNumPlayers > tMaxNumPlayers then
      tMaxNumPlayers = tNumPlayers
    end if
    repeat with j = 1 to tNumPlayers
      tPlayer = [:]
      tPlayer.setaProp(#room_index, tConn.GetIntFrom())
      tPlayer.setaProp(#pos, j)
      tPlayer.setaProp(#team_id, tTeam.getaProp(#id))
      tPlayer.setaProp(#team_pos, i)
      tPlayer.setaProp(#score, tConn.GetIntFrom())
      tPlayer.setaProp(#is_highscore, tConn.GetIntFrom())
      tPlayer.setaProp(#xp_gained, tConn.GetIntFrom())
      tPlayer.setaProp(#xp_today, tConn.GetIntFrom())
      tPlayer.setaProp(#xp_month, tConn.GetIntFrom())
      tPlayer.setaProp(#xp_total, tConn.GetIntFrom())
      tPlayerInfo = tGameDataService.getPlayerInfoByRoomIndex(tPlayer.getaProp(#room_index))
      tKeyList = [#id, #figure, #sex, #class, #name, #disconnected]
      if tPlayerInfo <> 0 then
        repeat with tKey in tKeyList
          tPlayer.setaProp(tKey, tPlayerInfo.getaProp(tKey))
        end repeat
      end if
      tPlayers.setaProp(tPlayer.getaProp(#id), tPlayer)
    end repeat
    tTeam.setaProp(#players, tPlayers)
    tTeams.setaProp(tTeam.getaProp(#id), tTeam)
  end repeat
  tdata.setaProp(#teams, tTeams)
  tdata.setaProp(#number_of_teams, tNumTeams)
  tNumTopLevelScores = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumTopLevelScores
    tPlayer = [:]
    tPlayer.setaProp(#name, tConn.GetStrFrom())
    tPlayer.setaProp(#score, tConn.GetIntFrom())
    tPlayer.setaProp(#room_index, tConn.GetIntFrom())
    tList.append(tPlayer)
  end repeat
  tdata.setaProp(#top_level_scores, tList)
  tNumLevelTeamScores = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumLevelTeamScores
    tItem = [:]
    tItem.setaProp(#score, tConn.GetIntFrom())
    tItem.setaProp(#id, tConn.GetIntFrom())
    tNumPlayers = tConn.GetIntFrom()
    tPlayers = []
    repeat with j = 1 to tNumPlayers
      tPlayers.append(tConn.GetStrFrom())
    end repeat
    tItem.setaProp(#players, tPlayers)
    tList.append(tItem)
  end repeat
  tdata.setaProp(#level_team_scores, tList)
  me.getComponent().displayIGComponentEvent("AfterGame", #after_game, tdata, 1)
  tService = me.getComponent().getIGComponent("BottomBar")
  if tService = 0 then
    return 0
  end if
  tService.setActiveFlag(1)
  tService.displayEvent(#game_ending, tdata)
  return 1
end

on handle_game_created me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  me.parse_game_long_data(tdata, tConn)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.storeJoinedGameInstance(tdata)
  me.send_ROOM_GAME_STATUS(1, tdata.getaProp(#id), tdata.getaProp(#game_type))
  tSystemState = me.getComponent().getSystemState()
  if tSystemState = #ready then
    me.getInterface().showWindow("JoinedGame")
  else
    if tSystemState = #after_game then
      me.getInterface().showWindow("AfterGame", #rejoin)
    end if
  end if
  return 1
end

on handle_game_long_data me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  me.parse_game_long_data(tdata, tConn)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.storeGameInstance(tdata)
  return 1
end

on handle_create_game_info me, tMsg
  tConn = tMsg.connection
  tService = me.getComponent().getIGComponent("GameTypes")
  if tService = 0 then
    return 0
  end if
  tLevels = []
  tNumLevels = tConn.GetIntFrom()
  repeat with i = 1 to tNumLevels
    tItem = [:]
    tItem.addProp(#id, tConn.GetStrFrom())
    tItem.addProp(#level_name, tConn.GetStrFrom())
    tItem.addProp(#game_type, tConn.GetIntFrom())
    tItem.addProp(#field_type, tConn.GetIntFrom())
    tService.getAction(tItem.getaProp(#game_type), #parse_create_game_info, tItem, tConn)
    tLevels.add(tItem)
  end repeat
  me.getComponent().removeIGComponent("GameTypes")
  tService = me.getComponent().getIGComponent("LevelList")
  if tService = 0 then
    return 0
  end if
  return tService.storeLevelListInfo(tLevels)
end

on handle_game_list me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tInstanceCount = tConn.GetIntFrom()
  tdata.setaProp(#instance_count, tInstanceCount)
  tInstanceList = []
  repeat with i = 1 to tInstanceCount
    tInstance = [:]
    me.parse_game_short_data(tInstance, tConn)
    tInstanceList.append(tInstance)
  end repeat
  tdata.addProp(#list, tInstanceList)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  return tService.storeGameList(tdata)
end

on parse_game_short_data me, tdata, tConn
  tdata.setaProp(#id, tConn.GetIntFrom())
  tdata.setaProp(#level_name, tConn.GetStrFrom())
  tdata.setaProp(#game_type, tConn.GetIntFrom())
  tdata.setaProp(#field_type, tConn.GetIntFrom())
  tdata.setaProp(#number_of_teams, tConn.GetIntFrom())
  tdata.setaProp(#player_count, tConn.GetIntFrom())
  tdata.setaProp(#player_max_count, tConn.GetIntFrom())
  tdata.setaProp(#owner_name, tConn.GetStrFrom())
  tTypeService = me.getComponent().getIGComponent("GameTypes")
  if tTypeService = 0 then
    return 0
  end if
  tdata.setaProp(#game_type_icon, tTypeService.getAction(tdata.getaProp(#game_type), #get_icon_image))
  tTypeService.getAction(tdata.getaProp(#game_type), #parse_short_data, tdata, tConn)
  return tdata
end

on parse_game_long_data me, tdata, tConn
  me.parse_game_short_data(tdata, tConn)
  tdata.setaProp(#level_id, tConn.GetIntFrom())
  tTeamCount = tConn.GetIntFrom()
  tAllTeamData = [:]
  tdata.setaProp(#number_of_teams, tTeamCount)
  repeat with tTeamIndex = 1 to tTeamCount
    tTeamInfo = [:]
    tPlayerList = [:]
    tPlayerCount = tConn.GetIntFrom()
    repeat with j = 1 to tPlayerCount
      tPlayerInfo = [#team_id: tTeamIndex]
      me.parse_player(tPlayerInfo, tConn)
      tPlayerList.setaProp(tPlayerInfo.getaProp(#id), tPlayerInfo)
    end repeat
    tTeamInfo.setaProp(#players, tPlayerList)
    tAllTeamData.setaProp(tTeamIndex, tTeamInfo)
  end repeat
  tdata.setaProp(#teams, tAllTeamData)
  me.parse_required_players(tdata, tConn)
  tTypeService = me.getComponent().getIGComponent("GameTypes")
  if tTypeService = 0 then
    return 0
  end if
  tTypeService.getAction(tdata.getaProp(#game_type), #parse_long_data, tdata, tConn)
  return tdata
end

on parse_required_players me, tdata, tConn
  tInvalidTeamCount = tConn.GetIntFrom()
  tList = [:]
  repeat with i = 1 to tInvalidTeamCount
    tTeamId = tConn.GetIntFrom()
    tNumNeeded = tConn.GetIntFrom()
    tList.setaProp(tTeamId, tNumNeeded)
  end repeat
  tdata.setaProp(#players_required, tList)
  return tdata
end

on handle_user_joined_game me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#game_id, tConn.GetIntFrom())
  me.parse_player(tdata, tConn)
  tdata.setaProp(#team_id, tConn.GetIntFrom())
  me.parse_required_players(tdata, tConn)
  tGameId = tdata.getaProp(#game_id)
  tSystemState = me.getComponent().getSystemState()
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.addUserToGame(tdata)
  if tGameId = tService.getJoinedGameId() then
    tJoinedGame = tService.getJoinedGame()
    if tJoinedGame = 0 then
      return 0
    end if
    if tJoinedGame.getOwnPlayerId() = tdata.getaProp(#id) then
      me.getComponent().removeIGComponent("Prejoin")
      me.send_ROOM_GAME_STATUS(1, tGameId, tJoinedGame.getProperty(#game_type))
      if tSystemState = #ready then
        me.getInterface().showWindow("JoinedGame")
      else
        if tSystemState = #after_game then
          me.getInterface().showWindow("AfterGame", #rejoin)
        end if
      end if
    end if
  end if
  if tSystemState = #after_game then
    me.getComponent().displayIGComponentEvent("AfterGame", #user_joined_game, tdata)
  end if
end

on parse_player me, tdata, tConn
  if tdata = VOID then
    tdata = [:]
  end if
  tdata.setaProp(#id, tConn.GetIntFrom())
  tdata.setaProp(#name, tConn.GetStrFrom())
  tdata.setaProp(#figure, tConn.GetStrFrom())
  tdata.setaProp(#sex, tConn.GetStrFrom())
  return tdata
end

on handle_user_left_game me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.setaProp(#game_id, tConn.GetIntFrom())
  tdata.setaProp(#id, tConn.GetIntFrom())
  tdata.setaProp(#was_kicked, tConn.GetIntFrom())
  me.parse_required_players(tdata, tConn)
  tGameId = tdata.getaProp(#game_id)
  tPlayerId = tdata.getaProp(#id)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.removeUserFromGame(tdata)
  return 1
end

on handle_game_observation_started_short me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  me.parse_game_short_data(tdata, tConn)
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  tService.storeGameInstance(tdata)
  return 1
end

on handle_game_cancelled me, tMsg
  tConn = tMsg.connection
  tGameId = tConn.GetIntFrom()
  tReasonCode = tConn.GetIntFrom()
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  if tGameId = tService.getJoinedGameId() then
    me.getComponent().removeIGComponent("JoinedGame")
  end if
  if tGameId = tService.getObservedGameId() then
    me.getComponent().removeIGComponent("Prejoin")
  end if
  return tService.removeGameInstance(tGameId)
end

on handle_game_started me, tMsg
  tConn = tMsg.connection
  tGameId = tConn.GetIntFrom()
  tService = me.getComponent().getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  if tGameId = tService.getJoinedGameId() then
    me.getInterface().resetToDefaultAndHide()
    me.getComponent().setSystemState(#enter_arena)
  end if
  return tService.removeGameInstance(tGameId)
end

on getOwnPlayerName me
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  return tSession.GET(#user_name)
end

on getGameConnection me
  return getConnection(#Info)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(387, #handle_directory_status)
  tMsgs.setaProp(388, #handle_ENTER_ARENA_FAILED)
  tMsgs.setaProp(389, #handle_GAME_REJOIN)
  tMsgs.setaProp(390, #handle_player_exited_game_arena)
  tMsgs.setaProp(391, #handle_level_hall_of_fame)
  tMsgs.setaProp(392, #handle_start_failed)
  tMsgs.setaProp(393, #handle_join_failed)
  tMsgs.setaProp(394, #handle_in_arena_queue)
  tMsgs.setaProp(395, #handle_stage_still_loading)
  tMsgs.setaProp(396, #handle_game_not_found)
  tMsgs.setaProp(399, #handle_game_chat)
  tMsgs.setaProp(400, #handle_enter_arena)
  tMsgs.setaProp(401, #handle_arena_entered)
  tMsgs.setaProp(402, #handle_load_stage)
  tMsgs.setaProp(403, #handle_stage_starting)
  tMsgs.setaProp(404, #handle_stage_running)
  tMsgs.setaProp(405, #handle_stage_ending)
  tMsgs.setaProp(406, #handle_game_ending)
  tMsgs.setaProp(407, #handle_game_created)
  tMsgs.setaProp(408, #handle_game_long_data)
  tMsgs.setaProp(409, #handle_create_game_info)
  tMsgs.setaProp(410, #handle_game_list)
  tMsgs.setaProp(413, #handle_user_joined_game)
  tMsgs.setaProp(414, #handle_user_left_game)
  tMsgs.setaProp(415, #handle_game_observation_started_short)
  tMsgs.setaProp(416, #handle_game_cancelled)
  tMsgs.setaProp(417, #handle_game_long_data)
  tMsgs.setaProp(418, #handle_game_started)
  tCmds = [:]
  tCmds.setaProp("IG_CHECK_DIRECTORY_STATUS", 288)
  tCmds.setaProp("IG_ROOM_GAME_STATUS", 289)
  tCmds.setaProp("IG_PLAY_AGAIN", 290)
  tCmds.setaProp("GAME_CHAT", 298)
  tCmds.setaProp("IG_CREATE_GAME", 300)
  tCmds.setaProp("IG_GET_GAME_LIST", 301)
  tCmds.setaProp("IG_GET_CREATE_GAME_INFO", 302)
  tCmds.setaProp("IG_CHANGE_PARAMETERS", 303)
  tCmds.setaProp("IG_LIST_POSSIBLE_INVITEES", 304)
  tCmds.setaProp("IG_INVITE_USER", 305)
  tCmds.setaProp("IG_KICK_USER", 306)
  tCmds.setaProp("IG_START_GAME", 307)
  tCmds.setaProp("IG_CANCEL_GAME", 308)
  tCmds.setaProp("IG_JOIN_GAME", 309)
  tCmds.setaProp("IG_LEAVE_GAME", 310)
  tCmds.setaProp("IG_START_OBSERVING_GAME", 311)
  tCmds.setaProp("IG_STOP_OBSERVING_GAME", 312)
  tCmds.setaProp("IG_GET_LEVEL_HALL_OF_FAME", 291)
  tCmds.setaProp("IG_ACCEPT_INVITE_REQUEST", 292)
  tCmds.setaProp("IG_DECLINE_INVITE_REQUEST", 293)
  tCmds.setaProp("IG_LOAD_STAGE_READY", 295)
  tCmds.setaProp("MSG_PLAYER_INPUT", 296)
  tCmds.setaProp("IG_EXIT_GAME", 299)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
