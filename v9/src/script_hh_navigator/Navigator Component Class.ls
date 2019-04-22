property pRootUnitCatId, pRootFlatCatId, pState, pNodeCache, pCategoryIndex, pNaviHistory, pHideFullRoomsFlag, pNodeCacheExpList, pUpdateInterval, pConnectionId, pDefaultUnitCatId, pDefaultFlatCatId

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
  getObject(#session).set("lastroom", "Entry")
  registerMessage(#userlogin, me.getID(), #updateState)
  registerMessage(#show_navigator, me.getID(), #showNavigator)
  registerMessage(#hide_navigator, me.getID(), #hideNavigator)
  registerMessage(#show_hide_navigator, me.getID(), #showhidenavigator)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#executeRoomEntry, me.getID(), #executeRoomEntry)
  registerMessage(#requestFlatStruct, me.getID(), #sendGetFlatInfo)
  registerMessage(#updateAvailableFlatCategories, me.getID(), #sendGetUserFlatCats)
  return(1)
end

on deconstruct me 
  pNodeCache = void()
  pCategoryIndex = void()
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#show_navigator, me.getID())
  unregisterMessage(#hide_navigator, me.getID())
  unregisterMessage(#show_hide_navigator, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#executeRoomEntry, me.getID())
  unregisterMessage(#requestFlatStruct, me.getID())
  unregisterMessage(#updateAvailableFlatCategories, me.getID())
  return(me.updateState("reset"))
end

on showNavigator me 
  return(me.getInterface().showNavigator())
end

on hideNavigator me 
  return(me.getInterface().hideNavigator(#hide))
end

on showhidenavigator me 
  return(me.getInterface().showhidenavigator(#hide))
end

on getState me 
  return(pState)
end

on leaveRoom me 
  getObject(#session).set("lastroom", "Entry")
  return(me.getInterface().showNavigator())
end

on getNodeInfo me, tNodeId, tCategoryId 
  if tNodeId = void() then
    return(0)
  end if
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
      return(pNodeCache.getAt(tCategoryId).getAt(#children).getAt(tNodeId))
    end if
  end if
  if pNodeCache.getAt(tNodeId) <> void() then
    return(pNodeCache.getAt(tNodeId))
  end if
  repeat while pNodeCache <= tCategoryId
    tList = getAt(tCategoryId, tNodeId)
    if tList.getAt(#children).getAt(tNodeId) <> void() then
      return(tList.getAt(#children).getAt(tNodeId))
    end if
  end repeat
  return(0)
end

on getTreeInfoFor me, tid 
  if tid = void() then
    return(0)
  end if
  if pCategoryIndex.getAt(tid) = void() then
    return(0)
  end if
  return(pCategoryIndex.getAt(tid))
end

on setNodeProperty me, tNodeId, tProp, tValue 
  tNodeInfo = me.getNodeInfo(tNodeId)
  if not listp(tNodeInfo) then
    return(0)
  end if
  tNodeInfo.setaProp(tProp, tValue)
  return(1)
end

on getNodeProperty me, tNodeId, tProp 
  if tNodeId = void() then
    return(0)
  end if
  tNodeInfo = me.getNodeInfo(tNodeId)
  if tNodeInfo = 0 then
    return(0)
  end if
  return(tNodeInfo.getaProp(tProp))
end

on updateInterface me, tid 
  if tid = #own or tid = #src or tid = #fav then
    return(me.feedNewRoomList(tid))
  else
    return(me.feedNewRoomList(tid & "/" & me.getCurrentNodeMask()))
  end if
end

on prepareRoomEntry me, tRoomID 
  tRoomInfo = me.getComponent().getNodeInfo(tRoomID)
  if tRoomInfo = 0 then
    return(0)
  end if
  if tRoomInfo.getAt(#nodeType) = 1 then
    return(me.getComponent().executeRoomEntry(tRoomID))
  else
    me.getInterface().hideNavigator()
    registerMessage(symbol("receivedFlatStruct" & tRoomID), me.getInterface().getID(), #checkFlatAccess)
    return(me.getComponent().sendGetFlatInfo(tRoomID))
  end if
end

on executeRoomEntry me, tNodeId, tRoomDataStruct 
  me.getInterface().hideNavigator()
  if getObject(#session).get("lastroom") = "Entry" then
    if threadExists(#entry) then
      getThread(#entry).getComponent().leaveEntry()
    end if
    if tRoomDataStruct = void() then
      tRoomDataStruct = me.getRoomProperties(tNodeId)
    end if
    getObject(#session).set("lastroom", tRoomDataStruct)
    me.delay(500, #executeRoomEntry)
    return(1)
  else
    if voidp(tNodeId) then
      if getObject(#session).get("lastroom").ilk = #propList then
        tRoomDataStruct = getObject(#session).get("lastroom")
      else
        error(me, "Target room's ID expected!", #executeRoomEntry)
        return(me.updateState("enterEntry"))
      end if
    else
      if tRoomDataStruct = void() then
        tRoomDataStruct = me.getRoomProperties(tNodeId)
      end if
      getObject(#session).set("lastroom", tRoomDataStruct)
    end if
    return(executeMessage(#enterRoom, tRoomDataStruct))
  end if
end

on expandNode me, tNodeId 
  me.getInterface().clearRoomList()
  me.getInterface().setProperty(#categoryId, tNodeId)
  me.createNaviHistory(tNodeId)
  return(me.updateInterface(tNodeId))
end

on expandHistoryItem me, tClickedItem 
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
end

on createNaviHistory me, tCategoryId 
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
      error(me, "Category loop detected in navigation data!", #createNaviHistory)
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
  if getObject(#session).get("lastroom") <> "Entry" then
    pNaviHistory.addAt(1, #entry)
    tText = getText("nav_hotelview") & "\r" & tText
  end if
  me.getInterface().renderHistory(tCategoryId, tText)
  return(1)
end

on callNodeUpdate me 
  if me.getInterface().getNaviView() <> #unit then
    if me.getInterface().getNaviView() = #flat then
      return(me.sendNavigate(me.getInterface().getProperty(#categoryId)))
    else
      if me.getInterface().getNaviView() = #own then
        return(me.getComponent().sendGetOwnFlats())
      else
        if me.getInterface().getNaviView() = #fav then
          return(me.getComponent().sendGetFavoriteFlats())
        else
          return(0)
        end if
      end if
    end if
  end if
end

on showHideFullRooms me, tNodeId 
  pHideFullRoomsFlag = not pHideFullRoomsFlag
  return(me.updateInterface(tNodeId))
end

on roomkioskGoingFlat me, tRoomProps 
  tRoomProps.setAt(#flatId, tRoomProps.getAt(#id))
  tRoomProps.setAt(#id, "f_" & tRoomProps.getAt(#id))
  tRoomProps.setAt(#nodeType, 2)
  if pNodeCache.getAt(#own) = void() then
    pNodeCache.setAt(#own, [#children:[:]])
  end if
  pNodeCache.getAt(#own).getAt(#children).setaProp(tRoomProps.getAt(#id), tRoomProps)
  me.getComponent().executeRoomEntry(tRoomProps.getAt(#id))
  return(1)
end

on getFlatPassword me, tFlatID 
  tFlatInfo = me.getNodeInfo("f_" & tFlatID)
  if tFlatInfo = 0 then
    return(error(me, "Flat info is VOID", #getFlatPassword))
  end if
  if tFlatInfo.getAt(#door) <> "password" then
    return(0)
  end if
  if voidp(tFlatInfo.getAt(#password)) then
    return(0)
  else
    return(tFlatInfo.getAt(#password))
  end if
end

on flatAccessResult me, tMsg 
  if tMsg <> "flat_letin" then
    if tMsg = "flatpassword_ok" then
    else
      if tMsg <> "incorrect flat password" then
        if tMsg = "password required" then
          me.getInterface().flatPasswordIncorrect()
          me.updateState("enterEntry")
        end if
      end if
    end if
  end if
end

on delayedAlert me, tAlert, tDelay 
  if tDelay > 0 then
    createTimeout(#temp, tDelay, #delayedAlert, me.getID(), tAlert, 1)
  else
    executeMessage(#alert, [#Msg:tAlert])
  end if
end

on checkCacheForNode me, tNodeId 
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
end

on feedNewRoomList me, tid 
  if tid = void() then
    return(0)
  end if
  tNodeInfo = me.getNodeInfo(tid)
  if not listp(tNodeInfo) or not me.checkCacheForNode(tid) then
    return(me.callNodeUpdate())
  end if
  me.getInterface().updateRoomList(tNodeInfo.getAt(#id), tNodeInfo.getAt(#children))
  return(1)
end

on purgeNodeCacheExpList me 
  i = 1
  repeat while i <= pNodeCacheExpList.count
    if the milliSeconds - pNodeCacheExpList.getAt(i) > pUpdateInterval then
      tid = pNodeCacheExpList.getPropAt(i)
      pNodeCacheExpList.deleteAt(i)
      pNodeCache.deleteProp(tid)
    end if
    i = 1 + i
  end repeat
end

on saveFlatResults me, tMsg 
  if listp(tMsg) then
    tid = tMsg.getAt(#id)
    pNodeCache.setAt(tid, tMsg)
    pNodeCacheExpList.setAt(tid, the milliSeconds)
  end if
  return(me.feedNewRoomList(tMsg.getAt(#id)))
end

on sendNavigate me, tNodeId, tDepth 
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendNavigate))
  end if
  if tNodeId = void() then
    return(error(me, "Node id is VOID", #sendNavigate))
  end if
  if tDepth = void() then
    tDepth = 1
  end if
  tNodeMask = me.getCurrentNodeMask()
  getConnection(pConnectionId).send("NAVIGATE", [#integer:tNodeMask, #integer:integer(tNodeId), #integer:tDepth])
  me.purgeNodeCacheExpList()
  return(1)
end

on updateCategoryIndex me, tCategoryIndex 
  i = 1
  repeat while i <= tCategoryIndex.count
    pCategoryIndex.setaProp(tCategoryIndex.getPropAt(i), tCategoryIndex.getAt(i))
    i = 1 + i
  end repeat
  return(1)
end

on saveNodeInfo me, tNodeInfo 
  tNodeId = tNodeInfo.getAt(#id) & "/" & tNodeInfo.getAt(#nodeMask)
  if listp(tNodeInfo) then
    pNodeCache.setAt(tNodeId, tNodeInfo)
    pNodeCacheExpList.setAt(tNodeId, the milliSeconds)
  end if
  return(me.feedNewRoomList(tNodeId))
end

on updateSingleFlatInfo me, tdata, tMode 
  if listp(tdata) then
    tFlatID = "f_" & tdata.getAt(#flatId)
    tdata.addProp(#id, tFlatID)
    repeat while pNodeCache <= tMode
      myList = getAt(tMode, tdata)
      if myList.getAt(#children).getAt(tFlatID) <> void() then
        f = 1
        repeat while f <= tdata.count()
          myList.getAt(#children).getAt(tFlatID).setaProp(tdata.getPropAt(f), tdata.getAt(f))
          f = 1 + f
        end repeat
      end if
    end repeat
    executeMessage(symbol("receivedFlatStruct" & tFlatID), tdata)
  else
    return(error(me, "Flat info parsing failed!", #updateSingleFlatInfo))
  end if
end

on sendGetUserFlatCats me 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("GETUSERFLATCATS"))
  else
    return(error(me, "Connection not found:" && pConnectionId, #sendGetUserFlatCats))
  end if
end

on noflatsforuser me 
  return(me.getInterface().showRoomlistError(getText("nav_private_norooms")))
end

on noflats me 
  return(me.getInterface().showRoomlistError(getText("nav_prvrooms_notfound")))
end

on sendGetOwnFlats me 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("SUSERF", getObject(#session).get("user_name")))
  else
    return(0)
  end if
end

on sendGetFavoriteFlats me 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("GETFVRF", [#boolean:0]))
  else
    return(0)
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
      return(error(me, "Room ID expected!", #sendAddFavoriteFlat))
    end if
    return(getConnection(pConnectionId).send("ADD_FAVORITE_ROOM", [#integer:tRoomType, #integer:tRoomID]))
  else
    return(0)
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
      return(error(me, "Flat ID expected!", #sendRemoveFavoriteFlat))
    end if
    return(getConnection(pConnectionId).send("DEL_FAVORITE_ROOM", [#integer:tRoomType, #integer:tRoomID]))
  else
    return(0)
  end if
end

on sendGetFlatInfo me, tNodeId 
  if tNodeId contains "f_" then
    tFlatID = me.getNodeProperty(tNodeId, #flatId)
  else
    tFlatID = tNodeId
  end if
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return(error(me, "Flat ID expected!", #sendGetFlatInfo))
    else
      return(getConnection(pConnectionId).send("GETFLATINFO", tFlatID))
    end if
  else
    return(0)
  end if
end

on sendSearchFlats me, tQuery 
  if connectionExists(pConnectionId) then
    if voidp(tQuery) then
      return(error(me, "Search query is void!", #sendSearchFlats))
    end if
    tQuery = convertSpecialChars(tQuery, 1)
    return(getConnection(pConnectionId).send("SRCHF", "%" & tQuery & "%"))
  else
    return(0)
  end if
end

on sendGetSpaceNodeUsers me, tNodeId 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send("GETSPACENODEUSERS", [#integer:integer(tNodeId)]))
  end if
  return(0)
end

on sendDeleteFlat me, tNodeId 
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
end

on sendGetFlatCategory me, tNodeId 
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return(error(me, "Flat ID expected!", #sendGetFlatCategory))
    end if
    getConnection(pConnectionId).send("GETFLATCAT", [#integer:integer(tFlatID)])
  else
    return(0)
  end if
end

on sendSetFlatCategory me, tNodeId, tCategoryId 
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return(error(me, "Flat ID expected!", #sendSetFlatCategory))
    end if
    getConnection(pConnectionId).send("SETFLATCAT", [#integer:integer(tFlatID), #integer:integer(tCategoryId)])
  else
    return(0)
  end if
end

on sendupdateFlatInfo me, tPropList 
  if tPropList.ilk <> #propList or voidp(tPropList.getAt(#flatId)) then
    return(error(me, "Cant send updateFlatInfo", #sendupdateFlatInfo))
  end if
  tFlatMsg = ""
  repeat while [#flatId, #name, #door, #showownername] <= undefined
    tProp = getAt(undefined, tPropList)
    tFlatMsg = tFlatMsg & tPropList.getAt(tProp) & "/"
  end repeat
  tFlatMsg = tFlatMsg.getProp(#char, 1, length(tFlatMsg) - 1)
  getConnection(pConnectionId).send("UPDATEFLAT", tFlatMsg)
  tFlatMsg = string(tPropList.getAt(#flatId)) & "/" & "\r"
  tFlatMsg = tFlatMsg & "description=" & tPropList.getAt(#description) & "\r"
  tFlatMsg = tFlatMsg & "password=" & tPropList.getAt(#password) & "\r"
  tFlatMsg = tFlatMsg & "allsuperuser=" & tPropList.getAt(#ableothersmovefurniture) & "\r"
  tFlatMsg = tFlatMsg & "maxvisitors=" & tPropList.getAt(#maxVisitors)
  getConnection(pConnectionId).send("SETFLATINFO", tFlatMsg)
  return(1)
end

on sendRemoveAllRights me, tRoomID 
  tFlatID = integer(me.getNodeProperty(tRoomID, #flatId))
  if voidp(tFlatID) then
    return(0)
  end if
  getConnection(pConnectionId).send("REMOVEALLRIGHTS", [#integer:tFlatID])
  return(1)
end

on sendGetParentChain me, tRoomID 
  if voidp(tRoomID) then
    return(0)
  end if
  getConnection(pConnectionId).send("GETPARENTCHAIN", [#integer:integer(tRoomID)])
  return(1)
end

on getRoomProperties me, tRoomID 
  tProps = me.getNodeInfo(tRoomID)
  if tProps = void() then
    return(error(me, "Couldn't find room properties:" && tRoomID, #getRoomProperties))
  end if
  if tProps.getAt(#nodeType) <> 1 then
    tStruct = [:]
    tStruct.setAt(#id, string(tProps.getAt(#flatId)))
    tStruct.setAt(#name, tProps.getAt(#name))
    tStruct.setAt(#type, #private)
    tStruct.setAt(#marker, tProps.getAt(#marker))
    tStruct.setAt(#owner, tProps.getAt(#owner))
    tStruct.setAt(#door, tProps.getAt(#door))
    tStruct.setAt(#port, tProps.getAt(#port))
    tStruct.setAt(#trading, tProps.getAt(#trading))
    tStruct.setAt(#teleport, 0)
    tStruct.setAt(#casts, getVariableValue("room.cast.private"))
    return(tStruct)
  else
    tStruct = [:]
    tStruct.setAt(#id, tProps.getAt(#unitStrId))
    tStruct.setAt(#name, tProps.getAt(#name))
    tStruct.setAt(#type, #public)
    tStruct.setAt(#marker, tProps.getAt(#marker))
    tStruct.setAt(#owner, 0)
    tStruct.setAt(#door, tProps.getAt(#door))
    tStruct.setAt(#port, tProps.getAt(#port))
    tStruct.setAt(#teleport, 0)
    tStruct.setAt(#casts, tProps.getAt(#casts))
    return(tStruct)
  end if
end

on getCurrentNodeMask me 
  return(pHideFullRoomsFlag)
end

on updateState me, tstate, tProps 
  if tstate = "reset" then
    pState = tstate
    me.getInterface().setUpdates(0)
    return(0)
  else
    if tstate = "userLogin" then
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
      me.delay(2000, #updateState, "openNavigator")
      return(1)
    else
      if tstate = "openNavigator" then
        pState = tstate
        me.getInterface().showNavigator()
        executeMessage(#updateAvailableFlatCategories)
      else
        if tstate = "enterEntry" then
          pState = tstate
          executeMessage(#changeRoom)
          executeMessage(#leaveRoom)
          me.createNaviHistory(me.getInterface().getProperty(#categoryId))
          return(1)
        else
          return(error(me, "Unknown state:" && tstate, #updateState))
        end if
      end if
    end if
  end if
end
