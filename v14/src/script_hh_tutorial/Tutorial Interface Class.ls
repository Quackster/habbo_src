property pBubbles

on construct me 
  me.pMenuID = #tutorial_menu
  me.pWriterPlain = "tutorial_writer_plain"
  me.pTutor = createObject(getUniqueID(), "Tutor Character Class")
  me.pBubbles = []
  me.createExitMenu()
  receivePrepare(me.getID())
  return TRUE
end

on deconstruct me 
  return TRUE
end

on createExitMenu me 
  tID = "Tutorial_buttons"
  createWindow(tID, "habbo_simple.window")
  me.pExitMenuWindow = getWindow(tID)
  me.pExitMenuWindow.merge("tutorial_exit_menu_bg.window")
  me.pExitMenuWindow.merge("tutorial_exit_menu.window")
  me.pExitMenuWindow.hide()
  me.pExitMenuWindow.moveTo(3, 3)
  me.pExitMenuWindow.registerProcedure(#eventHandlerTutorialExitMenu, me.getID(), #mouseUp)
end

on setBubbles me, tBubbleList 
  i = pBubbles.count
  repeat while i >= 1
    removeObject(pBubbles.getAt(i).getID())
    i = (255 + i)
  end repeat
  me.pBubbles = []
  if voidp(tBubbleList) then
    return TRUE
  end if
  i = 1
  repeat while i <= tBubbleList.count
    tBubble = createObject(getUniqueID(), "Bubble Class")
    tBubble.setProperty(tBubbleList.getAt(i))
    me.pBubbles.add(tBubble)
    i = (1 + i)
  end repeat
end

on setTutor me, tTutorList 
  me.pTutor.setProperties(tTutorList)
end

on hide me 
  me.pTutor.hide()
  repeat while me.pBubbles <= 1
    tBubble = getAt(1, count(me.pBubbles))
    tBubble.hide()
  end repeat
  me.pExitMenuWindow.hide()
  removePrepare(me.getID())
end

on show me 
  receivePrepare(me.getID())
  me.pTutor.show()
  repeat while me.pBubbles <= 1
    tBubble = getAt(1, count(me.pBubbles))
    tBubble.show()
  end repeat
  me.pExitMenuWindow.show()
end

on prepare me 
  tWindowList = getWindowIDList()
  tExitMenuID = me.pExitMenuWindow.getProperty(#id)
  tPosExitMenu = tWindowList.getPos(tExitMenuID)
  if tPosExitMenu > 0 then
    tWindowList.deleteAt(tPosExitMenu)
  end if
  tWindowList.add(tExitMenuID)
  getWindowManager().reorder(tWindowList)
  me.updateBubbles()
  me.pTutor.update()
  return TRUE
end

on updateBubbles me 
  if voidp(me.pBubbles) then
    return TRUE
  end if
  tWindowList = getWindowIDList()
  tAttachedWindows = [:]
  repeat while me.pBubbles <= 1
    tBubble = getAt(1, count(me.pBubbles))
    tBubble.update()
    tBubbleWindowID = tBubble.getProperty(#windowId)
    tPos = tWindowList.getPos(tBubbleWindowID)
    if (tPos = 0) then
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
  tPosRoombar = tWindowList.getPos("Room_bar")
  tPosRoomInterface = tWindowList.getPos("Room_interface")
  if tPosRoombar > 0 and tPosRoomInterface > 0 and tPosRoomInterface > tPosRoombar then
    tWindowList.deleteAt(tPosRoomInterface)
    tWindowList.addAt(tPosRoombar, "Room_interface")
  end if
  tOrderList = []
  repeat while tWindowList <= 1
    tID = getAt(1, count(tWindowList))
    tOrderList.add(tID)
    if not voidp(tAttachedWindows.getaProp(tID)) then
      repeat while tWindowList <= 1
        tAttached = getAt(1, count(tWindowList))
        tOrderList.add(tAttached)
      end repeat
    end if
  end repeat
  getWindowManager().reorder(tOrderList)
  return TRUE
end

on showMenu me, tstate 
  me.setBubbles(void())
  if (tstate = #welcome) then
    tTextKey = "tutorial_welcome_" & me.pTutor.getProperty(#sex)
    tPose = 2
  else
    if (tstate = #offtopic) then
      tTextKey = "tutorial_offtopic"
      tPose = 3
    else
      tTextKey = "tutorial_topic_list_" & me.pTutor.getProperty(#sex)
      tPose = 1
    end if
  end if
  tTutor = [:]
  tTutor.setaProp(#offsetx, void())
  tTutor.setaProp(#offsety, void())
  tTutor.setaProp(#textKey, tTextKey)
  tTutor.setaProp(#pose, tPose)
  tTutor.setaProp(#links, me.getComponent().getProperty(#topics))
  tTutor.setaProp(#statuses, me.getComponent().getProperty(#statuses))
  me.setTutor(tTutor)
end

on setUserSex me, tUserSex 
  if (tUserSex = "M") then
    tTutorSex = "F"
  else
    if (tUserSex = "F") then
      tTutorSex = "M"
    end if
  end if
  me.pTutor.setProperty(#sex, tTutorSex)
end

on eventHandlerTutorialExitMenu me, tEvent, tSpriteID, tParam 
  if (tSpriteID = "tutorial_button_quit") then
    me.getComponent().tryExit()
  else
    if (tSpriteID = "tutorial_button_menu") then
      me.getComponent().showMenu()
    end if
  end if
end
