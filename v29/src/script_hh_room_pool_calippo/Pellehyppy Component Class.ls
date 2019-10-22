property pJumpButtonsWnd, pTicketCountWnd

on construct me 
  pJumpButtonsWnd = "pool_helpbuttons"
  pTicketCountWnd = "pool_ticketcount"
  registerMessage(#sendVoteSign, me.getID(), #sendSign)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#sendVoteSign, me.getID())
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
  return TRUE
end

on openUimakoppi me 
  me.getInterface().openUimakoppi()
end

on closeUimaKoppi me 
  me.getInterface().closeUimaKoppi()
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
  me.getInterface().deactivateChatField()
  getConnection(getVariable("connection.room.id")).send("JUMPSTART")
  me.poolUpView("jump")
  createWindow(pJumpButtonsWnd, "ph_instructions.window", 20, 20)
  tWndObj = getWindow(pJumpButtonsWnd)
  tWndObj.registerClient(me.getID())
  tWndObj.moveZ(19000040)
  tWndObj.lock()
  tPelleKeys = getVariableValue("swimjump.key.list")
  if tPelleKeys.ilk <> #propList then
    error(me, "Couldn't retrieve keymap for jump! Using default keys.", #jumpingPlaceOk)
    tPelleKeys = [#run1:"A", #run2:"D", #dive1:"W", #dive2:"E", #dive3:"A", #dive4:"S", #dive5:"D", #dive6:"Z", #dive7:"X", #jump:"SPACE"]
  end if
  i = 1
  repeat while i <= 9
    tWndObj.getElement("ph_ui_text_" & i).setText(tPelleKeys.getAt(i))
    i = (1 + i)
  end repeat
  tUserName = getObject(#session).GET("user_name")
  tFigure = getThread(#room).getComponent().getOwnUser().getPelleFigure()
  createObject(#jumpingpelle_obj, "Jumping Pelle Class", "Pelle KeyDown Class")
  getObject(#jumpingpelle_obj).Init(tUserName, tFigure, 0)
  return TRUE
end

on jumpPlayPack me, tMsg 
  if objectExists(#jumpingpelle_obj) then
    removeObject(#jumpingpelle_obj)
  end if
  if not objectExists(#playpackpelle_obj) then
    createObject(#playpackpelle_obj, "Jumping Pelle Class", "Pelle Player Class")
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(tMsg.getAt(#index))
  tFigure = call(#getPelleFigure, [tUserObj])
  if not listp(tFigure) then
    return FALSE
  end if
  if (tMsg.getAt(#index) = getObject(#session).GET("user_index")) then
    me.poolUpView("playback")
  end if
  getObject(#playpackpelle_obj).Init(tUserObj.getName(), tFigure, 1)
  getObject(#playpackpelle_obj).initPlayer(tUserObj.getName(), tMsg.getAt(#jumpdata))
  if objectExists(#pool_fuse_screen) then
    getObject(#pool_fuse_screen).fuseShow_showtext(tUserObj.getName())
  end if
end

on sendSign me, tSign 
  getConnection(getVariable("connection.room.id")).send("SIGN", tSign)
end

on sendJumpPerf me, tJumpData 
  if not objectExists("Figure_System_Pool") then
    return(error(me, "Figure system Pool object not found", #sendJumpPerf))
  end if
  getConnection(getVariable("connection.room.id")).send("JUMPPERF", tJumpData)
end
