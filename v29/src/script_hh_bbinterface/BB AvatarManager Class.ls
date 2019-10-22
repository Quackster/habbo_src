property pRoomComponentObj, pGoalLocationList, pFigureSystemObj, pCurrentLocationList, pExpectedLocationList

on construct me 
  pGoalLocationList = [:]
  pCurrentLocationList = [:]
  pExpectedLocationList = [:]
  pRoomComponentObj = getObject(#room_component)
  if (pRoomComponentObj = 0) then
    return(error(me, "BB: Avatar manager failed to initialize", #construct))
  end if
  tClassContainer = pRoomComponentObj.getClassContainer()
  if (tClassContainer = 0) then
    return(error(me, "BB: Avatar manager failed to initialize", #construct))
  end if
  tClassContainer.set("bouncing.human.class", ["Human Class EX", "Bouncing Human Class"])
  registerMessage(#create_user, me.getID(), #handleUserCreated)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#create_user, me.getID())
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #gamestatus_events) then
    repeat while tTopic <= tdata
      tEvent = getAt(tdata, tTopic)
      if (tTopic = 0) then
        me.createRoomObject(tEvent.getAt(#data))
      else
        if (tTopic = 1) then
          me.deleteRoomObject(tEvent.getAt(#id))
        else
          if (tTopic = 2) then
            me.updateRoomObjectGoal(tEvent)
          end if
        end if
      end if
    end repeat
  else
    if (tTopic = #gamestatus_players) then
      tUpdatedPlayers = []
      repeat while tTopic <= tdata
        tPlayer = getAt(tdata, tTopic)
        me.updateRoomObjectLocation(tPlayer)
        tUpdatedPlayers.add(tPlayer.getAt(#id))
      end repeat
    else
      if (tTopic = #fullgamestatus_players) then
        repeat while tTopic <= tdata
          tPlayer = getAt(tdata, tTopic)
          me.createRoomObject(tPlayer)
        end repeat
      else
        if (tTopic = #gamereset) then
          repeat while tTopic <= tdata
            tPlayer = getAt(tdata, tTopic)
            pGoalLocationList.deleteProp(string(tPlayer.getAt(#id)))
            me.updateRoomObjectLocation(tPlayer)
          end repeat
        else
          if (tTopic = #gamestart) then
            me.hideArrowHiliter()
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on createRoomObject me, tdata 
  if (pRoomComponentObj = 0) then
    return(error(me, "BB: Room couldn't create avatar!", #createRoomObject))
  end if
  if (pFigureSystemObj = void()) then
    pFigureSystemObj = getObject("Figure_System")
    if (pFigureSystemObj = void()) then
      return(error(me, "BB: Room couldn't create avatar!", #createRoomObject))
    end if
  end if
  tUserStrId = string(tdata.getAt(#id))
  tAvatarStruct = [:]
  tAvatarStruct.addProp(#id, tUserStrId)
  tAvatarStruct.addProp(#name, tdata.getAt(#name))
  tAvatarStruct.addProp(#direction, [tdata.getAt(#dirBody), 0])
  tAvatarStruct.addProp(#class, "bouncing.human.class")
  tAvatarStruct.addProp(#x, tdata.getAt(#locX))
  tAvatarStruct.addProp(#y, tdata.getAt(#locY))
  tAvatarStruct.addProp(#h, 0)
  tAvatarStruct.addProp(#custom, tdata.getAt(#mission))
  tAvatarStruct.addProp(#sex, tdata.getAt(#sex))
  tAvatarStruct.addProp(#teamId, tdata.getAt(#teamId))
  if (tdata.getAt(#name) = getObject(#session).GET(#userName)) then
    getObject(#session).set("user_index", tUserStrId)
  end if
  tFigure = pFigureSystemObj.parseFigure(tdata.getAt(#figure), tdata.getAt(#sex), "user")
  tTeamId = (tdata.getAt(#teamId) + 1)
  tTeamColors = [rgb("#E73929"), rgb("#217BEF"), rgb("#FFCE21"), rgb("#8CE700")]
  tBallModel = ["model":"001", "color":tTeamColors.getAt(tTeamId)]
  tFigure.addProp("bl", tBallModel)
  tAvatarStruct.addProp(#figure, tFigure)
  pCurrentLocationList.setaProp(tUserStrId, [tdata.getAt(#locX), tdata.getAt(#locY), tdata.getAt(#dirBody)])
  pGoalLocationList.setaProp(tUserStrId, void())
  if not pRoomComponentObj.validateUserObjects(tAvatarStruct) then
    return(error(me, "BB: Room couldn't create avatar!", #createRoomObject))
  else
    return TRUE
  end if
end

on deleteRoomObject me, tID 
  if (pRoomComponentObj = 0) then
    return FALSE
  end if
  tUserStrId = string(tID)
  pGoalLocationList.deleteProp(tUserStrId)
  pCurrentLocationList.deleteProp(tUserStrId)
  pExpectedLocationList.deleteProp(tUserStrId)
  return(pRoomComponentObj.removeUserObject(tUserStrId))
end

on updateRoomObjectLocation me, tuser 
  if (pRoomComponentObj = 0) then
    return FALSE
  end if
  if not (ilk(tuser) = #propList) then
    return FALSE
  end if
  tUserStrId = string(tuser.getAt(#id))
  tUserObj = pRoomComponentObj.getUserObject(tUserStrId)
  if (tUserObj = 0) then
    return(error(me, "User" && tUserStrId && "not found!", #updateRoomObjectLocation))
  end if
  if ([tuser.getAt(#locX), tuser.getAt(#locY)] = pGoalLocationList.getAt(tUserStrId)) then
    pGoalLocationList.deleteProp(tUserStrId)
    pExpectedLocationList.deleteProp(tUserStrId)
  else
    tNextLoc = me.solveNextTile(tUserStrId, [tuser.getAt(#locX), tuser.getAt(#locY)])
  end if
  if (tNextLoc = 0) then
    tDirBody = tuser.getAt(#dirBody)
  else
    tDirBody = tNextLoc.getAt(3)
  end if
  tUserObj.resetValues(tuser.getAt(#locX), tuser.getAt(#locY), 0, tDirBody, tDirBody)
  pCurrentLocationList.setaProp(tUserStrId, [tuser.getAt(#locX), tuser.getAt(#locY), tDirBody])
  if pExpectedLocationList.getAt(tUserStrId) <> void() then
    if [tuser.getAt(#locX), tuser.getAt(#locY)] <> [pExpectedLocationList.getAt(tUserStrId).getAt(1), pExpectedLocationList.getAt(tUserStrId).getAt(2)] and tNextLoc <> 0 then
      pExpectedLocationList.deleteProp(tUserStrId)
      tUserObj.Refresh(tuser.getAt(#locX), tuser.getAt(#locY), 0)
      return TRUE
    end if
  end if
  pExpectedLocationList.setAt(tUserStrId, tNextLoc)
  if tNextLoc <> 0 then
    tParams = "mv " & tNextLoc.getAt(1) & "," & tNextLoc.getAt(2) & ",1.0"
    call(symbol("action_mv"), [tUserObj], tParams)
  end if
  tUserObj.Refresh(tuser.getAt(#locX), tuser.getAt(#locY), 0)
end

on updateRoomObjectGoal me, tuser 
  tUserStrId = string(tuser.getAt(#id))
  pGoalLocationList.setaProp(tUserStrId, [tuser.getAt(#goalx), tuser.getAt(#goaly)])
  if (pCurrentLocationList.getAt(tUserStrId) = void()) then
    return FALSE
  end if
  tuser.setAt(#locX, pCurrentLocationList.getAt(tUserStrId).getAt(1))
  tuser.setAt(#locY, pCurrentLocationList.getAt(tUserStrId).getAt(2))
  tuser.setAt(#dirBody, pCurrentLocationList.getAt(tUserStrId).getAt(3))
  pExpectedLocationList.deleteProp(tUserStrId)
  return(me.updateRoomObjectLocation(tuser))
end

on handleUserCreated me, tName, tUserStrId 
  if me.getGameSystem().getSpectatorModeFlag() then
    return TRUE
  end if
  if tUserStrId <> getObject(#session).GET("user_index") then
    return FALSE
  end if
  return(getObject(#room_interface).showArrowHiliter(tUserStrId))
end

on hideArrowHiliter me 
  return(getObject(#room_interface).hideArrowHiliter())
end

on solveNextTile me, tUserStrId, tCurrentLocation 
  if (pGoalLocationList.getAt(tUserStrId) = void()) then
    return FALSE
  end if
  tGoalX = pGoalLocationList.getAt(tUserStrId).getAt(1)
  tGoalY = pGoalLocationList.getAt(tUserStrId).getAt(2)
  tDirX = (tGoalX - tCurrentLocation.getAt(1))
  tDirY = (tGoalY - tCurrentLocation.getAt(2))
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
    tBodyDir = [5, 4, 3].getAt((tDirX + 2))
  else
    if tDirY < 0 then
      tDirY = -1
      tBodyDir = [7, 0, 1].getAt((tDirX + 2))
    else
      tDirY = 0
      tBodyDir = [6, 0, 2].getAt((tDirX + 2))
    end if
  end if
  tNextX = (tCurrentLocation.getAt(1) + tDirX)
  tNextY = (tCurrentLocation.getAt(2) + tDirY)
  return([tNextX, tNextY, tBodyDir])
end
