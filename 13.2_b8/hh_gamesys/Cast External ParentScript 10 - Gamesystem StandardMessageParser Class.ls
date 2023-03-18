on construct me
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  call(symbol("handle_" & tTopic), me, tdata)
  return 1
end

on handle_msgstruct_numtickets me, tMsg
  tNum = integer(tMsg.content.line[1].word[1])
  if not integerp(tNum) then
    return 0
  end if
  return me.getGameSystem().sendGameSystemEvent(#numtickets, tNum)
end

on handle_msgstruct_notickets me, tMsg
  return me.getGameSystem().sendGameSystemEvent(#notickets, VOID)
end

on handle_msgstruct_users me, tMsg
  return me.getGameSystem().sendGameSystemEvent(#users, tMsg)
end

on handle_msgstruct_loungeinfo me, tMsg
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#tournament_flag, tConn.GetIntFrom())
  if tdata[#tournament_flag] > 0 then
    tdata.addProp(#tournament_logo_url, tConn.GetStrFrom())
    tdata.addProp(#tournament_logo_click_url, tConn.GetStrFrom())
  end if
  tdata.addProp(#lounge_skill_name, tConn.GetStrFrom())
  tdata.addProp(#lounge_skill_score_min, tConn.GetIntFrom())
  tdata.addProp(#lounge_skill_score_max, tConn.GetIntFrom())
  return me.getGameSystem().sendGameSystemEvent(#loungeinfo, tdata)
end

on handle_msgstruct_instancenotavailable me, tMsg
  tConn = tMsg.connection
  tid = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#instancenotavailable, tid)
end

on handle_msgstruct_gameparameters me, tMsg
  tConn = tMsg.connection
  tParamCount = tConn.GetIntFrom()
  tParamList = []
  repeat with i = 1 to tParamCount
    tItem = [:]
    tItem.addProp(#name, tConn.GetStrFrom())
    ttype = tConn.GetIntFrom()
    tItem.addProp(#editable, tConn.GetIntFrom())
    if ttype = 0 then
      tItem.addProp(#type, #integer)
      tItem.addProp(#default, tConn.GetIntFrom())
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#min, tConn.GetIntFrom())
      end if
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#max, tConn.GetIntFrom())
      end if
    else
      tItem.addProp(#type, #string)
      tItem.addProp(#default, tConn.GetStrFrom())
      tItem.addProp(#choices, [])
      tNumChoices = tConn.GetIntFrom()
      if tNumChoices > 0 then
        repeat with i = 1 to tNumChoices
          tItem[#choices].append(tConn.GetStrFrom)
        end repeat
      end if
    end if
    tParamList.append(tItem)
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#gameparameters, tParamList)
end

on handle_msgstruct_createfailed me, tMsg
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  if tReason = 1 then
    tdata = [#reason: tReason, #request: "create", #key: tConn.GetStrFrom()]
  else
    tdata = [#reason: tReason, #request: "create"]
  end if
  return me.getGameSystem().sendGameSystemEvent(#createfailed, tdata)
end

on handle_msgstruct_gamedeleted me, tMsg
  tConn = tMsg.connection
  tid = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#gamedeleted, tid)
end

on handle_msgstruct_joinparameters me, tMsg
  tConn = tMsg.connection
  tInstanceId = tConn.GetIntFrom()
  tParamCount = tConn.GetIntFrom()
  tParamList = []
  repeat with i = 1 to tParamCount
    tItem = [:]
    tItem.addProp(#name, tConn.GetStrFrom())
    ttype = tConn.GetIntFrom()
    if ttype = 0 then
      tItem.addProp(#type, #integer)
      tItem.addProp(#default, tConn.GetIntFrom())
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#min, tConn.GetIntFrom())
      end if
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#max, tConn.GetIntFrom())
      end if
    else
      tItem.addProp(#type, #string)
      tItem.addProp(#default, tConn.GetStrFrom())
      tItem.addProp(#choices, [])
      tNumChoices = tConn.GetIntFrom()
      if tNumChoices > 0 then
        repeat with i = 1 to tNumChoices
          tItem[#choices].append(tConn.GetStrFrom)
        end repeat
      end if
    end if
    tParamList.append(tItem)
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#joinparameters, tParamList)
end

on handle_msgstruct_joinfailed me, tMsg
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  if tReason = 1 then
    tdata = [#request: "join", #reason: tReason, #key: tConn.GetStrFrom()]
  else
    tdata = [#request: "join", #reason: tReason]
  end if
  return me.getGameSystem().sendGameSystemEvent(#joinfailed, tdata)
end

on handle_msgstruct_watchfailed me, tMsg
  tConn = tMsg.connection
  tInstanceId = tConn.GetIntFrom()
  tReason = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#watchfailed, [#id: tInstanceId, #request: "watch", #reason: tReason])
end

on handle_msgstruct_startfailed me, tMsg
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#startfailed, [#reason: tReason, #request: "start"])
end

on handle_msgstruct_gamelocation me, tMsg
  tConn = tMsg.connection
  tUnitId = tConn.GetIntFrom()
  tWorldId = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#gamelocation, [#unitId: tUnitId, #worldId: tWorldId])
end

on handle_msgstruct_playerrejoined me, tMsg
  tConn = tMsg.connection
  tid = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#playerrejoined, [#id: tid])
end

on handle_msgstruct_idlewarning me, tMsg
  return me.getGameSystem().sendGameSystemEvent(#idlewarning, VOID)
end

on handle_msgstruct_skilllevelchanged me, tMsg
  tConn = tMsg.connection
  tLevel = tConn.GetStrFrom()
  return me.getGameSystem().sendGameSystemEvent(#skilllevelchanged, [#level: tLevel])
end

on handle_msgstruct_heightmap me, tdata
  tContent = tdata[#content]
  if ilk(tContent) <> #string then
    return 0
  end if
  if tContent.line[tContent.line.count] = EMPTY then
    delete char -30003 of tContent
  end if
  return me.getGameSystem().getWorld().storeHeightmap(tContent)
end

on handle_msgstruct_objects me, tdata
  tList = []
  tCount = tdata.content.line.count
  repeat with i = 1 to tCount
    tLine = tdata.content.line[i]
    if length(tLine) > 5 then
      tObj = [:]
      tObj[#id] = tLine.word[1]
      tObj[#class] = tLine.word[2]
      tObj[#x] = integer(tLine.word[3])
      tObj[#y] = integer(tLine.word[4])
      tObj[#h] = integer(tLine.word[5])
      if tLine.word.count = 6 then
        tdir = integer(tLine.word[6]) mod 8
        tObj[#direction] = [tdir, tdir, tdir]
        tObj[#dimensions] = 0
      else
        tWidth = integer(tLine.word[6])
        tHeight = integer(tLine.word[7])
        tObj[#dimensions] = [tWidth, tHeight]
        tObj[#x] = tObj[#x] + tObj[#width] - 1
        tObj[#y] = tObj[#y] + tObj[#height] - 1
      end if
      if tObj[#id] <> EMPTY then
        tList.add(tObj)
      end if
    end if
  end repeat
  return me.getGameSystem().getWorld().storeObjects(tList)
end
