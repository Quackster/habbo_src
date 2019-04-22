on construct(me)
  pNumOfPhTickets = 0
  pJumpButtonsWnd = "pool_helpbuttons"
  pTicketCountWnd = "pool_ticketcount"
  return(1)
  exit
end

on deconstruct(me)
  if objectExists(#jumpingpelle_obj) then
    removeObject(#jumpingpelle_obj)
  end if
  if objectExists(#playpackpelle_obj) then
    removeObject(#playpackpelle_obj)
  end if
  if objectExists(#poolclouds) then
    removeObject(#poolclouds)
  end if
  if visualizerExists(#pooltower) then
    removeVisualizer(#pooltower)
  end if
  if windowExists(pJumpButtonsWnd) then
    removeWindow(pJumpButtonsWnd)
  end if
  if windowExists(pTicketCountWnd) then
    removeWindow(pTicketCountWnd)
  end if
  pJumpinPelleObj = void()
  return(1)
  exit
end

on openUimakoppi(me)
  me.getInterface().openUimakoppi()
  exit
end

on closeUimaKoppi(me)
  me.getInterface().closeUimaKoppi()
  exit
end

on setNumOfPhTickets(me, tMsg)
  pNumOfPhTickets = tMsg
  return(1)
  exit
end

on getNumOfPhTickets(me)
  return(pNumOfPhTickets)
  exit
end

on poolUpView(me, tMode)
  if not visualizerExists(#pooltower) then
    createVisualizer(#pooltower, "pool_tower.room")
    -- UNK_C0 4326055
    exit
  end if
  if not objectExists(#poolclouds) then
    createObject(#poolclouds, "poolClouds Class")
  end if
  executeMessage(#hide_messenger)
  executeMessage(#hide_navigator)
  exit
end

on poolDownView(me)
  if windowExists(pJumpButtonsWnd) then
    removeWindow(pJumpButtonsWnd)
  end if
  if windowExists(pTicketCountWnd) then
    removeWindow(pTicketCountWnd)
  end if
  if objectExists(#poolclouds) then
    removeObject(#poolclouds)
  end if
  if visualizerExists(#pooltower) then
    removeVisualizer(#pooltower)
  end if
  exit
end

on jumpingPlaceOk(me)
  executeMessage(#roomStatistic, "jumpplace")
  me.getInterface().deactivateChatField()
  getConnection(getVariable("connection.room.id")).send(#room, "JUMPSTART")
  me.poolUpView("jump")
  createWindow(pJumpButtonsWnd, "ph_instructions.window", 20, 20)
  tWndObj = getWindow(pJumpButtonsWnd)
  tWndObj.registerClient(me.getID())
  -- UNK_E8 4326055
  exit
  tWndObj.lock()
  tUserName = getObject(#session).get("user_name")
  tUserObj = getThread(#room).getComponent().getUserObject(tUserName)
  tFigure = tUserObj.getPelleFigure()
  createObject(#jumpingpelle_obj, "Jumping Pelle Class", "Pelle KeyDown Class")
  getObject(#jumpingpelle_obj).Init(tUserName, tFigure, 0)
  return(1)
  exit
end

on jumpPlayPack(me, tMsg)
  if objectExists(#jumpingpelle_obj) then
    removeObject(#jumpingpelle_obj)
  end if
  if not objectExists(#playpackpelle_obj) then
    createObject(#playpackpelle_obj, "Jumping Pelle Class", "Pelle Player Class")
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(tMsg.getAt("name"))
  tFigure = tUserObj.getPelleFigure()
  if tMsg.getAt("name") = getObject(#session).get("user_name") then
    me.poolUpView("playback")
  end if
  getObject(#playpackpelle_obj).Init(tMsg.getAt("name"), tFigure, 1)
  getObject(#playpackpelle_obj).initPlayer(tMsg.getAt("name"), tMsg.getAt("jumpdata"))
  if objectExists(#pool_fuse_screen) then
    getObject(#pool_fuse_screen).fuseShow_showtext(tMsg.getAt("name"))
  end if
  exit
end

on sendSign(me, tSign)
  getConnection(getVariable("connection.room.id")).send(#room, "Sign " & tSign)
  exit
end

on buyPoolTickets(me, tName)
  if not connectionExists(getVariable("connection.info.id")) then
    return(error(me, "Connection not found:" && getVariable("connection.info.id"), #buyPoolTickets))
  end if
  if tName = "" then
    tName = getObject(#session).get("user_name")
  end if
  if voidp(tName) then
    tName = getObject(#session).get("user_name")
  end if
  getConnection(getVariable("connection.info.id")).send(#info, "BTCKS /" & tName)
  exit
end

on sendJumpPerf(me, tJumpData)
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  tName = getObject(#session).get("user_name")
  tFigure = getObject(#session).get("user_figure").duplicate()
  tPHFigure = tUserObj.pPhFigure
  tFigure = me.generateFigureDataToOldServerMode(tFigure, getObject(#session).get("user_sex"), 0).getAt("figuretoServer")
  tColor = string(tPHFigure.getAt("color"))
  tR = value(tColor.getPropRef(#item, 1).getProp(#char, 5, tColor.getPropRef(#item, 1).length))
  tG = value(tColor.getProp(#item, 2))
  tB = value(tColor.getPropRef(#item, 3).getProp(#char, 1, tColor.getPropRef(#item, 3).length - 1))
  tColor = tR & "," & tG & "," & tB
  tPHFigure = "ch=" & tPHFigure.getAt("model") & "/" & tColor
  tJump = tName & "\r" & tFigure & "\r" & tPHFigure & "\r" & tJumpData
  getConnection(getVariable("connection.room.id")).send(#room, "JUMPPERF" && tJump)
  exit
end