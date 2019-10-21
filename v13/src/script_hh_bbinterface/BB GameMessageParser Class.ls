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
  i = 1
  repeat while i <= tCreatedCount
    tInstance = me.parse_created_instance(tConn)
    tResult.addProp(string(tInstance.getAt(#id)), tInstance)
    i = 1 + i
  end repeat
  tStartedCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tStartedCount
    tInstance = me.parse_started_instance(tConn)
    tResult.addProp(string(tInstance.getAt(#id)), tInstance)
    i = 1 + i
  end repeat
  tFinishedCount = tConn.GetIntFrom()
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
  tstate = [#created, #started, #finished].getAt(tStateInt)
  tdata.addProp(#state, tstate)
  tdata.addProp(#time, [#state:tstate, #time_to_next_state:tConn.GetIntFrom(), #state_duration:tConn.GetIntFrom()])
  tNumPlayers = tConn.GetIntFrom()
  tPlayers = []
  i = 1
  repeat while i <= tNumPlayers
    tPlayers.add(me.parse_fullgamestatus_player(tConn))
    i = 1 + i
  end repeat
  tdata.addProp(#players, tPlayers)
  tWorldLength = tConn.GetIntFrom()
  tWorldWidth = tConn.GetIntFrom()
  tWorld = []
  tLocH = 1
  repeat while tLocH <= tWorldWidth
    tLocV = 1
    repeat while tLocV <= tWorldLength
      tTile = me.parse_tile(tConn)
      if tTile.getAt(#teamId) > -1 then
        tTile.setAt(#locX, tLocH - 1)
        tTile.setAt(#locY, tLocV - 1)
        tWorld.add(tTile)
      end if
      tLocV = 1 + tLocV
    end repeat
    tLocH = 1 + tLocH
  end repeat
  tdata.addProp(#flood, tWorld)
  tNumSubturns = tConn.GetIntFrom()
  tNumEvents = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumEvents
    tEvent = []
    tEvent.addProp(#type, tConn.GetIntFrom())
    if me = 0 then
      tEvent.addProp(#data, me.parse_fullgamestatus_player(tConn))
    else
      if me = 1 then
        tEvent.addProp(#id, tConn.GetIntFrom())
      else
        if me = 2 then
          tEvent.addProp(#id, tConn.GetIntFrom())
          tEvent.addProp(#goalx, tConn.GetIntFrom())
          tEvent.addProp(#goaly, tConn.GetIntFrom())
        end if
      end if
    end if
    tList.add(tEvent)
    i = 1 + i
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  if not getObject(#session).exists(#gamespace_world_info) then
    return(0)
  end if
  tGameSpaceData = getObject(#session).get(#gamespace_world_info)
  if listp(tGameSpaceData) then
    tGameSystem.getVarMgr().set(#tournament_flag, tGameSpaceData.getAt(#tournament_flag))
  end if
  tGameSystem.sendGameSystemEvent(#fullgamestatus_time, tdata.getAt(#time))
  tGameSystem.sendGameSystemEvent(#fullgamestatus_players, tdata.getAt(#players))
  tGameSystem.sendGameSystemEvent(#fullgamestatus_tiles, tdata.getAt(#flood))
  tGameSystem.sendGameSystemEvent(#gamestatus_events, tdata.getAt(#events))
  return(1)
  exit
end

on handle_gamestatus(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tNumChangedPlayers = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumChangedPlayers
    tList.add(me.parse_gamestatus_player(tConn))
    i = 1 + i
  end repeat
  tdata.addProp(#players, tList)
  tNumChangedTiles = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumChangedTiles
    tTile = []
    tTile.addProp(#locX, tConn.GetIntFrom())
    tTile.addProp(#locY, tConn.GetIntFrom())
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
    tTile.addProp(#locX, tConn.GetIntFrom())
    tTile.addProp(#locY, tConn.GetIntFrom())
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
    tEvent = []
    tEvent.addProp(#type, tConn.GetIntFrom())
    if me = 0 then
      tEvent.addProp(#data, me.parse_fullgamestatus_player(tConn))
    else
      if me = 1 then
        tEvent.addProp(#id, tConn.GetIntFrom())
      else
        if me = 2 then
          tEvent.addProp(#id, tConn.GetIntFrom())
          tEvent.addProp(#goalx, tConn.GetIntFrom())
          tEvent.addProp(#goaly, tConn.GetIntFrom())
        end if
      end if
    end if
    tList.add(tEvent)
    i = 1 + i
  end repeat
  tdata.addProp(#events, tList)
  tGameSystem = me.getGameSystem()
  tGameSystem.sendGameSystemEvent(#gamestatus_players, tdata.getAt(#players))
  tGameSystem.sendGameSystemEvent(#gamestatus_tiles, tdata.getAt(#tiles))
  tGameSystem.sendGameSystemEvent(#gamestatus_flood, tdata.getAt(#flood))
  tGameSystem.sendGameSystemEvent(#gamestatus_scores, tdata.getAt(#scores))
  tGameSystem.sendGameSystemEvent(#gamestatus_events, tdata.getAt(#events))
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
      tPlayerScore = tConn.GetIntFrom()
      tPlayers.addProp(string(tPlayerId), [#id:tPlayerId, #score:tPlayerScore])
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
  tdata.addProp(#time_until_game_start, tConn.GetIntFrom())
  tNumPlayers = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tNumPlayers
    tList.add(me.parse_gamestatus_player(tConn))
    i = 1 + i
  end repeat
  tdata.addProp(#players, tList)
  return(me.getGameSystem().sendGameSystemEvent(#gamereset, tdata))
  exit
end

on handle_gameplayerinfo(me, tMsg)
  tConn = tMsg.connection
  tdata = []
  tNumPlayers = tConn.GetIntFrom()
  i = 1
  repeat while i <= tNumPlayers
    tid = tConn.GetIntFrom()
    tValue = tConn.GetStrFrom()
    tSkill = tConn.GetStrFrom()
    tdata.addProp(string(tid), [#id:tid, #skillvalue:tValue, #skilllevel:tSkill])
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
  tResult.addProp(#state, #created)
  return(tResult)
  exit
end

on parse_started_instance(me, tConn)
  tResult = []
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name:tConn.GetStrFrom()])
  tResult.addProp(#state, #started)
  return(tResult)
  exit
end

on parse_finished_instance(me, tConn)
  tResult = []
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name:tConn.GetStrFrom()])
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

on parse_fullgamestatus_player(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#locX, tConn.GetIntFrom())
  tdata.addProp(#locY, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  tdata.addProp(#name, tConn.GetStrFrom())
  tdata.addProp(#mission, tConn.GetStrFrom())
  tdata.addProp(#figure, tConn.GetStrFrom())
  tdata.addProp(#sex, tConn.GetStrFrom())
  tdata.addProp(#teamId, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_tile(me, tConn)
  tdata = []
  tdata.addProp(#teamId, tConn.GetIntFrom())
  tdata.addProp(#jumps, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parse_gamestatus_player(me, tConn)
  tdata = []
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#locX, tConn.GetIntFrom())
  tdata.addProp(#locY, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  return(tdata)
  exit
end

on clonePlayers(me, tdata)
  tResult = tdata.duplicate()
  i = 1
  repeat while i <= 11
    tNew = tdata.getAt(1).duplicate()
    tNew.setAt(#id, tNew.getAt(#id) + i)
    tResult.add(tdata)
    i = 1 + i
  end repeat
  return(tResult)
  exit
end