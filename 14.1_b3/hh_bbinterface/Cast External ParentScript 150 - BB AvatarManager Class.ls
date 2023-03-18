property pRoomComponentObj, pFigureSystemObj, pGoalLocationList, pCurrentLocationList, pExpectedLocationList

on construct me
  pGoalLocationList = [:]
  pCurrentLocationList = [:]
  pExpectedLocationList = [:]
  pRoomComponentObj = getObject(#room_component)
  if pRoomComponentObj = 0 then
    return error(me, "BB: Avatar manager failed to initialize", #construct)
  end if
  tClassContainer = pRoomComponentObj.getClassContainer()
  if tClassContainer = 0 then
    return error(me, "BB: Avatar manager failed to initialize", #construct)
  end if
  tClassContainer.set("bouncing.human.class", ["Human Class EX", "Bouncing Human Class"])
  registerMessage(#create_user, me.getID(), #handleUserCreated)
  return 1
end

on deconstruct me
  unregisterMessage(#create_user, me.getID())
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gamestatus_events:
      repeat with tEvent in tdata
        case tEvent[#type] of
          0:
            me.createRoomObject(tEvent[#data])
          1:
            me.deleteRoomObject(tEvent[#id])
          2:
            me.updateRoomObjectGoal(tEvent)
        end case
      end repeat
    #gamestatus_players:
      tUpdatedPlayers = []
      repeat with tPlayer in tdata
        me.updateRoomObjectLocation(tPlayer)
        tUpdatedPlayers.add(tPlayer[#id])
      end repeat
    #fullgamestatus_players:
      repeat with tPlayer in tdata
        me.createRoomObject(tPlayer)
      end repeat
    #gamereset:
      repeat with tPlayer in tdata[#players]
        pGoalLocationList.deleteProp(string(tPlayer[#id]))
        me.updateRoomObjectLocation(tPlayer)
      end repeat
    #gamestart:
      me.hideArrowHiliter()
  end case
  return 1
end

on createRoomObject me, tdata
  if pRoomComponentObj = 0 then
    return error(me, "BB: Room couldn't create avatar!", #createRoomObject)
  end if
  if pFigureSystemObj = VOID then
    pFigureSystemObj = getObject("Figure_System")
    if pFigureSystemObj = VOID then
      return error(me, "BB: Room couldn't create avatar!", #createRoomObject)
    end if
  end if
  tUserStrId = string(tdata[#id])
  tAvatarStruct = [:]
  tAvatarStruct.addProp(#id, tUserStrId)
  tAvatarStruct.addProp(#name, tdata[#name])
  tAvatarStruct.addProp(#direction, [tdata[#dirBody], 0])
  tAvatarStruct.addProp(#class, "bouncing.human.class")
  tAvatarStruct.addProp(#x, tdata[#locX])
  tAvatarStruct.addProp(#y, tdata[#locY])
  tAvatarStruct.addProp(#h, 0.0)
  tAvatarStruct.addProp(#custom, tdata[#mission])
  tAvatarStruct.addProp(#sex, tdata[#sex])
  tAvatarStruct.addProp(#teamId, tdata[#teamId])
  if tdata[#name] = getObject(#session).GET(#userName) then
    getObject(#session).set("user_index", tUserStrId)
  end if
  tFigure = pFigureSystemObj.parseFigure(tdata[#figure], tdata[#sex], "user")
  tTeamId = tdata[#teamId] + 1
  tTeamColors = [rgb("#E73929"), rgb("#217BEF"), rgb("#FFCE21"), rgb("#8CE700")]
  tBallModel = ["model": "001", "color": tTeamColors[tTeamId]]
  tFigure.addProp("bl", tBallModel)
  tAvatarStruct.addProp(#figure, tFigure)
  pCurrentLocationList.setaProp(tUserStrId, [tdata[#locX], tdata[#locY], tdata[#dirBody]])
  pGoalLocationList.setaProp(tUserStrId, VOID)
  if not pRoomComponentObj.validateUserObjects(tAvatarStruct) then
    return error(me, "BB: Room couldn't create avatar!", #createRoomObject)
  else
    return 1
  end if
end

on deleteRoomObject me, tid
  if pRoomComponentObj = 0 then
    return 0
  end if
  tUserStrId = string(tid)
  pGoalLocationList.deleteProp(tUserStrId)
  pCurrentLocationList.deleteProp(tUserStrId)
  pExpectedLocationList.deleteProp(tUserStrId)
  return pRoomComponentObj.removeUserObject(tUserStrId)
end

on updateRoomObjectLocation me, tuser
  if pRoomComponentObj = 0 then
    return 0
  end if
  if not (ilk(tuser) = #propList) then
    return 0
  end if
  tUserStrId = string(tuser[#id])
  tUserObj = pRoomComponentObj.getUserObject(tUserStrId)
  if tUserObj = 0 then
    return error(me, "User" && tUserStrId && "not found!", #updateRoomObjectLocation)
  end if
  if [tuser[#locX], tuser[#locY]] = pGoalLocationList[tUserStrId] then
    pGoalLocationList.deleteProp(tUserStrId)
    pExpectedLocationList.deleteProp(tUserStrId)
  else
    tNextLoc = me.solveNextTile(tUserStrId, [tuser[#locX], tuser[#locY]])
  end if
  if tNextLoc = 0 then
    tDirBody = tuser[#dirBody]
  else
    tDirBody = tNextLoc[3]
  end if
  tUserObj.resetValues(tuser[#locX], tuser[#locY], 0.0, tDirBody, tDirBody)
  pCurrentLocationList.setaProp(tUserStrId, [tuser[#locX], tuser[#locY], tDirBody])
  if pExpectedLocationList[tUserStrId] <> VOID then
    if ([tuser[#locX], tuser[#locY]] <> [pExpectedLocationList[tUserStrId][1], pExpectedLocationList[tUserStrId][2]]) and (tNextLoc <> 0) then
      pExpectedLocationList.deleteProp(tUserStrId)
      tUserObj.Refresh(tuser[#locX], tuser[#locY], 0.0)
      return 1
    end if
  end if
  pExpectedLocationList[tUserStrId] = tNextLoc
  if tNextLoc <> 0 then
    tParams = "mv " & tNextLoc[1] & "," & tNextLoc[2] & ",1.0"
    call(symbol("action_mv"), [tUserObj], tParams)
  end if
  tUserObj.Refresh(tuser[#locX], tuser[#locY], 0.0)
end

on updateRoomObjectGoal me, tuser
  tUserStrId = string(tuser[#id])
  pGoalLocationList.setaProp(tUserStrId, [tuser[#goalx], tuser[#goaly]])
  if pCurrentLocationList[tUserStrId] = VOID then
    return 0
  end if
  tuser[#locX] = pCurrentLocationList[tUserStrId][1]
  tuser[#locY] = pCurrentLocationList[tUserStrId][2]
  tuser[#dirBody] = pCurrentLocationList[tUserStrId][3]
  pExpectedLocationList.deleteProp(tUserStrId)
  return me.updateRoomObjectLocation(tuser)
end

on handleUserCreated me, tName, tUserStrId
  if me.getGameSystem().getSpectatorModeFlag() then
    return 1
  end if
  if tUserStrId <> getObject(#session).GET("user_index") then
    return 0
  end if
  return getObject(#room_interface).showArrowHiliter(tUserStrId)
end

on hideArrowHiliter me
  return getObject(#room_interface).hideArrowHiliter()
end

on solveNextTile me, tUserStrId, tCurrentLocation
  if pGoalLocationList[tUserStrId] = VOID then
    return 0
  end if
  tGoalX = pGoalLocationList[tUserStrId][1]
  tGoalY = pGoalLocationList[tUserStrId][2]
  tDirX = tGoalX - tCurrentLocation[1]
  tDirY = tGoalY - tCurrentLocation[2]
  if tDirX > 0 then
    tDirX = 1
  else
    if tDirX < 0 then
      tDirX = -1
    else
      tDirX = 0
    end if
  end if
  if tDirY > 0 then
    tDirY = 1
    tBodyDir = [5, 4, 3][tDirX + 2]
  else
    if tDirY < 0 then
      tDirY = -1
      tBodyDir = [7, 0, 1][tDirX + 2]
    else
      tDirY = 0
      tBodyDir = [6, 0, 2][tDirX + 2]
    end if
  end if
  tNextX = tCurrentLocation[1] + tDirX
  tNextY = tCurrentLocation[2] + tDirY
  return [tNextX, tNextY, tBodyDir]
end
