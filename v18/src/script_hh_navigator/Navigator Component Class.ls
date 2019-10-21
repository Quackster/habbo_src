on construct(me)
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
  pCategoryIndex = []
  pNodeCache = []
  pNodeCacheExpList = []
  pNaviHistory = []
  pHideFullRoomsFlag = 1
  pUpdateInterval = getIntVariable("navigator.cache.duration") * 1000
  if pUpdateInterval = 0 then
    pUpdateInterval = getIntVariable("navigator.updatetime")
  end if
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
  return(1)
  exit
end

on deconstruct(me)
  pNodeCache = void()
  pCategoryIndex = void()
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#show_navigator, me.getID())
  unregisterMessage(#hide_navigator, me.getID())
  unregisterMessage(#show_hide_navigator, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#roomForward, me.getID())
  unregisterMessage(#executeRoomEntry, me.getID())
  unregisterMessage(#updateAvailableFlatCategories, me.getID())
  return(me.updateState("reset"))
  exit
end

on showNavigator(me)
  if not pRoomCatagoriesReady then
    executeMessage(#updateAvailableFlatCategories)
  end if
  return(me.getInterface().showNavigator())
  exit
end

on hideNavigator(me)
  return(me.getInterface().hideNavigator(#hide))
  exit
end

on showhidenavigator(me)
  if not pRoomCatagoriesReady then
    executeMessage(#updateAvailableFlatCategories)
  end if
  return(me.getInterface().showhidenavigator(#hide))
  exit
end

on getState(me)
  return(pState)
  exit
end

on getInfoBroker(me)
  return(pInfoBroker)
  exit
end

on leaveRoom(me)
  getObject(#session).set("lastroom", "Entry")
  return(me.showNavigator())
  exit
end

on getNodeInfo(me, tNodeId, tCategoryId)
  if tNodeId = void() then
    return(0)
  end if
  tNodeId = string(tNodeId)
  if not tNodeId contains "/" then
    tTestInfo = me.getNodeInfo(tNodeId & "/" & me.getCurrentNodeMask(), tCategoryId)
    if tTestInfo <> 0 then
      return(tTestInfo)
    end if
    tTestInfo = me.getNodeInfo(tNodeId & "/0", tCategoryId)
    if tTestInfo <> 0 then
      return(tTestInfo)
    end if
    tTestInfo = me.getNodeInfo(tNodeId & "/1", tCategoryId)
    if tTestInfo <> 0 then
      return(tTestInfo)
    end if
  end if
  if tCategoryId <> void() then
    if pNodeCache.getAt(tCategoryId) <> void() then
      if not voidp(pNodeCache.getAt(tCategoryId).getAt(#children).getAt(tNodeId)) then
        return(pNodeCache.getAt(tCategoryId).getAt(#children).getAt(tNodeId))
      end if
    end if
  end if
  if pNodeCache.getAt(tNodeId) <> void() then
    return(pNodeCache.getAt(tNodeId))
  end if
  repeat while me <= tCategoryId
    tList = getAt(tCategoryId, tNodeId)
    if tList.getAt(#children) <> void() then
      if tList.getAt(#children).getAt(tNodeId) <> void() then
        return(tList.getAt(#children).getAt(tNodeId))
      end if
    end if
  end repeat
  return(0)
  exit
end

on getTreeInfoFor(me, tID)
  if tID = void() then
    return(0)
  end if
  if pCategoryIndex.getAt(tID) = void() then
    return(0)
  end if
  return(pCategoryIndex.getAt(tID))
  exit
end

on setNodeProperty(me, tNodeId, tProp, tValue)
  repeat while me <= tProp
    myList = getAt(tProp, tNodeId)
    if myList.getAt(#children).getAt(tNodeId) <> void() then
      myList.getAt(#children).getAt(tNodeId).setaProp(tProp, tValue)
    end if
  end repeat
  return(1)
  exit
end

on getNodeProperty(me, tNodeId, tProp)
  if tNodeId = void() then
    return(0)
  end if
  tNodeInfo = me.getNodeInfo(tNodeId)
  if tNodeInfo = 0 then
    return(0)
  end if
  return(tNodeInfo.getaProp(tProp))
  exit
end

on getUpdateInterval(me)
  return(pUpdateInterval)
  exit
end

on updateInterface(me, tID)
  if tID = #own or tID = #src or tID = #fav or tID = #recom then
    return(me.feedNewRoomList(tID))
  else
    return(me.feedNewRoomList(tID & "/" & me.getCurrentNodeMask()))
  end if
  exit
end

on prepareRoomEntry(me, tRoomInfoOrId, tRoomType)
  if stringp(tRoomInfoOrId) then
    tRoomID = tRoomInfoOrId
    if tRoomType = #private and tRoomID.getProp(#char, 1, 2) <> "f_" then
      tRoomID = "f_" & tRoomID
    end if
    tRoomInfo = me.getComponent().getNodeInfo(tRoomID)
    if tRoomInfo = 0 then
      if tRoomType = void() then
        return(error(me, "No roomdata found and no roomType specified!", #prepareRoomEntry, #major))
      end if
      return(me.getInfoBroker().requestRoomData(tRoomID, tRoomType, [me.getID(), #prepareRoomEntry]))
    else
      if tRoomInfo.getAt(#nodeType) = 2 then
        return(me.getInfoBroker().requestRoomData(tRoomID, #private, [me.getID(), #prepareRoomEntry]))
      end if
    end if
  else
    if listp(tRoomInfoOrId) then
      tRoomInfo = tRoomInfoOrId
      me.getComponent().updateSingleSubNodeInfo(tRoomInfo)
    else
      return(error(me, "No room info or id given as parameter:" && tRoomInfoOrId, #prepareRoomEntry, #major))
    end if
  end if
  if tRoomInfo.getAt(#nodeType) = 1 then
    if tRoomInfo.findPos(#parentid) > 0 then
      me.getInterface().setProperty(#categoryId, tRoomInfo.getAt(#parentid))
    end if
    return(me.executeRoomEntry(tRoomInfo.getAt(#id)))
  else
    me.getInterface().hideNavigator()
    return(me.getInterface().checkFlatAccess(tRoomInfo))
  end if
  exit
end

on executeRoomEntry(me, tNodeId)
  me.getInterface().hideNavigator()
  if getObject(#session).GET("lastroom") = "Entry" then
    if threadExists(#entry) then
      getThread(#entry).getComponent().leaveEntry()
    end if
    getObject(#session).set("lastroom", "")
    me.delay(500, #executeRoomEntry, tNodeId)
    return(1)
  else
    tRoomInfo = me.getNodeInfo(tNodeId)
    tRoomDataStruct = me.convertNodeInfoToEntryStruct(tRoomInfo)
    getObject(#session).set("lastroom", tRoomDataStruct)
    if not getObject(#session).GET("lastroom").ilk = #propList then
      error(me, "Target room data unavailable!", #executeRoomEntry, #major)
      return(me.updateState("enterEntry"))
    end if
    return(executeMessage(#enterRoom, tRoomDataStruct))
  end if
  exit
end

on expandNode(me, tNodeId)
  me.getInterface().clearRoomList()
  me.getInterface().setProperty(#categoryId, tNodeId)
  me.createNaviHistory(tNodeId)
  me.updateInterface(#recom)
  return(me.updateInterface(tNodeId))
  exit
end

on expandHistoryItem(me, tClickedItem)
  if not listp(pNaviHistory) then
    return(0)
  end if
  if tClickedItem > pNaviHistory.count then
    tClickedItem = pNaviHistory.count
  end if
  if tClickedItem = 0 then
    return(0)
  end if
  if pNaviHistory.getAt(tClickedItem) = #entry then
    getConnection(getVariable("connection.info.id")).send("QUIT")
    return(me.updateState("enterEntry"))
  else
    return(me.expandNode(pNaviHistory.getAt(tClickedItem)))
  end if
  exit
end

on createNaviHistory(me, tCategoryId)
  pNaviHistory = []
  tText = ""
  if tCategoryId = void() then
    return(0)
  end if
  tParentInfo = me.getTreeInfoFor(tCategoryId)
  if tCategoryId = pRootUnitCatId or tCategoryId = pRootFlatCatId then
    tParentInfo = 0
  end if
  if listp(tParentInfo) then
    tParentId = tParentInfo.getAt(#parentid)
    tParentInfo = me.getTreeInfoFor(tParentId)
  end if
  repeat while tParentInfo <> 0
    if pNaviHistory.getPos(tParentInfo.getAt(#parentid)) > 0 then
      tParentInfo = 0
      error(me, "Category loop detected in navigation data!", #createNaviHistory, #minor)
      next repeat
    end if
    pNaviHistory.addAt(1, tParentId)
    tText = tParentInfo.getAt(#name) & "\r" & tText
    if tParentId = pRootUnitCatId or tParentId = pRootFlatCatId then
      tParentInfo = 0
      next repeat
    end if
    tParentId = tParentInfo.getAt(#parentid)
    tParentInfo = me.getTreeInfoFor(tParentId)
  end repeat
  if getObject(#session).GET("lastroom") <> "Entry" then
    pNaviHistory.addAt(1, #entry)
    tText = getText("nav_hotelview") & "\r" & tText
  end if
  tShowRecoms = 0
  if pNaviHistory.count = 0 then
    tShowRecoms = 1
  else
    if pNaviHistory.count = 1 then
      if pNaviHistory.getAt(1) = #entry then
        tShowRecoms = 1
      end if
    end if
  end if
  me.getInterface().renderHistory(tCategoryId, tText, tShowRecoms)
  return(1)
  exit
end

on callNodeUpdate(me)
  if me <> #unit then
    if me = #flat then
      me.sendNavigate(me.getInterface().getProperty(#categoryId))
      me.sendGetRecommendedRooms()
      return(1)
    else
      if me = #own then
        return(me.getComponent().sendGetOwnFlats())
      else
        if me = #fav then
          return(me.getComponent().sendGetFavoriteFlats())
        else
          return(0)
        end if
      end if
    end if
    exit
  end if
end

on showHideFullRooms(me, tNodeId)
  pHideFullRoomsFlag = not pHideFullRoomsFlag
  return(me.updateInterface(tNodeId))
  exit
end

on roomkioskGoingFlat(me, tRoomProps)
  tRoomProps.setAt(#flatId, tRoomProps.getAt(#id))
  tRoomProps.setAt(#id, "f_" & tRoomProps.getAt(#id))
  tRoomProps.setAt(#nodeType, 2)
  if pNodeCache.getAt(#own) = void() then
    pNodeCache.setAt(#own, [#children:[]])
  end if
  pNodeCache.getAt(#own).getAt(#children).setaProp(tRoomProps.getAt(#id), tRoomProps)
  me.getComponent().executeRoomEntry(tRoomProps.getAt(#id))
  return(1)
  exit
end

on getFlatPassword(me, tFlatID)
  tFlatInfo = me.getNodeInfo("f_" & tFlatID)
  if tFlatInfo = 0 then
    return(error(me, "Flat info is VOID", #getFlatPassword, #minor))
  end if
  if tFlatInfo.getAt(#door) <> "password" then
    return(0)
  end if
  if voidp(tFlatInfo.getAt(#password)) then
    return(0)
  else
    return(tFlatInfo.getAt(#password))
  end if
  exit
end

on flatAccessResult(me, tMsg)
  if me <> "flat_letin" then
    if me = "flatpassword_ok" then
    else
      if me <> "incorrect flat password" then
        if me = "Password required!" then
          me.getInterface().flatPasswordIncorrect()
          me.updateState("enterEntry")
        end if
        exit
      end if
    end if
  end if
end

on delayedAlert(me, tAlert, tDelay)
  if tDelay > 0 then
    createTimeout(#temp, tDelay, #delayedAlert, me.getID(), tAlert, 1)
  else
    executeMessage(#alert, [#Msg:tAlert])
  end if
  exit
end

on checkCacheForNode(me, tNodeId)
  if tNodeId = void() then
    return(0)
  end if
  if pNodeCacheExpList.getAt(tNodeId) = void() then
    return(0)
  end if
  if tNodeId = #src then
    return(1)
  end if
  if the milliSeconds - pNodeCacheExpList.getAt(tNodeId) < pUpdateInterval then
    return(1)
  end if
  return(0)
  exit
end

on feedNewRoomList(me, tID)
  if tID = void() then
    return(0)
  end if
  tNodeInfo = me.getNodeInfo(tID)
  if not listp(tNodeInfo) or not me.checkCacheForNode(tID) then
    return(me.callNodeUpdate())
  end if
  if tID = #recom then
    me.getInterface().updateRecomRoomList(tNodeInfo.getAt(#children))
  else
    me.getInterface().updateRoomList(tNodeInfo.getAt(#id), tNodeInfo.getAt(#children))
  end if
  return(1)
  exit
end

on purgeNodeCacheExpList(me)
  i = 1
  repeat while i <= pNodeCacheExpList.count
    if the milliSeconds - pNodeCacheExpList.getAt(i) > pUpdateInterval then
      tID = pNodeCacheExpList.getPropAt(i)
      pNodeCacheExpList.deleteAt(i)
      pNodeCache.deleteProp(tID)
    end if
    i = 1 + i
  end repeat
  exit
end

on sendNavigate(me, tNodeId, tDepth, tNodeMask)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendNavigate, #major))
  end if
  if tNodeId = void() then
    return(error(me, "Node id is VOID", #sendNavigate, #major))
  end if
  if tDepth = void() then
    tDepth = 1
  end if
  if tNodeMask = void() then
    tNodeMask = me.getCurrentNodeMask()
  end if
  getConnection(pConnectionId).send("NAVIGATE", [#integer:tNodeMask, #integer:integer(tNodeId), #integer:tDepth])
  me.purgeNodeCacheExpList()
  return(1)
  exit
end

on sendGetRecommendedRooms(me)
  tConn = getConnection(pConnectionId)
  tConn.send("GET_RECOMMENDED_ROOMS")
  exit
end

on updateCategoryIndex(me, tCategoryIndex)
  i = 1
  repeat while i <= tCategoryIndex.count
    pCategoryIndex.setaProp(tCategoryIndex.getPropAt(i), tCategoryIndex.getAt(i))
    i = 1 + i
  end repeat
  return(1)
  exit
end

on saveNodeInfo(me, tNodeInfo)
  tNodeId = tNodeInfo.getAt(#id)
  if tNodeId <> #own and tNodeId <> #src and tNodeId <> #fav and tNodeId <> #recom and not tNodeId contains "tmp" then
    tNodeId = tNodeId & "/" & tNodeInfo.getAt(#nodeMask)
  end if
  if listp(tNodeInfo) then
    pNodeCache.setAt(tNodeId, tNodeInfo)
    pNodeCacheExpList.setAt(tNodeId, the milliSeconds)
  end if
  return(me.feedNewRoomList(tNodeId))
  exit
end

on updateSingleSubNodeInfo(me, tdata)
  if listp(tdata) then
    tStored = 0
    tNodeId = tdata.getAt(#id)
    repeat while me <= undefined
      myList = getAt(undefined, tdata)
      if listp(myList.getAt(#children)) then
        if myList.getAt(#children).getAt(tNodeId) <> void() then
          f = 1
          repeat while f <= tdata.count()
            myList.getAt(#children).getAt(tNodeId).setaProp(tdata.getPropAt(f), tdata.getAt(f))
            f = 1 + f
          end repeat
          tStored = 1
        end if
      end if
    end repeat
    if not tStored then
      tNewNode = [#id:"tmp_" & tNodeId, #children:[]]
      tNewNode.getAt(#children).setaProp(tNodeId, tdata)
      return(me.saveNodeInfo(tNewNode))
    end if
  else
    return(error(me, "Flat info parsing failed!", #updateSingleSubNodeInfo, #major))
  end if
  exit
end

on sendGetUserFlatCats(me)
  if connectionExists(pConnectionId) then
    pRoomCatagoriesReady = 1
    return(getConnection(pConnectionId).send("GETUSERFLATCATS"))
  else
    return(error(me, "Connection not found:" && pConnectionId, #sendGetUserFlatCats, #major))
  end if
  exit
end

on noflatsforuser(me)
  return(me.getInterface().showRoomlistError(getText("nav_private_norooms")))
  exit
end

on noflats(me)
  return(me.getInterface().showRoomlistError(getText("nav_prvrooms_notfound")))
  exit
end

on sendGetOwnFlats(me)
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("SUSERF", getObject(#session).GET("user_name")))
  else
    return(0)
  end if
  exit
end

on sendGetFavoriteFlats(me)
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("GETFVRF", [#boolean:0]))
  else
    return(0)
  end if
  exit
end

on sendAddFavoriteFlat(me, tNodeId)
  tRoomType = me.getNodeProperty(tNodeId, #nodeType) = 1
  if tRoomType = 0 then
    tRoomID = me.getNodeProperty(tNodeId, #flatId)
  else
    tRoomID = tNodeId
  end if
  tRoomID = integer(tRoomID)
  if connectionExists(pConnectionId) then
    if voidp(tRoomID) then
      return(error(me, "Room ID expected!", #sendAddFavoriteFlat, #major))
    end if
    return(getConnection(pConnectionId).send("ADD_FAVORITE_ROOM", [#integer:tRoomType, #integer:tRoomID]))
  else
    return(0)
  end if
  exit
end

on sendRemoveFavoriteFlat(me, tNodeId)
  tRoomType = me.getNodeProperty(tNodeId, #nodeType) = 1
  if tRoomType = 0 then
    tRoomID = me.getNodeProperty(tNodeId, #flatId)
  else
    tRoomID = tNodeId
  end if
  tRoomID = integer(tRoomID)
  if connectionExists(pConnectionId) then
    if voidp(tRoomID) then
      return(error(me, "Flat ID expected!", #sendRemoveFavoriteFlat, #major))
    end if
    return(getConnection(pConnectionId).send("DEL_FAVORITE_ROOM", [#integer:tRoomType, #integer:tRoomID]))
  else
    return(0)
  end if
  exit
end

on sendGetFlatInfo(me, tFlatID)
  if tFlatID contains "f_" then
    tFlatID = tFlatID.getProp(#char, 3, tFlatID.length)
  end if
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return(error(me, "Flat ID expected!", #sendGetFlatInfo, #major))
    else
      return(getConnection(pConnectionId).send("GETFLATINFO", tFlatID))
    end if
  else
    return(0)
  end if
  exit
end

on sendSearchFlats(me, tQuery)
  if connectionExists(pConnectionId) then
    if voidp(tQuery) then
      return(error(me, "Search query is void!", #sendSearchFlats, #minor))
    end if
    tQuery = convertSpecialChars(tQuery, 1)
    return(getConnection(pConnectionId).send("SRCHF", "%" & tQuery & "%"))
  else
    return(0)
  end if
  exit
end

on sendGetSpaceNodeUsers(me, tNodeId)
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("GETSPACENODEUSERS", [#integer:integer(tNodeId)]))
  end if
  return(0)
  exit
end

on sendDeleteFlat(me, tNodeId)
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if listp(pNodeCache.getAt(#own)) then
      if listp(pNodeCache.getAt(#own).getAt(#children)) then
        pNodeCache.getAt(#own).getAt(#children).deleteProp(tNodeId)
      end if
    end if
    if tFlatID = void() then
      return(0)
    end if
    return(getConnection(pConnectionId).send("DELETEFLAT", tFlatID))
  else
    return(0)
  end if
  exit
end

on sendGetFlatCategory(me, tNodeId)
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return(error(me, "Flat ID expected!", #sendGetFlatCategory, #major))
    end if
    getConnection(pConnectionId).send("GETFLATCAT", [#integer:integer(tFlatID)])
  else
    return(0)
  end if
  exit
end

on sendSetFlatCategory(me, tNodeId, tCategoryId)
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return(error(me, "Flat ID expected!", #sendSetFlatCategory, #major))
    end if
    getConnection(pConnectionId).send("SETFLATCAT", [#integer:integer(tFlatID), #integer:integer(tCategoryId)])
  else
    return(0)
  end if
  exit
end

on sendupdateFlatInfo(me, tPropList)
  if tPropList.ilk <> #propList or voidp(tPropList.getAt(#flatId)) then
    return(error(me, "Cant send updateFlatInfo", #sendupdateFlatInfo, #major))
  end if
  tFlatMsg = ""
  repeat while me <= undefined
    tProp = getAt(undefined, tPropList)
    tFlatMsg = tFlatMsg & tPropList.getAt(tProp) & "/"
  end repeat
  tFlatMsg = tFlatMsg.getProp(#char, 1, length(tFlatMsg) - 1)
  getConnection(pConnectionId).send("UPDATEFLAT", tFlatMsg)
  tFlatMsg = string(tPropList.getAt(#flatId)) & "/" & "\r"
  tFlatMsg = tFlatMsg & "description=" & tPropList.getAt(#description) & "\r"
  if tPropList.getAt(#password) <> "" and tPropList.getAt(#password) <> void() then
    tFlatMsg = tFlatMsg & "password=" & tPropList.getAt(#password) & "\r"
  end if
  tFlatMsg = tFlatMsg & "allsuperuser=" & tPropList.getAt(#ableothersmovefurniture) & "\r"
  tFlatMsg = tFlatMsg & "maxvisitors=" & tPropList.getAt(#maxVisitors)
  getConnection(pConnectionId).send("SETFLATINFO", tFlatMsg)
  return(1)
  exit
end

on sendRemoveAllRights(me, tRoomID)
  tFlatID = integer(me.getNodeProperty(tRoomID, #flatId))
  if voidp(tFlatID) then
    return(0)
  end if
  getConnection(pConnectionId).send("REMOVEALLRIGHTS", [#integer:tFlatID])
  return(1)
  exit
end

on sendGetParentChain(me, tRoomID)
  if voidp(tRoomID) then
    return(0)
  end if
  getConnection(pConnectionId).send("GETPARENTCHAIN", [#integer:integer(tRoomID)])
  return(1)
  exit
end

on convertNodeInfoToEntryStruct(me, tProps)
  if ilk(tProps) <> #propList then
    return(error(me, "Invalid property list as parameter!", #convertNodeInfoToEntryStruct, #major))
  end if
  if tProps.getAt(#nodeType) <> 1 then
    tStruct = tProps.duplicate()
    tStruct.setAt(#id, string(tProps.getAt(#flatId)))
    tStruct.setAt(#type, #private)
    tStruct.setAt(#teleport, 0)
    tStruct.setAt(#casts, getVariableValue("room.cast.private"))
    return(tStruct)
  else
    tStruct = tProps.duplicate()
    tStruct.setAt(#id, tProps.getAt(#unitStrId))
    tStruct.setAt(#type, #public)
    tStruct.setAt(#owner, 0)
    tStruct.setAt(#teleport, 0)
    return(tStruct)
  end if
  exit
end

on getCurrentNodeMask(me)
  return(pHideFullRoomsFlag)
  exit
end

on updateState(me, tstate, tProps)
  if me = "reset" then
    pState = tstate
    me.getInterface().setUpdates(0)
    return(0)
  else
    if me = "userLogin" then
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
      me.sendGetRecommendedRooms()
      tForwardingHappening = variableExists("forward.id") and variableExists("forward.type")
      if tForwardingHappening then
        me.delay(3000, #goStraightToRoom)
      else
        if variableExists("friend.id") then
          me.delay(3000, #followFriend)
        else
          me.delay(2000, #updateState, "openNavigator")
        end if
      end if
      return(1)
    else
      if me = "openNavigator" then
        pState = tstate
        me.showNavigator()
      else
        if me = "enterEntry" then
          pState = tstate
          executeMessage(#changeRoom)
          executeMessage(#leaveRoom)
          me.createNaviHistory(me.getInterface().getProperty(#categoryId))
          return(1)
        else
          return(error(me, "Unknown state:" && tstate, #updateState, #minor))
        end if
      end if
    end if
  end if
  exit
end

on goStraightToRoom(me)
  tForwardId = getVariable("forward.id")
  tForwardTypeNum = getVariable("forward.type")
  if tForwardTypeNum = "1" then
    tForwardType = #public
  else
    tForwardType = #private
  end if
  executeMessage(#roomForward, tForwardId, tForwardType)
  return(1)
  exit
end

on followFriend(me)
  tID = getVariable("friend.id")
  tConn = getConnection(getVariable("connection.info.id"))
  tConn.send("FOLLOW_FRIEND", [#integer:tID])
  return(1)
  exit
end