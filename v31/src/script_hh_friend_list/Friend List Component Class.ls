on construct(me)
  tStamp = ""
  tNo = 1
  repeat while tNo <= 100
    tChar = numToChar(random(48) + 74)
    tStamp = tStamp & tChar
    tNo = 1 + tNo
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  tCharNo = 1
  repeat while tCharNo <= tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tReceipt.setAt(tCharNo, tChar)
    tCharNo = 1 + tCharNo
  end repeat
  if tReceipt <> tFuseReceipt then
    error(me, "Invalid build structure", #checkDataLoaded, #critical)
    return(0)
  end if
  pUpdateIntervalId = getUniqueID()
  pFriendDataContainer = createObject(getUniqueID(), "Friend List Container")
  pFriendRequestContainer = createObject(getUniqueID(), "Friend Request List Container")
  pReadyFlag = 0
  pNewMail = 0
  pHabboSearchResults = [#friends:[], #habbos:[]]
  pHabboSearchLastString = ""
  pSentFriendRequests = []
  registerMessage(#externalFriendRequest, me.getID(), #externalFriendRequest)
  return(1)
  exit
end

on deconstruct(me)
  if timeoutExists(pUpdateIntervalId) then
    removeTimeout(pUpdateIntervalId)
  end if
  unregisterMessage(#externalFriendRequest)
  pFriendDataContainer.deconstruct()
  pFriendRequestContainer.deconstruct()
  return(1)
  exit
end

on setFriendListInited(me)
  tInterval = getVariable("fr.update.interval")
  createTimeout(pUpdateIntervalId, tInterval, #requestFriendListUpdate, me.getID(), void(), 0)
  executeMessage(#friendListReady)
  pReadyFlag = 1
  exit
end

on isFriendListInited(me)
  return(pReadyFlag)
  exit
end

on populateCategoryData(me, tdata)
  pFriendDataContainer.populateCategoryData(tdata)
  me.getInterface().changeCategory(void())
  exit
end

on populateFriendData(me, tdata)
  pFriendDataContainer.populateFriendData(tdata)
  exit
end

on addFriend(me, tFriendData)
  if listp(tFriendData) then
    pSentFriendRequests.deleteOne(tFriendData.getaProp(#name))
  end if
  pFriendDataContainer.addFriend(tFriendData)
  me.getInterface().addFriend(tFriendData)
  exit
end

on updateFriend(me, tFriendData, tHoldRender)
  if ilk(tFriendData) <> #propList then
    return(0)
  end if
  tOldFriendData = pFriendDataContainer.getFriendByID(tFriendData.getAt(#id))
  if ilk(tOldFriendData) <> #propList then
    tOldFriendData = []
  end if
  pSentFriendRequests.deleteOne(tFriendData.getaProp(#name))
  if tOldFriendData.getAt(#categoryId) <> tFriendData.getAt(#categoryId) then
    me.getInterface().removeFriend(tOldFriendData.getAt(#id), tOldFriendData.getAt(#categoryId))
    pFriendDataContainer.updateFriend(tFriendData)
    tFriendData = pFriendDataContainer.getFriendByID(tFriendData.getAt(#id))
    if tFriendData = 0 then
      return(0)
    end if
    me.getInterface().addFriend(tFriendData, tHoldRender)
  else
    pFriendDataContainer.updateFriend(tFriendData)
    tFriendData = pFriendDataContainer.getFriendByID(tFriendData.getAt(#id))
    if tFriendData = 0 then
      return(0)
    end if
    me.getInterface().updateFriend(tFriendData, tHoldRender)
  end if
  executeMessage(#friendDataUpdated, tFriendData.getAt(#id))
  exit
end

on removeFriend(me, tFriendID)
  tFriendData = me.getFriendByID(tFriendID)
  if tFriendData = 0 then
    return(0)
  end if
  tCategoryID = tFriendData.getAt(#categoryId)
  pFriendDataContainer.removeFriend(tFriendID)
  me.getInterface().removeFriend(tFriendID, tCategoryID)
  exit
end

on addFriendRequest(me, tRequestData)
  pFriendRequestContainer.addRequest(tRequestData)
  me.getInterface().addFriendRequest(tRequestData)
  exit
end

on setUnreadMailCount(me, tCount)
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
  exit
end

on newMailFrom(me, tUserID)
  pNewMail = 1
  me.updateFriendListIconStatus()
  me.getInterface().activateMailIcon(1)
  tSoundMemName = getVariable("fr.new.mail.sound")
  playSound(tSoundMemName, #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
  me.getInterface().startInboxBlink()
  exit
end

on notifyFriendRequests(me)
  tPendingList = me.getPendingFriendRequests()
  tPendingCount = tPendingList.count
  executeMessage(#updateFriendRequestCount, tPendingCount)
  if tPendingCount > 0 then
    me.getInterface().setCategoryHighlight(-2)
  else
    me.getInterface().removeCategoryHighlight(-2)
  end if
  me.updateFriendListIconStatus()
  exit
end

on updateFriendListIconStatus(me)
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
  exit
end

on setFriendLimits(me, tUserLimit, tNormalLimit, tExtendedLimit)
  pFriendDataContainer.setListLimit(tUserLimit)
  exit
end

on isFriendListFull(me)
  return(pFriendDataContainer.isListFull())
  exit
end

on updateFriendRequest(me, tRequestData, tstate)
  if not ilk(tRequestData) = #propList then
    return(0)
  end if
  if me = #rejected then
    tMsg = [#integer:0, #integer:1, #integer:integer(tRequestData.getAt(#id))]
    tConn = getConnection(getVariable("connection.info.id"))
    tConn.send("FRIENDLIST_DECLINEFRIEND", tMsg)
  else
    if me = #accepted then
      tMsg = [#integer:1, #integer:integer(tRequestData.getAt(#id))]
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("FRIENDLIST_ACCEPTFRIEND", tMsg)
    end if
  end if
  tRequestData.setAt(#state, tstate)
  pFriendRequestContainer.updateRequest(tRequestData)
  me.notifyFriendRequests()
  exit
end

on handleAllRequests(me, tstate)
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  tRequests = me.getPendingFriendRequests()
  if tRequests.count = 0 then
    return(1)
  end if
  tMsgList = []
  tMsgList.addProp(#integer, 0)
  tMsgList.addProp(#integer, tRequests.count)
  repeat while me <= undefined
    tRequest = getAt(undefined, tstate)
    tID = tRequest.getaProp(#id)
    tMsgList.addProp(#integer, integer(tID))
    tRequest.setAt(#state, tstate)
    pFriendRequestContainer.updateRequest(tRequest)
  end repeat
  if tstate = #accepted then
    tMsgList.deleteAt(1)
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_ACCEPTFRIEND", tMsgList)
  else
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_DECLINEFRIEND", tMsgList)
  end if
  me.notifyFriendRequests()
  return(1)
  exit
end

on getPendingFriendRequests(me)
  return(pFriendRequestContainer.getPendingRequests().duplicate())
  exit
end

on sendRemoveFriend(me, tFriendID)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_REMOVEFRIEND", [#integer:1, #integer:integer(tFriendID)])
  end if
  exit
end

on getFriendByID(me, tFriendID)
  tList = pFriendDataContainer.getFriendByID(tFriendID)
  if ilk(tList) = #propList then
    return(tList.duplicate())
  else
    return(0)
  end if
  exit
end

on getFriendByName(me, tName)
  tList = pFriendDataContainer.getFriendByName(tName)
  if ilk(tList) = #propList then
    return(tList.duplicate())
  else
    return(0)
  end if
  exit
end

on getFriendsInCategory(me, tCategoryID)
  tFriends = pFriendDataContainer.getFriendsInCategory(tCategoryID)
  if ilk(tFriends) = #propList then
    return(tFriends.duplicate())
  else
    return(0)
  end if
  exit
end

on getCategoryList(me)
  tList = pFriendDataContainer.getCategoryList()
  if ilk(tList) = #propList then
    return(tList.duplicate())
  else
    return(0)
  end if
  exit
end

on getCategoryName(me, tID)
  return(pFriendDataContainer.getCategoryName(tID))
  exit
end

on getItemCountForcategory(me, tCategoryID)
  if tCategoryID >= -1 then
    tList = pFriendDataContainer.getFriendsInCategory(tCategoryID)
  else
    if tCategoryID = -2 then
      tList = pFriendRequestContainer.getPendingRequests()
    else
      if tCategoryID = -3 then
        return(pHabboSearchResults.getAt(#friends).count + pHabboSearchResults.getAt(#habbos).count)
      end if
    end if
  end if
  if ilk(tList) = #propList then
    tCount = tList.count
  else
    tCount = 0
  end if
  return(tCount)
  exit
end

on requestFriendListUpdate(me)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_UPDATE")
  end if
  exit
end

on externalFriendRequest(me, tTargetUserName)
  if isFriendListFull() then
    executeMessage(#alert, "console_fr_limit_exceeded_error")
    return(0)
  end if
  if tTargetUserName = void() or tTargetUserName = "" then
    return(1)
  end if
  tText = tTargetUserName && getText("console_request_1")
  tText = tText & "\r"
  tText = tText & getText("console_request_2")
  executeMessage(#alert, tText)
  if not pSentFriendRequests.findPos(tTargetUserName) then
    pSentFriendRequests.append(tTargetUserName)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_FRIENDREQUEST", [#string:tTargetUserName])
  end if
  exit
end

on sendAskForFriendRequests(me)
  pFriendRequestList = []
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_GETFRIENDREQUESTS")
  end if
  exit
end

on sendHabboSearch(me, tSearchString)
  if not stringp(tSearchString) then
    return(error(me, "Search string must be stringp()", #sendHabboSearch))
  end if
  if tSearchString = "" then
    return(0)
  end if
  if tSearchString = pHabboSearchLastString then
    return(0)
  end if
  pHabboSearchLastString = tSearchString
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_HABBOSEARCH", [#string:tSearchString])
  end if
  exit
end

on setFriendRequestResult(me, tdata)
  tErrorList = []
  tNamesPerAlert = 10
  tNames = "\r"
  tNameNum = 1
  repeat while tNameNum <= tErrorList.count
    tName = tErrorList.getPropAt(tNameNum)
    pSentFriendRequests.deleteOne(tName)
    tNames = tNames & "\r" & tName
    if me = 1 then
      tReason = getText("console_fr_limit_exceeded_error")
    else
      if me = 2 then
        tReason = getText("console_target_friend_list_full")
      else
        if me = 3 then
          tReason = getText("console_target_does_not_accept")
        else
          if me = 4 then
            tReason = getText("console_friend_request_not_found")
          else
            if me = 42 then
              tReason = getText("console_concurrency_error")
            end if
          end if
        end if
      end if
    end if
    tNames = tNames & " - " & tReason
    if tNameNum mod tNamesPerAlert = 0 then
      tMessage = getText("console_friend_request_error") & tNames
      executeMessage(#alert, [#Msg:tMessage])
      tNames = "\r"
    end if
    tNameNum = 1 + tNameNum
  end repeat
  if tNames.count(#line) > 2 then
    tMessage = getText("console_friend_request_error") & tNames
    executeMessage(#alert, [#Msg:tMessage])
  end if
  exit
end

on setHabboSearchResults(me, tResultsFriends, tResultsHabbos)
  pHabboSearchResults.setAt(#friends, tResultsFriends)
  repeat while me <= tResultsHabbos
    tItem = getAt(tResultsHabbos, tResultsFriends)
    if pSentFriendRequests.findPos(tItem.getaProp(#name)) then
      tItem.setaProp(#fr_pending, 1)
    end if
  end repeat
  pHabboSearchResults.setAt(#habbos, tResultsHabbos)
  me.getInterface().updateCategoryCounts()
  exit
end

on getHabboSearchResults(me)
  return(pHabboSearchResults)
  exit
end

on getHabboSearchLastString(me)
  return(pHabboSearchLastString)
  exit
end