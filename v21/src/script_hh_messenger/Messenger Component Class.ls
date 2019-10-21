on construct(me)
  registerMessage(#enterRoom, me.getID(), #hideMessenger)
  registerMessage(#leaveRoom, me.getID(), #hideMessenger)
  registerMessage(#changeRoom, me.getID(), #hideMessenger)
  registerMessage(#show_messenger, me.getID(), #showMessenger)
  registerMessage(#hide_messenger, me.getID(), #hideMessenger)
  registerMessage(#show_hide_messenger, me.getID(), #showhidemessenger)
  registerMessage(#messageUpdateRequest, me.getID(), #tellMessageCount)
  registerMessage(#buddyUpdateRequest, me.getID(), #tellRequestCount)
  registerMessage(#externalBuddyRequest, me.getID(), #externalBuddyRequest)
  registerMessage(#pause_messeger_update, me.getID(), #pause)
  registerMessage(#resume_messeger_update, me.getID(), #resume)
  registerMessage(#updateClubStatus, me.getID(), #updateClubStatus)
  pState = void()
  pPaused = 0
  pTimeOutID = #messenger_msg_poller
  pReadyFlag = 0
  pBuddyList = getStructVariable("struct.pointer")
  pItemList = [#messages:[], #msgCount:[], #newBuddyRequest:[], #pendingBuddyAccept:"", #persistenMsg:""]
  -- UNK_C0 4391511
  pLastBuddiesUpdateTime = ERROR
  pFriendRequestList = []
  pFriendRequestUpdateRequired = 0
  pMessageUpdateRequired = 0
  pInvitationData = []
  pBuddyList.setProp(#value, [#buddies:[], #online:[], #offline:[], #render:[]])
  me.getInterface().createBuddyList(pBuddyList)
  executeMessage(#messenger_ready, #messenger)
  return(1)
  exit
end

on deconstruct(me)
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
  pBuddyList = []
  pItemList = []
  executeMessage(#messenger_dead, #messenger)
  return(1)
  exit
end

on showMessenger(me)
  if not pReadyFlag then
    return(error(me, "Messenger not ready yet..", #showMessenger, #minor))
  end if
  return(me.getInterface().showMessenger())
  exit
end

on hideMessenger(me)
  if not pReadyFlag then
    return(error(me, "Messenger not ready yet..", #hideMessenger, #minor))
  end if
  return(me.getInterface().hideMessenger())
  exit
end

on showhidemessenger(me)
  if not pReadyFlag then
    return(error(me, "Messenger not ready yet..", #showhidemessenger, #minor))
  end if
  return(me.getInterface().showhidemessenger())
  exit
end

on deleteAllMessages(me)
  pItemList.messages = []
  pItemList.msgCount = []
  me.tellMessageCount()
  return(1)
  exit
end

on getNextPendingInstantBuddyRequest(me)
  if threadExists(#room) then
    tRoomComp = getThread(#room).getComponent()
    if tRoomComp.getRoomID() = "" then
      return(0)
    end if
  end if
  if pFriendRequestList.count < 1 then
    return(0)
  else
    tItemNo = 1
    repeat while tItemNo <= pFriendRequestList.count
      tItem = pFriendRequestList.getAt(tItemNo)
      if tItem.getAt(#state) = #pending then
        tUserIndex = tRoomComp.getUsersRoomId(tItem.getAt(#name))
        if tUserIndex <> -1 then
          return(tItem.duplicate())
        end if
      end if
      tItemNo = 1 + tItemNo
    end repeat
  end if
  return(0)
  exit
end

on getRequestSet(me, tSetIndex, tRequestsInSet)
  tStartIndex = tSetIndex - 1 * tRequestsInSet + 1
  tEndIndex = tStartIndex + tRequestsInSet - 1
  if tEndIndex > pFriendRequestList.count then
    tEndIndex = pFriendRequestList.count
  end if
  tSet = []
  tIndex = tStartIndex
  repeat while tIndex <= tEndIndex
    tSet.add(pFriendRequestList.getAt(tIndex))
    tIndex = 1 + tIndex
  end repeat
  return(tSet)
  exit
end

on getRequestsByState(me, tstate)
  tRequests = []
  repeat while me <= undefined
    tRequest = getAt(undefined, tstate)
    if tRequest.getaProp(#state) = tstate then
      tRequests.add(tRequest)
    end if
  end repeat
  return(tRequests)
  exit
end

on clearRequests(me)
  tRequestNo = pFriendRequestList.count
  repeat while tRequestNo >= 1
    tRequest = pFriendRequestList.getAt(tRequestNo)
    tstate = tRequest.getaProp(#state)
    if tstate = #accepted or tstate = #declined or tstate = #failed then
      pFriendRequestList.deleteAt(tRequestNo)
    end if
    tRequestNo = 255 + tRequestNo
  end repeat
  me.tellRequestCount()
  return(1)
  exit
end

on getRequestCount(me)
  return(pFriendRequestList.count)
  exit
end

on getPendingRequestCount(me)
  tCount = 0
  repeat while me <= undefined
    tRequest = getAt(undefined, undefined)
    tstate = tRequest.getaProp(#state)
    if tstate = #pending then
      tCount = tCount + 1
    end if
  end repeat
  return(tCount)
  exit
end

on getFriendRequests(me)
  return(pFriendRequestList)
  exit
end

on getFriendRequestUpdateRequired(me)
  return(pFriendRequestUpdateRequired)
  exit
end

on setFriendRequestUpdateRequired(me, tValue)
  pFriendRequestUpdateRequired = tValue
  exit
end

on setMessageUpdateRequired(me, tValue)
  pMessageUpdateRequired = tValue
  exit
end

on getMessageUpdateRequired(me)
  return(pMessageUpdateRequired)
  exit
end

on receive_MessengerReady(me, tMsg)
  pReadyFlag = 1
  createTimeout(pTimeOutID, pUpdateBuddiesInterval, #send_BuddylistUpdate, me.getID(), void(), 0)
  return(executeMessage(#messenger_ready))
  exit
end

on receive_BuddyList(me, ttype, tList)
  me.getInterface().setMessengerActive()
  if me = #new then
    pBuddyList.setaProp(#value, tList)
    me.getInterface().createBuddyList(pBuddyList)
  else
    if me = #update then
      if tList.buddies = void() then
        return(0)
      end if
      if tList.count(#buddies) = 0 then
        return(0)
      end if
      tTheBuddyList = pBuddyList.getaProp(#value)
      i = 1
      repeat while i <= tList.count(#buddies)
        tBuddy = tList.getProp(#buddies, i)
        tCurrData = buddies.getaProp(tBuddy.id)
        if voidp(tCurrData) then
          error(me, "Buddy not found:" & tBuddy.getAt(#id) & " - Rejecting update.", #receive_BuddyList, #minor)
        else
          j = 1
          repeat while j <= tBuddy.count
            tKey = tBuddy.getPropAt(j)
            tValue = tBuddy.getAt(j)
            tCurrData.setAt(tKey, tValue)
            j = 1 + j
          end repeat
          tMsgList = messages.getaProp(tBuddy.getAt(#id))
          if listp(tMsgList) then
            tCurrData.setAt(#msgs, tMsgList.count)
          end if
          if tBuddy.online then
            if offline.getOne(tCurrData.getAt(#name)) then
              offline.deleteOne(tCurrData.getAt(#name))
            end if
            if online.getOne(tCurrData.getAt(#name)) = 0 then
              online.add(tCurrData.getAt(#name))
            end if
          else
            if online.getOne(tCurrData.getAt(#name)) then
              online.deleteOne(tCurrData.getAt(#name))
            end if
            if offline.getOne(tCurrData.getAt(#name)) = 0 then
              offline.add(tCurrData.getAt(#name))
            end if
          end if
        end if
        i = 1 + i
      end repeat
      tTheBuddyList.render = []
      repeat while me <= tList
        tName = getAt(tList, ttype)
        render.add(tName)
      end repeat
      repeat while me <= tList
        tName = getAt(tList, ttype)
        render.add(tName)
      end repeat
      me.getInterface().updateBuddyList()
    end if
  end if
  exit
end

on receive_AppendBuddy(me, tdata)
  if not listp(tdata) then
    return(0)
  end if
  if tdata.count < 1 then
    return(0)
  end if
  tdata = tdata.buddies
  tTheBuddyList = pBuddyList.getaProp(#value)
  buddies.setaProp(tdata.getAt(#id), tdata)
  if tdata.online then
    if online.getOne(tdata.name) = 0 then
      online.add(tdata.name)
    end if
  else
    if offline.getOne(tdata.name) = 0 then
      offline.add(tdata.name)
    end if
  end if
  tTheBuddyList.render = []
  repeat while me <= undefined
    tName = getAt(undefined, tdata)
    render.add(tName)
  end repeat
  repeat while me <= undefined
    tName = getAt(undefined, tdata)
    render.add(tName)
  end repeat
  repeat while me <= undefined
    tRequest = getAt(undefined, tdata)
    tBuddyID = tdata.getaProp(#id)
    tRequestBuddyId = tRequest.getaProp(#webID)
    tRequestId = tRequest.getaProp(#id)
    if tBuddyID = tRequestBuddyId then
      me.setRequestState(tRequestId, #accepted)
    end if
  end repeat
  me.getInterface().appendBuddy(tdata)
  exit
end

on receive_RemoveBuddies(me, tList)
  if not me.getInterface().isMessengerActive() then
    if objectExists("buddy_massremove") then
      getObject("buddy_massremove").confirmationReceived()
    end if
    return(1)
  end if
  repeat while me <= undefined
    tID = getAt(undefined, tList)
    me.getInterface().removeBuddy(tID)
    tTheBuddyList = pBuddyList.getaProp(#value)
    tTheBuddyList.sort()
    tBuddy = buddies.getaProp(tID)
    if voidp(tBuddy) then
      return(error(me, "Buddy not found:" && tID, #receive_RemoveBuddies, #minor))
    end if
    tBuddyName = tBuddy.name
    buddies.deleteProp(tID)
    online.deleteOne(tBuddyName)
    offline.deleteOne(tBuddyName)
    render.deleteOne(tBuddyName)
    me.eraseMessagesBySenderID(tID)
  end repeat
  return(1)
  exit
end

on receive_PersistentMsg(me, tMsg)
  pItemList.setAt(#persistenMsg, tMsg)
  exit
end

on receive_Message(me, tMsg)
  if voidp(pItemList.getAt(#messages).getaProp(tMsg.getAt(#senderID))) then
    pItemList.getAt(#messages).setaProp(tMsg.getAt(#senderID), [])
  end if
  pItemList.getAt(#messages).getaProp(tMsg.getAt(#senderID)).setaProp(tMsg.getAt(#id), tMsg)
  if voidp(pItemList.getAt(#msgCount).getAt(#allmsg)) then
    pItemList.getAt(#msgCount).setAt(#allmsg, 1)
  else
    pItemList.getAt(#msgCount).setAt(#allmsg, pItemList.getAt(#msgCount).getAt(#allmsg) + 1)
  end if
  tSender = buddies.getaProp(tMsg.getAt(#senderID))
  if not voidp(tSender) then
    tSender.setaProp(#msgs, tSender.getaProp(#msgs) + 1)
    tSender.setaProp(#update, 1)
  end if
  if voidp(pItemList.getAt(#msgCount).getaProp(tMsg.getAt(#senderID))) then
    pItemList.getAt(#msgCount).setaProp(tMsg.getAt(#senderID), 1)
  else
    pItemList.getAt(#msgCount).setaProp(tMsg.getAt(#senderID), pItemList.getAt(#msgCount).getaProp(tMsg.getAt(#senderID)) + 1)
  end if
  me.getInterface().updateBuddyList()
  me.tellMessageCount()
  me.getInterface().updateFrontPage()
  exit
end

on receive_BuddyRequest(me, tdata)
  repeat while me <= undefined
    tRequest = getAt(undefined, tdata)
    pFriendRequestList.add(tRequest)
  end repeat
  me.tellRequestCount()
  tInterface = me.getInterface()
  tInterface.updateFrontPage()
  exit
end

on receive_UserFound(me, tMsg)
  me.getInterface().updateUserFind(tMsg, 1)
  exit
end

on receive_UserNotFound(me, tMsg)
  me.getInterface().updateUserFind(void(), 0)
  exit
end

on receive_CampaignMsg(me, tMsg)
  if tMsg.getAt(#message).getProp(#char, 1, 12) = "[dialog_msg]" then
    if memberExists(tMsg.getAt(#link) && "Class") then
      tObjID = getUniqueID()
      if not createObject(tObjID, tMsg.getAt(#link) && "Class") then
        return(error(me, "Failed to initialize class:" && tMsg.getAt(#link), #receive_CampaignMsg, #major))
      end if
      call(#assignCampaignID, [getObject(tObjID)], tMsg.getAt(#id))
      return(1)
    end if
  end if
  me.receive_Message(tMsg)
  exit
end

on receive_BuddyRequestResult(me, tErrorList)
  tErrorNo = 1
  repeat while tErrorNo <= tErrorList.count
    tSenderName = tErrorList.getPropAt(tErrorNo)
    tErrorCode = tErrorList.getAt(tErrorNo)
    repeat while me <= undefined
      tRequest = getAt(undefined, tErrorList)
      tRequestName = tRequest.getaProp(#name)
      tRequestId = tRequest.getaProp(#id)
      if tRequestName = tSenderName then
        if tErrorCode = 1 then
          me.setRequestState(tRequestId, #pending)
        else
          me.setRequestState(tRequestId, #failed)
        end if
      end if
    end repeat
    tErrorNo = 1 + tErrorNo
  end repeat
  exit
end

on send_MessageMarkRead(me, tmessageId, tSenderId, tCampaignFlag)
  me.decreaseMsgCount(tSenderId)
  if pItemList.getAt(#messages).count > 0 then
    if not voidp(pItemList.getAt(#messages).getaProp(tSenderId)) then
      pItemList.getAt(#messages).getaProp(tSenderId).deleteProp(tmessageId)
      if pItemList.getAt(#messages).getaProp(tSenderId).count = 0 then
        pItemList.getAt(#messages).deleteProp(tSenderId)
      end if
    end if
  end if
  me.getInterface().updateBuddyList()
  if tCampaignFlag then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_C_READ", [#integer:integer(tmessageId)])
  else
    getConnection(getVariable("connection.info.id")).send("MESSENGER_MARKREAD", [#integer:integer(tmessageId)])
  end if
  exit
end

on send_Message(me, tReceivers, tMsg)
  if not listp(tReceivers) then
    return(0)
  end if
  playSound("con_message_sent", #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  tdata = [#integer:tReceivers.count]
  repeat while me <= tMsg
    tReceiver = getAt(tMsg, tReceivers)
    tdata.addProp(#integer, integer(tReceiver.getAt(#id)))
  end repeat
  tdata.addProp(#string, tMsg)
  return(getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDMSG", tdata))
  exit
end

on send_PersistentMsg(me, tMsg)
  tMsg = tMsg.getProp(#line, 1)
  if tMsg = pItemList.getAt(#persistenMsg) then
    return(0)
  end if
  pItemList.setAt(#persistenMsg, tMsg)
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ASSIGNPERSMSG", [#string:tMsg])
  exit
end

on acceptRequest(me, tRequestId)
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  me.setRequestState(tRequestId, #sent)
  me.tellRequestCount()
  tMsg = [#integer:1, #integer:integer(tRequestId)]
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", tMsg)
  return(1)
  exit
end

on acceptAllRequests(me)
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  tMsgList = [#integer:0]
  tRequests = me.getRequestsByState(#pending)
  repeat while me <= undefined
    tRequest = getAt(undefined, undefined)
    tID = tRequest.getaProp(#id)
    tMsgList.addProp(#integer, integer(tID))
    me.setRequestState(tID, #sent)
  end repeat
  tMsgList.setAt(1, tMsgList.count - 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", tMsgList)
  me.tellRequestCount()
  return(1)
  exit
end

on declineRequest(me, tRequestId)
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  me.setRequestState(tRequestId, #declined)
  me.tellRequestCount()
  tMsg = [#integer:0, #integer:1, #integer:integer(tRequestId)]
  getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", tMsg)
  return(1)
  exit
end

on declineAllRequests(me)
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  tRequests = me.getRequestsByState(#pending)
  repeat while me <= undefined
    tRequest = getAt(undefined, undefined)
    tID = tRequest.getaProp(#id)
    me.setRequestState(tID, #declined)
  end repeat
  getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", [#integer:1])
  me.tellRequestCount()
  return(1)
  exit
end

on setRequestState(me, tRequestId, tstate)
  repeat while me <= tstate
    tRequest = getAt(tstate, tRequestId)
    tID = tRequest.getaProp(#id)
    if tID = tRequestId then
      tRequest.setaProp(#state, tstate)
    else
    end if
  end repeat
  me.getInterface().updateRequests()
  me.tellRequestCount()
  if me.getPendingRequestCount() = 0 and me.getFriendRequestUpdateRequired() then
    me.getComponent().send_AskForFriendRequests()
  end if
  return(1)
  exit
end

on send_RequestBuddy(me, tBuddyName)
  if tBuddyName = void() or tBuddyName = "" then
    return(1)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REQUESTBUDDY", [#string:tBuddyName])
  end if
  exit
end

on send_RemoveBuddy(me, tBuddyID)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REMOVEBUDDY", [#integer:1, #integer:integer(tBuddyID)])
  end if
  exit
end

on send_reportMessage(me, tMsgId)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REPORTMESSAGE", [#integer:integer(tMsgId)])
  end if
  exit
end

on send_FindUser(me, tName)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FINDUSER", [#string:tName, #string:"MESSENGER"])
  end if
  exit
end

on send_BuddylistUpdate(me)
  if not pPaused then
    tWindow = me.getInterface().pOpenWindow
    if tWindow = "" then
      return(0)
    end if
    if pLastBuddiesUpdateTime + pUpdateBuddiesInterval > the milliSeconds then
      return(0)
    end if
    pLastBuddiesUpdateTime = the milliSeconds
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE")
    end if
  end if
  exit
end

on send_AskForMessages(me)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_GETMESSAGES", [#integer:1])
  end if
  exit
end

on send_AskForFriendRequests(me)
  pFriendRequestList = []
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("GET_BUDDY_REQUESTS")
  end if
  exit
end

on getBuddyData(me)
  return(pBuddyList.getaProp(#value))
  exit
end

on getNumOfMessages(me)
  if voidp(pItemList.getAt(#msgCount).getAt(#allmsg)) then
    return(0)
  else
    return(pItemList.getAt(#msgCount).getAt(#allmsg))
  end if
  exit
end

on getMyPersistenMsg(me)
  return(pItemList.getAt(#persistenMsg))
  exit
end

on getNextMessage(me)
  if pItemList.getAt(#messages).count > 0 then
    tSenderId = pItemList.getAt(#messages).getAt(1).getAt(1).getAt(#senderID)
    return(pItemList.getAt(#messages).getAt(1).getAt(1))
  end if
  exit
end

on getMessageBySenderId(me, tSenderId)
  if pItemList.getAt(#messages).count > 0 then
    if not stringp(tSenderId) then
      tSenderId = string(tSenderId)
    end if
    if not voidp(pItemList.getAt(#messages).getAt(tSenderId)) then
      return(pItemList.getAt(#messages).getAt(tSenderId).getAt(1))
    end if
  end if
  exit
end

on eraseMessagesBySenderID(me, tSenderId)
  tMsgCount = 0
  if pItemList.getAt(#messages).count > 0 then
    if not voidp(pItemList.getAt(#messages).getaProp(tSenderId)) then
      tMsgCount = pItemList.getAt(#messages).getAt(tSenderId).count
      pItemList.getAt(#messages).deleteProp(tSenderId)
    end if
  end if
  pItemList.getAt(#msgCount).setAt(tSenderId, 0)
  pItemList.getAt(#msgCount).setAt(#allmsg, pItemList.getAt(#msgCount).getAt(#allmsg) - tMsgCount)
  me.tellMessageCount()
  me.getInterface().updateFrontPage()
  exit
end

on decreaseMsgCount(me, tSenderId)
  pItemList.getAt(#msgCount).setaProp(tSenderId, pItemList.getAt(#msgCount).getaProp(tSenderId) - 1)
  if pItemList.getAt(#msgCount).getaProp(tSenderId) < 0 then
    pItemList.getAt(#msgCount).setaProp(tSenderId, 0)
  end if
  pItemList.getAt(#msgCount).setAt(#allmsg, pItemList.getAt(#msgCount).getAt(#allmsg) - 1)
  if pItemList.getAt(#msgCount).getAt(#allmsg) < 0 then
    pItemList.getAt(#msgCount).setAt(#allmsg, 0)
  end if
  tBuddy = buddies.getaProp(tSenderId)
  if not voidp(tBuddy) then
    tMsgCount = tBuddy.getaProp(#msgs)
    if tMsgCount > 0 then
      tBuddy.setaProp(#msgs, tMsgCount - 1)
      tBuddy.setaProp(#update, 1)
    end if
  end if
  me.tellMessageCount()
  exit
end

on tellMessageCount(me)
  return(executeMessage(#updateMessageCount, me.getNumOfMessages()))
  exit
end

on tellRequestCount(me)
  return(executeMessage(#updateBuddyrequestCount, me.getPendingRequestCount()))
  exit
end

on externalBuddyRequest(me, tTargetUser)
  me.send_RequestBuddy(tTargetUser)
  me.getInterface().showMessenger()
  me.getInterface().setProp(#pLastSearch, #name, tTargetUser)
  me.getInterface().ChangeWindowView("console_sentrequest.window")
  exit
end

on pause(me)
  pPaused = 1
  return(1)
  exit
end

on resume(me)
  pPaused = 0
  return(1)
  exit
end

on handleFriendlistConcurrency(me)
  executeMessage(#alert, [#Msg:"console_buddylist_concurrency", #modal:1])
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE", [#integer:0])
  end if
  exit
end

on updateClubStatus(me, tStatus)
  if tStatus.getaProp(#productName) <> "club_habbo" then
    return(0)
  end if
  if tStatus.getaProp(#daysLeft) < 1 then
    return(0)
  end if
  tLimits = me.getInterface().getBuddyListLimits()
  tOwn = tLimits.getaProp(#own)
  tNormal = tLimits.getaProp(#normal)
  tClub = tLimits.getaProp(#club)
  if voidp(tOwn) or voidp(tNormal) or voidp(tClub) then
    return(0)
  end if
  if tOwn = -1 or tOwn >= tClub then
    return(0)
  end if
  me.getInterface().setBuddyListLimits(tClub, tNormal, tClub)
  return(1)
  exit
end