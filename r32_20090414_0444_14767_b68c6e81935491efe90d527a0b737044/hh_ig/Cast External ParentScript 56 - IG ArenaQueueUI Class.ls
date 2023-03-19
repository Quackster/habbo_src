property pWindowID

on construct me
  pWindowID = getText("ig_arena_queue_header")
  return 1
end

on deconstruct me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return me.ancestor.deconstruct()
end

on render me, tQueuePos
  if not windowExists(pWindowID) then
    me.addWindows()
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("ig_queue_text")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(replaceChunks(getText("ig_arena_queue_text"), "\x", string(tQueuePos)))
  return 1
end

on addWindows me
  createWindow(pWindowID, VOID)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.merge("ig_arena_queue.window")
  tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseDown)
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  if tSprID <> "ig_leave_game.button" then
    return 1
  end if
  me.getHandler().send_LEAVE_GAME()
  me.getHandler().send_EXIT_GAME(0)
  me.getComponent().setSystemState(#ready)
  me.Remove()
  return 1
end
