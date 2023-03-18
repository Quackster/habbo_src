property pState, pCategoryIndex, pNodeCache, pNodeCacheExpList, pNaviHistory, pHideFullRoomsFlag, pRootUnitCatId, pRootFlatCatId, pDefaultUnitCatId, pDefaultFlatCatId, pUpdateInterval, pConnectionId, pInfoBroker, pRoomCatagoriesReady

on construct me
  pRootUnitCatId = string(getIntVariable("navigator.visible.public.root"))
  pRootFlatCatId = string(getIntVariable("navigator.visible.private.root"))
  if variableExists("navigator.public.default") then
    pDefaultUnitCatId = string(getIntVariable("navigator.public.default"))
  else
    pDefaultUnitCatId = pRootUnitCatId
  end if
  if variableExists("navigator.private.default") then
    pDefaultFlatCatId = string(getIntVariable("navigator.private.default"))
  else
    pDefaultFlatCatId = pRootFlatCatId
  end if
  pCategoryIndex = [:]
  pNodeCache = [:]
  pNodeCacheExpList = [:]
  pNaviHistory = []
  pHideFullRoomsFlag = 0
  pUpdateInterval = getIntVariable("navigator.updatetime")
  pConnectionId = getVariableValue("connection.info.id", #info)
  pInfoBroker = createObject(#navigator_infobroker, "Navigator Info Broker Class")
  getObject(#session).set("lastroom", "Entry")
  registerMessage(#userlogin, me.getID(), #updateState)
  registerMessage(#show_navigator, me.getID(), #showNavigator)
  registerMessage(#hide_navigator, me.getID(), #hideNavigator)
  registerMessage(#show_hide_navigator, me.getID(), #showhidenavigator)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#roomForward, me.getID(), #prepareRoomEntry)
  registerMessage(#executeRoomEntry, me.getID(), #executeRoomEntry)
  registerMessage(#updateAvailableFlatCategories, me.getID(), #sendGetUserFlatCats)
  pRoomCatagoriesReady = 0
  return 1
end

on deconstruct me
  pNodeCache = VOID
  pCategoryIndex = VOID
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#show_navigator, me.getID())
  unregisterMessage(#hide_navigator, me.getID())
  unregisterMessage(#show_hide_navigator, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#roomForward, me.getID())
  unregisterMessage(#executeRoomEntry, me.getID())
  unregisterMessage(#updateAvailableFlatCategories, me.getID())
  return me.updateState("reset")
end

on showNavigator me
  if not pRoomCatagoriesReady then
    executeMessage(#updateAvailableFlatCategories)
  end if
  return me.getInterface().showNavigator()
end

on hideNavigator me
  return me.getInterface().hideNavigator(#hide)
end

on showhidenavigator me
  if not pRoomCatagoriesReady then
    executeMessage(#updateAvailableFlatCategories)
  end if
  return me.getInterface().showhidenavigator(#hide)
end

on getState me
  return pState
end

on getInfoBroker me
  return pInfoBroker
end

on leaveRoom me
  getObject(#session).set("lastroom", "Entry")
  return me.showNavigator()
end

on getNodeInfo me, tNodeId, tCategoryId
  if tNodeId = VOID then
    return 0
  end if
  tNodeId = string(tNodeId)
  if not (tNodeId contains "/") then
    tTestInfo = me.getNodeInfo(tNodeId & "/" & me.getCurrentNodeMask(), tCategoryId)
    if tTestInfo <> 0 then
      return tTestInfo
    end if
    tTestInfo = me.getNodeInfo(tNodeId & "/0", tCategoryId)
    if tTestInfo <> 0 then
      return tTestInfo
    end if
    tTestInfo = me.getNodeInfo(tNodeId & "/1", tCategoryId)
    if tTestInfo <> 0 then
      return tTestInfo
    end if
  end if
  if tCategoryId <> VOID then
    if pNodeCache[tCategoryId] <> VOID then
      if not voidp(pNodeCache[tCategoryId][#children][tNodeId]) then
        return pNodeCache[tCategoryId][#children][tNodeId]
      end if
    end if
  end if
  if pNodeCache[tNodeId] <> VOID then
    return pNodeCache[tNodeId]
  end if
  repeat with tList in pNodeCache
    if tList[#children] <> VOID then
      if tList[#children][tNodeId] <> VOID then
        return tList[#children][tNodeId]
      end if
    end if
  end repeat
  return 0
end

on getTreeInfoFor me, tid
  if tid = VOID then
    return 0
  end if
  if pCategoryIndex[tid] = VOID then
    return 0
  end if
  return pCategoryIndex[tid]
end

on setNodeProperty me, tNodeId, tProp, tValue
  repeat with myList in pNodeCache
    if myList[#children][tNodeId] <> VOID then
      myList[#children][tNodeId].setaProp(tProp, tValue)
    end if
  end repeat
  return 1
end

on getNodeProperty me, tNodeId, tProp
  if tNodeId = VOID then
    return 0
  end if
  tNodeInfo = me.getNodeInfo(tNodeId)
  if tNodeInfo = 0 then
    return 0
  end if
  return tNodeInfo.getaProp(tProp)
end

on updateInterface me, tid
  if (tid = #own) or (tid = #src) or (tid = #fav) then
    return me.feedNewRoomList(tid)
  else
    return me.feedNewRoomList(tid & "/" & me.getCurrentNodeMask())
  end if
end

on prepareRoomEntry me, tRoomInfoOrId, tRoomType
  if stringp(tRoomInfoOrId) then
    tRoomID = tRoomInfoOrId
    if (tRoomType = #private) and (tRoomID.char[1..2] <> "f_") then
      tRoomID = "f_" & tRoomID
    end if
    tRoomInfo = me.getComponent().getNodeInfo(tRoomID)
    if tRoomInfo = 0 then
      if tRoomType = VOID then
        return error(me, "No roomdata found and no roomType specified!", #prepareRoomEntry)
      end if
      return me.getInfoBroker().requestRoomData(tRoomID, tRoomType, [me.getID(), #prepareRoomEntry])
    else
      if tRoomInfo[#nodeType] = 2 then
        return me.getInfoBroker().requestRoomData(tRoomID, #private, [me.getID(), #prepareRoomEntry])
      end if
    end if
  else
    if listp(tRoomInfoOrId) then
      tRoomInfo = tRoomInfoOrId
      me.getComponent().updateSingleSubNodeInfo(tRoomInfo)
    else
      return error(me, "No room info or id given as parameter:" && tRoomInfoOrId, #prepareRoomEntry)
    end if
  end if
  if tRoomInfo[#nodeType] = 1 then
    if tRoomInfo.findPos(#parentid) > 0 then
      me.getInterface().setProperty(#categoryId, tRoomInfo[#parentid])
    end if
    return me.executeRoomEntry(tRoomInfo[#id])
  else
    me.getInterface().hideNavigator()
    return me.getInterface().checkFlatAccess(tRoomInfo)
  end if
end

on executeRoomEntry me, tNodeId
  me.getInterface().hideNavigator()
  if getObject(#session).GET("lastroom") = "Entry" then
    if threadExists(#entry) then
      getThread(#entry).getComponent().leaveEntry()
    end if
    getObject(#session).set("lastroom", EMPTY)
    me.delay(500, #executeRoomEntry, tNodeId)
    return 1
  else
    tRoomInfo = me.getNodeInfo(tNodeId)
    tRoomDataStruct = me.convertNodeInfoToEntryStruct(tRoomInfo)
    getObject(#session).set("lastroom", tRoomDataStruct)
    if not (getObject(#session).GET("lastroom").ilk = #propList) then
      error(me, "Target room data unavailable!", #executeRoomEntry)
      return me.updateState("enterEntry")
    end if
    return executeMessage(#enterRoom, tRoomDataStruct)
  end if
end

on expandNode me, tNodeId
  me.getInterface().clearRoomList()
  me.getInterface().setProperty(#categoryId, tNodeId)
  me.createNaviHistory(tNodeId)
  return me.updateInterface(tNodeId)
end

on expandHistoryItem me, tClickedItem
  if not listp(pNaviHistory) then
    return 0
  end if
  if tClickedItem > pNaviHistory.count then
    tClickedItem = pNaviHistory.count
  end if
  if tClickedItem = 0 then
    return 0
  end if
  if pNaviHistory[tClickedItem] = #entry then
    getConnection(getVariable("connection.info.id")).send("QUIT")
    return me.updateState("enterEntry")
  else
    return me.expandNode(pNaviHistory[tClickedItem])
  end if
end

on createNaviHistory me, tCategoryId
  pNaviHistory = []
  tText = EMPTY
  if tCategoryId = VOID then
    return 0
  end if
  tParentInfo = me.getTreeInfoFor(tCategoryId)
  if (tCategoryId = pRootUnitCatId) or (tCategoryId = pRootFlatCatId) then
    tParentInfo = 0
  end if
  if listp(tParentInfo) then
    tParentId = tParentInfo[#parentid]
    tParentInfo = me.getTreeInfoFor(tParentId)
  end if
  repeat while tParentInfo <> 0
    if pNaviHistory.getPos(tParentInfo[#parentid]) > 0 then
      tParentInfo = 0
      error(me, "Category loop detected in navigation data!", #createNaviHistory)
      next repeat
    end if
    pNaviHistory.addAt(1, tParentId)
    tText = tParentInfo[#name] & RETURN & tText
    if (tParentId = pRootUnitCatId) or (tParentId = pRootFlatCatId) then
      tParentInfo = 0
      next repeat
    end if
    tParentId = tParentInfo[#parentid]
    tParentInfo = me.getTreeInfoFor(tParentId)
  end repeat
  if getObject(#session).GET("lastroom") <> "Entry" then
    pNaviHistory.addAt(1, #entry)
    tText = getText("nav_hotelview") & RETURN & tText
  end if
  delete char -30003 of tText
  me.getInterface().renderHistory(tCategoryId, tText)
  return 1
end

on callNodeUpdate me
  case me.getInterface().getNaviView() of
    #unit, #flat:
      return me.sendNavigate(me.getInterface().getProperty(#categoryId))
    #own:
      return me.getComponent().sendGetOwnFlats()
    #fav:
      return me.getComponent().sendGetFavoriteFlats()
    otherwise:
      return 0
  end case
end

on showHideFullRooms me, tNodeId
  pHideFullRoomsFlag = not pHideFullRoomsFlag
  return me.updateInterface(tNodeId)
end

on roomkioskGoingFlat me, tRoomProps
  tRoomProps[#flatId] = tRoomProps[#id]
  tRoomProps[#id] = "f_" & tRoomProps[#id]
  tRoomProps[#nodeType] = 2
  if pNodeCache[#own] = VOID then
    pNodeCache[#own] = [#children: [:]]
  end if
  pNodeCache[#own][#children].setaProp(tRoomProps[#id], tRoomProps)
  me.getComponent().executeRoomEntry(tRoomProps[#id])
  return 1
end

on getFlatPassword me, tFlatID
  tFlatInfo = me.getNodeInfo("f_" & tFlatID)
  if tFlatInfo = 0 then
    return error(me, "Flat info is VOID", #getFlatPassword)
  end if
  if tFlatInfo[#door] <> "password" then
    return 0
  end if
  if voidp(tFlatInfo[#password]) then
    return 0
  else
    return tFlatInfo[#password]
  end if
end

on flatAccessResult me, tMsg
  case tMsg of
    "flat_letin", "flatpassword_ok":
    "incorrect flat password", "Password required!":
      me.getInterface().flatPasswordIncorrect()
      me.updateState("enterEntry")
  end case
end

on delayedAlert me, tAlert, tDelay
  if tDelay > 0 then
    createTimeout(#temp, tDelay, #delayedAlert, me.getID(), tAlert, 1)
  else
    executeMessage(#alert, [#Msg: tAlert])
  end if
end

on checkCacheForNode me, tNodeId
  if tNodeId = VOID then
    return 0
  end if
  if pNodeCacheExpList[tNodeId] = VOID then
    return 0
  end if
  if tNodeId = #src then
    return 1
  end if
  if (the milliSeconds - pNodeCacheExpList[tNodeId]) < pUpdateInterval then
    return 1
  end if
  return 0
end

on feedNewRoomList me, tid
  if tid = VOID then
    return 0
  end if
  tNodeInfo = me.getNodeInfo(tid)
  if not listp(tNodeInfo) or not me.checkCacheForNode(tid) then
    return me.callNodeUpdate()
  end if
  me.getInterface().updateRoomList(tNodeInfo[#id], tNodeInfo[#children])
  return 1
end

on purgeNodeCacheExpList me
  repeat with i = 1 to pNodeCacheExpList.count
    if (the milliSeconds - pNodeCacheExpList[i]) > pUpdateInterval then
      tid = pNodeCacheExpList.getPropAt(i)
      pNodeCacheExpList.deleteAt(i)
      pNodeCache.deleteProp(tid)
    end if
  end repeat
end

on sendNavigate me, tNodeId, tDepth, tNodeMask
  if not connectionExists(pConnectionId) then
    return error(me, "Connection not found:" && pConnectionId, #sendNavigate)
  end if
  if tNodeId = VOID then
    return error(me, "Node id is VOID", #sendNavigate)
  end if
  if tDepth = VOID then
    tDepth = 1
  end if
  if tNodeMask = VOID then
    tNodeMask = me.getCurrentNodeMask()
  end if
  getConnection(pConnectionId).send("NAVIGATE", [#integer: tNodeMask, #integer: integer(tNodeId), #integer: tDepth])
  me.purgeNodeCacheExpList()
  return 1
end

on updateCategoryIndex me, tCategoryIndex
  repeat with i = 1 to tCategoryIndex.count
    pCategoryIndex.setaProp(tCategoryIndex.getPropAt(i), tCategoryIndex[i])
  end repeat
  return 1
end

on saveNodeInfo me, tNodeInfo
  tNodeId = tNodeInfo[#id]
  if (tNodeId <> #own) and (tNodeId <> #src) and (tNodeId <> #fav) and not (tNodeId contains "tmp") then
    tNodeId = tNodeId & "/" & tNodeInfo[#nodeMask]
  end if
  if listp(tNodeInfo) then
    pNodeCache[tNodeId] = tNodeInfo
    pNodeCacheExpList[tNodeId] = the milliSeconds
  end if
  return me.feedNewRoomList(tNodeId)
end

on updateSingleSubNodeInfo me, tdata
  if listp(tdata) then
    tStored = 0
    tNodeId = tdata[#id]
    repeat with myList in pNodeCache
      if listp(myList[#children]) then
        if myList[#children][tNodeId] <> VOID then
          repeat with f = 1 to tdata.count()
            myList[#children][tNodeId].setaProp(tdata.getPropAt(f), tdata[f])
          end repeat
          tStored = 1
        end if
      end if
    end repeat
    if not tStored then
      tNewNode = [#id: "tmp_" & tNodeId, #children: [:]]
      tNewNode[#children].setaProp(tNodeId, tdata)
      return me.saveNodeInfo(tNewNode)
    end if
  else
    return error(me, "Flat info parsing failed!", #updateSingleSubNodeInfo)
  end if
end

on sendGetUserFlatCats me
  if connectionExists(pConnectionId) then
    pRoomCatagoriesReady = 1
    return getConnection(pConnectionId).send("GETUSERFLATCATS")
  else
    return error(me, "Connection not found:" && pConnectionId, #sendGetUserFlatCats)
  end if
end

on noflatsforuser me
  return me.getInterface().showRoomlistError(getText("nav_private_norooms"))
end

on noflats me
  return me.getInterface().showRoomlistError(getText("nav_prvrooms_notfound"))
end

on sendGetOwnFlats me
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send("SUSERF", getObject(#session).GET("user_name"))
  else
    return 0
  end if
end

on sendGetFavoriteFlats me
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send("GETFVRF", [#boolean: 0])
  else
    return 0
  end if
end

on sendAddFavoriteFlat me, tNodeId
  tRoomType = me.getNodeProperty(tNodeId, #nodeType) = 1
  if tRoomType = 0 then
    tRoomID = me.getNodeProperty(tNodeId, #flatId)
  else
    tRoomID = tNodeId
  end if
  tRoomID = integer(tRoomID)
  if connectionExists(pConnectionId) then
    if voidp(tRoomID) then
      return error(me, "Room ID expected!", #sendAddFavoriteFlat)
    end if
    return getConnection(pConnectionId).send("ADD_FAVORITE_ROOM", [#integer: tRoomType, #integer: tRoomID])
  else
    return 0
  end if
end

on sendRemoveFavoriteFlat me, tNodeId
  tRoomType = me.getNodeProperty(tNodeId, #nodeType) = 1
  if tRoomType = 0 then
    tRoomID = me.getNodeProperty(tNodeId, #flatId)
  else
    tRoomID = tNodeId
  end if
  tRoomID = integer(tRoomID)
  if connectionExists(pConnectionId) then
    if voidp(tRoomID) then
      return error(me, "Flat ID expected!", #sendRemoveFavoriteFlat)
    end if
    return getConnection(pConnectionId).send("DEL_FAVORITE_ROOM", [#integer: tRoomType, #integer: tRoomID])
  else
    return 0
  end if
end

on sendGetFlatInfo me, tFlatID
  if tFlatID contains "f_" then
    tFlatID = tFlatID.char[3..tFlatID.length]
  end if
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return error(me, "Flat ID expected!", #sendGetFlatInfo)
    else
      return getConnection(pConnectionId).send("GETFLATINFO", tFlatID)
    end if
  else
    return 0
  end if
end

on sendSearchFlats me, tQuery
  if connectionExists(pConnectionId) then
    if voidp(tQuery) then
      return error(me, "Search query is void!", #sendSearchFlats)
    end if
    tQuery = convertSpecialChars(tQuery, 1)
    return getConnection(pConnectionId).send("SRCHF", "%" & tQuery & "%")
  else
    return 0
  end if
end

on sendGetSpaceNodeUsers me, tNodeId
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send("GETSPACENODEUSERS", [#integer: integer(tNodeId)])
  end if
  return 0
end

on sendDeleteFlat me, tNodeId
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if listp(pNodeCache[#own]) then
      if listp(pNodeCache[#own][#children]) then
        pNodeCache[#own][#children].deleteProp(tNodeId)
      end if
    end if
    if tFlatID = VOID then
      return 0
    end if
    return getConnection(pConnectionId).send("DELETEFLAT", tFlatID)
  else
    return 0
  end if
end

on sendGetFlatCategory me, tNodeId
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return error(me, "Flat ID expected!", #sendGetFlatCategory)
    end if
    getConnection(pConnectionId).send("GETFLATCAT", [#integer: integer(tFlatID)])
  else
    return 0
  end if
end

on sendSetFlatCategory me, tNodeId, tCategoryId
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return error(me, "Flat ID expected!", #sendSetFlatCategory)
    end if
    getConnection(pConnectionId).send("SETFLATCAT", [#integer: integer(tFlatID), #integer: integer(tCategoryId)])
  else
    return 0
  end if
end

on sendupdateFlatInfo me, tPropList
  if (tPropList.ilk <> #propList) or voidp(tPropList[#flatId]) then
    return error(me, "Cant send updateFlatInfo", #sendupdateFlatInfo)
  end if
  tFlatMsg = EMPTY
  repeat with tProp in [#flatId, #name, #door, #showownername]
    tFlatMsg = tFlatMsg & tPropList[tProp] & "/"
  end repeat
  tFlatMsg = tFlatMsg.char[1..length(tFlatMsg) - 1]
  getConnection(pConnectionId).send("UPDATEFLAT", tFlatMsg)
  tFlatMsg = string(tPropList[#flatId]) & "/" & RETURN
  tFlatMsg = tFlatMsg & "description=" & tPropList[#description] & RETURN
  if (tPropList[#password] <> EMPTY) and (tPropList[#password] <> VOID) then
    tFlatMsg = tFlatMsg & "password=" & tPropList[#password] & RETURN
  end if
  tFlatMsg = tFlatMsg & "allsuperuser=" & tPropList[#ableothersmovefurniture] & RETURN
  tFlatMsg = tFlatMsg & "maxvisitors=" & tPropList[#maxVisitors]
  getConnection(pConnectionId).send("SETFLATINFO", tFlatMsg)
  return 1
end

on sendRemoveAllRights me, tRoomID
  tFlatID = integer(me.getNodeProperty(tRoomID, #flatId))
  if voidp(tFlatID) then
    return 0
  end if
  getConnection(pConnectionId).send("REMOVEALLRIGHTS", [#integer: tFlatID])
  return 1
end

on sendGetParentChain me, tRoomID
  if voidp(tRoomID) then
    return 0
  end if
  getConnection(pConnectionId).send("GETPARENTCHAIN", [#integer: integer(tRoomID)])
  return 1
end

on convertNodeInfoToEntryStruct me, tProps
  if ilk(tProps) <> #propList then
    return error(me, "Invalid property list as parameter!", #convertNodeInfoToEntryStruct)
  end if
  if tProps[#nodeType] <> 1 then
    tStruct = tProps.duplicate()
    tStruct[#id] = string(tProps[#flatId])
    tStruct[#type] = #private
    tStruct[#teleport] = 0
    tStruct[#casts] = getVariableValue("room.cast.private")
    return tStruct
  else
    tStruct = tProps.duplicate()
    tStruct[#id] = tProps[#unitStrId]
    tStruct[#type] = #public
    tStruct[#owner] = 0
    tStruct[#teleport] = 0
    return tStruct
  end if
end

on getCurrentNodeMask me
  return pHideFullRoomsFlag
end

on updateState me, tstate, tProps
  case tstate of
    "reset":
      pState = tstate
      me.getInterface().setUpdates(0)
      return 0
    "userLogin":
      pState = tstate
      me.getInterface().setProperty(#categoryId, pDefaultUnitCatId, #unit)
      me.getInterface().setProperty(#categoryId, pDefaultFlatCatId, #flat)
      me.getInterface().setProperty(#categoryId, #src, #src)
      me.getInterface().setProperty(#categoryId, #own, #own)
      me.getInterface().setProperty(#categoryId, #fav, #fav)
      if pDefaultUnitCatId <> pRootUnitCatId then
        me.sendGetParentChain(pDefaultUnitCatId)
      end if
      me.sendNavigate(pDefaultUnitCatId)
      if pDefaultFlatCatId <> pRootFlatCatId then
        me.sendGetParentChain(pDefaultFlatCatId)
      end if
      me.sendNavigate(pDefaultFlatCatId)
      tForwardingHappening = variableExists("forward.id") and variableExists("forward.type")
      if tForwardingHappening then
        me.delay(3000, #goStraightToRoom)
      else
        me.delay(2000, #updateState, "openNavigator")
      end if
      return 1
    "openNavigator":
      pState = tstate
      me.showNavigator()
    "enterEntry":
      pState = tstate
      executeMessage(#changeRoom)
      executeMessage(#leaveRoom)
      me.createNaviHistory(me.getInterface().getProperty(#categoryId))
      return 1
    otherwise:
      return error(me, "Unknown state:" && tstate, #updateState)
  end case
end

on goStraightToRoom me
  tForwardId = getVariable("forward.id")
  tForwardTypeNum = getVariable("forward.type")
  if tForwardTypeNum = "1" then
    tForwardType = #public
  else
    tForwardType = #private
  end if
  executeMessage(#roomForward, tForwardId, tForwardType)
  return 1
end
