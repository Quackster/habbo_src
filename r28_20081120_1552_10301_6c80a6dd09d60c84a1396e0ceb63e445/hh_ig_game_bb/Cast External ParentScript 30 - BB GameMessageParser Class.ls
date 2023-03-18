on construct me
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #msgstruct_instancelist:
      return me.handle_instancelist(tdata)
    #msgstruct_gameinstance:
      return me.handle_gameinstance(tdata)
    #msgstruct_gamestatus:
      return me.handle_gamestatus(tdata)
    #msgstruct_fullgamestatus:
      return me.handle_fullgamestatus(tdata)
    #msgstruct_gamestart:
      return me.handle_gamestart(tdata)
    #msgstruct_gameend:
      return me.handle_gameend(tdata)
    #msgstruct_gamereset:
      return me.handle_gamereset(tdata)
    #msgstruct_gameplayerinfo:
      return me.handle_gameplayerinfo(tdata)
  end case
  return 0
end

on handle_instancelist me, tMsg
  tConn = tMsg.connection
  tResult = [:]
  tCreatedCount = tConn.GetIntFrom()
  if tCreatedCount > 100 then
    return 0
  end if
  repeat with i = 1 to tCreatedCount
    tInstance = me.parse_created_instance(tConn)
    tResult.addProp(string(tInstance[#id]), tInstance)
  end repeat
  tStartedCount = tConn.GetIntFrom()
  if tStartedCount > 100 then
    return 0
  end if
  repeat with i = 1 to tStartedCount
    tInstance = me.parse_started_instance(tConn)
    tResult.addProp(string(tInstance[#id]), tInstance)
  end repeat
  tFinishedCount = tConn.GetIntFrom()
  if tFinishedCount > 100 then
    return 0
  end if
  repeat with i = 1 to tFinishedCount
    tInstance = me.parse_finished_instance(tConn)
    tResult.addProp(string(tInstance[#id]), tInstance)
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#instancelist, tResult)
  return tResult
end

on handle_gameinstance me, tMsg
  tConn = tMsg.connection
  tStateInt = tConn.GetIntFrom()
  tstate = [#created, #started, #finished][tStateInt + 1]
  case tstate of
    #created:
      tResult = me.parse_created_instance(tConn)
      tResult.addProp(#numSpectators, tConn.GetIntFrom())
      tNumTeams = tConn.GetIntFrom()
      tTeams = []
      repeat with i = 1 to tNumTeams
        tList = []
        tNumPlayers = tConn.GetIntFrom()
        repeat with j = 1 to tNumPlayers
          tList.add(me.parse_team_player(tConn))
        end repeat
        tTeams.add([#players: tList, #id: i])
      end repeat
      tResult.addProp(#numTeams, tNumTeams)
      tResult.addProp(#teams, tTeams)
      tResult.addProp(#allowedPowerups, tConn.GetStrFrom())
    #started:
      tResult = me.parse_started_instance(tConn)
      tNumTeams = tConn.GetIntFrom()
      tTeams = []
      repeat with i = 1 to tNumTeams
        tList = []
        tNumPlayers = tConn.GetIntFrom()
        repeat with j = 1 to tNumPlayers
          tList.add([#name: tConn.GetStrFrom()])
        end repeat
        tTeams.add([#players: tList, #id: i])
      end repeat
      tResult.addProp(#numTeams, tNumTeams)
      tResult.addProp(#teams, tTeams)
      tResult.addProp(#allowedPowerups, tConn.GetStrFrom())
    #finished:
      tResult = me.parse_finished_instance(tConn)
      tNumTeams = tConn.GetIntFrom()
      tTeamsUnsorted = []
      repeat with i = 1 to tNumTeams
        tList = [#players: []]
        tNumPlayers = tConn.GetIntFrom()
        repeat with j = 1 to tNumPlayers
          tPlayer = [:]
          tPlayer.addProp(#name, tConn.GetStrFrom())
          tPlayer.addProp(#score, tConn.GetIntFrom())
          tList[#players].add(tPlayer)
        end repeat
        tList.addProp(#score, tConn.GetIntFrom())
        tTeamsUnsorted.add(tList)
      end repeat
      tResult.addProp(#numTeams, tNumTeams)
      tResult.addProp(#allowedPowerups, tConn.GetStrFrom())
      tTeams = []
      repeat with tTeamId = 1 to tNumTeams
        tList = [#players: [], #id: tTeamId, #score: tTeamsUnsorted[tTeamId][#score]]
        tTeamPlayers = tTeamsUnsorted[tTeamId][#players]
        repeat with j = 1 to tTeamPlayers.count
          tPlayer = [:]
          tPlayer.addProp(#name, tTeamPlayers[j][#name])
          tPlayer.addProp(#score, tTeamPlayers[j][#score])
          tPlayerPos = 1
          if tList[#players].count > 0 then
            repeat while tList[#players][tPlayerPos][#score] > tPlayer[#score]
              tPlayerPos = tPlayerPos + 1
              if tPlayerPos > tList[#players].count then
                exit repeat
              end if
            end repeat
          end if
          tList[#players].addAt(tPlayerPos, tPlayer)
        end repeat
        tTeamPos = 1
        if tTeams.count > 0 then
          repeat while tTeams[tTeamPos][#score] > tList[#score]
            tTeamPos = tTeamPos + 1
            if tTeamPos > tTeams.count then
              exit repeat
            end if
          end repeat
        end if
        tTeams.addAt(tTeamPos, tList)
      end repeat
      tPlayerPos = 1
      tResult.addProp(#teams, tTeams)
  end case
  tResult.addProp(#state, tstate)
  return me.getGameSystem().sendGameSystemEvent(#gameinstance, tResult)
end

on handle_fullgamestatus me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tStateInt = tConn.GetIntFrom()
  tTimeToNextState = tConn.GetIntFrom()
  tStateDuration = tConn.GetIntFrom()
  me.sendGameSystemEvent(#musicstart)
  tNumObjects = tConn.GetIntFrom()
  tObjects = []
  repeat with i = 1 to tNumObjects
    tObjects.add(me.parse_info_gameobject_full(tConn))
  end repeat
  tdata.addProp(#game_objects, tObjects)
  tWorldLength = tConn.GetIntFrom()
  tWorldWidth = tConn.GetIntFrom()
  tWorld = []
  repeat with tLocV = 1 to tWorldLength
    repeat with tLocH = 1 to tWorldWidth
      tTile = me.parse_tile(tConn)
      if tTile[#teamId] > 0 then
        tTile[#x] = tLocH - 1
        tTile[#y] = tLocV - 1
        tWorld.add(tTile)
      end if
    end repeat
  end repeat
  tdata.addProp(#flood, tWorld)
  tNumSubturns = tConn.GetIntFrom()
  tNumEvents = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumEvents
    tEvent = me.parse_event(tConn)
    tList.add(tEvent)
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  if not getObject(#session).exists(#gamespace_world_info) then
    return 0
  end if
  tGameSpaceData = getObject(#session).GET(#gamespace_world_info)
  if listp(tGameSpaceData) then
    tGameSystem.getVarMgr().set(#tournament_flag, tGameSpaceData[#tournament_flag])
  end if
  repeat with tGameObject in tdata[#game_objects]
    if tGameSystem.getGameObject(tGameObject[#id]) = 0 then
      tGameSystem.sendGameSystemEvent(#create_game_object, tGameObject)
      next repeat
    end if
    tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
  end repeat
  tGameSystem.sendGameSystemEvent(#fullgamestatus_tiles, tdata[#flood])
  repeat with tEvent in tdata[#events]
    tGameSystem.sendGameSystemEvent(symbol("bb_event_" & tEvent[#type]), tEvent)
  end repeat
  return 1
end

on handle_gamestatus me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tNumChangedObjects = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumChangedObjects
    tList.add(me.parse_info_gameobject_update(tConn))
  end repeat
  tdata.addProp(#game_objects, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumChangedTiles
    tTile = [:]
    tTile.addProp(#x, tConn.GetIntFrom())
    tTile.addProp(#y, tConn.GetIntFrom())
    tTile.addProp(#teamId, tConn.GetIntFrom())
    tTile.addProp(#jumps, tConn.GetIntFrom())
    tList.add(tTile)
  end repeat
  tdata.addProp(#tiles, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumChangedTiles
    tTile = [:]
    tTile.addProp(#x, tConn.GetIntFrom())
    tTile.addProp(#y, tConn.GetIntFrom())
    tTile.addProp(#teamId, tConn.GetIntFrom())
    tTile.addProp(#jumps, tConn.GetIntFrom())
    tList.add(tTile)
  end repeat
  tdata.addProp(#flood, tList)
  tList = []
  tNumTeams = tConn.GetIntFrom()
  repeat with i = 1 to tNumTeams
    tList.add(tConn.GetIntFrom())
  end repeat
  tdata.addProp(#scores, tList)
  tNumSubturns = tConn.GetIntFrom()
  tNumEvents = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumEvents
    tEvent = me.parse_event(tConn)
    tList.add(tEvent)
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  repeat with tGameObject in tdata[#game_objects]
    tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
  end repeat
  tGameSystem.sendGameSystemEvent(#gamestatus_tiles, tdata[#tiles])
  tGameSystem.sendGameSystemEvent(#gamestatus_flood, tdata[#flood])
  tGameSystem.sendGameSystemEvent(#gamestatus_scores, tdata[#scores])
  repeat with tEvent in tdata[#events]
    tGameSystem.sendGameSystemEvent(symbol("bb_event_" & tEvent[#type]), tEvent)
  end repeat
  return 1
end

on handle_gamestart me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#time_until_game_end, tConn.GetIntFrom())
  return me.getGameSystem().sendGameSystemEvent(#gamestart, tdata)
end

on handle_gameend me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#time_until_game_reset, tConn.GetIntFrom())
  tNumTeams = tConn.GetIntFrom()
  tTeamScores = []
  repeat with tTeamNum = 1 to tNumTeams
    tNumPlayers = tConn.GetIntFrom()
    tPlayers = [:]
    repeat with tPlayer = 1 to tNumPlayers
      tPlayerId = tConn.GetIntFrom()
      tPlayerName = tConn.GetStrFrom()
      tPlayerScore = tConn.GetIntFrom()
      tPlayers.addProp(string(tPlayerId), [#id: tPlayerId, #name: tPlayerName, #score: tPlayerScore])
    end repeat
    if tNumPlayers > 0 then
      tTeamScore = tConn.GetIntFrom()
    else
      tTeamScore = 0
    end if
    tTeamScores.add([#players: tPlayers, #score: tTeamScore])
  end repeat
  tdata.addProp(#gameend_scores, tTeamScores)
  return me.getGameSystem().sendGameSystemEvent(#gameend, tdata)
end

on handle_gamereset me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tNumObjects = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumObjects
    tList.add(me.parse_info_gameobject_full(tConn))
  end repeat
  tdata.addProp(#game_objects, tList)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  tWorldLength = tConn.GetIntFrom()
  tWorldWidth = tConn.GetIntFrom()
  tdata.setaProp(#world_width, tWorldWidth)
  tdata.setaProp(#world_height, tWorldLength)
  tHeightMap = EMPTY
  tWorld = []
  repeat with tLocV = 1 to tWorldLength
    repeat with tLocH = 1 to tWorldWidth
      tTile = me.parse_tile(tConn)
      if tTile[#teamId] > 0 then
        tTile[#x] = tLocH - 1
        tTile[#y] = tLocV - 1
        tWorld.add(tTile)
      end if
      tHeightMap = tHeightMap & "0"
    end repeat
    tHeightMap = tHeightMap & RETURN
  end repeat
  tdata.addProp(#flood, tWorld)
  tHeightMap = tConn.GetStrFrom()
  me.store_heightmap(tHeightMap, tWorldWidth, tWorldLength)
  repeat with tGameObject in tdata[#game_objects]
    if tGameSystem.getGameObject(tGameObject[#id]) = 0 then
      tGameSystem.sendGameSystemEvent(#create_game_object, tGameObject)
      next repeat
    end if
    tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
  end repeat
  tGameSystem.sendGameSystemEvent(#gamereset, tdata)
  tGameSystem.sendGameSystemEvent(#fullgamestatus_tiles, tdata[#flood])
  return 1
end

on store_heightmap me, tdata, tWorldWidth, tWorldHeight
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  tRoomComponent.getInterface().getGeometry().loadHeightMap(tdata)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  return tGameSystem.getWorld().storeHeightmap(tdata, tWorldWidth, tWorldHeight)
end

on handle_gameplayerinfo me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tNumPlayers = tConn.GetIntFrom()
  repeat with i = 1 to tNumPlayers
    tID = tConn.GetIntFrom()
    tValue = tConn.GetStrFrom()
    tSkill = tConn.GetStrFrom()
    tdata.addProp(string(tID), [#id: tID, #skillvalue: tValue, #skilllevel: tSkill])
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#gameplayerinfo, tdata)
end

on parse_created_instance me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, me.parse_team_player(tConn))
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  tResult.addProp(#state, #created)
  return tResult
end

on parse_started_instance me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name: tConn.GetStrFrom()])
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  tResult.addProp(#state, #started)
  return tResult
end

on parse_finished_instance me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name: tConn.GetStrFrom()])
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  tResult.addProp(#state, #finished)
  return tResult
end

on parse_team_player me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  return tResult
end

on parse_tile me, tConn
  tdata = [:]
  tdata.addProp(#teamId, tConn.GetIntFrom())
  tdata.addProp(#jumps, tConn.GetIntFrom())
  return tdata
end

on parse_info_player_update me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  tdata.addProp(#state, tConn.GetIntFrom())
  tdata.addProp(#coloringForOpponentTeamId, tConn.GetIntFrom())
  return tdata
end

on parse_info_player_full me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  tdata.addProp(#state, tConn.GetIntFrom())
  tdata.addProp(#coloringForOpponentTeamId, tConn.GetIntFrom())
  tdata.addProp(#name, tConn.GetStrFrom())
  tdata.addProp(#mission, tConn.GetStrFrom())
  tdata.addProp(#figure, tConn.GetStrFrom())
  tdata.addProp(#sex, tConn.GetStrFrom())
  tdata.addProp(#teamId, tConn.GetIntFrom())
  tdata.addProp(#roomindex, tConn.GetIntFrom())
  return tdata
end

on parse_info_powerup_full me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#timetolive, tConn.GetIntFrom())
  tdata.addProp(#holdingplayer, tConn.GetIntFrom())
  tdata.addProp(#powerupType, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  return tdata
end

on parse_info_pin_full me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  return tdata
end

on parse_info_powerup_update me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#timetolive, tConn.GetIntFrom())
  tdata.addProp(#holdingplayer, tConn.GetIntFrom())
  return tdata
end

on parse_info_pin_update me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  return tdata
end

on parse_info_gameobject_full me, tConn
  tObjectType = tConn.GetIntFrom()
  case tObjectType of
    0:
      tdata = me.parse_info_player_full(tConn)
      tStrType = "player"
    1:
      tdata = me.parse_info_powerup_full(tConn)
      tStrType = "powerup"
    2:
      tdata = me.parse_info_pin_full(tConn)
      tStrType = "pin"
    otherwise:
      error(me, "Unsupported game object type:" && tObjectType, #parse_info_gameobject_full)
  end case
  if tdata = 0 then
    return error(me, "Cannot parse gameobject data from server", #parse_info_gameobject_full)
  end if
  tdata.addProp(#type, tObjectType)
  tdata.addProp(#str_type, tStrType)
  tExtraProps = []
  tSystemId = me.getGameSystem().getID()
  repeat with tProp in tExtraProps
    if variableExists(tSystemId & ".gameobject." & tdata[#str_type] & "." & tProp) then
      tdata.addProp(symbol("gameobject_" & tProp), getVariable(tSystemId & ".gameobject." & tdata[#str_type] & "." & tProp))
    end if
  end repeat
  return tdata
end

on parse_info_gameobject_update me, tConn
  tObjectType = tConn.GetIntFrom()
  case tObjectType of
    0:
      tdata = me.parse_info_player_update(tConn)
      tStrType = "player"
    1:
      tdata = me.parse_info_powerup_update(tConn)
      tStrType = "powerup"
    2:
      tdata = me.parse_info_pin_update(tConn)
      tStrType = "pin"
    otherwise:
      return error(me, "Unknown object type!" && tObjectType, #parse_info_gameobject_update)
  end case
  tdata.addProp(#type, tObjectType)
  tdata.addProp(#str_type, tStrType)
  return tdata
end

on parse_event me, tConn
  tEvent = [:]
  tEvent.addProp(#type, tConn.GetIntFrom())
  case tEvent[#type] of
    0:
      tEvent.addProp(#data, me.parse_info_gameobject_full(tConn))
    1:
      tEvent.addProp(#id, tConn.GetIntFrom())
    2:
      tEvent.addProp(#id, tConn.GetIntFrom())
      tEvent.addProp(#goalx, tConn.GetIntFrom())
      tEvent.addProp(#goaly, tConn.GetIntFrom())
    3:
      tEvent.addProp(#playerId, tConn.GetIntFrom())
      tEvent.addProp(#powerupid, tConn.GetIntFrom())
      tEvent.addProp(#powerupType, tConn.GetIntFrom())
    5:
      tEvent.addProp(#playerId, tConn.GetIntFrom())
      tEvent.addProp(#powerupid, tConn.GetIntFrom())
      tEvent.addProp(#effectdirection, tConn.GetIntFrom())
      tEvent.addProp(#powerupType, tConn.GetIntFrom())
    otherwise:
      error(me, "Undefined event type:" && tEvent[#type], #parse_event)
  end case
  return tEvent
end
