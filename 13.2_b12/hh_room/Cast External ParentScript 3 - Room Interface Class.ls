property pInfoConnID, pRoomConnID, pGeometryId, pHiliterId, pContainerID, pSafeTraderID, pObjMoverID, pArrowObjID, pBadgeObjID, pDoorBellID, pRoomSpaceId, pBottomBarId, pInterfaceId, pDelConfirmID, pPlcConfirmID, pLoaderBarID, pDeleteObjID, pDeleteType, pIgnoreListObj, pModBadgeList, pClickAction, pSelectedObj, pSelectedType, pCoverSpr, pRingingUser, pVisitorQueue, pBannerLink, pLoadingBarID, pQueueCollection, pMessengerFlash, pNewMsgCount, pNewBuddyReq, pFloodblocking, pFloodTimer, pFloodEnterCount, pSwapAnimations, pTradeTimeout, pInfoStandId

on construct me
  pInfoConnID = getVariable("connection.info.id")
  pRoomConnID = getVariable("connection.room.id")
  pObjMoverID = "Room_obj_mover"
  pHiliterId = "Room_hiliter"
  pGeometryId = "Room_geometry"
  pContainerID = "Room_container"
  pSafeTraderID = "Room_safe_trader"
  pArrowObjID = "Room_arrow_hilite"
  pBadgeObjID = "Room_badge"
  pDoorBellID = "Room_doorbell"
  pPreviewObjID = "Preview_renderer"
  pInfoStandId = "Room_info_stand"
  pRoomSpaceId = "Room_visualizer"
  pBottomBarId = "Room_bar"
  pInterfaceId = "Room_interface"
  pDelConfirmID = getText("win_delete_item", "Delete item?")
  pLoaderBarID = "Loading room"
  pPlcConfirmID = getText("win_place", "Place item?")
  pClickAction = #null
  pSelectedObj = EMPTY
  pSelectedType = EMPTY
  pDeleteObjID = EMPTY
  pDeleteType = EMPTY
  pRingingUser = EMPTY
  pVisitorQueue = []
  pBannerLink = 0
  pSwapAnimations = []
  pTradeTimeout = 0
  pLoadingBarID = 0
  pQueueCollection = []
  pModBadgeList = getVariableValue("moderator.badgelist")
  createObject(pGeometryId, "Room Geometry Class")
  createObject(pContainerID, "Container Hand Class")
  createObject(pSafeTraderID, "Safe Trader Class")
  createObject(pArrowObjID, "Select Arrow Class")
  createObject(pObjMoverID, "Object Mover Class")
  createObject(pBadgeObjID, "Badge Manager Class")
  createObject(pPreviewObjID, "Preview Renderer Class")
  createObject(pDoorBellID, "Doorbell Class")
  createObject(pInfoStandId, "Info Stand Class")
  pIgnoreListObj = createObject(#temp, "Ignore List Class")
  getObject(pObjMoverID).setProperty(#geometry, getObject(pGeometryId))
  registerMessage(#notify, me.getID(), #notify)
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  registerMessage(#objectFinalized, me.getID(), #objectFinalized)
  registerMessage(#soundSettingChanged, me.getID(), #updateSoundButton)
  return 1
end

on deconstruct me
  pClickAction = #null
  unregisterMessage(#notify, me.getID())
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#objectFinalized, me.getID())
  unregisterMessage(#soundSettingChanged, me.getID())
  pIgnoreListObj = VOID
  removeObject(pBadgeObjID)
  removeObject(pDoorBellID)
  removeObject(pInfoStandId)
  return me.hideAll()
end

on showRoom me, tRoomID
  if not memberExists(tRoomID & ".room") then
    return error(me, "Room recording data member not found, check recording label name. Tried to find" && tRoomID & ".room", #showRoom)
  end if
  me.showTrashCover()
  if windowExists(pLoaderBarID) then
    activateWindow(pLoaderBarID)
  end if
  tRoomField = tRoomID & ".room"
  createVisualizer(pRoomSpaceId, tRoomField)
  tVisObj = getVisualizer(pRoomSpaceId)
  tLocX = tVisObj.getProperty(#locX)
  tLocY = tVisObj.getProperty(#locY)
  tlocz = tVisObj.getProperty(#locZ)
  tdata = getObject(#layout_parser).parse(tRoomField).roomdata[1]
  tdata[#offsetz] = tlocz
  tdata[#offsetx] = tdata[#offsetx]
  tdata[#offsety] = tdata[#offsety]
  me.getGeometry().define(tdata)
  tSprList = tVisObj.getProperty(#spriteList)
  call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseDown)
  call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseUp)
  tHiliterSpr = tVisObj.getSprById("hiliter")
  if not tHiliterSpr then
    if me.getHiliter() <> 0 then
      me.getHiliter().deconstruct()
    end if
    error(me, "Hiliter not found in room description!!!", #showRoom)
  else
    createObject(pHiliterId, "Room Hiliter Class")
    me.getHiliter().define([#sprite: tHiliterSpr, #geometry: pGeometryId])
    receiveUpdate(pHiliterId)
  end if
  tAnimations = tVisObj.getProperty(#swapAnims)
  if tAnimations <> 0 then
    repeat with tAnimation in tAnimations
      tObj = createObject(#random, getVariableValue("swap.animation.class"))
      if tObj = 0 then
        error(me, "Error creating swap animation", #showRoom)
        next repeat
      end if
      pSwapAnimations.add(tObj)
      pSwapAnimations[pSwapAnimations.count].define(tAnimation)
    end repeat
  end if
  me.getArrowHiliter().Init()
  pClickAction = "moveHuman"
  return 1
end

on hideRoom me
  removeUpdate(pHiliterId)
  removeObject(pHiliterId)
  pClickAction = #null
  pSelectedObj = EMPTY
  me.hideArrowHiliter()
  me.hideTrashCover()
  repeat with tAnim in pSwapAnimations
    tAnim.deconstruct()
  end repeat
  pSwapAnimations = []
  if visualizerExists(pRoomSpaceId) then
    removeVisualizer(pRoomSpaceId)
  end if
  return 1
end

on showRoomBar me
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "empty.window", 0, 452)
  end if
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.lock(1)
  tWndObj.unmerge()
  if me.getComponent().getSpectatorMode() then
    tLayout = "room_bar_spectator.window"
  else
    tLayout = "room_bar.window"
  end if
  if not tWndObj.merge(tLayout) then
    return 0
  end if
  me.updateSoundButton()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  executeMessage(#messageUpdateRequest)
  executeMessage(#buddyUpdateRequest)
  if me.getComponent().getRoomData().type = #private then
    tRoomData = me.getComponent().pSaveData
    tRoomTxt = getText("room_name") && tRoomData[#name] & RETURN & getText("room_owner") && tRoomData[#owner]
    tWndObj.getElement("room_info_text").setText(tRoomTxt)
  else
    tWndObj.getElement("room_info_text").hide()
  end if
  return 1
end

on updateSoundButton me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tstate = getSoundState()
  tElem = tWndObj.getElement("int_sound_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_on_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_off_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
  tElem = tWndObj.getElement("int_sound_bg_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_on_icon_sd")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_off_icon_sd")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
end

on hideRoomBar me
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBarId) then
    removeWindow(pBottomBarId)
  end if
end

on showInterface me, tObjType
  tSession = getObject(#session)
  tUserRights = getObject(#session).GET("user_rights")
  tOwnUser = me.getComponent().getOwnUser()
  if (tOwnUser = 0) and (tObjType <> "user") then
    return error(me, "Own user not found!", #showInterface)
  end if
  if (tObjType = "active") or (tObjType = "item") then
    tSomeRights = 0
    if tOwnUser.getInfo().ctrl <> 0 then
      tSomeRights = 1
    end if
    if tUserRights.getOne("fuse_any_room_controller") then
      tSomeRights = 1
    end if
    if tUserRights.getOne("fuse_pick_up_any_furni") then
      tSomeRights = 1
    end if
    if not tSomeRights then
      return me.hideInterface(#hide)
    end if
  end if
  tCtrlType = EMPTY
  if tSession.GET("room_controller") or tUserRights.getOne("fuse_any_room_controller") then
    tCtrlType = "ctrl"
  end if
  if tSession.GET("room_owner") then
    tCtrlType = "owner"
  end if
  if tObjType = "user" then
    if pSelectedObj = tSession.GET("user_index") then
      tCtrlType = "personal"
    else
      if tCtrlType = EMPTY then
        tCtrlType = "friend"
      end if
    end if
    if tOwnUser = 0 then
      tCtrlType = "spectator"
    end if
  end if
  if variableExists("interface.cmds." & tObjType & "." & tCtrlType) then
    tButtonList = getVariableValue("interface.cmds." & tObjType & "." & tCtrlType)
  else
    return me.hideInterface(#hide)
  end if
  if (tObjType = "active") or (tObjType = "item") then
    if getObject(#session).GET("user_rights").getOne("fuse_pick_up_any_furni") then
      if tButtonList.getPos("pick") = 0 then
        tButtonList.add("pick")
      end if
    end if
  end if
  if tButtonList.count = 0 then
    return me.hideInterface(#hide)
  end if
  if tUserRights.getOne("fuse_use_club_dance") then
    tButtonList.deleteOne("dance")
    if tOwnUser <> 0 then
      if tOwnUser.getProperty(#dancing) = 0 then
        me.dancingStoppedExternally()
      end if
    end if
  else
    tButtonList.deleteOne("hcdance")
  end if
  if tOwnUser <> 0 then
    tMainAction = tOwnUser.getProperty(#mainAction)
    tSwimming = tOwnUser.getProperty(#swimming)
    if (tMainAction = "sit") or (tMainAction = "lay") or tSwimming then
      tButtonList.deleteOne("dance")
      tButtonList.deleteOne("hcdance")
    end if
    if tSwimming then
      tButtonList.deleteOne("wave")
    end if
  end if
  if tObjType = "item" then
    tObjType = "active"
  end if
  if tCtrlType = "personal" then
    tObjType = "personal"
  end if
  if me.getComponent().getRoomData().type = #private then
    if tObjType = "user" then
      if pSelectedObj <> tSession.GET("user_name") then
        tUserInfo = me.getComponent().getUserObject(pSelectedObj).getInfo()
        if tUserInfo.ctrl = 0 then
          tButtonList.deleteOne("take_rights")
        else
          if tUserInfo.ctrl = "furniture" then
            tButtonList.deleteOne("give_rights")
          else
            if tUserInfo.ctrl = "useradmin" then
              tButtonList.deleteOne("give_rights")
            end if
          end if
        end if
        tTargetIsOwner = tUserInfo.name = me.getComponent().getRoomData().owner
        if tTargetIsOwner then
          if not tUserRights.getOne("fuse_kick") then
            tButtonList.deleteOne("kick")
          end if
          if not tUserRights.getOne("fuse_ignore_room_owner") then
            tButtonList.deleteOne("ignore")
          end if
        end if
      end if
    end if
  else
    tButtonList.deleteOne("take_rights")
    tButtonList.deleteOne("give_rights")
    tButtonList.deleteOne("kick")
  end if
  if tObjType = "user" then
    tUserInfo = me.getComponent().getUserObject(pSelectedObj).getInfo()
    tBadge = tUserInfo.getaProp(#badge)
    if pModBadgeList.getOne(tBadge) > 0 then
      tButtonList.deleteOne("ignore")
    end if
    if pIgnoreListObj.getIgnoreStatus(tUserInfo.name) then
      tButtonList.deleteOne("ignore")
    else
      tButtonList.deleteOne("unignore")
    end if
  end if
  if tCtrlType = "personal" then
    if getObject("session").GET("available_badges").ilk <> #list then
      tButtonList.deleteOne("badge")
    else
      if getObject("session").GET("available_badges").count < 1 then
        tButtonList.deleteOne("badge")
      end if
    end if
  end if
  if tObjType = "user" then
    tWebID = me.getComponent().getUserObject(pSelectedObj).getWebID()
    if not variableExists("link.format.userpage") or voidp(tWebID) then
      tButtonList.deleteOne("userpage")
    end if
  end if
  tWndObj = getWindow(pInterfaceId)
  tLayout = "object_interface.window"
  if tWndObj = 0 then
    createWindow(pInterfaceId, tLayout, 545, 466)
    tWndObj = getWindow(pInterfaceId)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInterface, me.getID())
  else
    tWndObj.show()
  end if
  repeat with tSpr in tWndObj.getProperty(#spriteList)
    tSpr.visible = 0
  end repeat
  tRightMargin = 4
  repeat with tAction in tButtonList
    tElem = tWndObj.getElement(tAction & ".button")
    if tElem <> 0 then
      tSpr = tElem.getProperty(#sprite)
      tSpr.visible = 1
      tRightMargin = tRightMargin + tElem.getProperty(#width) + 2
      tSpr.locH = (the stage).rect.width - tRightMargin
    end if
  end repeat
  if (tObjType = "user") and (tCtrlType <> "personal") then
    if me.getComponent().userObjectExists(pSelectedObj) then
      if threadExists(#messenger) then
        tUserName = me.getComponent().getUserObject(pSelectedObj).getName()
        tBuddyData = getThread(#messenger).getComponent().getBuddyData()
        if tBuddyData.online.getPos(tUserName) > 0 then
          tWndObj.getElement("friend.button").deactivate()
          tWndObj.getElement("friend.button").setProperty(#cursor, 0)
        else
          tWndObj.getElement("friend.button").Activate()
          tWndObj.getElement("friend.button").setProperty(#cursor, "cursor.finger")
        end if
      end if
    end if
    if tButtonList.getPos("trade") > 0 then
      tNotPrivateRoom = me.getComponent().getRoomID() <> "private"
      tNoTrading = me.getComponent().getRoomData()[#trading] = 0
      if pTradeTimeout or tNotPrivateRoom or tNoTrading then
        tWndObj.getElement("trade.button").deactivate()
      end if
      if not tUserRights.getOne("fuse_trade") then
        tWndObj.getElement("trade.button").deactivate()
      end if
    end if
  end if
  return 1
end

on startTradeButtonTimeout me
  pTradeTimeout = 1
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if tWndObj.elementExists("trade.button") then
      tWndObj.getElement("trade.button").deactivate()
    end if
  end if
  tTimeout = getVariable("room.request.timeout", 10000)
  createTimeout(#activeTradeButton, tTimeout, #endTradeButtonTimeout, me.getID(), VOID, 1)
end

on endTradeButtonTimeout me
  pTradeTimeout = 0
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if tWndObj.elementExists("trade.button") then
      tWndObj.getElement("trade.button").Activate()
    end if
  end if
end

on hideInterface me, tHideOrRemove
  if voidp(tHideOrRemove) then
    tHideOrRemove = #Remove
  end if
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if tHideOrRemove = #Remove then
      return removeWindow(pInterfaceId)
    else
      return tWndObj.hide()
    end if
  end if
  return 0
end

on showArrowHiliter me, tUserID
  if objectExists(pArrowObjID) then
    return me.getArrowHiliter().show(tUserID)
  end if
end

on hideArrowHiliter me
  return me.getArrowHiliter().hide()
end

on showDoorBellWaiting me
  me.hideLoaderBar()
  createWindow(pLoaderBarID, "habbo_simple.window")
  tWndObj = getWindow(pLoaderBarID)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.merge("room_doorbell_waiting.window")
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
  tRoomData = me.getComponent().getRoomData()
  if tRoomData = 0 then
    return 1
  end if
  tRoomName = tRoomData[#name]
  tElem = tWndObj.getElement("room_doorbell_roomname")
  if tElem = 0 then
    return 1
  end if
  tElem.setText(tRoomName)
  return 1
end

on showDoorBellAccepted me, tName
  if tName = EMPTY then
    nothing()
  else
    if objectExists(pDoorBellID) then
      getObject(pDoorBellID).removeFromList(tName)
    end if
  end if
  return 1
end

on showDoorBellRejected me, tName
  if tName = EMPTY then
    me.hideLoaderBar()
    createWindow(pLoaderBarID, "habbo_simple.window")
    tWndObj = getWindow(pLoaderBarID)
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.merge("room_doorbell_rejected.window")
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
  else
    if objectExists(pDoorBellID) then
      getObject(pDoorBellID).removeFromList(tName)
    end if
  end if
  return 1
end

on showDoorBellDialog me, tName
  tOwnUser = me.getComponent().getOwnUser()
  if tOwnUser = 0 then
    return error(me, "Own user not found!", #showDoorBell)
  end if
  if tOwnUser.getInfo().ctrl = 0 then
    return 1
  end if
  if objectExists(pDoorBellID) then
    return getObject(pDoorBellID).addDoorbellRinger(tName)
  end if
end

on hideDoorBellDialog me
  if objectExists(pDoorBellID) then
    getObject(pDoorBellID).hideDoorBell()
  end if
end

on showLoaderBar me, tCastLoadId, tText
  if not windowExists(pLoaderBarID) then
    createWindow(pLoaderBarID, "habbo_simple.window")
    tWndObj = getWindow(pLoaderBarID)
    tWndObj.merge("room_loader.window")
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
    if not voidp(tCastLoadId) then
      tBuffer = tWndObj.getElement("gen_loaderbar").getProperty(#buffer).image
      pLoadingBarID = showLoadingBar(tCastLoadId, [#buffer: tBuffer, #bgColor: rgb(255, 255, 255)])
    end if
    if stringp(tText) then
      tWndObj.getElement("general_loader_text").setText(tText)
    end if
  end if
  return 1
end

on hideLoaderBar me
  if windowExists(pLoaderBarID) then
    removeWindow(pLoaderBarID)
  end if
  tInterstitialMngr = me.getComponent().getInterstitial()
  if not voidp(tInterstitialMngr) then
    tInterstitialMngr.adClosed()
  end if
  pLoadingBarID = 0
end

on resizeInterstitialWindow me
  if not windowExists(pLoaderBarID) then
    return 0
  end if
  tWndObj = getWindow(pLoaderBarID)
  tInterstitialMngr = me.getComponent().getInterstitial()
  if voidp(tInterstitialMngr) then
    return 0
  end if
  tMemNum = tInterstitialMngr.getInterstitialMemNum()
  if tMemNum < 1 then
    return 0
  end if
  tAdMember = member(tMemNum)
  if tAdMember.type = #bitmap then
    tAdImage = tAdMember.image
  else
    tAdImage = image(1, 1, 8)
  end if
  tAdWidth = tAdImage.rect[3]
  tAdHeight = tAdImage.rect[4]
  tAdMaxW = 620
  if tAdWidth > tAdMaxW then
    tAdWidth = tAdMaxW
  end if
  tAdMaxH = 360
  if tAdHeight > tAdMaxH then
    tAdHeight = tAdMaxH
  end if
  tAdImage = image(tAdWidth, tAdHeight, 32)
  tAdImage.copyPixels(tAdMember.image, rect(0, 0, tAdWidth, tAdHeight), rect(0, 0, tAdWidth, tAdHeight))
  tWndWidth = 240
  tBorderWidth = 25
  tAdLocX = 0
  tAdLocY = tBorderWidth
  tOffX = 0
  tOffY = tAdHeight + 10 + tBorderWidth
  if tAdWidth > (tWndWidth - (tBorderWidth * 2)) then
    tOffX = tAdWidth - tWndWidth + (tBorderWidth * 2)
    tAdLocX = tBorderWidth
  else
    tAdLocX = (tWndWidth - tAdWidth) / 2
  end if
  tWndObj.resizeBy(tOffX, tOffY)
  tWndObj.center()
  tElementList = ["general_loader_text", "queue_text", "second_queue_title", "queue_text_2"]
  repeat with tElemID in tElementList
    tElem = tWndObj.getElement(tElemID)
    if tElem <> 0 then
      tElem.setText(tElem.getText())
    end if
  end repeat
  if not tWndObj.elementExists("room_banner_pic") then
    return 0
  end if
  tPic = tWndObj.getElement("room_banner_pic")
  tPic.moveTo(tAdLocX, tAdLocY)
  tPic.setProperty(#width, tAdWidth)
  tPic.feedImage(tAdImage)
  tPic.setProperty(#cursor, "cursor.finger")
  tAdSprite = tPic.pSprite
  tAdSprite.registerProcedure(#eventProc, tInterstitialMngr.getID(), #mouseUp)
  tAdSprite.registerProcedure(#eventProc, tInterstitialMngr.getID(), #mouseEnter)
  tAdSprite.registerProcedure(#eventProc, tInterstitialMngr.getID(), #mouseLeave)
  tAdSprite.registerProcedure(#eventProc, tInterstitialMngr.getID(), #mouseWithin)
end

on updateQueueWindow me, tQueueCollection
  if not windowExists(pLoaderBarID) then
    return 0
  end if
  tWndObj = getWindow(pLoaderBarID)
  if pLoadingBarID <> 0 then
    if objectExists(pLoadingBarID) then
      removeObject(pLoadingBarID)
    end if
    pLoadingBarID = 0
  end if
  tWndObj.unmerge()
  if tQueueCollection.count() = 1 then
    tWndObj.merge("room_loader.window")
    tSetCount = 1
  else
    tWndObj.merge("room_loader_2.window")
    tSetCount = 2
  end if
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
  if tWndObj.elementExists("gen_loaderbar") then
    tWndObj.getElement("gen_loaderbar").setProperty(#visible, 0)
  end if
  if not tWndObj.elementExists("general_loader_text") then
    return 0
  end if
  tTitleElementList = ["general_loader_text", "second_queue_title"]
  tTextElementList = ["queue_text", "queue_text_2"]
  tTitleTextList = ["queue_current_", "queue_other_"]
  pQueueCollection = tQueueCollection.duplicate()
  repeat with i = 1 to tSetCount
    tQueueSet = pQueueCollection[i]
    tQueueTarget = tQueueSet["target"]
    tQueueData = tQueueSet["data"]
    tQueueSetName = tQueueSet["name"]
    if tWndObj.elementExists(tTitleElementList[i]) then
      tTitleElem = tWndObj.getElement(tTitleElementList[i])
      tTitleElem.setText(getText(tTitleTextList[i] & string(tQueueTarget)))
    end if
    if tWndObj.elementExists(tTextElementList[i]) then
      tQueueTxtElem = tWndObj.getElement(tTextElementList[i])
      tQueueTxt = getText("queue_set." & tQueueSetName & ".info")
      repeat with tCount = 1 to tQueueData.count
        tQueueProp = getPropAt(tQueueData, tCount)
        tQueueValue = tQueueData[tQueueProp]
        tQueueTxt = replaceChunks(tQueueTxt, "%" & tQueueProp & "%", tQueueValue)
      end repeat
      tQueueTxtElem.setText(tQueueTxt)
    end if
  end repeat
  me.resizeInterstitialWindow()
  return 1
end

on showTrashCover me, tlocz, tColor
  if voidp(pCoverSpr) then
    if not integerp(tlocz) then
      tlocz = 0
    end if
    if not ilk(tColor, #color) then
      tColor = rgb(0, 0, 0)
    end if
    pCoverSpr = sprite(reserveSprite(me.getID()))
    if not memberExists("Room Trash Cover") then
      createMember("Room Trash Cover", #bitmap)
    end if
    tmember = member(getmemnum("Room Trash Cover"))
    tmember.image = image(1, 1, 8)
    tmember.image.setPixel(0, 0, tColor)
    pCoverSpr.member = tmember
    pCoverSpr.loc = point(0, 0)
    pCoverSpr.width = (the stage).rect.width
    pCoverSpr.height = (the stage).rect.height
    pCoverSpr.locZ = tlocz
    pCoverSpr.blend = 100
    setEventBroker(pCoverSpr.spriteNum, "Trash Cover")
    updateStage()
  end if
end

on hideTrashCover me
  if not voidp(pCoverSpr) then
    releaseSprite(pCoverSpr.spriteNum)
    pCoverSpr = VOID
  end if
end

on hideAll me
  if objectExists(pObjMoverID) then
    getObject(pObjMoverID).close()
  end if
  if objectExists(pSafeTraderID) then
    getObject(pSafeTraderID).close()
  end if
  if objectExists(pContainerID) then
    getObject(pContainerID).close()
  end if
  if objectExists(pArrowObjID) then
    getObject(pArrowObjID).hide()
  end if
  if objectExists("BadgeEffect") then
    removeObject("BadgeEffect")
  end if
  if objectExists(#photo_interface) then
    getObject(#photo_interface).close()
  end if
  if objectExists(pInfoStandId) then
    getObject(pInfoStandId).hideInfoStand()
  end if
  me.hideRoom()
  me.hideRoomBar()
  me.hideInterface(#Remove)
  me.hideConfirmDelete()
  me.hideConfirmPlace()
  me.hideDoorBellDialog()
  me.hideLoaderBar()
  me.hideTrashCover()
  me.hideLoaderBar()
  return 1
end

on getRoomVisualizer me
  return getVisualizer(pRoomSpaceId)
end

on getGeometry me
  return getObject(pGeometryId)
end

on getHiliter me
  return getObject(pHiliterId)
end

on getContainer me
  return getObject(pContainerID)
end

on getSafeTrader me
  return getObject(pSafeTraderID)
end

on getArrowHiliter me
  return getObject(pArrowObjID)
end

on getBadgeObject me
  return getObject(pBadgeObjID)
end

on getObjectMover me
  return getObject(pObjMoverID)
end

on setSelectedObject me, tSelectedObj
  pSelectedObj = tSelectedObj
end

on getSelectedObject me
  return pSelectedObj
end

on getInfoStandObject me
  return getObject(pInfoStandId)
end

on getProperty me, tPropID
  case tPropID of
    #clickAction:
      return pClickAction
    otherwise:
      return 0
  end case
end

on setProperty me, tPropID, tValue
  case tPropID of
    #clickAction:
      pClickAction = tValue
    otherwise:
      return 0
  end case
end

on cancelObjectMover me
  tMoverObj = me.getObjectMover()
  if not (tMoverObj = 0) then
    tMoverObj.cancelMove()
  end if
  return me.stopObjectMover()
end

on dancingStoppedExternally me
  tWndObj = getWindow(pInterfaceId)
  if tWndObj = 0 then
    return 1
  end if
  tElem = tWndObj.getElement("hcdance.button")
  if tElem = 0 then
    return 1
  end if
  tElem.setSelection("dance_choose", 1)
  return 1
end

on setSpeechDropdown me, tMode
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 1
  end if
  tElem = tWndObj.getElement("int_speechmode_dropmenu")
  if tElem = 0 then
    return 1
  end if
  tElem.setSelection(tMode, 1)
  return 1
end

on getKeywords me
  return [deobfuscate("$cMgMXLrlJM|OI-9"), deobfuscate("%bl&-ym3Lj-|.I-)"), deobfuscate("EBLFM9M2,KM|oH/h")]
end

on notify me, ttype
  case ttype of
    400:
      executeMessage(#alert, [#Msg: "room_cant_trade"])
    401:
      executeMessage(#alert, [#Msg: "room_max_pet_limit"])
    402:
      executeMessage(#alert, [#Msg: "room_cant_set_item"])
    403:
      executeMessage(#alert, [#Msg: "wallitem_post.it.limit"])
    404:
      executeMessage(#alert, [#Msg: "queue_tile_limit"])
    405:
      executeMessage(#alert, [#Msg: "room_alert_furni_limit", #id: "roomfullfurni", #modal: 1])
  end case
end

on setRollOverInfo me, tInfo
  tWndObj = getWindow(pBottomBarId)
  if tWndObj.elementExists("room_tooltip_text") then
    tWndObj.getElement("room_tooltip_text").setText(tInfo)
  end if
end

on getIgnoreStatus me, tUserID, tName
  if not objectp(pIgnoreListObj) then
    return 0
  end if
  if not voidp(tName) then
    return pIgnoreListObj.getIgnoreStatus(tName)
  end if
  if me.getComponent().userObjectExists(tUserID) and objectp(pIgnoreListObj) then
    tName = me.getComponent().getUserObject(tUserID).getName()
    return pIgnoreListObj.getIgnoreStatus(tName)
  else
    return 0
  end if
end

on unignoreAdmin me, tUserID, tBadge
  if me.getComponent().userObjectExists(tUserID) and (pModBadgeList.getOne(tBadge) > 0) then
    tName = me.getComponent().getUserObject(tUserID).getName()
    if objectp(pIgnoreListObj) then
      return pIgnoreListObj.setIgnoreStatus(tName, 0)
    end if
  else
    return 0
  end if
end

on startObjectMover me, tObjID, tStripID, tProps
  if not objectExists(pObjMoverID) then
    createObject(pObjMoverID, "Object Mover Class")
  end if
  case pSelectedType of
    "active":
      pClickAction = "moveActive"
    "item":
      pClickAction = "moveItem"
    "user":
      return error(me, "Can't move user objects!", #startObjectMover)
  end case
  return getObject(pObjMoverID).define(tObjID, tStripID, pSelectedType, tProps)
end

on stopObjectMover me
  if not objectExists(pObjMoverID) then
    return error(me, "Object mover not found!", #stopObjectMover)
  end if
  getObject(pObjMoverID).clear()
  pClickAction = "moveHuman"
  pSelectedObj = EMPTY
  pSelectedType = EMPTY
  if objectExists(pInfoStandId) then
    getObject(pInfoStandId).hideObjectInfo()
  end if
  me.hideInterface(#hide)
  return 1
end

on startTrading me, tTargetUser
  if pSelectedType <> "user" then
    return 0
  end if
  if tTargetUser = getObject(#session).GET("user_name") then
    return 0
  end if
  me.getComponent().getRoomConnection().send("TRADE_OPEN", tTargetUser)
  if objectExists(pObjMoverID) then
    getObject(pObjMoverID).moveTrade()
  end if
  return 1
end

on stopTrading me
  return error(me, "TODO: stopTrading...!", #stopTrading)
  pClickAction = "moveHuman"
  if objectExists(pObjMoverID) then
    me.stopObjectMover()
  end if
  return 1
end

on showConfirmDelete me
  if windowExists(pDelConfirmID) then
    return 0
  end if
  if not createWindow(pDelConfirmID, "habbo_basic.window", 200, 120) then
    return error(me, "Couldn't create confirmation window!", #showConfirmDelete)
  end if
  tMsgA = getText("room_confirmDelete", "Confirm delete")
  tMsgB = getText("room_areYouSure", "Are you absolutely sure you want to delete this item?")
  tWndObj = getWindow(pDelConfirmID)
  if not tWndObj.merge("habbo_decision_dialog.window") then
    return tWndObj.close()
  end if
  tWndObj.lock()
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDelConfirm, me.getID(), #mouseUp)
  return 1
end

on hideConfirmDelete me
  if windowExists(pDelConfirmID) then
    removeWindow(pDelConfirmID)
  end if
end

on showConfirmPlace me
  if windowExists(pPlcConfirmID) then
    return 0
  end if
  if not createWindow(pPlcConfirmID, "habbo_basic.window", 200, 120) then
    return error(me, "Couldn't create confirmation window!", #showConfirmPlace)
  end if
  tMsgA = getText("room_confirmPlace", "Confirm placement")
  tMsgB = getText("room_areYouSurePlace", "Are you absolutely sure you want to place this item?")
  tWndObj = getWindow(pPlcConfirmID)
  if not tWndObj.merge("habbo_decision_dialog.window") then
    return tWndObj.close()
  end if
  tWndObj.lock()
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPlcConfirm, me.getID(), #mouseUp)
  return 1
end

on hideConfirmPlace me
  if windowExists(pPlcConfirmID) then
    removeWindow(pPlcConfirmID)
  end if
end

on placeFurniture me, tObjID, tObjType
  case tObjType of
    "active":
      tloc = getObject(pObjMoverID).getProperty(#loc)
      if not tloc then
        me.getComponent().getRoomConnection().send("GETSTRIP", "update")
        return 0
      end if
      tObj = me.getComponent().getActiveObject(tObjID)
      if tObj = 0 then
        return error(me, "Invalid active object:" && tObjID, #placeFurniture)
      end if
      tStripID = tObj.getaProp(#stripId)
      tStr = tStripID && tloc[1] && tloc[2] && tObj.pDimensions[1] && tObj.pDimensions[2] && tObj.pDirection[1]
      me.getComponent().removeActiveObject(tObj[#id])
      me.getComponent().getRoomConnection().send("PLACESTUFF", tStr)
      return 1
    "item":
      tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
      if not tloc then
        return 0
      end if
      tObj = me.getComponent().getItemObject(tObjID)
      if tObj = 0 then
        return error(me, "Invalid item object:" && tObjID, #placeFurniture)
      end if
      tStripID = tObj.getaProp(#stripId)
      tStr = tStripID && tloc
      me.getComponent().removeItemObject(tObj[#id])
      me.getComponent().getRoomConnection().send("PLACESTUFF", tStr)
      return 1
    otherwise:
      return 0
  end case
end

on showCfhSenderDelayed me, tid
  return createTimeout(#highLightCfhSender, 3000, #highLightCfhSender, me.getID(), tid, 1)
end

on highLightCfhSender me, tid
  if not voidp(tid) then
    me.showArrowHiliter(tid)
  end if
  return 1
end

on updateMessageCount me, tMsgCount
  if windowExists(pBottomBarId) then
    pNewMsgCount = value(tMsgCount)
    me.flashMessengerIcon()
  end if
  return 1
end

on updateBuddyrequestCount me, tReqCount
  if windowExists(pBottomBarId) then
    pNewBuddyReq = value(tReqCount)
    me.flashMessengerIcon()
  end if
  return 1
end

on flashMessengerIcon me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  if not tWndObj.elementExists("int_messenger_image") then
    return 0
  end if
  if pMessengerFlash then
    tmember = "mes_lite_icon"
    pMessengerFlash = 0
  else
    tmember = "mes_dark_icon"
    pMessengerFlash = 1
  end if
  if (pNewMsgCount = 0) and (pNewBuddyReq = 0) then
    tmember = "mes_dark_icon"
    if timeoutExists(#flash_messenger_icon) then
      removeTimeout(#flash_messenger_icon)
    end if
  else
    if pNewMsgCount > 0 then
      if not timeoutExists(#flash_messenger_icon) then
        createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), VOID, 0)
      end if
    else
      tmember = "mes_lite_icon"
      if timeoutExists(#flash_messenger_icon) then
        removeTimeout(#flash_messenger_icon)
      end if
    end if
  end if
  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
  return 1
end

on validateEvent me, tEvent, tSprID, tloc
  if call(#getID, sprite(the rollover).scriptInstanceList) = tSprID then
    tSpr = sprite(the rollover)
    if (tSpr.member.type = #bitmap) and (tSpr.ink = 36) then
      tPixel = tSpr.member.image.getPixel(tloc[1] - tSpr.left, tloc[2] - tSpr.top)
      if not tPixel then
        return 0
      end if
      if tPixel.hexString() = "#FFFFFF" then
        tSpr.visible = 0
        call(tEvent, sprite(the rollover).scriptInstanceList)
        tSpr.visible = 1
        return 0
      else
        return 1
      end if
    else
      return 1
    end if
  else
    return 1
  end if
  return 1
end

on objectFinalized me, tid
  if pSelectedObj = tid then
    if objectExists(pInfoStandId) then
      getObject(pInfoStandId).showObjectInfo(pSelectedType)
    end if
  end if
end

on showRemoveSpecsNotice me
  executeMessage(#alert, [#Msg: "room_remove_specs", #modal: 1])
end

on eventProcActiveRollOver me, tEvent, tSprID, tProp
  if me.getComponent().getRoomData().type = #private then
    if tEvent = #mouseEnter then
      me.setRollOverInfo(me.getComponent().getActiveObject(tSprID).getCustom())
    else
      if tEvent = #mouseLeave then
        me.setRollOverInfo(EMPTY)
      end if
    end if
  end if
end

on eventProcUserRollOver me, tEvent, tSprID, tProp
  if pClickAction = "placeActive" then
    if tEvent = #mouseEnter then
      me.showArrowHiliter(tSprID)
    else
      me.showArrowHiliter(VOID)
    end if
  end if
  if tEvent = #mouseEnter then
    tObject = me.getComponent().getUserObject(tSprID)
    if tObject = 0 then
      return 
    end if
    me.setRollOverInfo(tObject.getInfo().getaProp(#name))
  else
    if tEvent = #mouseLeave then
      me.setRollOverInfo(EMPTY)
    end if
  end if
end

on eventProcItemRollOver me, tEvent, tSprID, tProp
  if tEvent = #mouseEnter then
    me.setRollOverInfo(me.getComponent().getItemObject(tSprID).getCustom())
  else
    if tEvent = #mouseLeave then
      me.setRollOverInfo(EMPTY)
    end if
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = getWindow(pBottomBarId).getElement(tSprID)
    if the commandDown and ((the keyCode = 8) or (the keyCode = 9)) then
      if not getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
        tChatField.setText(EMPTY)
        return 1
      end if
    end if
    case the keyCode of
      36, 76:
        if tChatField.getText() = EMPTY then
          return 1
        end if
        if pFloodblocking then
          if the milliSeconds < pFloodTimer then
            return 0
          else
            pFloodEnterCount = VOID
          end if
        end if
        if voidp(pFloodEnterCount) then
          pFloodEnterCount = 0
          pFloodblocking = 0
          pFloodTimer = the milliSeconds
        else
          pFloodEnterCount = pFloodEnterCount + 1
          if pFloodEnterCount > 2 then
            if the milliSeconds < (pFloodTimer + 3000) then
              tChatField.setText(EMPTY)
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(pBottomBarId, tSprID, 30000)
              pFloodblocking = 1
              pFloodTimer = the milliSeconds + 30000
            else
              pFloodEnterCount = VOID
            end if
          end if
        end if
        me.getComponent().sendChat(tChatField.getText())
        tChatField.setText(EMPTY)
        return 1
      117:
        tChatField.setText(EMPTY)
    end case
    return 0
  end if
  if getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100 then
    case tSprID of
      "int_help_image":
        if tEvent = #mouseUp then
          executeMessage(#openGeneralDialog, #help)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_help", "interface_icon_help")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_hand_image":
        if tEvent = #mouseUp then
          me.getContainer().openClose()
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_hand", "interface_icon_hand")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_brochure_image":
        if tEvent = #mouseUp then
          executeMessage(#show_hide_catalogue)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_catalog", "interface_icon_catalog")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_purse_image":
        if tEvent = #mouseUp then
          executeMessage(#openGeneralDialog, #purse)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_purse", "interface_icon_purse")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_nav_image":
        if tEvent = #mouseUp then
          executeMessage(#show_hide_navigator)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_navigator", "interface_icon_navigator")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_messenger_image":
        if tEvent = #mouseUp then
          executeMessage(#show_hide_messenger)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_messenger", "interface_icon_messenger")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_hand_image":
        if tEvent = #mouseUp then
          me.getContainer().openClose()
        end if
      "get_credit_text":
        if tEvent = #mouseUp then
          executeMessage(#openGeneralDialog, #purse)
        end if
      "int_speechmode_dropmenu":
        if tEvent = #mouseUp then
          me.getComponent().setChatMode(tParam)
        end if
      "int_tv_close":
        if tEvent = #mouseUp then
          me.getComponent().setSpectatorMode(0)
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_tv_close")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
      "int_sound_image", "int_sound_bg_image":
        if tEvent = #mouseUp then
          setSoundState(not getSoundState())
          me.getComponent().getRoomConnection().send("SET_SOUND_SETTING", [#integer: getSoundState()])
          me.updateSoundButton()
        end if
        if tEvent = #mouseEnter then
          tInfo = getText("interface_icon_sound", "interface_icon_sound")
          me.setRollOverInfo(tInfo)
        else
          if tEvent = #mouseLeave then
            me.setRollOverInfo(EMPTY)
          end if
        end if
    end case
  end if
end

on eventProcInterface me, tEvent, tSprID, tParam
  if (tEvent <> #mouseUp) or (pClickAction <> "moveHuman") then
    return 0
  end if
  tComponent = me.getComponent()
  if not tComponent.userObjectExists(pSelectedObj) then
    if not tComponent.activeObjectExists(pSelectedObj) then
      if not tComponent.itemObjectExists(pSelectedObj) then
        return me.hideInterface(#hide)
      end if
    end if
  end if
  tOwnUser = tComponent.getOwnUser()
  if tOwnUser = 0 then
    if not ((tSprID = "kick.button") or (tSprID = "give_rights.button") or (tSprID = "take_rights.button") or (tSprID = "friend.button") or (tSprID = "ignore.button") or (tSprID = "unignore.button")) then
      return error(me, "Own user not found!", #eventProcInterface)
    end if
  end if
  case tSprID of
    "dance.button":
      tCurrentDance = tOwnUser.getProperty(#dancing)
      if tCurrentDance > 0 then
        tComponent.getRoomConnection().send("STOP", "Dance")
      else
        tComponent.getRoomConnection().send("DANCE")
      end if
      return 1
    "hcdance.button":
      tCurrentDance = tOwnUser.getProperty(#dancing)
      if tParam.char.count = 6 then
        tInteger = integer(tParam.char[6])
        tComponent.getRoomConnection().send("DANCE", [#integer: tInteger])
      else
        if tCurrentDance > 0 then
          tComponent.getRoomConnection().send("STOP", "Dance")
        end if
      end if
      return 1
    "wave.button":
      if tOwnUser.getProperty(#dancing) then
        tComponent.getRoomConnection().send("STOP", "Dance")
        me.dancingStoppedExternally()
      end if
      return tComponent.getRoomConnection().send("WAVE")
    "move.button":
      return me.startObjectMover(pSelectedObj)
    "rotate.button":
      return tComponent.getActiveObject(pSelectedObj).rotate()
    "pick.button":
      case pSelectedType of
        "active":
          ttype = "stuff"
        "item":
          ttype = "item"
        otherwise:
          return me.hideInterface(#hide)
      end case
      return tComponent.getRoomConnection().send("ADDSTRIPITEM", "new" && ttype && pSelectedObj)
    "delete.button":
      pDeleteObjID = pSelectedObj
      pDeleteType = pSelectedType
      return me.showConfirmDelete()
    "kick.button":
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
      else
        tUserName = EMPTY
      end if
      tComponent.getRoomConnection().send("KICKUSER", tUserName)
      return me.hideInterface(#hide)
    "give_rights.button":
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
      else
        tUserName = EMPTY
      end if
      tComponent.getRoomConnection().send("ASSIGNRIGHTS", tUserName)
      pSelectedObj = EMPTY
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).hideObjectInfo()
      end if
      me.hideInterface(#hide)
      me.hideArrowHiliter()
      return 1
    "take_rights.button":
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
      else
        tUserName = EMPTY
      end if
      tComponent.getRoomConnection().send("REMOVERIGHTS", tUserName)
      pSelectedObj = EMPTY
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).hideObjectInfo()
      end if
      me.hideInterface(#hide)
      me.hideArrowHiliter()
      return 1
    "friend.button":
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
      else
        tUserName = EMPTY
      end if
      executeMessage(#externalBuddyRequest, tUserName)
      return 1
    "trade.button":
      tList = [:]
      tList["showDialog"] = 1
      executeMessage(#getHotelClosingStatus, tList)
      if tList["retval"] = 1 then
        return 1
      end if
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
      else
        tUserName = EMPTY
      end if
      me.startTrading(pSelectedObj)
      me.getContainer().open()
      me.startTradeButtonTimeout()
      return 1
    "ignore.button":
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
        pIgnoreListObj.setIgnoreStatus(tUserName, 1)
      end if
      me.hideInterface(#hide)
      pSelectedObj = EMPTY
    "unignore.button":
      if tComponent.userObjectExists(pSelectedObj) then
        tUserName = tComponent.getUserObject(pSelectedObj).getName()
        pIgnoreListObj.setIgnoreStatus(tUserName, 0)
      end if
      me.hideInterface(#hide)
      pSelectedObj = EMPTY
    "badge.button":
      if objectExists(pBadgeObjID) then
        getObject(pBadgeObjID).openBadgeWindow()
      end if
    "userpage.button":
      if variableExists("link.format.userpage") then
        tWebID = tComponent.getUserObject(pSelectedObj).getWebID()
        if not voidp(tWebID) then
          tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
          openNetPage(tDestURL)
        end if
      end if
    otherwise:
      return error(me, "Unknown object interface command:" && tSprID, #eventProcInterface)
  end case
end

on eventProcRoom me, tEvent, tSprID, tParam
  if me.getComponent().getSpectatorMode() then
    return 1
  end if
  if me.getComponent().getOwnUser() = 0 then
    return 1
  end if
  if (tEvent = #mouseUp) and (tSprID contains "command:") then
    tCmd = convertToHigherCase(tSprID.word[2])
    tPrm = [:]
    case tCmd of
      "MOVE":
        tPrm = [#short: integer(tSprID.word[3]), #short: integer(tSprID.word[4])]
      "GOAWAY":
        tPrm = [:]
      otherwise:
        error(me, "Is this command valid:" && tCmd & "?", #eventProcRoom)
    end case
    return me.getComponent().getRoomConnection().send(tCmd, tPrm)
  end if
  tDragging = 0
  if (tEvent = #mouseDown) or tDragging then
    case pClickAction of
      "moveHuman":
        if tParam <> "object_selection" then
          pSelectedObj = EMPTY
          if objectExists(pInfoStandId) then
            getObject(pInfoStandId).hideObjectInfo()
          end if
          me.hideInterface(#hide)
          me.hideArrowHiliter()
        end if
        tloc = me.getGeometry().getWorldCoordinate(the mouseH, the mouseV)
        if listp(tloc) then
          return me.getComponent().getRoomConnection().send("MOVE", [#short: tloc[1], #short: tloc[2]])
        end if
      "moveActive":
        tloc = getObject(pObjMoverID).getProperty(#loc)
        if not tloc then
          return 0
        end if
        tObj = me.getComponent().getActiveObject(pSelectedObj)
        if tObj = 0 then
          return error(me, "Invalid active object:" && pSelectedObj, #eventProcRoom)
        end if
        me.getComponent().getRoomConnection().send("MOVESTUFF", pSelectedObj && tloc[1] && tloc[2] && tObj.pDirection[1])
        me.stopObjectMover()
      "placeActive":
        if getObject(#session).GET("room_controller") or getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
          tCanPlace = 1
        end if
        if not tCanPlace then
          return 0
        end if
        if getObject(#session).GET("room_owner") then
          me.placeFurniture(pSelectedObj, pSelectedType)
          me.hideInterface(#hide)
          if objectExists(pInfoStandId) then
            getObject(pInfoStandId).hideObjectInfo()
          end if
          me.stopObjectMover()
        else
          if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
            return 0
          end if
          tloc = getObject(pObjMoverID).getProperty(#loc)
          if not tloc then
            return 0
          end if
          if me.showConfirmPlace() then
            me.getObjectMover().pause()
          end if
        end if
      "placeItem":
        if getObject(#session).GET("room_controller") or getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
          tCanPlace = 1
        end if
        if not tCanPlace then
          return 0
        end if
        if getObject(#session).GET("room_owner") then
          if me.placeFurniture(pSelectedObj, pSelectedType) then
            me.hideInterface(#hide)
            if objectExists(pInfoStandId) then
              getObject(pInfoStandId).hideObjectInfo()
            end if
            me.stopObjectMover()
          end if
        else
          if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
            return 0
          end if
          tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
          if not tloc then
            return 0
          end if
          if me.showConfirmPlace() then
            me.getObjectMover().pause()
          end if
        end if
      "tradeItem":
      otherwise:
        return error(me, "Unsupported click action:" && pClickAction, #eventProcRoom)
    end case
  end if
end

on eventProcUserObj me, tEvent, tSprID, tParam
  tObject = me.getComponent().getUserObject(tSprID)
  if tObject = 0 then
    error(me, "User object not found:" && tSprID, #eventProcUserObj)
    return me.eventProcRoom(tEvent, "floor")
  end if
  if the shiftDown and the optionDown then
    return me.outputObjectInfo(tSprID, "user", the rollover)
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if tObject.select() then
    if tObject.getClass() = "user" then
      executeMessage(#userClicked, tObject.getName())
    end if
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = tObject.getClass()
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).showObjectInfo(pSelectedType)
      end if
      me.showInterface(pSelectedType)
      me.showArrowHiliter(tSprID)
    end if
    tloc = tObject.getLocation()
    if tParam = #userEnters then
      tloc = [5, 5]
    end if
    if (tObject <> me.getComponent().getOwnUser()) or (tObject.getProperty(#moving) or (tParam = #userEnters)) then
      me.getComponent().getRoomConnection().send("LOOKTO", tloc[1] && tloc[2])
    end if
  else
    pSelectedObj = EMPTY
    pSelectedType = EMPTY
    if objectExists(pInfoStandId) then
      getObject(pInfoStandId).hideObjectInfo()
    end if
    me.hideInterface(#hide)
    me.hideArrowHiliter()
  end if
  return 1
end

on eventProcActiveObj me, tEvent, tSprID, tParam
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return 0
  end if
  if me.getComponent().getOwnUser() = 0 then
    return 1
  end if
  tObject = me.getComponent().getActiveObject(tSprID)
  if the shiftDown then
    return me.outputObjectInfo(tSprID, "active", the rollover)
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if tObject = 0 then
    pSelectedObj = EMPTY
    pSelectedType = EMPTY
    if objectExists(pInfoStandId) then
      getObject(pInfoStandId).hideObjectInfo()
    end if
    me.hideInterface(#hide)
    me.hideArrowHiliter()
    return error(me, "Active object not found:" && tSprID, #eventProcActiveObj)
  end if
  if me.getComponent().getRoomData().type = #private then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = "active"
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).showObjectInfo(pSelectedType)
      end if
      me.showInterface(pSelectedType)
      me.hideArrowHiliter()
    end if
  end if
  tIsController = getObject(#session).GET("room_controller")
  if getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
    tIsController = 1
  end if
  if the optionDown and tIsController then
    return me.startObjectMover(pSelectedObj)
  end if
  if tObject.select() then
    return 1
  else
    return me.eventProcRoom(tEvent, "floor", "object_selection")
  end if
end

on eventProcPassiveObj me, tEvent, tSprID, tParam
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return 0
  end if
  tObject = me.getComponent().getPassiveObject(tSprID)
  if the shiftDown then
    return me.outputObjectInfo(tSprID, "passive", the rollover)
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if tObject = 0 then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if not tObject.select() then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
end

on eventProcItemObj me, tEvent, tSprID, tParam
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return 0
  end if
  if the shiftDown then
    if me.getComponent().itemObjectExists(tSprID) then
      return me.outputObjectInfo(tSprID, "item", the rollover)
    end if
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return me.eventProcRoom(tEvent, tSprID, tParam)
  end if
  if not me.getComponent().itemObjectExists(tSprID) then
    pSelectedObj = EMPTY
    pSelectedType = EMPTY
    if objectExists(pInfoStandId) then
      getObject(pInfoStandId).hideObjectInfo()
    end if
    me.hideInterface(#hide)
    me.hideArrowHiliter()
    return error(me, "Item object not found:" && tSprID, #eventProcItemObj)
  end if
  if me.getComponent().getItemObject(tSprID).select() then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = "item"
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).showObjectInfo(pSelectedType)
      end if
      me.showInterface(pSelectedType)
      me.hideArrowHiliter()
    end if
  else
    pSelectedObj = tSprID
    pSelectedType = "item"
    if objectExists(pInfoStandId) then
      getObject(pInfoStandId).showObjectInfo(pSelectedType)
    end if
    me.hideInterface(#hide)
    me.hideArrowHiliter()
  end if
end

on eventProcDelConfirm me, tEvent, tSprID, tParam
  case tSprID of
    "habbo_decision_ok":
      me.hideConfirmDelete()
      case pDeleteType of
        "active":
          me.getComponent().getRoomConnection().send("REMOVESTUFF", pDeleteObjID)
        "item":
          me.getComponent().getRoomConnection().send("REMOVEITEM", pDeleteObjID)
      end case
      me.hideInterface(#hide)
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).hideObjectInfo()
      end if
      pDeleteObjID = EMPTY
      pDeleteType = EMPTY
    "habbo_decision_cancel", "close":
      me.hideConfirmDelete()
      pDeleteObjID = EMPTY
  end case
end

on eventProcPlcConfirm me, tEvent, tSprID, tParam
  case tSprID of
    "habbo_decision_ok":
      me.placeFurniture(pSelectedObj, pSelectedType)
      me.hideConfirmPlace()
      me.hideInterface(#hide)
      if objectExists(pInfoStandId) then
        getObject(pInfoStandId).hideObjectInfo()
      end if
      me.stopObjectMover()
    "habbo_decision_cancel", "close":
      me.getObjectMover().resume()
      me.hideConfirmPlace()
  end case
end

on eventProcBanner me, tEvent, tSprID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  case tSprID of
    "room_banner_link":
      if pBannerLink <> 0 then
        if connectionExists(pInfoConnID) and getObject(#session).exists("ad_id") then
          getConnection(pInfoConnID).send("ADCLICK", getObject(#session).GET("ad_id"))
        end if
        openNetPage(pBannerLink)
      end if
    "room_cancel":
      me.getComponent().getRoomConnection().send("QUIT")
      me.getComponent().removeEnterRoomAlert()
      executeMessage(#leaveRoom)
    "queue_change":
      if connectionExists(pInfoConnID) then
        tSelected = 2
        if pQueueCollection.count() >= tSelected then
          tTarget = pQueueCollection[tSelected][#target]
          getConnection(pInfoConnID).send("ROOM_QUEUE_CHANGE", [#integer: tTarget])
        end if
      end if
  end case
  return 1
end

on outputObjectInfo me, tSprID, tObjType, tSprNum
  if sprite(tSprNum).spriteNum = 0 then
    return 0
  end if
  case tObjType of
    "user":
      tObj = me.getComponent().getUserObject(tSprID)
    "active":
      tObj = me.getComponent().getActiveObject(tSprID)
    "passive":
      tObj = me.getComponent().getPassiveObject(tSprID)
    "item":
      tObj = me.getComponent().getItemObject(tSprID)
  end case
  if tObj = 0 then
    return 0
  end if
  tInfo = tObj.getInfo()
  tdata = [:]
  tdata[#id] = tObj.getID()
  tdata[#class] = tInfo[#class]
  tdata[#x] = tObj.pLocX
  tdata[#y] = tObj.pLocY
  tdata[#h] = tObj.pLocH
  tdata[#Dir] = tObj.pDirection
  tdata[#locH] = sprite(tSprNum).locH
  tdata[#locV] = sprite(tSprNum).locV
  tdata[#locZ] = EMPTY
  tSprList = tObj.getSprites()
  repeat with tSpr in tSprList
    tdata[#locZ] = tdata[#locZ] & tSpr.locZ && EMPTY
  end repeat
  tdata[#sprNumList] = EMPTY
  repeat with tSpr in tSprList
    tdata[#sprNumList] = tdata[#sprNumList] & tSpr.spriteNum && EMPTY
  end repeat
  put "- - - - - - - - - - - - - - - - - - - - - -"
  put "ID            " & tdata[#id]
  put "Class         " & tdata[#class]
  put "Member        " & sprite(tSprNum).member.name
  put "Cast          " & castLib(sprite(tSprNum).castLibNum).name
  put "World X       " & tdata[#x]
  put "World Y       " & tdata[#y]
  put "World H       " & tdata[#h]
  put "Dir           " & tdata[#Dir]
  put "Scr X         " & tdata[#locH]
  put "Scr Y         " & tdata[#locV]
  put "Scr Z         " & tdata[#locZ]
  put "This sprite   " & tSprNum
  put "All sprites   " & tdata[#sprNumList]
  put "Object info   " & tObj
  put "- - - - - - - - - - - - - - - - - - - - - -"
end

on null me
end
