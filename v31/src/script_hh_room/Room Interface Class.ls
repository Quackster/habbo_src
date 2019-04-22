on construct(me)
  pInfoConnID = getVariable("connection.info.id", #info)
  pRoomConnID = getVariable("connection.room.id", #info)
  pObjMoverID = "Room_obj_mover"
  pHiliterId = "Room_hiliter"
  pGeometryId = "Room_geometry"
  pContainerID = "Room_container"
  pSafeTraderID = "Room_safe_trader"
  pArrowObjID = "Room_arrow_hilite"
  pDoorBellID = "Room_doorbell"
  pPreviewObjID = "Preview_renderer"
  pIgnoreListID = "Room_ignore_list"
  pRoomGuiID = "Room_gui_program"
  pRespectMgrID = "Room_respect_manager"
  pSongSelectorID = "Performer_song_selector"
  pJudgeToolID = "Judge_tool"
  pRoomSpaceId = "Room_visualizer"
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
  pSwapAnimations = []
  pTradeTimeout = 0
  pWIndowText = void()
  pLoadingBarID = 0
  pQueueCollection = []
  pModBadgeList = getVariableValue("moderator.badgelist")
  createObject(pGeometryId, "Room Geometry Class")
  createObject(pContainerID, "Container Hand Class")
  createObject(pSafeTraderID, "Safe Trader Class")
  createObject(pArrowObjID, "Select Arrow Class")
  createObject(pObjMoverID, "Object Mover Class")
  createObject(pPreviewObjID, "Preview Renderer Class")
  createObject(pDoorBellID, "Doorbell Class")
  createObject(pRoomGuiID, "Room GUI Class")
  createObject(pIgnoreListID, "Ignore List Class")
  createObject(pRespectMgrID, "Respect Manager Class")
  getObject(pObjMoverID).setProperty(#geometry, getObject(pGeometryId))
  registerMessage(#notify, me.getID(), #notify)
  registerMessage(#objectFinalized, me.getID(), #objectFinalized)
  me.updateScreenOffset()
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#objectFinalized, me.getID())
  unregisterMessage(#notify, me.getID())
  pClickAction = #null
  removeObject(pGeometryId)
  removeObject(pContainerID)
  removeObject(pSafeTraderID)
  removeObject(pArrowObjID)
  removeObject(pObjMoverID)
  removeObject(pPreviewObjID)
  removeObject(pDoorBellID)
  removeObject(pIgnoreListID)
  removeObject(pRoomGuiID)
  removeObject(pRespectMgrID)
  return(me.hideAll())
  exit
end

on showRoom(me, tRoomID)
  if not memberExists(tRoomID & ".room") then
    return(error(me, "Room recording data member not found, check recording label name. Tried to find" && tRoomID & ".room", #showRoom, #major))
  end if
  me.showTrashCover()
  if windowExists(pLoaderBarID) then
    activateWindowObj(pLoaderBarID)
  end if
  tRoomField = tRoomID & ".room"
  me.updateScreenOffset(tRoomID)
  createVisualizer(pRoomSpaceId, tRoomField, pWideScreenOffset)
  tVisObj = getVisualizer(pRoomSpaceId)
  tLocX = tVisObj.getProperty(#locX)
  tLocY = tVisObj.getProperty(#locY)
  tlocz = tVisObj.getProperty(#locZ)
  tdata = getObject(#layout_parser).parse(tRoomField).getProp(#roomdata, 1)
  tdata.setAt(#offsetz, tlocz)
  tdata.setAt(#offsetx, tdata.getAt(#offsetx) + pWideScreenOffset)
  tdata.setAt(#offsety, tdata.getAt(#offsety))
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
    me.getHiliter().define([#sprite:tHiliterSpr, #geometry:pGeometryId])
    receiveUpdate(pHiliterId)
  end if
  tAnimations = tVisObj.getProperty(#swapAnims)
  if tAnimations <> 0 then
    repeat while me <= undefined
      tAnimation = getAt(undefined, tRoomID)
      tObj = createObject(#random, getStringVariable("swap.animation.class"))
      if tObj = 0 then
        error(me, "Error creating swap animation", #showRoom, #minor)
      else
        pSwapAnimations.add(tObj)
        pSwapAnimations.getAt(pSwapAnimations.count).define(tAnimation)
      end if
    end repeat
  end if
  me.getArrowHiliter().Init()
  pClickAction = "moveHuman"
  return(1)
  exit
end

on hideRoom(me)
  removeUpdate(pHiliterId)
  removeObject(pHiliterId)
  pClickAction = #null
  pSelectedObj = ""
  me.hideArrowHiliter()
  me.hideTrashCover()
  repeat while me <= undefined
    tAnim = getAt(undefined, undefined)
    tAnim.deconstruct()
  end repeat
  pSwapAnimations = []
  if visualizerExists(pRoomSpaceId) then
    removeVisualizer(pRoomSpaceId)
  end if
  return(1)
  exit
end

on showRoomBar(me, tLayout)
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and not tGUI = 0 then
    tGUI.showRoomBar(tLayout)
  end if
  exit
end

on hideRoomBar(me)
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and not tGUI = 0 then
    tGUI.hideRoomBar()
  end if
  exit
end

on showVote(me)
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and not tGUI = 0 then
    tGUI.showVote()
  end if
  exit
end

on startTradeButtonTimeout(me)
  pTradeTimeout = 1
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if tWndObj.elementExists("trade.button") then
      tWndObj.getElement("trade.button").deactivate()
    end if
  end if
  tTimeout = getVariable("room.request.timeout", 10000)
  createTimeout(#activeTradeButton, tTimeout, #endTradeButtonTimeout, me.getID(), void(), 1)
  exit
end

on endTradeButtonTimeout(me)
  pTradeTimeout = 0
  tWndObj = getWindow(pInterfaceId)
  if tWndObj <> 0 then
    if tWndObj.elementExists("trade.button") then
      tWndObj.getElement("trade.button").Activate()
    end if
  end if
  exit
end

on showArrowHiliter(me, tUserID)
  if objectExists(pArrowObjID) then
    return(me.getArrowHiliter().show(tUserID, 1))
  end if
  exit
end

on hideArrowHiliter(me)
  return(me.getArrowHiliter().hide())
  exit
end

on showDoorBellWaiting(me)
  me.hideLoaderBar()
  createWindow(pLoaderBarID, "habbo_simple.window")
  tWndObj = getWindow(pLoaderBarID)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.merge("room_doorbell_waiting.window")
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
  tRoomData = me.getComponent().getRoomData()
  if tRoomData = 0 then
    return(1)
  end if
  tRoomName = tRoomData.getAt(#name)
  tElem = tWndObj.getElement("room_doorbell_roomname")
  if tElem = 0 then
    return(1)
  end if
  tElem.setText(tRoomName)
  return(1)
  exit
end

on showDoorBellAccepted(me, tName)
  if tName = "" then
    nothing()
  else
    if objectExists(pDoorBellID) then
      getObject(pDoorBellID).removeFromList(tName)
    end if
  end if
  return(1)
  exit
end

on showDoorBellRejected(me, tName)
  if tName = "" then
    me.hideLoaderBar()
    createWindow(pLoaderBarID, "habbo_simple.window")
    tWndObj = getWindow(pLoaderBarID)
    if tWndObj = 0 then
      return(0)
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
  return(1)
  exit
end

on showDoorBellDialog(me, tName)
  tOwnUser = me.getComponent().getOwnUser()
  if tOwnUser = 0 then
    return(error(me, "Own user not found!", #showDoorBell, #major))
  end if
  if tOwnUser.pClass = "pet" then
    return(error(me, "Wrong type of user found as own user", #showDoorBell, #major))
  end if
  if tOwnUser.getInfo().ctrl = 0 then
    return(1)
  end if
  if objectExists(pDoorBellID) then
    return(getObject(pDoorBellID).addDoorbellRinger(tName))
  end if
  exit
end

on hideDoorBellDialog(me)
  if objectExists(pDoorBellID) then
    getObject(pDoorBellID).hideDoorBell()
  end if
  exit
end

on showLoaderBar(me, tCastLoadId, tText)
  if not windowExists(pLoaderBarID) then
    createWindow(pLoaderBarID, "habbo_simple.window")
    tWndObj = getWindow(pLoaderBarID)
    tWndObj.merge("room_loader.window")
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcBanner, me.getID(), #mouseUp)
    if not voidp(tCastLoadId) then
      tBuffer = tWndObj.getElement("gen_loaderbar").getProperty(#buffer).image
      pLoadingBarID = showLoadingBar(tCastLoadId, [#buffer:tBuffer, #bgColor:rgb(255, 255, 255)])
    end if
    if stringp(tText) then
      tWndObj.getElement("general_loader_text").setText(tText)
    end if
    pWIndowText = tText
  end if
  return(1)
  exit
end

on hideLoaderBar(me)
  if windowExists(pLoaderBarID) then
    removeWindow(pLoaderBarID)
  end if
  tInterstitialMngr = me.getComponent().getInterstitial()
  if not voidp(tInterstitialMngr) then
    tInterstitialMngr.adClosed()
  end if
  pLoadingBarID = 0
  exit
end

on resizeInterstitialWindow(me)
  if not windowExists(pLoaderBarID) then
    return(0)
  end if
  tWndObj = getWindow(pLoaderBarID)
  tInterstitialMngr = me.getComponent().getInterstitial()
  if voidp(tInterstitialMngr) then
    return(0)
  end if
  tMemNum = tInterstitialMngr.getInterstitialMemNum()
  if tMemNum < 1 then
    return(0)
  end if
  tWndObj.unmerge()
  if pQueueCollection.count() <= 1 then
    tWndObj.merge("room_loader_interstitial_ad.window")
  else
    tWndObj.merge("room_loader_2_interstitial_ad.window")
  end if
  if objectExists(pLoadingBarID) then
    tLoadID = getObject(pLoadingBarID).pTaskId
    tBuffer = tWndObj.getElement("gen_loaderbar").getProperty(#buffer).image
    showLoadingBar(tLoadID, [#buffer:tBuffer, #bgColor:rgb(255, 255, 255)])
  end if
  if stringp(pWIndowText) then
    tWndObj.getElement("general_loader_text").setText(pWIndowText)
  end if
  tAdMember = member(tMemNum)
  if tAdMember.type = #bitmap then
    tAdImage = tAdMember.image
  else
    tAdImage = image(1, 1, 8)
  end if
  tAdWidth = tAdImage.getProp(#rect, 3)
  tAdHeight = tAdImage.getProp(#rect, 4)
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
  if tAdWidth > tWndWidth - tBorderWidth * 2 then
    tOffX = tAdWidth - tWndWidth + tBorderWidth * 2
    tAdLocX = tBorderWidth
  else
    tAdLocX = tWndWidth - tAdWidth / 2
  end if
  tWndObj.resizeBy(tOffX, tOffY)
  tWndObj.center()
  tElementList = ["general_loader_text", "queue_text", "second_queue_title", "queue_text_2"]
  repeat while me <= undefined
    tElemID = getAt(undefined, undefined)
    tElem = tWndObj.getElement(tElemID)
    if tElem <> 0 then
      tElem.setText(tElem.getText())
    end if
  end repeat
  if not tWndObj.elementExists("room_banner_pic") then
    return(0)
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
  exit
end

on updateQueueWindow(me, tQueueCollection)
  if not windowExists(pLoaderBarID) then
    return(0)
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
    return(0)
  end if
  tTitleElementList = ["general_loader_text", "second_queue_title"]
  tTextElementList = ["queue_text", "queue_text_2"]
  tTitleTextList = ["queue_current_", "queue_other_"]
  pQueueCollection = tQueueCollection.duplicate()
  i = 1
  repeat while i <= tSetCount
    tQueueSet = pQueueCollection.getAt(i)
    tQueueTarget = tQueueSet.getAt("target")
    tQueueData = tQueueSet.getAt("data")
    tQueueSetName = tQueueSet.getAt("name")
    if tWndObj.elementExists(tTitleElementList.getAt(i)) then
      tTitleElem = tWndObj.getElement(tTitleElementList.getAt(i))
      tTitleElem.setText(getText(tTitleTextList.getAt(i) & string(tQueueTarget)))
    end if
    if tWndObj.elementExists(tTextElementList.getAt(i)) then
      tQueueTxtElem = tWndObj.getElement(tTextElementList.getAt(i))
      tQueueTxt = getText("queue_set." & tQueueSetName & ".info")
      if ilk(tQueueData) <> #propList then
        return(error(me, "tQueueData is not a propList", #updateQueueWindow, #major))
      end if
      tCount = 1
      repeat while tCount <= tQueueData.count
        tQueueProp = getPropAt(tQueueData, tCount)
        tQueueValue = tQueueData.getAt(tQueueProp)
        tQueueTxt = replaceChunks(tQueueTxt, "%" & tQueueProp & "%", tQueueValue)
        tCount = 1 + tCount
      end repeat
      tQueueTxtElem.setText(tQueueTxt)
    end if
    i = 1 + i
  end repeat
  me.resizeInterstitialWindow()
  return(1)
  exit
end

on showTrashCover(me, tlocz, tColor)
  if voidp(pCoverSpr) then
    if not integerp(tlocz) then
      tlocz = 0
    end if
    if ilk(tColor) <> #color then
      tColor = rgb(0, 0, 0)
    end if
    pCoverSpr = sprite(reserveSprite(me.getID()))
    if not memberExists("Room Trash Cover") then
      createMember("Room Trash Cover", #bitmap)
    end if
    tmember = member(getmemnum("Room Trash Cover"))
    tmember.image = image(1, 1, 8)
    tmember.setPixel(0, 0, tColor)
    pCoverSpr.member = tmember
    pCoverSpr.loc = point(0, 0)
    pCoverSpr.width = undefined.width
    pCoverSpr.height = undefined.height
    pCoverSpr.locZ = tlocz
    pCoverSpr.blend = 100
    setEventBroker(pCoverSpr.spriteNum, "Trash Cover")
    updateStage()
  end if
  exit
end

on hideTrashCover(me)
  if not voidp(pCoverSpr) then
    releaseSprite(pCoverSpr.spriteNum)
    pCoverSpr = void()
  end if
  exit
end

on hideAll(me)
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
  return(1)
  exit
end

on getRoomVisualizer(me)
  return(getVisualizer(pRoomSpaceId))
  exit
end

on getGeometry(me)
  return(getObject(pGeometryId))
  exit
end

on getHiliter(me)
  return(getObject(pHiliterId))
  exit
end

on getContainer(me)
  return(getObject(pContainerID))
  exit
end

on getSafeTrader(me)
  return(getObject(pSafeTraderID))
  exit
end

on getArrowHiliter(me)
  return(getObject(pArrowObjID))
  exit
end

on getBadgeObject(me)
  tGUI = me.getGUIObject()
  if tGUI = 0 then
    return(0)
  end if
  return(tGUI.getBadgeObject())
  exit
end

on getGUIObject(me)
  return(getObject(pRoomGuiID))
  exit
end

on getIgnoreListObject(me)
  return(getObject(pIgnoreListID))
  exit
end

on getObjectMover(me)
  return(getObject(pObjMoverID))
  exit
end

on setSelectedObject(me, tSelectedObj)
  pSelectedObj = tSelectedObj
  exit
end

on getSelectedObject(me)
  return(pSelectedObj)
  exit
end

on getProperty(me, tPropID)
  if me = #clickAction then
    return(pClickAction)
  else
    if me = #widescreenoffset then
      return(pWideScreenOffset)
    else
      return(0)
    end if
  end if
  exit
end

on setProperty(me, tPropID, tValue)
  if me = #clickAction then
    pClickAction = tValue
  else
    return(0)
  end if
  exit
end

on cancelObjectMover(me)
  tMoverObj = me.getObjectMover()
  if not tMoverObj = 0 then
    tMoverObj.cancelMove()
  end if
  return(me.stopObjectMover())
  exit
end

on dancingStoppedExternally(me)
  tWndObj = getWindow(pInterfaceId)
  if tWndObj = 0 then
    return(1)
  end if
  tElem = tWndObj.getElement("hcdance.button")
  if tElem = 0 then
    return(1)
  end if
  tElem.setSelection("dance_choose", 1)
  return(1)
  exit
end

on openSongSelector(me, tSongList)
  if not objectExists(pSongSelectorID) then
    createObject(pSongSelectorID, "Performer Song Selector Class")
  end if
  call(#open, [getObject(pSongSelectorID)], tSongList)
  exit
end

on setJudgeToolState(me, tstate, tPerformerID)
  if not objectExists(pJudgeToolID) then
    createObject(pJudgeToolID, "Judge Tool Class")
  end if
  call(#setState, [getObject(pJudgeToolID)], tstate, tPerformerID)
  exit
end

on getKeywords(me)
  return([deobfuscate("$cMgMXLrlJM|OI-9"), deobfuscate("%bl&-ym3Lj-|.I-)"), deobfuscate("EBLFM9M2,KM|oH/h")])
  exit
end

on notify(me, ttype)
  if me = 400 then
    executeMessage(#alert, [#Msg:"room_cant_trade"])
  else
    if me = 401 then
      executeMessage(#alert, [#Msg:"room_max_pet_limit"])
    else
      if me = 402 then
        executeMessage(#alert, [#Msg:"room_cant_set_item"])
      else
        if me = 403 then
          executeMessage(#alert, [#Msg:"wallitem_post.it.limit"])
        else
          if me = 404 then
            executeMessage(#alert, [#Msg:"queue_tile_limit"])
          else
            if me = 405 then
              executeMessage(#alert, [#Msg:"room_alert_furni_limit", #id:"roomfullfurni", #modal:1])
            else
              if me = 406 then
                executeMessage(#alert, [#Msg:"room_sound_furni_limit"])
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end

on getIgnoreStatus(me, tUserID, tName)
  tIgnoreListObj = me.getIgnoreListObject()
  if not objectp(tIgnoreListObj) then
    return(0)
  end if
  if not voidp(tName) then
    return(tIgnoreListObj.getIgnoreStatus(tName))
  end if
  if me.getComponent().userObjectExists(tUserID) then
    tName = me.getComponent().getUserObject(tUserID).getName()
    return(tIgnoreListObj.getIgnoreStatus(tName))
  else
    return(0)
  end if
  exit
end

on unignoreAdmin(me, tUserID, tBadges)
  tIgnoreListObj = me.getIgnoreListObject()
  tModBadgeFound = 0
  repeat while me <= tBadges
    tBadge = getAt(tBadges, tUserID)
    if pModBadgeList.getOne(tBadge) > 0 then
      tModBadgeFound = 1
    else
    end if
  end repeat
  if me.getComponent().userObjectExists(tUserID) and tModBadgeFound then
    tName = me.getComponent().getUserObject(tUserID).getName()
    if objectp(tIgnoreListObj) then
      return(tIgnoreListObj.setIgnoreStatus(tName, 0))
    end if
  else
    return(0)
  end if
  exit
end

on startObjectMover(me, tObjID, tStripID, tProps)
  if not objectExists(pObjMoverID) then
    createObject(pObjMoverID, "Object Mover Class")
  end if
  if me = "active" then
    pClickAction = "moveActive"
  else
    if me = "item" then
      pClickAction = "moveItem"
    else
      return(error(me, "Object type" && pSelectedType && "can't be moved.", #startObjectMover, #minor))
    end if
  end if
  return(getObject(pObjMoverID).define(tObjID, tStripID, pSelectedType, tProps))
  exit
end

on stopObjectMover(me)
  if not objectExists(pObjMoverID) then
    return(error(me, "Object mover not found!", #stopObjectMover, #minor))
  end if
  getObject(pObjMoverID).clear()
  pClickAction = "moveHuman"
  pSelectedType = ""
  return(1)
  exit
end

on startTrading(me, tuser)
  if tuser = getObject(#session).GET("user_index") then
    return(0)
  end if
  if not me.getComponent().userObjectExists(tuser) then
    return(0)
  end if
  me.getComponent().getRoomConnection().send("TRADE_OPEN", [#integer:integer(tuser)])
  me.getContainer().open()
  if objectExists(pObjMoverID) then
    getObject(pObjMoverID).moveTrade()
  end if
  return(1)
  exit
end

on stopTrading(me)
  return(error(me, "TODO: stopTrading...!", #stopTrading, #minor))
  pClickAction = "moveHuman"
  if objectExists(pObjMoverID) then
    me.stopObjectMover()
  end if
  return(1)
  exit
end

on showConfirmDelete(me)
  if windowExists(pDelConfirmID) then
    return(0)
  end if
  if not createWindow(pDelConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmDelete, #major))
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
  return(1)
  exit
end

on hideConfirmDelete(me)
  if windowExists(pDelConfirmID) then
    removeWindow(pDelConfirmID)
  end if
  exit
end

on showConfirmPlace(me)
  if windowExists(pPlcConfirmID) then
    return(0)
  end if
  if not createWindow(pPlcConfirmID, "habbo_basic.window", 200, 120) then
    return(error(me, "Couldn't create confirmation window!", #showConfirmPlace, #major))
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
  return(1)
  exit
end

on hideConfirmPlace(me)
  if windowExists(pPlcConfirmID) then
    removeWindow(pPlcConfirmID)
  end if
  exit
end

on placeFurniture(me, tObjID, tObjType)
  if me = "active" then
    tloc = getObject(pObjMoverID).getProperty(#loc)
    if not tloc then
      me.getComponent().getRoomConnection().send("GETSTRIP", [#integer:4])
      return(0)
    end if
    tObj = me.getComponent().getActiveObject(tObjID)
    if tObj = 0 then
      return(error(me, "Invalid active object:" && tObjID, #placeFurniture, #major))
    end if
    tStripID = integer(tObj.getaProp(#stripId))
    tMsg = tStripID && tloc.getAt(1) && tloc.getAt(2) && tObj.getProp(#pDirection, 1)
    me.getComponent().removeActiveObject(tObj.getAt(#id))
    me.getComponent().getRoomConnection().send("PLACESTUFF", tMsg)
    return(1)
  else
    if me = "item" then
      tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
      if not tloc then
        return(0)
      end if
      tObj = me.getComponent().getItemObject(tObjID)
      if tObj = 0 then
        return(error(me, "Invalid item object:" && tObjID, #placeFurniture, #major))
      end if
      tStripID = integer(tObj.getaProp(#stripId))
      tMsg = tStripID && tloc
      me.getComponent().removeItemObject(tObj.getAt(#id))
      me.getComponent().getRoomConnection().send("PLACESTUFF", tMsg)
      return(1)
    else
      return(0)
    end if
  end if
  exit
end

on setSpeechDropdown(me, tMode)
  tGUI = getObject(pRoomGuiID)
  if not voidp(tGUI) and not tGUI = 0 then
    tGUI.setSpeechDropdown(tMode)
  end if
  exit
end

on showCfhSenderDelayed(me, tID)
  return(createTimeout(#highLightCfhSender, 3000, #highLightCfhSender, me.getID(), tID, 1))
  exit
end

on highLightCfhSender(me, tID)
  if not voidp(tID) then
    me.showArrowHiliter(tID)
  end if
  return(1)
  exit
end

on validateEvent(me, tEvent, tSprID, tloc)
  if call(#getID, sprite(the rollover).scriptInstanceList) = tSprID then
    tSpr = sprite(the rollover)
    if tSpr.type = #bitmap and tSpr.ink = 36 then
      tPixel = undefined.getPixel(tloc.getAt(1) - tSpr.left, tloc.getAt(2) - tSpr.top)
      if not tPixel then
        return(0)
      end if
      if tPixel.hexString() = "#FFFFFF" then
        tSpr.visible = 0
        call(tEvent, sprite(the rollover).scriptInstanceList)
        tSpr.visible = 1
        return(0)
      else
        return(1)
      end if
    else
      return(1)
    end if
  else
    return(1)
  end if
  return(1)
  exit
end

on objectFinalized(me, tID)
  if pSelectedObj = tID then
    executeMessage(#hideObjectInfo)
  end if
  exit
end

on showRemoveSpecsNotice(me)
  executeMessage(#alert, [#Msg:"room_remove_specs", #modal:1])
  exit
end

on updateScreenOffset(me, tRoomID)
  if undefined.width > 800 then
    pWideScreenOffset = getVariable("widescreen.offset.x")
  else
    pWideScreenOffset = 0
  end if
  if pWideScreenOffset <> 0 and not voidp(tRoomID) then
    if variableExists(tRoomID & ".wide.offset.x") then
      pWideScreenOffset = value(getVariable(tRoomID & ".wide.offset.x"))
    end if
  end if
  if variableExists(tRoomID & ".wide.align.right") then
    if value(getVariable(tRoomID & ".wide.align.right")) then
      pWideScreenOffset = undefined.width - 720 - pWideScreenOffset
    end if
  end if
  exit
end

on eventProcActiveRollOver(me, tEvent, tSprID, tProp)
  tGUI = getObject(pRoomGuiID)
  if voidp(tGUI) or tGUI = 0 then
    return(0)
  end if
  if me.getComponent().getRoomData().type = #private then
    if tEvent = #mouseEnter then
      tGUI.setRollOverInfo(me.getComponent().getActiveObject(tSprID).getCustom())
    else
      if tEvent = #mouseLeave then
        tGUI.setRollOverInfo("")
      end if
    end if
  end if
  exit
end

on eventProcUserRollOver(me, tEvent, tSprID, tProp)
  if pClickAction = "placeActive" then
    if tEvent = #mouseEnter then
      me.showArrowHiliter(tSprID)
    else
      me.showArrowHiliter(void())
    end if
  end if
  tGUI = getObject(pRoomGuiID)
  if voidp(tGUI) or tGUI = 0 then
    return(0)
  end if
  if tEvent = #mouseEnter then
    tObject = me.getComponent().getUserObject(tSprID)
    if tObject = 0 then
      return()
    end if
    tGUI.setRollOverInfo(tObject.getInfo().getaProp(#name))
  else
    if tEvent = #mouseLeave then
      tGUI.setRollOverInfo("")
    end if
  end if
  exit
end

on eventProcItemRollOver(me, tEvent, tSprID, tProp)
  tGUI = getObject(pRoomGuiID)
  if voidp(tGUI) or tGUI = 0 then
    return(0)
  end if
  tObject = me.getComponent().getItemObject(tSprID)
  if tObject = 0 then
    return(tGUI.setRollOverInfo(""))
  end if
  if tEvent = #mouseEnter then
    tGUI.setRollOverInfo(tObject.getCustom())
  else
    if tEvent = #mouseLeave then
      tGUI.setRollOverInfo("")
    end if
  end if
  if not getObject(#session).GET("room_controller") or getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") or the shiftDown and the optionDown then
    if tObject.hasURL() then
      tAdSystem = me.getComponent().getAd()
      if tAdSystem <> 0 then
        tAdSystem.eventProc(tEvent, tSprID, tObject.GetUrl())
      end if
    end if
  end if
  exit
end

on eventProcRoom(me, tEvent, tSprID, tParam)
  if me.getComponent().getSpectatorMode() then
    return(1)
  end if
  if me.getComponent().getOwnUser() = 0 then
    return(1)
  end if
  if tEvent = #mouseUp and tSprID contains "command:" then
    tCmd = convertToHigherCase(tSprID.getProp(#word, 2))
    tPrm = []
    if me = "MOVE" then
      tPrm = [#short:integer(tSprID.getProp(#word, 3)), #short:integer(tSprID.getProp(#word, 4))]
    else
      if me = "GOAWAY" then
        tPrm = []
      else
        error(me, "Is this command valid:" && tCmd & "?", #eventProcRoom, #minor)
      end if
    end if
    return(me.getComponent().getRoomConnection().send(tCmd, tPrm))
  end if
  tDragging = 0
  if tEvent = #mouseDown or tDragging then
    if me = "moveHuman" then
      if tParam <> "object_selection" then
        pSelectedObj = ""
        executeMessage(#hideObjectInfo)
        me.hideArrowHiliter()
      end if
      tloc = me.getGeometry().getFloorCoordinate(the mouseH, the mouseV)
      if listp(tloc) then
        return(me.getComponent().getRoomConnection().send("MOVE", [#short:tloc.getAt(1), #short:tloc.getAt(2)]))
      end if
    else
      if me = "moveActive" then
        tloc = getObject(pObjMoverID).getProperty(#loc)
        if not tloc then
          return(0)
        end if
        tObj = me.getComponent().getActiveObject(pSelectedObj)
        if tObj = 0 then
          return(error(me, "Invalid active object:" && pSelectedObj, #eventProcRoom, #major))
        end if
        me.getComponent().getRoomConnection().send("MOVESTUFF", [#integer:integer(pSelectedObj), #integer:tloc.getAt(1), #integer:tloc.getAt(2), #integer:tObj.getProp(#pDirection, 1)])
        me.stopObjectMover()
      else
        if me = "placeActive" then
          if getObject(#session).GET("room_controller") or getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
            tCanPlace = 1
          end if
          if not tCanPlace then
            return(0)
          end if
          if getObject(#session).GET("room_owner") then
            me.placeFurniture(pSelectedObj, pSelectedType)
            executeMessage(#hideObjectInfo)
            me.stopObjectMover()
          else
            if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
              return(0)
            end if
            tloc = getObject(pObjMoverID).getProperty(#loc)
            if not tloc then
              return(0)
            end if
            if me.showConfirmPlace() then
              me.getObjectMover().pause()
            end if
          end if
        else
          if me = "placeItem" then
            if getObject(#session).GET("room_controller") or getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
              tCanPlace = 1
            end if
            if not tCanPlace then
              return(0)
            end if
            if getObject(#session).GET("room_owner") then
              if me.placeFurniture(pSelectedObj, pSelectedType) then
                executeMessage(#hideObjectInfo)
                me.stopObjectMover()
              end if
            else
              if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
                return(0)
              end if
              tloc = getObject(pObjMoverID).getProperty(#itemLocStr)
              if not tloc then
                return(0)
              end if
              if me.showConfirmPlace() then
                me.getObjectMover().pause()
              end if
            end if
          else
            if me = "tradeItem" then
            else
              return(error(me, "Unsupported click action:" && pClickAction, #eventProcRoom, #minor))
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end

on eventProcUserObj(me, tEvent, tSprID, tParam)
  tObject = me.getComponent().getUserObject(tSprID)
  if tObject = 0 then
    error(me, "User object not found:" && tSprID, #eventProcUserObj, #major)
    return(me.eventProcRoom(tEvent, "floor"))
  end if
  if the shiftDown and the optionDown then
    return(me.outputObjectInfo(tSprID, "user", the rollover))
  end if
  if pClickAction = "moveActive" or pClickAction = "placeActive" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if pClickAction = "moveItem" or pClickAction = "placeItem" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if tObject.select() then
    if tObject.getClass() = "user" then
      executeMessage(#userClicked, tObject.getName())
    end if
    if tObject.getClass() = "user" and tEvent = #mouseDown then
      executeMessage(#tutorial_userClicked)
    end if
    pSelectedObj = tSprID
    pSelectedType = tObject.getClass()
    if tParam <> #userEnters then
      executeMessage(#showObjectInfo, pSelectedType)
    end if
    me.showArrowHiliter(tSprID)
    tloc = tObject.getLocation()
    if tObject <> me.getComponent().getOwnUser() or tObject.getProperty(#moving) then
      me.getComponent().getRoomConnection().send("LOOKTO", tloc.getAt(1) && tloc.getAt(2))
    end if
  else
    pSelectedObj = ""
    pSelectedType = ""
    executeMessage(#hideObjectInfo)
    me.hideArrowHiliter()
  end if
  return(1)
  exit
end

on eventProcActiveObj(me, tEvent, tSprID, tParam)
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return(0)
  end if
  if me.getComponent().getOwnUser() = 0 then
    return(1)
  end if
  tObject = me.getComponent().getActiveObject(tSprID)
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "active", the rollover))
  end if
  if pClickAction = "moveActive" or pClickAction = "placeActive" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if pClickAction = "moveItem" or pClickAction = "placeItem" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if tObject = 0 then
    pSelectedObj = ""
    pSelectedType = ""
    executeMessage(#hideObjectInfo)
    me.hideArrowHiliter()
    return(error(me, "Active object not found:" && tSprID, #eventProcActiveObj, #major))
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
    return(me.startObjectMover(pSelectedObj))
  end if
  tTemp = call(#select, tObject)
  if tTemp then
    return(1)
  else
    return(me.eventProcRoom(tEvent, "floor", "object_selection"))
  end if
  exit
end

on eventProcPassiveObj(me, tEvent, tSprID, tParam)
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return(0)
  end if
  tObject = me.getComponent().getPassiveObject(tSprID)
  if the shiftDown then
    return(me.outputObjectInfo(tSprID, "passive", the rollover))
  end if
  if pClickAction = "moveActive" or pClickAction = "placeActive" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if pClickAction = "moveItem" or pClickAction = "placeItem" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if tObject = 0 then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if not tObject.select() then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  exit
end

on eventProcItemObj(me, tEvent, tSprID, tParam)
  if not me.validateEvent(tEvent, tSprID, the mouseLoc) then
    return(0)
  end if
  if the shiftDown then
    if me.getComponent().itemObjectExists(tSprID) then
      me.outputObjectInfo(tSprID, "item", the rollover)
    end if
  end if
  if pClickAction = "moveActive" or pClickAction = "placeActive" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if pClickAction = "moveItem" or pClickAction = "placeItem" then
    return(me.eventProcRoom(tEvent, tSprID, tParam))
  end if
  if not me.getComponent().itemObjectExists(tSprID) then
    pSelectedObj = ""
    pSelectedType = ""
    executeMessage(#hideObjectInfo)
    me.hideArrowHiliter()
    return(error(me, "Item object not found:" && tSprID, #eventProcItemObj, #major))
  end if
  tObject = me.getComponent().getItemObject(tSprID)
  if tObject.select() then
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
  if not getObject(#session).GET("room_controller") or getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") or the shiftDown and the optionDown then
    if tObject.hasURL() then
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tObject.GetUrl())
      tAdSystem = me.getComponent().getAd()
      if tAdSystem <> 0 then
        tAdSystem.eventProc(#mouseLeave, tSprID, tObject.GetUrl())
      end if
    end if
  end if
  exit
end

on eventProcDelConfirm(me, tEvent, tSprID, tParam)
  if me = "habbo_decision_ok" then
    me.hideConfirmDelete()
    if me = "active" then
      me.getComponent().getRoomConnection().send("REMOVESTUFF", [#integer:integer(pDeleteObjID)])
    else
      if me = "item" then
        me.getComponent().getRoomConnection().send("REMOVEITEM", [#integer:integer(pDeleteObjID)])
      end if
    end if
    executeMessage(#hideObjectInfo)
    pDeleteObjID = ""
    pDeleteType = ""
  else
    if me <> "habbo_decision_cancel" then
      if me = "close" then
        me.hideConfirmDelete()
        pDeleteObjID = ""
      end if
      exit
    end if
  end if
end

on eventProcPlcConfirm(me, tEvent, tSprID, tParam)
  if me = "habbo_decision_ok" then
    me.placeFurniture(pSelectedObj, pSelectedType)
    me.hideConfirmPlace()
    executeMessage(#hideObjectInfo)
    me.stopObjectMover()
  else
    if me <> "habbo_decision_cancel" then
      if me = "close" then
        me.getObjectMover().resume()
        me.hideConfirmPlace()
      end if
      exit
    end if
  end if
end

on eventProcBanner(me, tEvent, tSprID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "room_banner_link" then
    if pBannerLink <> 0 then
      if connectionExists(pInfoConnID) and getObject(#session).exists("ad_id") then
        getConnection(pInfoConnID).send("ADCLICK", getObject(#session).GET("ad_id"))
      end if
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(pBannerLink)
    end if
  else
    if me = "room_cancel" then
      me.getComponent().getRoomConnection().send("QUIT")
      me.getComponent().removeEnterRoomAlert()
      executeMessage(#leaveRoom)
      me.hideLoaderBar()
    else
      if me = "queue_change" then
        if connectionExists(pInfoConnID) then
          tSelected = 2
          if pQueueCollection.count() >= tSelected then
            tTarget = pQueueCollection.getAt(tSelected).getAt(#target)
            getConnection(pInfoConnID).send("ROOM_QUEUE_CHANGE", [#integer:tTarget])
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on outputObjectInfo(me, tSprID, tObjType, tSprNum)
  if sprite(tSprNum).spriteNum = 0 then
    return(0)
  end if
  if me = "user" then
    tObj = me.getComponent().getUserObject(tSprID)
  else
    if me = "active" then
      tObj = me.getComponent().getActiveObject(tSprID)
    else
      if me = "passive" then
        tObj = me.getComponent().getPassiveObject(tSprID)
      else
        if me = "item" then
          tObj = me.getComponent().getItemObject(tSprID)
        end if
      end if
    end if
  end if
  if tObj = 0 then
    return(0)
  end if
  tInfo = tObj.getInfo()
  tdata = []
  tdata.setAt(#id, tObj.getID())
  tdata.setAt(#class, tInfo.getAt(#class))
  tdata.setAt(#x, tObj.pLocX)
  tdata.setAt(#y, tObj.pLocY)
  tdata.setAt(#h, tObj.pLocH)
  tdata.setAt(#Dir, tObj.pDirection)
  tdata.setAt(#locH, sprite(tSprNum).locH)
  tdata.setAt(#locV, sprite(tSprNum).locV)
  tdata.setAt(#locZ, "")
  tSprList = tObj.getSprites()
  repeat while me <= tObjType
    tSpr = getAt(tObjType, tSprID)
    tdata.setAt(#locZ, tdata.getAt(#locZ) & tSpr.locZ && "")
  end repeat
  tdata.setAt(#sprNumList, "")
  repeat while me <= tObjType
    tSpr = getAt(tObjType, tSprID)
    tdata.setAt(#sprNumList, tdata.getAt(#sprNumList) & tSpr.spriteNum && "")
  end repeat
  put("- - - - - - - - - - - - - - - - - - - - - -")
  put("ID            " & tdata.getAt(#id))
  put("Class         " & tdata.getAt(#class))
  put("Member        " & undefined.name)
  put("Cast          " & castLib(sprite(tSprNum).castLibNum).name)
  put("World X       " & tdata.getAt(#x))
  put("World Y       " & tdata.getAt(#y))
  put("World H       " & tdata.getAt(#h))
  put("Dir           " & tdata.getAt(#Dir))
  put("Scr X         " & tdata.getAt(#locH))
  put("Scr Y         " & tdata.getAt(#locV))
  put("Scr Z         " & tdata.getAt(#locZ))
  put("This sprite   " & tSprNum)
  put("All sprites   " & tdata.getAt(#sprNumList))
  put("Object info   " & tObj)
  put("- - - - - - - - - - - - - - - - - - - - - -")
  exit
end

on null(me)
  exit
end