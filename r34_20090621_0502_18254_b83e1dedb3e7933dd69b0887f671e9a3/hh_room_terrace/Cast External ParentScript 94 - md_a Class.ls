property pSplashs, pTimer, pCurtainsLocZ

on construct me
  pTimer = 0
  createObject("dew_clouds", "Mountain Clouds Class")
  createObject("dew_camera", "FUSE screen Class")
  initThread("mountain.index")
  initThread("paalu.index")
  receivePrepare(me.getID())
  me.prepareRoom()
  me.regMsgList(1)
  return 1
end

on deconstruct me
  me.regMsgList(0)
  removePrepare(me.getID())
  removeObject("dew_clouds")
  removeObject("dew_camera")
  removeObject(#waterripples)
  closeThread(#mountain)
  closeThread(#paalu)
  return 1
end

on prepareRoom me
  pCurtainsLocZ = [:]
  repeat with f = 1 to 2
    tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("curtains" & f)
    pCurtainsLocZ["curtains" & f] = tsprite.locZ
    tsprite.locZ = tsprite.locZ - 2000
  end repeat
  tProps = [:]
  pSplashs = [:]
  pSplashs.addProp("Splash0", createObject(#temp, "AnimSprite Class"))
  tProps[#visible] = 0
  tProps[#AnimFrames] = 10
  tProps[#startFrame] = 0
  tProps[#MemberName] = "splash_"
  tProps[#id] = "Splash0"
  pSplashs["Splash0"].setData(tProps)
  createObject(#waterripples, "Water Ripple Effects Class")
  getObject(#waterripples).Init("vesi1")
end

on showprogram me, tMsg
  if not voidp(tMsg) then
    tDest = tMsg[#show_dest]
    tCommand = tMsg[#show_command]
    tParam = tMsg[#show_params]
    if tDest contains "cam" then
      if objectExists("dew_camera") then
        call(symbol("fuseShow_" & tCommand), getObject("dew_camera"), tParam)
      end if
    end if
  end if
end

on handle_dressing_room_curtain me, tMsg
  tConn = tMsg.connection
  tID = tConn.GetStrFrom()
  tStateInt = tConn.GetIntFrom()
  case tStateInt of
    0:
      tmember = member(getmemnum("dew_verho_kiinni"))
      tlocz = pCurtainsLocZ[tID] - 1000
    1:
      tmember = member(getmemnum("dew_verho_auki"))
      tlocz = pCurtainsLocZ[tID] - 2000
  end case
  tID = "curtains" & tID.char[tID.length]
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return 0
  end if
  tSpr = tRoomVis.getSprById(tID)
  if tSpr = 0 then
    return 0
  end if
  tSpr.setMember(tmember)
  tSpr.locZ = tlocz
  return 1
end

on handle_pool_stair_splash me, tMsg
  tConn = tMsg.connection
  tDest = "Splash0"
  if not voidp(pSplashs[tDest]) then
    call(#Activate, pSplashs[tDest])
  end if
end

on prepare me
  pTimer = not pTimer
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if pTimer then
    repeat with i = 1 to 3
      tRoomVis.getSprById("putous" && i).member = member(getmemnum("dew_putous" & i & "_" & random(7)))
    end repeat
  end if
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(504, #handle_dressing_room_curtain)
  tMsgs.setaProp(505, #handle_pool_stair_splash)
  tCmds = [:]
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
