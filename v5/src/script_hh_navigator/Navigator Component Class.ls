property pState, pItemList, pFlatCache, pConnectionId, pUpdatePeriod

on construct me 
  pItemList = [#units:[:], #flats:[:], #prvunits:[:]]
  pRoomData = [:]
  pFlatCache = [:]
  pUpdatePeriod = getIntVariable("navigator.updatetime.units", 60000)
  pConnectionId = getVariableValue("connection.info.id")
  pLoaderBarID = "Navigator Loader"
  registerMessage(#show_navigator, me.getID(), #showNavigator)
  registerMessage(#hide_navigator, me.getID(), #hideNavigator)
  registerMessage(#show_hide_navigator, me.getID(), #showhidenavigator)
  registerMessage(#leaveRoom, me.getID(), #showNavigator)
  registerMessage(#Initialize, me.getID(), #updateState)
  getObject(#session).set("user_rights", [])
  return(1)
end

on deconstruct me 
  pItemList = [:]
  pRoomData = [:]
  pFlatCache = [:]
  unregisterMessage(#show_navigator, me.getID())
  unregisterMessage(#hide_navigator, me.getID())
  unregisterMessage(#show_hide_navigator, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#Initialize, me.getID())
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

on saveUnitList me, tMsg 
  if listp(tMsg) then
    pItemList.setAt(#units, tMsg)
  end if
  return(me.getInterface().createUnitlist(pItemList.getAt(#units)))
end

on UpdateUnitList me, tMsg 
  if listp(tMsg) then
    f = 1
    repeat while f <= tMsg.count()
      tUnitid = tMsg.getPropAt(f)
      if not voidp(pItemList.getAt(#units).getAt(tUnitid)) then
        pItemList.getAt(#units).getAt(tUnitid).setAt(#usercount, tMsg.getAt(f).getAt(#usercount))
      end if
      f = 1 + f
    end repeat
  end if
  return(me.getInterface().UpdateUnitList(pItemList.getAt(#units)))
end

on prepareFlatList me, tMsg 
  pItemList.setAt(#prvunits, [:])
  if listp(tMsg) then
    f = 1
    repeat while f <= tMsg.count()
      tUnitPort = tMsg.getPropAt(f)
      pItemList.getAt(#prvunits).setAt(tUnitPort, tMsg.getAt(f))
      f = 1 + f
    end repeat
  end if
end

on saveFlatList me, tMsg, tMode 
  pItemList.setAt(#flats, [:])
  if listp(tMsg) then
    if tMode = #busy then
      pFlatCache.setAt(#flats, [:])
      f = 1
      repeat while f <= tMsg.count()
        tFlatID = tMsg.getPropAt(f)
        pItemList.getAt(#flats).setAt(tFlatID, tMsg.getAt(f))
        pFlatCache.getAt(#flats).setAt(tFlatID, tMsg.getAt(f))
        f = 1 + f
      end repeat
      exit repeat
    end if
    f = 1
    repeat while f <= tMsg.count()
      tFlatID = tMsg.getPropAt(f)
      pItemList.getAt(#flats).setAt(tFlatID, tMsg.getAt(f))
      f = 1 + f
    end repeat
  end if
  return(me.getInterface().saveFlatList(pItemList.getAt(#flats), tMode))
end

on saveFlatInfo me, tMsg 
  if listp(tMsg) then
    tFlatID = tMsg.getPropAt(1)
    tdata = tMsg.getAt(tFlatID)
    if listp(tdata) then
      f = 1
      repeat while f <= tdata.count()
        tProp = tdata.getPropAt(f)
        tDesc = tdata.getAt(tProp)
        if voidp(pItemList.getAt(#flats).getAt(tFlatID)) then
          pItemList.getAt(#flats).setAt(tFlatID, [:])
        end if
        pItemList.getAt(#flats).getAt(tFlatID).setAt(tProp, tDesc)
        f = 1 + f
      end repeat
    end if
  end if
  return(me.getInterface().saveFlatInfo(pItemList.getAt(#flats).getAt(tFlatID)))
end

on roomListTimeOutUpdate me 
  return(me.getInterface().roomlistupdate())
end

on noflatsforuser me 
  return(me.getInterface().failedFlatSearch(getText("nav_private_norooms")))
end

on noflats me 
  return(me.getInterface().failedFlatSearch(getText("nav_prvrooms_notfound")))
end

on getUnitUpdates me 
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #getUnitUpdates))
  end if
  return(getConnection(pConnectionId).send(#info, "GETUNITUPDATES"))
end

on searchBusyFlats me, tFromNum, tToNum, tMode 
  if not voidp(pFlatCache.getAt(#flats)) and tMode <> #update then
    return(me.getInterface().saveFlatList(pFlatCache.getAt(#flats), #cached))
  else
    if connectionExists(pConnectionId) then
      if not integerp(tFromNum) then
        tFromNum = 0
      end if
      if not integerp(tToNum) then
        tToNum = tFromNum + getIntVariable("navigator.private.count", 40)
      end if
      getConnection(pConnectionId).send(#info, "SBUSYF /" & tFromNum & "," & tToNum)
    end if
  end if
  return(0)
end

on getOwnFlats me 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send(#info, "SUSERF /" & getObject(#session).get("user_name")))
  end if
  return(0)
end

on getFavouriteFlats me 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send(#info, "GETFVRF"))
  end if
  return(0)
end

on addToFavouriteFlats me, tRoomId 
  if connectionExists(pConnectionId) then
    if voidp(tRoomId) then
      return(error(me, "Room ID expected!", #addToFavouriteFlats))
    end if
    return(getConnection(pConnectionId).send(#info, "ADD_FAVORITE_ROOM" && tRoomId))
  end if
  return(0)
end

on removeFavouriteFlats me, tRoomId 
  if connectionExists(pConnectionId) then
    if voidp(tRoomId) then
      return(error(me, "Room ID expected!", #removeFavouriteFlats))
    else
      return(getConnection(pConnectionId).send(#info, "DEL_FAVORITE_ROOM" && tRoomId))
    end if
  end if
  return(0)
end

on getFlatInfo me, tRoomId 
  if connectionExists(pConnectionId) then
    if voidp(tRoomId) then
      return(error(me, "Room ID expected!", #getFlatInfo))
    else
      return(getConnection(pConnectionId).send(#info, "GETFLATINFO /" & tRoomId))
    end if
  end if
  return(0)
end

on searchFlats me, tQuery 
  if connectionExists(pConnectionId) then
    if voidp(tQuery) then
      return(error(me, "Search query is void. cant search flats", #searchFlats))
    end if
    return(getConnection(pConnectionId).send(#info, "SRCHF /" & "%" & tQuery & "%"))
  end if
  return(0)
end

on GetUnitUsers me, tUnitName, tSubUnitName 
  if connectionExists(pConnectionId) then
    if not voidp(tSubUnitName) then
      return(getConnection(pConnectionId).send(#info, "GETUNITUSERS" && "/" & tUnitName & "/" & tSubUnitName))
    else
      return(getConnection(pConnectionId).send(#info, "GETUNITUSERS" && "/" & tUnitName))
    end if
  end if
  return(0)
end

on deleteFlat me, tFlatID 
  if connectionExists(pConnectionId) then
    return(getConnection(pConnectionId).send(#info, "DELETEFLAT /" & tFlatID))
  else
    return(0)
  end if
end

on sendupdateFlatInfo me, tPropList 
  if tPropList.ilk <> #propList or voidp(tPropList.getAt(#id)) then
    return(error(me, "Cant send updateFlatInfo", #sendupdateFlatInfo))
  end if
  tFlatMsg = ""
  repeat while [#id, #name, #door, #showownername] <= undefined
    tProp = getAt(undefined, tPropList)
    tFlatMsg = tFlatMsg & tPropList.getAt(tProp) & "/"
  end repeat
  tFlatMsg = tFlatMsg.getProp(#char, 1, length(tFlatMsg) - 1)
  getConnection(pConnectionId).send(#info, "UPDATEFLAT /" & tFlatMsg)
  tFlatMsg = string(tPropList.getAt(#id)) & "/" & "\r"
  tFlatMsg = tFlatMsg & "description=" & tPropList.getAt(#description) & "\r"
  tFlatMsg = tFlatMsg & "password=" & tPropList.getAt(#password) & "\r"
  tFlatMsg = tFlatMsg & "allsuperuser=" & tPropList.getAt(#ableothersmovefurniture)
  getConnection(pConnectionId).send(#info, "SETFLATINFO /" & tFlatMsg)
  return(1)
end

on getFlatIp me, tFlatPort 
  if not voidp(pItemList.getAt(#prvunits).getAt(tFlatPort)) then
    return(pItemList.getAt(#prvunits).getAt(tFlatPort).getAt(#ip))
  else
    return(error(me, "Missing flat server! Port:" && tFlatPort, #getFlatIp))
  end if
end

on getRoomProperties me, tRoomId 
  if integerp(value(tRoomId)) then
    if not voidp(pItemList.getAt(#flats).getAt(tRoomId)) then
      tRoomProps = pItemList.getAt(#flats).getAt(tRoomId)
      tRoomProps.setAt(#id, tRoomId)
      tRoomProps.setAt(#type, #private)
      tRoomProps.setAt(#ip, me.getFlatIp(tRoomProps.getAt(#port)))
    end if
  else
    if not voidp(pItemList.getAt(#units).getAt(tRoomId)) then
      tRoomProps = pItemList.getAt(#units).getAt(tRoomId)
      tRoomProps.setAt(#id, tRoomId)
      tRoomProps.setAt(#type, #public)
    end if
  end if
  if listp(tRoomProps) then
    return(tRoomProps)
  else
    return(error(me, "Couldn't find room properties:" && tRoomId, #getRoomProperties))
  end if
end

on roomkioskGoingFlat me, tRoomProps 
  tTemp = [:]
  tTemp.setAt(tRoomProps.getAt(#id), tRoomProps)
  me.saveFlatList(tTemp)
  return(me.getInterface().roomkioskGoingFlat(tRoomProps.getAt(#id)))
end

on getFlatPassword me, tFlatID 
  return(me.getInterface().getFlatPassword(tFlatID))
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

on getUnitId me, tMsg 
  f = 1
  repeat while f <= pItemList.getAt(#units).count
    tUnitid = pItemList.getAt(#units).getPropAt(f)
    tUnitData = pItemList.getAt(#units).getAt(tUnitid)
    if tUnitData.getAt(#port) = tMsg.getAt(#port) and tUnitData.getAt(#marker) = tMsg.getAt(#marker) then
      return(tUnitid)
    else
      f = 1 + f
    end if
  end repeat
  return(0)
end

on updateState me, tstate, tProps 
  if tstate = "reset" then
    pState = tstate
    if timeoutExists(#navigator_update) then
      removeTimeout(#navigator_update)
    end if
    return(0)
  else
    if tstate = "initialize" then
      pState = tstate
      initThread("thread.hobba")
      me.delay(1000, #updateState, "login")
    else
      if tstate = "login" then
        if getIntVariable("figurepartlist.loaded", 1) = 0 then
          return(me.delay(1000, #updateState, "login"))
        end if
        pState = tstate
        if not variableExists("login.mode") then
          setVariable("login.mode", #normal)
        end if
        getObject(#session).set("lastroom", "Entry")
        if not variableExists("quickLogin") then
          setVariable("quickLogin", 0)
        end if
        if getIntVariable("quickLogin", 0) and the runMode contains "Author" then
          if not voidp(getPref(getVariable("fuse.project.id", "fusepref"))) then
            tTemp = value(getPref(getVariable("fuse.project.id", "fusepref")))
            getObject(#session).set(#userName, tTemp.getAt(1))
            getObject(#session).set(#password, tTemp.getAt(2))
            return(me.updateState("connection"))
          end if
        end if
        initThread("thread.hobba")
        if tstate = #trial then
          executeMessage(#show_registration)
        else
          if tstate = #subscribe then
            executeMessage(#show_registration)
          else
            me.getInterface().getLogin().showLogin()
          end if
        end if
      else
        if tstate = "forgottenPassWord" then
          pState = tstate
          return(1)
        else
          if tstate = "connection" then
            pState = tstate
            tHost = getVariable("connection.info.host")
            tPort = getIntVariable("connection.info.port")
            if voidp(tHost) or voidp(tPort) then
              return(error(me, "Server data not found!", #updateState))
            end if
            if not createConnection(pConnectionId, tHost, tPort) then
              return(error(me, "Failed to create info connection!!!", #updateState))
            else
              return(1)
            end if
          else
            if tstate = "connectionOk" then
              if pState = "forgottenPassWord" then
                return(1)
              end if
              if not connectionExists(pConnectionId) then
                return(me.updateState("connection"))
              end if
              pState = tstate
              tUserName = getObject(#session).get(#userName)
              tPassword = getObject(#session).get(#password)
              if voidp(tUserName) or voidp(tPassword) then
                return(0)
              end if
              if tUserName = "" or tPassword = "" then
                return(0)
              end if
              if not stringp(tUserName) or not stringp(tPassword) then
                return(0)
              end if
              getConnection(pConnectionId).send(#info, "LOGIN" && tUserName && tPassword)
              getConnection(pConnectionId).send(#info, "UNIQUEMACHINEID" && getMachineID())
              return(1)
            else
              if tstate = "loginOk" then
                pState = tstate
                executeMessage(#userlogin, 1)
                if not connectionExists(pConnectionId) then
                  return(me.updateState("connection"))
                end if
                if getIntVariable("quickLogin", 0) and the runMode contains "Author" then
                  setPref(getVariable("fuse.project.id", "fusepref"), string([getObject(#session).get(#userName), getObject(#session).get(#password)]))
                  me.getInterface().getLogin().hideLogin()
                  me.updateState("openNavigator")
                else
                  me.getInterface().getLogin().showUserFound()
                  me.delay(2000, #updateState, "openNavigator")
                end if
                tConnection = getConnection(pConnectionId)
                tConnection.send(#info, "GETALLUNITS")
                tConnection.send(#info, "GETADFORME general")
                tConnection.send(#info, "MESSENGERINIT")
                me.searchBusyFlats(void(), void(), #update)
                return(1)
              else
                if tstate = "openNavigator" then
                  pState = tstate
                  me.showNavigator()
                  createTimeout(#navigator_update, pUpdatePeriod, #roomListTimeOutUpdate, me.getID(), void(), 0)
                  return(executeMessage(#navigator_activated, #navigator))
                else
                  if tstate = "enterEntry" then
                    pState = tstate
                    executeMessage(#leaveRoom)
                    getObject(#session).set("lastroom", "Entry")
                    return(1)
                  else
                    if tstate <> "enterRoom" then
                      if tstate <> "enterUnit" then
                        if tstate = "enterFlat" then
                          pState = tstate
                          me.getInterface().hideNavigator()
                          if getObject(#session).get("lastroom") = "Entry" then
                            if threadExists(#entry) then
                              getThread(#entry).getComponent().leaveEntry()
                            end if
                            tRoomDataStruct = me.getRoomProperties(tProps)
                            getObject(#session).set("lastroom", tRoomDataStruct)
                            return(me.delay(500, #updateState, tstate))
                          else
                            if connectionExists(pConnectionId) then
                              getConnection(pConnectionId).send(#info, "GETADFORME general")
                            end if
                            if voidp(tProps) then
                              if getObject(#session).get("lastroom").ilk = #propList then
                                tProps = getObject(#session).get("lastroom").getaProp(#id)
                              else
                                error(me, "Target room's ID expected!", #updateState)
                                return(me.updateState("enterEntry"))
                              end if
                            end if
                            tRoomDataStruct = me.getRoomProperties(tProps)
                            getObject(#session).set("lastroom", tRoomDataStruct)
                            return(executeMessage(#enterRoom, tRoomDataStruct))
                          end if
                        else
                          if tstate = "disconnection" then
                            pState = tstate
                            return(me.getInterface().showDisconnectionDialog())
                          else
                            return(error(me, "Unknown state:" && tstate, #updateState))
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
