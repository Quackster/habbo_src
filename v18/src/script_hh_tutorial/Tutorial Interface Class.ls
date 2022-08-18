property pWriterPlain, pTutorialConfig, pTopicList, pView, pMenuID, pBubbles, pTutor, pExitMenuWindow

on construct me
  me.pMenuID = #tutorial_menu
  me.pWriterPlain = "tutorial_writer_plain"
  me.pTutor = createObject(getUniqueID(), "Tutor Character Class")
  me.pBubbles = []
  me.createExitMenu()
  receivePrepare(me.getID())
  return 1
end

on deconstruct me
  return 1
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
  repeat with i = pBubbles.count down to 1
    removeObject(pBubbles[i].getID())
  end repeat
  me.pBubbles = []
  if voidp(tBubbleList) then
    return 1
  end if
  repeat with i = 1 to tBubbleList.count
    tBubble = createObject(getUniqueID(), "Bubble Class")
    tBubble.setProperty(tBubbleList[i])
    me.pBubbles.add(tBubble)
  end repeat
end

on setTutor me, tTutorList
  me.pTutor.setProperties(tTutorList)
end

on hide me
  me.pTutor.hide()
  repeat with tBubble in me.pBubbles
    tBubble.hide()
  end repeat
  me.pExitMenuWindow.hide()
  removePrepare(me.getID())
end

on show me
  receivePrepare(me.getID())
  me.pTutor.show()
  repeat with tBubble in me.pBubbles
    tBubble.show()
  end repeat
  me.pExitMenuWindow.show()
end

on prepare me
  tWindowList = getWindowIDList()
  tExitMenuID = me.pExitMenuWindow.getProperty(#id)
  tPosExitMenu = tWindowList.getPos(tExitMenuID)
  if (tPosExitMenu > 0) then
    tWindowList.deleteAt(tPosExitMenu)
  end if
  tWindowList.add(tExitMenuID)
  getWindowManager().reorder(tWindowList)
  me.updateBubbles()
  me.pTutor.update()
  return 1
end

on updateBubbles me
  if voidp(me.pBubbles) then
    return 1
  end if
  tWindowList = getWindowIDList()
  tAttachedWindows = [:]
  repeat with tBubble in me.pBubbles
    tBubble.update()
    tBubbleWindowID = tBubble.getProperty(#windowID)
    tPos = tWindowList.getPos(tBubbleWindowID)
    if (tPos = 0) then
      next repeat
    end if
    tTargetWindowID = tBubble.getProperty(#targetWindowID)
    if voidp(tTargetWindowID) then
      getWindow(tBubbleWindowID).hide()
      next repeat
    else
      tWindowList.deleteAt(tPos)
    end if
    if voidp(tAttachedWindows.getaProp(tTargetWindowID)) then
      tAttachedWindows.setaProp(tTargetWindowID, [tBubbleWindowID])
      next repeat
    end if
    tAttachedWindows[tTargetWindowID].add(tBubbleWindowID)
  end repeat
  tPosRoombar = tWindowList.getPos("Room_bar")
  tPosRoomInterface = tWindowList.getPos("Room_interface")
  if (((tPosRoombar > 0) and (tPosRoomInterface > 0)) and (tPosRoomInterface > tPosRoombar)) then
    tWindowList.deleteAt(tPosRoomInterface)
    tWindowList.addAt(tPosRoombar, "Room_interface")
  end if
  tOrderList = []
  repeat with tID in tWindowList
    tOrderList.add(tID)
    if not voidp(tAttachedWindows.getaProp(tID)) then
      repeat with tAttached in tAttachedWindows[tID]
        tOrderList.add(tAttached)
      end repeat
    end if
  end repeat
  getWindowManager().reorder(tOrderList)
  return 1
end

on showMenu me, tstate
  me.setBubbles(VOID)
  case tstate of
    #welcome:
      tTextKey = ("tutorial_welcome_" & me.pTutor.getProperty(#sex))
      tPose = 2
    #offtopic:
      tTextKey = "tutorial_offtopic"
      tPose = 3
    otherwise:
      tTextKey = ("tutorial_topic_list_" & me.pTutor.getProperty(#sex))
      tPose = 1
  end case
  tTutor = [:]
  tTutor.setaProp(#offsetx, VOID)
  tTutor.setaProp(#offsety, VOID)
  tTutor.setaProp(#textKey, tTextKey)
  tTutor.setaProp(#pose, tPose)
  tTutor.setaProp(#links, me.getComponent().getProperty(#topics))
  tTutor.setaProp(#statuses, me.getComponent().getProperty(#statuses))
  me.setTutor(tTutor)
end

on setUserSex me, tUserSex
  case tUserSex of
    "M":
      tTutorSex = "F"
    "F":
      tTutorSex = "M"
  end case
  me.pTutor.setProperty(#sex, tTutorSex)
end

on eventHandlerTutorialExitMenu me, tEvent, tSpriteID, tParam
  case tSpriteID of
    "tutorial_button_quit":
      me.getComponent().tryExit()
    "tutorial_button_menu":
      me.getComponent().showMenu()
  end case
end
