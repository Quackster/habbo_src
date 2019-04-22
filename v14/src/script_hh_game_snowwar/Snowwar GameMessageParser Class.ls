on construct me 
  return(1)
end

on deconstruct me 
  return(1)
end

on Refresh me, tTopic, tdata 
  call(symbol("handle_" & tTopic), me, tdata)
  return(1)
end

on handle_msgstruct_objects me, tdata 
  tList = []
  tCount = content.count(#line)
  i = 1
  repeat while i <= tCount
    tLine = content.getProp(#line, i)
    if length(tLine) > 5 then
      tObj = [:]
      tObj.setAt(#id, tLine.getProp(#word, 1))
      tObj.setAt(#class, tLine.getProp(#word, 2))
      tObj.setAt(#x, integer(tLine.getProp(#word, 3)))
      tObj.setAt(#y, integer(tLine.getProp(#word, 4)))
      tObj.setAt(#h, integer(tLine.getProp(#word, 5)))
      if tLine.count(#word) = 6 then
        tdir = integer(tLine.getProp(#word, 6)) mod 8
        tObj.setAt(#direction, [tdir, tdir, tdir])
        tObj.setAt(#dimensions, 0)
      else
        tWidth = integer(tLine.getProp(#word, 6))
        tHeight = integer(tLine.getProp(#word, 7))
        tObj.setAt(#dimensions, [tWidth, tHeight])
        tObj.setAt(#x, tObj.getAt(#x) + tObj.getAt(#width) - 1)
        tObj.setAt(#y, tObj.getAt(#y) + tObj.getAt(#height) - 1)
      end if
      tVarKey = "snowwar.object_" & tObj.getAt(#class) & ".height"
      if variableExists(tVarKey) then
        tObj.setAt(#height, getIntVariable(tVarKey))
      else
        tObj.setAt(#height, 0)
      end if
      if tObj.getAt(#id) <> "" then
        tList.add(tObj)
      end if
    end if
    i = 1 + i
  end repeat
  return(me.getGameSystem().getWorld().storeObjects(tList))
end

on handle_msgstruct_instancelist me, tMsg 
  tConn = tMsg.connection
  tResult = [:]
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
end

on handle_msgstruct_gameinstance me, tMsg 
  tConn = tMsg.connection
  tStateInt = tConn.GetIntFrom()
  tstate = [#created, #started, #finished].getAt(tStateInt + 1)
  if tstate = #created then
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
    if tstate = #started then
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
      if tstate = #finished then
        tResult = me.parse_finished_instance(tConn)
        tNumTeams = tConn.GetIntFrom()
        tTeamsUnsorted = []
        i = 1
        repeat while i <= tNumTeams
          tList = [#players:[]]
          tNumPlayers = tConn.GetIntFrom()
          j = 1
          repeat while j <= tNumPlayers
            tPlayer = [:]
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
            tPlayer = [:]
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
          tTeams.add(tList)
          tTeamId = 1 + tTeamId
        end repeat
        tPlayerPos = 1
        tResult.addProp(#teams, tTeams)
      end if
    end if
  end if
  tResult.addProp(#state, tstate)
  return(me.getGameSystem().sendGameSystemEvent(#gameinstance, tResult))
end

on handle_msgstruct_fullgamestatus me, tMsg 
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tConn = tMsg.connection
  tdata = [:]
  tStateInt = tConn.GetIntFrom()
  tstate = [#created, #started, #finished].getAt(tStateInt)
  tdata.addProp(#state, tstate)
  tdata.addProp(#time, [#state:tstate, #time_to_next_state:tConn.GetIntFrom(), #state_duration:tConn.GetIntFrom()])
  tNumObjects = tConn.GetIntFrom()
  tObjectIdList = []
  tGameObjects = []
  i = 1
  repeat while i <= tNumObjects
    tGameObject = me.parse_snowwar_gameobject(tConn)
    if listp(tGameObject) then
      tGameObjects.add(tGameObject)
      tObjectIdList.add(string(tGameObject.getAt(#id)))
    end if
    i = 1 + i
  end repeat
  tdata.addProp(#game_objects, tGameObjects)
  tGameSystem.getVarMgr().set(#tournament_flag, tConn.GetBoolFrom())
  tGameSystem.sendGameSystemEvent(#set_number_of_teams, tConn.GetIntFrom())
  tGameSystem.sendGameSystemEvent(#fullgamestatus_time, tdata.getAt(#time))
  tGameSystem.clearTurnBuffer()
  tGameSystem.sendGameSystemEvent(#verify_game_object_id_list, tObjectIdList)
  repeat while tdata.getAt(#game_objects) <= undefined
    tGameObject = getAt(undefined, tMsg)
    if tGameSystem.getGameObject(tGameObject.getAt(#id)) = 0 then
      tGameSystem.sendGameSystemEvent(#create_game_object, tGameObject)
    else
      tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
    end if
  end repeat
  tGameSystem.sendGameSystemEvent(#update_game_visuals)
  tGameSystem.startTurnManager()
  return(me.parse_gamestatus(tConn))
end

on handle_msgstruct_gamestart me, tMsg 
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#time_until_game_end, tConn.GetIntFrom())
  return(me.getGameSystem().sendGameSystemEvent(#gamestart, tdata))
end

on handle_msgstruct_gameend me, tMsg 
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#time_until_game_reset, tConn.GetIntFrom())
  tNumTeams = tConn.GetIntFrom()
  tTeamScores = []
  tTeamNum = 1
  repeat while tTeamNum <= tNumTeams
    tNumPlayers = tConn.GetIntFrom()
    tPlayers = [:]
    tPlayer = 1
    repeat while tPlayer <= tNumPlayers
      tPlayerId = tConn.GetIntFrom()
      tPlayerName = tConn.GetStrFrom()
      tPlayerScore = tConn.GetIntFrom()
      tPlayers.addProp(tPlayerName, [#id:tPlayerId, #name:tPlayerName, #score:tPlayerScore])
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
end

on handle_msgstruct_gamereset me, tMsg 
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#time_until_game_start, tConn.GetIntFrom())
  tNumObjects = tConn.GetIntFrom()
  tGameObjects = []
  tObjectIdList = []
  i = 1
  repeat while i <= tNumObjects
    tGameObject = me.parse_snowwar_gameobject(tConn)
    if listp(tGameObject) then
      tGameObjects.add(tGameObject)
      tObjectIdList.add(string(tGameObject.getAt(#id)))
    end if
    i = 1 + i
  end repeat
  tdata.addProp(#game_objects, tGameObjects)
  tGameSystem = me.getGameSystem()
  tGameSystem.clearTurnBuffer()
  tGameSystem.sendGameSystemEvent(#verify_game_object_id_list, tObjectIdList)
  repeat while tdata.getAt(#game_objects) <= undefined
    tGameObject = getAt(undefined, tMsg)
    if tGameSystem.getGameObject(tGameObject.getAt(#id)) = 0 then
      tGameSystem.sendGameSystemEvent(#create_game_object, tGameObject)
    else
      tGameSystem.sendGameSystemEvent(#update_game_object, tGameObject)
    end if
  end repeat
  tGameSystem.sendGameSystemEvent(#update_game_visuals)
  return(tGameSystem.sendGameSystemEvent(#gamereset, tdata))
end

on handle_msgstruct_gameplayerinfo me, tMsg 
  tConn = tMsg.connection
  tdata = [:]
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
end

on handle_msgstruct_gamestatus me, tMsg 
  tConn = tMsg.connection
  return(me.parse_gamestatus(tConn))
end

on parse_gamestatus me, tConn 
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tTurnNum = tConn.GetIntFrom()
  tCheckSum = tConn.GetIntFrom()
  tNumSubturns = tConn.GetIntFrom()
  tTurn = tGameSystem.getNewTurnContainer()
  if not objectp(tTurn) then
    return(error(me, "Cannot create turn container!", #parse_gamestatus))
  end if
  tTurn.SetNumber(tTurnNum)
  tTurn.SetChecksum(tCheckSum)
  tSubTurnIndex = []
  tSubTurnNum = 1
  repeat while tSubTurnNum <= tNumSubturns
    tSubTurnIndex.setAt(tSubTurnNum, [])
    tNumEvents = tConn.GetIntFrom()
    tEventNum = 1
    repeat while tEventNum <= tNumEvents
      tEvent = me.parse_event(tConn)
      if tEvent = 0 then
        return(error(me, "SERVER ERROR: No event received when expected!", #parse_gamestatus))
      end if
      tTurn.AddElement(tSubTurnNum, tEvent)
      tEventNum = 1 + tEventNum
    end repeat
    if tNumEvents = 0 then
      tTurn.AddElement(tSubTurnNum, void())
    end if
    tSubTurnNum = 1 + tSubTurnNum
  end repeat
  return(tGameSystem.sendGameSystemEvent(#gamestatus_turn, tTurn))
end

on parse_snowwar_gameobject me, tConn 
  tdata = [:]
  tdata.addProp(#type, tConn.GetIntFrom())
  tid = tConn.GetIntFrom()
  tdata.addProp(#int_id, tid)
  tdata.addProp(#id, string(tid))
  if tdata.getAt(#type) = 0 then
    tObjectData = me.parse_snowwar_player_gameobjectvariables(tdata.duplicate(), tConn)
    tdata.addProp(#objectDataStruct, tObjectData)
    tdata.addProp(#str_type, "player")
  else
    if tdata.getAt(#type) = 1 then
      tObjectData = me.parse_snowwar_snowball_gameobjectvariables(tdata.duplicate(), tConn)
      tdata.addProp(#objectDataStruct, tObjectData)
      tdata.addProp(#str_type, "snowball")
    else
      if tdata.getAt(#type) = 2 then
        return(0)
      else
        if tdata.getAt(#type) = 3 then
          tObjectData = me.parse_snowwar_large_snowball_gameobjectvariables(tdata.duplicate(), tConn)
          tdata.addProp(#objectDataStruct, tObjectData)
          tdata.addProp(#str_type, "large_snowball")
        else
          if tdata.getAt(#type) = 4 then
            tObjectData = me.parse_snowwar_snowball_machine_gameobjectvariables(tdata.duplicate(), tConn)
            tdata.addProp(#objectDataStruct, tObjectData)
            tdata.addProp(#str_type, "snowball_machine")
          else
            if tdata.getAt(#type) = 5 then
              tObjectData = me.parse_snowwar_avatar_gameobjectvariables(tdata.duplicate(), tConn)
              tdata.addProp(#objectDataStruct, tObjectData)
              i = 1
              repeat while i <= tObjectData.count
                tdata.addProp(tObjectData.getPropAt(i), tObjectData.getAt(i))
                i = 1 + i
              end repeat
              tdata.addProp(#human_id, tdata.getAt(#id))
              tdata.addProp(#dirBody, tdata.getAt(#body_direction))
              tdata.addProp(#name, tConn.GetStrFrom())
              tdata.addProp(#mission, tConn.GetStrFrom())
              tdata.addProp(#figure, tConn.GetStrFrom())
              tdata.addProp(#sex, tConn.GetStrFrom())
              tdata.addProp(#str_type, "avatar")
            else
              error(me, "Unsupported game object type:" && tdata.getAt(#type), #parse_snowwar_gameobject)
            end if
          end if
        end if
      end if
    end if
  end if
  tExtraProps = ["collisionshape_type", "height", "collisionshape_radius"]
  repeat while tdata.getAt(#type) <= undefined
    tProp = getAt(undefined, tConn)
    if variableExists("snowwar.object_" & tdata.getAt(#str_type) & "." & tProp) then
      tdata.addProp(symbol("gameobject_" & tProp), getVariable("snowwar.object_" & tdata.getAt(#str_type) & "." & tProp))
    end if
  end repeat
  return(tdata)
end

on parse_snowwar_snowball_gameobjectvariables me, tdata, tConn 
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#z, tConn.GetIntFrom())
  tdata.addProp(#movement_direction, tConn.GetIntFrom())
  tdata.addProp(#trajectory, tConn.GetIntFrom())
  tdata.addProp(#time_to_live, tConn.GetIntFrom())
  tdata.addProp(#int_thrower_id, tConn.GetIntFrom())
  tdata.addProp(#parabola_offset, tConn.GetIntFrom())
  return(tdata)
end

on parse_snowwar_player_gameobjectvariables me, tdata, tConn 
  tdata.addProp(#room_index, tConn.GetIntFrom())
  tdata.addProp(#human_id, tConn.GetIntFrom())
  return(tdata)
end

on parse_snowwar_avatar_gameobjectvariables me, tdata, tConn 
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#body_direction, tConn.GetIntFrom())
  tdata.addProp(#hit_points, tConn.GetIntFrom())
  tdata.addProp(#snowball_count, tConn.GetIntFrom())
  tdata.addProp(#is_bot, tConn.GetIntFrom())
  tdata.addProp(#activity_timer, tConn.GetIntFrom())
  tdata.addProp(#activity_state, tConn.GetIntFrom())
  tdata.addProp(#next_tile_x, tConn.GetIntFrom())
  tdata.addProp(#next_tile_y, tConn.GetIntFrom())
  tdata.addProp(#move_target_x, tConn.GetIntFrom())
  tdata.addProp(#move_target_y, tConn.GetIntFrom())
  tdata.addProp(#score, tConn.GetIntFrom())
  tdata.addProp(#player_id, tConn.GetIntFrom())
  tdata.addProp(#team_id, tConn.GetIntFrom())
  tdata.addProp(#room_index, tConn.GetIntFrom())
  return(tdata)
end

on parse_snowwar_large_snowball_gameobjectvariables me, tdata, tConn 
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  return(tdata)
end

on parse_snowwar_snowball_machine_gameobjectvariables me, tdata, tConn 
  tdata.addProp(#x, tConn.GetIntFrom())
  tdata.addProp(#y, tConn.GetIntFrom())
  tdata.addProp(#snowball_count, tConn.GetIntFrom())
  return(tdata)
end

on parse_event me, tConn 
  tEventType = tConn.GetIntFrom()
  if tEventType = 0 then
    tEvent = me.parse_snowwar_gameobject(tConn)
    tEvent.addProp(#event_type, 0)
  else
    if tEventType = 1 then
      tIntKeyList = [#int_id]
    else
      if tEventType = 2 then
        tIntKeyList = [#int_id, #x, #y]
      else
        if tEventType = 3 then
          tIntKeyList = [#int_id, #int_target_id, #throw_height]
        else
          if tEventType = 4 then
            tIntKeyList = [#int_id, #targetX, #targetY, #throw_height]
          else
            if tEventType = 5 then
              tIntKeyList = [#int_thrower_id, #int_id, #hit_direction]
            else
              if tEventType = 6 then
                tIntKeyList = [#x, #y]
              else
                if tEventType = 7 then
                  tIntKeyList = [#int_id]
                else
                  if tEventType = 8 then
                    tIntKeyList = [#int_id, #int_thrower_id, #targetX, #targetY, #trajectory]
                  else
                    if tEventType = 9 then
                      tIntKeyList = [#int_id, #int_thrower_id, #hit_direction]
                    else
                      if tEventType = 10 then
                        tIntKeyList = []
                      else
                        if tEventType = 11 then
                          tIntKeyList = [#int_machine_id]
                        else
                          if tEventType = 12 then
                            tIntKeyList = [#int_player_id, #int_machine_id]
                          else
                            return(error(me, "Undefined event sent by server, parsing cannot continue!", #handle_gamestatus))
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  if listp(tIntKeyList) then
    tEvent = [#event_type:tEventType]
    repeat while tEventType <= undefined
      tKey = getAt(undefined, tConn)
      tEvent.addProp(tKey, tConn.GetIntFrom())
    end repeat
    if tEvent.findPos(#int_id) > 0 then
      tEvent.addProp(#id, string(tEvent.getAt(#int_id)))
    end if
  end if
  return(tEvent)
end

on parse_created_instance me, tConn 
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, me.parse_team_player(tConn))
  tResult.addProp(#state, #created)
  tResult.addProp(#gameLength, tConn.GetIntFrom())
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  return(tResult)
end

on parse_started_instance me, tConn 
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name:tConn.GetStrFrom()])
  tResult.addProp(#state, #started)
  tResult.addProp(#gameLength, tConn.GetIntFrom())
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  return(tResult)
end

on parse_finished_instance me, tConn 
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  tResult.addProp(#host, [#name:tConn.GetStrFrom()])
  tResult.addProp(#state, #finished)
  tResult.addProp(#gameLength, tConn.GetIntFrom())
  tResult.addProp(#fieldType, tConn.GetIntFrom())
  return(tResult)
end

on parse_team_player me, tConn 
  tResult = [:]
  tResult.addProp(#id, tConn.GetIntFrom())
  tResult.addProp(#name, tConn.GetStrFrom())
  return(tResult)
end

on parse_gamestatus_player me, tConn 
  tdata = [:]
  tdata.addProp(#id, tConn.GetIntFrom())
  tdata.addProp(#locX, tConn.GetIntFrom())
  tdata.addProp(#locY, tConn.GetIntFrom())
  tdata.addProp(#dirBody, tConn.GetIntFrom())
  return(tdata)
end
