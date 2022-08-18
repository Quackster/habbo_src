property pCatAliases

on construct me
  pCatAliases = [:]
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on clearCatAliases me
  pCatAliases = [:]
end

on getSlotCatAlias me, tUniqueCatID
  tUniqueCatID = string(tUniqueCatID)
  if (tUniqueCatID <= 0) then
    return tUniqueCatID
  end if
  if pCatAliases.findPos(tUniqueCatID) then
    return pCatAliases[tUniqueCatID]
  end if
  tMaxFreeCount = getVariable("fr.window.max.free.categories", 5)
  repeat with tSlotNo = 1 to tMaxFreeCount
    tSlotStr = string(tSlotNo)
    tPropID = pCatAliases.getOne(tSlotStr)
    if (tPropID = 0) then
      pCatAliases[tUniqueCatID] = tSlotStr
      return tSlotStr
    end if
  end repeat
  error(me, ("Could not map category id to a slot: " & tUniqueCatID), #getSlotCatAlias, #major)
  return 0
end

on removeUnusedCategories me, tIdsInUse
  tAliasList = pCatAliases.duplicate()
  repeat with tNo = 1 to tAliasList.count
    tID = tAliasList.getPropAt(tNo)
    if not tIdsInUse.getOne(tID) then
      pCatAliases.deleteProp(tID)
    end if
  end repeat
end

on handleOk me, tMsg
  tConn = tMsg.connection
  tConn.send("FRIENDLIST_INIT")
end

on handleFriendListInit me, tMsg
  tConn = tMsg.connection
  if (tConn = 0) then
    return 0
  end if
  tUserLimit = tConn.GetIntFrom()
  tNormalLimit = tConn.GetIntFrom()
  tExtendedLimit = tConn.GetIntFrom()
  tCategoryCount = tConn.GetIntFrom()
  tCategories = [:]
  repeat with tCatNo = 1 to tCategoryCount
    tUniqueId = string(tConn.GetIntFrom())
    tName = tConn.GetStrFrom()
    tID = me.getSlotCatAlias(tUniqueId)
    if (tID <> 0) then
      tCategories[tID] = tName
    end if
  end repeat
  tFriendCount = tConn.GetIntFrom()
  tFriendList = [:]
  repeat with tFriendNo = 1 to tFriendCount
    tFriend = me.parseFriendData(tMsg)
    tFriendList[string(tFriend[#id])] = tFriend
  end repeat
  tFriendRequestLimit = tConn.GetIntFrom()
  tFriendRequestCount = tConn.GetIntFrom()
  tComponent = me.getComponent()
  tComponent.setFriendLimits(tUserLimit, tNormalLimit, tExtendedLimit)
  tComponent.populateCategoryData(tCategories)
  tComponent.populateFriendData(tFriendList)
  tComponent.sendAskForFriendRequests()
  return tComponent.setFriendListInited()
end

on handleFriendListUpdate me, tMsg
  tConn = tMsg.connection
  if (tConn = 0) then
    return 0
  end if
  tCategoryCount = tConn.GetIntFrom()
  if (tCategoryCount > 0) then
    tCategoriesTemp = [:]
    tUsedIds = []
    repeat with tCatNo = 1 to tCategoryCount
      tID = string(tConn.GetIntFrom())
      tName = tConn.GetStrFrom()
      tCategoriesTemp[tID] = tName
      tUsedIds.add(tID)
    end repeat
    me.removeUnusedCategories(tUsedIds)
    tCategories = [:]
    repeat with tNo = 1 to tCategoriesTemp.count
      tUniqueId = tCategoriesTemp.getPropAt(tNo)
      tName = tCategoriesTemp[tNo]
      tSlotID = me.getSlotCatAlias(tUniqueId)
      if (tSlotID <> 0) then
        tCategories[tSlotID] = tName
      end if
    end repeat
    me.getComponent().populateCategoryData(tCategories)
  end if
  tFriendCount = tConn.GetIntFrom()
  repeat with tNo = 1 to tFriendCount
    tUpdateType = tConn.GetIntFrom()
    case tUpdateType of
      -1:
        tFriendID = tConn.GetIntFrom()
        me.getComponent().removeFriend(tFriendID)
      0:
        tFriend = [:]
        tFriend[#id] = tConn.GetIntFrom()
        tFriend[#gender] = tConn.GetIntFrom()
        tFriend[#online] = tConn.GetIntFrom()
        tFriend[#canfollow] = tConn.GetIntFrom()
        tFriend[#figure] = tConn.GetStrFrom()
        tFriend[#categoryId] = me.getSlotCatAlias(tConn.GetIntFrom())
        if (tFriend[#categoryId] < 0) then
          tFriend[#categoryId] = "0"
        end if
        if (tFriend[#online] = 0) then
          tFriend[#categoryId] = "-1"
        end if
        tFriend[#categoryId] = string(tFriend[#categoryId])
        me.getComponent().updateFriend(tFriend)
      1:
        tFriend = me.parseFriendData(tMsg)
        me.getComponent().addFriend(tFriend)
    end case
  end repeat
  if ((tFriendCount > 0) or (tCategoryCount > 0)) then
    me.getInterface().updateCategoryCounts()
  end if
end

on handleError me, tMsg
  tConn = tMsg.connection
  if (tConn = 0) then
    return 0
  end if
  tClientMessageId = tConn.GetIntFrom()
  tErrorCode = tConn.GetIntFrom()
  case tErrorCode of
    0:
      return error(me, "Undefined friend list error!", #handleError, #major)
    2:
      return executeMessage(#alert, [#Msg: getText("console_target_friend_list_full")])
    3:
      return executeMessage(#alert, [#Msg: getText("console_target_does_not_accept")])
    4:
      return executeMessage(#alert, [#Msg: getText("console_friend_request_not_found")])
    37:
      tReason = tConn.GetIntFrom()
      case tReason of
        1:
        2:
          executeMessage(#alert, [#Msg: "console_buddylimit_requester", #modal: 1])
        42:
          executeMessage(#alert, [#Msg: "console_buddylist_concurrency", #modal: 1])
          if connectionExists(getVariable("connection.info.id")) then
            getConnection(getVariable("connection.info.id")).send("FRIENDLIST_UPDATE")
          end if
      end case
    39:
    42:
      return executeMessage(#alert, [#Msg: getText("console_concurrency_error")])
  end case
  return error(me, ((("Friendlist error, failed message:" && tErrorCode) && "Triggered by message:") && tClientMessageId), #handleError, #major)
  return 1
end

on handleFriendRequestList me, tMsg
  tConn = tMsg.connection
  tTotalFriendRequests = tConn.GetIntFrom()
  tFriendRequestCount = tConn.GetIntFrom()
  repeat with tRequestNo = 1 to tFriendRequestCount
    tRequest = me.parseFriendRequest(tMsg)
    me.getComponent().addFriendRequest(tRequest)
  end repeat
  me.getInterface().updateCategoryCounts()
  me.getComponent().notifyFriendRequests()
end

on handleFriendRequest me, tMsg
  tRequest = me.parseFriendRequest(tMsg)
  me.getComponent().addFriendRequest(tRequest)
  me.getInterface().updateCategoryCounts()
  me.getComponent().notifyFriendRequests()
end

on handleFriendRequestResult me, tMsg
  tConn = tMsg.connection
  tFailureCount = tConn.GetIntFrom()
  tErrorList = [:]
  repeat with tItemNo = 1 to tFailureCount
    tSenderName = tConn.GetStrFrom()
    tErrorCode = tConn.GetIntFrom()
    tErrorList.setaProp(tSenderName, tErrorCode)
  end repeat
  me.getComponent().setFriendRequestResult(tErrorList)
  if (tFailureCount < 1) then
    return 1
  end if
end

on handleFollowFailed me, tMsg
  tConn = tMsg.connection
  tFailureType = tConn.GetIntFrom()
  case tFailureType of
    0:
      tTextKey = "console_follow_not_friend"
    1:
      tTextKey = "console_follow_offline"
    2:
      tTextKey = "console_follow_hotelview"
    3:
      tTextKey = "console_follow_prevented"
  end case
  return 0
  if threadExists(#room) then
    tRoomID = getThread(#room).getComponent().getRoomID()
    if (tRoomID = EMPTY) then
      executeMessage(#show_navigator)
    end if
  end if
  executeMessage(#alert, [#Msg: tTextKey, #id: #follow_failure_notice])
  return 1
end

on handleInvitation me, tMsg
  tConn = tMsg.connection
  if (tConn = 0) then
    return 0
  end if
  tInvitationData = [:]
  tInvitationData.setaProp(#userID, tConn.GetStrFrom())
  tInvitationData.setaProp(#name, tConn.GetStrFrom())
  executeMessage(#showInvitation, tInvitationData)
  return 1
end

on handleInvitationFollowFailed me, tMsg
  executeMessage(#alert, "invitation_follow_failed")
end

on handleInvitationExpired me, tMsg
  executeMessage(#hideInvitation)
end

on handleMailNotification me, tMsg
  tConn = tMsg.connection
  tUserID = tConn.GetStrFrom()
  me.getComponent().newMailFrom(tUserID)
end

on handleMailCountNotification me, tMsg
  tConn = tMsg.connection
  tUnreadMailCount = tConn.GetIntFrom()
  me.getComponent().setUnreadMailCount(tUnreadMailCount)
end

on parseFriendRequest me, tMsg
  tConn = tMsg.connection
  if (tConn = 0) then
    return 0
  end if
  tdata = [:]
  tdata[#id] = string(tConn.GetIntFrom())
  tdata[#name] = tConn.GetStrFrom()
  tdata[#userID] = tConn.GetStrFrom()
  tdata[#state] = #pending
  return tdata
end

on parseFriendData me, tMsg
  tConn = tMsg.connection
  if (tConn = 0) then
    return 0
  end if
  tFriend = [:]
  tFriend[#id] = tConn.GetIntFrom()
  tFriend[#name] = tConn.GetStrFrom()
  tFriend[#gender] = tConn.GetIntFrom()
  tFriend[#online] = tConn.GetIntFrom()
  tFriend[#canfollow] = tConn.GetIntFrom()
  tFriend[#figure] = tConn.GetStrFrom()
  tFriend[#categoryId] = me.getSlotCatAlias(tConn.GetIntFrom())
  if (tFriend[#categoryId] < 0) then
    tFriend[#categoryId] = "0"
  end if
  if (tFriend[#online] = 0) then
    tFriend[#categoryId] = "-1"
  end if
  tFriend[#categoryId] = string(tFriend[#categoryId])
  return tFriend
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(3, #handleOk)
  tMsgs.setaProp(12, #handleFriendListInit)
  tMsgs.setaProp(13, #handleFriendListUpdate)
  tMsgs.setaProp(132, #handleFriendRequest)
  tMsgs.setaProp(260, #handleError)
  tMsgs.setaProp(314, #handleFriendRequestList)
  tMsgs.setaProp(315, #handleFriendRequestResult)
  tMsgs.setaProp(349, #handleFollowFailed)
  tMsgs.setaProp(355, #handleInvitation)
  tMsgs.setaProp(359, #handleInvitationFollowFailed)
  tMsgs.setaProp(360, #handleInvitationExpired)
  tMsgs.setaProp(363, #handleMailNotification)
  tMsgs.setaProp(364, #handleMailCountNotification)
  tCmds = [:]
  tCmds.setaProp("FRIENDLIST_INIT", 12)
  tCmds.setaProp("FRIENDLIST_UPDATE", 15)
  tCmds.setaProp("FRIENDLIST_REMOVEFRIEND", 40)
  tCmds.setaProp("FRIENDLIST_ACCEPTFRIEND", 37)
  tCmds.setaProp("FRIENDLIST_DECLINEFRIEND", 38)
  tCmds.setaProp("FRIENDLIST_FRIENDREQUEST", 39)
  tCmds.setaProp("FRIENDLIST_GETFRIENDREQUESTS", 233)
  tCmds.setaProp("FOLLOW_FRIEND", 262)
  tCmds.setaProp("MSG_ACCEPT_TUTOR_INVITATION", 357)
  tCmds.setaProp("MSG_REJECT_TUTOR_INVITATION", 358)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
