property pState, pPaused, pTimeOutID, pReadyFlag, pBuddyList, pItemList, pUpdateBuddiesInterval, pLastBuddiesUpdateTime

on construct me
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
  pState = VOID
  pPaused = 0
  pTimeOutID = #messenger_msg_poller
  pReadyFlag = 0
  pBuddyList = getStructVariable("struct.pointer")
  pItemList = [#messages: [:], #msgCount: [:], #newBuddyRequest: [], #pendingBuddyAccept: EMPTY, #persistenMsg: EMPTY]
  pUpdateBuddiesInterval = getIntVariable("messenger.updatetime.buddylist", 120000)
  pLastBuddiesUpdateTime = 0
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
    return error(me, "Messenger not ready yet..", #showMessenger)
  end if
  return me.getInterface().showMessenger()
end

on hideMessenger me
  if not pReadyFlag then
    return error(me, "Messenger not ready yet..", #hideMessenger)
  end if
  return me.getInterface().hideMessenger()
end

on showhidemessenger me
  if not pReadyFlag then
    return error(me, "Messenger not ready yet..", #showhidemessenger)
  end if
  return me.getInterface().showhidemessenger()
end

on deleteAllMessages me
  pItemList.messages = [:]
  pItemList.msgCount = [:]
  me.tellMessageCount()
  return 1
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
      if tList.buddies = VOID then
        return 0
      end if
      if tList.buddies.count = 0 then
        return 0
      end if
      tTheBuddyList = pBuddyList.getaProp(#value)
      repeat with i = 1 to tList.buddies.count
        tBuddy = tList.buddies[i]
        tCurrData = tTheBuddyList.buddies.getaProp(tBuddy.id)
        if voidp(tCurrData) then
          error(me, "Buddy not found:" & tBuddy[#id] & " - Rejecting update.", #receive_BuddyList)
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
          if tTheBuddyList.online.getOne(tCurrData[#name]) = 0 then
            tTheBuddyList.online.add(tCurrData[#name])
          end if
          next repeat
        end if
        if tTheBuddyList.online.getOne(tCurrData[#name]) then
          tTheBuddyList.online.deleteOne(tCurrData[#name])
        end if
        if tTheBuddyList.offline.getOne(tCurrData[#name]) = 0 then
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
  if tdata.count < 1 then
    return 0
  end if
  tdata = tdata.buddies
  tTheBuddyList = pBuddyList.getaProp(#value)
  tTheBuddyList.buddies.setaProp(tdata[#id], tdata)
  if tdata.online then
    if tTheBuddyList.online.getOne(tdata.name) = 0 then
      tTheBuddyList.online.add(tdata.name)
    end if
  else
    if tTheBuddyList.offline.getOne(tdata.name) = 0 then
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
  me.getInterface().appendBuddy(tdata)
end

on receive_RemoveBuddies me, tList
  if not me.getInterface().isMessengerActive() then
    if objectExists("buddy_massremove") then
      getObject("buddy_massremove").confirmationReceived()
    end if
    return 1
  end if
  repeat with tid in tList
    me.getInterface().removeBuddy(tid)
    tTheBuddyList = pBuddyList.getaProp(#value)
    tTheBuddyList.sort()
    tBuddy = tTheBuddyList.buddies.getaProp(tid)
    if voidp(tBuddy) then
      return error(me, "Buddy not found:" && tid, #receive_RemoveBuddies)
    end if
    tBuddyName = tBuddy.name
    tTheBuddyList.buddies.deleteProp(tid)
    tTheBuddyList.online.deleteOne(tBuddyName)
    tTheBuddyList.offline.deleteOne(tBuddyName)
    tTheBuddyList.render.deleteOne(tBuddyName)
    me.eraseMessagesBySenderID(tid)
  end repeat
  return 1
end

on receive_PersistentMsg me, tMsg
  pItemList[#persistenMsg] = tMsg
end

on receive_Message me, tMsg
  if voidp(pItemList[#messages].getaProp(tMsg[#senderID])) then
    pItemList[#messages].setaProp(tMsg[#senderID], [:])
  end if
  pItemList[#messages].getaProp(tMsg[#senderID]).setaProp(tMsg[#id], tMsg)
  if voidp(pItemList[#msgCount][#allmsg]) then
    pItemList[#msgCount][#allmsg] = 1
  else
    pItemList[#msgCount][#allmsg] = pItemList[#msgCount][#allmsg] + 1
  end if
  tSender = pBuddyList.getaProp(#value).buddies.getaProp(tMsg[#senderID])
  if not voidp(tSender) then
    tSender.setaProp(#msgs, tSender.getaProp(#msgs) + 1)
    tSender.setaProp(#update, 1)
  end if
  if voidp(pItemList[#msgCount].getaProp(tMsg[#senderID])) then
    pItemList[#msgCount].setaProp(tMsg[#senderID], 1)
  else
    pItemList[#msgCount].setaProp(tMsg[#senderID], pItemList[#msgCount].getaProp(tMsg[#senderID]) + 1)
  end if
  me.getInterface().updateBuddyList()
  me.tellMessageCount()
  puppetSound(3, getmemnum("con_new_message"))
  me.getInterface().updateFrontPage()
end

on receive_BuddyRequest me, tdata
  pItemList[#newBuddyRequest].add(tdata)
  me.tellRequestCount()
  return me.getInterface().updateFrontPage()
end

on receive_UserFound me, tMsg
  me.getInterface().updateUserFind(tMsg, 1)
end

on receive_UserNotFound me, tMsg
  me.getInterface().updateUserFind(VOID, 0)
end

on receive_CampaignMsg me, tMsg
  if tMsg[#message].char[1..12] = "[dialog_msg]" then
    if memberExists(tMsg[#link] && "Class") then
      tObjID = getUniqueID()
      if not createObject(tObjID, tMsg[#link] && "Class") then
        return error(me, "Failed to initialize class:" && tMsg[#link], #receive_CampaignMsg)
      end if
      call(#assignCampaignID, [getObject(tObjID)], tMsg[#id])
      return 1
    end if
  end if
  me.receive_Message(tMsg)
end

on send_MessageMarkRead me, tmessageId, tSenderId, tCampaignFlag
  me.decreaseMsgCount(tSenderId)
  if pItemList[#messages].count > 0 then
    if not voidp(pItemList[#messages].getaProp(tSenderId)) then
      pItemList[#messages].getaProp(tSenderId).deleteProp(tmessageId)
      if pItemList[#messages].getaProp(tSenderId).count = 0 then
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
  puppetSound(3, getmemnum("con_message_sent"))
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
  if tMsg = pItemList[#persistenMsg] then
    return 0
  end if
  pItemList[#persistenMsg] = tMsg
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ASSIGNPERSMSG", [#string: tMsg])
end

on send_AcceptBuddy me
  if pItemList[#newBuddyRequest].count > 0 then
    tBuddyID = pItemList[#newBuddyRequest][1][#id]
    pItemList[#pendingBuddyAccept] = pItemList[#newBuddyRequest][1]
    pItemList[#newBuddyRequest].deleteAt(1)
    me.tellRequestCount()
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", [#integer: integer(tBuddyID)])
    end if
  end if
end

on send_DeclineBuddy me, ttype
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  if ttype = #all then
    pItemList[#newBuddyRequest] = []
    me.tellRequestCount()
    me.getInterface().updateFrontPage()
    return getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", [#integer: 0])
  else
    if (ttype = #one) and (pItemList[#newBuddyRequest].count > 0) then
      tBuddyID = pItemList[#newBuddyRequest][1][#id]
      pItemList[#newBuddyRequest].deleteAt(1)
      me.tellRequestCount()
      return getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", [#integer: 1, #integer: integer(tBuddyID)])
    end if
  end if
end

on send_RequestBuddy me, tBuddyName
  if (tBuddyName = VOID) or (tBuddyName = EMPTY) then
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
    if tWindow = EMPTY then
      return 0
    end if
    if (pLastBuddiesUpdateTime + pUpdateBuddiesInterval) > the milliSeconds then
      return 0
    end if
    pLastBuddiesUpdateTime = the milliSeconds
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE")
    end if
  end if
end

on send_AskForMessages me
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_GETMESSAGES", [#integer: 1])
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

on getNumOfBuddyRequest me
  return pItemList[#newBuddyRequest].count
end

on getMyPersistenMsg me
  return pItemList[#persistenMsg]
end

on getNextBuddyRequest me
  if pItemList[#newBuddyRequest].count < 1 then
    return EMPTY
  else
    return pItemList[#newBuddyRequest][1]
  end if
end

on getNextMessage me
  if pItemList[#messages].count > 0 then
    tSenderId = pItemList[#messages][1][1][#senderID]
    return pItemList[#messages][1][1]
  end if
end

on getMessageBySenderId me, tSenderId
  if pItemList[#messages].count > 0 then
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
  if pItemList[#messages].count > 0 then
    if not voidp(pItemList[#messages].getaProp(tSenderId)) then
      tMsgCount = pItemList[#messages][tSenderId].count
      pItemList[#messages].deleteProp(tSenderId)
    end if
  end if
  pItemList[#msgCount][tSenderId] = 0
  pItemList[#msgCount][#allmsg] = pItemList[#msgCount][#allmsg] - tMsgCount
  me.tellMessageCount()
  me.getInterface().updateFrontPage()
end

on decreaseMsgCount me, tSenderId
  pItemList[#msgCount].setaProp(tSenderId, pItemList[#msgCount].getaProp(tSenderId) - 1)
  if pItemList[#msgCount].getaProp(tSenderId) < 0 then
    pItemList[#msgCount].setaProp(tSenderId, 0)
  end if
  pItemList[#msgCount][#allmsg] = pItemList[#msgCount][#allmsg] - 1
  if pItemList[#msgCount][#allmsg] < 0 then
    pItemList[#msgCount][#allmsg] = 0
  end if
  tBuddy = pBuddyList.getaProp(#value).buddies.getaProp(tSenderId)
  if not voidp(tBuddy) then
    tMsgCount = tBuddy.getaProp(#msgs)
    if tMsgCount > 0 then
      tBuddy.setaProp(#msgs, tMsgCount - 1)
      tBuddy.setaProp(#update, 1)
    end if
  end if
  me.tellMessageCount()
end

on tellMessageCount me
  return executeMessage(#updateMessageCount, me.getNumOfMessages())
end

on tellRequestCount me
  return executeMessage(#updateBuddyrequestCount, me.getNumOfBuddyRequest())
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
