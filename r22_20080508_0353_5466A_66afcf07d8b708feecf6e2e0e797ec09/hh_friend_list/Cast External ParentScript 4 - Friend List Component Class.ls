property pFriendDataContainer, pFriendRequestContainer, pUpdateIntervalId, pReadyFlag, pNewMail

on construct me
  tStamp = EMPTY
  repeat with tNo = 1 to 100
    tChar = numToChar(random(48) + 74)
    tStamp = tStamp & tChar
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  repeat with tCharNo = 1 to tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = (tChar * tCharNo) + 309203
    tReceipt[tCharNo] = tChar
  end repeat
  if tReceipt <> tFuseReceipt then
    error(me, "Invalid build structure", #checkDataLoaded, #critical)
    return 0
  end if
  pUpdateIntervalId = getUniqueID()
  pFriendDataContainer = createObject(getUniqueID(), "Friend List Container")
  pFriendRequestContainer = createObject(getUniqueID(), "Friend Request List Container")
  pReadyFlag = 0
  pNewMail = 0
  registerMessage(#externalFriendRequest, me.getID(), #externalFriendRequest)
  return 1
end

on deconstruct me
  if timeoutExists(pUpdateIntervalId) then
    removeTimeout(pUpdateIntervalId)
  end if
  unregisterMessage(#externalFriendRequest)
  pFriendDataContainer.deconstruct()
  pFriendRequestContainer.deconstruct()
  return 1
end

on setFriendListInited me
  tInterval = getVariable("fr.update.interval")
  createTimeout(pUpdateIntervalId, tInterval, #requestFriendListUpdate, me.getID(), VOID, 0)
  executeMessage(#friendListReady)
  pReadyFlag = 1
end

on isFriendListInited me
  return pReadyFlag
end

on populateCategoryData me, tdata
  pFriendDataContainer.populateCategoryData(tdata)
  me.getInterface().changeCategory(VOID)
end

on populateFriendData me, tdata
  pFriendDataContainer.populateFriendData(tdata)
end

on addFriend me, tFriendData
  pFriendDataContainer.addFriend(tFriendData)
  me.getInterface().addFriend(tFriendData)
end

on updateFriend me, tFriendData
  if ilk(tFriendData) <> #propList then
    return 0
  end if
  tOldFriendData = pFriendDataContainer.getFriendByID(tFriendData[#id])
  if ilk(tOldFriendData) <> #propList then
    tOldFriendData = [:]
  end if
  if tOldFriendData[#categoryId] <> tFriendData[#categoryId] then
    me.getInterface().removeFriend(tOldFriendData[#id], tOldFriendData[#categoryId])
    pFriendDataContainer.updateFriend(tFriendData)
    tFriendData = pFriendDataContainer.getFriendByID(tFriendData[#id])
    me.getInterface().addFriend(tFriendData)
  else
    pFriendDataContainer.updateFriend(tFriendData)
    tFriendData = pFriendDataContainer.getFriendByID(tFriendData[#id])
    me.getInterface().updateFriend(tFriendData)
  end if
  executeMessage(#friendDataUpdated, tFriendData[#id])
end

on removeFriend me, tFriendID
  tFriendData = me.getFriendByID(tFriendID)
  if tFriendData = 0 then
    return 0
  end if
  tCategoryId = tFriendData[#categoryId]
  pFriendDataContainer.removeFriend(tFriendID)
  me.getInterface().removeFriend(tFriendID, tCategoryId)
end

on addFriendRequest me, tRequestData
  pFriendRequestContainer.addRequest(tRequestData)
  me.getInterface().addFriendRequest(tRequestData)
end

on setUnreadMailCount me, tCount
  if tCount > 0 then
    pNewMail = 1
    me.getInterface().activateMailIcon(1)
    me.getInterface().startInboxBlink()
  else
    pNewMail = 0
    me.getInterface().activateMailIcon(0)
    me.getInterface().endInboxBlink()
  end if
  me.updateFriendListIconStatus()
end

on newMailFrom me, tUserID
  pNewMail = 1
  me.updateFriendListIconStatus()
  me.getInterface().activateMailIcon(1)
  tSoundMemName = getVariable("fr.new.mail.sound")
  playSound(tSoundMemName, #cut, [#loopCount: 1, #infiniteloop: 0, #volume: 255])
  me.getInterface().startInboxBlink()
end

on notifyFriendRequests me
  tPendingList = me.getPendingFriendRequests()
  tPendingCount = tPendingList.count
  executeMessage(#updateFriendRequestCount, tPendingCount)
  if tPendingCount > 0 then
    me.getInterface().setCategoryHighlight(-2)
  else
    me.getInterface().removeCategoryHighlight(-2)
  end if
  me.updateFriendListIconStatus()
end

on updateFriendListIconStatus me
  tActive = 0
  tFrList = me.getPendingFriendRequests()
  if ilk(tFrList) = #propList then
    tFrCount = tFrList.count
    if tFrCount > 0 then
      tActive = 1
    end if
  end if
  if pNewMail = 1 then
    tActive = 1
  end if
  executeMessage(#updateFriendListIcon, tActive)
end

on setFriendLimits me, tUserLimit, tNormalLimit, tExtendedLimit
  pFriendDataContainer.setListLimit(tUserLimit)
end

on isFriendListFull me
  return pFriendDataContainer.isListFull()
end

on updateFriendRequest me, tRequestData, tstate
  if not (ilk(tRequestData) = #propList) then
    return 0
  end if
  case tstate of
    #rejected:
      tMsg = [#integer: 1, #integer: integer(tRequestData[#id])]
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("FRIENDLIST_DECLINEFRIEND", tMsg)
    #accepted:
      tMsg = [#integer: 1, #integer: integer(tRequestData[#id])]
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("FRIENDLIST_ACCEPTFRIEND", tMsg)
  end case
  tRequestData[#state] = tstate
  pFriendRequestContainer.updateRequest(tRequestData)
  me.notifyFriendRequests()
end

on handleAllRequests me, tstate
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  tMsgList = [#integer: 0]
  tRequests = me.getPendingFriendRequests()
  if tRequests.count = 0 then
    return 1
  end if
  repeat with tRequest in tRequests
    tID = tRequest.getaProp(#id)
    tMsgList.addProp(#integer, integer(tID))
    tRequest[#state] = tstate
    pFriendRequestContainer.updateRequest(tRequest)
  end repeat
  tMsgList[1] = tMsgList.count - 1
  if tstate = #accepted then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_ACCEPTFRIEND", tMsgList)
  else
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_DECLINEFRIEND", tMsgList)
  end if
  me.notifyFriendRequests()
  return 1
end

on getPendingFriendRequests me
  return pFriendRequestContainer.getPendingRequests().duplicate()
end

on sendRemoveFriend me, tFriendID
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_REMOVEFRIEND", [#integer: 1, #integer: integer(tFriendID)])
  end if
end

on getFriendByID me, tFriendID
  tList = pFriendDataContainer.getFriendByID(tFriendID)
  if ilk(tList) = #propList then
    return tList.duplicate()
  else
    return 0
  end if
end

on getFriendByName me, tName
  tList = pFriendDataContainer.getFriendByName(tName)
  if ilk(tList) = #propList then
    return tList.duplicate()
  else
    return 0
  end if
end

on getFriendsInCategory me, tCategoryId
  tFriends = pFriendDataContainer.getFriendsInCategory(tCategoryId)
  if ilk(tFriends) = #propList then
    return tFriends.duplicate()
  else
    return 0
  end if
end

on getCategoryList me
  tList = pFriendDataContainer.getCategoryList()
  if ilk(tList) = #propList then
    return tList.duplicate()
  else
    return 0
  end if
end

on getCategoryName me, tID
  return pFriendDataContainer.getCategoryName(tID)
end

on getItemCountForcategory me, tCategoryId
  if tCategoryId >= -1 then
    tList = pFriendDataContainer.getFriendsInCategory(tCategoryId)
  else
    if tCategoryId = -2 then
      tList = pFriendRequestContainer.getPendingRequests()
    end if
  end if
  if ilk(tList) = #propList then
    tCount = tList.count
  else
    tCount = 0
  end if
  return tCount
end

on requestFriendListUpdate me
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_UPDATE")
  end if
end

on externalFriendRequest me, tTargetUserName
  if (tTargetUserName = VOID) or (tTargetUserName = EMPTY) then
    return 1
  end if
  tText = tTargetUserName && getText("console_request_1")
  tText = tText & RETURN
  tText = tText & getText("console_request_2")
  executeMessage(#alert, tText)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_FRIENDREQUEST", [#string: tTargetUserName])
  end if
end

on sendAskForFriendRequests me
  pFriendRequestList = []
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_GETFRIENDREQUESTS")
  end if
end

on setFriendRequestResult me, tdata
  tErrorList = [:]
  tNamesPerAlert = 10
  tNames = RETURN
  repeat with tNameNum = 1 to tErrorList.count
    tNames = tNames & RETURN & tErrorList.getPropAt(tNameNum)
    case tErrorList[tNameNum] of
      1:
        tReason = getText("console_fr_limit_exceeded_error")
      2:
        tReason = getText("console_target_friend_list_full")
      3:
        tReason = getText("console_target_does_not_accept")
      4:
        tReason = getText("console_friend_request_not_found")
      42:
        tReason = getText("console_concurrency_error")
    end case
    tNames = tNames & " - " & tReason
    if (tNameNum mod tNamesPerAlert) = 0 then
      tMessage = getText("console_friend_request_error") & tNames
      executeMessage(#alert, [#Msg: tMessage])
      tNames = RETURN
    end if
  end repeat
  if tNames.line.count > 2 then
    tMessage = getText("console_friend_request_error") & tNames
    executeMessage(#alert, [#Msg: tMessage])
  end if
end
