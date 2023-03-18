property pInfoConnID, pRoomConnID, pGeometryId, pHiliterId, pContainerID, pSafeTraderID, pObjMoverID, pArrowObjID, pBadgeObjID, pDoorBellID, pRoomSpaceId, pInterfaceId, pDelConfirmID, pPlcConfirmID, pLoaderBarID, pDeleteObjID, pDeleteType, pModBadgeList, pClickAction, pSelectedObj, pSelectedType, pCoverSpr, pRingingUser, pVisitorQueue, pBannerLink, pLoadingBarID, pQueueCollection, pSwapAnimations, pTradeTimeout, pRoomGuiID, pInfoStandId, pIgnoreListID, pWideScreenOffset

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
  pIgnoreListID = "Room_ignore_list"
  pRoomGuiID = "Room_gui_program"
  pRoomSpaceId = "Room_visualizer"
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
  createObject(pRoomGuiID, "Room GUI Class")
  createObject(pInfoStandId, "Info Stand Class")
  createObject(pIgnoreListID, "Ignore List Class")
  getObject(pObjMoverID).setProperty(#geometry, getObject(pGeometryId))
  registerMessage(#objectFinalized, me.getID(), #objectFinalized)
  if (the stage).rect.width > 800 then
    pWideScreenOffset = getVariable("widescreen.offset.x")
  else
    pWideScreenOffset = 0
  end if
  return 1
end

on deconstruct me
  pClickAction = #null
  removeObject(pBadgeObjID)
  removeObject(pDoorBellID)
  removeObject(pInfoStandId)
  removeObject(pIgnoreListID)
  removeObject(pRoomGuiID)
  return me.hideAll()
end

on showRoom me, tRoomID
  if not memberExists(tRoomID & ".room") then
    return error(me, "Room recording data member not found, check recording label name. Tried to find" && tRoomID & ".room", #showRoom, #major)
  end if
  me.showTrashCover()
  if windowExists(pLoaderBarID) then
    activateWindow(pLoaderBarID)
  end if
  tRoomField = tRoomID & ".room"
  if pWideScreenOffset > 0 then
    if variableExists(tRoomID & ".wide.offset.x") then
      pWideScreenOffset = value(getVariable(tRoomID & ".wide.offset.x"))
    end if
  end if
  if variableExists(tRoomID & ".wide.align.right") then
    if value(getVariable(tRoomID & ".wide.align.right")) then
      pWideScreenOffset = (the stage).rect.width - 720 - pWideScreenOffset
    end if
  end if
  createVisualizer(pRoomSpaceId, tRoomField, pWideScreenOffset)
  tVisObj = getVisualizer(pRoomSpaceId)
  tLocX = tVisObj.getProperty(#locX)
  tLocY = tVisObj.getProperty(#locY)
  tlocz = tVisObj.getProperty(#locZ)
  tdata = getObject(#layout_parser).parse(tRoomField).roomdata[1]
  tdata[#offsetz] = tlocz
  tdata[#offsetx] = tdata[#offsetx] + pWideScreenOffset
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
    error(me, "Hiliter not found in room description!!!", #showRoom, #minor)
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
        error(me, "Error creating swap animation", #showRoom, #minor)
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
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and (not tGUI = 0) then
    tGUI.showRoomBar()
  end if
end

on hideRoomBar me
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and (not tGUI = 0) then
    tGUI.hideRoomBar()
  end if
end

on showVote me
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and (not tGUI = 0) then
    tGUI.showVote()
  end if
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
    return error(me, "Own user not found!", #showDoorBell, #major)
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
  if tAdMember.type = #bitmap then
    tAdImage = image(tAdWidth, tAdHeight, 32)
    tAdImage.copyPixels(tAdMember.image, rect(0, 0, tAdWidth, tAdHeight), rect(0, 0, tAdWidth, tAdHeight))
  end if
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
  if objectExists(pRoomGuiID) then
    getObject(pRoomGuiID).hideInfoStand()
  end if
  me.hideRoom()
  me.hideRoomBar()
  me.hideConfirmDelete()
  me.hideConfirmPlace()
  me.hideDoorBellDialog()
  me.hideLoaderBar()
  me.hideTrashCover()
  me.hideLoaderBar()
  executeMessage(#roomInterfaceHidden)
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

on getIgnoreListObject me
  return getObject(pIgnoreListID)
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

on getProperty me, tPropID
  case tPropID of
    #clickAction:
      return pClickAction
    #widescreenoffset:
      return pWideScreenOffset
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
    406:
      executeMessage(#alert, [#Msg: "room_sound_furni_limit"])
  end case
end

on getIgnoreStatus me, tUserID, tName
  tIgnoreListObj = me.getIgnoreListObject()
  if not objectp(tIgnoreListObj) then
    return 0
  end if
  if not voidp(tName) then
    return tIgnoreListObj.getIgnoreStatus(tName)
  end if
  if me.getComponent().userObjectExists(tUserID) then
    tName = me.getComponent().getUserObject(tUserID).getName()
    return tIgnoreListObj.getIgnoreStatus(tName)
  else
    return 0
  end if
end

on unignoreAdmin me, tUserID, tBadge
  tIgnoreListObj = me.getIgnoreListObject()
  if me.getComponent().userObjectExists(tUserID) and (pModBadgeList.getOne(tBadge) > 0) then
    tName = me.getComponent().getUserObject(tUserID).getName()
    if objectp(tIgnoreListObj) then
      return tIgnoreListObj.setIgnoreStatus(tName, 0)
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
    otherwise:
      return error(me, "Object type" && pSelectedType && "can't be moved.", #startObjectMover, #minor)
  end case
  return getObject(pObjMoverID).define(tObjID, tStripID, pSelectedType, tProps)
end

on stopObjectMover me
  if not objectExists(pObjMoverID) then
    return error(me, "Object mover not found!", #stopObjectMover, #minor)
  end if
  getObject(pObjMoverID).clear()
  pClickAction = "moveHuman"
  pSelectedObj = EMPTY
  pSelectedType = EMPTY
  executeMessage(#hideObjectInfo)
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
  return error(me, "TODO: stopTrading...!", #stopTrading, #minor)
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
    return error(me, "Couldn't create confirmation window!", #showConfirmDelete, #major)
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
    return error(me, "Couldn't create confirmation window!", #showConfirmPlace, #major)
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
        return error(me, "Invalid active object:" && tObjID, #placeFurniture, #major)
      end if
      tStripID = tObj.getaProp(#stripId)
      tStr = tStripID && tloc[1] && tloc[2] && tObj.pDirection[1]
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
        return error(me, "Invalid item object:" && tObjID, #placeFurniture, #major)
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

on setSpeechDropdown me, tMode
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and (not tGUI = 0) then
    tGUI.setSpeechDropdown(tMode)
  end if
end

on showCfhSenderDelayed me, tID
  return createTimeout(#highLightCfhSender, 3000, #highLightCfhSender, me.getID(), tID, 1)
end

on highLightCfhSender me, tID
  if not voidp(tID) then
    me.showArrowHiliter(tID)
  end if
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

on objectFinalized me, tID
  if pSelectedObj = tID then
    executeMessage(#hideObjectInfo)
  end if
end

on showRemoveSpecsNotice me
  executeMessage(#alert, [#Msg: "room_remove_specs", #modal: 1])
end

on eventProcActiveRollOver me, tEvent, tSprID, tProp
  tGUI = getObject(pRoomGuiID)
  if voidp(tGUI) or (tGUI = 0) then
    return 0
  end if
  if me.getComponent().getRoomData().type = #private then
    if tEvent = #mouseEnter then
      tGUI.setRollOverInfo(me.getComponent().getActiveObject(tSprID).getCustom())
    else
      if tEvent = #mouseLeave then
        tGUI.setRollOverInfo(EMPTY)
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
  tGUI = getObject(pRoomGuiID)
  if voidp(tGUI) or (tGUI = 0) then
    return 0
  end if
  if tEvent = #mouseEnter then
    tObject = me.getComponent().getUserObject(tSprID)
    if tObject = 0 then
      return 
    end if
    tGUI.setRollOverInfo(tObject.getInfo().getaProp(#name))
  else
    if tEvent = #mouseLeave then
      tGUI.setRollOverInfo(EMPTY)
    end if
  end if
end

on eventProcItemRollOver me, tEvent, tSprID, tProp
  tGUI = getObject(pRoomGuiID)
  if voidp(tGUI) or (tGUI = 0) then
    return 0
  end if
  if tEvent = #mouseEnter then
    tGUI.setRollOverInfo(me.getComponent().getItemObject(tSprID).getCustom())
  else
    if tEvent = #mouseLeave then
      tGUI.setRollOverInfo(EMPTY)
    end if
  end if
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
        error(me, "Is this command valid:" && tCmd & "?", #eventProcRoom, #minor)
    end case
    return me.getComponent().getRoomConnection().send(tCmd, tPrm)
  end if
  tDragging = 0
  if (tEvent = #mouseDown) or tDragging then
    case pClickAction of
      "moveHuman":
        if tParam <> "object_selection" then
          pSelectedObj = EMPTY
          executeMessage(#hideObjectInfo)
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
          return error(me, "Invalid active object:" && pSelectedObj, #eventProcRoom, #major)
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
          executeMessage(#hideObjectInfo)
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
            executeMessage(#hideObjectInfo)
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
        return error(me, "Unsupported click action:" && pClickAction, #eventProcRoom, #minor)
    end case
  end if
end

on eventProcUserObj me, tEvent, tSprID, tParam
  tObject = me.getComponent().getUserObject(tSprID)
  if tObject = 0 then
    error(me, "User object not found:" && tSprID, #eventProcUserObj, #major)
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
    if (tObject.getClass() = "user") and (tEvent = #mouseDown) then
      executeMessage(#tutorial_userClicked)
    end if
    pSelectedObj = tSprID
    pSelectedType = tObject.getClass()
    if tParam <> #userEnters then
      executeMessage(#showObjectInfo, pSelectedType)
    end if
    me.showArrowHiliter(tSprID)
    tloc = tObject.getLocation()
    if tParam = #userEnters then
      tloc[1] = tloc[1] + 4
    end if
    if (tObject <> me.getComponent().getOwnUser()) or (tObject.getProperty(#moving) or (tParam = #userEnters)) then
      me.getComponent().getRoomConnection().send("LOOKTO", tloc[1] && tloc[2])
    end if
  else
    pSelectedObj = EMPTY
    pSelectedType = EMPTY
    executeMessage(#hideObjectInfo)
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
    executeMessage(#hideObjectInfo)
    me.hideArrowHiliter()
    return error(me, "Active object not found:" && tSprID, #eventProcActiveObj, #major)
  end if
  if me.getComponent().getRoomData().type = #private then
    pSelectedObj = tSprID
    pSelectedType = "active"
    executeMessage(#showObjectInfo, pSelectedType)
    me.hideArrowHiliter()
  end if
  tIsController = getObject(#session).GET("room_controller")
  if getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
    tIsController = 1
  end if
  if the optionDown and tIsController then
    return me.startObjectMover(pSelectedObj)
  end if
  tTemp = call(#select, tObject)
  if tTemp then
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
    executeMessage(#hideObjectInfo)
    me.hideArrowHiliter()
    return error(me, "Item object not found:" && tSprID, #eventProcItemObj, #major)
  end if
  if me.getComponent().getItemObject(tSprID).select() then
    pSelectedObj = tSprID
    pSelectedType = "item"
    executeMessage(#showObjectInfo, pSelectedType)
    me.hideArrowHiliter()
  else
    pSelectedObj = tSprID
    pSelectedType = "item"
    executeMessage(#showObjectInfo, pSelectedType)
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
      executeMessage(#hideObjectInfo)
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
      executeMessage(#hideObjectInfo)
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
