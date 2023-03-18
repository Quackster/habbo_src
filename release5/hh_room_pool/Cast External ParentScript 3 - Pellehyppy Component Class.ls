property pNumOfPhTickets, pJumpButtonsWnd, pTicketCountWnd

on construct me
  pNumOfPhTickets = 0
  pJumpButtonsWnd = "pool_helpbuttons"
  pTicketCountWnd = "pool_ticketcount"
  return 1
end

on deconstruct me
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
  pJumpinPelleObj = VOID
  return 1
end

on openUimakoppi me
  me.getInterface().openUimakoppi()
end

on closeUimaKoppi me
  me.getInterface().closeUimaKoppi()
end

on setNumOfPhTickets me, tMsg
  pNumOfPhTickets = tMsg
  return 1
end

on getNumOfPhTickets me
  return pNumOfPhTickets
end

on poolUpView me, tMode
  if not visualizerExists(#pooltower) then
    createVisualizer(#pooltower, "pool_tower.room")
    getVisualizer(#pooltower).moveZ(19000000)
  end if
  if not objectExists(#poolclouds) then
    createObject(#poolclouds, "poolClouds Class")
  end if
  executeMessage(#hide_messenger)
  executeMessage(#hide_navigator)
end

on poolDownView me
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
end

on jumpingPlaceOk me
  executeMessage(#roomStatistic, "jumpplace")
  me.getInterface().deactivateChatField()
  getConnection(getVariable("connection.room.id")).send(#room, "JUMPSTART")
  me.poolUpView("jump")
  createWindow(pJumpButtonsWnd, "ph_instructions.window", 20, 20)
  tWndObj = getWindow(pJumpButtonsWnd)
  tWndObj.registerClient(me.getID())
  tWndObj.moveZ(19000040)
  tWndObj.lock()
  tUserName = getObject(#session).get("user_name")
  tUserObj = getThread(#room).getComponent().getUserObject(tUserName)
  tFigure = tUserObj.getPelleFigure()
  createObject(#jumpingpelle_obj, "Jumping Pelle Class", "Pelle KeyDown Class")
  getObject(#jumpingpelle_obj).Init(tUserName, tFigure, 0)
  return 1
end

on jumpPlayPack me, tMsg
  if objectExists(#jumpingpelle_obj) then
    removeObject(#jumpingpelle_obj)
  end if
  if not objectExists(#playpackpelle_obj) then
    createObject(#playpackpelle_obj, "Jumping Pelle Class", "Pelle Player Class")
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(tMsg["name"])
  tFigure = tUserObj.getPelleFigure()
  if tMsg["name"] = getObject(#session).get("user_name") then
    me.poolUpView("playback")
  end if
  getObject(#playpackpelle_obj).Init(tMsg["name"], tFigure, 1)
  getObject(#playpackpelle_obj).initPlayer(tMsg["name"], tMsg["jumpdata"])
  if objectExists(#pool_fuse_screen) then
    getObject(#pool_fuse_screen).fuseShow_showtext(tMsg["name"])
  end if
end

on sendSign me, tSign
  getConnection(getVariable("connection.room.id")).send(#room, "Sign " & tSign)
end

on buyPoolTickets me, tName
  if not connectionExists(getVariable("connection.info.id")) then
    return error(me, "Connection not found:" && getVariable("connection.info.id"), #buyPoolTickets)
  end if
  if tName = EMPTY then
    tName = getObject(#session).get("user_name")
  end if
  if voidp(tName) then
    tName = getObject(#session).get("user_name")
  end if
  getConnection(getVariable("connection.info.id")).send(#info, "BTCKS /" & tName)
end

on sendJumpPerf me, tJumpData
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  tName = getObject(#session).get("user_name")
  tFigure = getObject(#session).get("user_figure").duplicate()
  tPHFigure = tUserObj.pPhFigure
  tFigure = me.generateFigureDataToOldServerMode(tFigure, getObject(#session).get("user_sex"), 0)["figuretoServer"]
  tColor = string(tPHFigure["color"])
  tR = value(tColor.item[1].char[5..tColor.item[1].length])
  tG = value(tColor.item[2])
  tB = value(tColor.item[3].char[1..tColor.item[3].length - 1])
  tColor = tR & "," & tG & "," & tB
  tPHFigure = "ch=" & tPHFigure["model"] & "/" & tColor
  tJump = tName & RETURN & tFigure & RETURN & tPHFigure & RETURN & tJumpData
  getConnection(getVariable("connection.room.id")).send(#room, "JUMPPERF" && tJump)
end
