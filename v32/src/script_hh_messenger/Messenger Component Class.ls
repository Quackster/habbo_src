property pState, pPaused, pTimeOutID, pReadyFlag, pBuddyList, pItemList, pUpdateBuddiesInterval, pLastBuddiesUpdateTime, pFriendRequestList, pFriendRequestUpdateRequired, pMessageUpdateRequired

on construct me
  registerMessage(#enterRoom, me.getID(), #hideMessenger)
  registerMessage(#leaveRoom, me.getID(), #hideMessenger)
  registerMessage(#changeRoom, me.getID(), #hideMessenger)
  registerMessage(#show_messenger, me.getID(), #showMessenger)
  registerMessage(#hide_messenger, me.getID(), #hideMessenger)
  registerMessage(#show_hide_messenger, me.getID(), #showhidemessenger)
  registerMessage(#messageUpdateRequest, me.getID(), #tellMessageCount)
  registerMessage(#buddyUpdateRequest, me.getID(), #tellRequestCount)
  registerMessage(#pause_messeger_update, me.getID(), #pause)
  registerMessage(#resume_messeger_update, me.getID(), #resume)
  registerMessage(#updateClubStatus, me.getID(), #updateClubStatus)
  pState = VOID
  pPaused = 0
  pTimeOutID = #messenger_msg_poller
  pReadyFlag = 0
  pBuddyList = getStructVariable("struct.pointer")
  pItemList = [#messages: [:], #msgCount: [:], #newBuddyRequest: [], #pendingBuddyAccept: EMPTY, #persistenMsg: EMPTY]
  pUpdateBuddiesInterval = getIntVariable("messenger.updatetime.buddylist", 120000)
  pLastBuddiesUpdateTime = 0
  pFriendRequestList = []
  pFriendRequestUpdateRequired = 0
  pMessageUpdateRequired = 0
  pInvitationData = [:]
  pBuddyList.setProp(#value, [#buddies: [:], #online: [], #offline: [], #render: []])
  me.getInterface().createBuddyList(pBuddyList)
  executeMessage(#messenger_ready, #messenger)
  return 1
end

on deconstruct me
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#show_messenger, me.getID())
  unregisterMessage(#hide_messenger, me.getID())
  unregisterMessage(#show_hide_messenger, me.getID())
  unregisterMessage(#messageUpdateRequest, me.getID())
  unregisterMessage(#buddyUpdateRequest, me.getID())
  unregisterMessage(#externalBuddyRequest, me.getID())
  unregisterMessage(#pause_messeger_update, me.getID())
  unregisterMessage(#resume_messeger_update, me.getID())
  pReadyFlag = 0
  pBuddyList = [:]
  pItemList = [:]
  executeMessage(#messenger_dead, #messenger)
  return 1
end

on showMessenger me
  if not pReadyFlag then
    return error(me, "Messenger not ready yet..", #showMessenger, #minor)
  end if
  return me.getInterface().showMessenger()
end

on hideMessenger me
  if not pReadyFlag then
    return error(me, "Messenger not ready yet..", #hideMessenger, #minor)
  end if
  return me.getInterface().hideMessenger()
end

on showhidemessenger me
  if not pReadyFlag then
    return error(me, "Messenger not ready yet..", #showhidemessenger, #minor)
  end if
  return me.getInterface().showhidemessenger()
end

on deleteAllMessages me
  pItemList.messages = [:]
  pItemList.msgCount = [:]
  me.tellMessageCount()
  return 1
end

on getNextPendingInstantBuddyRequest me
  if threadExists(#room) then
    tRoomComp = getThread(#room).getComponent()
    if (tRoomComp.getRoomID() = EMPTY) then
      return 0
    end if
  end if
  if (pFriendRequestList.count < 1) then
    return 0
  else
    repeat with tItemNo = 1 to pFriendRequestList.count
      tItem = pFriendRequestList[tItemNo]
      if (tItem[#state] = #pending) then
        tUserIndex = tRoomComp.getUsersRoomId(tItem[#name])
        if (tUserIndex <> -1) then
          return tItem.duplicate()
        end if
      end if
    end repeat
  end if
  return 0
end

on getRequestSet me, tSetIndex, tRequestsInSet
  tStartIndex = (((tSetIndex - 1) * tRequestsInSet) + 1)
  tEndIndex = ((tStartIndex + tRequestsInSet) - 1)
  if (tEndIndex > pFriendRequestList.count) then
    tEndIndex = pFriendRequestList.count
  end if
  tSet = []
  repeat with tIndex = tStartIndex to tEndIndex
    tSet.add(pFriendRequestList[tIndex])
  end repeat
  return tSet
end

on getRequestsByState me, tstate
  tRequests = []
  repeat with tRequest in pFriendRequestList
    if (tRequest.getaProp(#state) = tstate) then
      tRequests.add(tRequest)
    end if
  end repeat
  return tRequests
end

on clearRequests me
  repeat with tRequestNo = pFriendRequestList.count down to 1
    tRequest = pFriendRequestList[tRequestNo]
    tstate = tRequest.getaProp(#state)
    if (((tstate = #accepted) or (tstate = #declined)) or (tstate = #failed)) then
      pFriendRequestList.deleteAt(tRequestNo)
    end if
  end repeat
  me.tellRequestCount()
  return 1
end

on getRequestCount me
  return pFriendRequestList.count
end

on getPendingRequestCount me
  tCount = 0
  repeat with tRequest in pFriendRequestList
    tstate = tRequest.getaProp(#state)
    if (tstate = #pending) then
      tCount = (tCount + 1)
    end if
  end repeat
  return tCount
end

on getFriendRequests me
  return pFriendRequestList
end

on getFriendRequestUpdateRequired me
  return pFriendRequestUpdateRequired
end

on setFriendRequestUpdateRequired me, tValue
  pFriendRequestUpdateRequired = tValue
end

on setMessageUpdateRequired me, tValue
  pMessageUpdateRequired = tValue
end

on getMessageUpdateRequired me
  return pMessageUpdateRequired
end

on receive_MessengerReady me, tMsg
  pReadyFlag = 1
  createTimeout(pTimeOutID, pUpdateBuddiesInterval, #send_BuddylistUpdate, me.getID(), VOID, 0)
  return executeMessage(#messenger_ready)
end

on receive_BuddyList me, ttype, tList
  me.getInterface().setMessengerActive()
  case ttype of
    #new:
      pBuddyList.setaProp(#value, tList)
      me.getInterface().createBuddyList(pBuddyList)
    #update:
      if (tList.buddies = VOID) then
        return 0
      end if
      if (tList.buddies.count = 0) then
        return 0
      end if
      tTheBuddyList = pBuddyList.getaProp(#value)
      repeat with i = 1 to tList.buddies.count
        tBuddy = tList.buddies[i]
        tCurrData = tTheBuddyList.buddies.getaProp(tBuddy.id)
        if voidp(tCurrData) then
          error(me, (("Buddy not found:" & tBuddy[#id]) & " - Rejecting update."), #receive_BuddyList, #minor)
          next repeat
        end if
        repeat with j = 1 to tBuddy.count
          tKey = tBuddy.getPropAt(j)
          tValue = tBuddy[j]
          tCurrData[tKey] = tValue
        end repeat
        tMsgList = pItemList.messages.getaProp(tBuddy[#id])
        if listp(tMsgList) then
          tCurrData[#msgs] = tMsgList.count
        end if
        if tBuddy.online then
          if tTheBuddyList.offline.getOne(tCurrData[#name]) then
            tTheBuddyList.offline.deleteOne(tCurrData[#name])
          end if
          if (tTheBuddyList.online.getOne(tCurrData[#name]) = 0) then
            tTheBuddyList.online.add(tCurrData[#name])
          end if
          next repeat
        end if
        if tTheBuddyList.online.getOne(tCurrData[#name]) then
          tTheBuddyList.online.deleteOne(tCurrData[#name])
        end if
        if (tTheBuddyList.offline.getOne(tCurrData[#name]) = 0) then
          tTheBuddyList.offline.add(tCurrData[#name])
        end if
      end repeat
      tTheBuddyList.render = []
      repeat with tName in tTheBuddyList.online
        tTheBuddyList.render.add(tName)
      end repeat
      repeat with tName in tTheBuddyList.offline
        tTheBuddyList.render.add(tName)
      end repeat
      me.getInterface().updateBuddyList()
  end case
end

on receive_AppendBuddy me, tdata
  if not listp(tdata) then
    return 0
  end if
  if (tdata.count < 1) then
    return 0
  end if
  tdata = tdata.buddies
  tTheBuddyList = pBuddyList.getaProp(#value)
  tTheBuddyList.buddies.setaProp(tdata[#id], tdata)
  if tdata.online then
    if (tTheBuddyList.online.getOne(tdata.name) = 0) then
      tTheBuddyList.online.add(tdata.name)
    end if
  else
    if (tTheBuddyList.offline.getOne(tdata.name) = 0) then
      tTheBuddyList.offline.add(tdata.name)
    end if
  end if
  tTheBuddyList.render = []
  repeat with tName in tTheBuddyList.online
    tTheBuddyList.render.add(tName)
  end repeat
  repeat with tName in tTheBuddyList.offline
    tTheBuddyList.render.add(tName)
  end repeat
  repeat with tRequest in pFriendRequestList
    tBuddyID = tdata.getaProp(#id)
    tRequestBuddyId = tRequest.getaProp(#webID)
    tRequestId = tRequest.getaProp(#id)
    if (tBuddyID = tRequestBuddyId) then
      me.setRequestState(tRequestId, #accepted)
    end if
  end repeat
  me.getInterface().appendBuddy(tdata)
end

on receive_RemoveBuddies me, tList
  if not me.getInterface().isMessengerActive() then
    if objectExists("buddy_massremove") then
      getObject("buddy_massremove").confirmationReceived()
    end if
    return 1
  end if
  repeat with tID in tList
    me.getInterface().removeBuddy(tID)
    tTheBuddyList = pBuddyList.getaProp(#value)
    tTheBuddyList.sort()
    tBuddy = tTheBuddyList.buddies.getaProp(tID)
    if voidp(tBuddy) then
      return error(me, ("Buddy not found:" && tID), #receive_RemoveBuddies, #minor)
    end if
    tBuddyName = tBuddy.name
    tTheBuddyList.buddies.deleteProp(tID)
    tTheBuddyList.online.deleteOne(tBuddyName)
    tTheBuddyList.offline.deleteOne(tBuddyName)
    tTheBuddyList.render.deleteOne(tBuddyName)
    me.eraseMessagesBySenderID(tID)
  end repeat
  return 1
end

on receive_PersistentMsg me, tMsg
  pItemList[#persistenMsg] = tMsg
end

on receive_Message me, tMsg
  return 1
  if voidp(pItemList[#messages].getaProp(tMsg[#senderID])) then
    pItemList[#messages].setaProp(tMsg[#senderID], [:])
  end if
  pItemList[#messages].getaProp(tMsg[#senderID]).setaProp(tMsg[#id], tMsg)
  if voidp(pItemList[#msgCount][#allmsg]) then
    pItemList[#msgCount][#allmsg] = 1
  else
    pItemList[#msgCount][#allmsg] = (pItemList[#msgCount][#allmsg] + 1)
  end if
  tSender = pBuddyList.getaProp(#value).buddies.getaProp(tMsg[#senderID])
  if not voidp(tSender) then
    tSender.setaProp(#msgs, (tSender.getaProp(#msgs) + 1))
    tSender.setaProp(#update, 1)
  end if
  if voidp(pItemList[#msgCount].getaProp(tMsg[#senderID])) then
    pItemList[#msgCount].setaProp(tMsg[#senderID], 1)
  else
    pItemList[#msgCount].setaProp(tMsg[#senderID], (pItemList[#msgCount].getaProp(tMsg[#senderID]) + 1))
  end if
  me.getInterface().updateBuddyList()
  me.tellMessageCount()
  me.getInterface().updateFrontPage()
end

on receive_BuddyRequest me, tdata
  repeat with tRequest in tdata
    pFriendRequestList.add(tRequest)
  end repeat
  me.tellRequestCount()
  tInterface = me.getInterface()
  tInterface.updateFrontPage()
end

on receive_UserFound me, tMsg
  me.getInterface().updateUserFind(tMsg, 1)
end

on receive_UserNotFound me, tMsg
  me.getInterface().updateUserFind(VOID, 0)
end

on receive_CampaignMsg me, tMsg
  if (tMsg[#message].char[1] = "[dialog_msg]") then
    if memberExists((tMsg[#link] && "Class")) then
      tObjID = getUniqueID()
      if not createObject(tObjID, (tMsg[#link] && "Class")) then
        return error(me, ("Failed to initialize class:" && tMsg[#link]), #receive_CampaignMsg, #major)
      end if
      call(#assignCampaignID, [getObject(tObjID)], tMsg[#id])
      return 1
    end if
  end if
  me.receive_Message(tMsg)
end

on receive_BuddyRequestResult me, tErrorList
  repeat with tErrorNo = 1 to tErrorList.count
    tSenderName = tErrorList.getPropAt(tErrorNo)
    tErrorCode = tErrorList[tErrorNo]
    repeat with tRequest in pFriendRequestList
      tRequestName = tRequest.getaProp(#name)
      tRequestId = tRequest.getaProp(#id)
      if (tRequestName = tSenderName) then
        if (tErrorCode = 1) then
          me.setRequestState(tRequestId, #pending)
          next repeat
        end if
        me.setRequestState(tRequestId, #failed)
      end if
    end repeat
  end repeat
end

on send_MessageMarkRead me, tmessageId, tSenderId, tCampaignFlag
  me.decreaseMsgCount(tSenderId)
  if (pItemList[#messages].count > 0) then
    if not voidp(pItemList[#messages].getaProp(tSenderId)) then
      pItemList[#messages].getaProp(tSenderId).deleteProp(tmessageId)
      if (pItemList[#messages].getaProp(tSenderId).count = 0) then
        pItemList[#messages].deleteProp(tSenderId)
      end if
    end if
  end if
  me.getInterface().updateBuddyList()
  if tCampaignFlag then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_C_READ", [#integer: integer(tmessageId)])
  else
    getConnection(getVariable("connection.info.id")).send("MESSENGER_MARKREAD", [#integer: integer(tmessageId)])
  end if
end

on send_Message me, tReceivers, tMsg
  if not listp(tReceivers) then
    return 0
  end if
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  tdata = [#integer: tReceivers.count]
  repeat with tReceiver in tReceivers
    tdata.addProp(#integer, integer(tReceiver[#id]))
  end repeat
  tdata.addProp(#string, tMsg)
  return getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDMSG", tdata)
end

on send_PersistentMsg me, tMsg
  tMsg = tMsg.line[1]
  if (tMsg = pItemList[#persistenMsg]) then
    return 0
  end if
  pItemList[#persistenMsg] = tMsg
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ASSIGNPERSMSG", [#string: tMsg])
end

on acceptRequest me, tRequestId
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  me.setRequestState(tRequestId, #sent)
  me.tellRequestCount()
  tMsg = [#integer: 1, #integer: integer(tRequestId)]
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", tMsg)
  return 1
end

on acceptAllRequests me
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  tMsgList = [#integer: 0]
  tRequests = me.getRequestsByState(#pending)
  repeat with tRequest in tRequests
    tID = tRequest.getaProp(#id)
    tMsgList.addProp(#integer, integer(tID))
    me.setRequestState(tID, #sent)
  end repeat
  tMsgList[1] = (tMsgList.count - 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", tMsgList)
  me.tellRequestCount()
  return 1
end

on declineRequest me, tRequestId
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  me.setRequestState(tRequestId, #declined)
  me.tellRequestCount()
  tMsg = [#integer: 0, #integer: 1, #integer: integer(tRequestId)]
  getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", tMsg)
  return 1
end

on declineAllRequests me
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  tRequests = me.getRequestsByState(#pending)
  repeat with tRequest in tRequests
    tID = tRequest.getaProp(#id)
    me.setRequestState(tID, #declined)
  end repeat
  getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", [#integer: 1])
  me.tellRequestCount()
  return 1
end

on setRequestState me, tRequestId, tstate
  repeat with tRequest in pFriendRequestList
    tID = tRequest.getaProp(#id)
    if (tID = tRequestId) then
      tRequest.setaProp(#state, tstate)
      exit repeat
    end if
  end repeat
  me.getInterface().updateRequests()
  me.tellRequestCount()
  if ((me.getPendingRequestCount() = 0) and me.getFriendRequestUpdateRequired()) then
    me.getComponent().send_AskForFriendRequests()
  end if
  return 1
end

on send_RequestBuddy me, tBuddyName
  if ((tBuddyName = VOID) or (tBuddyName = EMPTY)) then
    return 1
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REQUESTBUDDY", [#string: tBuddyName])
  end if
end

on send_RemoveBuddy me, tBuddyID
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REMOVEBUDDY", [#integer: 1, #integer: integer(tBuddyID)])
  end if
end

on send_reportMessage me, tMsgId
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REPORTMESSAGE", [#integer: integer(tMsgId)])
  end if
end

on send_FindUser me, tName
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FINDUSER", [#string: tName, #string: "MESSENGER"])
  end if
end

on send_BuddylistUpdate me
  if not pPaused then
    tWindow = me.getInterface().pOpenWindow
    if (tWindow = EMPTY) then
      return 0
    end if
    if ((pLastBuddiesUpdateTime + pUpdateBuddiesInterval) > the milliSeconds) then
      return 0
    end if
    pLastBuddiesUpdateTime = the milliSeconds
    if connectionExists(getVariable("connection.info.id")) then
    end if
  end if
end

on send_AskForMessages me
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_GETMESSAGES", [#integer: 1])
  end if
end

on send_AskForFriendRequests me
  pFriendRequestList = []
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("GET_BUDDY_REQUESTS")
  end if
end

on getBuddyData me
  return pBuddyList.getaProp(#value)
end

on getNumOfMessages me
  if voidp(pItemList[#msgCount][#allmsg]) then
    return 0
  else
    return pItemList[#msgCount][#allmsg]
  end if
end

on getMyPersistenMsg me
  return pItemList[#persistenMsg]
end

on getNextMessage me
  if (pItemList[#messages].count > 0) then
    tSenderId = pItemList[#messages][1][1][#senderID]
    return pItemList[#messages][1][1]
  end if
end

on getMessageBySenderId me, tSenderId
  if (pItemList[#messages].count > 0) then
    if not stringp(tSenderId) then
      tSenderId = string(tSenderId)
    end if
    if not voidp(pItemList[#messages][tSenderId]) then
      return pItemList[#messages][tSenderId][1]
    end if
  end if
end

on eraseMessagesBySenderID me, tSenderId
  tMsgCount = 0
  if (pItemList[#messages].count > 0) then
    if not voidp(pItemList[#messages].getaProp(tSenderId)) then
      tMsgCount = pItemList[#messages][tSenderId].count
      pItemList[#messages].deleteProp(tSenderId)
    end if
  end if
  pItemList[#msgCount][tSenderId] = 0
  pItemList[#msgCount][#allmsg] = (pItemList[#msgCount][#allmsg] - tMsgCount)
  me.tellMessageCount()
  me.getInterface().updateFrontPage()
end

on decreaseMsgCount me, tSenderId
  pItemList[#msgCount].setaProp(tSenderId, (pItemList[#msgCount].getaProp(tSenderId) - 1))
  if (pItemList[#msgCount].getaProp(tSenderId) < 0) then
    pItemList[#msgCount].setaProp(tSenderId, 0)
  end if
  pItemList[#msgCount][#allmsg] = (pItemList[#msgCount][#allmsg] - 1)
  if (pItemList[#msgCount][#allmsg] < 0) then
    pItemList[#msgCount][#allmsg] = 0
  end if
  tBuddy = pBuddyList.getaProp(#value).buddies.getaProp(tSenderId)
  if not voidp(tBuddy) then
    tMsgCount = tBuddy.getaProp(#msgs)
    if (tMsgCount > 0) then
      tBuddy.setaProp(#msgs, (tMsgCount - 1))
      tBuddy.setaProp(#update, 1)
    end if
  end if
  me.tellMessageCount()
end

on tellMessageCount me
  return executeMessage(#updateMessageCount, me.getNumOfMessages())
end

on tellRequestCount me
  return executeMessage(#updateFriendRequestCount, me.getPendingRequestCount())
end

on externalBuddyRequest me, tTargetUser
  me.send_RequestBuddy(tTargetUser)
  me.getInterface().showMessenger()
  me.getInterface().pLastSearch[#name] = tTargetUser
  me.getInterface().ChangeWindowView("console_sentrequest.window")
end

on pause me
  pPaused = 1
  return 1
end

on resume me
  pPaused = 0
  return 1
end

on handleFriendlistConcurrency me
  executeMessage(#alert, [#Msg: "console_buddylist_concurrency", #modal: 1])
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE", [#integer: 0])
  end if
end

on updateClubStatus me, tStatus
  if (tStatus.getaProp(#productName) <> "club_habbo") then
    return 0
  end if
  if (tStatus.getaProp(#daysLeft) < 1) then
    return 0
  end if
  tLimits = me.getInterface().getBuddyListLimits()
  tOwn = tLimits.getaProp(#own)
  tNormal = tLimits.getaProp(#normal)
  tClub = tLimits.getaProp(#club)
  if ((voidp(tOwn) or voidp(tNormal)) or voidp(tClub)) then
    return 0
  end if
  if ((tOwn = -1) or (tOwn >= tClub)) then
    return 0
  end if
  me.getInterface().setBuddyListLimits(tClub, tNormal, tClub)
  return 1
end
