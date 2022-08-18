property pModBadgeList



on construct me 

  pModBadgeList = getVariableValue("moderator.badgelist")

  return TRUE

end



on deconstruct me 

  return TRUE

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

  return(tID)

end



on getHumanWindowID me 

  return("object.displayer.human")

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

  return(tID)

end



on createPetWindow me, tClass, tName, tDesc, tImage 

  tID = "object.displayer.furni"

  createWindow(tID, "obj_disp_furni.window")

  tWndObj = getWindow(tID)

  tWndObj.getElement("room_obj_disp_name").setText(tName)

  tWndObj.getElement("room_obj_disp_desc").setText(tDesc)

  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)

  tWndObj.lock()

  return(tID)

end



on createActionsHumanWindow me, tTargetUserName 

  tSessionObj = getObject(#session)

  tID = "object.displayer.actions"

  if (tTargetUserName = tSessionObj.GET("user_name")) then

    tWindowModel = "obj_disp_actions_own.window"

    tButtonList = [:]

    tButtonList.setAt("wave", #visible)

    tButtonList.setAt("dance", #visible)

    tButtonList.setAt("hcdance", #visible)

    if tSessionObj.GET("hc") then

      tButtonList.setAt("dance", #hidden)

    else

      tButtonList.setAt("hcdance", #hidden)

    end if

  else

    tButtonList = [:]

    tButtonList.setAt("friend", #visible)

    tButtonList.setAt("trade", #visible)

    tButtonList.setAt("ignore", #visible)

    tButtonList.setAt("unignore", #visible)

    tButtonList.setAt("kick", #visible)

    tButtonList.setAt("give_rights", #visible)

    tButtonList.setAt("take_rights", #visible)

    tWindowModel = "obj_disp_actions_peer.window"

    tRoomOwner = tSessionObj.GET("room_owner")

    tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")

    if threadExists(#messenger) then

      tBuddyData = getThread(#messenger).getComponent().getBuddyData()

      if tBuddyData.online.getPos(tTargetUserName) > 0 then

        tButtonList.setAt("friend", #deactive)

      end if

    end if

    tRoomComponent = getThread(#room).getComponent()

    tNotPrivateRoom = tRoomComponent.getRoomID() <> "private"

    tNoTrading = (tRoomComponent.getRoomData().getAt(#trading) = 0)

    tTradeTimeout = 0

    tUserRights = getObject(#session).GET("user_rights")

    tTradeProhibited = not tUserRights.getOne("fuse_trade")

    if tTradeTimeout or tNotPrivateRoom or tNoTrading or tTradeProhibited then

      tButtonList.setAt("trade", #deactive)

    end if

    tRoomInterface = getThread(#room).getInterface()

    tSelectedObj = tRoomInterface.getSelectedObject()

    tUserInfo = tRoomComponent.getUserObject(tSelectedObj).getInfo()

    tBadge = tUserInfo.getaProp(#badge)

    tIgnoreListObj = getThread(#room).getInterface().pIgnoreListObj

    if tIgnoreListObj.getIgnoreStatus(tUserInfo.name) then

      tButtonList.setAt("ignore", #hidden)

    else

      tButtonList.setAt("unignore", #hidden)

    end if

    if pModBadgeList.getOne(tBadge) > 0 then

      tButtonList.setAt("ignore", #hidden)

      tButtonList.setAt("unignore", #hidden)

    end if

    if not tRoomOwner and not tAnyRoomController then

      tButtonList.setAt("kick", #hidden)

    end if

    if tRoomOwner then

      if (tUserInfo.ctrl = 0) then

        tButtonList.setAt("take_rights", #hidden)

      else

        if (tUserInfo.ctrl = "furniture") then

          tButtonList.setAt("give_rights", #hidden)

        else

          if (tUserInfo.ctrl = "useradmin") then

            tButtonList.setAt("give_rights", #hidden)

          end if

        end if

      end if

    else

      tButtonList.setAt("give_rights", #hidden)

      tButtonList.setAt("take_rights", #hidden)

    end if

  end if

  createWindow(tID, tWindowModel)

  tWndObj = getWindow(tID)

  tCurrentButtonTopPos = 0

  tButtonVertMargins = 3

  tButtonHeight = 15

  tHiddenRowCount = 0

  tIndex = 1

  repeat while tIndex <= tButtonList.count

    tButtonID = tButtonList.getPropAt(tIndex)

    tButtonVisibility = tButtonList.getAt(tButtonID)

    tElement = tWndObj.getElement(tButtonID & ".button")

    tLeftPos = tElement.getProperty(#locX)

    if (tIndex = 1) then

      tCurrentButtonTopPos = tElement.getProperty(#locY)

    end if

    if (tButtonVisibility = #visible) then

      tElement.moveTo(tLeftPos, tCurrentButtonTopPos)

      tCurrentButtonTopPos = ((tCurrentButtonTopPos + tButtonHeight) + tButtonVertMargins)

    else

      if (tButtonVisibility = #deactive) then

        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)

        tElement.deactivate()

        tCurrentButtonTopPos = ((tCurrentButtonTopPos + tButtonHeight) + tButtonVertMargins)

      else

        if (tButtonVisibility = #hidden) then

          tElement.setProperty(#visible, 0)

          tHiddenRowCount = (tHiddenRowCount + 1)

        end if

      end if

    end if

    tIndex = (1 + tIndex)

  end repeat

  tWndObj.lock()

  tNewHeight = ((tWndObj.getProperty(#height) - (tHiddenRowCount * (tButtonHeight + tButtonVertMargins))) - tButtonVertMargins)

  createTimeout(#temp, 10, #resizeWindowTo, me.getID(), [#id:tID, #x:tWndObj.getProperty(#width), #y:tNewHeight], 1)

  return(tID)

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

  if (tClass = "item") then

    tButtonList.deleteOne("move")

    tButtonList.deleteOne("rotate")

  end if

  tID = "object.displayer.actions"

  createWindow(tID, "obj_disp_actions_furni.window")

  tWndObj = getWindow(tID)

  tAllButtons = ["move", "rotate", "pick", "delete"]

  tRowHeight = 20

  repeat while tAllButtons <= 1

    tButtonID = getAt(1, count(tAllButtons))

    if not tButtonList.getOne(tButtonID) then

      tElem = tWndObj.getElement(tButtonID & ".button")

      if tElem <> 0 then

        tElem.setProperty(#visible, 0)

      end if

    end if

  end repeat

  tDeletedRowCount = (tAllButtons.count - tButtonList.count)

  tNewHeight = ((-1 * tDeletedRowCount) * tRowHeight)

  tWndObj.lock()

  createTimeout(#temp, 10, #resizeWindowBy, me.getID(), [#id:tID, #x:0, #y:tNewHeight], 1)

  return(tID)

end



on createLinksWindow me, tFormat 

  if (tFormat = #own) then

    tWindowModel = "obj_disp_links_own.window"

  else

    if (tFormat = #peer) then

      tWindowModel = "obj_disp_links_peer.window"

    else

      if (tFormat = #furni) then

        tWindowModel = "obj_disp_links_furni.window"

      end if

    end if

  end if

  tID = "object.displayer.links"

  createWindow(tID, tWindowModel)

  tWndObj = getWindow(tID)

  tWndObj.lock()

  return(tID)

end



on createBottomWindow me 

  tID = "object.displayer.bottom"

  createWindow(tID, "obj_disp_bottom.window")

  tWndObj = getWindow(tID)

  tWndObj.lock()

  return(tID)

end



on resizeWindowBy me, tParams 

  tWndObj = getWindow(tParams.getAt(#id))

  tX = tParams.getAt(#x)

  tY = tParams.getAt(#y)

  tWndObj.resizeBy(tX, tY)

end



on resizeWindowTo me, tParams 

  tWndObj = getWindow(tParams.getAt(#id))

  tX = tParams.getAt(#x)

  tY = tParams.getAt(#y)

  tWndObj.resizeTo(tX, tY)

end

