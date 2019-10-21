property pChatProps, pClassContId, pBalloonId, pAdSystemID, pInterstitialSystemID, pSpectatorSystemID, pShadowManagerID, pRoomConnID, pUserObjList, pActiveObjList, pPassiveObjList, pItemObjList, pRoomPrgID, pActiveFlag, pRoomId, pSaveData, pPrvRoomsReady, pTrgDoorID, pCacheFlag, pCacheKey, pFurniChooserID, pCurrentSlidingObjects, pCastLoaded, pPickedCryName, pProcessList, pRoomPollerID, pHeightMapData, pEnterRoomAlert

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
  pPickedCryName = ""
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pBalloonId = "Room Balloon"
  pClassContId = "Room Classes"
  pRoomPrgID = "Room Program"
  pRoomPollerID = "Room Poller"
  pAdSystemID = "Room ad"
  pInterstitialSystemID = "Interstitial system"
  pSpectatorSystemID = "Room Mode Manager"
  pFurniChooserID = "Furniture Chooser"
  pShadowManagerID = "Room Shadow Manager"
  pChatProps = [:]
  pChatProps.setAt("returnCount", 0)
  pChatProps.setAt("timerStart", 0)
  pChatProps.setAt("timerDelay", 0)
  pChatProps.setAt("mode", "CHAT")
  pChatProps.setAt("hobbaCmds", getVariableValue("moderator.cmds"))
  createObject(pClassContId, getClassVariable("variable.manager.class"))
  getObject(pClassContId).dump("fuse.object.classes", "\r")
  createObject(pBalloonId, "Balloon Manager")
  createObject(pAdSystemID, "Ad Manager")
  pCastLoaded = 0
  pPrvRoomsReady = 0
  createObject(pInterstitialSystemID, "Interstitial Manager")
  createObject(pSpectatorSystemID, "Spectator System Class")
  pCurrentSlidingObjects = [:]
  createObject(pShadowManagerID, "Shadow Manager")
  registerMessage(#pickAndGoCFH, me.getID(), #pickAndGoCFH)
  registerMessage(#enterRoom, me.getID(), #enterRoom)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#enterRoomDirect, me.getID(), #enterRoomDirect)
  registerMessage(#setEnterRoomAlert, me.getID(), #setEnterRoomAlert)
  registerMessage(#removeEnterRoomAlert, me.getID(), #removeEnterRoomAlert)
  return TRUE
end

on deconstruct me 
  removeUpdate(me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoomDirect, me.getID())
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
  pRoomId = ""
  pUserObjList = [:]
  pActiveObjList = [:]
  pPassiveObjList = [:]
  pItemObjList = [:]
  pCurrentSlidingObjects = [:]
  pEnterRoomAlert = ""
  return TRUE
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
    return(executeMessage(#leaveRoom))
  end if
  getInterstitial().adRequested()
  me.getRoomConnection().send("GETINTERST", "general")
  tdata = tRoomDataStruct.duplicate()
  if voidp(tdata.getAt(#id)) then
    error(me, "Missing ID in room data struct!", #enterRoom)
    return(executeMessage(#leaveRoom))
  end if
  if pRoomId <> "" then
    executeMessage(#changeRoom)
  end if
  tSession = getObject(#session)
  tSession.set("room_owner", 0)
  tSession.set("room_controller", 0)
  if (tdata.getAt(#type) = #private) then
    pRoomId = "private"
  else
    pRoomId = tdata.getAt(#id)
  end if
  pTrgDoorID = void()
  pSaveData = tdata
  pCastLoaded = 0
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
  tCurrentScale = me.getRoomScale(pSaveData.getAt(#marker))
  tCurrentRoomCasts = pSaveData.getAt(#casts)
  pRoomId = "private"
  pTrgDoorID = tdata.getAt(#id)
  pSaveData = tdata.duplicate()
  pSaveData.setAt(#type, #private)
  getObject(#session).set("lastroom", pSaveData.duplicate())
  if (me.getRoomScale(pSaveData.getAt(#marker)) = #small) and (tCurrentScale = #large) and not pPrvRoomsReady then
    pSaveData.setAt(#casts, tCurrentRoomCasts)
    me.loadRoomCasts()
    pPrvRoomsReady = 1
    return FALSE
  end if
  if tReConnect then
    return(me.roomCastLoaded())
  else
    return(me.getRoomConnection().send("GOVIADOOR", pTrgDoorID & "/" & pSaveData.getAt(#teleport)))
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
    getObject(#cache).Remove(pCacheKey)
  end if
  if objectp(me.getInterface().pIgnoreListObj) then
    me.getInterface().pIgnoreListObj.reset()
  end if
  if objectExists(#furniChooser) then
    getObject(#furniChooser).close()
  end if
  pActiveFlag = 0
  if not tJumpingToSubUnit then
    pRoomId = ""
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
  getObject(#session).set("room_owner", 0)
  getObject(#session).set("room_controller", 0)
  return TRUE
end

on enterRoomDirect me, tdata 
  if (tdata.getAt(#type) = #private) then
    pRoomId = "private"
  else
    pRoomId = tdata.getAt(#id)
  end if
  pTrgDoorID = void()
  pSaveData = tdata
  getObject(#session).set("lastroom", pSaveData)
  if (pSaveData.getAt(#type) = #private) then
    tRoomID = integer(pSaveData.getAt(#id))
    tDoorID = 0
    tTypeID = 0
  else
    tRoomID = integer(pSaveData.getAt(#port))
    tDoorID = integer(pSaveData.getAt(#door))
    tTypeID = 1
  end if
  if (tDoorID.ilk = #void) then
    tDoorID = 0
  end if
  return(getConnection(pRoomConnID).send(#room_directory, [#boolean:tTypeID, #integer:tRoomID, #integer:tDoorID]))
end

on createUserObject me, tdata 
  if me.userObjectExists(tdata.getAt(#id)) then
    me.removeUserObject(tdata.getAt(#id))
  end if
  if me.createRoomObject(tdata, pUserObjList, "user") then
    return(executeMessage(#create_user, tdata.getAt(#name), tdata.getAt(#id)))
  else
    return FALSE
  end if
end

on removeUserObject me, tid 
  if me.removeRoomObject(tid, pUserObjList) then
    return(executeMessage(#remove_user, tid))
  else
    return FALSE
  end if
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

on getAd me 
  return(getObject(pAdSystemID))
end

on getInterstitial me 
  if objectExists(pInterstitialSystemID) then
    return(getObject(pInterstitialSystemID))
  else
    return(error(me, "Interstitial manager not found", #getInterstitial))
  end if
end

on getClassContainer me 
  return(getObject(pClassContId))
end

on getOwnUser me 
  return(me.getUserObject(getObject(#session).get("user_index")))
end

on getShadowManager me 
  if objectExists(pShadowManagerID) then
    return(getObject(pShadowManagerID))
  else
    return(error(me, "Shadow manager not found", #getShadowManager))
  end if
end

on roomExists me, tRoomID 
  if voidp(tRoomID) then
    return(pActiveFlag)
  else
    return((pRoomId = tRoomID))
  end if
end

on sendChat me, tChat 
  if voidp(tChat) then
    return FALSE
  end if
  if (tChat = "") then
    return FALSE
  end if
  tChat = convertSpecialChars(tChat, 1)
  if (tChat.getProp(#char, 1) = ":") then
    if (tChat.getProp(#word, 1) = ":chooser") then
      if getObject(#session).get("user_rights").getOne("fuse_habbo_chooser") then
        return(createObject(#chooser, "User Chooser Class"))
      end if
    else
      if (tChat.getProp(#word, 1) = ":furni") then
        if pSaveData.getAt(#type) <> #private then
          return TRUE
        end if
        if getObject(#session).get("user_rights").getOne("fuse_furni_chooser") then
          if not objectExists(pFurniChooserID) then
            createObject(pFurniChooserID, "Furni Chooser Class")
          end if
          if (getObject(pFurniChooserID) = 0) then
            return FALSE
          end if
          return(getObject(pFurniChooserID).showList())
        end if
      else
        if (tChat.getProp(#word, 1) = ":performance") then
          if getObject(#session).get("user_rights").getOne("fuse_performance_panel") then
            return(performance())
          end if
        else
          if tChat.getProp(#word, 1) <> ":debug" then
            if tChat.getProp(#word, 1) <> ":log" then
              if (tChat.getProp(#word, 1) = ":usestaffrights") then
                if getObject(#session).get("user_rights").getOne("fuse_debug_window") then
                  if not the runMode contains "Author" then
                    me.sendChat(":log")
                  end if
                end if
              else
                if (tChat.getProp(#word, 1) = ":editcatalogue") then
                  if getObject(#session).get("user_rights").getOne("fuse_catalog_editor") then
                    return(executeMessage("edit_catalogue"))
                  end if
                else
                  if (tChat.getProp(#word, 1) = ":copypaste") then
                    if getObject(#session).get("user_rights").getOne("fuse_debug_window") then
                      the editShortcutsEnabled = 1
                      return TRUE
                    end if
                  end if
                end if
              end if
              if getObject(#session).get("user_rights").getOne("fuse_debug_window") then
                tKeywords = me.getInterface().getKeywords()
                if tChat.getProp(#word, 1) <> tKeywords.getAt(1) then
                  if (tChat.getProp(#word, 1) = tKeywords.getAt(2)) then
                    if float(the productVersion.getProp(#char, 1, 3)) >= 8.5 then
                      the debugPlaybackEnabled = 1
                    end if
                    tInfoID = getVariable("connection.info.id")
                    if (tChat.getProp(#word, 1) = tKeywords.getAt(1)) then
                      if connectionExists(tInfoID) then
                        getConnection(tInfoID).setLogMode(1)
                      end if
                    else
                      if (tChat.getProp(#word, 1) = tKeywords.getAt(2)) then
                        if connectionExists(tInfoID) then
                          getConnection(tInfoID).setLogMode(0)
                        end if
                      end if
                    end if
                    return TRUE
                  else
                    if (tChat.getProp(#word, 1) = tKeywords.getAt(3)) then
                      if not memberExists("System Debug Class") then
                        return FALSE
                      end if
                      if not objectExists("loggertool") then
                        createObject("loggertool", "Debug System Class")
                      end if
                      if (getObject("loggertool") = 0) then
                        return TRUE
                      end if
                      return(getObject("loggertool").initDebug())
                    end if
                  end if
                  tKeywords = void()
                  if the shiftDown then
                    tMode = "SHOUT"
                  else
                    tMode = pChatProps.getAt("mode")
                  end if
                  tSelected = me.getInterface().getSelectedObject()
                  if me.userObjectExists(tSelected) then
                    tSelected = me.getUserObject(tSelected).getName()
                  else
                    tSelected = ""
                  end if
                  if pChatProps.getAt("hobbaCmds").getOne(tChat.getProp(#word, 1, 2)) then
                    tMode = "CHAT"
                    if (tChat.getProp(#word, 2) = "x") then
                      if (tSelected = "") then
                        return TRUE
                      end if
                      tOffsetX = offset("x", tChat)
                      tChat = tChat.getProp(#char, 1, (tOffsetX - 1)) & tSelected & tChat.getProp(#char, (tOffsetX + 1), tChat.length)
                    end if
                  else
                    if (tMode = "WHISPER") then
                      tChat = tSelected && tChat
                    end if
                  end if
                  return(me.getRoomConnection().send(tMode, [#string:tChat]))
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on setChatMode me, tMode, tUpdate 
  if (tMode = "whisper") then
    pChatProps.setAt("mode", "WHISPER")
  else
    if (tMode = "shout") then
      pChatProps.setAt("mode", "SHOUT")
    else
      pChatProps.setAt("mode", "CHAT")
    end if
  end if
  if tUpdate then
    me.getInterface().setSpeechDropdown(tMode)
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

on addSlideObject me, tid, tFromLoc, tToLoc, tTimeNow, tHasCharacter 
  if the paramCount < 4 then
    return(error(me, "Wrong parameter count", #addSlideObject))
  end if
  tid = tid.string
  if voidp(tTimeNow) then
    tTimeNow = the milliSeconds
  end if
  if voidp(tHasCharacter) then
    tHasCharacter = 0
  end if
  if not voidp(pActiveObjList.getAt(tid)) then
    tObj = pActiveObjList.getAt(tid)
    tObj.setSlideTo(tFromLoc, tToLoc, tTimeNow, tHasCharacter)
    pCurrentSlidingObjects.setAt(tid, tObj)
  end if
end

on removeSlideObject me, tid 
  tid = tid.string
  if not voidp(pCurrentSlidingObjects.getAt(tid)) then
    pCurrentSlidingObjects.deleteProp(tid)
  end if
end

on roomPrePartFinished me 
  tInterstFinished = getInterstitial().isAdFinished()
  if (pCastLoaded = 0) or (tInterstFinished = 0) then
    return FALSE
  end if
  if (pSaveData.getAt(#type) = #private) then
    tRoomID = integer(pSaveData.getAt(#id))
    tDoorID = 0
    tTypeID = 0
  else
    tRoomID = integer(pSaveData.getAt(#port))
    tDoorID = integer(pSaveData.getAt(#door))
    tTypeID = 1
  end if
  if (tDoorID.ilk = #void) then
    tDoorID = 0
  end if
  return(getConnection(pRoomConnID).send(#room_directory, [#boolean:tTypeID, #integer:tRoomID, #integer:tDoorID]))
  return TRUE
end

on getSpectatorMode me 
  tModeMgrObj = getObject(pSpectatorSystemID)
  if (tModeMgrObj = 0) then
    return(error(me, "Spectator System missing!", #getSpectatorMode))
  end if
  return(tModeMgrObj.getSpectatorMode())
end

on setSpectatorMode me, tstate 
  tModeMgrObj = getObject(pSpectatorSystemID)
  if (tModeMgrObj = 0) then
    return(error(me, "Spectator System missing!", #setSpectatorMode))
  end if
  tRoomData = me.getRoomData()
  if (tRoomData = 0) then
    tRoomType = #public
  else
    tRoomType = tRoomData.getAt(#type)
  end if
  return(tModeMgrObj.setSpectatorMode(tstate, tRoomType))
end

on pickAndGoCFH me, tSender 
  if not stringp(tSender) then
    return FALSE
  end if
  pPickedCryName = tSender
  return TRUE
end

on getPickedCryName me 
  return(pPickedCryName)
end

on showCfhSenderDelayed me, tid 
  pPickedCryName = ""
  return(me.getInterface().showCfhSenderDelayed(tid))
end

on loadRoomCasts me 
  if (pRoomId = "") then
    return FALSE
  end if
  tCastVarPrefix = "room.cast."
  tCastList = me.addToCastDownloadList(tCastVarPrefix, tCastList)
  if (pSaveData.getAt(#type) = #public) then
    pPrvRoomsReady = 0
  end if
  if (pSaveData.getAt(#type) = #private) then
    if (me.getRoomScale(pSaveData.getAt(#marker)) = #small) then
      tCastVarPrefix = "room.cast.small."
      tCastList = me.addToCastDownloadList(tCastVarPrefix, tCastList)
      pPrvRoomsReady = 1
    end if
  end if
  if tCastList.count > 0 then
    tCastLoadId = startCastLoad(tCastList, 1)
    registerCastloadCallback(tCastLoadId, #loadRoomCasts, me.getID())
    me.getInterface().showLoaderBar(tCastLoadId, getText("room_hold", getText("room_loading", "Hold on...")))
    return TRUE
  end if
  if voidp(pSaveData.getAt(#casts)) then
    pSaveData.setAt(#casts, [])
  end if
  if pSaveData.getAt(#casts).count < 1 then
    error(me, "Cast for room not defined:" && pRoomId, #loadRoomCasts)
    me.getInterface().hideLoaderBar()
    executeMessage(#leaveRoom)
  end if
  tCastLoadId = startCastLoad(pSaveData.getAt(#casts), 0)
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
    tRoomCasts = pSaveData.getAt(#casts)
    repeat while tRoomCasts <= undefined
      tCast = getAt(undefined, undefined)
      if not castExists(tCast) then
        error(me, "Cast required by room not found:" && tCast, #roomCastLoaded)
        return(executeMessage(#leaveRoom))
      end if
    end repeat
  end if
  pCastLoaded = 1
  me.roomPrePartFinished()
end

on roomConnected me, tMarker, tstate 
  if (pRoomId = "") then
    pRoomId = "null"
    executeMessage(#leaveRoom)
    return(error(me, "Room building process is aborted!", #roomCastLoaded))
  end if
  if not voidp(pTrgDoorID) then
    if (tstate = "OPC_OK") then
      tValue = me.getRoomConnection().send("GOVIADOOR", pTrgDoorID & "/" & pSaveData.getAt(#teleport))
      pTrgDoorID = void()
      return(tValue)
    end if
  end if
  if (pSaveData.getAt(#type) = #private) then
    if (tstate = "OPC_OK") then
      tStr = pSaveData.getAt(#id)
      if threadExists(#navigator) then
        tPassword = getThread(#navigator).getComponent().getFlatPassword(pSaveData.getAt(#id))
        if tPassword <> 0 then
          tStr = tStr & "/" & tPassword
        end if
      end if
      return(me.getRoomConnection().send("TRYFLAT", tStr))
    else
      if (tstate = "FLAT_LETIN") then
        return(me.getRoomConnection().send("GOTOFLAT", pSaveData.getAt(#id)))
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
  if connectionExists(pRoomConnID) then
    getConnection(pRoomConnID).send("GETROOMAD")
  end if
  if memberExists(pSaveData.getAt(#marker) && "Class") then
    createObject(pRoomPrgID, pSaveData.getAt(#marker) && "Class")
  end if
  if (pSaveData.getAt(#type) = #private) then
    pProcessList = [#passive:0, #Active:0, #users:0, #items:0, #heightmap:0]
  else
    if (pSaveData.getAt(#type) = #public) then
      pProcessList = [#passive:0, #Active:0, #users:0, #items:1, #heightmap:0]
    else
      if (pSaveData.getAt(#type) = #game) then
        pProcessList = [#passive:1, #Active:1, #users:1, #items:1, #heightmap:0]
      end if
    end if
  end if
  pCacheKey = "room_data_" & pRoomId & "_" & pSaveData.getAt(#marker)
  if not getObject(#cache).exists(pCacheKey) then
    getObject(#cache).set(pCacheKey, [:])
  end if
  tCache = getObject(#cache).get(pCacheKey)
  if voidp(tCache.getAt(#heightmap)) and not pProcessList.getAt(#heightmap) then
    tCache.setAt(#heightmap, "")
    me.getRoomConnection().send("G_HMAP")
  else
    me.validateHeightMap(tCache.getAt(#heightmap))
  end if
  tShadowManager = me.getShadowManager()
  tShadowManager.define("roomShadow")
  tCache.setAt(#users, [])
  if not pProcessList.getAt(#users) then
    me.getRoomConnection().send("G_USRS")
  end if
  if voidp(tCache.getAt(#passive)) and not pProcessList.getAt(#passive) then
    tCache.setAt(#passive, [])
    me.getRoomConnection().send("G_OBJS")
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
    me.getRoomConnection().send("G_ITEMS")
  else
    if voidp(tCache.getAt(#items)) then
      tCache.setAt(#items, [])
    end if
    me.validateItemObjects(0)
  end if
  createTimeout(pRoomPollerID, 1000, #pollRoomMessages, me.getID(), void(), 0)
  me.executeEnterRoomAlert()
  return TRUE
end

on roomDisconnected me 
  pPrvRoomsReady = 0
  me.leaveRoom()
  return(executeMessage(#leaveRoom))
end

on validateHeightMap me, tdata 
  if not getObject(#cache).exists(pCacheKey) then
    return(error(me, "Data not expected yet!", #validateHeightMap))
  end if
  me.getInterface().getGeometry().loadHeightMap(tdata)
  me.pHeightMapData = tdata
  if not pActiveFlag then
    getObject(#cache).get(pCacheKey).setaProp(#heightmap, tdata)
    me.updateProcess(#heightmap, 1)
  end if
  return FALSE
end

on updateHeightMap me, tdata 
  tHeightMapData = pHeightMapData
  if voidp(tHeightMapData) then
    return(error(me, "Height map update data sent but heightmap data not cached!"))
  else
    a = 1
    i = 1
    repeat while i <= tdata.length
      if (tdata.getProp(#char, i) = "!") then
        i = (i + 1)
        a = (a + charToNum(tdata.getProp(#char, i)))
      else
        -- UNK_21
        ERROR.setContents()
        a = (a + 1)
      end if
      i = (1 + i)
    end repeat
    return(validateHeightMap(me, tHeightMapData))
  end if
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
    me.getShadowManager().disableRender(1)
    repeat while pProcessList <= tValue
      tdata = getAt(tValue, tKey)
      me.createActiveObject(tdata)
    end repeat
    me.getShadowManager().disableRender(0)
    me.getShadowManager().render()
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
    setcursor(#arrow)
    call(#prepare, [me.getRoomPrg()])
    executeMessage(#roomReady)
    me.getRoomConnection().send("G_STAT")
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
  if voidp(tList.getaProp(tid)) then
    return FALSE
  else
    return(tList.getaProp(tid))
  end if
end

on roomObjectExists me, tid, tList 
  return(not voidp(tList.getAt(tid)))
end

on startTeleport me, tTeleId, tFlatID 
  getObject(#session).set("target_door_ID", tTeleId)
  getObject(#session).set("target_flat_ID", tFlatID)
  registerMessage(symbol("receivedFlatStructf_" & tFlatID), me.getID(), #processTeleportStruct)
  executeMessage(#requestFlatStruct, tFlatID)
end

on processTeleportStruct me, tFlatStruct 
  unregisterMessage(symbol("receivedFlatStructf_" & getObject(#session).get("target_flat_ID")))
  tFlatStruct.setAt(#id, tFlatStruct.getAt(#flatId))
  tFlatStruct.addProp(#teleport, getObject(#session).get("target_door_ID"))
  getObject(#session).Remove("target_flat_id")
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

on setEnterRoomAlert me, tMsg 
  pEnterRoomAlert = tMsg
end

on executeEnterRoomAlert me 
  if pEnterRoomAlert.length > 0 then
    executeMessage(#alert, [#Msg:pEnterRoomAlert])
    pEnterRoomAlert = ""
  end if
end

on removeEnterRoomAlert me 
  pEnterRoomAlert = ""
end

on getRoomScale me, tRoomMarker 
  if voidp(tRoomMarker) then
    return FALSE
  end if
  tRoomProps = getVariableValue("private.room.properties")
  if voidp(tRoomProps) then
    return FALSE
  end if
  tRoomKey = chars(tRoomMarker, tRoomMarker.length, tRoomMarker.length)
  repeat while tRoomProps <= undefined
    tRoom = getAt(undefined, tRoomMarker)
    if (tRoom.getAt(#model) = tRoomKey) then
      return(tRoom.getAt(#charScale))
    end if
  end repeat
  return FALSE
end

on addToCastDownloadList me, tCastVarPrefix, tCastList 
  if voidp(tCastList) or not listp(tCastList) then
    tCastList = []
  end if
  i = 1
  repeat while 1
    if variableExists(tCastVarPrefix & i) then
      tCast = getVariable(tCastVarPrefix & i)
      if not castExists(tCast) then
        tCastList.add(tCast)
      end if
    else
    end if
    i = (i + 1)
  end repeat
  return(tCastList)
end
