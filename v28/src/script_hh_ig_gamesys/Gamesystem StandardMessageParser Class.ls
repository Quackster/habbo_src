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

on handle_msgstruct_numtickets me, tMsg 
  tNum = integer(tMsg.getPropRef(#line, 1).getProp(#word, 1))
  if not integerp(tNum) then
    return(0)
  end if
  return(me.getGameSystem().sendGameSystemEvent(#numtickets, tNum))
end

on handle_msgstruct_notickets me, tMsg 
  return(me.getGameSystem().sendGameSystemEvent(#notickets, void()))
end

on handle_msgstruct_users me, tMsg 
  return(me.getGameSystem().sendGameSystemEvent(#users, tMsg))
end

on handle_msgstruct_loungeinfo me, tMsg 
  tConn = tMsg.connection
  tdata = [:]
  tdata.addProp(#tournament_flag, tConn.GetIntFrom())
  if tdata.getAt(#tournament_flag) > 0 then
    tdata.addProp(#tournament_logo_url, tConn.GetStrFrom())
    tdata.addProp(#tournament_logo_click_url, tConn.GetStrFrom())
  end if
  tdata.addProp(#lounge_skill_name, tConn.GetStrFrom())
  tdata.addProp(#lounge_skill_score_min, tConn.GetIntFrom())
  tdata.addProp(#lounge_skill_score_max, tConn.GetIntFrom())
  return(me.getGameSystem().sendGameSystemEvent(#loungeinfo, tdata))
end

on handle_msgstruct_instancenotavailable me, tMsg 
  tConn = tMsg.connection
  tID = tConn.GetIntFrom()
  return(me.getGameSystem().sendGameSystemEvent(#instancenotavailable, tID))
end

on handle_msgstruct_gameparameters me, tMsg 
  tConn = tMsg.connection
  tParamCount = tConn.GetIntFrom()
  tParamList = []
  i = 1
  repeat while i <= tParamCount
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
        i = 1
        repeat while i <= tNumChoices
          tItem.getAt(#choices).append(tConn.GetStrFrom)
          i = 1 + i
        end repeat
      end if
    end if
    tParamList.append(tItem)
    i = 1 + i
  end repeat
  return(me.getGameSystem().sendGameSystemEvent(#gameparameters, tParamList))
end

on handle_msgstruct_createfailed me, tMsg 
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  if tReason = 1 then
    tdata = [#reason:tReason, #request:"create", #key:tConn.GetStrFrom()]
  else
    tdata = [#reason:tReason, #request:"create"]
  end if
  return(me.getGameSystem().sendGameSystemEvent(#createfailed, tdata))
end

on handle_msgstruct_gamedeleted me, tMsg 
  tConn = tMsg.connection
  tID = tConn.GetIntFrom()
  return(me.getGameSystem().sendGameSystemEvent(#gamedeleted, tID))
end

on handle_msgstruct_joinparameters me, tMsg 
  tConn = tMsg.connection
  tInstanceId = tConn.GetIntFrom()
  tParamCount = tConn.GetIntFrom()
  tParamList = []
  i = 1
  repeat while i <= tParamCount
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
        i = 1
        repeat while i <= tNumChoices
          tItem.getAt(#choices).append(tConn.GetStrFrom)
          i = 1 + i
        end repeat
      end if
    end if
    tParamList.append(tItem)
    i = 1 + i
  end repeat
  return(me.getGameSystem().sendGameSystemEvent(#joinparameters, tParamList))
end

on handle_msgstruct_joinfailed me, tMsg 
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  if tReason = 1 then
    tdata = [#request:"join", #reason:tReason, #key:tConn.GetStrFrom()]
  else
    tdata = [#request:"join", #reason:tReason]
  end if
  return(me.getGameSystem().sendGameSystemEvent(#joinfailed, tdata))
end

on handle_msgstruct_watchfailed me, tMsg 
  tConn = tMsg.connection
  tInstanceId = tConn.GetIntFrom()
  tReason = tConn.GetIntFrom()
  return(me.getGameSystem().sendGameSystemEvent(#watchfailed, [#id:tInstanceId, #request:"watch", #reason:tReason]))
end

on handle_msgstruct_startfailed me, tMsg 
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  return(me.getGameSystem().sendGameSystemEvent(#startfailed, [#reason:tReason, #request:"start"]))
end

on handle_msgstruct_gamelocation me, tMsg 
  tConn = tMsg.connection
  tUnitId = tConn.GetIntFrom()
  tWorldId = tConn.GetIntFrom()
  return(me.getGameSystem().sendGameSystemEvent(#gamelocation, [#unitId:tUnitId, #worldId:tWorldId]))
end

on handle_msgstruct_playerrejoined me, tMsg 
  tConn = tMsg.connection
  tID = tConn.GetIntFrom()
  return(me.getGameSystem().sendGameSystemEvent(#playerrejoined, [#id:tID]))
end

on handle_msgstruct_idlewarning me, tMsg 
  return(me.getGameSystem().sendGameSystemEvent(#idlewarning, void()))
end

on handle_msgstruct_skilllevelchanged me, tMsg 
  tConn = tMsg.connection
  tLevel = tConn.GetStrFrom()
  return(me.getGameSystem().sendGameSystemEvent(#skilllevelchanged, [#level:tLevel]))
end

on handle_msgstruct_heightmap me, tdata 
  tContent = tdata.getAt(#content)
  if ilk(tContent) <> #string then
    return(0)
  end if
  if tContent.getProp(#line, tContent.count(#line)) = "" then
  end if
  tWorldMaxY = tContent.count(#line)
  if tWorldMaxY < 1 then
    return(error(me, "World is under 1 lines long!", #handle_msgstruct_heightmap))
  end if
  tWorldMaxX = tContent.getPropRef(#line, 1).length
  tArray = []
  tLocY = 1
  repeat while tLocY <= tWorldMaxY
    tLocX = 1
    repeat while tLocX <= tWorldMaxX
      tArray.add(tContent.getPropRef(#line, tLocY).getProp(#char, tLocX))
      tLocX = 1 + tLocX
    end repeat
    tLocY = 1 + tLocY
  end repeat
  return(me.getGameSystem().getWorld().storeHeightmap(tArray, tWorldMaxX, tWorldMaxY))
end

on handle_msgstruct_objects me, tdata 
  tList = []
  tCount = tdata.count(#line)
  i = 1
  repeat while i <= tCount
    tLine = tdata.getProp(#line, i)
    if length(tLine) > 5 then
      tObj = [:]
      tObj.setAt(#id, tLine.getProp(#word, 1))
      tObj.setAt(#class, tLine.getProp(#word, 2))
      tObj.setAt(#x, integer(tLine.getProp(#word, 3)))
      tObj.setAt(#y, integer(tLine.getProp(#word, 4)))
      tObj.setAt(#h, integer(tLine.getProp(#word, 5)))
      if tLine.count(#word) = 6 then
        tdir = (integer(tLine.getProp(#word, 6)) mod 8)
        tObj.setAt(#direction, [tdir, tdir, tdir])
        tObj.setAt(#dimensions, 0)
      else
        tWidth = integer(tLine.getProp(#word, 6))
        tHeight = integer(tLine.getProp(#word, 7))
        tObj.setAt(#dimensions, [tWidth, tHeight])
        tObj.setAt(#x, tObj.getAt(#x) + tObj.getAt(#width) - 1)
        tObj.setAt(#y, tObj.getAt(#y) + tObj.getAt(#height) - 1)
      end if
      if tObj.getAt(#id) <> "" then
        tList.add(tObj)
      end if
    end if
    i = 1 + i
  end repeat
  return(me.getGameSystem().getWorld().storeObjects(tList))
end

on handle_msgstruct_game_chat me, tMsg 
  tConn = tMsg.connection
  tUserID = string(tConn.GetIntFrom())
  tChat = tConn.GetStrFrom()
  tMode = "CHAT"
  executeMessage(#show_balloon, [#command:tMode, #id:tUserID, #message:tChat])
end
