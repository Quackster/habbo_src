property pState, pCategoryIndex, pNodeCache, pNaviHistory, pRootUnitCatId, pRootFlatCatId, pDefaultUnitCatId, pDefaultFlatCatId, pUpdatePeriod, pConnectionId

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
  pNaviHistory = []
  pUpdatePeriod = getIntVariable("navigator.updatetime", 60000)
  pConnectionId = getVariableValue("connection.info.id")
  getObject(#session).set("lastroom", "Entry")
  registerMessage(#userlogin, me.getID(), #updateState)
  registerMessage(#show_navigator, me.getID(), #showNavigator)
  registerMessage(#hide_navigator, me.getID(), #hideNavigator)
  registerMessage(#show_hide_navigator, me.getID(), #showhidenavigator)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#executeRoomEntry, me.getID(), #executeRoomEntry)
  registerMessage(#requestFlatStruct, me.getID(), #sendGetFlatInfo)
  registerMessage(#updateAvailableFlatCategories, me.getID(), #sendGetUserFlatCats)
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
  unregisterMessage(#executeRoomEntry, me.getID())
  unregisterMessage(#requestFlatStruct, me.getID())
  unregisterMessage(#updateAvailableFlatCategories, me.getID())
  return me.updateState("reset")
end

on showNavigator me
  return me.getInterface().showNavigator()
end

on hideNavigator me
  return me.getInterface().hideNavigator(#hide)
end

on showhidenavigator me
  return me.getInterface().showhidenavigator(#hide)
end

on getState me
  return pState
end

on leaveRoom me
  getObject(#session).set("lastroom", "Entry")
  return me.getInterface().showNavigator()
end

on getNodeInfo me, tNodeId, tCache
  if tNodeId = VOID then
    return 0
  end if
  if tCache <> VOID then
    if pNodeCache[tCache] <> VOID then
      return pNodeCache[tCache][#children][tNodeId]
    end if
  end if
  if pNodeCache[tNodeId] <> VOID then
    return pNodeCache[tNodeId]
  end if
  repeat with tList in pNodeCache
    if tList[#children][tNodeId] <> VOID then
      return tList[#children][tNodeId]
    end if
  end repeat
  return 0
end

on getNodeParentId me, tid
  if pCategoryIndex[tid] = VOID then
    return 0
  end if
  if (tid = pRootUnitCatId) or (tid = pRootFlatCatId) then
    return 0
  end if
  return pCategoryIndex[tid][#parentid]
end

on getNodeChildren me, tid
  if tid = VOID then
    return [:]
  end if
  if pNodeCache[tid] = VOID then
    return [:]
  end if
  return pNodeCache[tid][#children]
end

on getNodeName me, tid
  if tid = VOID then
    return EMPTY
  end if
  if pCategoryIndex[tid] <> VOID then
    return pCategoryIndex[tid][#name]
  end if
  repeat with tList in pNodeCache
    if tList[#children][tid] <> VOID then
      return tList[#children][tid][#name]
    end if
  end repeat
  return EMPTY
end

on setNodeProperty me, tNodeId, tProp, tValue
  if tNodeId = VOID then
    return 0
  end if
  repeat with tList in pNodeCache
    if not (tList[#children][tNodeId] = VOID) then
      tList[#children][tNodeId].setaProp(tProp, tValue)
    end if
  end repeat
  return 1
end

on getNodeProperty me, tNodeId, tProp
  if tNodeId = VOID then
    return 0
  end if
  repeat with tList in pNodeCache
    tNode = tList.getaProp(#children).getaProp(tNodeId)
    if not voidp(tNode) then
      tValue = tNode.getaProp(tProp)
      if not voidp(tValue) then
        return tValue
      end if
    end if
  end repeat
  return 0
end

on feedNewRoomList me, tid
  if not listp(pNodeCache[tid]) then
    return me.callNodeUpdate()
  end if
  tNodeCache = pNodeCache[tid]
  me.getInterface().updateRoomList(tNodeCache[#id], tNodeCache[#children])
  return 1
end

on prepareRoomEntry me, tRoomId
  tRoomInfo = me.getComponent().getNodeInfo(tRoomId)
  if tRoomInfo = 0 then
    return 0
  end if
  if tRoomInfo[#nodeType] = 1 then
    return me.getComponent().executeRoomEntry(tRoomId)
  else
    me.getInterface().hideNavigator()
    registerMessage(symbol("receivedFlatStruct" & tRoomId), me.getInterface().getID(), #checkFlatAccess)
    return me.getComponent().sendGetFlatInfo(tRoomId)
  end if
end

on executeRoomEntry me, tNodeId, tRoomDataStruct
  me.getInterface().hideNavigator()
  if getObject(#session).get("lastroom") = "Entry" then
    if threadExists(#entry) then
      getThread(#entry).getComponent().leaveEntry()
    end if
    if tRoomDataStruct = VOID then
      tRoomDataStruct = me.getRoomProperties(tNodeId)
    end if
    getObject(#session).set("lastroom", tRoomDataStruct)
    me.delay(500, #executeRoomEntry)
    return 1
  else
    if voidp(tNodeId) then
      if getObject(#session).get("lastroom").ilk = #propList then
        tRoomDataStruct = getObject(#session).get("lastroom")
      else
        error(me, "Target room's ID expected!", #executeRoomEntry)
        return me.updateState("enterEntry")
      end if
    else
      if tRoomDataStruct = VOID then
        tRoomDataStruct = me.getRoomProperties(tNodeId)
      end if
      getObject(#session).set("lastroom", tRoomDataStruct)
    end if
    return executeMessage(#enterRoom, tRoomDataStruct)
  end if
end

on expandNode me, tNodeId
  me.getInterface().clearRoomList()
  tPrevNodeId = me.getInterface().getProperty(#categoryId)
  if not voidp(tPrevNodeId) then
    pNodeCache.deleteProp(tPrevNodeId)
  end if
  me.getInterface().setProperty(#categoryId, tNodeId)
  me.createNaviHistory(tNodeId)
  return me.sendNavigate(tNodeId)
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
  tParent = me.getNodeParentId(tCategoryId)
  repeat while tParent <> 0
    if pNaviHistory.getPos(tParent) = 0 then
      pNaviHistory.addAt(1, tParent)
      tText = me.getNodeName(tParent) & RETURN & tText
      tParent = me.getNodeParentId(tParent)
      next repeat
    end if
    return error(me, "Category loop detected in navigation data!", #createNaviHistory)
  end repeat
  if getObject(#session).get("lastroom") <> "Entry" then
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
      tCategoryId = me.getInterface().getProperty(#categoryId)
      return me.sendNavigate(tCategoryId)
    #own:
      return me.getComponent().sendGetOwnFlats()
    #fav:
      return me.getComponent().sendGetFavoriteFlats()
    otherwise:
      return 0
  end case
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
    "incorrect flat password", "password required":
      me.getInterface().flatPasswordIncorrect()
      me.updateState("enterEntry")
  end case
end

on delayedAlert me, tAlert, tDelay
  if tDelay > 0 then
    createTimeout(#temp, tDelay, #delayedAlert, me.getID(), tAlert, 1)
  else
    executeMessage(#alert, [#msg: tAlert])
  end if
end

on saveFlatResults me, tMsg
  if listp(tMsg) then
    tid = tMsg[#id]
    pNodeCache[tid] = tMsg
  end if
  return me.feedNewRoomList(tMsg[#id])
end

on sendNavigate me, tNodeId, tDepth
  if not connectionExists(pConnectionId) then
    return error(me, "Connection not found:" && pConnectionId, #sendNavigate)
  end if
  if tNodeId = VOID then
    return error(me, "Node id is VOID", #sendNavigate)
  end if
  if tDepth = VOID then
    tDepth = 1
  end if
  getConnection(pConnectionId).send("NAVIGATE", [#integer: integer(tNodeId), #integer: tDepth])
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
  if listp(tNodeInfo) then
    pNodeCache[tNodeId] = tNodeInfo
  end if
  return me.feedNewRoomList(tNodeId)
end

on updateSingleFlatInfo me, tdata, tMode
  if listp(tdata) then
    tFlatID = "f_" & tdata[#flatId]
    tdata.addProp(#id, tFlatID)
    repeat with myList in pNodeCache
      if myList[#children][tFlatID] <> VOID then
        repeat with f = 1 to tdata.count()
          myList[#children][tFlatID].setaProp(tdata.getPropAt(f), tdata[f])
        end repeat
      end if
    end repeat
    executeMessage(symbol("receivedFlatStruct" & tFlatID), tdata)
  else
    return error(me, "Flat info parsing failed!", #updateSingleFlatInfo)
  end if
end

on sendGetUserFlatCats me
  if connectionExists(pConnectionId) then
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
    return getConnection(pConnectionId).send("SUSERF", getObject(#session).get("user_name"))
  else
    return 0
  end if
end

on sendGetFavoriteFlats me
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send("GETFVRF")
  else
    return 0
  end if
end

on sendAddFavoriteFlat me, tNodeId
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return error(me, "Room ID expected!", #sendAddFavoriteFlat)
    end if
    return getConnection(pConnectionId).send("ADD_FAVORITE_ROOM", tFlatID)
  else
    return 0
  end if
end

on sendRemoveFavoriteFlat me, tNodeId
  tFlatID = me.getNodeProperty(tNodeId, #flatId)
  if connectionExists(pConnectionId) then
    if voidp(tFlatID) then
      return error(me, "Flat ID expected!", #sendRemoveFavoriteFlat)
    end if
    return getConnection(pConnectionId).send("DEL_FAVORITE_ROOM", tFlatID)
  else
    return 0
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
    repeat with tList in pNodeCache
      tList[#children].deleteProp(tNodeId)
    end repeat
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
  tFlatMsg = tFlatMsg & "password=" & tPropList[#password] & RETURN
  tFlatMsg = tFlatMsg & "allsuperuser=" & tPropList[#ableothersmovefurniture]
  getConnection(pConnectionId).send("SETFLATINFO", tFlatMsg)
  return 1
end

on sendRemoveAllRights me, tRoomId
  tFlatID = me.getNodeProperty(tRoomId, #flatId)
  if voidp(tFlatID) then
    return 0
  end if
  tFlatIdInt = integer(tFlatID)
  getConnection(pConnectionId).send("REMOVEALLRIGHTS", [#integer: tFlatIdInt])
  return 1
end

on sendGetParentChain me, tRoomId
  tFlatID = me.getNodeProperty(tRoomId, #flatId)
  if voidp(tRoomId) then
    return 0
  end if
  getConnection(pConnectionId).send("GETPARENTCHAIN", [#integer: integer(tRoomId)])
  return 1
end

on getRoomProperties me, tRoomId
  tProps = me.getNodeInfo(tRoomId)
  if tProps = VOID then
    return error(me, "Couldn't find room properties:" && tRoomId, #getRoomProperties)
  end if
  if tProps[#owner] <> VOID then
    tStruct = [:]
    tStruct[#id] = tProps[#flatId]
    tStruct[#name] = tProps[#name]
    tStruct[#type] = #private
    tStruct[#marker] = tProps[#marker]
    tStruct[#owner] = tProps[#owner]
    tStruct[#door] = tProps[#door]
    tStruct[#port] = tProps[#port]
    tStruct[#trading] = tProps[#trading]
    tStruct[#teleport] = 0
    tStruct[#casts] = getVariableValue("room.cast.private")
    return tStruct
  else
    tStruct = [:]
    tStruct[#id] = tProps[#unitStrId]
    tStruct[#name] = tProps[#name]
    tStruct[#type] = #public
    tStruct[#marker] = tProps[#marker]
    tStruct[#owner] = 0
    tStruct[#door] = tProps[#door]
    tStruct[#port] = tProps[#port]
    tStruct[#teleport] = 0
    tStruct[#casts] = tProps[#casts]
    return tStruct
  end if
end

on updateState me, tstate, tProps
  case tstate of
    "reset":
      pState = tstate
      if timeoutExists(#navigator_update) then
        removeTimeout(#navigator_update)
      end if
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
      me.delay(2000, #updateState, "openNavigator")
      return 1
    "openNavigator":
      pState = tstate
      me.showNavigator()
      executeMessage(#updateAvailableFlatCategories)
      return createTimeout(#navigator_update, pUpdatePeriod, #callNodeUpdate, me.getID(), VOID, 0)
    "enterEntry":
      pState = tstate
      executeMessage(#leaveRoom)
      me.createNaviHistory(me.getInterface().getProperty(#categoryId))
      return 1
    otherwise:
      return error(me, "Unknown state:" && tstate, #updateState)
  end case
end
