property pAnimCounter, pAnimList, pCurrentFrame, pCurtainsLocZ, pSplashs, pArrowCursor, pBalloonRightMargin

on construct me
  pSplashs = [:]
  pBalloonRightMargin = getIntVariable("balloons.rightmargin", 720)
  createVariable("balloons.rightmargin", 597)
  initThread("thread.pelle")
  return 1
end

on deconstruct me
  closeThread(#pellehyppy)
  createVariable("balloons.rightmargin", pBalloonRightMargin)
  removeUpdate(me.getID())
  if objectExists(#waterripples) then
    removeObject(#waterripples)
  end if
  if objectExists(#poolliftdoor) then
    removeObject(#poolliftdoor)
  end if
  if objectExists(#pool_fuse_screen) then
    removeObject(#pool_fuse_screen)
  end if
  pSplashs = [:]
  if objectExists(#pool_bigSplash) then
    removeObject(#pool_bigSplash)
  end if
  return me.removeArrowCursor()
end

on prepare me
  createObject(#pool_fuse_screen, "FUSE screen Class")
  pSplashs = [:]
  repeat with f = 0 to 2
    tProps = [:]
    pSplashs.addProp("Splash" & f, createObject(#temp, "AnimSprite Class"))
    tProps[#visible] = 0
    tProps[#AnimFrames] = 10
    tProps[#startFrame] = 0
    tProps[#MemberName] = "splash_"
    tProps[#id] = "Splash" & f
    pSplashs["Splash" & f].setData(tProps)
  end repeat
  if not objectExists(#waterripples) then
    createObject(#waterripples, "Water Ripple Effects Class")
  end if
  if not objectExists(#poolliftdoor) then
    createObject(#poolliftdoor, "Elevator Door Class")
  end if
  if objectExists(#waterripples) then
    getObject(#waterripples).Init("vesi2")
  end if
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("jumpticketautomatic")
  registerProcedure(tSpr, #eventProcJumpTicketAutomatic, me.getID(), #mouseDown)
  repeat with tid in ["pool_clickarea", "floor", "hiliter", "vesi2", "portaat1", "portaat3"]
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tid)
    registerProcedure(tSpr, #poolTeleport, me.getID(), #mouseDown)
  end repeat
  pArrowCursor = 0
  if threadExists(#room) then
    getThread(#room).getInterface().hideRoomBar()
  end if
  getThread(#pellehyppy).getInterface().showRoomBar()
  receiveUpdate(me.getID())
  return 1
end

on showprogram me, tMsg
  if not getThread(#room).getComponent().pActiveFlag then
    return 0
  end if
  if voidp(tMsg) then
    return 0
  end if
  tDst = tMsg[#show_dest]
  tCmd = tMsg[#show_command]
  tPrm = tMsg[#show_params]
  if tDst contains "cam" then
    if not objectExists(#pool_fuse_screen) then
      return 0
    end if
    call(symbol("fuseShow_" & tCmd), getObject(#pool_fuse_screen), tPrm)
  else
    if tDst contains "Splash" then
      me.splash(tDst, tCmd)
    else
      if tDst contains "door" then
        me.delay(200, #elvatorDoor, [#dest: tDst, #command: tCmd])
      else
      end if
    end if
  end if
end

on splash me, tDest, tCommand
  if voidp(pSplashs[tDest]) then
    return 0
  end if
  call(#Activate, pSplashs[tDest])
end

on elvatorDoor me, tProps
  tDst = tProps[#dest]
  tCmd = tProps[#command]
  case tCmd of
    "open":
      tmember = getMember("towerdoor_2")
    "close":
      tmember = getMember("towerdoor_0")
  end case
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  tVisObj.getSprById("lift_door").setMember(tmember)
end

on update me
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  if pArrowCursor or (the mouseH < 25) then
    me.poolArrows()
  end if
end

on poolArrows me
  tStartPos = [0, 13]
  tloc = getThread(#room).getInterface().getGeometry().getWorldCoordinate(the mouseH, the mouseV)
  if tloc.ilk <> #list then
    return me.removeArrowCursor()
  end if
  if (tStartPos[1] - tloc[1]) = (tStartPos[2] - tloc[2]) then
    pArrowCursor = 1
    cursor([member(getmemnum("cursor_arrow_l")), member(getmemnum("cursor_arrow_l_mask"))])
  else
    me.removeArrowCursor()
  end if
end

on removeArrowCursor me
  pArrowCursor = 0
  cursor(-1)
  return 1
end

on eventProcJumpTicketAutomatic me
  if threadExists(#pellehyppy) then
    return executeMessage(#show_ticketWindow)
  else
    return 0
  end if
end

on poolTeleport me, tEvent, tSprID, tParam
  tMyIndex = getObject(#session).get("user_index")
  if not getThread(#room).getComponent().userObjectExists(tMyIndex) then
    return 0
  end if
  tloc = getThread(#room).getComponent().getUserObject(tMyIndex).getLocation()
  getThread(#room).getInterface().eventProcRoom(tEvent, "floor", tParam)
  if not (tSprID contains "pool_clickarea") and (tloc[3] < 7) then
    if (tloc[2] > 11) and (tloc[1] < 20) then
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 17, #short: 22])
    else
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 31, #short: 11])
    end if
  else
    if (tSprID contains "pool_clickarea") and (tloc[3] = 7) then
      if tloc[2] > 11 then
        getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 17, #short: 21])
      else
        getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 31, #short: 10])
      end if
    end if
  end if
end
