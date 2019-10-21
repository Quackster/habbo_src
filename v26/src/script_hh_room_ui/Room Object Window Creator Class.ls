on construct(me)
  pModBadgeList = getVariableValue("moderator.badgelist")
  pExtensionClosedID = "roomnfo_ext_right"
  pExtensionOpenedID = "roomnfo_ext_close"
  tScrollerID = #name_scroller
  createObject(tScrollerID, "Infostand Text Scroller Class")
  pScroller = getObject(tScrollerID)
  tWriterId = #infostand_name_writer
  tBold = getStructVariable("struct.font.bold")
  tBold.setaProp(#color, rgb("#EEEEEE"))
  createWriter(tWriterId, tBold)
  pWriterBold = getWriter(tWriterId)
  tWriterId = #infostand_desc_writer
  tPlain = getStructVariable("struct.font.plain")
  tPlain.setaProp(#color, rgb("#EEEEEE"))
  createWriter(tWriterId, tPlain)
  pWriterPlain = getWriter(tWriterId)
  return(1)
  exit
end

on deconstruct(me)
  removeObject(pScroller.getID())
  return(1)
  exit
end

on initWindow(me, tID, ttype)
  if not windowExists(tID) then
    tBaseWindowType = "obj_disp_base.window"
    createWindow(tID, tBaseWindowType, 9999, 9999)
    tWndObj = getWindow(tID)
  else
    tWndObj = getWindow(tID)
  end if
  tWndObj.lock()
  mergeWindow(tID, ttype)
  return(tWndObj)
  exit
end

on createFurnitureWindow(me, tID, tProps)
  tWndObj = me.initWindow(tID, "obj_disp_furni.window")
  tNameImage = pWriterBold.render(tProps.getAt(#name)).duplicate()
  tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
  tWndObj.getElement("room_obj_disp_desc").setText(tProps.getAt(#custom))
  pScroller.registerElement(tID, "room_obj_disp_name")
  pScroller.setScroll(1)
  tImage = tProps.getaProp(#image)
  if voidp(tImage) then
    tImage = member(getmemnum(tProps.getAt(#smallmember))).image
  end if
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return(1)
  exit
end

on createMottoWindow(me, tID, tProps, tSelectedObj, tBadgeObjID, tShowTags)
  tWndObj = me.initWindow(tID, "obj_disp_motto.window")
  if tWndObj.elementExists("room_obj_disp_name") then
    tNameImage = pWriterBold.render(tProps.getAt(#name)).duplicate()
    tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
    pScroller.registerElement(tID, "room_obj_disp_name")
    pScroller.setScroll(1)
  end if
  if tWndObj.elementExists("room_obj_disp_desc") then
    tDescElem = tWndObj.getElement("room_obj_disp_desc")
    tWidth = tDescElem.getProperty(#width)
    tOrigHeight = tDescElem.getProperty(#height)
    pWriterPlain.setProperty(#wordWrap, 1)
    pWriterPlain.setProperty(#rect, rect(0, 0, tWidth, 0))
    tDescImage = pWriterPlain.render(tProps.getAt(#custom)).duplicate()
    tWndObj.getElement("room_obj_disp_desc").feedImage(tDescImage)
    tDescHeight = tDescImage.height
    if tProps.getAt(#custom) = "" then
      tDescHeight = 0
    end if
    tWndObj.resizeBy(0, tDescHeight - tOrigHeight)
  end if
  tWndObj.lock()
  return(1)
  exit
end

on createHumanWindow(me, tID, tProps, tSelectedObj, tBadgeObjID, tShowTags)
  tWndObj = me.initWindow(tID, "obj_disp_avatar.window")
  if not tWndObj.elementExists("room_obj_disp_avatar") then
    return(error(me, "Avatar element missing.", #createHumanWindow, #major))
  end if
  tAvatarElem = tWndObj.getElement("room_obj_disp_avatar")
  tAvatarElem.feedImage(tProps.getAt(#image))
  if tSelectedObj <> getObject(#session).GET("user_index") then
    tAvatarElem.setProperty(#cursor, #arrow)
  end if
  tBadges = tProps.getAt(#badges)
  if tBadges.ilk <> #propList then
    tBadges = []
  end if
  tMaxBadgeIndex = 0
  i = 1
  repeat while i <= tBadges.count
    tIndex = tBadges.getPropAt(i)
    if tIndex > tMaxBadgeIndex then
      tMaxBadgeIndex = tIndex
    end if
    i = 1 + i
  end repeat
  if tMaxBadgeIndex < 4 then
    tOffsetV = tAvatarElem.getProperty(#height) - tWndObj.getProperty(#height)
    tWndObj.resizeBy(0, tOffsetV)
  end if
  tBadgeObj = getObject(tBadgeObjID)
  tBadgeObj.updateInfoStandBadge(tID, tSelectedObj, tBadges)
  tWndObj.lock()
  return(1)
  exit
end

on createBotWindow(me, tID, tProps)
  tWndObj = me.initWindow(tID, "obj_disp_bot.window")
  tNameImage = pWriterBold.render(tProps.getAt(#name)).duplicate()
  tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
  tWndObj.getElement("room_obj_disp_desc").setText(tProps.getAt(#custom))
  pScroller.registerElement(tID, "room_obj_disp_name")
  pScroller.setScroll(1)
  tWndObj.lock()
  return(1)
  exit
end

on createPetWindow(me, tID, tProps)
  tWndObj = me.initWindow(tID, "obj_disp_pet.window")
  tNameImage = pWriterBold.render(tProps.getAt(#name)).duplicate()
  tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
  tWndObj.getElement("room_obj_disp_desc").setText(tProps.getAt(#custom))
  pScroller.registerElement(tID, "room_obj_disp_name")
  pScroller.setScroll(1)
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tProps.getAt(#image))
  tWndObj.lock()
  return(1)
  exit
end

on createActionsHumanWindow(me, tID, tTargetUserName, tShowButtons)
  tSessionObj = getObject(#session)
  tUserRights = tSessionObj.GET("user_rights")
  if tTargetUserName = tSessionObj.GET("user_name") then
    tOwnUser = getThread("room").getComponent().getOwnUser()
    tWindowModel = "obj_disp_actions_own.window"
    tButtonList = []
    tButtonList.setAt("wave", #visible)
    tButtonList.setAt("dance", #hidden)
    tButtonList.setAt("hcdance", #hidden)
    tButtonList.setAt("badges", #visible)
    tButtonList.setAt("outlook", #visible)
    tMainAction = tOwnUser.getProperty(#mainAction)
    tSwimming = tOwnUser.getProperty(#swimming)
    tSitting = tMainAction = "sit"
    tLaying = tMainAction = "lay"
    tDanceButtonState = #visible
    if tLaying or tSwimming then
      tDanceButtonState = #deactive
      tButtonList.setAt("wave", #deactive)
    end if
    if tSitting then
      tDanceButtonState = #deactive
    end if
    if tUserRights.getOne("fuse_use_club_dance") then
      tButtonList.setAt("hcdance", tDanceButtonState)
    else
      tButtonList.setAt("dance", tDanceButtonState)
    end if
  else
    tButtonList = []
    tButtonList.setAt("friend", #visible)
    tButtonList.setAt("trade", #visible)
    tButtonList.setAt("ignore", #visible)
    tButtonList.setAt("unignore", #visible)
    tButtonList.setAt("kick", #visible)
    tButtonList.setAt("ban", #visible)
    tButtonList.setAt("give_rights", #visible)
    tButtonList.setAt("take_rights", #visible)
    tWindowModel = "obj_disp_actions_peer.window"
    tRoomOwner = tSessionObj.GET("room_owner")
    tAnyRoomController = tUserRights.getOne("fuse_any_room_controller")
    tRoomController = tSessionObj.GET("room_controller")
    if threadExists(#friend_list) then
      tComponent = getThread(#friend_list).getComponent()
      tFriendData = tComponent.getFriendByName(tTargetUserName)
      if ilk(tFriendData) = #propList then
        tButtonList.setAt("friend", #deactive)
      end if
    else
      tButtonList.setAt("friend", #deactive)
    end if
    tRoomComponent = getThread(#room).getComponent()
    tNotPrivateRoom = tRoomComponent.getRoomID() <> "private"
    tNoTrading = tRoomComponent.getRoomData().getAt(#trading) = 0
    tTradeTimeout = 0
    tTradeProhibited = not tUserRights.getOne("fuse_trade")
    if tTradeTimeout or tNotPrivateRoom or tNoTrading or tTradeProhibited then
      tButtonList.setAt("trade", #deactive)
    end if
    tRoomInterface = getThread(#room).getInterface()
    tSelectedObj = tRoomInterface.getSelectedObject()
    tUserInfo = tRoomComponent.getUserObject(tSelectedObj).getInfo()
    tBadge = tUserInfo.getaProp(#badge)
    tIgnoreListObj = getThread(#room).getInterface().getIgnoreListObject()
    if tIgnoreListObj.getIgnoreStatus(tUserInfo.name) then
      tButtonList.setAt("ignore", #hidden)
    else
      tButtonList.setAt("unignore", #hidden)
    end if
    if pModBadgeList.getOne(tBadge) > 0 then
      tButtonList.setAt("ignore", #hidden)
      tButtonList.setAt("unignore", #hidden)
    end if
    if not tRoomOwner and not tAnyRoomController and not tRoomController then
      tButtonList.setAt("kick", #hidden)
    end if
    if not tRoomOwner and not tAnyRoomController then
      tButtonList.setAt("ban", #hidden)
    end if
    tRoomData = tRoomComponent.getRoomData()
    if tRoomData.getaProp(#type) = #public then
      tButtonList.setAt("kick", #hidden)
      tButtonList.setAt("ban", #hidden)
    end if
    if tRoomOwner then
      if tUserInfo.ctrl = 0 then
        tButtonList.setAt("take_rights", #hidden)
      else
        if tUserInfo.ctrl = "furniture" then
          tButtonList.setAt("give_rights", #hidden)
        else
          if tUserInfo.ctrl = "useradmin" then
            tButtonList.setAt("give_rights", #hidden)
          end if
        end if
      end if
    else
      tButtonList.setAt("give_rights", #hidden)
      tButtonList.setAt("take_rights", #hidden)
    end if
  end if
  tWndObj = me.initWindow(tID, tWindowModel)
  me.scaleButtonWindow(tID, tButtonList, tShowButtons)
  if tTargetUserName = tSessionObj.GET("user_name") then
    if tWndObj.elementExists("hcdance.button") then
      tElem = tWndObj.getElement("hcdance.button")
      tDance = tOwnUser.getProperty(#dancing)
      tElem.setSelection(tDance + 2, 1)
    end if
  end if
  tWndObj.lock()
  return(tID)
  exit
end

on createActionsFurniWindow(me, tID, tClass, tShowButtons)
  tButtonList = []
  tButtonList.setAt("move", #hidden)
  tButtonList.setAt("rotate", #hidden)
  tButtonList.setAt("pick", #hidden)
  tButtonList.setAt("delete", #hidden)
  tSessionObj = getObject(#session)
  tRoomController = tSessionObj.GET("room_controller")
  if tRoomController then
    tButtonList.setAt("move", #visible)
    tButtonList.setAt("rotate", #visible)
  end if
  tRoomOwner = tSessionObj.GET("room_owner")
  if tRoomOwner then
    tButtonList.setAt("move", #visible)
    tButtonList.setAt("rotate", #visible)
    tButtonList.setAt("pick", #visible)
  end if
  tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
  if tAnyRoomController then
    tButtonList.setAt("move", #visible)
    tButtonList.setAt("rotate", #visible)
    tButtonList.setAt("pick", #visible)
  end if
  if tClass = "item" then
    tButtonList.setAt("move", #hidden)
    tButtonList.setAt("rotate", #hidden)
  end if
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObjID = tRoomInterface.getSelectedObject()
  tRoomComponent = tRoomInterface.getComponent()
  if tRoomComponent.itemObjectExists(tSelectedObjID) then
    tSelectedObj = tRoomComponent.getItemObject(tSelectedObjID)
    tClass = tSelectedObj.getClass()
    if tClass contains "post.it" then
      tButtonList.setAt("pick", #hidden)
    end if
  end if
  tWndObj = me.initWindow(tID, "obj_disp_actions_furni.window")
  if not tRoomController and not tRoomOwner and not tAnyRoomController then
    if tWndObj.elementExists("object_displayer_toggle_actions_icon") then
      tWndObj.getElement("object_displayer_toggle_actions_icon").hide()
    end if
    if tWndObj.elementExists("object_displayer_toggle_actions") then
      tWndObj.getElement("object_displayer_toggle_actions").hide()
    end if
  end if
  me.scaleButtonWindow(tID, tButtonList, tShowButtons)
  tWndObj.lock()
  return(tID)
  exit
end

on showHideTags(me, tID, tShowTags)
  tWndObj = getWindow(tID)
  if not tWndObj.elementExists("object_displayer_toggle_tags_icon") then
    return(0)
  end if
  if not tWndObj.elementExists("object_displayer_toggle_tags") then
    return(0)
  end if
  tArrowElem = tWndObj.getElement("object_displayer_toggle_tags_icon")
  tTextElem = tWndObj.getElement("object_displayer_toggle_tags")
  if voidp(tShowTags) then
    tArrowElem.hide()
    tTextElem.hide()
  else
    if tShowTags then
      tArrowElem.setProperty(#member, pExtensionOpenedID)
      tTextElem.setText(getText("object_displayer_hide_tags"))
    else
      tArrowElem.setProperty(#member, pExtensionClosedID)
      tTextElem.setText(getText("object_displayer_show_tags"))
    end if
  end if
  exit
end

on scaleButtonWindow(me, tID, tButtonList, tShowButtons)
  tWndObj = getWindow(tID)
  if tShowButtons = 0 then
    tIndex = 1
    repeat while tIndex <= tButtonList.count
      tButtonID = tButtonList.getPropAt(tIndex)
      tButtonList.setAt(tButtonID, #hidden)
      tIndex = 1 + tIndex
    end repeat
    tArrowElem = tWndObj.getElement("object_displayer_toggle_actions_icon")
    tArrowElem.setProperty(#member, pExtensionClosedID)
    tTextElem = tWndObj.getElement("object_displayer_toggle_actions")
    tOpenText = getText("object_displayer_show_actions")
    tTextElem.setText(tOpenText)
  end if
  tCurrentButtonTopPos = 0
  tOffsetV = 0
  tButtonVertMargins = 3
  tButtonHeight = 15
  tLine = 1
  tWindowWidth = tWndObj.getProperty(#width)
  tMaxWidth = rect.width
  tIndex = 1
  repeat while tIndex <= tButtonList.count
    tButtonID = tButtonList.getPropAt(tIndex)
    tButtonVisibility = tButtonList.getAt(tButtonID)
    tElement = tWndObj.getElement(tButtonID & ".button")
    tLeftPos = tElement.getProperty(#locX)
    if tIndex = 1 then
      tCurrentButtonTopPos = tElement.getProperty(#locY)
    end if
    tElemWidth = tElement.getProperty(#width)
    if tButtonVisibility <> #hidden then
      if tOffsetV + tElemWidth <= tMaxWidth then
        tLeftPos = tLeftPos + tOffsetV
        tOffsetV = tOffsetV + tElemWidth + tButtonVertMargins
      else
        if tButtonVisibility <> #hidden and tIndex > 1 then
          tCurrentButtonTopPos = tCurrentButtonTopPos + tButtonHeight + tButtonVertMargins
          tLine = tLine + 1
        end if
        tOffsetV = tElemWidth + tButtonVertMargins
      end if
    end if
    if me = #visible then
      tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
    else
      if me = #deactive then
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tElement.deactivate()
      else
        if me = #hidden then
          tElement.setProperty(#visible, 0)
        end if
      end if
    end if
    tIndex = 1 + tIndex
  end repeat
  tStackHeight = tLine * tButtonHeight + tButtonVertMargins + 2 * tButtonVertMargins
  me.resizeWindowTo(tID, tOffsetV, tStackHeight)
  exit
end

on createLinksWindow(me, tID, tFormat)
  if me = #own then
    tWindowModel = "obj_disp_links_own.window"
  else
    if me = #peer then
      tWindowModel = "obj_disp_links_peer.window"
    end if
  end if
  tWndObj = me.initWindow(tID, tWindowModel)
  if tFormat = #own then
    tBadgeList = getObject(#session).GET("available_badges")
    if listp(tBadgeList) then
      if tBadgeList.count = 0 then
        tElem = tWndObj.getElement("room_obj_disp_badge_sel")
        tElem.setProperty(#blend, 20)
        tElem.setProperty(#cursor, 0)
        tElem = tWndObj.getElement("room_obj_disp_icon_badge")
        tElem.setProperty(#blend, 20)
        tElem.setProperty(#cursor, 0)
      end if
    end if
  end if
  tWndObj.lock()
  return(tID)
  exit
end

on createUserTagsWindow(me, tID)
  tWindowModel = "obj_disp_user_tags.window"
  tWndObj = me.initWindow(tID, tWindowModel)
  tWndObj.lock()
  return(tID)
  exit
end

on createUserXpWindow(me, tID, tXP)
  tWindowModel = "obj_disp_xp.window"
  tWndObj = me.initWindow(tID, tWindowModel)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.lock()
  tElem = tWndObj.getElement("room_obj_disp_xp")
  if tElem = 0 then
    return(0)
  end if
  tElem.setText(replaceChunks(getText("object_displayer_xp"), "\\xp", tXP))
  return(tID)
  exit
end

on createBottomWindow(me, tID)
  tWndObj = me.initWindow(tID, "obj_disp_bottom.window")
  tWndObj.lock()
  return(tID)
  exit
end

on resizeWindowBy(me, tID, tX, tY)
  tWndObj = getWindow(tID)
  tWndObj.resizeBy(tX, tY)
  exit
end

on resizeWindowTo(me, tID, tX, tY)
  tWndObj = getWindow(tID)
  tWndObj.resizeTo(tX, tY)
  exit
end

on clearWindow(me, tWindowID)
  if not windowExists(tWindowID) then
    return(0)
  end if
  tWndObj = getWindow(tWindowID)
  tWndObj.hide()
  tWndObj.unmerge()
  pScroller.setScroll(0)
  return(1)
  exit
end