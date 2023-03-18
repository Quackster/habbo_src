property pModBadgeList

on construct me
  pModBadgeList = getVariableValue("moderator.badgelist")
  return 1
end

on deconstruct me
  return 1
end

on createFurnitureWindow me, tClass, tName, tDesc, tMemName
  tID = "object.displayer.furni"
  createWindow(tID, "obj_disp_furni.window")
  tWndObj = getWindow(tID)
  tWndObj.getElement("room_obj_disp_name").setText(tName)
  tWndObj.getElement("room_obj_disp_desc").setText(tDesc)
  tImage = member(getmemnum(tMemName)).image
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return tID
end

on getHumanWindowID me
  return "object.displayer.human"
end

on createHumanWindow me, tClass, tName, tPersMessage, tImage, tBadge, tSelectedObj, tBadgeObjID
  tID = me.getHumanWindowID()
  createWindow(tID, "obj_disp_human.window")
  tWndObj = getWindow(tID)
  tWndObj.getElement("room_obj_disp_name").setText(tName)
  tWndObj.getElement("room_obj_disp_desc").setText(tPersMessage)
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tBadgeObj = getObject(tBadgeObjID)
  tBadgeObj.updateInfoStandBadge(tID, tSelectedObj, tBadge)
  tWndObj.lock()
  return tID
end

on createPetWindow me, tClass, tName, tDesc, tImage
  tID = "object.displayer.furni"
  createWindow(tID, "obj_disp_furni.window")
  tWndObj = getWindow(tID)
  tWndObj.getElement("room_obj_disp_name").setText(tName)
  tWndObj.getElement("room_obj_disp_desc").setText(tDesc)
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return tID
end

