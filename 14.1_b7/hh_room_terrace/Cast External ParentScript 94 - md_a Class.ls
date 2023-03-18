property pSplashs, pTimer, pCurtainsLocZ

on construct me
  pTimer = 0
  createObject("dew_clouds", "Mountain Clouds Class")
  createObject("dew_camera", "FUSE screen Class")
  initThread("mountain.index")
  initThread("paalu.index")
  receivePrepare(me.getID())
  me.prepareRoom()
  return 1
end

on deconstruct me
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
    else
      if tDest contains "Splash" then
        me.splash(tDest, tCommand)
      else
        if tDest contains "curtains" then
          me.curtains(tDest, tCommand)
        end if
      end if
    end if
  end if
end

on curtains me, tid, tCommand
  case tCommand of
    "open":
      tmember = member(getmemnum("dew_verho_auki"))
      tlocz = pCurtainsLocZ[tid] - 2000
    "close":
      tmember = member(getmemnum("dew_verho_kiinni"))
      tlocz = pCurtainsLocZ[tid] - 1000
  end case
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return 0
  end if
  tRoomVis.getSprById(tid).setMember(tmember)
  tRoomVis.getSprById(tid).locZ = tlocz
  return 1
end

on splash me, tDest, tCommand
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
