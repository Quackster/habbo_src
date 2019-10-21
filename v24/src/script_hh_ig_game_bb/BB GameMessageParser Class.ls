on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if me = #msgstruct_instancelist then
    return(me.handle_instancelist(tdata))
  else
    if me = #msgstruct_gameinstance then
      return(me.handle_gameinstance(tdata))
    else
      if me = #msgstruct_gamestatus then
        return(me.handle_gamestatus(tdata))
      else
        if me = #msgstruct_fullgamestatus then
          return(me.handle_fullgamestatus(tdata))
        else
          if me = #msgstruct_gamestart then
            return(me.handle_gamestart(tdata))
          else
            if me = #msgstruct_gameend then
              return(me.handle_gameend(tdata))
            else
              if me = #msgstruct_gamereset then
                return(me.handle_gamereset(tdata))
              else
                if me = #msgstruct_gameplayerinfo then
                  return(me.handle_gameplayerinfo(tdata))
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(0)
  exit
end

on handle_instancelist(me, tMsg)
  tConn = tMsg.connection
  tResult = []
  tCreatedCount = tConn.GetIntFrom()
  if tCreatedCount > 100 then
    return(0)
  end if
  i = 1
  repeat while i <= tCreatedCount
    tInstance = me.parse_created_instance(tConn)
    tResult.addProp(string(tInstance.getAt(#id)), tInstance)
    i = 1 + i
  end repeat
  tStartedCount = tConn.GetIntFrom()
  if tStartedCount > 100 then
    return(0)
  end if
  i = 1
  repeat while i <= tStartedCount
    tInstance = me.parse_started_instance(tConn)
    tResult.addProp(string(tInstance.getAt(#id)), tInstance)
    i = 1 + i
  end repeat
  tFinishedCount = tConn.GetIntFrom()
  if tFinishedCount > 100 then
    return(0)
  end if
  i = 1
  repeat while i <= tFinishedCount
    tInstance = me.parse_finished_instance(tConn)
    tResult.addProp(string(tInstance.getAt(#id)), tInstance)
    i = 1 + i
  end repeat
  return(me.getGameSystem().sendGameSystemEvent(#instancelist, tResult))
  return(tResult)
  exit
end

on handle_gameinstance(me, tMsg)
  tConn = tMsg.connection
  tStateInt = tConn.GetIntFrom()
  tstate = [#created, #started, #finished].getAt(tStateInt + 1)
  if me = #created then
    tResult = me.parse_created_instance(tConn)
    tResult.addProp(#numSpectators, tConn.GetIntFrom())
    tNumTeams = tConn.GetIntFrom()
    tTeams = []
    i = 1
    repeat while i <= tNumTeams
      tList = []
      tNumPlayers = tConn.GetIntFrom()
      j = 1
      repeat while j <= tNumPlayers
        tList.add(me.parse_team_player(tConn))
        j = 1 + j
      end repeat
      tTeams.add([#players:tList, #id:i])
      i = 1 + i
    end repeat
    tResult.addProp(#numTeams, tNumTeams)
    tResult.addProp(#teams, tTeams)
    tResult.addProp(#allowedPowerups, tConn.GetStrFrom())
  else
    if me = #started then
      tResult = me.parse_started_instance(tConn)
      tNumTeams = tConn.GetIntFrom()
      tTeams = []
      i = 1
      repeat while i <= tNumTeams
        tList = []
        tNumPlayers = tConn.GetIntFrom()
        j = 1
        repeat while j <= tNumPlayers
          tList.add([#name:tConn.GetStrFrom()])
          j = 1 + j
        end repeat
        tTeams.add([#players:tList, #id:i])
        i = 1 + i
      end repeat
      tResult.addProp(#numTeams, tNumTeams)
      tResult.addProp(#teams, tTeams)
      tResult.addProp(#allowedPowerups, tConn.GetStrFrom())
    else
      if me = #finished then
        tResult = me.parse_finished_instance(tConn)
        tNumTeams = tConn.GetIntFrom()
        tTeamsUnsorted = []
        i = 1
        repeat while i <= tNumTeams
          tList = [#players:[]]
          tNumPlayers = tConn.GetIntFrom()
          j = 1
          repeat while j <= tNumPlayers
            tPlayer = []
            tPlayer.addProp(#name, tConn.GetStrFrom())
            tPlayer.addProp(#score, tConn.GetIntFrom())
            tList.getAt(#players).add(tPlayer)
            j = 1 + j
          end repeat
          tList.addProp(#score, tConn.GetIntFrom())
          tTeamsUnsorted.add(tList)
          i = 1 + i
        end repeat
        tResult.addProp(#numTeams, tNumTeams)
        tResult.addProp(#allowedPowerups, tConn.GetStrFrom())
        tTeams = []
        tTeamId = 1
        repeat while tTeamId <= tNumTeams
          tList = [#players:[], #id:tTeamId, #score:tTeamsUnsorted.getAt(tTeamId).getAt(#score)]
          tTeamPlayers = tTeamsUnsorted.getAt(tTeamId).getAt(#players)
          j = 1
          repeat while j <= tTeamPlayers.count
            tPlayer = []
            tPlayer.addProp(#name, tTeamPlayers.getAt(j).getAt(#name))
            tPlayer.addProp(#score, tTeamPlayers.getAt(j).getAt(#score))
            tPlayerPos = 1
            if tList.getAt(#players).count > 0 then
              repeat while tList.getAt(#players).getAt(tPlayerPos).getAt(#score) > tPlayer.getAt(#score)
                tPlayerPos = tPlayerPos + 1
                if tPlayerPos > tList.getAt(#players).count then
                else
                end if
              end repeat
            end if
            tList.getAt(#players).addAt(tPlayerPos, tPlayer)
            j = 1 + j
          end repeat
          tTeamPos = 1
          if tTeams.count > 0 then
            repeat while tTeams.getAt(tTeamPos).getAt(#score) > tList.getAt(#score)
              tTeamPos = tTeamPos + 1
              if tTeamPos > tTeams.count then
              else
              end if
            end repeat
          end if
          tTeams.addAt(tTeamPos, tList)
          tTeamId = 1 + tTeamId
        end repeat
        tPlayerPos = 1
        tResult.addProp(#teams, tTeams)
      end if
    end if
  end if
  tResult.addProp(#state, tstate)
  return(me.getGameSystem().sendGameSystemEvent(#gameinstance, tResult))
  exit
end

on handle_fullgamestatus(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tStateInt = tConn.GetIntFrom()
  tTimeToNextState = tConn.GetIntFrom()
  tStateDuration = tConn.GetIntFrom()
  me.sendGameSystemEvent(#musicstart)
  tNumObjects = tConn.GetIntFrom()
  tObjects = []
  i = 1
  repeat while i <= tNumObjects
    tObjects.add(me.parse_info_gameobject_full(tConn))
    i = 1 + i
  end repeat
  tdata.addProp(#game_objects, tObjects)
  tWorldLength = tConn.GetIntFrom()
  tWorldWidth = tConn.GetIntFrom()
  tWorld = []
  tLocV = 1
  repeat while tLocV <= tWorldLength
    tLocH = 1
    repeat while tLocH <= tWorldWidth
      tTile = me.parse_tile(tConn)
      if tTile.getAt(#teamId) > 0 then
        tTile.setAt(#x, tLocH - 1)
        tTile.setAt(#y, tLocV - 1)
        tWorld.add(tTile)
      end if
      tLocH = 1 + tLocH
    end repeat
    tLocV = 1 + tLocV
  end repeat
  tdata.addProp(#flood, tWorld)
  tNumSubturns = tConn.GetIntFrom()
  tNumEvents = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumEvents
    tEvent = me.parse_event(tConn)
    tList.add(tEvent)
    i = 1 + i
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  if not getObject(#session).exists(#gamespace_world_info) then
    return(0)
  end if
  tGameSpaceData = getObject(#session).GET(#gamespace_world_info)
  if listp(tGameSpaceData) then
    tGameSystem.getVarMgr().set(#tournament_flag, tGameSpaceData.getAt(#tournament_flag))
  end if
  repeat while me <= undefined
    tGameObject = getAt(undefined, tMsg)
    if tGameSystem.getGameObject(tGameObject.getAt(#id)) = 0 then
      tGameSystem.sendGameSystemEvent(#create_game_object, tGameObject)
    else
      tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
    end if
  end repeat
  tGameSystem.sendGameSystemEvent(#fullgamestatus_tiles, tdata.getAt(#flood))
  repeat while me <= undefined
    tEvent = getAt(undefined, tMsg)
    tGameSystem.sendGameSystemEvent(symbol("bb_event_" & tEvent.getAt(#type)), tEvent)
  end repeat
  return(1)
  exit
end

on handle_gamestatus(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tNumChangedObjects = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumChangedObjects
    tList.add(me.parse_info_gameobject_update(tConn))
    i = 1 + i
  end repeat
  tdata.addProp(#game_objects, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumChangedTiles
    tTile = []
    tTile.addProp(#x, tConn.GetIntFrom())
    tTile.addProp(#y, tConn.GetIntFrom())
    tTile.addProp(#teamId, tConn.GetIntFrom())
    tTile.addProp(#jumps, tConn.GetIntFrom())
    tList.add(tTile)
    i = 1 + i
  end repeat
  tdata.addProp(#tiles, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumChangedTiles
    tTile = []
    tTile.addProp(#x, tConn.GetIntFrom())
    tTile.addProp(#y, tConn.GetIntFrom())
    tTile.addProp(#teamId, tConn.GetIntFrom())
    tTile.addProp(#jumps, tConn.GetIntFrom())
    tList.add(tTile)
    i = 1 + i
  end repeat
  tdata.addProp(#flood, tList)
  tList = []
  tNumTeams = tConn.GetIntFrom()
  i = 1
  repeat while i <= tNumTeams
    tList.add(tConn.GetIntFrom())
    i = 1 + i
  end repeat
  tdata.addProp(#scores, tList)
  tNumSubturns = tConn.GetIntFrom()
  tNumEvents = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumEvents
    tEvent = me.parse_event(tConn)
    tList.add(tEvent)
    i = 1 + i
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  repeat while me <= undefined
    tGameObject = getAt(undefined, tMsg)
    tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
  end repeat
  tGameSystem.sendGameSystemEvent(#gamestatus_tiles, tdata.getAt(#tiles))
  tGameSystem.sendGameSystemEvent(#gamestatus_flood, tdata.getAt(#flood))
  tGameSystem.sendGameSystemEvent(#gamestatus_scores, tdata.getAt(#scores))
  repeat while me <= undefined
    tEvent = getAt(undefined, tMsg)
    tGameSystem.sendGameSystemEvent(symbol("bb_event_" & tEvent.getAt(#type)), tEvent)
  end repeat
  return(1)
  exit
end

on handle_gamestart(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tdata.addProp(#time_until_game_end, tConn.GetIntFrom())
  return(me.getGameSystem().sendGameSystemEvent(#gamestart, tdata))
  exit
end

on handle_gameend(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tdata.addProp(#time_until_game_reset, tConn.GetIntFrom())
  tNumTeams = tConn.GetIntFrom()
  tTeamScores = []
  tTeamNum = 1
  repeat while tTeamNum <= tNumTeams
    tNumPlayers = tConn.GetIntFrom()
    tPlayers = []
    tPlayer = 1
    repeat while tPlayer <= tNumPlayers
      tPlayerId = tConn.GetIntFrom()
      tPlayerName = tConn.GetStrFrom()
      tPlayerScore = tConn.GetIntFrom()
      tPlayers.addProp(string(tPlayerId), [#id:tPlayerId, #name:tPlayerName, #score:tPlayerScore])
      tPlayer = 1 + tPlayer
    end repeat
    if tNumPlayers > 0 then
      tTeamScore = tConn.GetIntFrom()
    else
      tTeamScore = 0
    end if
    tTeamScores.add([#players:tPlayers, #score:tTeamScore])
    tTeamNum = 1 + tTeamNum
  end repeat
  tdata.addProp(#gameend_scores, tTeamScores)
  return(me.getGameSystem().sendGameSystemEvent(#gameend, tdata))
  exit
end

on handle_gamereset(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tNumObjects = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumObjects
    tList.add(me.parse_info_gameobject_full(tConn))
    i = 1 + i
  end repeat
  tdata.addProp(#game_objects, tList)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tWorldLength = tConn.GetIntFrom()
  tWorldWidth = tConn.GetIntFrom()
  tdata.setaProp(#world_width, tWorldWidth)
  tdata.setaProp(#world_height, tWorldLength)
  tHeightMap = ""
  tWorld = []
  tLocV = 1
  repeat while tLocV <= tWorldLength
    tLocH = 1
    repeat while tLocH <= tWorldWidth
      tTile = me.parse_tile(tConn)
      if tTile.getAt(#teamId) > 0 then
        tTile.setAt(#x, tLocH - 1)
        tTile.setAt(#y, tLocV - 1)
        tWorld.add(tTile)
      end if
      tHeightMap = tHeightMap & "0"
      tLocH = 1 + tLocH
    end repeat
    tHeightMap = tHeightMap & "\r"
    tLocV = 1 + tLocV
  end repeat
  tdata.addProp(#flood, tWorld)
  tHeightMap = tConn.GetStrFrom()
  me.store_heightmap(tHeightMap, tWorldWidth, tWorldLength)
  repeat while me <= undefined
    tGameObject = getAt(undefined, tMsg)
    if tGameSystem.getGameObject(tGameObject.getAt(#id)) = 0 then
      tGameSystem.sendGameSystemEvent(#create_game_object, tGameObject)
    else
      tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
    end if
  end repeat
  tGameSystem.sendGameSystemEvent(#gamereset, tdata)
  tGameSystem.sendGameSystemEvent(#fullgamestatus_tiles, tdata.getAt(#flood))
  return(1)
  exit
end

on store_heightmap(me, tdata, tWorldWidth, tWorldHeight)
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return(0)
  end if
  tRoomComponent.getInterface().getGeometry().loadHeightMap(tdata)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  return(tGameSystem.getWorld().storeHeightmap(tdata, tWorldWidth, tWorldHeight))
  exit
end

on handle_gameplayerinfo(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tNumPlayers = tConn.GetIntFrom()
  i = 1
  repeat while i <= tNumPlayers
    tID = tConn.GetIntFrom()
    tValue = tConn.GetStrFrom()
    tSkill = tConn.GetStrFrom()
    tdata.addProp(string(tID), [#id:tID, #skillvalue:tValue, #skilllevel:tSkill])
    i = 1 + i
  end repeat
  return(me.getGameSystem().sendGameSystemEvent(#gameplayerinfo, tdata))
  exit
end

on parse_created_instance(me, tConn)
  tResult = []
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, me.parse_team_player(tConn))
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  tResult.addProp(#state, #created)
  return(tResult)
  exit
end

on parse_started_instance(me, tConn)
  tResult = []
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name:tConn.GetStrFrom()])
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  tResult.addProp(#state, #started)
  return(tResult)
  exit
end

on parse_finished_instance(me, tConn)
  tResult = []
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name:tConn.GetStrFrom()])
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  tResult.addProp(#state, #finished)
  return(tResult)
  exit
end

on parse_team_player(me, tConn)
  tResult = []
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  return(tResult)
  exit
end

on parse_tile(me, tConn)
  tdata = []
  tdata.addProp(#teamId, tConn.GetIntFrom())
  tdata.addProp(#jumps, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_info_player_update(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  tdata.addProp(#state, tConn.GetIntFrom())
  tdata.addProp(#coloringForOpponentTeamId, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_info_player_full(me, tConn)
  tdata = []
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
  return(tdata)
  exit
end

on parse_info_powerup_full(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#timetolive, tConn.GetIntFrom())
  tdata.addProp(#holdingplayer, tConn.GetIntFrom())
  tdata.addProp(#powerupType, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_info_pin_full(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_info_powerup_update(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#timetolive, tConn.GetIntFrom())
  tdata.addProp(#holdingplayer, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_info_pin_update(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_info_gameobject_full(me, tConn)
  tObjectType = tConn.GetIntFrom()
  if me = 0 then
    tdata = me.parse_info_player_full(tConn)
    tStrType = "player"
  else
    if me = 1 then
      tdata = me.parse_info_powerup_full(tConn)
      tStrType = "powerup"
    else
      if me = 2 then
        tdata = me.parse_info_pin_full(tConn)
        tStrType = "pin"
      else
        error(me, "Unsupported game object type:" && tObjectType, #parse_info_gameobject_full)
      end if
    end if
  end if
  if tdata = 0 then
    return(error(me, "Cannot parse gameobject data from server", #parse_info_gameobject_full))
  end if
  tdata.addProp(#type, tObjectType)
  tdata.addProp(#str_type, tStrType)
  tExtraProps = []
  tSystemId = me.getGameSystem().getID()
  repeat while me <= undefined
    tProp = getAt(undefined, tConn)
    if variableExists(tSystemId & ".gameobject." & tdata.getAt(#str_type) & "." & tProp) then
      tdata.addProp(symbol("gameobject_" & tProp), getVariable(tSystemId & ".gameobject." & tdata.getAt(#str_type) & "." & tProp))
    end if
  end repeat
  return(tdata)
  exit
end

on parse_info_gameobject_update(me, tConn)
  tObjectType = tConn.GetIntFrom()
  if me = 0 then
    tdata = me.parse_info_player_update(tConn)
    tStrType = "player"
  else
    if me = 1 then
      tdata = me.parse_info_powerup_update(tConn)
      tStrType = "powerup"
    else
      if me = 2 then
        tdata = me.parse_info_pin_update(tConn)
        tStrType = "pin"
      else
        return(error(me, "Unknown object type!" && tObjectType, #parse_info_gameobject_update))
      end if
    end if
  end if
  tdata.addProp(#type, tObjectType)
  tdata.addProp(#str_type, tStrType)
  return(tdata)
  exit
end

on parse_event(me, tConn)
  tEvent = []
  tEvent.addProp(#type, tConn.GetIntFrom())
  if me = 0 then
    tEvent.addProp(#data, me.parse_info_gameobject_full(tConn))
  else
    if me = 1 then
      tEvent.addProp(#id, tConn.GetIntFrom())
    else
      if me = 2 then
        tEvent.addProp(#id, tConn.GetIntFrom())
        tEvent.addProp(#goalx, tConn.GetIntFrom())
        tEvent.addProp(#goaly, tConn.GetIntFrom())
      else
        if me = 3 then
          tEvent.addProp(#playerId, tConn.GetIntFrom())
          tEvent.addProp(#powerupid, tConn.GetIntFrom())
          tEvent.addProp(#powerupType, tConn.GetIntFrom())
        else
          if me = 5 then
            tEvent.addProp(#playerId, tConn.GetIntFrom())
            tEvent.addProp(#powerupid, tConn.GetIntFrom())
            tEvent.addProp(#effectdirection, tConn.GetIntFrom())
            tEvent.addProp(#powerupType, tConn.GetIntFrom())
          else
            error(me, "Undefined event type:" && tEvent.getAt(#type), #parse_event)
          end if
        end if
      end if
    end if
  end if
  return(tEvent)
  exit
end