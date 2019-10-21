on construct(me)
  pTimer = 0
  createObject("dew_clouds", "Mountain Clouds Class")
  createObject("dew_camera", "FUSE screen Class")
  initThread("mountain.index")
  initThread("paalu.index")
  receivePrepare(me.getID())
  me.prepareRoom()
  me.regMsgList(1)
  return(1)
  exit
end

on deconstruct(me)
  me.regMsgList(0)
  removePrepare(me.getID())
  removeObject("dew_clouds")
  removeObject("dew_camera")
  removeObject(#waterripples)
  closeThread(#mountain)
  closeThread(#paalu)
  return(1)
  exit
end

on prepareRoom(me)
  pCurtainsLocZ = []
  f = 1
  repeat while f <= 2
    tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("curtains" & f)
    pCurtainsLocZ.setAt("curtains" & f, tsprite.locZ)
    tsprite.locZ = tsprite.locZ - 2000
    f = 1 + f
  end repeat
  tProps = []
  pSplashs = []
  pSplashs.addProp("Splash0", createObject(#temp, "AnimSprite Class"))
  tProps.setAt(#visible, 0)
  tProps.setAt(#AnimFrames, 10)
  tProps.setAt(#startFrame, 0)
  tProps.setAt(#MemberName, "splash_")
  tProps.setAt(#id, "Splash0")
  pSplashs.getAt("Splash0").setData(tProps)
  createObject(#waterripples, "Water Ripple Effects Class")
  getObject(#waterripples).Init("vesi1")
  exit
end

on showprogram(me, tMsg)
  if not voidp(tMsg) then
    tDest = tMsg.getAt(#show_dest)
    tCommand = tMsg.getAt(#show_command)
    tParam = tMsg.getAt(#show_params)
    if tDest contains "cam" then
      if objectExists("dew_camera") then
        call(symbol("fuseShow_" & tCommand), getObject("dew_camera"), tParam)
      end if
    end if
  end if
  exit
end

on handle_dressing_room_curtain(me, tMsg)
  tConn = tMsg.connection
  tID = tConn.GetStrFrom()
  tStateInt = tConn.GetIntFrom()
  if me = 0 then
    tmember = member(getmemnum("dew_verho_kiinni"))
    tlocz = pCurtainsLocZ.getAt(tID) - 1000
  else
    if me = 1 then
      tmember = member(getmemnum("dew_verho_auki"))
      tlocz = pCurtainsLocZ.getAt(tID) - 2000
    end if
  end if
  tID = "curtains" & tID.getProp(#char, tID.length)
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return(0)
  end if
  tSpr = tRoomVis.getSprById(tID)
  if tSpr = 0 then
    return(0)
  end if
  tSpr.setMember(tmember)
  tSpr.locZ = tlocz
  return(1)
  exit
end

on handle_pool_stair_splash(me, tMsg)
  tConn = tMsg.connection
  tDest = "Splash0"
  if not voidp(pSplashs.getAt(tDest)) then
    call(#Activate, pSplashs.getAt(tDest))
  end if
  exit
end

on prepare(me)
  pTimer = not pTimer
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if pTimer then
    i = 1
    repeat while i <= 3
      tRoomVis.getSprById("putous" && i).member = member(getmemnum("dew_putous" & i & "_" & random(7)))
      i = 1 + i
    end repeat
  end if
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(504, #handle_dressing_room_curtain)
  tMsgs.setaProp(505, #handle_pool_stair_splash)
  tCmds = []
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
  exit
end