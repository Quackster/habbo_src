property pChatProps, pClassContId, pBalloonId, pRoomConnID, pUserObjList, pActiveObjList, pPassiveObjList, pItemObjList, pRoomPrgID, pActiveFlag, pRoomId, pSaveData, pTrgDoorID, pCacheFlag, pCacheKey, pProcessList, pRoomPollerID

on construct me 
  pInfoConnID = getVariable("connection.info.id")
  pRoomConnID = getVariable("connection.room.id")
  pRoomId = ""
  pActiveFlag = 0
  pProcessList = [:]
  pSaveData = void()
  pCacheKey = ""
  pCacheFlag = getVariableValue("room.map.cache", 0)
  pTrgDoorID = void()
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pBalloonId = "Room Balloon"
  pClassContId = "Room Classes"
  pRoomPrgID = "Room Program"
  pRoomPollerID = "Room Poller"
  pChatProps = [:]
  pChatProps.setAt("returnCount", 0)
  pChatProps.setAt("timerStart", 0)
  pChatProps.setAt("timerDelay", 0)
  pChatProps.setAt("mode", "CHAT")
  pChatProps.setAt("hobbaCmds", getVariableValue("moderator.cmds"))
  createObject(pClassContId, getClassVariable("variable.manager.class"))
  getObject(pClassContId).dump("fuse.object.classes", "\r")
  createObject(pBalloonId, "Balloon Manager")
  registerMessage(#enterRoom, me.getID(), #enterRoom)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  return TRUE
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
  pRoomId = ""
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  return TRUE
end

on prepare me 
  if pActiveFlag then
    call(#update, pUserObjList)
    call(#update, pActiveObjList)
  end if
end

on enterRoom me, tRoomDataStruct 
  if not listp(tRoomDataStruct) then
    error(me, "Invalid room data struct!", #enterRoom)
    return(executeMessage(#leaveRoom))
  end if
  tdata = tRoomDataStruct.duplicate()
  if voidp(tdata.getAt(#id)) then
    error(me, "Missing ID in room data struct!", #enterRoom)
    return(executeMessage(#leaveRoom))
  end if
  if pRoomId <> "" then
    executeMessage(#changeRoom)
  end if
  getObject(#session).set("room_owner", 0)
  getObject(#session).set("room_controller", 0)
  getObject(#session).set("moderator", 0)
  if (tdata.getAt(#type) = #private) then
    pRoomId = "private"
  else
    pRoomId = tdata.getAt(#id)
  end if
  pTrgDoorID = void()
  pSaveData = tdata
  me.loadRoomCasts()
  return TRUE
end

on enterDoor me, tdata 
  if not listp(tdata) then
    return(error(me, "Room data struct expected!", #enterDoor))
  end if
  if tdata.getAt(#id) <> pSaveData.getAt(#id) then
    me.leaveRoom(1)
    tReConnect = 1
  else
    getObject(#session).set("target_door_ID", 0)
    tReConnect = 0
  end if
  pRoomId = "private"
  pTrgDoorID = tdata.getAt(#id)
  pSaveData = tdata.duplicate()
  pSaveData.setAt(#type, #private)
  getObject(#session).set("lastroom", tdata.duplicate())
  if tReConnect then
    return(me.roomCastLoaded())
  else
    return(me.getRoomConnection().send(#room, "GOVIADOOR /" & pTrgDoorID & "/" & pSaveData.getAt(#teleport)))
  end if
end

on leaveRoom me, tJumpingToSubUnit 
  if (pRoomId = "") then
    return FALSE
  end if
  removePrepare(me.getID())
  if objectExists(pRoomPrgID) then
    removeObject(pRoomPrgID)
  end if
  if not pCacheFlag then
    getObject(#cache).remove(pCacheKey)
  end if
  pActiveFlag = 0
  if not tJumpingToSubUnit then
    pRoomId = ""
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
  getObject(#session).set("moderator", 0)
  return TRUE
end

on createUserObject me, tdata 
  if me.userObjectExists(tdata.getAt(#id)) then
    me.removeUserObject(tdata.getAt(#id))
  end if
  executeMessage(#create_user, tdata.getAt(#id))
  return(me.createRoomObject(tdata, pUserObjList, "user"))
end

on removeUserObject me, tid 
  executeMessage(#remove_user, tid)
  return(me.removeRoomObject(tid, pUserObjList))
end

on getUserObject me, tid 
  return(me.getRoomObject(tid, pUserObjList))
end

on userObjectExists me, tid 
  return(me.roomObjectExists(tid, pUserObjList))
end

on createActiveObject me, tdata 
  if me.activeObjectExists(tdata.getAt(#id)) then
    me.removeActiveObject(tdata.getAt(#id))
  end if
  return(me.createRoomObject(tdata, pActiveObjList, "active"))
end

on removeActiveObject me, tid 
  return(me.removeRoomObject(tid, pActiveObjList))
end

on getActiveObject me, tid 
  return(me.getRoomObject(tid, pActiveObjList))
end

on activeObjectExists me, tid 
  return(me.roomObjectExists(tid, pActiveObjList))
end

on createPassiveObject me, tdata 
  if me.passiveObjectExists(tdata.getAt(#id)) then
    me.removePassiveObject(tdata.getAt(#id))
  end if
  return(me.createRoomObject(tdata, pPassiveObjList, "passive"))
end

on removePassiveObject me, tid 
  return(me.removeRoomObject(tid, pPassiveObjList))
end

on getPassiveObject me, tid 
  return(me.getRoomObject(tid, pPassiveObjList))
end

on passiveObjectExists me, tid 
  return(me.roomObjectExists(tid, pPassiveObjList))
end

on createItemObject me, tdata 
  if me.itemObjectExists(tdata.getAt(#id)) then
    me.removeItemObject(tdata.getAt(#id))
  end if
  return(me.createRoomObject(tdata, pItemObjList, "item"))
end

on removeItemObject me, tid 
  return(me.removeRoomObject(tid, pItemObjList))
end

on getItemObject me, tid 
  return(me.getRoomObject(tid, pItemObjList))
end

on itemObjectExists me, tid 
  return(me.roomObjectExists(tid, pItemObjList))
end

on getRoomPrg me 
  return(getObject(pRoomPrgID))
end

on getRoomID me 
  return(pRoomId)
end

on getRoomData me 
  if voidp(pSaveData) then
    return FALSE
  else
    return(pSaveData)
  end if
end

on getRoomConnection me 
  return(getConnection(pRoomConnID))
end

on getBalloon me 
  return(getObject(pBalloonId))
end

on getClassContainer me 
  return(getObject(pClassContId))
end

on roomExists me, tRoomId 
  if voidp(tRoomId) then
    return(pActiveFlag)
  else
    return((pRoomId = tRoomId))
  end if
end

on sendChat me, tChat 
  if voidp(tChat) then
    return FALSE
  end if
  if (tChat = "") then
    return FALSE
  end if
  if (tChat.getProp(#word, 1) = ":chooser") then
    if getObject(#session).get("moderator") <> 0 then
      return(createObject(#chooser, "User Chooser Class"))
    end if
  else
    if (tChat.getProp(#word, 1) = ":performance") then
      return(performance())
    else
      if (tChat.getProp(#word, 1) = ":debug") then
        if getObject(#session).get("moderator") <> 0 then
          if float(the productVersion.getProp(#char, 1, 3)) >= 8.5 then
            the debugPlaybackEnabled = 1
            return TRUE
          end if
        end if
      else
        if (tChat.getProp(#word, 1) = ":editcatalogue") then
          return(executeMessage("edit_catalogue"))
        end if
      end if
    end if
  end if
  if the shiftDown then
    tMode = "SHOUT"
  else
    tMode = pChatProps.getAt("mode")
  end if
  tSelected = me.getInterface().getSelectedObject()
  if not me.userObjectExists(tSelected) then
    tSelected = ""
  end if
  if pChatProps.getAt("hobbaCmds").getOne(tChat.getProp(#word, 1, 2)) then
    tMode = "CHAT"
    if not tChat contains tSelected then
      tChat = replaceChunks(tChat, "x", tSelected)
    end if
  else
    if (tMode = "WHISPER") then
      tChat = tSelected && tChat
    end if
  end if
  tStrSrvcs = getStringServices()
  tChat = tStrSrvcs.replaceChunks(tChat, "�", "&auml;")
  tChat = tStrSrvcs.replaceChunks(tChat, "�", "&ouml;")
  tChat = tStrSrvcs.replaceChunks(tChat, "�", "&AUML;")
  tChat = tStrSrvcs.replaceChunks(tChat, "�", "&OUML;")
  return(me.getRoomConnection().send(#room, tMode && tChat))
end

on setChatMode me, tMode 
  if (tMode = "whisper") then
    pChatProps.setAt("mode", "WHISPER")
  else
    if (tMode = "shout") then
      pChatProps.setAt("mode", "SHOUT")
    else
      pChatProps.setAt("mode", "CHAT")
    end if
  end if
  return TRUE
end

on print me 
  put("\r" & "User objects:" & "\r")
  i = 1
  repeat while i <= pUserObjList.count
    put(pUserObjList.getPropAt(i) & ":" && pUserObjList.getAt(i))
    i = (1 + i)
  end repeat
  put("\r" & "Active objects:" & "\r")
  i = 1
  repeat while i <= pActiveObjList.count
    put(pActiveObjList.getPropAt(i) & ":" && pActiveObjList.getAt(i))
    i = (1 + i)
  end repeat
  put("\r" & "Passive objects:" & "\r")
  i = 1
  repeat while i <= pPassiveObjList.count
    put(pPassiveObjList.getPropAt(i) & ":" && pPassiveObjList.getAt(i))
    i = (1 + i)
  end repeat
end

on loadRoomCasts me 
  if (pRoomId = "") then
    return FALSE
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
    end if
    i = (i + 1)
  end repeat
  if tCastList.count > 0 then
    tCastLoadId = startCastLoad(tCastList, 1)
    registerCastloadCallback(tCastLoadId, #loadRoomCasts, me.getID())
    me.getInterface().showLoaderBar(tCastLoadId, getText("room_hold", getText("room_loading", "Hold on...")))
    return TRUE
  end if
  if not variableExists("room.cast." & pRoomId) then
    error(me, "Cast for room not defined:" && pRoomId, #loadRoomCasts)
    executeMessage(#leaveRoom)
  end if
  tCastLoadId = startCastLoad(getVariableValue("room.cast." & pRoomId), 0)
  registerCastloadCallback(tCastLoadId, #roomCastLoaded, me.getID())
  me.getInterface().showLoaderBar(tCastLoadId, getText("room_loading", "Loading room") & "\r" & "\"" & pSaveData.getAt(#name) & "\"")
  return TRUE
end

on roomCastLoaded me 
  if (pRoomId = "") then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return(error(me, "Room building process is aborted!", #roomCastLoaded))
  end if
  if voidp(pTrgDoorID) then
    tTxt = getText("room_preparing", "...preparing room.")
    if (pSaveData.getAt(#type) = #private) then
      if (pSaveData.getAt(#door) = "closed") then
        if pSaveData.getAt(#owner) <> getObject(#session).get("user_name") then
          tTxt = getText("room_waiting", "...waiting.")
        end if
      end if
    end if
    me.getInterface().showLoaderBar(void(), "\"" & pSaveData.getAt(#name) & "\"" & "\r" & tTxt)
    tRoomCasts = getVariableValue("room.cast." & pRoomId)
    repeat while tRoomCasts <= undefined
      tCast = getAt(undefined, undefined)
      if not castExists(tCast) then
        error(me, "Cast required by room not found:" && tCast, #roomCastLoaded)
        return(executeMessage(#leaveRoom))
      end if
    end repeat
  end if
  if (pSaveData.getAt(#type) = #private) then
    tRoomId = integer(pSaveData.getAt(#id))
    tDoorID = 0
    tTypeID = numToChar(128)
  else
    tRoomId = integer(pSaveData.getAt(#port))
    tDoorID = integer(pSaveData.getAt(#door))
    tTypeID = numToChar(129)
  end if
  if (tDoorID.ilk = #void) then
    tDoorID = 0
  end if
  tL1 = numToChar(bitOr(bitAnd(tRoomId, 127), 128))
  tL2 = numToChar(bitOr(bitAnd((tRoomId / 128), 127), 128))
  tL3 = numToChar(bitOr(bitAnd((tRoomId / 16384), 127), 128))
  tL4 = numToChar(bitOr(bitAnd((tRoomId / integer(power(2, 21))), 127), 128))
  tL5 = numToChar(bitOr(bitAnd(tDoorID, 127), 128))
  tL6 = numToChar(bitOr(bitAnd((tDoorID / 128), 127), 128))
  tL7 = numToChar(bitOr(bitAnd((tDoorID / 16384), 127), 128))
  tL8 = numToChar(bitOr(bitAnd((tDoorID / integer(power(2, 21))), 127), 128))
  return(getConnection(pRoomConnID).send(#room_directory, tTypeID & tL4 & tL3 & tL2 & tL1 & tL8 & tL7 & tL6 & tL5))
end

on roomConnected me, tMarker, tstate 
  if (pRoomId = "") then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return(error(me, "Room building process is aborted!", #roomCastLoaded))
  end if
  if not voidp(pTrgDoorID) then
    if (tstate = "OPC_OK") then
      tValue = me.getRoomConnection().send(#room, "GOVIADOOR /" & pTrgDoorID & "/" & pSaveData.getAt(#teleport))
      pTrgDoorID = void()
      return(tValue)
    end if
  end if
  if (pSaveData.getAt(#type) = #private) then
    if (tstate = "OPC_OK") then
      tStr = "TRYFLAT /" & pSaveData.getAt(#id)
      if threadExists(#navigator) then
        tPassword = getThread(#navigator).getComponent().getFlatPassword(pSaveData.getAt(#id))
        if tPassword <> 0 then
          tStr = tStr & "/" & tPassword
        end if
      end if
      return(me.getRoomConnection().send(#room, tStr))
    else
      if (tstate = "FLAT_LETIN") then
        return(me.getRoomConnection().send(#room, "GOTOFLAT /" & pSaveData.getAt(#id)))
      end if
    end if
  end if
  if voidp(tMarker) then
    error(me, "Missing room marker!!!", #roomConnected)
  end if
  pSaveData.setAt(#marker, tMarker)
  me.leaveRoom(1)
  if not me.getInterface().showRoom(tMarker) then
    return(executeMessage(#leaveRoom))
  end if
  if memberExists(pSaveData.getAt(#marker) && "Class") then
    createObject(pRoomPrgID, pSaveData.getAt(#marker) && "Class")
  end if
  if (pSaveData.getAt(#type) = #private) then
    pProcessList = [#passive:0, #Active:0, #users:0, #items:0, #heightmap:0]
  else
    pProcessList = [#passive:0, #Active:0, #users:0, #items:1, #heightmap:0]
  end if
  pCacheKey = "room_data_" & pRoomId & "_" & pSaveData.getAt(#marker)
  if not getObject(#cache).exists(pCacheKey) then
    getObject(#cache).set(pCacheKey, [:])
  end if
  tCache = getObject(#cache).get(pCacheKey)
  if voidp(tCache.getAt(#heightmap)) and not pProcessList.getAt(#heightmap) then
    tCache.setAt(#heightmap, "")
    me.getRoomConnection().send(#room, "G_HMAP")
  else
    me.validateHeightMap(tCache.getAt(#heightmap))
  end if
  tCache.setAt(#users, [])
  me.getRoomConnection().send(#room, "G_USRS")
  if voidp(tCache.getAt(#passive)) and not pProcessList.getAt(#passive) then
    tCache.setAt(#passive, [])
    me.getRoomConnection().send(#room, "G_OBJS")
  else
    if voidp(tCache.getAt(#passive)) then
      tCache.setAt(#passive, [])
    end if
    me.validatePassiveObjects(0)
  end if
  if voidp(tCache.getAt(#Active)) and not pProcessList.getAt(#Active) then
    tCache.setAt(#Active, [])
  else
    if voidp(tCache.getAt(#Active)) then
      tCache.setAt(#Active, [])
    end if
    me.validateActiveObjects(0)
  end if
  if voidp(tCache.getAt(#items)) and not pProcessList.getAt(#items) then
    tCache.setAt(#items, [])
    me.getRoomConnection().send(#room, "G_ITEMS")
  else
    if voidp(tCache.getAt(#items)) then
      tCache.setAt(#items, [])
    end if
    me.validateItemObjects(0)
  end if
  createTimeout(pRoomPollerID, 1000, #pollRoomMessages, me.getID(), void(), 0)
  return TRUE
end

on roomDisconnected me 
  return(executeMessage(#leaveRoom))
end

on validateHeightMap me, tdata 
  if not getObject(#cache).exists(pCacheKey) then
    return(error(me, "Data not expected yet!", #validateHeightMap))
  end if
  me.getInterface().getGeometry().loadHeightMap(tdata)
  if not pActiveFlag then
    getObject(#cache).get(pCacheKey).setaProp(#heightmap, tdata)
    me.updateProcess(#heightmap, 1)
  end if
  return FALSE
end

on validateUserObjects me, tdata 
  if not getObject(#cache).exists(pCacheKey) then
    return(error(me, "Data not expected yet!", #validateUserObjects))
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#users).add(tdata)
  end if
  if pActiveFlag and tdata <> 0 then
    me.createUserObject(tdata)
  else
    me.updateProcess(#users, 1)
  end if
  return TRUE
end

on validateActiveObjects me, tdata 
  if not getObject(#cache).exists(pCacheKey) then
    return(error(me, "Data not expected yet!", #validateActiveObjects))
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#Active).add(tdata)
  end if
  if pActiveFlag and tdata <> 0 then
    me.createActiveObject(tdata)
  else
    me.updateProcess(#Active, 1)
  end if
  return TRUE
end

on validatePassiveObjects me, tdata 
  if not getObject(#cache).exists(pCacheKey) then
    return(error(me, "Data not expected yet!", #validatePassiveObjects))
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#passive).add(tdata)
  end if
  if pActiveFlag and tdata <> 0 then
    me.createPassiveObject(tdata)
  else
    me.updateProcess(#passive, 1)
  end if
  return TRUE
end

on validateItemObjects me, tdata 
  if not getObject(#cache).exists(pCacheKey) then
    return(error(me, "Data not expected yet!", #validateItemObjects))
  end if
  if tdata <> 0 then
    getObject(#cache).get(pCacheKey).getaProp(#items).add(tdata)
  end if
  if pActiveFlag and tdata <> 0 then
    me.createItemObject(tdata)
  else
    me.updateProcess(#items, 1)
  end if
  return TRUE
end

on pollRoomMessages me 
  if not me.getRoomConnection() and timeoutExists(pRoomPollerID) then
    return(removeTimeout(pRoomPollerID))
  end if
  if me.getRoomConnection().getWaitingMessagesCount() > 0 then
    me.getRoomConnection().processWaitingMessages()
  end if
end

on updateProcess me, tKey, tValue 
  if pActiveFlag then
    return(error(me, "Attempted to remake room!", #updateProcess))
  end if
  if (pProcessList.getAt(tKey) = 0) then
    pProcessList.setAt(tKey, tValue)
  end if
  repeat while pProcessList <= tValue
    tProcess = getAt(tValue, tKey)
    if not tProcess then
    else
    end if
  end repeat
  if (tProcess = 1) then
    if timeoutExists(pRoomPollerID) then
      removeTimeout(pRoomPollerID)
    end if
    tCache = getObject(#cache).get(pCacheKey)
    repeat while pProcessList <= tValue
      tdata = getAt(tValue, tKey)
      me.createPassiveObject(tdata)
    end repeat
    repeat while pProcessList <= tValue
      tdata = getAt(tValue, tKey)
      me.createActiveObject(tdata)
    end repeat
    repeat while pProcessList <= tValue
      tdata = getAt(tValue, tKey)
      me.createItemObject(tdata)
    end repeat
    repeat while pProcessList <= tValue
      tdata = getAt(tValue, tKey)
      me.createUserObject(tdata)
    end repeat
    tCache.setAt(#users, [])
    tCache.setAt(#Active, [])
    tCache.setAt(#items, [])
    me.getInterface().showInfostand()
    me.getInterface().showRoomBar()
    me.getInterface().hideLoaderBar()
    me.getInterface().hideTrashCover()
    pActiveFlag = 1
    pChatProps.setAt("mode", "CHAT")
    call(#prepare, [me.getRoomPrg()])
    me.getRoomConnection().send(#room, "G_STAT")
    tFirstActField = pSaveData.getAt(#marker) & ".firstAction"
    if memberExists(tFirstActField) then
      #room.send(tFirstActField, field(0))
    end if
    executeMessage(#roomStatistic, pRoomId)
    return(receivePrepare(me.getID()))
  end if
  return FALSE
end

on createRoomObject me, tdata, tList, tClass 
  if (tdata = 0) then
    return FALSE
  end if
  if voidp(tdata.getAt(#id)) or not listp(tList) then
    return(error(me, "Invalid arguments in object creation!", #createRoomObject))
  end if
  if not voidp(tList.getAt(tdata.getAt(#id))) then
    return(error(me, "Object already exists:" && tdata.getAt(#id), #createRoomObject))
  end if
  if voidp(tClass) then
    tClass = "passive"
  end if
  tCustomCls = tdata.getAt(#class)
  if tCustomCls contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tCustomCls = tCustomCls.getProp(#item, 1)
    the itemDelimiter = tDelim
  end if
  if getObject(pClassContId).exists(tCustomCls) then
    tClasses = value(getObject(pClassContId).get(tCustomCls))
  else
    tClasses = value(getObject(pClassContId).get(tClass))
  end if
  tObject = createObject(#temp, tClasses)
  if not objectp(tObject) then
    return(error(me, "Failed to create room object:" && tdata, #createRoomObject))
  end if
  tObject.setID(tdata.getAt(#id))
  tObject.define(tdata.duplicate())
  if (the result = 0) then
    return TRUE
  end if
  tList.setAt(tObject.getID(), tObject)
  return TRUE
end

on removeRoomObject me, tid, tList 
  if voidp(tList.getAt(tid)) then
    return(error(me, "Object not found:" && tid, #removeRoomObject))
  end if
  tList.getAt(tid).deconstruct()
  tList.deleteProp(tid)
  return TRUE
end

on getRoomObject me, tid, tList 
  if (tid = #list) then
    return(tList)
  end if
  if voidp(tList.getAt(tid)) then
    return FALSE
  else
    return(tList.getAt(tid))
  end if
end

on roomObjectExists me, tid, tList 
  return(not voidp(tList.getAt(tid)))
end
