property pAnimCounter, pAnimList, pCurrentFrame, pCurtainsLocZ, pSplashs, pArrowCursor

on construct me
  pCurtainsLocZ = [:]
  tProps = [:]
  pSplashs = [:]
  initThread("thread.pelle")
  me.regMsgList(1)
  return 1
end

on deconstruct me
  me.regMsgList(0)
  closeThread(#pellehyppy)
  removeUpdate(me.getID())
  if objectExists(#waterripples) then
    removeObject(#waterripples)
  end if
  pSplashs = VOID
  me.removeArrowCursor()
  return 1
end

on prepare me
  pCurtainsLocZ = [:]
  repeat with f = 1 to 2
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("curtains" & f)
    pCurtainsLocZ["curtains" & f] = tSpr.locZ
    tSpr.locZ = tSpr.locZ - 2000
  end repeat
  tProps = [:]
  pSplashs = [:]
  pSplashs.addProp("Splash0", createObject(#temp, "AnimSprite Class"))
  tProps[#visible] = 0
  tProps[#AnimFrames] = 10
  tProps[#startFrame] = 0
  tProps[#MemberName] = "splash_"
  tProps[#id] = "Splash0"
  tProps[#loc] = point(the stageRight + 1000, 0)
  pSplashs["Splash0"].setData(tProps)
  if not objectExists(#waterripples) then
    createObject(#waterripples, "Water Ripple Effects Class")
  end if
  getObject(#waterripples).Init("vesi1")
  repeat with tID in ["pool_clickarea", "floor", "hiliter", "vesi1", "portaat0"]
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tID)
    registerProcedure(tSpr, #poolTeleport, me.getID(), #mouseDown)
  end repeat
  pArrowCursor = 0
  if threadExists(#room) then
    getThread(#room).getInterface().hideRoomBar()
  end if
  getThread(#pellehyppy).getInterface().showRoomBar()
  receiveUpdate(me.getID())
end

on showprogram me, tMsg
end

on handle_dressing_room_curtain me, tMsg
  tConn = tMsg.connection
  tID = tConn.GetStrFrom()
  tStateInt = tConn.GetIntFrom()
  case tStateInt of
    0:
      tmember = member(getmemnum("verho kiinni"))
      tlocz = pCurtainsLocZ[tID] - 1000
    1:
      tmember = member(getmemnum("verhot auki"))
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
  tDest = "Splash" & tConn.GetIntFrom()
  if not voidp(pSplashs[tDest]) then
    call(#Activate, pSplashs[tDest])
  end if
end

on update me
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  if pArrowCursor or (the mouseH > 694) then
    me.poolArrows()
  end if
end

on poolArrows me
  tStartPos = [19, 3]
  tloc = getThread(#room).getInterface().getGeometry().getWorldCoordinate(the mouseH, the mouseV)
  if tloc.ilk <> #list then
    return me.removeArrowCursor()
  end if
  if (tStartPos[1] - tloc[1]) = (tStartPos[2] - tloc[2]) then
    pArrowCursor = 1
    cursor([member(getmemnum("cursor_arrow_r")), member(getmemnum("cursor_arrow_r_mask"))])
  else
    me.removeArrowCursor()
  end if
end

on removeArrowCursor me
  pArrowCursor = 0
  cursor(-1)
  return 1
end

on poolTeleport me, tEvent, tSprID, tParm
  tMyIndex = getObject(#session).GET("user_index")
  tObject = getThread(#room).getComponent().getUserObject(tMyIndex)
  if tObject = 0 then
    return error(me, "Userobject not found:" && tMyIndex, #poolTeleport)
  end if
  tloc = tObject.getLocation()
  getThread(#room).getInterface().eventProcRoom(tEvent, "floor", tParm)
  if not (tSprID contains "pool_clickarea") and (tloc[3] < 7) then
    getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 21, #short: 28])
  else
    if (tSprID contains "pool_clickarea") and (tloc[3] = 7) then
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 20, #short: 28])
    end if
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
