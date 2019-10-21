property pHiliterId, pGeometryId, pContainerID, pSafeTraderID, pArrowObjID, pObjMoverID, pBadgeObjID, pDoorBellID, pLoaderBarID, pRoomSpaceId, pBottomBarId, pInfoStandId, pSelectedObj, pModBadgeList, pIgnoreListObj, pInterfaceId, pBannerLink, pInfoConnID, pCoverSpr, pClickAction, pSelectedType, pDelConfirmID, pPlcConfirmID, pMessengerFlash, pNewMsgCount, pNewBuddyReq, pFloodblocking, pFloodTimer, pFloodEnterCount, pDeleteType, pDeleteObjID

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
  pRoomSpaceId = "Room_visualizer"
  pBottomBarId = "Room_bar"
  pInfoStandId = "Room_info_stand"
  pInterfaceId = "Room_interface"
  pDelConfirmID = getText("win_delete_item", "Delete item?")
  pLoaderBarID = "Loading room"
  pPlcConfirmID = getText("win_place", "Place item?")
  pClickAction = #null
  pSelectedObj = ""
  pSelectedType = ""
  pDeleteObjID = ""
  pDeleteType = ""
  pRingingUser = ""
  pVisitorQueue = []
  pBannerLink = 0
  pModBadgeList = getVariableValue("moderator.badgelist")
  createObject(pHiliterId, "Room Hiliter Class")
  createObject(pGeometryId, "Room Geometry Class")
  createObject(pContainerID, "Container Hand Class")
  createObject(pSafeTraderID, "Safe Trader Class")
  createObject(pArrowObjID, "Select Arrow Class")
  createObject(pObjMoverID, "Object Mover Class")
  createObject(pBadgeObjID, "Badge Manager Class")
  createObject(pPreviewObjID, "Preview Renderer Class")
  createObject(pDoorBellID, "Doorbell Class")
  pIgnoreListObj = createObject(#temp, "Ignore List Class")
  getObject(pObjMoverID).setProperty(#geometry, getObject(pGeometryId))
  registerMessage(#notify, me.getID(), #notify)
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  return TRUE
end

on deconstruct me 
  pClickAction = #null
  unregisterMessage(#notify, me.getID())
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  pIgnoreListObj = void()
  removeObject(pBadgeObjID)
  removeObject(pDoorBellID)
  return(me.hideAll())
end

on showRoom me, tRoomId 
  if not memberExists(tRoomId & ".room") then
    return(error(me, "Room description not found:" && tRoomId, #showRoom))
  end if
  me.showTrashCover()
  if windowExists(pLoaderBarID) then
    activateWindow(pLoaderBarID)
  end if
  tRoomField = tRoomId & ".room"
  createVisualizer(pRoomSpaceId, tRoomField)
  tVisObj = getVisualizer(pRoomSpaceId)
  tLocX = tVisObj.getProperty(#locX)
  tLocY = tVisObj.getProperty(#locY)
  tlocz = tVisObj.getProperty(#locZ)
  tdata = getObject(#layout_parser).parse(tRoomField).getProp(#roomdata, 1)
  tdata.setAt(#offsetz, tlocz)
  tdata.setAt(#offsetx, tdata.getAt(#offsetx))
  tdata.setAt(#offsety, tdata.getAt(#offsety))
  me.getGeometry().define(tdata)
  tSprList = tVisObj.getProperty(#spriteList)
  call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseDown)
  call(#registerProcedure, tSprList, #eventProcRoom, me.getID(), #mouseUp)
  tHiliterSpr = tVisObj.getSprById("hiliter")
  if not tHiliterSpr then
    me.getHiliter().deconstruct()
    error(me, "Hiliter not found in room description!!!", #showRoom)
  else
    me.getHiliter().define([#sprite:tHiliterSpr, #geometry:pGeometryId])
    receiveUpdate(pHiliterId)
  end if
  me.getArrowHiliter().Init()
  pClickAction = "moveHuman"
  return TRUE
end

on hideRoom me 
  removeUpdate(pHiliterId)
  pClickAction = #null
  pSelectedObj = ""
  me.hideArrowHiliter()
  me.hideTrashCover()
  if visualizerExists(pRoomSpaceId) then
    removeVisualizer(pRoomSpaceId)
  end if
  return TRUE
end

on showRoomBar me 
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "empty.window", 0, 452)
    tWndObj = getWindow(pBottomBarId)
    tWndObj.lock(1)
    tWndObj.merge("room_bar.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
    executeMessage(#messageUpdateRequest)
    executeMessage(#buddyUpdateRequest)
    if (me.getComponent().getRoomData().type = #private) then
      tRoomData = me.getComponent().pSaveData
      tRoomTxt = getText("room_name") && tRoomData.getAt(#name) & "\r" & getText("room_owner") && tRoomData.getAt(#owner)
      tWndObj.getElement("room_info_text").setText(tRoomTxt)
    else
      tWndObj.getElement("room_info_text").hide()
    end if
    return TRUE
  end if
  return FALSE
end

on hideRoomBar me 
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBarId) then
    removeWindow(pBottomBarId)
  end if
end

on showInfostand me 
  if not windowExists(pInfoStandId) then
    createWindow(pInfoStandId, "info_stand.window", 552, 332)
    tWndObj = getWindow(pInfoStandId)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInfoStand, me.getID(), #mouseUp)
  end if
  return TRUE
end

on hideInfoStand me 
  if windowExists(pInfoStandId) then
    return(removeWindow(pInfoStandId))
  end if
end

on showInterface me, tObjType 
  tSession = getObject(#session)
  if (tObjType = "active") or (tObjType = "item") then
    tSomeRights = 0
    tOwnUser = me.getComponent().getOwnUser()
    if (tOwnUser = 0) then
      return(error(me, "Own user not found!", #showInterface))
    end if
    if tOwnUser.getInfo().ctrl <> 0 then
      tSomeRights = 1
    end if
    if getObject(#session).get("user_rights").getOne("fuse_any_room_controller") then
      tSomeRights = 1
    end if
    if getObject(#session).get("user_rights").getOne("fuse_pick_up_any_furni") then
      tSomeRights = 1
    end if
    if not tSomeRights then
      return(me.hideInterface(#hide))
    end if
  end if
  tCtrlType = ""
  if tSession.get("room_controller") or getObject(#session).get("user_rights").getOne("fuse_any_room_controller") then
    tCtrlType = "ctrl"
  end if
  if tSession.get("room_owner") then
    tCtrlType = "owner"
  end if
  if (tObjType = "user") then
    if (pSelectedObj = tSession.get("user_index")) then
      tCtrlType = "personal"
    else
      if (tCtrlType = "") then
        tCtrlType = "friend"
      end if
    end if
  end if
  if variableExists("interface.cmds." & tObjType & "." & tCtrlType) then
    tButtonList = getVariableValue("interface.cmds." & tObjType & "." & tCtrlType)
  else
    return(me.hideInterface(#hide))
  end if
  if (tObjType = "active") or (tObjType = "item") then
    if getObject(#session).get("user_rights").getOne("fuse_pick_up_any_furni") then
      if (tButtonList.getPos("pick") = 0) then
        tButtonList.add("pick")
      end if
    end if
  end if
  if (tButtonList.count = 0) then
    return(me.hideInterface(#hide))
  end if
  if (tObjType = "item") then
    tObjType = "active"
  end if
  if (tCtrlType = "personal") then
    tObjType = "personal"
  end if
  if (me.getComponent().getRoomData().type = #private) then
    if (tObjType = "user") then
      if pSelectedObj <> tSession.get("user_name") then
        tUserInfo = me.getComponent().getUserObject(pSelectedObj).getInfo()
        if (tUserInfo.ctrl = 0) then
          tButtonList.deleteOne("take_rights")
        else
          if (tUserInfo.ctrl = "furniture") then
            tButtonList.deleteOne("give_rights")
          else
            if (tUserInfo.ctrl = "useradmin") then
              tButtonList.deleteOne("give_rights")
            end if
          end if
        end if
        tTargetIsOwner = (tUserInfo.name = me.getComponent().getRoomData().owner)
        if tTargetIsOwner then
          if not getObject(#session).get("user_rights").getOne("fuse_kick") then
            tButtonList.deleteOne("kick")
          end if
          if not getObject(#session).get("user_rights").getOne("fuse_ignore_room_owner") then
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
  if (tObjType = "user") then
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
  if (tCtrlType = "personal") then
    if getObject("session").get("available_badges").ilk <> #list then
      tButtonList.deleteOne("badge")
    else
      if getObject("session").get("available_badges").count < 1 then
        tButtonList.deleteOne("badge")
      end if
    end if
  end if
  tWndObj = getWindow(pInterfaceId)
  tLayout = "object_interface.window"
  if (tWndObj = 0) then
    createWindow(pInterfaceId, tLayout, 545, 466)
    tWndObj = getWindow(pInterfaceId)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInterface, me.getID())
  else
    tWndObj.show()
  end if
  repeat while tWndObj.getProperty(#spriteList) <= undefined
    tSpr = getAt(undefined, tObjType)
    tSpr.visible = 0
  end repeat
  tRightMargin = 4
  repeat while tWndObj.getProperty(#spriteList) <= undefined
    tAction = getAt(undefined, tObjType)
    tElem = tWndObj.getElement(tAction & ".button")
    if tElem <> 0 then
      tSpr = tElem.getProperty(#sprite)
      tSpr.visible = 1
      tRightMargin = ((tRightMargin + tElem.getProperty(#width)) + 2)
      tSpr.locH = (the stage.rect.width - tRightMargin)
    end if
  end repeat
  if (tObjType = "user") and tCtrlType <> "personal" then
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
      if me.getComponent().getRoomID() <> "private" or (me.getComponent().getRoomData().getAt(#trading) = 0) then
        tWndObj.getElement("trade.button").deactivate()
      end if
      if not getObject(#session).get("user_rights").getOne("fuse_trade") then
        tWndObj.getElement("trade.button").deactivate()
      end if
    end if
  end if
  return TRUE
end

on hideInterface me, tHideOrRemove 
  if voidp(tHideOrRemove) then
    tHideOrRemove = #remove
  end if
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if (tHideOrRemove = #remove) then
      return(removeWindow(pInterfaceId))
    else
      return(tWndObj.hide())
    end if
  end if
  return FALSE
end

on showObjectInfo me, tObjType 
  tWndObj = getWindow(pInfoStandId)
  if not tWndObj then
    return FALSE
  end if
  if (tObjType = "user") then
    tObj = me.getComponent().getUserObject(pSelectedObj)
  else
    if (tObjType = "active") then
      tObj = me.getComponent().getActiveObject(pSelectedObj)
    else
      if (tObjType = "item") then
        tObj = me.getComponent().getItemObject(pSelectedObj)
      else
        if (tObjType = "pet") then
          tObj = me.getComponent().getUserObject(pSelectedObj)
        else
          error(me, "Unsupported object type:" && tObjType, #showObjectInfo)
          tObj = 0
        end if
      end if
    end if
  end if
  if (tObj = 0) then
    tProps = 0
  else
    tProps = tObj.getInfo()
  end if
  if listp(tProps) then
    tWndObj.getElement("bg_darken").show()
    tWndObj.getElement("info_name").show()
    tWndObj.getElement("info_text").show()
    tWndObj.getElement("info_name").setText(tProps.getAt(#name))
    tWndObj.getElement("info_text").setText(tProps.getAt(#custom))
    tElem = tWndObj.getElement("info_image")
    if (ilk(tProps.getAt(#image)) = #image) then
      tElem.resizeTo(tProps.getAt(#image).width, tProps.getAt(#image).height)
      tElem.getProperty(#sprite).member.regPoint = point((tProps.getAt(#image).width / 2), tProps.getAt(#image).height)
      tElem.feedImage(tProps.getAt(#image))
    end if
    me.updateInfoStandBadge(tProps.getAt(#badge))
    return TRUE
  else
    return(me.hideObjectInfo())
  end if
end

on hideObjectInfo me 
  if objectExists("BadgeEffect") then
    removeObject("BadgeEffect")
  end if
  if not windowExists(pInfoStandId) then
    return FALSE
  end if
  tWndObj = getWindow(pInfoStandId)
  tWndObj.getElement("info_image").clearImage()
  tWndObj.getElement("bg_darken").hide()
  tWndObj.getElement("info_name").hide()
  tWndObj.getElement("info_text").hide()
  tWndObj.getElement("info_badge").clearImage()
  return TRUE
end

on updateInfoStandBadge me, tBadgeID, tUserID 
  if objectExists(pBadgeObjID) then
    return(me.getBadgeObject().updateInfoStandBadge(pInfoStandId, pSelectedObj, tBadgeID, tUserID))
  end if
end

on showArrowHiliter me, tUserID 
  return(me.getArrowHiliter().show(tUserID))
end

on hideArrowHiliter me 
  return(me.getArrowHiliter().hide())
end

on showDoorBell me, tName 
  tOwnUser = me.getComponent().getOwnUser()
  if (tOwnUser = 0) then
    return(error(me, "Own user not found!", #showDoorBell))
  end if
  if (tOwnUser.getInfo().ctrl = 0) then
    return TRUE
  end if
  if objectExists(pDoorBellID) then
    return(getObject(pDoorBellID).addDoorbellRinger(tName))
  end if
end

on hideDoorBell me 
  if objectExists(pDoorBellID) then
    getObject(pDoorBellID).hideDoorBell()
  end if
end

on roomEnterDoorBell me, tName 
  if objectExists(pDoorBellID) then
    getObject(pDoorBellID).removeFromList(tName)
  end if
end

on showLoaderBar me, tCastLoadId, tText 
  if not windowExists(pLoaderBarID) then
    tSession = getObject(#session)
    if getObject(#session).exists("ad_memnum") then
      tShowAd = 1
      tWindowType = "room_loader.window"
      tAdText = string(tSession.get("ad_text"))
      pBannerLink = string(tSession.get("ad_link"))
      tAdMember = member(tSession.get("ad_memnum"))
      if (tAdMember.type = #bitmap) then
        tAdImage = tAdMember.image
      else
        tAdImage = image(1, 1, 8)
      end if
    else
      tShowAd = 0
      tWindowType = "room_loader_small.window"
      pBannerLink = 0
    end if
    createWindow(pLoaderBarID, "habbo_simple.window")
    tWndObj = getWindow(pLoaderBarID)
    tWndObj.merge(tWindowType)
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
    if tShowAd then
      tWndObj.getElement("room_banner_pic").feedImage(tAdImage)
      tWndObj.getElement("room_banner_link").setText(tAdText)
      if pBannerLink <> 0 then
        tWndObj.getElement("room_banner_link").setProperty(#cursor, "cursor.arrow")
      else
        tWndObj.getElement("room_banner_link").setProperty(#cursor, 0)
      end if
      if connectionExists(pInfoConnID) then
        getConnection(pInfoConnID).send("ADVIEW", getObject(#session).get("ad_id"))
      end if
    end if
  else
    tWndObj = getWindow(pLoaderBarID)
  end if
  if not voidp(tCastLoadId) then
    tBuffer = tWndObj.getElement("gen_loaderbar").getProperty(#buffer).image
    showLoadingBar(tCastLoadId, [#buffer:tBuffer, #bgColor:rgb(255, 255, 255)])
  end if
  if stringp(tText) then
    tWndObj.getElement("general_loader_text").setText(tText)
  end if
  return TRUE
end

on hideLoaderBar me 
  if windowExists(pLoaderBarID) then
    removeWindow(pLoaderBarID)
  end if
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
    pCoverSpr.width = the stage.rect.width
    pCoverSpr.height = the stage.rect.height
    pCoverSpr.locZ = tlocz
    pCoverSpr.blend = 100
    setEventBroker(pCoverSpr.spriteNum, "Trash Cover")
    updateStage()
  end if
end

on hideTrashCover me 
  if not voidp(pCoverSpr) then
    releaseSprite(pCoverSpr.spriteNum)
    pCoverSpr = void()
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
  me.hideRoom()
  me.hideRoomBar()
  me.hideInfoStand()
  me.hideInterface(#remove)
  me.hideConfirmDelete()
  me.hideConfirmPlace()
  me.hideDoorBell()
  me.hideLoaderBar()
  me.hideTrashCover()
  me.hideLoaderBar()
  return TRUE
end

on getRoomVisualizer me 
  return(getVisualizer(pRoomSpaceId))
end

on getGeometry me 
  return(getObject(pGeometryId))
end

on getHiliter me 
  return(getObject(pHiliterId))
end

on getContainer me 
  return(getObject(pContainerID))
end

on getSafeTrader me 
  return(getObject(pSafeTraderID))
end

on getArrowHiliter me 
  return(getObject(pArrowObjID))
end

on getBadgeObject me 
  return(getObject(pBadgeObjID))
end

on getObjectMover me 
  return(getObject(pObjMoverID))
end

on getSelectedObject me 
  return(pSelectedObj)
end

on getProperty me, tPropID 
  if (tPropID = #clickAction) then
    return(pClickAction)
  else
    return FALSE
  end if
end

on setProperty me, tPropID, tValue 
  if (tPropID = #clickAction) then
    pClickAction = tValue
  else
    return FALSE
  end if
end

on cancelObjectMover me 
  tMoverObj = me.getObjectMover()
  if not (tMoverObj = 0) then
    tMoverObj.cancelMove()
  end if
  return(me.stopObjectMover())
end

on notify me, ttype 
  if (ttype = 400) then
    executeMessage(#alert, [#msg:"room_cant_trade"])
  else
    if (ttype = 401) then
      executeMessage(#alert, [#msg:"room_max_pet_limit"])
    else
      if (ttype = 402) then
        executeMessage(#alert, [#msg:"room_cant_set_item"])
      else
        if (ttype = 403) then
          executeMessage(#alert, [#msg:"wallitem_post.it.limit"])
        else
          if (ttype = 404) then
            executeMessage(#alert, [#msg:"queue_tile_limit"])
          end if
        end if
      end if
    end if
  end if
end

on setRollOverInfo me, tInfo 
  tWndObj = getWindow(pBottomBarId)
  if tWndObj <> 0 then
    tWndObj.getElement("room_tooltip_text").setText(tInfo)
  end if
end

on getIgnoreStatus me, tUserID 
  if me.getComponent().userObjectExists(tUserID) and objectp(pIgnoreListObj) then
    tName = me.getComponent().getUserObject(tUserID).getName()
    return(pIgnoreListObj.getIgnoreStatus(tName))
  else
    return FALSE
  end if
end

on uningoreAdmin me, tUserID, tBadge 
  if me.getComponent().userObjectExists(tUserID) and pModBadgeList.getOne(tBadge) > 0 then
    tName = me.getComponent().getUserObject(tUserID).getName()
    if objectp(pIgnoreListObj) then
      return(pIgnoreListObj.setIgnoreStatus(tName, 0))
    end if
  else
    return FALSE
  end if
end

on startObjectMover me, tObjID, tStripID 
  if not objectExists(pObjMoverID) then
    createObject(pObjMoverID, "Object Mover Class")
  end if
  if (pSelectedType = "active") then
    pClickAction = "moveActive"
  else
    if (pSelectedType = "item") then
      pClickAction = "moveItem"
    else
      if (pSelectedType = "user") then
        return(error(me, "Can't move user objects!", #startObjectMover))
      end if
    end if
  end if
  return(getObject(pObjMoverID).define(tObjID, tStripID, pSelectedType))
end

on stopObjectMover me 
  if not objectExists(pObjMoverID) then
    return(error(me, "Object mover not found!", #stopObjectMover))
  end if
  pClickAction = "moveHuman"
  pSelectedObj = ""
  pSelectedType = ""
  me.hideObjectInfo()
  me.hideInterface(#hide)
  getObject(pObjMoverID).clear()
  return TRUE
end

on startTrading me, tTargetUser 
  if pSelectedType <> "user" then
    return FALSE
  end if
  if (tTargetUser = getObject(#session).get("user_name")) then
    return FALSE
  end if
  me.getComponent().getRoomConnection().send("TRADE_OPEN", tTargetUser)
  if objectExists(pObjMoverID) then
    getObject(pObjMoverID).moveTrade()
  end if
  return TRUE
end

on stopTrading me 
  return(error(me, "TODO: stopTrading...!", #stopTrading))
  pClickAction = "moveHuman"
  if objectExists(pObjMoverID) then
    me.stopObjectMover()
  end if
  return TRUE
end

on showConfirmDelete me 
  if windowExists(pDelConfirmID) then
    return FALSE
  end if
  if not createWindow(pDelConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmDelete))
  end if
  tMsgA = getText("room_confirmDelete", "Confirm delete")
  tMsgB = getText("room_areYouSure", "Are you absolutely sure you want to delete this item?")
  tWndObj = getWindow(pDelConfirmID)
  if not tWndObj.merge("habbo_decision_dialog.window") then
    return(tWndObj.close())
  end if
  tWndObj.lock()
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcDelConfirm, me.getID(), #mouseUp)
  return TRUE
end

on hideConfirmDelete me 
  if windowExists(pDelConfirmID) then
    removeWindow(pDelConfirmID)
  end if
end

on showConfirmPlace me 
  if windowExists(pPlcConfirmID) then
    return FALSE
  end if
  if not createWindow(pPlcConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmPlace))
  end if
  tMsgA = getText("room_confirmPlace", "Confirm placement")
  tMsgB = getText("room_areYouSurePlace", "Are you absolutely sure you want to place this item?")
  tWndObj = getWindow(pPlcConfirmID)
  if not tWndObj.merge("habbo_decision_dialog.window") then
    return(tWndObj.close())
  end if
  tWndObj.lock()
  tWndObj.getElement("habbo_decision_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_decision_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPlcConfirm, me.getID(), #mouseUp)
  return TRUE
end

on hideConfirmPlace me 
  if windowExists(pPlcConfirmID) then
    removeWindow(pPlcConfirmID)
  end if
end

on placeFurniture me, tObjID, tObjType 
  if (tObjType = "active") then
    tloc = getObject(pObjMoverID).getProperty(#loc)
    if not tloc then
      return FALSE
    end if
    tObj = me.getComponent().getActiveObject(tObjID)
    if (tObj = 0) then
      return(error(me, "Invalid active object:" && tObjID, #placeFurniture))
    end if
    tStripID = tObj.getaProp(#stripId)
    tStr = tStripID && tloc.getAt(1) && tloc.getAt(2) && tObj.getProp(#pDimensions, 1) && tObj.getProp(#pDimensions, 2) && tObj.getProp(#pDirection, 1)
    me.getComponent().removeActiveObject(tObj.getAt(#id))
    me.getComponent().getRoomConnection().send("PLACESTUFF", tStr)
    me.getComponent().getRoomConnection().send("GETSTRIP", "new")
    return TRUE
  else
    if (tObjType = "item") then
      tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
      if not tloc then
        return FALSE
      end if
      tObj = me.getComponent().getItemObject(tObjID)
      if (tObj = 0) then
        return(error(me, "Invalid item object:" && tObjID, #placeFurniture))
      end if
      tStripID = tObj.getaProp(#stripId)
      tStr = tStripID && tloc
      me.getComponent().removeItemObject(tObj.getAt(#id))
      me.getComponent().getRoomConnection().send("PLACESTUFF", tStr)
      me.getComponent().getRoomConnection().send("GETSTRIP", "new")
      return TRUE
    else
      return FALSE
    end if
  end if
end

on updateMessageCount me, tMsgCount 
  if windowExists(pBottomBarId) then
    pNewMsgCount = value(tMsgCount)
    me.flashMessengerIcon()
  end if
  return TRUE
end

on updateBuddyrequestCount me, tReqCount 
  if windowExists(pBottomBarId) then
    pNewBuddyReq = value(tReqCount)
    me.flashMessengerIcon()
  end if
  return TRUE
end

on flashMessengerIcon me 
  tWndObj = getWindow(pBottomBarId)
  if (tWndObj = 0) then
    return FALSE
  end if
  if not tWndObj.elementExists("int_messenger_image") then
    return FALSE
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
        createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), void(), 0)
      end if
    else
      tmember = "mes_lite_icon"
      if timeoutExists(#flash_messenger_icon) then
        removeTimeout(#flash_messenger_icon)
      end if
    end if
  end if
  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
  return TRUE
end

on validateEvent me, tEvent, tSprID, tloc 
  if (call(#getID, sprite(the rollover).scriptInstanceList) = tSprID) then
    tSpr = sprite(the rollover)
    if (tSpr.member.type = #bitmap) and (tSpr.ink = 36) then
      tPixel = tSpr.member.image.getPixel((tloc.getAt(1) - tSpr.left), (tloc.getAt(2) - tSpr.top))
      if not tPixel then
        return FALSE
      end if
      if (tPixel.hexString() = "#FFFFFF") then
        tSpr.visible = 0
        tNextSpr = sprite(the rollover)
        tSpr.visible = 1
        call(tEvent, tNextSpr.scriptInstanceList)
        return FALSE
      else
        return TRUE
      end if
    else
      return TRUE
    end if
  else
    return TRUE
  end if
  return TRUE
end

on validateEvent2 me, tEvent, tSprID, tloc 
  if (call(#getID, sprite(the rollover).scriptInstanceList) = tSprID) then
    tSpr = sprite(the rollover)
    if (tSpr.member.type = #bitmap) and (tSpr.ink = 36) then
      tPixel = tSpr.member.image.getPixel((tloc.getAt(1) - tSpr.left), (tloc.getAt(2) - tSpr.top))
      if not tPixel then
        return FALSE
      end if
      if (tPixel.hexString() = "#FFFFFF") then
        tSpr.visible = 0
        call(tEvent, sprite(the rollover).scriptInstanceList)
        tSpr.visible = 1
        return FALSE
      else
        return TRUE
      end if
    else
      return TRUE
    end if
  else
    return TRUE
  end if
  return TRUE
end

on eventProcActiveRollOver me, tEvent, tSprID, tProp 
  if (me.getComponent().getRoomData().type = #private) then
    if (tEvent = #mouseEnter) then
      me.setRollOverInfo(me.getComponent().getActiveObject(tSprID).getCustom())
    else
      if (tEvent = #mouseLeave) then
        me.setRollOverInfo("")
      end if
    end if
  end if
end

on eventProcUserRollOver me, tEvent, tSprID, tProp 
  if (pClickAction = "placeActive") then
    if (tEvent = #mouseEnter) then
      me.showArrowHiliter(tSprID)
    else
      me.showArrowHiliter(void())
    end if
  end if
  if (tEvent = #mouseEnter) then
    tObject = me.getComponent().getUserObject(tSprID)
    if (tObject = 0) then
      return()
    end if
    me.setRollOverInfo(tObject.getInfo().getaProp(#name))
  else
    if (tEvent = #mouseLeave) then
      me.setRollOverInfo("")
    end if
  end if
end

on eventProcItemRollOver me, tEvent, tSprID, tProp 
  if (tEvent = #mouseEnter) then
    me.setRollOverInfo(me.getComponent().getItemObject(tSprID).getCustom())
  else
    if (tEvent = #mouseLeave) then
      me.setRollOverInfo("")
    end if
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam 
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = getWindow(pBottomBarId).getElement(tSprID)
    if the commandDown and (the keyCode = 8) or (the keyCode = 9) then
      if not getObject(#session).get("user_rights").getOne("fuse_debug_window") then
        tChatField.setText("")
        return TRUE
      end if
    end if
    if the keyCode <> 36 then
      if (the keyCode = 76) then
        if pFloodblocking then
          if the milliSeconds < pFloodTimer then
            return FALSE
          else
            pFloodEnterCount = void()
          end if
        end if
        if voidp(pFloodEnterCount) then
          pFloodEnterCount = 0
          pFloodblocking = 0
          pFloodTimer = the milliSeconds
        else
          pFloodEnterCount = (pFloodEnterCount + 1)
          if pFloodEnterCount > 2 then
            if the milliSeconds < (pFloodTimer + 3000) then
              tChatField.setText("")
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(pBottomBarId, tSprID, 30000)
              pFloodblocking = 1
              pFloodTimer = (the milliSeconds + 30000)
            else
              pFloodEnterCount = void()
            end if
          end if
        end if
        me.getComponent().sendChat(tChatField.getText())
        tChatField.setText("")
        return TRUE
      else
        if (the keyCode = 117) then
          tChatField.setText("")
        end if
      end if
      return FALSE
      if (getWindow(pBottomBarId).getElement(tSprID).getProperty(#blend) = 100) then
        if (the keyCode = "int_help_image") then
          if (tEvent = #mouseUp) then
            executeMessage(#openGeneralDialog, #help)
          end if
          if (tEvent = #mouseEnter) then
            tInfo = getText("interface_icon_help", "interface_icon_help")
            me.setRollOverInfo(tInfo)
          else
            if (tEvent = #mouseLeave) then
              me.setRollOverInfo("")
            end if
          end if
        else
          if (the keyCode = "int_hand_image") then
            if (tEvent = #mouseUp) then
              me.getContainer().openClose()
            end if
            if (tEvent = #mouseEnter) then
              tInfo = getText("interface_icon_hand", "interface_icon_hand")
              me.setRollOverInfo(tInfo)
            else
              if (tEvent = #mouseLeave) then
                me.setRollOverInfo("")
              end if
            end if
          else
            if (the keyCode = "int_brochure_image") then
              if (tEvent = #mouseUp) then
                executeMessage(#show_hide_catalogue)
              end if
              if (tEvent = #mouseEnter) then
                tInfo = getText("interface_icon_catalog", "interface_icon_catalog")
                me.setRollOverInfo(tInfo)
              else
                if (tEvent = #mouseLeave) then
                  me.setRollOverInfo("")
                end if
              end if
            else
              if (the keyCode = "int_purse_image") then
                if (tEvent = #mouseUp) then
                  executeMessage(#openGeneralDialog, #purse)
                end if
                if (tEvent = #mouseEnter) then
                  tInfo = getText("interface_icon_purse", "interface_icon_purse")
                  me.setRollOverInfo(tInfo)
                else
                  if (tEvent = #mouseLeave) then
                    me.setRollOverInfo("")
                  end if
                end if
              else
                if (the keyCode = "int_nav_image") then
                  if (tEvent = #mouseUp) then
                    executeMessage(#show_hide_navigator)
                  end if
                  if (tEvent = #mouseEnter) then
                    tInfo = getText("interface_icon_navigator", "interface_icon_navigator")
                    me.setRollOverInfo(tInfo)
                  else
                    if (tEvent = #mouseLeave) then
                      me.setRollOverInfo("")
                    end if
                  end if
                else
                  if (the keyCode = "int_messenger_image") then
                    if (tEvent = #mouseUp) then
                      executeMessage(#show_hide_messenger)
                    end if
                    if (tEvent = #mouseEnter) then
                      tInfo = getText("interface_icon_messenger", "interface_icon_messenger")
                      me.setRollOverInfo(tInfo)
                    else
                      if (tEvent = #mouseLeave) then
                        me.setRollOverInfo("")
                      end if
                    end if
                  else
                    if (the keyCode = "int_hand_image") then
                      if (tEvent = #mouseUp) then
                        me.getContainer().openClose()
                      end if
                    else
                      if (the keyCode = "get_credit_text") then
                        if (tEvent = #mouseUp) then
                          executeMessage(#openGeneralDialog, #purse)
                        end if
                      else
                        if (the keyCode = "int_speechmode_dropmenu") then
                          if (tEvent = #mouseUp) then
                            me.getComponent().setChatMode(tParam)
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcInfoStand me, tEvent, tSprID, tParam 
  if (tSprID = "info_badge") then
    tSession = getObject(#session)
    if (me.getSelectedObject() = tSession.get("user_index")) then
      if objectExists(pBadgeObjID) then
        getObject(pBadgeObjID).toggleOwnBadgeVisibility()
      end if
    end if
  end if
  return TRUE
end

on eventProcInterface me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp or pClickAction <> "moveHuman" then
    return FALSE
  end if
  tComponent = me.getComponent()
  if not tComponent.userObjectExists(pSelectedObj) then
    if not tComponent.activeObjectExists(pSelectedObj) then
      if not tComponent.itemObjectExists(pSelectedObj) then
        return(me.hideInterface(#hide))
      end if
    end if
  end if
  tOwnUser = tComponent.getOwnUser()
  if (tOwnUser = 0) then
    return(error(me, "Own user not found!", #eventProcInterface))
  end if
  if (tSprID = "dance.button") then
    if tOwnUser.getProperty(#dancing) then
      tComponent.getRoomConnection().send("STOP", "Dance")
    else
      tComponent.getRoomConnection().send("STOP", "CarryDrink")
      tComponent.getRoomConnection().send("DANCE")
    end if
    return TRUE
  else
    if (tSprID = "wave.button") then
      if tOwnUser.getProperty(#dancing) then
        tComponent.getRoomConnection().send("STOP", "Dance")
      end if
      return(tComponent.getRoomConnection().send("WAVE"))
    else
      if (tSprID = "move.button") then
        return(me.startObjectMover(pSelectedObj))
      else
        if (tSprID = "rotate.button") then
          return(tComponent.getActiveObject(pSelectedObj).rotate())
        else
          if (tSprID = "pick.button") then
            if (tSprID = "active") then
              ttype = "stuff"
            else
              if (tSprID = "item") then
                ttype = "item"
              else
                return(me.hideInterface(#hide))
              end if
            end if
            return(tComponent.getRoomConnection().send("ADDSTRIPITEM", "new" && ttype && pSelectedObj))
          else
            if (tSprID = "delete.button") then
              pDeleteObjID = pSelectedObj
              pDeleteType = pSelectedType
              return(me.showConfirmDelete())
            else
              if (tSprID = "kick.button") then
                if tComponent.userObjectExists(pSelectedObj) then
                  tUserName = tComponent.getUserObject(pSelectedObj).getName()
                else
                  tUserName = ""
                end if
                tComponent.getRoomConnection().send("KICKUSER", tUserName)
                return(me.hideInterface(#hide))
              else
                if (tSprID = "give_rights.button") then
                  if tComponent.userObjectExists(pSelectedObj) then
                    tUserName = tComponent.getUserObject(pSelectedObj).getName()
                  else
                    tUserName = ""
                  end if
                  tComponent.getRoomConnection().send("ASSIGNRIGHTS", tUserName)
                  pSelectedObj = ""
                  me.hideObjectInfo()
                  me.hideInterface(#hide)
                  me.hideArrowHiliter()
                  return TRUE
                else
                  if (tSprID = "take_rights.button") then
                    if tComponent.userObjectExists(pSelectedObj) then
                      tUserName = tComponent.getUserObject(pSelectedObj).getName()
                    else
                      tUserName = ""
                    end if
                    tComponent.getRoomConnection().send("REMOVERIGHTS", tUserName)
                    pSelectedObj = ""
                    me.hideObjectInfo()
                    me.hideInterface(#hide)
                    me.hideArrowHiliter()
                    return TRUE
                  else
                    if (tSprID = "friend.button") then
                      if tComponent.userObjectExists(pSelectedObj) then
                        tUserName = tComponent.getUserObject(pSelectedObj).getName()
                      else
                        tUserName = ""
                      end if
                      executeMessage(#externalBuddyRequest, tUserName)
                      return TRUE
                    else
                      if (tSprID = "trade.button") then
                        if tComponent.userObjectExists(pSelectedObj) then
                          tUserName = tComponent.getUserObject(pSelectedObj).getName()
                        else
                          tUserName = ""
                        end if
                        me.startTrading(pSelectedObj)
                        me.getContainer().open()
                        return TRUE
                      else
                        if (tSprID = "ignore.button") then
                          if tComponent.userObjectExists(pSelectedObj) then
                            tUserName = tComponent.getUserObject(pSelectedObj).getName()
                            pIgnoreListObj.setIgnoreStatus(tUserName, 1)
                          end if
                          me.hideInterface(#hide)
                          pSelectedObj = ""
                        else
                          if (tSprID = "unignore.button") then
                            if tComponent.userObjectExists(pSelectedObj) then
                              tUserName = tComponent.getUserObject(pSelectedObj).getName()
                              pIgnoreListObj.setIgnoreStatus(tUserName, 0)
                            end if
                            me.hideInterface(#hide)
                            pSelectedObj = ""
                          else
                            if (tSprID = "badge.button") then
                              if objectExists(pBadgeObjID) then
                                getObject(pBadgeObjID).openBadgeWindow()
                              end if
                            else
                              return(error(me, "Unknown object interface command:" && tSprID, #eventProcInterface))
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcRoom me, tEvent, tSprID, tParam 
  if (tEvent = #mouseUp) and tSprID contains "command:" then
    tCmd = convertToHigherCase(tSprID.getProp(#word, 2))
    tPrm = [:]
    if (tCmd = "MOVE") then
      tPrm = [#short:integer(tSprID.getProp(#word, 3)), #short:integer(tSprID.getProp(#word, 4))]
    else
      if (tCmd = "GOAWAY") then
        tPrm = [:]
      else
        error(me, "Is this command valid:" && tCmd & "?", #eventProcRoom)
      end if
    end if
    return(me.getComponent().getRoomConnection().send(tCmd, tPrm))
  end if
  if (tEvent = #mouseDown) then
    if (tCmd = "moveHuman") then
      if tParam <> "object_selection" then
        pSelectedObj = ""
        me.hideObjectInfo()
        me.hideInterface(#hide)
        me.hideArrowHiliter()
      end if
      tloc = me.getGeometry().getWorldCoordinate(the mouseH, the mouseV)
      if listp(tloc) then
        return(me.getComponent().getRoomConnection().send("MOVE", [#short:tloc.getAt(1), #short:tloc.getAt(2)]))
      end if
    else
      if (tCmd = "moveActive") then
        tloc = getObject(pObjMoverID).getProperty(#loc)
        if not tloc then
          return FALSE
        end if
        tObj = me.getComponent().getActiveObject(pSelectedObj)
        if (tObj = 0) then
          return(error(me, "Invalid active object:" && pSelectedObj, #eventProcRoom))
        end if
        me.getComponent().getRoomConnection().send("MOVESTUFF", pSelectedObj && tloc.getAt(1) && tloc.getAt(2) && tObj.getProp(#pDirection, 1))
        me.stopObjectMover()
      else
        if (tCmd = "placeActive") then
          if getObject(#session).get("room_controller") or getObject(#session).get("user_rights").getOne("fuse_any_room_controller") then
            tCanPlace = 1
          end if
          if not tCanPlace then
            return FALSE
          end if
          if getObject(#session).get("room_owner") then
            me.placeFurniture(pSelectedObj, pSelectedType)
            me.hideInterface(#hide)
            me.hideObjectInfo()
            me.stopObjectMover()
          else
            if not getObject(#session).get("user_rights").getOne("fuse_trade") then
              return FALSE
            end if
            tloc = getObject(pObjMoverID).getProperty(#loc)
            if not tloc then
              return FALSE
            end if
            if me.showConfirmPlace() then
              me.getObjectMover().pause()
            end if
          end if
        else
          if (tCmd = "placeItem") then
            if getObject(#session).get("room_controller") or getObject(#session).get("user_rights").getOne("fuse_any_room_controller") then
              tCanPlace = 1
            end if
            if not tCanPlace then
              return FALSE
            end if
            if getObject(#session).get("room_owner") then
              if me.placeFurniture(pSelectedObj, pSelectedType) then
                me.hideInterface(#hide)
                me.hideObjectInfo()
                me.stopObjectMover()
              end if
            else
              if not getObject(#session).get("user_rights").getOne("fuse_trade") then
                return FALSE
              end if
              tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
              if not tloc then
                return FALSE
              end if
              if me.showConfirmPlace() then
                me.getObjectMover().pause()
              end if
            end if
          else
            if (tCmd = "tradeItem") then
            else
              return(error(me, "Unsupported click action:" && pClickAction, #eventProcRoom))
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcUserObj me, tEvent, tSprID, tParam 
  tObject = me.getComponent().getUserObject(tSprID)
  if (tObject = 0) then
    error(me, "User object not found:" && tSprID, #eventProcUserObj)
    return(me.eventProcRoom(tEvent, "floor"))
  end if
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "user", the rollover))
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if tObject.select() then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = tObject.getClass()
      me.showObjectInfo(pSelectedType)
      me.showInterface(pSelectedType)
      me.showArrowHiliter(tSprID)
    end if
    tloc = tObject.getLocation()
    me.getComponent().getRoomConnection().send("LOOKTO", tloc.getAt(1) && tloc.getAt(2))
  else
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
  end if
  return TRUE
end

on eventProcActiveObj me, tEvent, tSprID, tParam 
  if not me.validateEvent2(tEvent, tSprID, the mouseLoc) then
    return FALSE
  end if
  tObject = me.getComponent().getActiveObject(tSprID)
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "active", the rollover))
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (tObject = 0) then
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
    return(error(me, "Active object not found:" && tSprID, #eventProcActiveObj))
  end if
  if (me.getComponent().getRoomData().type = #private) then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = "active"
      me.showObjectInfo(pSelectedType)
      me.showInterface(pSelectedType)
      me.hideArrowHiliter()
    end if
  end if
  tIsController = getObject(#session).get("room_controller")
  if getObject(#session).get("user_rights").getOne("fuse_any_room_controller") then
    tIsController = 1
  end if
  if the optionDown and tIsController then
    return(me.startObjectMover(pSelectedObj))
  end if
  if tObject.select() then
    return TRUE
  else
    return(me.eventProcRoom(tEvent, "floor", "object_selection"))
  end if
end

on eventProcPassiveObj me, tEvent, tSprID, tParam 
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    pass()
  end if
  tObject = me.getComponent().getPassiveObject(tSprID)
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "passive", the rollover))
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (tObject = 0) then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if not tObject.select() then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
end

on eventProcItemObj me, tEvent, tSprID, tParam 
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return FALSE
  end if
  if the shiftDown then
    if me.getComponent().itemObjectExists(tSprID) then
      return(me.outputObjectInfo(tSprID, "item", the rollover))
    end if
  end if
  if (pClickAction = "moveActive") or (pClickAction = "placeActive") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if (pClickAction = "moveItem") or (pClickAction = "placeItem") then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if not me.getComponent().itemObjectExists(tSprID) then
    pSelectedObj = ""
    pSelectedType = ""
    me.hideObjectInfo()
    me.hideInterface(#hide)
    me.hideArrowHiliter()
    return(error(me, "Item object not found:" && tSprID, #eventProcItemObj))
  end if
  if me.getComponent().getItemObject(tSprID).select() then
    if pSelectedObj <> tSprID then
      pSelectedObj = tSprID
      pSelectedType = "item"
      me.showObjectInfo(pSelectedType)
      me.showInterface(pSelectedType)
      me.hideArrowHiliter()
    end if
  else
    pSelectedObj = tSprID
    pSelectedType = "item"
    me.showObjectInfo(pSelectedType)
    me.hideInterface(#hide)
    me.hideArrowHiliter()
  end if
end

on eventProcDelConfirm me, tEvent, tSprID, tParam 
  if (tSprID = "habbo_decision_ok") then
    me.hideConfirmDelete()
    if (tSprID = "active") then
      me.getComponent().getRoomConnection().send("REMOVESTUFF", pDeleteObjID)
    else
      if (tSprID = "item") then
        me.getComponent().getRoomConnection().send("REMOVEITEM", pDeleteObjID)
      end if
    end if
    me.hideInterface(#hide)
    me.hideObjectInfo()
    pDeleteObjID = ""
    pDeleteType = ""
  else
    if tSprID <> "habbo_decision_cancel" then
      if (tSprID = "close") then
        me.hideConfirmDelete()
        pDeleteObjID = ""
      end if
    end if
  end if
end

on eventProcPlcConfirm me, tEvent, tSprID, tParam 
  if (tSprID = "habbo_decision_ok") then
    me.placeFurniture(pSelectedObj, pSelectedType)
    me.hideConfirmPlace()
    me.hideInterface(#hide)
    me.hideObjectInfo()
    me.stopObjectMover()
  else
    if tSprID <> "habbo_decision_cancel" then
      if (tSprID = "close") then
        me.getObjectMover().resume()
        me.hideConfirmPlace()
      end if
    end if
  end if
end

on eventProcBanner me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp then
    return FALSE
  end if
  if (tSprID = "room_banner_link") then
    if pBannerLink <> 0 then
      if connectionExists(pInfoConnID) and getObject(#session).exists("ad_id") then
        getConnection(pInfoConnID).send("ADCLICK", getObject(#session).get("ad_id"))
      end if
      openNetPage(pBannerLink)
    end if
  else
    if (tSprID = "room_cancel") then
      me.getComponent().getRoomConnection().send("QUIT")
      executeMessage(#leaveRoom)
    end if
  end if
  return TRUE
end

on outputObjectInfo me, tSprID, tObjType, tSprNum 
  if (tObjType = "user") then
    tObj = me.getComponent().getUserObject(tSprID)
  else
    if (tObjType = "active") then
      tObj = me.getComponent().getActiveObject(tSprID)
    else
      if (tObjType = "passive") then
        tObj = me.getComponent().getPassiveObject(tSprID)
      else
        if (tObjType = "item") then
          tObj = me.getComponent().getItemObject(tSprID)
        end if
      end if
    end if
  end if
  if (tObj = 0) then
    return FALSE
  end if
  tInfo = tObj.getInfo()
  tdata = [:]
  tdata.setAt(#id, tObj.getID())
  tdata.setAt(#class, tInfo.getAt(#class))
  tdata.setAt(#x, tObj.pLocX)
  tdata.setAt(#y, tObj.pLocY)
  tdata.setAt(#h, tObj.pLocH)
  tdata.setAt(#dir, tObj.pDirection)
  tdata.setAt(#locH, sprite(tSprNum).locH)
  tdata.setAt(#locV, sprite(tSprNum).locV)
  tdata.setAt(#locZ, "")
  tSprList = tObj.getSprites()
  repeat while tObjType <= tObjType
    tSpr = getAt(tObjType, tSprID)
    tdata.setAt(#locZ, tdata.getAt(#locZ) && tSpr.locZ)
  end repeat
  put("- - - - - - - - - - - - - - - - - - - - - -")
  put("ID       " & tdata.getAt(#id))
  put("Class    " & tdata.getAt(#class))
  put("Member   " & sprite(tSprNum).member.name)
  put("World X  " & tdata.getAt(#x))
  put("World Y  " & tdata.getAt(#y))
  put("World H  " & tdata.getAt(#h))
  put("Dir      " & tdata.getAt(#dir))
  put("Scr X    " & tdata.getAt(#locH))
  put("Scr Y    " & tdata.getAt(#locV))
  put("Scr Z    " & tdata.getAt(#locZ))
  put("- - - - - - - - - - - - - - - - - - - - - -")
end

on null me 
end
