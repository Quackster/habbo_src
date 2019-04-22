property pCatAliases

on construct me 
  pCatAliases = [:]
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on clearCatAliases me 
  pCatAliases = [:]
end

on getSlotCatAlias me, tUniqueCatID 
  tUniqueCatID = string(tUniqueCatID)
  if tUniqueCatID <= 0 then
    return(tUniqueCatID)
  end if
  if pCatAliases.findPos(tUniqueCatID) then
    return(pCatAliases.getAt(tUniqueCatID))
  end if
  tMaxFreeCount = getVariable("fr.window.max.free.categories", 5)
  tSlotNo = 1
  repeat while tSlotNo <= tMaxFreeCount
    tSlotStr = string(tSlotNo)
    tPropID = pCatAliases.getOne(tSlotStr)
    if tPropID = 0 then
      pCatAliases.setAt(tUniqueCatID, tSlotStr)
      return(tSlotStr)
    end if
    tSlotNo = 1 + tSlotNo
  end repeat
  error(me, "Could not map category id to a slot: " & tUniqueCatID, #getSlotCatAlias, #major)
  return(0)
end

on removeUnusedCategories me, tIdsInUse 
  tAliasList = pCatAliases.duplicate()
  tNo = 1
  repeat while tNo <= tAliasList.count
    tID = tAliasList.getPropAt(tNo)
    if not tIdsInUse.getOne(tID) then
      pCatAliases.deleteProp(tID)
    end if
    tNo = 1 + tNo
  end repeat
end

on handleOk me, tMsg 
  tConn = tMsg.connection
  tConn.send("FRIENDLIST_INIT")
end

on handleFriendListInit me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tUserLimit = tConn.GetIntFrom()
  tNormalLimit = tConn.GetIntFrom()
  tExtendedLimit = tConn.GetIntFrom()
  tCategoryCount = tConn.GetIntFrom()
  tCategories = [:]
  tCatNo = 1
  repeat while tCatNo <= tCategoryCount
    tUniqueId = string(tConn.GetIntFrom())
    tName = tConn.GetStrFrom()
    tID = me.getSlotCatAlias(tUniqueId)
    if tID <> 0 then
      tCategories.setAt(tID, tName)
    end if
    tCatNo = 1 + tCatNo
  end repeat
  tFriendCount = tConn.GetIntFrom()
  tFriendList = [:]
  tFriendNo = 1
  repeat while tFriendNo <= tFriendCount
    tFriend = me.parseFriendData(tMsg)
    tFriendList.setAt(string(tFriend.getAt(#id)), tFriend)
    tFriendNo = 1 + tFriendNo
  end repeat
  tFriendRequestLimit = tConn.GetIntFrom()
  tFriendRequestCount = tConn.GetIntFrom()
  tComponent = me.getComponent()
  tComponent.setFriendLimits(tUserLimit, tNormalLimit, tExtendedLimit)
  tComponent.populateCategoryData(tCategories)
  tComponent.populateFriendData(tFriendList)
  tComponent.sendAskForFriendRequests()
  return(tComponent.setFriendListInited())
end

on handleFriendListUpdate me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tCategoryCount = tConn.GetIntFrom()
  if tCategoryCount > 0 then
    tCategoriesTemp = [:]
    tUsedIds = []
    tCatNo = 1
    repeat while tCatNo <= tCategoryCount
      tID = string(tConn.GetIntFrom())
      tName = tConn.GetStrFrom()
      tCategoriesTemp.setAt(tID, tName)
      tUsedIds.add(tID)
      tCatNo = 1 + tCatNo
    end repeat
    me.removeUnusedCategories(tUsedIds)
    tCategories = [:]
    tNo = 1
    repeat while tNo <= tCategoriesTemp.count
      tUniqueId = tCategoriesTemp.getPropAt(tNo)
      tName = tCategoriesTemp.getAt(tNo)
      tSlotID = me.getSlotCatAlias(tUniqueId)
      if tSlotID <> 0 then
        tCategories.setAt(tSlotID, tName)
      end if
      tNo = 1 + tNo
    end repeat
    me.getComponent().populateCategoryData(tCategories)
  end if
  tFriendCount = tConn.GetIntFrom()
  tNo = 1
  repeat while tNo <= tFriendCount
    tUpdateType = tConn.GetIntFrom()
    if tUpdateType = -1 then
      tFriendID = tConn.GetIntFrom()
      me.getComponent().removeFriend(tFriendID, 1)
    else
      if tUpdateType = 0 then
        tFriend = [:]
        tFriend.setAt(#id, tConn.GetIntFrom())
        tFriend.setAt(#name, tConn.GetStrFrom())
        tFriend.setAt(#sex, tConn.GetIntFrom())
        tFriend.setAt(#online, tConn.GetIntFrom())
        tFriend.setAt(#canfollow, tConn.GetIntFrom())
        tFriend.setAt(#figure, tConn.GetStrFrom())
        tFriend.setAt(#categoryId, me.getSlotCatAlias(tConn.GetIntFrom()))
        if tFriend.getAt(#categoryId) < 0 then
          tFriend.setAt(#categoryId, "0")
        end if
        if tFriend.getAt(#online) = 0 then
          tFriend.setAt(#categoryId, "-1")
        end if
        tFriend.setAt(#categoryId, string(tFriend.getAt(#categoryId)))
        tFriend.setAt(#mission, tConn.GetStrFrom())
        tFriend.setAt(#lastAccess, tConn.GetStrFrom())
        me.getComponent().updateFriend(tFriend, 1)
      else
        if tUpdateType = 1 then
          tFriend = me.parseFriendData(tMsg)
          me.getComponent().addFriend(tFriend, 1)
        end if
      end if
    end if
    tNo = 1 + tNo
  end repeat
  if tFriendCount > 0 or tCategoryCount > 0 then
    me.getInterface().updateCategoryCounts()
    me.getInterface().updateOpenCategoryPanel()
    callJavaScriptFunction("friendListUpdate")
  end if
end

on handleError me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tClientMessageId = tConn.GetIntFrom()
  tErrorCode = tConn.GetIntFrom()
  if tErrorCode = 0 then
    return(error(me, "Undefined friend list error!", #handleError, #major))
  else
    if tErrorCode = 2 then
      return(executeMessage(#alert, [#Msg:getText("console_target_friend_list_full")]))
    else
      if tErrorCode = 3 then
        return(executeMessage(#alert, [#Msg:getText("console_target_does_not_accept")]))
      else
        if tErrorCode = 4 then
          return(executeMessage(#alert, [#Msg:getText("console_friend_request_not_found")]))
        else
          if tErrorCode = 37 then
            tReason = tConn.GetIntFrom()
            if tErrorCode = 1 then
            else
              if tErrorCode = 2 then
                executeMessage(#alert, [#Msg:"console_buddylimit_requester", #modal:1])
              else
                if tErrorCode = 42 then
                  executeMessage(#alert, [#Msg:"console_buddylist_concurrency", #modal:1])
                  if connectionExists(getVariable("connection.info.id")) then
                    getConnection(getVariable("connection.info.id")).send("FRIENDLIST_UPDATE")
                  end if
                end if
              end if
            end if
          else
            if tErrorCode = 39 then
            else
              if tErrorCode = 42 then
                return(executeMessage(#alert, [#Msg:getText("console_concurrency_error")]))
              else
                return(error(me, "Friendlist error, failed message:" && tErrorCode && "Triggered by message:" && tClientMessageId, #handleError, #major))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on handleFriendRequestList me, tMsg 
  tConn = tMsg.connection
  tTotalFriendRequests = tConn.GetIntFrom()
  tFriendRequestCount = tConn.GetIntFrom()
  tRequestNo = 1
  repeat while tRequestNo <= tFriendRequestCount
    tRequest = me.parseFriendRequest(tMsg)
    me.getComponent().addFriendRequest(tRequest)
    tRequestNo = 1 + tRequestNo
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
  tItemNo = 1
  repeat while tItemNo <= tFailureCount
    tSenderName = tConn.GetStrFrom()
    tErrorCode = tConn.GetIntFrom()
    tErrorList.setaProp(tSenderName, tErrorCode)
    tItemNo = 1 + tItemNo
  end repeat
  me.getComponent().setFriendRequestResult(tErrorList)
  if tFailureCount < 1 then
    return(1)
  end if
end

on handleFollowFailed me, tMsg 
  tConn = tMsg.connection
  tFailureType = tConn.GetIntFrom()
  if tFailureType = 0 then
    tTextKey = "console_follow_not_friend"
  else
    if tFailureType = 1 then
      tTextKey = "console_follow_offline"
    else
      if tFailureType = 2 then
        tTextKey = "console_follow_hotelview"
      else
        if tFailureType = 3 then
          tTextKey = "console_follow_prevented"
        else
          return(0)
        end if
      end if
    end if
  end if
  if threadExists(#room) then
    tRoomID = getThread(#room).getComponent().getRoomID()
    if tRoomID = "" then
      executeMessage(#show_navigator)
    end if
  end if
  executeMessage(#alert, [#Msg:tTextKey, #id:#follow_failure_notice])
  return(1)
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

on handleHabboSearchResult me, tMsg 
  tConn = tMsg.connection
  tResultFriendsCount = tConn.GetIntFrom()
  tResultsFriends = []
  tRequestNo = 1
  repeat while tRequestNo <= tResultFriendsCount
    tResultsFriends.append(me.parseHabboSearchResult(tMsg))
    tRequestNo = 1 + tRequestNo
  end repeat
  tResultHabbosCount = tConn.GetIntFrom()
  tResultsHabbos = []
  tRequestNo = 1
  repeat while tRequestNo <= tResultHabbosCount
    tResultsHabbos.append(me.parseHabboSearchResult(tMsg))
    tRequestNo = 1 + tRequestNo
  end repeat
  me.getComponent().setHabboSearchResults(tResultsFriends, tResultsHabbos)
  me.getInterface().showHabboSearchResults()
end

on parseFriendRequest me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#name, tConn.GetStrFrom())
  tdata.setAt(#userID, tConn.GetStrFrom())
  tdata.setAt(#state, #pending)
  return(tdata)
end

on parseFriendData me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tFriend = [:]
  tFriend.setAt(#id, tConn.GetIntFrom())
  tFriend.setAt(#name, tConn.GetStrFrom())
  tFriend.setAt(#sex, tConn.GetIntFrom())
  tFriend.setAt(#online, tConn.GetIntFrom())
  tFriend.setAt(#canfollow, tConn.GetIntFrom())
  tFriend.setAt(#figure, tConn.GetStrFrom())
  tFriend.setAt(#categoryId, me.getSlotCatAlias(tConn.GetIntFrom()))
  if tFriend.getAt(#categoryId) < 0 then
    tFriend.setAt(#categoryId, "0")
  end if
  if tFriend.getAt(#online) = 0 then
    tFriend.setAt(#categoryId, "-1")
  end if
  tFriend.setAt(#categoryId, string(tFriend.getAt(#categoryId)))
  tFriend.setAt(#mission, tConn.GetStrFrom())
  tFriend.setAt(#lastAccess, tConn.GetStrFrom())
  return(tFriend)
end

on parseHabboSearchResult me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [:]
  tdata.setAt(#id, tConn.GetIntFrom())
  tdata.setAt(#name, tConn.GetStrFrom())
  tdata.setAt(#mission, tConn.GetStrFrom())
  tdata.setAt(#online, tConn.GetIntFrom())
  tdata.setAt(#canfollow, tConn.GetIntFrom())
  tdata.setAt(#roomname, tConn.GetStrFrom())
  tdata.setAt(#sex, tConn.GetIntFrom())
  tdata.setAt(#figure, tConn.GetStrFrom())
  tdata.setAt(#lastAccess, tConn.GetStrFrom())
  return(tdata)
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
  tMsgs.setaProp(363, #handleMailNotification)
  tMsgs.setaProp(364, #handleMailCountNotification)
  tMsgs.setaProp(435, #handleHabboSearchResult)
  tCmds = [:]
  tCmds.setaProp("FRIENDLIST_INIT", 12)
  tCmds.setaProp("FRIENDLIST_UPDATE", 15)
  tCmds.setaProp("FRIENDLIST_GETOFFLINEFRIENDS", 32)
  tCmds.setaProp("FRIENDLIST_REMOVEFRIEND", 40)
  tCmds.setaProp("MESSENGER_HABBOSEARCH", 41)
  tCmds.setaProp("FRIENDLIST_ACCEPTFRIEND", 37)
  tCmds.setaProp("FRIENDLIST_DECLINEFRIEND", 38)
  tCmds.setaProp("FRIENDLIST_FRIENDREQUEST", 39)
  tCmds.setaProp("FRIENDLIST_GETFRIENDREQUESTS", 233)
  tCmds.setaProp("FOLLOW_FRIEND", 262)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
end
