property pBalloonRightMargin, pSplashs, pArrowCursor

on construct me 
  pSplashs = [:]
  pBalloonRightMargin = getIntVariable("balloons.rightmargin", 720)
  createVariable("balloons.rightmargin", 597)
  initThread("thread.pelle")
  return TRUE
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
  return(me.removeArrowCursor())
end

on prepare me 
  createObject(#pool_fuse_screen, "FUSE screen Class")
  pSplashs = [:]
  f = 0
  repeat while f <= 2
    tProps = [:]
    pSplashs.addProp("Splash" & f, createObject(#temp, "AnimSprite Class"))
    tProps.setAt(#visible, 0)
    tProps.setAt(#AnimFrames, 10)
    tProps.setAt(#startFrame, 0)
    tProps.setAt(#MemberName, "splash_")
    tProps.setAt(#id, "Splash" & f)
    pSplashs.getAt("Splash" & f).setData(tProps)
    f = (1 + f)
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
  repeat while ["pool_clickarea", "floor", "hiliter", "vesi2", "portaat1", "portaat3"] <= undefined
    tid = getAt(undefined, undefined)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tid)
    registerProcedure(tSpr, #poolTeleport, me.getID(), #mouseDown)
  end repeat
  pArrowCursor = 0
  if threadExists(#room) then
    getThread(#room).getInterface().hideRoomBar()
  end if
  getThread(#pellehyppy).getInterface().showRoomBar()
  receiveUpdate(me.getID())
  return TRUE
end

on showprogram me, tMsg 
  if not getThread(#room).getComponent().pActiveFlag then
    return FALSE
  end if
  if voidp(tMsg) then
    return FALSE
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPrm = tMsg.getAt(#show_params)
  if tDst contains "cam" then
    if not objectExists(#pool_fuse_screen) then
      return FALSE
    end if
    call(symbol("fuseShow_" & tCmd), getObject(#pool_fuse_screen), tPrm)
  else
    if tDst contains "Splash" then
      me.splash(tDst, tCmd)
    else
      if tDst contains "door" then
        me.delay(200, #elvatorDoor, [#dest:tDst, #command:tCmd])
      else
      end if
    end if
  end if
end

on splash me, tDest, tCommand 
  if voidp(pSplashs.getAt(tDest)) then
    return FALSE
  end if
  call(#Activate, pSplashs.getAt(tDest))
end

on elvatorDoor me, tProps 
  tDst = tProps.getAt(#dest)
  tCmd = tProps.getAt(#command)
  if (tCmd = "open") then
    tmember = getMember("towerdoor_2")
  else
    if (tCmd = "close") then
      tmember = getMember("towerdoor_0")
    end if
  end if
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  if (tVisObj = 0) then
    return FALSE
  end if
  tVisObj.getSprById("lift_door").setMember(tmember)
end

on update me 
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  if pArrowCursor or the mouseH < 25 then
    me.poolArrows()
  end if
end

on poolArrows me 
  tStartPos = [0, 13]
  tloc = getThread(#room).getInterface().getGeometry().getWorldCoordinate(the mouseH, the mouseV)
  if tloc.ilk <> #list then
    return(me.removeArrowCursor())
  end if
  if ((tStartPos.getAt(1) - tloc.getAt(1)) = (tStartPos.getAt(2) - tloc.getAt(2))) then
    pArrowCursor = 1
    cursor([member(getmemnum("cursor_arrow_l")), member(getmemnum("cursor_arrow_l_mask"))])
  else
    me.removeArrowCursor()
  end if
end

on removeArrowCursor me 
  pArrowCursor = 0
  cursor(-1)
  return TRUE
end

on eventProcJumpTicketAutomatic me 
  if threadExists(#pellehyppy) then
    return(getThread(#pellehyppy).getInterface().showTicketWnd())
  else
    return FALSE
  end if
end

on poolTeleport me, tEvent, tSprID, tParam 
  tMyName = getObject(#session).get("user_name")
  if not getThread(#room).getComponent().userObjectExists(tMyName) then
    return FALSE
  end if
  tloc = getThread(#room).getComponent().getUserObject(tMyName).getLocation()
  getThread(#room).getInterface().eventProcRoom(tEvent, "floor", tParam)
  if not tSprID contains "pool_clickarea" and tloc.getAt(3) < 7 then
    if tloc.getAt(2) > 11 and tloc.getAt(1) < 20 then
      getConnection(getVariable("connection.room.id")).send(#room, "Move 17 22")
    else
      getConnection(getVariable("connection.room.id")).send(#room, "Move 31 11")
    end if
  else
    if tSprID contains "pool_clickarea" and (tloc.getAt(3) = 7) then
      if tloc.getAt(2) > 11 then
        getConnection(getVariable("connection.room.id")).send(#room, "Move 17 21")
      else
        getConnection(getVariable("connection.room.id")).send(#room, "Move 31 10")
      end if
    end if
  end if
end
