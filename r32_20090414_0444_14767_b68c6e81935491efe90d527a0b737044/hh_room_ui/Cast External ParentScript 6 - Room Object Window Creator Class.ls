property pModBadgeList, pExtensionClosedID, pExtensionOpenedID, pWriterBold, pWriterPlain, pScroller

on construct me
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
  return 1
end

on deconstruct me
  removeObject(pScroller.getID())
  return 1
end

on initWindow me, tID, ttype
  if not windowExists(tID) then
    tBaseWindowType = "obj_disp_base.window"
    createWindow(tID, tBaseWindowType, 9999, 9999)
    tWndObj = getWindow(tID)
  else
    tWndObj = getWindow(tID)
  end if
  getWindowManager().lock()
  tWndObj.lock()
  mergeWindow(tID, ttype)
  getWindowManager().unlock()
  return tWndObj
end

on createFurnitureWindow me, tID, tProps
  tSessionObj = getObject(#session)
  tRoomController = tSessionObj.GET("room_controller")
  tRoomOwner = tSessionObj.GET("room_owner")
  tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
  tExpireTime = tProps[#expire]
  if tExpireTime = VOID then
    tExpireTime = -1
  end if
  if (tExpireTime > -1) and (tRoomController or tRoomOwner or (tAnyRoomController > 0)) then
    tExpireTimeLeft = (tExpireTime - the milliSeconds) / 1000.0 / 60
    tExpireTimeLeft = max([0, tExpireTimeLeft])
    tWndObj = me.initWindow(tID, "obj_disp_furni_expire.window")
    if tWndObj <> 0 then
      if tExpireTimeLeft > 60 then
        tExpireTxt = getText("object_displayer_furni_expires_long")
      else
        tExpireTxt = getText("object_displayer_furni_expires")
      end if
      tHours = tExpireTimeLeft / 60
      tMinutes = tExpireTimeLeft mod 60
      tExpireTxt = replaceChunks(tExpireTxt, "%minutes%", tMinutes)
      tExpireTxt = replaceChunks(tExpireTxt, "%hours%", tHours)
      if tWndObj.elementExists("room_obj_disp_expiration") then
        tWndObj.getElement("room_obj_disp_expiration").setText(tExpireTxt)
      end if
    end if
  else
    tWndObj = me.initWindow(tID, "obj_disp_furni.window")
  end if
  tNameImage = pWriterBold.render(tProps[#name]).duplicate()
  tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
  tWndObj.getElement("room_obj_disp_desc").setText(tProps[#custom])
  pScroller.registerElement(tID, "room_obj_disp_name")
  pScroller.setScroll(1)
  tImage = tProps.getaProp(#image)
  if voidp(tImage) then
    tImage = member(getmemnum(tProps[#smallmember])).image
  end if
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return 1
end

on createMottoWindow me, tID, tProps, tSelectedObj, tBadgeObjID, tShowTags
  tWndObj = me.initWindow(tID, "obj_disp_motto.window")
  if tWndObj.elementExists("room_obj_disp_name") then
    tNameImage = pWriterBold.render(tProps[#name]).duplicate()
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
    if tProps.getaProp(#custom) = VOID then
      tCustom = EMPTY
    else
      tCustom = tProps.getaProp(#custom)
    end if
    tDescImage = pWriterPlain.render(tCustom).duplicate()
    tWndObj.getElement("room_obj_disp_desc").feedImage(tDescImage)
    tDescHeight = tDescImage.height
    if tCustom = EMPTY then
      tDescHeight = 0
    end if
    tWndObj.resizeBy(0, tDescHeight - tOrigHeight)
  end if
  tWndObj.lock()
  return 1
end

on createHumanWindow me, tID, tProps, tSelectedObj, tBadgeObjID, tShowTags
  tWndObj = me.initWindow(tID, "obj_disp_avatar.window")
  if not tWndObj.elementExists("room_obj_disp_avatar") then
    return error(me, "Avatar element missing.", #createHumanWindow, #major)
  end if
  tAvatarElem = tWndObj.getElement("room_obj_disp_avatar")
  tAvatarElem.feedImage(tProps[#image])
  if tSelectedObj <> getObject(#session).GET("user_index") then
    tAvatarElem.setProperty(#cursor, #arrow)
  end if
  tBadges = tProps[#badges]
  if tBadges.ilk <> #propList then
    tBadges = [:]
  end if
  tMaxBadgeIndex = 0
  repeat with i = 1 to tBadges.count
    tIndex = tBadges.getPropAt(i)
    if tIndex > tMaxBadgeIndex then
      tMaxBadgeIndex = tIndex
    end if
  end repeat
  if tMaxBadgeIndex < 4 then
    tOffsetV = tAvatarElem.getProperty(#height) - tWndObj.getProperty(#height)
    tWndObj.resizeBy(0, tOffsetV)
  end if
  tBadgeObj = getObject(tBadgeObjID)
  if tBadgeObj <> 0 then
    tBadgeObj.updateInfoStandBadge(tID, tSelectedObj, tBadges)
  end if
  tWndObj.lock()
  return 1
end

on createBotWindow me, tID, tProps
  tWndObj = me.initWindow(tID, "obj_disp_bot.window")
  tNameImage = pWriterBold.render(tProps[#name]).duplicate()
  tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
  tWndObj.getElement("room_obj_disp_desc").setText(tProps[#custom])
  pScroller.registerElement(tID, "room_obj_disp_name")
  pScroller.setScroll(1)
  tWndObj.lock()
  return 1
end

on createPetWindow me, tID, tProps
  tWndObj = me.initWindow(tID, "obj_disp_pet.window")
  tNameImage = pWriterBold.render(tProps[#name]).duplicate()
  tWndObj.getElement("room_obj_disp_name").feedImage(tNameImage)
  tWndObj.getElement("room_obj_disp_desc").setText(tProps[#custom])
  pScroller.registerElement(tID, "room_obj_disp_name")
  pScroller.setScroll(1)
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tProps[#image])
  tWndObj.lock()
  return 1
end

on createActionsHumanWindow me, tID, tTargetUserName, tShowButtons
  tSessionObj = getObject(#session)
  tUserRights = tSessionObj.GET("user_rights")
  if tTargetUserName = tSessionObj.GET("user_name") then
    tOwnUser = getThread("room").getComponent().getOwnUser()
    if tOwnUser = 0 then
      return 0
    end if
    tWindowModel = "obj_disp_actions_own.window"
    tButtonList = [:]
    tButtonList["fx"] = #visible
    tButtonList["wave"] = #visible
    tButtonList["dance"] = #hidden
    tButtonList["hcdance"] = #hidden
    tButtonList["badges"] = #visible
    tButtonList["outlook"] = #visible
    tMainAction = tOwnUser.getProperty(#mainAction)
    tSwimming = tOwnUser.getProperty(#swimming)
    tSitting = tMainAction = "sit"
    tLaying = tMainAction = "lay"
    tDancing = tOwnUser.getProperty(#dancing)
    tFxOn = tOwnUser.getProperty(#FX)
    tFxFeatureOn = getObject(#session).exists(#fx_on)
    if tOwnUser.isInSwimsuit() or not tFxFeatureOn then
      tButtonList["fx"] = #hidden
    end if
    if tDancing then
      tButtonList["fx"] = #deactive
      if not tFxFeatureOn then
        tButtonList["fx"] = #hidden
      end if
    end if
    tDanceButtonState = #visible
    if tLaying or tSwimming or tFxOn then
      tDanceButtonState = #deactive
      tButtonList["wave"] = #deactive
    end if
    if tSitting then
      tDanceButtonState = #deactive
    end if
    if tUserRights.getOne("fuse_use_club_dance") then
      tButtonList["hcdance"] = tDanceButtonState
    else
      tButtonList["dance"] = tDanceButtonState
    end if
  else
    tButtonList = [:]
    tButtonList["friend"] = #visible
    tButtonList["respect"] = #visible
    tButtonList["trade"] = #visible
    tButtonList["ignore"] = #visible
    tButtonList["unignore"] = #visible
    tButtonList["kick"] = #visible
    tButtonList["ban"] = #visible
    tButtonList["give_rights"] = #visible
    tButtonList["take_rights"] = #visible
    tWindowModel = "obj_disp_actions_peer.window"
    tRoomOwner = tSessionObj.GET("room_owner")
    tAnyRoomController = tUserRights.getOne("fuse_any_room_controller")
    tRoomController = tSessionObj.GET("room_controller")
    if threadExists(#friend_list) then
      tComponent = getThread(#friend_list).getComponent()
      tFriendData = tComponent.getFriendByName(tTargetUserName)
      if ilk(tFriendData) = #propList then
        tButtonList["friend"] = #deactive
      end if
    else
      tButtonList["friend"] = #deactive
    end if
    tRespectCount = me.getRespectCount()
    if tRespectCount = 0 then
      tButtonList["respect"] = #hidden
    end if
    tRoomComponent = getThread(#room).getComponent()
    tNotPrivateRoom = tRoomComponent.getRoomID() <> "private"
    tNoTrading = tRoomComponent.getRoomData()[#trading] = 0
    tTradeTimeout = 0
    tTradeProhibited = not tUserRights.getOne("fuse_trade")
    if tTradeTimeout or tNotPrivateRoom or tNoTrading or tTradeProhibited then
      tButtonList["trade"] = #deactive
    end if
    tRoomInterface = getThread(#room).getInterface()
    tSelectedObj = tRoomInterface.getSelectedObject()
    tUserInfo = tRoomComponent.getUserObject(tSelectedObj).getInfo()
    tBadge = tUserInfo.getaProp(#badge)
    tIgnoreListObj = getThread(#room).getInterface().getIgnoreListObject()
    if tIgnoreListObj.getIgnoreStatus(tUserInfo.name) then
      tButtonList["ignore"] = #hidden
    else
      tButtonList["unignore"] = #hidden
    end if
    if pModBadgeList.getOne(tBadge) > 0 then
      tButtonList["ignore"] = #hidden
      tButtonList["unignore"] = #hidden
    end if
    if not tRoomOwner and not tAnyRoomController and not tRoomController then
      tButtonList["kick"] = #hidden
    end if
    if not tRoomOwner and not tAnyRoomController then
      tButtonList["ban"] = #hidden
    end if
    tRoomData = tRoomComponent.getRoomData()
    if tRoomData.getaProp(#type) = #public then
      tButtonList["kick"] = #hidden
      tButtonList["ban"] = #hidden
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
  tWndObj = me.initWindow(tID, tWindowModel)
  if tWndObj.elementExists("respect.button") then
    if tRespectCount > 0 then
      tElem = tWndObj.getElement("respect.button")
      tElem.setText(replaceChunks(getText("room_give_respect"), "%count%", tRespectCount))
    end if
  end if
  me.scaleButtonWindow(tID, tButtonList, tShowButtons)
  if tTargetUserName = tSessionObj.GET("user_name") then
    if tWndObj.elementExists("hcdance.button") then
      tElem = tWndObj.getElement("hcdance.button")
      tDance = tOwnUser.getProperty(#dancing)
      tElem.setSelection(tDance + 2, 1)
    end if
    if tWndObj.elementExists("fx.button") then
      me.updateFXDropDown(tWndObj)
    end if
  end if
  tWndObj.lock()
  return tID
end

on createActionsFurniWindow me, tID, tClass, tShowButtons
  tButtonList = [:]
  tButtonList["move"] = #hidden
  tButtonList["rotate"] = #hidden
  tButtonList["pick"] = #hidden
  tButtonList["delete"] = #hidden
  tSessionObj = getObject(#session)
  tRoomController = tSessionObj.GET("room_controller")
  if tRoomController then
    tButtonList["move"] = #visible
    tButtonList["rotate"] = #visible
  end if
  tRoomOwner = tSessionObj.GET("room_owner")
  if tRoomOwner then
    tButtonList["move"] = #visible
    tButtonList["rotate"] = #visible
    tButtonList["pick"] = #visible
  end if
  tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
  if tAnyRoomController then
    tButtonList["move"] = #visible
    tButtonList["rotate"] = #visible
    tButtonList["pick"] = #visible
  end if
  if tClass = "item" then
    tButtonList["move"] = #hidden
    tButtonList["rotate"] = #hidden
  end if
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObjID = tRoomInterface.getSelectedObject()
  tRoomComponent = tRoomInterface.getComponent()
  if tRoomComponent.itemObjectExists(tSelectedObjID) then
    tSelectedObj = tRoomComponent.getItemObject(tSelectedObjID)
    tClass = tSelectedObj.getClass()
    if tClass contains "post.it" then
      tButtonList["pick"] = #hidden
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
  return tID
end

on showHideTags me, tID, tShowTags
  tWndObj = getWindow(tID)
  if not tWndObj.elementExists("object_displayer_toggle_tags_icon") then
    return 0
  end if
  if not tWndObj.elementExists("object_displayer_toggle_tags") then
    return 0
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
end

on scaleButtonWindow me, tID, tButtonList, tShowButtons
  tWndObj = getWindow(tID)
  if tShowButtons = 0 then
    repeat with tIndex = 1 to tButtonList.count
      tButtonID = tButtonList.getPropAt(tIndex)
      tButtonList[tButtonID] = #hidden
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
  tMaxWidth = 0
  tWindowWidth = tWndObj.getProperty(#width)
  tStageWidth = (the stage).rect.width
  repeat with tIndex = 1 to tButtonList.count
    tButtonID = tButtonList.getPropAt(tIndex)
    tButtonVisibility = tButtonList[tButtonID]
    tElement = tWndObj.getElement(tButtonID & ".button")
    if tIndex = 1 then
      tLeftPos = tElement.getProperty(#locX)
      tFirstLeftPos = tLeftPos
      tCurrentButtonTopPos = tElement.getProperty(#locY)
    end if
    tElemWidth = tElement.getProperty(#width)
    if tButtonVisibility <> #hidden then
      if (tOffsetV + tElemWidth) <= tStageWidth then
        tOffsetV = tOffsetV + tElemWidth + tButtonVertMargins
      else
        if tIndex > 1 then
          tCurrentButtonTopPos = tCurrentButtonTopPos + tButtonHeight + tButtonVertMargins
          tLine = tLine + 1
          tOffsetV = tElemWidth + tButtonVertMargins
          tLeftPos = tFirstLeftPos
        else
          tOffsetV = tOffsetV + tElemWidth + tButtonVertMargins
        end if
      end if
      if tMaxWidth < tOffsetV then
        tMaxWidth = tOffsetV
      end if
    end if
    case tButtonVisibility of
      #visible:
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tLeftPos = tLeftPos + tElemWidth + tButtonVertMargins
      #deactive:
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tLeftPos = tLeftPos + tElemWidth + tButtonVertMargins
        tElement.deactivate()
      #hidden:
        tElement.setProperty(#visible, 0)
    end case
  end repeat
  tStackHeight = (tLine * (tButtonHeight + tButtonVertMargins)) + (2 * tButtonVertMargins)
  me.resizeWindowTo(tID, tMaxWidth, tStackHeight)
end

on createLinksWindow me, tID, tFormat
  case tFormat of
    #own:
      tWindowModel = "obj_disp_links_own.window"
    #peer:
      tWindowModel = "obj_disp_links_peer.window"
  end case
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
  return tID
end

on createUserTagsWindow me, tID
  tWindowModel = "obj_disp_user_tags.window"
  tWndObj = me.initWindow(tID, tWindowModel)
  tWndObj.lock()
  return tID
end

on createUserXpWindow me, tID, tXP
  tWindowModel = "obj_disp_xp.window"
  tWndObj = me.initWindow(tID, tWindowModel)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.lock()
  tElem = tWndObj.getElement("room_obj_disp_xp")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(replaceChunks(getText("object_displayer_xp"), "\xp", tXP))
  return tID
end

on createUserFxWindow me, tID, tFx
  tWindowModel = "obj_disp_fx.window"
  tWndObj = me.initWindow(tID, tWindowModel)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.lock()
  tElem = tWndObj.getElement("room_obj_disp_fx")
  if tElem = 0 then
    return 0
  end if
  tFXId = tFx.getPropAt(1)
  tFXTime = tFx[1]
  if not integerp(tFXTime) then
    return 0
  end if
  tSec = tFXTime mod 60
  tMin = (tFXTime - tSec) / 60
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  if tMin < 10 then
    tMin = "0" & tMin
  end if
  tText = replaceChunks(getText("object_displayer_fx"), "%fx", getText("fx_" & tFXId))
  tText = replaceChunks(tText, "%t", tMin & ":" & tSec)
  tElem.setText(tText)
  return tID
end

on createBottomWindow me, tID
  tWndObj = me.initWindow(tID, "obj_disp_bottom.window")
  tWndObj.lock()
  return tID
end

on resizeWindowBy me, tID, tX, tY
  tWndObj = getWindow(tID)
  tWndObj.resizeBy(tX, tY)
end

on resizeWindowTo me, tID, tX, tY
  tWndObj = getWindow(tID)
  tWndObj.resizeTo(tX, tY)
end

on clearWindow me, tWindowID
  if not windowExists(tWindowID) then
    return 0
  end if
  tWndObj = getWindow(tWindowID)
  tWndObj.hide()
  tWndObj.unmerge()
  if objectp(pScroller) then
    pScroller.setScroll(0)
  end if
  return 1
end

on getRespectCount me
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  if not tSession.exists(#user_respect_ticket_count) then
    return -1
  end if
  return tSession.GET(#user_respect_ticket_count)
end

on updateFXDropDown me, tWndObj
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("fx.button")
  if ilk(tElem) <> #instance then
    return error(me, "Unable to retrieve dropdown:" && tElem, #updateFXDropDown, #major)
  end if
  tAvailableFX = getObject(#session).GET("active_fx")
  if not listp(tAvailableFX) then
    return tElem.hide()
  end if
  if tAvailableFX.count = 0 then
    tNewKeyList = ["fx_btn_inventory"]
    tNewTextList = [getText("fx_btn_inventory")]
    tNewTextList2 = [EMPTY]
  else
    tOwnUser = getThread("room").getComponent().getOwnUser()
    if tOwnUser = 0 then
      return 0
    end if
    tFx = tOwnUser.getProperty(#FX)
    tAvailableFX = tAvailableFX.duplicate()
    repeat with i = 1 to tAvailableFX.count
      tTimeInt = (tAvailableFX[i] - the milliSeconds) / 1000
      tMin = tTimeInt mod 60
      tHour = (tTimeInt - tMin) / 60
      if tMin < 10 then
        tMin = "0" & tMin
      end if
      if tHour < 10 then
        tHour = "0" & tHour
      end if
      tAvailableFX[i] = tHour & ":" & tMin
    end repeat
    tNewTextList = []
    tNewTextList2 = []
    tNewKeyList = []
    if tFx <> 0 then
      tNewTextList.add(getText("fx_" & tFx))
      tNewTextList2.add(tAvailableFX.getaProp(tFx))
      tNewKeyList.add("fx" & tFx)
    end if
    tNewKeyList.append("fx_btn_inventory")
    tNewTextList.append(getText("fx_btn_inventory"))
    tNewTextList2.append(EMPTY)
    if tFx <> 0 then
      tNewKeyList.append("fx_btn_stop")
      tNewTextList.append(getText("fx_btn_stop"))
      tNewTextList2.append(EMPTY)
    end if
    repeat with i = 1 to tAvailableFX.count
      ttype = tAvailableFX.getPropAt(i)
      if ttype <> tFx then
        tNewTextList.append(getText("fx_" & ttype))
        tNewTextList2.append(tAvailableFX[i])
        tNewKeyList.append("fx" & ttype)
      end if
    end repeat
  end if
  tElem.updateData(tNewTextList, tNewKeyList, VOID, VOID, tNewTextList2)
  return 1
end
