property pAnimCounter, pAnimList, pCurrentFrame, pCurtainsLocZ, pSplashs, pArrowCursor

on construct me
  pCurtainsLocZ = [:]
  tProps = [:]
  pSplashs = [:]
  initThread("thread.pelle")
  return 1
end

on deconstruct me
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
  pSplashs["Splash0"].setData(tProps)
  if not objectExists(#waterripples) then
    createObject(#waterripples, "Water Ripple Effects Class")
  end if
  getObject(#waterripples).Init("vesi1")
  repeat with tid in ["pool_clickarea", "floor", "hiliter", "vesi1", "portaat0"]
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tid)
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
  if voidp(tMsg) then
    return 0
  end if
  tDest = tMsg[#show_dest]
  tCommand = tMsg[#show_command]
  tParm = tMsg[#show_params]
  if tDest contains "curtains" then
    me.curtains(tDest, tCommand)
  else
    if tDest contains "Splash" then
      me.splash(tDest, tCommand)
    end if
  end if
end

on curtains me, tid, tCommand
  case tCommand of
    "open":
      tmember = getMember("verhot auki")
    "close":
      tmember = getMember("verho kiinni")
  end case
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  tVisObj.getSprById(tid).setMember(tmember)
  return 1
end

on splash me, tDest, tCommand
  if voidp(pSplashs[tDest]) then
    return 0
  end if
  call(#Activate, pSplashs[tDest])
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
  tMyIndex = getObject(#session).get("user_index")
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
