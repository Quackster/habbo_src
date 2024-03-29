property pInfoConnID, pRoomConnID, pRoomId, pActiveFlag, pProcessList, pChatProps, pSaveData, pCacheKey, pCacheFlag, pUserObjList, pActiveObjList, pPassiveObjList, pItemObjList, pBalloonId, pClassContId, pRoomPrgID, pRoomPollerID, pTrgDoorID, pAdSystemID, pHeightMapData, pCurrentSlidingObjects

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
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pBalloonId = "Room Balloon"
  pClassContId = "Room Classes"
  pRoomPrgID = "Room Program"
  pRoomPollerID = "Room Poller"
  pAdSystemID = "Room ad"
  pChatProps = [:]
  pChatProps["returnCount"] = 0
  pChatProps["timerStart"] = 0
  pChatProps["timerDelay"] = 0
  pChatProps["mode"] = "CHAT"
  pChatProps["hobbaCmds"] = getVariableValue("moderator.cmds")
  createObject(pClassContId, getClassVariable("variable.manager.class"))
  getObject(pClassContId).dump("fuse.object.classes", RETURN)
  createObject(pBalloonId, "Balloon Manager")
  createObject(pAdSystemID, "Ad Manager")
  pCurrentSlidingObjects = [:]
  registerMessage(#enterRoom, me.getID(), #enterRoom)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
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
  pRoomId = EMPTY
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pCurrentSlidingObjects = [:]
  return 1
end

on prepare me
  if pActiveFlag then
    call(#update, pUserObjList)
    me.updateSlideObjects(the milliSeconds)
    call(#update, pActiveObjList)
  end if
end

on enterRoom me, tRoomDataStruct
  if not listp(tRoomDataStruct) then
    error(me, "Invalid room data struct!", #enterRoom)
    return executeMessage(#leaveRoom)
  end if
  me.getRoomConnection().send("GET_ADV", "general")
  tdata = tRoomDataStruct.duplicate()
  if voidp(tdata[#id]) then
    error(me, "Missing ID in room data struct!", #enterRoom)
    return executeMessage(#leaveRoom)
  end if
  if pRoomId <> EMPTY then
    executeMessage(#changeRoom)
  end if
  tSession = getObject(#session)
  tSession.set("room_owner", 0)
  tSession.set("room_controller", 0)
  if tdata[#type] = #private then
    pRoomId = "private"
  else
    pRoomId = tdata[#id]
  end if
  pTrgDoorID = VOID
  pSaveData = tdata
  me.loadRoomCasts()
  return 1
end

on enterDoor me, tdata
  if not listp(tdata) then
    return error(me, "Room data struct expected!", #enterDoor)
  end if
  if tdata[#id] <> pSaveData[#id] then
    me.leaveRoom(1)
    tReConnect = 1
  else
    getObject(#session).set("target_door_ID", 0)
    tReConnect = 0
  end if
  pRoomId = "private"
  pTrgDoorID = tdata[#id]
  pSaveData = tdata.duplicate()
  pSaveData[#type] = #private
  getObject(#session).set("lastroom", pSaveData.duplicate())
  if tReConnect then
    return me.roomCastLoaded()
  else
    return me.getRoomConnection().send("GOVIADOOR", pTrgDoorID & "/" & pSaveData[#teleport])
  end if
end

on leaveRoom me, tJumpingToSubUnit
  if pRoomId = EMPTY then
    return 0
  end if
  removePrepare(me.getID())
  if objectExists(pRoomPrgID) then
    removeObject(pRoomPrgID)
  end if
  if not pCacheFlag then
    getObject(#cache).remove(pCacheKey)
  end if
  if objectp(me.getInterface().pIgnoreListObj) then
    me.getInterface().pIgnoreListObj.reset()
  end if
  if objectExists(#furniChooser) then
    getObject(#furniChooser).close()
  end if
  pActiveFlag = 0
  if not tJumpingToSubUnit then
    pRoomId = EMPTY
  end if
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
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  if objectExists(pBalloonId) then
    getObject(pBalloonId).removeBalloons()
  end if
  me.getInterface().hideAll()
  getObject(#session).set("room_owner", 0)
  getObject(#session).set("room_controller", 0)
  return 1
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

on removeUserObject me, tid
  if me.removeRoomObject(tid, pUserObjList) then
    return executeMessage(#remove_user, tid)
  else
    return 0
  end if
end

on getUserObject me, tid
  return me.getRoomObject(tid, pUserObjList)
end

on userObjectExists me, tid
  return me.roomObjectExists(tid, pUserObjList)
end

on createActiveObject me, tdata
  if me.activeObjectExists(tdata[#id]) then
    me.removeActiveObject(tdata[#id])
  end if
  return me.createRoomObject(tdata, pActiveObjList, "active")
end

on removeActiveObject me, tid
  return me.removeRoomObject(tid, pActiveObjList)
end

on getActiveObject me, tid
  return me.getRoomObject(tid, pActiveObjList)
end

on activeObjectExists me, tid
  return me.roomObjectExists(tid, pActiveObjList)
end

on createPassiveObject me, tdata
  if me.passiveObjectExists(tdata[#id]) then
    me.removePassiveObject(tdata[#id])
  end if
  return me.createRoomObject(tdata, pPassiveObjList, "passive")
end

on removePassiveObject me, tid
  return me.removeRoomObject(tid, pPassiveObjList)
end

on getPassiveObject me, tid
  return me.getRoomObject(tid, pPassiveObjList)
end

on passiveObjectExists me, tid
  return me.roomObjectExists(tid, pPassiveObjList)
end

on createItemObject me, tdata
  if me.itemObjectExists(tdata[#id]) then
    me.removeItemObject(tdata[#id])
  end if
  return me.createRoomObject(tdata, pItemObjList, "item")
end

on removeItemObject me, tid
  return me.removeRoomObject(tid, pItemObjList)
end

on getItemObject me, tid
  return me.getRoomObject(tid, pItemObjList)
end

on itemObjectExists me, tid
  return me.roomObjectExists(tid, pItemObjList)
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

on getClassContainer me
  return getObject(pClassContId)
end

on getOwnUser me
  return me.getUserObject(getObject(#session).get("user_index"))
end

on roomExists me, tRoomId
  if voidp(tRoomId) then
    return pActiveFlag
  else
    return pRoomId = tRoomId
  end if
end

on sendChat me, tChat
  if voidp(tChat) then
    return 0
  end if
  if tChat = EMPTY then
    return 0
  end if
  tChat = getStringServices().convertSpecialChars(tChat, 1)
  if tChat.char[1] = ":" then
    case tChat.word[1] of
      ":chooser":
        if getObject(#session).get("user_rights").getOne("fuse_habbo_chooser") then
          return createObject(#chooser, "User Chooser Class")
        end if
      ":furni":
        if getObject(#session).get("user_rights").getOne("fuse_furni_chooser") then
          createObject(#furniChooser, "Furni Chooser Class")
          if getObject(#furniChooser) = 0 then
            return 0
          end if
          return getObject(#furniChooser).showList()
        end if
      ":performance":
        if getObject(#session).get("user_rights").getOne("fuse_performance_panel") then
          return performance()
        end if
      ":debug", ":log":
        if getObject(#session).get("user_rights").getOne("fuse_debug_window") then
          if float((the productVersion).char[1..3]) >= 8.5 then
            the debugPlaybackEnabled = 1
          end if
          tInfoID = getVariable("connection.info.id")
          case tChat.word[1] of
            ":log":
              if connectionExists(tInfoID) then
                getConnection(tInfoID).setLogMode(1)
              end if
            ":debug":
              if connectionExists(tInfoID) then
                getConnection(tInfoID).setLogMode(0)
              end if
          end case
          return 1
        end if
      ":editcatalogue":
        if getObject(#session).get("user_rights").getOne("fuse_catalog_editor") then
          return executeMessage("edit_catalogue")
        end if
      ":copypaste":
        if getObject(#session).get("user_rights").getOne("fuse_debug_window") then
          the editShortcutsEnabled = 1
          return 1
        end if
    end case
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
  if pChatProps["hobbaCmds"].getOne(tChat.word[1..2]) then
    tMode = "CHAT"
    if (tChat.word[2] = "x") and (tSelected <> EMPTY) then
      tOffsetX = offset("x", tChat)
      tChat = tChat.char[1..tOffsetX - 1] & tSelected & tChat.char[tOffsetX + 1..tChat.length]
    end if
  else
    if tMode = "WHISPER" then
      tChat = tSelected && tChat
    end if
  end if
  return me.getRoomConnection().send(tMode, [#string: tChat])
end

on setChatMode me, tMode
  case tMode of
    "whisper":
      pChatProps["mode"] = "WHISPER"
    "shout":
      pChatProps["mode"] = "SHOUT"
    otherwise:
      pChatProps["mode"] = "CHAT"
  end case
  return 1
end

on print me
  put RETURN & "User objects:" & RETURN
  repeat with i = 1 to pUserObjList.count
    put pUserObjList.getPropAt(i) & ":" && pUserObjList[i]
  end repeat
  put RETURN & "Active objects:" & RETURN
  repeat with i = 1 to pActiveObjList.count
    put pActiveObjList.getPropAt(i) & ":" && pActiveObjList[i]
  end repeat
  put RETURN & "Passive objects:" & RETURN
  repeat with i = 1 to pPassiveObjList.count
    put pPassiveObjList.getPropAt(i) & ":" && pPassiveObjList[i]
  end repeat
end

on addSlideObject me, tid, tFromLoc, tToLoc, tTimeNow, tHasCharacter
  if the paramCount < 4 then
    return error(me, "Wrong parameter count", #addSlideObject)
  end if
  tid = tid.string
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  if voidp(tHasCharacter) then
    tHasCharacter = 0
  end if
  if not voidp(pActiveObjList[tid]) then
    tObj = pActiveObjList[tid]
    tObj.setSlideTo(tFromLoc, tToLoc, tTimeNow, tHasCharacter)
    pCurrentSlidingObjects[tid] = tObj
  end if
end

on removeSlideObject me, tid
  tid = tid.string
  if not voidp(pCurrentSlidingObjects[tid]) then
    pCurrentSlidingObjects.deleteProp(tid)
  end if
end

on loadRoomCasts me
  if pRoomId = EMPTY then
    return 0
  end if
  tCastList = []
  i = 1
  repeat while 1
    if variableExists("room.cast." & i) then
      tCast = getVariable("room.cast." & i)
      if not castExists(tCast) then
        tCastList.add(tCast)
      end if
    else
      exit repeat
    end if
    i = i + 1
  end repeat
  if tCastList.count > 0 then
    tCastLoadId = startCastLoad(tCastList, 1)
    registerCastloadCallback(tCastLoadId, #loadRoomCasts, me.getID())
    me.getInterface().showLoaderBar(tCastLoadId, getText("room_hold", getText("room_loading", "Hold on...")))
    return 1
  end if
  if voidp(pSaveData[#casts]) then
    pSaveData[#casts] = []
  end if
  if pSaveData[#casts].count < 1 then
    error(me, "Cast for room not defined:" && pRoomId, #loadRoomCasts)
    executeMessage(#leaveRoom)
  end if
  tCastLoadId = startCastLoad(pSaveData[#casts], 0)
  registerCastloadCallback(tCastLoadId, #roomCastLoaded, me.getID())
  me.getInterface().showLoaderBar(tCastLoadId, getText("room_loading", "Loading room") & RETURN & QUOTE & pSaveData[#name] & QUOTE)
  return 1
end

on roomCastLoaded me
  if pRoomId = EMPTY then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return error(me, "Room building process is aborted!", #roomCastLoaded)
  end if
  if voidp(pTrgDoorID) then
    tTxt = getText("room_preparing", "...preparing room.")
    if pSaveData[#type] = #private then
      if pSaveData[#door] = "closed" then
        if pSaveData[#owner] <> getObject(#session).get("user_name") then
          tTxt = getText("room_waiting", "...waiting.")
        end if
      end if
    end if
    me.getInterface().showLoaderBar(VOID, QUOTE & pSaveData[#name] & QUOTE & RETURN & tTxt)
    tRoomCasts = pSaveData[#casts]
    repeat with tCast in tRoomCasts
      if not castExists(tCast) then
        error(me, "Cast required by room not found:" && tCast, #roomCastLoaded)
        return executeMessage(#leaveRoom)
      end if
    end repeat
  end if
  if pSaveData[#type] = #private then
    tRoomId = integer(pSaveData[#id])
    tDoorID = 0
    tTypeID = 0
  else
    tRoomId = integer(pSaveData[#port])
    tDoorID = integer(pSaveData[#door])
    tTypeID = 1
  end if
  if tDoorID.ilk = #void then
    tDoorID = 0
  end if
  return getConnection(pRoomConnID).send(#room_directory, [#boolean: tTypeID, #integer: tRoomId, #integer: tDoorID])
end

on roomConnected me, tMarker, tstate
  if pRoomId = EMPTY then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return error(me, "Room building process is aborted!", #roomCastLoaded)
  end if
  if not voidp(pTrgDoorID) then
    if tstate = "OPC_OK" then
      tValue = me.getRoomConnection().send("GOVIADOOR", pTrgDoorID & "/" & pSaveData[#teleport])
      pTrgDoorID = VOID
      return tValue
    end if
  end if
  if pSaveData[#type] = #private then
    if tstate = "OPC_OK" then
      tStr = pSaveData[#id]
      if threadExists(#navigator) then
        tPassword = getThread(#navigator).getComponent().getFlatPassword(pSaveData[#id])
        if tPassword <> 0 then
          tStr = tStr & "/" & tPassword
        end if
      end if
      return me.getRoomConnection().send("TRYFLAT", tStr)
    else
      if tstate = "FLAT_LETIN" then
        return me.getRoomConnection().send("GOTOFLAT", pSaveData[#id])
      end if
    end if
  end if
  if voidp(tMarker) then
    error(me, "Missing room marker!!!", #roomConnected)
  end if
  pSaveData[#marker] = tMarker
  me.leaveRoom(1)
  if not me.getInterface().showRoom(tMarker) then
    return executeMessage(#leaveRoom)
  end if
  if connectionExists(pRoomConnID) then
    getConnection(pRoomConnID).send("GETROOMAD")
  end if
  if memberExists(pSaveData[#marker] && "Class") then
    createObject(pRoomPrgID, pSaveData[#marker] && "Class")
  end if
  if pSaveData[#type] = #private then
    pProcessList = [#passive: 0, #Active: 0, #users: 0, #items: 0, #heightmap: 0]
  else
    pProcessList = [#passive: 0, #Active: 0, #users: 0, #items: 1, #heightmap: 0]
  end if
  pCacheKey = "room_data_" & pRoomId & "_" & pSaveData[#marker]
  if not getObject(#cache).exists(pCacheKey) then
    getObject(#cache).set(pCacheKey, [:])
  end if
  tCache = getObject(#cache).get(pCacheKey)
  if voidp(tCache[#heightmap]) and not pProcessList[#heightmap] then
    tCache[#heightmap] = EMPTY
    me.getRoomConnection().send("G_HMAP")
  else
    me.validateHeightMap(tCache[#heightmap])
  end if
  tCache[#users] = []
  me.getRoomConnection().send("G_USRS")
  if voidp(tCache[#passive]) and not pProcessList[#passive] then
    tCache[#passive] = []
    me.getRoomConnection().send("G_OBJS")
  else
    if voidp(tCache[#passive]) then
      tCache[#passive] = []
    end if
    me.validatePassiveObjects(0)
  end if
  if voidp(tCache[#Active]) and not pProcessList[#Active] then
    tCache[#Active] = []
  else
    if voidp(tCache[#Active]) then
      tCache[#Active] = []
    end if
    me.validateActiveObjects(0)
  end if
  if voidp(tCache[#items]) and not pProcessList[#items] then
    tCache[#items] = []
    me.getRoomConnection().send("G_ITEMS")
  else
    if voidp(tCache[#items]) then
      tCache[#items] = []
    end if
    me.validateItemObjects(0)
  end if
  createTimeout(pRoomPollerID, 1000, #pollRoomMessages, me.getID(), VOID, 0)
  return 1
end

on roomDisconnected me
  me.leaveRoom()
  return executeMessage(#leaveRoom)
end

on validateHeightMap me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateHeightMap)
  end if
  me.getInterface().getGeometry().loadHeightMap(tdata)
  me.pHeightMapData = tdata
  if not pActiveFlag then
    getObject(#cache).get(pCacheKey).setaProp(#heightmap, tdata)
    me.updateProcess(#heightmap, 1)
  end if
  return 0
end

on updateHeightMap me, tdata
  tHeightMapData = pHeightMapData
  if voidp(tHeightMapData) then
    return error(me, "Height map update data sent but heightmap data not cached!")
  else
    a = 1
    repeat with i = 1 to tdata.length
      if tdata.char[i] = "!" then
        i = i + 1
        a = a + charToNum(tdata.char[i])
        next repeat
      end if
      put tdata.char[i] into tHeightMapData.char[a]
      a = a + 1
    end repeat
    return validateHeightMap(me, tHeightMapData)
  end if
end

on validateUserObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateUserObjects)
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#users).add(tdata)
  end if
  if pActiveFlag and (tdata <> 0) then
    me.createUserObject(tdata)
  else
    me.updateProcess(#users, 1)
  end if
  return 1
end

on validateActiveObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateActiveObjects)
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#Active).add(tdata)
  end if
  if pActiveFlag and (tdata <> 0) then
    me.createActiveObject(tdata)
  else
    me.updateProcess(#Active, 1)
  end if
  return 1
end

on validatePassiveObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validatePassiveObjects)
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#passive).add(tdata)
  end if
  if pActiveFlag and (tdata <> 0) then
    me.createPassiveObject(tdata)
  else
    me.updateProcess(#passive, 1)
  end if
  return 1
end

on validateItemObjects me, tdata
  if not getObject(#cache).exists(pCacheKey) then
    return error(me, "Data not expected yet!", #validateItemObjects)
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#items).add(tdata)
  end if
  if pActiveFlag and (tdata <> 0) then
    me.createItemObject(tdata)
  else
    me.updateProcess(#items, 1)
  end if
  return 1
end

on pollRoomMessages me
  if not me.getRoomConnection() and timeoutExists(pRoomPollerID) then
    return removeTimeout(pRoomPollerID)
  end if
  if me.getRoomConnection().getWaitingMessagesCount() > 0 then
    me.getRoomConnection().processWaitingMessages()
  end if
end

on updateProcess me, tKey, tValue
  if pActiveFlag then
    return error(me, "Attempted to remake room!", #updateProcess)
  end if
  if pProcessList[tKey] = 0 then
    pProcessList[tKey] = tValue
  end if
  repeat with tProcess in pProcessList
    if not tProcess then
      exit repeat
    end if
  end repeat
  if tProcess = 1 then
    if timeoutExists(pRoomPollerID) then
      removeTimeout(pRoomPollerID)
    end if
    tCache = getObject(#cache).get(pCacheKey)
    repeat with tdata in tCache[#passive]
      me.createPassiveObject(tdata)
    end repeat
    repeat with tdata in tCache[#Active]
      me.createActiveObject(tdata)
    end repeat
    repeat with tdata in tCache[#items]
      me.createItemObject(tdata)
    end repeat
    repeat with tdata in tCache[#users]
      me.createUserObject(tdata)
    end repeat
    tCache[#users] = []
    tCache[#Active] = []
    tCache[#items] = []
    me.getInterface().showInfostand()
    me.getInterface().showRoomBar()
    me.getInterface().hideLoaderBar()
    me.getInterface().hideTrashCover()
    pActiveFlag = 1
    pChatProps["mode"] = "CHAT"
    setcursor(#arrow)
    call(#prepare, [me.getRoomPrg()])
    me.getRoomConnection().send("G_STAT")
    return receivePrepare(me.getID())
  end if
  return 0
end

on createRoomObject me, tdata, tList, tClass
  if tdata = 0 then
    return 0
  end if
  if voidp(tdata[#id]) or not listp(tList) then
    return error(me, "Invalid arguments in object creation!", #createRoomObject)
  end if
  if not voidp(tList[tdata[#id]]) then
    return error(me, "Object already exists:" && tdata[#id], #createRoomObject)
  end if
  if voidp(tClass) then
    tClass = "passive"
  end if
  tCustomCls = tdata[#class]
  if tCustomCls contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tCustomCls = tCustomCls.item[1]
    the itemDelimiter = tDelim
  end if
  if getObject(pClassContId).exists(tCustomCls) then
    tClasses = value(getObject(pClassContId).get(tCustomCls))
  else
    tClasses = value(getObject(pClassContId).get(tClass))
  end if
  tObject = createObject(#temp, tClasses)
  if not objectp(tObject) then
    return error(me, "Failed to create room object:" && tdata, #createRoomObject)
  end if
  tObject.setID(tdata[#id])
  tObject.define(tdata.duplicate())
  if the result = 0 then
    return 1
  end if
  tList[tObject.getID()] = tObject
  return 1
end

on removeRoomObject me, tid, tList
  if voidp(tList[tid]) then
    return error(me, "Object not found:" && tid, #removeRoomObject)
  end if
  tList[tid].deconstruct()
  tList.deleteProp(tid)
  return 1
end

on getRoomObject me, tid, tList
  if tid = #list then
    return tList
  end if
  if voidp(tList.getaProp(tid)) then
    return 0
  else
    return tList.getaProp(tid)
  end if
end

on roomObjectExists me, tid, tList
  return not voidp(tList[tid])
end

on startTeleport me, tTeleId, tFlatID
  getObject(#session).set("target_door_ID", tTeleId)
  getObject(#session).set("target_flat_ID", tFlatID)
  registerMessage(symbol("receivedFlatStructf_" & tFlatID), me.getID(), #processTeleportStruct)
  executeMessage(#requestFlatStruct, tFlatID)
end

on processTeleportStruct me, tFlatStruct
  unregisterMessage(symbol("receivedFlatStructf_" & getObject(#session).get("target_flat_ID")))
  tFlatStruct[#id] = tFlatStruct[#flatId]
  tFlatStruct.addProp(#teleport, getObject(#session).get("target_door_ID"))
  getObject(#session).remove("target_flat_id")
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).get("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if tDoorObj <> 0 then
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
