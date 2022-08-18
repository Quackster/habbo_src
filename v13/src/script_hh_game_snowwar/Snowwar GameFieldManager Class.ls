property pRoomGeometry, pMouseClickTime

on construct me
  me.registerEventProc(1)
  return 1
end

on deconstruct me
  me.registerEventProc(0)
  if managerExists(#sound_manager) then
    stopAllSounds()
  end if
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #objects_ready:
      me.processRoomReady()
    #snowwar_event_11:
      me.getGameSystem().executeGameObjectEvent(string(tdata[#int_machine_id]), #add_snowball)
    #snowwar_event_12:
      return me.moveBallsToUser(string(tdata[#int_machine_id]), string(tdata[#int_player_id]))
  end case
  return error(me, ((("Undefined event!" && tTopic) && "for") && me.pID), #Refresh)
  return 1
end

on processRoomReady me
  tList = getObject(#room_component).pPassiveObjList
  tTargetID = getThread(#room).getInterface().getID()
  tVisObj = getObject("Room_visualizer")
  tBaseLocZ = tVisObj.getProperty(#locZ)
  tBaseLocZ = tVisObj.getSprById("floor").locZ
  tHiliterLocZ = tVisObj.getSprById("hiliter").locZ
  repeat with tObject in tList
    tSprites = tObject.getSprites()
    if (tSprites.count > 0) then
      tSpr = tSprites[1]
      tSpr.removeProcedure(#eventProcPassiveObj, tTargetID)
      tSpr.registerProcedure(#eventProcRoom, me.getID(), #mouseDown)
      tSpr.registerProcedure(#eventProcRoom, me.getID(), #mouseUp)
      if (tSpr.member.name contains "sw_backround") then
        tSpr.locZ = (tBaseLocZ + 1)
        if (tSpr.locZ >= tHiliterLocZ) then
          tVisObj.getSprById("hiliter").locZ = (tHiliterLocZ + 1)
        end if
      end if
    end if
  end repeat
end

on registerEventProc me, tBoolean
  tRoomThread = getThread(#room)
  if (tRoomThread = 0) then
    return 0
  end if
  tRoomInt = tRoomThread.getInterface()
  if (tRoomInt = 0) then
    return 0
  end if
  pRoomGeometry = tRoomInt.getGeometry()
  if (pRoomGeometry = 0) then
    return 0
  end if
  tVisObj = tRoomInt.getRoomVisualizer()
  if (tVisObj = 0) then
    return 0
  end if
  tSprList = tVisObj.getProperty(#spriteList)
  if tBoolean then
    call(#removeProcedure, tSprList, #mouseDown)
    call(#removeProcedure, tSprList, #mouseUp)
    call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseDown)
    call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseUp)
  else
    if listp(tSprList) then
      call(#removeProcedure, tSprList, #mouseDown)
      call(#removeProcedure, tSprList, #mouseUp)
    end if
  end if
end

on eventProcRoom me, tEvent, tSprID, tParam
  tloc = pRoomGeometry.getWorldCoordinate(the mouseH, the mouseV)
  if not listp(tloc) then
    return 1
  end if
  tRoomInt = getObject(#room_interface)
  if (tRoomInt = 0) then
    return 0
  end if
  if tRoomInt.getComponent().getSpectatorMode() then
    return 1
  end if
  if (tEvent = #mouseUp) then
    tMouseDownTime = ((the milliSeconds - pMouseClickTime) / 1000)
    if the optionDown then
      pMouseClickTime = -1
      return me.sendThrowBall(tloc, 2)
    end if
    if the shiftDown then
      if (tMouseDownTime >= 1) then
        return me.sendThrowBall(tloc, 2)
      else
        return me.sendThrowBall(tloc, 1)
      end if
    end if
    pMouseClickTime = -1
    return 1
  end if
  if (tEvent = #mouseDown) then
    if the shiftDown then
      pMouseClickTime = the milliSeconds
    else
      if not the optionDown then
        return me.sendMoveGoal(tloc)
      end if
    end if
    return 1
  end if
end

on sendThrowBall me, tloc, tTrajectory
  tFramework = me.getGameSystem()
  if (tFramework = 0) then
    return 0
  end if
  tGameState = tFramework.getGamestatus()
  if (tGameState = #game_started) then
    tWorldLoc = tFramework.convertTileToWorldCoordinate(tloc[1], tloc[2])
    if not getObject(#session).exists("user_game_index") then
      return 0
    end if
    tMyId = getObject(#session).GET("user_game_index")
    tFramework.executeGameObjectEvent(tMyId, #send_throw_at_loc, [#targetloc: tWorldLoc, #trajectory: tTrajectory])
    return 1
  end if
end

on sendMoveGoal me, tloc
  tFramework = me.getGameSystem()
  if (tFramework = 0) then
    return 0
  end if
  tGameState = tFramework.getGamestatus()
  if (tGameState = #game_started) then
    if not getObject(#session).exists("user_game_index") then
      return 0
    end if
    tMyId = getObject(#session).GET("user_game_index")
    return tFramework.executeGameObjectEvent(tMyId, #send_set_target_tile, [#tile_x: tloc[1], #tile_y: tloc[2]])
  else
    return tFramework.sendHabboRoomMove(tloc[1], tloc[2])
  end if
end

on moveBallsToUser me, tMachineID, tUserID
  tMachineObject = me.getGameSystem().getGameObject(tMachineID)
  if (tMachineObject = 0) then
    return 0
  end if
  tMachineBallCount = tMachineObject.getGameObjectProperty(#snowball_count)
  tUserObject = me.getGameSystem().getGameObject(tUserID)
  if (tUserObject = 0) then
    return 0
  end if
  tUserBallCount = tUserObject.getGameObjectProperty(#snowball_count)
  tMaxBallCount = getIntVariable("snowwar.snowball.maximum")
  if ((tMachineBallCount > 0) and (tUserBallCount < tMaxBallCount)) then
    me.getGameSystem().executeGameObjectEvent(tUserID, #set_ball_count, [#value: (tUserBallCount + 1)])
    me.getGameSystem().executeGameObjectEvent(tMachineID, #remove_snowball)
  end if
  return 1
end
