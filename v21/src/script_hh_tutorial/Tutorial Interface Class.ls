on construct(me)
  me.pMenuID = #tutorial_menu
  me.pWriterPlain = "tutorial_writer_plain"
  me.pFrameCount = 0
  me.pTutor = createObject(getUniqueID(), "Tutor Character Class")
  me.pBubbles = []
  me.createExitMenu()
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on createExitMenu(me)
  tID = "Tutorial_buttons"
  createWindow(tID, "habbo_simple.window")
  me.pExitMenuWindow = getWindow(tID)
  pExitMenuWindow.merge("tutorial_exit_menu_bg.window")
  pExitMenuWindow.merge("tutorial_exit_menu.window")
  pExitMenuWindow.hide()
  pExitMenuWindow.moveTo(3, 3)
  pExitMenuWindow.registerProcedure(#eventHandlerTutorialExitMenu, me.getID(), #mouseUp)
  exit
end

on setBubbles(me, tBubbleList)
  i = pBubbles.count
  repeat while i >= 1
    removeObject(pBubbles.getAt(i).getID())
    i = 255 + i
  end repeat
  me.pBubbles = []
  if voidp(tBubbleList) then
    return(1)
  end if
  i = 1
  repeat while i <= tBubbleList.count
    tBubble = createObject(getUniqueID(), "Bubble Class")
    tBubble.setProperty(tBubbleList.getAt(i))
    pBubbles.add(tBubble)
    i = 1 + i
  end repeat
  exit
end

on setTutor(me, tTutorList)
  pTutor.setProperties(tTutorList)
  exit
end

on hide(me)
  pTutor.hide()
  repeat while me <= undefined
    tBubble = getAt(undefined, undefined)
    tBubble.hide()
  end repeat
  pExitMenuWindow.hide()
  removePrepare(me.getID())
  exit
end

on show(me)
  receivePrepare(me.getID())
  pTutor.show()
  repeat while me <= undefined
    tBubble = getAt(undefined, undefined)
    tBubble.show()
  end repeat
  pExitMenuWindow.show()
  exit
end

on prepare(me)
  tWindowIdList = pTutor.update()
  me.add(pExitMenuWindow.getProperty(#id))
  tWindowList = me.updateBubbles()
  repeat while me <= undefined
    tID = getAt(undefined, undefined)
    tPos = tWindowList.getPos(tID)
    if tPos > 0 then
      tWindowList.deleteAt(tPos)
    end if
    tWindowList.add(tID)
  end repeat
  getWindowManager().reorder(tWindowList)
  return(1)
  exit
end

on updateBubbles(me)
  if voidp(me.pBubbles) then
    return(1)
  end if
  tWindowList = getWindowIDList()
  tAttachedWindows = []
  repeat while me <= undefined
    tBubble = getAt(undefined, undefined)
    tBubble.update()
    tBubbleWindowID = tBubble.getProperty(#windowId)
    tPos = tWindowList.getPos(tBubbleWindowID)
    if tPos = 0 then
    else
      tTargetWindowID = tBubble.getProperty(#targetWindowID)
      if voidp(tTargetWindowID) then
        getWindow(tBubbleWindowID).hide()
      else
        tWindowList.deleteAt(tPos)
      end if
      if voidp(tAttachedWindows.getaProp(tTargetWindowID)) then
        tAttachedWindows.setaProp(tTargetWindowID, [tBubbleWindowID])
      else
        tAttachedWindows.getAt(tTargetWindowID).add(tBubbleWindowID)
      end if
    end if
  end repeat
  tPosRoombar = tWindowList.getPos("RoomBarID")
  tPosRoomInterface = tWindowList.getPos("Room_interface")
  if tPosRoombar > 0 and tPosRoomInterface > 0 and tPosRoomInterface > tPosRoombar then
    tWindowList.deleteAt(tPosRoomInterface)
    tWindowList.addAt(tPosRoombar, "Room_interface")
  end if
  tOrderList = []
  repeat while me <= undefined
    tID = getAt(undefined, undefined)
    tOrderList.add(tID)
    if not voidp(tAttachedWindows.getaProp(tID)) then
      repeat while me <= undefined
        tAttached = getAt(undefined, undefined)
        tOrderList.add(tAttached)
      end repeat
    end if
  end repeat
  return(tOrderList)
  exit
end

on showMenu(me, tstate)
  me.setBubbles(void())
  if me = #welcome then
    tTextKey = me & pTutor.getProperty(#sex)
    tPose = 2
  else
    if me = #offtopic then
      tTextKey = "tutorial_offtopic"
      tPose = 3
    else
      tTextKey = me & pTutor.getProperty(#sex)
      tPose = 1
    end if
  end if
  tTutor = []
  tTutor.setaProp(#offsetx, void())
  tTutor.setaProp(#offsety, void())
  tTutor.setaProp(#textKey, tTextKey)
  tTutor.setaProp(#pose, tPose)
  tTutor.setaProp(#links, me.getComponent().getProperty(#topics))
  tTutor.setaProp(#statuses, me.getComponent().getProperty(#statuses))
  me.setTutor(tTutor)
  exit
end

on setUserSex(me, tUserSex)
  if me = "M" then
    tTutorSex = "F"
  else
    if me = "F" then
      tTutorSex = "M"
    end if
  end if
  pTutor.setProperty(#sex, tTutorSex)
  exit
end

on eventHandlerTutorialExitMenu(me, tEvent, tSpriteID, tParam)
  if me = "tutorial_button_quit" then
    me.getComponent().tryExit()
  else
    if me = "tutorial_button_menu" then
      me.getComponent().showMenu()
    end if
  end if
  exit
end