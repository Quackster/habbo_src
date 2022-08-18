property pInfoConnID, pRoomConnID, pRoomId, pActiveFlag, pProcessList, pChatProps, pDefaultChatMode, pSaveData, pCacheKey, pCacheFlag, pUserObjList, pActiveObjList, pPassiveObjList, pItemObjList, pBalloonId, pClassContId, pRoomPrgID, pRoomPollerID, pTrgDoorID, pAdSystemID, pFurniChooserID, pInterstitialSystemID, pSpectatorSystemID, pHeightMapData, pCurrentSlidingObjects, pPickedCryName, pCastLoaded, pEnterRoomAlert, pShadowManagerID, pPrvRoomsReady, pGroupInfoID, pOneWayDoorManagerID, pFlatRatings, pEnterDoorData, pEnterDoorLocked, pRoomEventBrowserID, pRoomEventTypeCount, pRoomEventList, pRoomEventCurrent, pIconBarManagerID

on construct me
  pInfoConnID = getVariable("connection.info.id")
  pRoomConnID = getVariable("connection.room.id")
  pRoomId = EMPTY
  pActiveFlag = 0
  pProcessList = [:]
  pSaveData = VOID
  pCacheKey = EMPTY
  pCacheFlag = getVariableValue("room.map.cache", 0)
  pTrgDoorID = VOID
  pPickedCryName = EMPTY
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pFlatRatings = [#rate: -1, #Percent: 0]
  pBalloonId = "Chat Manager"
  pClassContId = "Room Classes"
  pRoomPrgID = "Room Program"
  pRoomPollerID = "Room Poller"
  pAdSystemID = "Room ad"
  pInterstitialSystemID = "Interstitial system"
  pSpectatorSystemID = "Room Mode Manager"
  pFurniChooserID = "Furniture Chooser"
  pShadowManagerID = "Room Shadow Manager"
  pGroupInfoID = "Group_Info"
  pRoomEventBrowserID = "RoomEvent Browser Window"
  pIconBarManagerID = "Icon Bar Manager"
  pRoomEventList = [:]
  pChatProps = [:]
  pChatProps["returnCount"] = 0
  pChatProps["timerStart"] = 0
  pChatProps["timerDelay"] = 0
  pChatProps["mode"] = "CHAT"
  pChatProps["hobbaCmds"] = getVariableValue("moderator.cmds")
  createObject(pClassContId, getClassVariable("variable.manager.class"))
  getObject(pClassContId).dump("fuse.object.classes", RETURN)
  createObject(pBalloonId, "Chat Manager")
  createObject(pAdSystemID, "Ad Manager")
  pCastLoaded = 0
  pPrvRoomsReady = 0
  createObject(pInterstitialSystemID, "Interstitial Manager")
  createObject(pSpectatorSystemID, "Spectator System Class")
  pCurrentSlidingObjects = [:]
  createObject(pShadowManagerID, "Shadow Manager")
  createObject(pGroupInfoID, "Group Info Class")
  pOneWayDoorManagerID = "One Way Door Manager"
  createObject(pOneWayDoorManagerID, "OneWayDoor Manager Class")
  registerMessage(#pickAndGoCFH, me.getID(), #pickAndGoCFH)
  registerMessage(#enterRoom, me.getID(), #enterRoom)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#enterRoomDirect, me.getID(), #enterRoomDirect)
  registerMessage(#setEnterRoomAlert, me.getID(), #setEnterRoomAlert)
  registerMessage(#removeEnterRoomAlert, me.getID(), #removeEnterRoomAlert)
  registerMessage(#show_hide_roomevents, me.getID(), #showHideRoomevents)
  registerMessage(#editRoomevent, me.getID(), #editRoomevent)
  pEnterDoorData = VOID
  pEnterDoorLocked = 0
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoomDirect, me.getID())
  unregisterMessage(#show_hide_roomevents, me.getID())
  unregisterMessage(#editRoomevent, me.getID())
  removeConnection(pRoomConnID)
  if listp(pUserObjList) then
    call(#deconstruct, pUserObjList)
  end if
  if listp(pActiveObjList) then
    call(#deconstruct, pActiveObjList)
  end if
  if listp(pPassiveObjList) then
    call(#deconstruct, pPassiveObjList)
  end if
  if listp(pItemObjList) then
    call(#deconstruct, pItemObjList)
  end if
  if objectExists(pBalloonId) then
    removeObject(pBalloonId)
  end if
  if objectExists(pClassContId) then
    removeObject(pClassContId)
  end if
  if objectExists(pRoomPrgID) then
    removeObject(pRoomPrgID)
  end if
  if objectExists(pAdSystemID) then
    removeObject(pAdSystemID)
  end if
  if objectExists(pInterstitialSystemID) then
    removeObject(pInterstitialSystemID)
  end if
  if objectExists(pSpectatorSystemID) then
    removeObject(pSpectatorSystemID)
  end if
  if objectExists(pShadowManagerID) then
    removeObject(pShadowManagerID)
  end if
  if objectExists(pGroupInfoID) then
    removeObject(pGroupInfoID)
  end if
  if objectExists(pOneWayDoorManagerID) then
    removeObject(pOneWayDoorManagerID)
  end if
  pRoomId = EMPTY
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pCurrentSlidingObjects = [:]
  pEnterRoomAlert = EMPTY
  return 1
end

on prepare me
  if pActiveFlag then
    pEnterDoorLocked = 1
    call(#update, pUserObjList)
    me.updateSlideObjects(the milliSeconds)
    call(#update, pActiveObjList)
    call(#update, pItemObjList)
    pEnterDoorLocked = 0
    if not voidp(pEnterDoorData) then
      me.enterDoor(pEnterDoorData)
      pEnterDoorData = VOID
    end if
  end if
end

on enterRoom me, tRoomDataStruct
  tStamp = EMPTY
  repeat with tNo = 1 to 100
    tChar = numToChar((random(48) + 74))
    tStamp = (tStamp & tChar)
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  repeat with tCharNo = 1 to tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = ((tChar * tCharNo) + 309203)
    tReceipt[tCharNo] = tChar
  end repeat
  if (tReceipt <> tFuseReceipt) then
    error(me, "Invalid build structure", #enterRoom, #critical)
    createTimeout(#builddisconnect, 3000, #disconnect, getThread(#login).getComponent().getID(), VOID, 1)
  end if
  if not listp(tRoomDataStruct) then
    error(me, "Invalid room data struct!", #enterRoom, #major)
    return executeMessage(#leaveRoom)
  end if
  getInterstitial().adRequested()
  me.getRoomConnection().send("GETINTERST", "general")
  tdata = tRoomDataStruct.duplicate()
  if voidp(tdata[#id]) then
    error(me, "Missing ID in room data struct!", #enterRoom, #major)
    return executeMessage(#leaveRoom)
  end if
  if (pRoomId <> EMPTY) then
    executeMessage(#changeRoom)
  end if
  tSession = getObject(#session)
  tSession.set("room_owner", 0)
  tSession.set("room_controller", 0)
  if (tdata[#type] = #private) then
    pRoomId = "private"
  else
    pRoomId = tdata[#id]
  end if
  pTrgDoorID = VOID
  pSaveData = tdata
  pCastLoaded = 0
  me.loadRoomCasts()
  return 1
end

on enterDoor me, tdata
  if not listp(tdata) then
    return error(me, "Room data struct expected!", #enterDoor, #major)
  end if
  if pEnterDoorLocked then
    pEnterDoorData = tdata
    return 1
  end if
  if (tdata[#id] <> pSaveData[#id]) then
    me.leaveRoom(1)
    tReConnect = 1
  else
    getObject(#session).set("target_door_ID", 0)
    tReConnect = 0
  end if
  tCurrentScale = me.getRoomScale(pSaveData[#marker])
  tCurrentRoomCasts = pSaveData[#casts]
  pRoomId = "private"
  pTrgDoorID = tdata[#id]
  pSaveData = tdata.duplicate()
  pSaveData[#type] = #private
  getObject(#session).set("lastroom", pSaveData.duplicate())
  if (((me.getRoomScale(pSaveData[#marker]) = #small) and (tCurrentScale = #large)) and not pPrvRoomsReady) then
    pSaveData[#casts] = tCurrentRoomCasts
    if voidp(tCurrentRoomCasts) then
      pSaveData[#casts] = ["hh_room_private"]
    end if
    me.loadRoomCasts()
    pPrvRoomsReady = 1
    return 0
  end if
  if tReConnect then
    return me.roomCastLoaded()
  else
    return me.getRoomConnection().send("GOVIADOOR", ((pTrgDoorID & "/") & pSaveData[#teleport]))
  end if
end

on leaveRoom me, tJumpingToSubUnit
  if (pRoomId = EMPTY) then
    return 0
  end if
  removePrepare(me.getID())
  if objectExists(pRoomPrgID) then
    removeObject(pRoomPrgID)
  end if
  if not pCacheFlag then
    getObject(#cache).Remove(pCacheKey)
  end if
  if objectExists(#furniChooser) then
    getObject(#furniChooser).close()
  end if
  pActiveFlag = 0
  if not tJumpingToSubUnit then
    pRoomId = EMPTY
  end if
  me.getShadowManager().disableRender(1)
  if listp(pUserObjList) then
    call(#deconstruct, pUserObjList)
  end if
  if listp(pActiveObjList) then
    call(#deconstruct, pActiveObjList)
  end if
  if listp(pPassiveObjList) then
    call(#deconstruct, pPassiveObjList)
  end if
  if listp(pItemObjList) then
    call(#deconstruct, pItemObjList)
  end if
  me.getShadowManager().disableRender(0)
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  if objectExists(pBalloonId) then
    getObject(pBalloonId).removeBalloons()
  end if
  me.getInterface().hideAll()
  getObject(#session).Remove("user_index")
  getObject(#session).set("room_owner", 0)
  getObject(#session).set("room_controller", 0)
  return 1
end

on enterRoomDirect me, tdata
  if (tdata[#type] = #private) then
    pRoomId = "private"
  else
    pRoomId = tdata[#id]
  end if
  pTrgDoorID = VOID
  pSaveData = tdata
  getObject(#session).set("lastroom", pSaveData)
  if (pSaveData[#type] = #private) then
    tRoomID = integer(pSaveData[#id])
    tDoorID = 0
    tTypeID = 0
  else
    tRoomID = integer(pSaveData[#port])
    tDoorID = integer(pSaveData[#door])
    tTypeID = 1
  end if
  if (tDoorID.ilk = #void) then
    tDoorID = 0
  end if
  return getConnection(pRoomConnID).send(#room_directory, [#boolean: tTypeID, #integer: tRoomID, #integer: tDoorID])
end

on createUserObject me, tdata
  if me.userObjectExists(tdata[#id]) then
    me.removeUserObject(tdata[#id])
  end if
  if me.createRoomObject(tdata, pUserObjList, "user") then
    return executeMessage(#create_user, tdata[#name], tdata[#id])
  else
    return 0
  end if
end

on removeUserObject me, tID
  if me.removeRoomObject(tID, pUserObjList) then
    return executeMessage(#remove_user, tID)
  else
    return 0
  end if
end

on getUserObject me, tID
  tObj = me.getRoomObject(tID, pUserObjList)
  return tObj
end

on getUsersRoomId me, tUserName
  tIndex = -1
  repeat with tPos = 1 to pUserObjList.count
    tuser = pUserObjList[tPos]
    tClass = tuser.getClass()
    if (tClass = "user") then
      if (tuser.getName() = tUserName) then
        tIndex = pUserObjList.getPropAt(tPos)
        exit repeat
      end if
    end if
  end repeat
  return tIndex
end

on userObjectExists me, tID
  return me.roomObjectExists(tID, pUserObjList)
end

on createActiveObject me, tdata
  if me.activeObjectExists(tdata[#id]) then
    me.removeActiveObject(tdata[#id])
  end if
  return me.createRoomObject(tdata, pActiveObjList, "active")
end

on removeActiveObject me, tID
  return me.removeRoomObject(tID, pActiveObjList)
end

on getActiveObject me, tID
  return me.getRoomObject(tID, pActiveObjList)
end

on activeObjectExists me, tID
  return me.roomObjectExists(tID, pActiveObjList)
end

on releaseSpritesFromActiveObjects me
  tRemoveCountMax = 100
  tActiveObjCount = (pActiveObjList.count - 1)
  tRemoveCount = min([tRemoveCountMax, tActiveObjCount])
  repeat with tNo = 1 to tRemoveCount
    tObject = pActiveObjList[tNo].deconstruct()
  end repeat
  createTimeout(#releaseactivetimeout, 3000, #releaseActiveTimeoutCallback, me.getID(), VOID, 1)
end

on releaseActiveTimeoutCallback me
  executeMessage(#alert, [#Msg: "alert_too_much_furnitures", #modal: 1])
end

on createPassiveObject me, tdata
  if me.passiveObjectExists(tdata[#id]) then
    me.removePassiveObject(tdata[#id])
  end if
  return me.createRoomObject(tdata, pPassiveObjList, "passive")
end

on removePassiveObject me, tID
  return me.removeRoomObject(tID, pPassiveObjList)
end

on getPassiveObject me, tID
  return me.getRoomObject(tID, pPassiveObjList)
end

on passiveObjectExists me, tID
  return me.roomObjectExists(tID, pPassiveObjList)
end

on createItemObject me, tdata
  if me.itemObjectExists(tdata[#id]) then
    me.removeItemObject(tdata[#id])
  end if
  return me.createRoomObject(tdata, pItemObjList, "item")
end

on removeItemObject me, tID
  return me.removeRoomObject(tID, pItemObjList)
end

on getItemObject me, tID
  return me.getRoomObject(tID, pItemObjList)
end

on itemObjectExists me, tID
  return me.roomObjectExists(tID, pItemObjList)
end

on setRoomRating me, tRoomRating, tRoomRatingPercent
  pFlatRatings[#rate] = tRoomRating
  pFlatRatings[#Percent] = tRoomRatingPercent
end

on getRoomRating me
  return pFlatRatings
end

on setRoomEvent me, tEventData
  pRoomEventCurrent = tEventData
  executeMessage(#roomEventInfoUpdated)
end

on getRoomEvent me
  return pRoomEventCurrent
end

on setRoomEventList me, ttype, tEvents
  pRoomEventList.setaProp(ttype, [#data: tEvents, #time: the milliSeconds])
  executeMessage(#roomEventsUpdated)
end

on getRoomEventList me, ttype
  if (ttype = 0) then
    return 0
  end if
  tEventList = pRoomEventList.getaProp(ttype)
  if not voidp(tEventList) then
    tAge = (the milliSeconds - tEventList.getaProp(#time))
  end if
  tCache = getIntVariable("roomevent.cache", 10000)
  if (voidp(tEventList) or (tAge > tCache)) then
    me.getRoomConnection().send("GET_ROOMEVENTS_BY_TYPE", [#integer: integer(ttype)])
    pRoomEventList.setaProp(ttype, [#data: [], #time: the milliSeconds])
  end if
  tEventList = pRoomEventList.getaProp(ttype)
  return tEventList.getaProp(#data)
end

on setRoomEventTypeCount me, tCount
  pRoomEventTypeCount = tCount
  executeMessage(#roomEventTypeCountUpdated)
end

on getRoomEventTypeCount me
  if voidp(pRoomEventTypeCount) then
    me.getRoomConnection().send("GET_ROOMEVENT_TYPE_COUNT")
    pRoomEventTypeCount = 0
  end if
  return pRoomEventTypeCount
end

on getRoomPrg me
  return getObject(pRoomPrgID)
end

on getRoomID me
  return pRoomId
end

on getRoomData me
  if voidp(pSaveData) then
    return 0
  else
    return pSaveData
  end if
end

on getRoomConnection me
  return getConnection(pRoomConnID)
end

on getBalloon me
  return getObject(pBalloonId)
end

on getAd me
  return getObject(pAdSystemID)
end

on getInterstitial me
  if objectExists(pInterstitialSystemID) then
    return getObject(pInterstitialSystemID)
  else
    return error(me, "Interstitial manager not found", #getInterstitial, #major)
  end if
end

on getClassContainer me
  return getObject(pClassContId)
end

on isCreditFurniClass me, tClass
  if getObject(pClassContId).exists(tClass) then
    tClasses = value(getObject(pClassContId).GET(tClass))
    if (tClasses.getOne("Credit Furni Class") > 0) then
      return 1
    end if
  end if
  return 0
end

on getOwnUser me
  return me.getUserObject(getObject(#session).GET("user_index"))
end

on getShadowManager me
  if objectExists(pShadowManagerID) then
    return getObject(pShadowManagerID)
  else
    return error(me, "Shadow manager not found", #getShadowManager, #major)
  end if
end

on getGroupInfoObject me
  return getObject(pGroupInfoID)
end

on roomExists me, tRoomID
  if voidp(tRoomID) then
    return pActiveFlag
  else
    return (pRoomId = tRoomID)
  end if
end

on sendChat me, tChat
  if voidp(tChat) then
    return 0
  end if
  if (tChat = EMPTY) then
    return 0
  end if
  tChat = convertSpecialChars(tChat, 1)
  if (tChat.char[1] = ":") then
    case tChat.word[1] of
      ":readytest":
        if getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
          return callJavascriptFunction("clientReady")
        end if
      ":jstest":
        if getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
          return callJavascriptFunction("hello", "JS Test")
        end if
      ":crashme":
        if getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
          tTemp = EMPTY
          return tTemp[#thisIsNotListAndWillCrash]
        end if
      ":chooser":
        if getObject(#session).GET("user_rights").getOne("fuse_habbo_chooser") then
          return createObject(#chooser, "User Chooser Class")
        end if
      ":furni":
        if (pSaveData[#type] <> #private) then
          return 1
        end if
        if getObject(#session).GET("user_rights").getOne("fuse_furni_chooser") then
          if not objectExists(pFurniChooserID) then
            createObject(pFurniChooserID, "Furni Chooser Class")
          end if
          if (getObject(pFurniChooserID) = 0) then
            return 0
          end if
          return getObject(pFurniChooserID).showList()
        end if
      ":performance":
        if getObject(#session).GET("user_rights").getOne("fuse_performance_panel") then
          return performance()
        end if
      ":editcatalogue":
        if getObject(#session).GET("user_rights").getOne("fuse_catalog_editor") then
          return executeMessage("edit_catalogue")
        end if
      ":copypaste":
        if getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
          the editShortcutsEnabled = 1
          return 1
        end if
      ":petcontrol":
        if getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
          petcontrol()
          return 1
        end if
      ":events":
        if variableExists("disable.roomevents") then
          if getIntVariable("disable.roomevents") then
            return 1
          end if
        end if
        if objectExists(pRoomEventBrowserID) then
          removeObject(pRoomEventBrowserID)
        else
          createObject(pRoomEventBrowserID, "RoomEvent Browser Class")
        end if
        return 1
      ":im":
        tName = tChat.word[2]
        tMsg = tChat.word[3]
        executeMessage(#startIMChat, tName, tMsg)
        return 1
      ":ig":
        executeMessage(#toggle_ig)
        return 1
    end case
  end if
  if getObject(#session).GET("user_rights").getOne("fuse_debug_window") then
    tKeywords = me.getInterface().getKeywords()
    case tChat.word[1] of
      ("!!" & tKeywords[1]), ("!!" & tKeywords[2]):
        tInfoID = getVariable("connection.info.id")
        getConnection(#Info).pD = 1
        the debugPlaybackEnabled = 1
        case tChat.word[1] of
          tKeywords[1]:
            if connectionExists(tInfoID) then
              getConnection(tInfoID).setLogMode(1)
            end if
          tKeywords[2]:
            if connectionExists(tInfoID) then
              getConnection(tInfoID).setLogMode(0)
            end if
        end case
        return 1
    end case
    tKeywords = VOID
  end if
  if the shiftDown then
    tMode = "SHOUT"
  else
    tMode = pChatProps["mode"]
  end if
  tSelected = me.getInterface().getSelectedObject()
  if me.userObjectExists(tSelected) then
    tSelected = me.getUserObject(tSelected).getName()
  else
    tSelected = EMPTY
  end if
  if pChatProps["hobbaCmds"].getOne(tChat.word[1]) then
    tMode = "CHAT"
    if (tChat.word[2] = "x") then
      if (tSelected = EMPTY) then
        tMode = "WHISPER"
        tMsg = getText("chat_user_not_found", "User not found.")
        tID = getObject(#session).GET("user_index")
        me.getComponent().getBalloon().enterChatMessage(tMode, tID, tMsg)
        return 1
      end if
      tOffsetX = offset("x", tChat)
      tChat = ((tChat.char[1] & tSelected) & tChat.char[(tOffsetX + 1)])
    end if
  else
    if (tMode = "WHISPER") then
      tChat = (tSelected && tChat)
    end if
  end if
  return me.getRoomConnection().send(tMode, [#string: tChat])
end

on setChatMode me, tMode, tUpdate
  case tMode of
    "whisper":
      pChatProps["mode"] = "WHISPER"
    "shout":
      pChatProps["mode"] = "SHOUT"
    otherwise:
      pChatProps["mode"] = "CHAT"
  end case
  if tUpdate then
    me.getInterface().setSpeechDropdown(tMode)
  end if
  return 1
end

on setUserTypingStatus me, tUserID, tStatus
  tUserObject = me.getUserObject(tUserID)
  if (tUserObject <> 0) then
    tUserObject.setUserTypingStatus(tStatus)
  end if
end

on print me
  put ((RETURN & "User objects:") & RETURN)
  repeat with i = 1 to pUserObjList.count
    put ((pUserObjList.getPropAt(i) & ":") && pUserObjList[i])
  end repeat
  put ((RETURN & "Active objects:") & RETURN)
  repeat with i = 1 to pActiveObjList.count
    put ((pActiveObjList.getPropAt(i) & ":") && pActiveObjList[i])
  end repeat
  put ((RETURN & "Passive objects:") & RETURN)
  repeat with i = 1 to pPassiveObjList.count
    put ((pPassiveObjList.getPropAt(i) & ":") && pPassiveObjList[i])
  end repeat
end

on addSlideObject me, tID, tFromLoc, tToLoc, tTimeNow, tHasCharacter
  if (the paramCount < 4) then
    return error(me, "Wrong parameter count", #addSlideObject, #major)
  end if
  tID = tID.string
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  if voidp(tHasCharacter) then
    tHasCharacter = 0
  end if
  if not voidp(pActiveObjList[tID]) then
    tObj = pActiveObjList[tID]
    tObj.setSlideTo(tFromLoc, tToLoc, tTimeNow, tHasCharacter)
    pCurrentSlidingObjects[tID] = tObj
  end if
end

on removeSlideObject me, tID
  tID = tID.string
  if not voidp(pCurrentSlidingObjects[tID]) then
    pCurrentSlidingObjects.deleteProp(tID)
  end if
end

on roomPrePartFinished me
  tInterstFinished = getInterstitial().isAdFinished()
  if ((pCastLoaded = 0) or (tInterstFinished = 0)) then
    return 0
  end if
  if (pSaveData[#type] = #private) then
    tRoomID = integer(pSaveData[#id])
    tDoorID = 0
    tTypeID = 0
  else
    tRoomID = integer(pSaveData[#port])
    tDoorID = integer(pSaveData[#door])
    tTypeID = 1
  end if
  if (tDoorID.ilk = #void) then
    tDoorID = 0
  end if
  return getConnection(pRoomConnID).send(#room_directory, [#boolean: tTypeID, #integer: tRoomID, #integer: tDoorID])
  return 1
end

on getSpectatorMode me
  tModeMgrObj = getObject(pSpectatorSystemID)
  if (tModeMgrObj = 0) then
    return error(me, "Spectator System missing!", #getSpectatorMode, #major)
  end if
  return tModeMgrObj.getSpectatorMode()
end

on setSpectatorMode me, tstate
  tModeMgrObj = getObject(pSpectatorSystemID)
  if (tModeMgrObj = 0) then
    return error(me, "Spectator System missing!", #setSpectatorMode, #major)
  end if
  if tstate then
    getObject(#session).set("user_index", -1000)
  end if
  tRoomData = me.getRoomData()
  if (tRoomData = 0) then
    tRoomType = #public
  else
    tRoomType = tRoomData[#type]
  end if
  return tModeMgrObj.setSpectatorMode(tstate, tRoomType)
end

on pickAndGoCFH me, tSender
  if not stringp(tSender) then
    return 0
  end if
  pPickedCryName = tSender
  return 1
end

on getPickedCryName me
  return pPickedCryName
end

on showCfhSenderDelayed me, tID
  pPickedCryName = EMPTY
  return me.getInterface().showCfhSenderDelayed(tID)
end

on updateCharacterFigure me, tUserID, tUserFigure, tsex, tUserCustomInfo
  if ((voidp(tUserID) or voidp(tUserFigure)) or voidp(tUserCustomInfo)) then
    return 0
  end if
  tUserID = string(tUserID)
  tSession = getObject(#session)
  tFigureParser = getObject("Figure_System")
  tParsedFigure = tFigureParser.parseFigure(tUserFigure, tsex, "user")
  if ((tSession.GET("user_index") = tUserID) or (tUserID = "-1")) then
    tSession.set("user_figure", tParsedFigure)
    tSession.set("user_sex", tsex)
    tSession.set("user_customData", tUserCustomInfo)
  end if
  if ((tSession.GET("lastroom") = "Entry") and (tUserID = "-1")) then
    executeMessage(#updateFigureData)
  else
    if (not (tSession.GET("lastroom") = "Entry") and (integer(tUserID) > -1)) then
      if voidp(pUserObjList[tUserID]) then
        return 0
      end if
      tUserObj = pUserObjList[tUserID]
      tloc = tUserObj.getLocation()
      tdir = tUserObj.getDirection()
      tuser = [:]
      tuser[#figure] = tParsedFigure
      tuser[#custom] = tUserCustomInfo
      tuser[#sex] = tsex
      tUserObj.changeFigureAndData(tuser)
      tScale = #large
      if (me.getInterface().getGeometry().getTileWidth() < 64) then
        tScale = #small
      end if
      tChangeEffect = createObject(#random, "Change Clothes Effect Class")
      tUserSprites = tUserObj.getSprites()
      tChangeEffect.defineWithSprite(tUserSprites[1], tScale)
      executeMessage(#updateInfostandAvatar, tUserObj)
    end if
  end if
end

on updateSpectatorCount me, tSpectatorCount, tSpectatorMax
  tModeMgrObj = getObject(pSpectatorSystemID)
  if (tModeMgrObj = 0) then
    return error(me, "Spectator System missing!", #updateSpectatorCount, #major)
  end if
  tModeMgrObj.updateSpectatorCount(tSpectatorCount, tSpectatorMax)
end

on highlightUser me, tUserID
  repeat with tuser in pUserObjList
    if (tuser.getWebID() = tUserID) then
      me.getInterface().eventProcUserObj(#mouseUp, tuser.getID())
      exit repeat
    end if
  end repeat
end

on showHideRoomevents me
  if objectExists(pRoomEventBrowserID) then
    removeObject(pRoomEventBrowserID)
  else
    createObject(pRoomEventBrowserID, "RoomEvent Browser Class")
  end if
  return 1
end

on editRoomevent me
  if not objectExists(pRoomEventBrowserID) then
    createObject(pRoomEventBrowserID, "RoomEvent Browser Class")
  end if
  getObject(pRoomEventBrowserID).editEvent(pRoomEventCurrent)
end

on getIconBarManager me
  if not objectExists(pIconBarManagerID) then
    createObject(pIconBarManagerID, "Room Bar Extensions Manager")
  end if
  return getObject(pIconBarManagerID)
end

on removeIconBarManager me
  if objectExists(pIconBarManagerID) then
    removeObject(pIconBarManagerID)
  end if
end

on setRoomProperty me, tKey, tValue
  case tKey of
    "wallpaper", "floor":
      tRoomPrg = me.getRoomPrg()
      if (tRoomPrg <> 0) then
        tRoomPrg.setProperty(tKey, tValue)
      end if
    "landscape":
      me.setLandscape(tValue)
    "landscapeanim":
      me.setLandscapeAnimation(tValue)
  end case
end

on insertWallMaskItem me, tID, tClassID, tloc, tdir, tSize
  if (me.getRoomID() <> "private") then
    return 0
  end if
  tObj = me.getRoomPrg()
  if objectp(tObj) then
    call(#insertWallMaskItem, [tObj], tID, tClassID, tloc, tdir, tSize)
  end if
end

on removeWallMaskItem me, tID
  if (me.getRoomID() <> "private") then
    return 0
  end if
  tObj = me.getRoomPrg()
  if objectp(tObj) then
    call(#removeWallMaskItem, [tObj], tID)
  end if
end

on getRoomModel me
  return pSaveData[#marker]
end

on setLandscape me, tID
  if (me.getRoomID() <> "private") then
    return 0
  end if
  tRoomType = me.getRoomModel()
  tObj = me.getRoomPrg()
  if objectp(tObj) then
    call(#setLandscape, [tObj], tID, tRoomType)
  end if
end

on setLandscapeAnimation me, tID
  if (me.getRoomID() <> "private") then
    return 0
  end if
  tRoomType = me.getRoomModel()
  tObj = me.getRoomPrg()
  if objectp(tObj) then
    call(#setLandscapeAnimation, [tObj], tID, tRoomType)
  end if
end

on loadRoomCasts me
  if (pRoomId = EMPTY) then
    return 0
  end if
  tCastVarPrefix = "room.cast."
  tCastList = me.addToCastDownloadList(tCastVarPrefix, tCastList)
  if (pSaveData[#type] = #public) then
    pPrvRoomsReady = 0
  end if
  if (pSaveData[#type] = #private) then
    if (me.getRoomScale(pSaveData[#marker]) = #small) then
      tCastVarPrefix = "room.cast.small."
      tCastList = me.addToCastDownloadList(tCastVarPrefix, tCastList)
      pPrvRoomsReady = 1
    end if
  end if
  if (tCastList.count > 0) then
    tCastLoadId = startCastLoad(tCastList, 1)
    registerCastloadCallback(tCastLoadId, #loadRoomCasts, me.getID())
    me.getInterface().showLoaderBar(tCastLoadId, getText("room_hold", getText("room_loading", "Hold on...")))
    return 1
  end if
  if voidp(pSaveData[#casts]) then
    pSaveData[#casts] = []
  end if
  if (pSaveData[#casts].count < 1) then
    error(me, ("Cast for room not defined:" && pRoomId), #loadRoomCasts, #major)
    me.getInterface().hideLoaderBar()
    executeMessage(#leaveRoom)
  end if
  tCastLoadId = startCastLoad(pSaveData[#casts], 0)
  registerCastloadCallback(tCastLoadId, #roomCastLoaded, me.getID())
  me.getInterface().showLoaderBar(tCastLoadId, ((((getText("room_loading", "Loading room") & RETURN) & QUOTE) & pSaveData[#name]) & QUOTE))
  return 1
end

on roomCastLoaded me
  if (pRoomId = EMPTY) then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return error(me, "Room building process is aborted!", #roomCastLoaded, #major)
  end if
  if voidp(pTrgDoorID) then
    tTxt = getText("room_preparing", "...preparing room.")
    if (pSaveData[#type] = #private) then
      if (pSaveData[#door] = "closed") then
        if (pSaveData[#owner] <> getObject(#session).GET("user_name")) then
          tTxt = getText("room_waiting", "...waiting.")
        end if
      end if
    end if
    me.getInterface().showLoaderBar(VOID, ((((QUOTE & pSaveData[#name]) & QUOTE) & RETURN) & tTxt))
    tRoomCasts = pSaveData[#casts]
    repeat with tCast in tRoomCasts
      if not castExists(tCast) then
        error(me, ("Cast required by room not found:" && tCast), #roomCastLoaded, #major)
        return executeMessage(#leaveRoom)
      end if
    end repeat
  end if
  pCastLoaded = 1
  me.roomPrePartFinished()
end

on roomConnected me, tMarker, tstate
  if (pRoomId = EMPTY) then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return error(me, "Room building process is aborted!", #roomConnected, #major)
  end if
  if not voidp(pTrgDoorID) then
    if (tstate = "OPC_OK") then
      tValue = me.getRoomConnection().send("GOVIADOOR", ((pTrgDoorID & "/") & pSaveData[#teleport]))
      pTrgDoorID = VOID
      return tValue
    end if
  end if
  if (pSaveData[#type] = #private) then
    if (tstate = "OPC_OK") then
      tStr = pSaveData[#id]
      if threadExists(#navigator) then
        tPassword = getThread(#navigator).getComponent().getFlatPassword(pSaveData[#id])
        if (tPassword <> 0) then
          tStr = ((tStr & "/") & tPassword)
        end if
      end if
      return me.getRoomConnection().send("TRYFLAT", tStr)
    else
      if (tstate = "FLAT_LETIN") then
        return me.getRoomConnection().send("GOTOFLAT", pSaveData[#id])
      end if
    end if
  end if
  if voidp(tMarker) then
    error(me, "Missing room marker!!!", #roomConnected, #major)
  end if
  pSaveData[#marker] = tMarker
  me.leaveRoom(1)
  if not me.getInterface().showRoom(tMarker) then
    return executeMessage(#leaveRoom)
  end if
  if connectionExists(pRoomConnID) then
    getConnection(pRoomConnID).send("GETROOMAD")
  end if
  if memberExists((pSaveData[#marker] && "Class")) then
    createObject(pRoomPrgID, (pSaveData[#marker] && "Class"))
  end if
  if (pSaveData[#type] = #private) then
    pProcessList = [#passive: 0, #Active: 0, #users: 0, #items: 0, #heightmap: 0]
  else
    if (pSaveData[#type] = #public) then
      pProcessList = [#passive: 0, #Active: 0, #users: 0, #items: 1, #heightmap: 0]
    else
      if (pSaveData[#type] = #game) then
        pProcessList = [#passive: 1, #Active: 1, #users: 1, #items: 1, #heightmap: 0]
      end if
    end if
  end if
  pCacheKey = ((("room_data_" & pRoomId) & "_") & pSaveData[#marker])
  if not getObject(#cache).exists(pCacheKey) then
    getObject(#cache).set(pCacheKey, [:])
  end if
  tCache = getObject(#cache).GET(pCacheKey)
  if (voidp(tCache[#heightmap]) and not pProcessList[#heightmap]) then
    tCache[#heightmap] = EMPTY
    me.getRoomConnection().send("G_HMAP")
  else
    me.validateHeightMap(tCache[#heightmap])
  end if
  tShadowManager = me.getShadowManager()
  tShadowManager.define("roomShadow")
  tCache[#users] = []
  if not pProcessList[#users] then
    me.getRoomConnection().send("G_USRS")
  end if
  if (voidp(tCache[#passive]) and not pProcessList[#passive]) then
    tCache[#passive] = []
    me.getRoomConnection().send("G_OBJS")
  else
    if voidp(tCache[#passive]) then
      tCache[#passive] = []
    end if
    me.validatePassiveObjects(0)
  end if
  if (voidp(tCache[#Active]) and not pProcessList[#Active]) then
    tCache[#Active] = []
  else
    if voidp(tCache[#Active]) then
      tCache[#Active] = []
    end if
    me.validateActiveObjects(0)
  end if
  if (voidp(tCache[#items]) and not pProcessList[#items]) then
    tCache[#items] = []
    me.getRoomConnection().send("G_ITEMS")
  else
    if voidp(tCache[#items]) then
      tCache[#items] = []
    end if
    me.validateItemObjects(0)
  end if
  createTimeout(pRoomPollerID, 1000, #pollRoomMessages, me.getID(), VOID, 0)
  me.executeEnterRoomAlert()
  return 1
end

on roomDisconnected me
  pPrvRoomsReady = 0
  me.leaveRoom()
  return executeMessage(#leaveRoom)
end

on validateHeightMap me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateHeightMap, #major)
  end if
  me.getInterface().getGeometry().loadHeightMap(tdata)
  me.pHeightMapData = tdata
  if not pActiveFlag then
    getObject(#cache).GET(pCacheKey).setaProp(#heightmap, tdata)
    me.updateProcess(#heightmap, 1)
  end if
  return 0
end

on updateHeightMap me, tdata
  tHeightMapData = pHeightMapData
  if voidp(tHeightMapData) then
    return error(me, "Height map update data sent but heightmap data not cached!", #updateHeightMap, #major)
  else
    a = 1
    repeat with i = 1 to tdata.length
      if (tdata.char[i] = "!") then
        i = (i + 1)
        a = (a + charToNum(tdata.char[i]))
        next repeat
      end if
      put tdata.char[i] into tHeightMapData.char[a]
      a = (a + 1)
    end repeat
    return validateHeightMap(me, tHeightMapData)
  end if
end

on validateUserObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateUserObjects, #major)
  end if
  if (tdata <> 0) then
    getObject(#cache).GET(pCacheKey).getaProp(#users).add(tdata)
  end if
  if (pActiveFlag and (tdata <> 0)) then
    me.createUserObject(tdata)
  else
    me.updateProcess(#users, 1)
  end if
  return 1
end

on validateActiveObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateActiveObjects, #major)
  end if
  if (tdata <> 0) then
    getObject(#cache).GET(pCacheKey).getaProp(#Active).add(tdata)
  end if
  if (pActiveFlag and (tdata <> 0)) then
    me.createActiveObject(tdata)
  else
    me.updateProcess(#Active, 1)
  end if
  return 1
end

on validatePassiveObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validatePassiveObjects, #major)
  end if
  if (tdata <> 0) then
    getObject(#cache).GET(pCacheKey).getaProp(#passive).add(tdata)
  end if
  if (pActiveFlag and (tdata <> 0)) then
    me.createPassiveObject(tdata)
  else
    me.updateProcess(#passive, 1)
  end if
  return 1
end

on validateItemObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateItemObjects, #major)
  end if
  if (tdata <> 0) then
    getObject(#cache).GET(pCacheKey).getaProp(#items).add(tdata)
  end if
  if (pActiveFlag and (tdata <> 0)) then
    me.createItemObject(tdata)
  else
    me.updateProcess(#items, 1)
  end if
  return 1
end

on pollRoomMessages me
  if (not me.getRoomConnection() and timeoutExists(pRoomPollerID)) then
    return removeTimeout(pRoomPollerID)
  end if
  if (me.getRoomConnection().getWaitingMessagesCount() > 0) then
    me.getRoomConnection().processWaitingMessages()
  end if
end

on updateProcess me, tKey, tValue
  if pActiveFlag then
    return error(me, "Attempted to remake room!", #updateProcess, #major)
  end if
  if (pProcessList[tKey] = 0) then
    pProcessList[tKey] = tValue
  end if
  repeat with tProcess in pProcessList
    if not tProcess then
      exit repeat
    end if
  end repeat
  if (tProcess = 1) then
    if timeoutExists(pRoomPollerID) then
      removeTimeout(pRoomPollerID)
    end if
    tCache = getObject(#cache).GET(pCacheKey)
    repeat with tdata in tCache[#passive]
      me.createPassiveObject(tdata)
    end repeat
    me.getShadowManager().disableRender(1)
    repeat with tdata in tCache[#Active]
      me.createActiveObject(tdata)
    end repeat
    me.getShadowManager().disableRender(0)
    me.getShadowManager().render()
    repeat with tdata in tCache[#items]
      me.createItemObject(tdata)
    end repeat
    repeat with tdata in tCache[#users]
      me.createUserObject(tdata)
    end repeat
    tCache[#users] = []
    tCache[#Active] = []
    tCache[#items] = []
    me.getInterface().showRoomBar()
    me.getInterface().hideLoaderBar()
    me.getInterface().hideTrashCover()
    pActiveFlag = 1
    pChatProps["mode"] = "CHAT"
    setcursor(#arrow)
    call(#prepare, [me.getRoomPrg()])
    executeMessage(#roomReady)
    me.getRoomConnection().send("G_STAT")
    return receivePrepare(me.getID())
  end if
  return 0
end

on createRoomObject me, tdata, tList, tClass
  if (tdata = 0) then
    return 0
  end if
  if (voidp(tdata[#id]) or not listp(tList)) then
    return error(me, "Invalid arguments in object creation!", #createRoomObject, #major)
  end if
  if not voidp(tList[tdata[#id]]) then
    return error(me, ("Object already exists:" && tdata[#id]), #createRoomObject, #major)
  end if
  if voidp(tClass) then
    tClass = "passive"
  end if
  tdata = getThread(#buffer).getComponent().processObject(tdata, tClass)
  tCustomCls = tdata[#class]
  if (tCustomCls contains "*") then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tCustomCls = tCustomCls.item[1]
    the itemDelimiter = tDelim
  end if
  if not voidp(tdata[#type]) then
    if getObject(pClassContId).exists((tCustomCls & tdata[#type])) then
      tCustomCls = (tCustomCls & tdata[#type])
    end if
  end if
  if getObject(pClassContId).exists(tCustomCls) then
    tClasses = value(getObject(pClassContId).GET(tCustomCls))
  else
    tClasses = value(getObject(pClassContId).GET(tClass))
  end if
  tObject = createObject(#temp, tClasses)
  if not objectp(tObject) then
    return error(me, ("Failed to create room object:" && tdata), #createRoomObject, #major)
  end if
  tObject.setID(tdata[#id])
  tSuccess = tObject.define(tdata.duplicate())
  if not tSuccess then
    tObject.deconstruct()
    return error(me, ("Failed to define room object:" && tdata), #createRoomObject, #major)
  end if
  tList[tObject.getID()] = tObject
  return 1
end

on removeRoomObject me, tID, tList
  if voidp(tList[tID]) then
    return error(me, ("Object not found:" && tID), #removeRoomObject, #minor)
  end if
  tList[tID].deconstruct()
  tList.deleteProp(tID)
  return 1
end

on getRoomObject me, tID, tList
  if (tID = #list) then
    return tList
  end if
  if voidp(tList.getaProp(tID)) then
    return 0
  else
    return tList.getaProp(tID)
  end if
end

on roomObjectExists me, tID, tList
  if not (listp(tList) or voidp(tID)) then
    return 0
  end if
  if (ilk(tID) = #string) then
    if (tID = EMPTY) then
      return 0
    end if
  else
    if (tID < 1) then
      return 0
    end if
  end if
  return not voidp(tList[tID])
end

on startTeleport me, tTeleId, tFlatID
  getObject(#session).set("target_door_ID", tTeleId)
  getObject(#session).set("target_flat_ID", tFlatID)
  return executeMessage(#requestRoomData, tFlatID, #private, [me.getID(), #processTeleportStruct])
end

on processTeleportStruct me, tFlatStruct
  if not listp(tFlatStruct) then
    return 0
  end if
  tFlatStruct = tFlatStruct.duplicate()
  tFlatStruct[#id] = tFlatStruct[#flatId]
  tFlatStruct.addProp(#teleport, getObject(#session).GET("target_door_ID"))
  getObject(#session).Remove("target_flat_id")
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).GET("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if (tDoorObj <> 0) then
      tDoorObj.startTeleport(tFlatStruct)
    end if
  end if
end

on updateSlideObjects me, tTimeNow
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  tList = pCurrentSlidingObjects.duplicate()
  call(#animateSlide, tList, tTimeNow)
end

on setEnterRoomAlert me, tMsg
  pEnterRoomAlert = tMsg
end

on executeEnterRoomAlert me
  if (pEnterRoomAlert.length > 0) then
    executeMessage(#alert, [#Msg: pEnterRoomAlert])
    pEnterRoomAlert = EMPTY
  end if
end

on removeEnterRoomAlert me
  pEnterRoomAlert = EMPTY
end

on getRoomScale me, tRoomMarker
  if voidp(tRoomMarker) then
    return 0
  end if
  tRoomProps = getVariableValue("private.room.properties")
  if voidp(tRoomProps) then
    return 0
  end if
  tRoomKey = chars(tRoomMarker, tRoomMarker.length, tRoomMarker.length)
  repeat with tRoom in tRoomProps
    if (tRoom[#model] = tRoomKey) then
      return tRoom[#charScale]
    end if
  end repeat
  return 0
end

on addToCastDownloadList me, tCastVarPrefix, tCastList
  if (voidp(tCastList) or not listp(tCastList)) then
    tCastList = []
  end if
  i = 1
  repeat while 1
    if variableExists((tCastVarPrefix & i)) then
      tCast = getVariable((tCastVarPrefix & i))
      if not castExists(tCast) then
        tCastList.add(tCast)
      end if
    else
      exit repeat
    end if
    i = (i + 1)
  end repeat
  return tCastList
end
