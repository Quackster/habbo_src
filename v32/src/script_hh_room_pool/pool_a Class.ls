on construct(me)
  pCurtainsLocZ = []
  tProps = []
  pSplashs = []
  initThread("thread.pelle")
  me.regMsgList(1)
  return(1)
  exit
end

on deconstruct(me)
  me.regMsgList(0)
  closeThread(#pellehyppy)
  removeUpdate(me.getID())
  if objectExists(#waterripples) then
    removeObject(#waterripples)
  end if
  pSplashs = void()
  me.removeArrowCursor()
  return(1)
  exit
end

on prepare(me)
  pCurtainsLocZ = []
  f = 1
  repeat while f <= 2
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("curtains" & f)
    pCurtainsLocZ.setAt("curtains" & f, tSpr.locZ)
    tSpr.locZ = tSpr.locZ - 2000
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
  tProps.setAt(#loc, point(the stageRight + 1000, 0))
  pSplashs.getAt("Splash0").setData(tProps)
  if not objectExists(#waterripples) then
    createObject(#waterripples, "Water Ripple Effects Class")
  end if
  getObject(#waterripples).Init("vesi1")
  repeat while me <= undefined
    tID = getAt(undefined, undefined)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tID)
    registerProcedure(tSpr, #poolTeleport, me.getID(), #mouseDown)
  end repeat
  pArrowCursor = 0
  if threadExists(#room) then
    getThread(#room).getInterface().hideRoomBar()
  end if
  getThread(#pellehyppy).getInterface().showRoomBar()
  receiveUpdate(me.getID())
  exit
end

on showprogram(me, tMsg)
  exit
end

on handle_dressing_room_curtain(me, tMsg)
  tConn = tMsg.connection
  tID = tConn.GetStrFrom()
  tStateInt = tConn.GetIntFrom()
  if me = 0 then
    tmember = member(getmemnum("verho kiinni"))
    tlocz = pCurtainsLocZ.getAt(tID) - 1000
  else
    if me = 1 then
      tmember = member(getmemnum("verhot auki"))
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
  tDest = "Splash" & tConn.GetIntFrom()
  if not voidp(pSplashs.getAt(tDest)) then
    call(#Activate, pSplashs.getAt(tDest))
  end if
  exit
end

on update(me)
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  if pArrowCursor or the mouseH > 694 then
    me.poolArrows()
  end if
  exit
end

on poolArrows(me)
  tStartPos = [19, 3]
  tloc = getThread(#room).getInterface().getGeometry().getWorldCoordinate(the mouseH, the mouseV)
  if tloc.ilk <> #list then
    return(me.removeArrowCursor())
  end if
  if tStartPos.getAt(1) - tloc.getAt(1) = tStartPos.getAt(2) - tloc.getAt(2) then
    pArrowCursor = 1
    cursor([member(getmemnum("cursor_arrow_r")), member(getmemnum("cursor_arrow_r_mask"))])
  else
    me.removeArrowCursor()
  end if
  exit
end

on removeArrowCursor(me)
  pArrowCursor = 0
  cursor(-1)
  return(1)
  exit
end

on poolTeleport(me, tEvent, tSprID, tParm)
  tMyIndex = getObject(#session).GET("user_index")
  tObject = getThread(#room).getComponent().getUserObject(tMyIndex)
  if tObject = 0 then
    return(error(me, "Userobject not found:" && tMyIndex, #poolTeleport))
  end if
  tloc = tObject.getLocation()
  getThread(#room).getInterface().eventProcRoom(tEvent, "floor", tParm)
  if not tSprID contains "pool_clickarea" and tloc.getAt(3) < 7 then
    getConnection(getVariable("connection.room.id")).send("MOVE", [#short:21, #short:28])
  else
    if tSprID contains "pool_clickarea" and tloc.getAt(3) = 7 then
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short:20, #short:28])
    end if
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