on createActionsHumanWindow me, tTargetUserName
  tSessionObj = getObject(#session)
  tID = "object.displayer.actions"
  if tTargetUserName = tSessionObj.GET("user_name") then
    tWindowModel = "obj_disp_actions_own.window"
    tButtonList = [:]
    tButtonList["wave"] = #visible
    tButtonList["dance"] = #visible
    tButtonList["hcdance"] = #visible
    if tSessionObj.GET("hc") then
      tButtonList["dance"] = #hidden
    else
      tButtonList["hcdance"] = #hidden
    end if
  else
    tButtonList = [:]
    tButtonList["friend"] = #visible
    tButtonList["trade"] = #visible
    tButtonList["ignore"] = #visible
    tButtonList["unignore"] = #visible
    tButtonList["kick"] = #visible
    tButtonList["give_rights"] = #visible
    tButtonList["take_rights"] = #visible
    tWindowModel = "obj_disp_actions_peer.window"
    tRoomOwner = tSessionObj.GET("room_owner")
    tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
    if threadExists(#messenger) then
      tBuddyData = getThread(#messenger).getComponent().getBuddyData()
      if tBuddyData.online.getPos(tTargetUserName) > 0 then
        tButtonList["friend"] = #deactive
      end if
    end if
    tRoomComponent = getThread(#room).getComponent()
    tNotPrivateRoom = tRoomComponent.getRoomID() <> "private"
    tNoTrading = tRoomComponent.getRoomData()[#trading] = 0
    tTradeTimeout = 0
    tUserRights = getObject(#session).GET("user_rights")
    tTradeProhibited = not tUserRights.getOne("fuse_trade")
    if tTradeTimeout or tNotPrivateRoom or tNoTrading or tTradeProhibited then
      tButtonList["trade"] = #deactive
    end if
    tRoomInterface = getThread(#room).getInterface()
    tSelectedObj = tRoomInterface.getSelectedObject()
    tUserInfo = tRoomComponent.getUserObject(tSelectedObj).getInfo()
    tBadge = tUserInfo.getaProp(#badge)
    tIgnoreListObj = getThread(#room).getInterface().pIgnoreListObj
    if tIgnoreListObj.getIgnoreStatus(tUserInfo.name) then
      tButtonList["ignore"] = #hidden
    else
      tButtonList["unignore"] = #hidden
    end if
    if pModBadgeList.getOne(tBadge) > 0 then
      tButtonList["ignore"] = #hidden
      tButtonList["unignore"] = #hidden
    end if
    if not tRoomOwner and not tAnyRoomController then
      tButtonList["kick"] = #hidden
    end if
    if tRoomOwner then
      if tUserInfo.ctrl = 0 then
        tButtonList["take_rights"] = #hidden
      else
        if tUserInfo.ctrl = "furniture" then
          tButtonList["give_rights"] = #hidden
        else
          if tUserInfo.ctrl = "useradmin" then
            tButtonList["give_rights"] = #hidden
          end if
        end if
      end if
    else
      tButtonList["give_rights"] = #hidden
      tButtonList["take_rights"] = #hidden
    end if
  end if
  createWindow(tID, tWindowModel)
  tWndObj = getWindow(tID)
  tCurrentButtonTopPos = 0
  tButtonVertMargins = 3
  tButtonHeight = 15
  tHiddenRowCount = 0
  repeat with tIndex = 1 to tButtonList.count
    tButtonID = tButtonList.getPropAt(tIndex)
    tButtonVisibility = tButtonList[tButtonID]
    tElement = tWndObj.getElement(tButtonID & ".button")
    tLeftPos = tElement.getProperty(#locX)
    if tIndex = 1 then
      tCurrentButtonTopPos = tElement.getProperty(#locY)
    end if
    case tButtonVisibility of
      #visible:
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tCurrentButtonTopPos = tCurrentButtonTopPos + tButtonHeight + tButtonVertMargins
      #deactive:
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tElement.deactivate()
        tCurrentButtonTopPos = tCurrentButtonTopPos + tButtonHeight + tButtonVertMargins
      #hidden:
        tElement.setProperty(#visible, 0)
        tHiddenRowCount = tHiddenRowCount + 1
    end case
  end repeat
  tWndObj.lock()
  tNewHeight = tWndObj.getProperty(#height) - (tHiddenRowCount * (tButtonHeight + tButtonVertMargins)) - tButtonVertMargins
  createTimeout(#temp, 10, #resizeWindowTo, me.getID(), [#id: tID, #x: tWndObj.getProperty(#width), #y: tNewHeight], 1)
  return tID
end

on createActionsFurniWindow me, tClass
  tButtonList = []
  tSessionObj = getObject(#session)
  tRoomController = tSessionObj.GET("room_controller")
  if tRoomController then
    tButtonList = ["move", "rotate"]
  end if
  tRoomOwner = tSessionObj.GET("room_owner")
  if tRoomOwner then
    tButtonList = ["move", "rotate", "pick"]
  end if
  tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
  if tAnyRoomController then
    tButtonList = ["move", "rotate", "pick"]
  end if
  if tClass = "item" then
    tButtonList.deleteOne("move")
    tButtonList.deleteOne("rotate")
  end if
  tID = "object.displayer.actions"
  createWindow(tID, "obj_disp_actions_furni.window")
  tWndObj = getWindow(tID)
  tAllButtons = ["move", "rotate", "pick", "delete"]
  tRowHeight = 20
  repeat with tButtonID in tAllButtons
    if not tButtonList.getOne(tButtonID) then
      tElem = tWndObj.getElement(tButtonID & ".button")
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
    end if
  end repeat
  tDeletedRowCount = tAllButtons.count - tButtonList.count
  tNewHeight = -1 * tDeletedRowCount * tRowHeight
  tWndObj.lock()
  createTimeout(#temp, 10, #resizeWindowBy, me.getID(), [#id: tID, #x: 0, #y: tNewHeight], 1)
  return tID
end

on createLinksWindow me, tFormat
  case tFormat of
    #own:
      tWindowModel = "obj_disp_links_own.window"
    #peer:
      tWindowModel = "obj_disp_links_peer.window"
    #furni:
      tWindowModel = "obj_disp_links_furni.window"
  end case
  tID = "object.displayer.links"
  createWindow(tID, tWindowModel)
  tWndObj = getWindow(tID)
  tWndObj.lock()
  return tID
end

on createBottomWindow me
  tID = "object.displayer.bottom"
  createWindow(tID, "obj_disp_bottom.window")
  tWndObj = getWindow(tID)
  tWndObj.lock()
  return tID
end

on resizeWindowBy me, tParams
  tWndObj = getWindow(tParams[#id])
  tX = tParams[#x]
  tY = tParams[#y]
  tWndObj.resizeBy(tX, tY)
end

on resizeWindowTo me, tParams
  tWndObj = getWindow(tParams[#id])
  tX = tParams[#x]
  tY = tParams[#y]
  tWndObj.resizeTo(tX, tY)
end
