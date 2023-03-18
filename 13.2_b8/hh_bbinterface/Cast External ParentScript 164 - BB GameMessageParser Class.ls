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
  repeat with i = 1 to tCreatedCount
    tInstance = me.parse_created_instance(tConn)
    tResult.addProp(string(tInstance[#id]), tInstance)
  end repeat
  tStartedCount = tConn.GetIntFrom()
  repeat with i = 1 to tStartedCount
    tInstance = me.parse_started_instance(tConn)
    tResult.addProp(string(tInstance[#id]), tInstance)
  end repeat
  tFinishedCount = tConn.GetIntFrom()
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
  tstate = [#created, #started, #finished][tStateInt]
  tdata.addProp(#state, tstate)
  tdata.addProp(#time, [#state: tstate, #time_to_next_state: tConn.GetIntFrom(), #state_duration: tConn.GetIntFrom()])
  tNumPlayers = tConn.GetIntFrom()
  tPlayers = []
  repeat with i = 1 to tNumPlayers
    tPlayers.add(me.parse_fullgamestatus_player(tConn))
  end repeat
  tdata.addProp(#players, tPlayers)
  tWorldLength = tConn.GetIntFrom()
  tWorldWidth = tConn.GetIntFrom()
  tWorld = []
  repeat with tLocH = 1 to tWorldWidth
    repeat with tLocV = 1 to tWorldLength
      tTile = me.parse_tile(tConn)
      if tTile[#teamId] > -1 then
        tTile[#locX] = tLocH - 1
        tTile[#locY] = tLocV - 1
        tWorld.add(tTile)
      end if
    end repeat
  end repeat
  tdata.addProp(#flood, tWorld)
  tNumSubturns = tConn.GetIntFrom()
  tNumEvents = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumEvents
    tEvent = [:]
    tEvent.addProp(#type, tConn.GetIntFrom())
    case tEvent[#type] of
      0:
        tEvent.addProp(#data, me.parse_fullgamestatus_player(tConn))
      1:
        tEvent.addProp(#id, tConn.GetIntFrom())
      2:
        tEvent.addProp(#id, tConn.GetIntFrom())
        tEvent.addProp(#goalx, tConn.GetIntFrom())
        tEvent.addProp(#goaly, tConn.GetIntFrom())
    end case
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
  tGameSystem.sendGameSystemEvent(#fullgamestatus_time, tdata[#time])
  tGameSystem.sendGameSystemEvent(#fullgamestatus_players, tdata[#players])
  tGameSystem.sendGameSystemEvent(#fullgamestatus_tiles, tdata[#flood])
  tGameSystem.sendGameSystemEvent(#gamestatus_events, tdata[#events])
  return 1
end

on handle_gamestatus me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tNumChangedPlayers = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumChangedPlayers
    tList.add(me.parse_gamestatus_player(tConn))
  end repeat
  tdata.addProp(#players, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumChangedTiles
    tTile = [:]
    tTile.addProp(#locX, tConn.GetIntFrom())
    tTile.addProp(#locY, tConn.GetIntFrom())
    tTile.addProp(#teamId, tConn.GetIntFrom())
    tTile.addProp(#jumps, tConn.GetIntFrom())
    tList.add(tTile)
  end repeat
  tdata.addProp(#tiles, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumChangedTiles
    tTile = [:]
    tTile.addProp(#locX, tConn.GetIntFrom())
    tTile.addProp(#locY, tConn.GetIntFrom())
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
    tEvent = [:]
    tEvent.addProp(#type, tConn.GetIntFrom())
    case tEvent[#type] of
      0:
        tEvent.addProp(#data, me.parse_fullgamestatus_player(tConn))
      1:
        tEvent.addProp(#id, tConn.GetIntFrom())
      2:
        tEvent.addProp(#id, tConn.GetIntFrom())
        tEvent.addProp(#goalx, tConn.GetIntFrom())
        tEvent.addProp(#goaly, tConn.GetIntFrom())
    end case
    tList.add(tEvent)
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  tGameSystem.sendGameSystemEvent(#gamestatus_players, tdata[#players])
  tGameSystem.sendGameSystemEvent(#gamestatus_tiles, tdata[#tiles])
  tGameSystem.sendGameSystemEvent(#gamestatus_flood, tdata[#flood])
  tGameSystem.sendGameSystemEvent(#gamestatus_scores, tdata[#scores])
  tGameSystem.sendGameSystemEvent(#gamestatus_events, tdata[#events])
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
      tPlayerScore = tConn.GetIntFrom()
      tPlayers.addProp(string(tPlayerId), [#id: tPlayerId, #score: tPlayerScore])
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
  tdata.addProp(#time_until_game_start, tConn.GetIntFrom())
  tNumPlayers = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tNumPlayers
    tList.add(me.parse_gamestatus_player(tConn))
  end repeat
  tdata.addProp(#players, tList)
  return me.getGameSystem().sendGameSystemEvent(#gamereset, tdata)
end

on handle_gameplayerinfo me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tNumPlayers = tConn.GetIntFrom()
  repeat with i = 1 to tNumPlayers
    tid = tConn.GetIntFrom()
    tValue = tConn.GetStrFrom()
    tSkill = tConn.GetStrFrom()
    tdata.addProp(string(tid), [#id: tid, #skillvalue: tValue, #skilllevel: tSkill])
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#gameplayerinfo, tdata)
end

on parse_created_instance me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, me.parse_team_player(tConn))
  tResult.addProp(#state, #created)
  return tResult
end

on parse_started_instance me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name: tConn.GetStrFrom()])
  tResult.addProp(#state, #started)
  return tResult
end

on parse_finished_instance me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name: tConn.GetStrFrom()])
  tResult.addProp(#state, #finished)
  return tResult
end

on parse_team_player me, tConn
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  return tResult
end

on parse_fullgamestatus_player me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#locX, tConn.GetIntFrom())
  tdata.addProp(#locY, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  tdata.addProp(#name, tConn.GetStrFrom())
  tdata.addProp(#mission, tConn.GetStrFrom())
  tdata.addProp(#figure, tConn.GetStrFrom())
  tdata.addProp(#sex, tConn.GetStrFrom())
  tdata.addProp(#teamId, tConn.GetIntFrom())
  return tdata
end

on parse_tile me, tConn
  tdata = [:]
  tdata.addProp(#teamId, tConn.GetIntFrom())
  tdata.addProp(#jumps, tConn.GetIntFrom())
  return tdata
end

on parse_gamestatus_player me, tConn
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#locX, tConn.GetIntFrom())
  tdata.addProp(#locY, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  return tdata
end

on clonePlayers me, tdata
  tResult = tdata.duplicate()
  repeat with i = 1 to 11
    tNew = tdata[1].duplicate()
    tNew[#id] = tNew[#id] + i
    tResult.add(tdata)
  end repeat
  return tResult
end
