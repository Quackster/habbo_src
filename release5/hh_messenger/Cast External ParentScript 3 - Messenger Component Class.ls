property pState, pPaused, pTimeOutID, pReadyFlag, pBuddyList, pItemList, pProfileData

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
  pItemList = [#messages: [:], #msgCount: [:], #newBuddyRequest: [], #persistenMsg: EMPTY, #smsAccount: "inactive"]
  pProfileData = [:]
  pBuddyList.setProp(#value, [#buddies: [:], #online: [], #offline: [], #render: []])
  me.getInterface().createBuddyList(pBuddyList)
  createTimeout(pTimeOutID, getIntVariable("messenger.updatetime.buddylist", 120000), #send_BuddylistUpdate, me.getID(), VOID, 0)
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

on receive_MessengerReady me, tMsg
  pReadyFlag = 1
  executeMessage(#messenger_ready)
end

on receive_BuddyList me, ttype, tList
  case ttype of
    #new:
      pBuddyList.setaProp(#value, tList)
      me.getInterface().createBuddyList(pBuddyList)
    #update:
      if tList.buddies.count = 0 then
        return 0
      end if
      tTheBuddyList = pBuddyList.getaProp(#value)
      repeat with i = 1 to tList.buddies.count
        tBuddy = tList.buddies[i]
        tCurrData = tTheBuddyList.buddies.getaProp(tBuddy.id)
        if voidp(tCurrData) then
          error(me, "Buddy not found:" & tBuddy[#name] & "Creating new struct.", #receive_BLUpdate)
          me.receive_AppendBuddy([#buddies: [tBuddy]])
          next repeat
        end if
        repeat with j = 1 to tCurrData.count
          tKey = tBuddy.getPropAt(j)
          tValue = tBuddy[j]
          tCurrData[tKey] = tValue
        end repeat
        tMsgList = pItemList.messages.getaProp(tBuddy[#id])
        if listp(tMsgList) then
          tCurrData[#msgs] = tMsgList.count
        end if
        if tBuddy.online then
          if tTheBuddyList.offline.getOne(tBuddy.name) then
            tTheBuddyList.offline.deleteOne(tBuddy.name)
          end if
          if tTheBuddyList.online.getOne(tBuddy.name) = 0 then
            tTheBuddyList.online.add(tBuddy.name)
          end if
          next repeat
        end if
        if tTheBuddyList.online.getOne(tBuddy.name) then
          tTheBuddyList.online.deleteOne(tBuddy.name)
        end if
        if tTheBuddyList.offline.getOne(tBuddy.name) = 0 then
          tTheBuddyList.offline.add(tBuddy.name)
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
  tdata = tdata.buddies[1]
  tTheBuddyList = pBuddyList.getaProp(#value)
  tTheBuddyList.buddies.setaProp(tdata[#id], tdata)
  if tdata.online then
    tTheBuddyList.online.add(tdata.name)
  else
    tTheBuddyList.offline.add(tdata.name)
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

on receive_RemoveBuddy me, tid
  me.getInterface().removeBuddy(tid)
  tTheBuddyList = pBuddyList.getaProp(#value)
  tBuddy = tTheBuddyList.buddies.getaProp(tid)
  if voidp(tBuddy) then
    return error(me, "Buddy not found:" && tid, #receive_RemoveBuddy)
  end if
  tTheBuddyList.buddies.deleteProp(tid)
  tTheBuddyList.online.deleteOne(tBuddy.name)
  tTheBuddyList.offline.deleteOne(tBuddy.name)
  tTheBuddyList.render.deleteOne(tBuddy.name)
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

on receive_BuddyRequest me, tMsg
  pItemList[#newBuddyRequest].add(tMsg[#name])
  me.tellRequestCount()
  me.getInterface().updateFrontPage()
end

on receive_SmsAccount me, tMsg
  pItemList[#smsAccount] = tMsg
end

on receive_UserFound me, tMsg
  me.getInterface().updateUserFind(tMsg, 1)
end

on receive_UserNotFound me, tMsg
  me.getInterface().updateUserFind(tMsg, 0)
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

on receive_UserProfile me, tMsg
  pProfileData = tMsg
  me.getInterface().renderProfileData()
end

on send_MessageMarkRead me, tmessageId, tSenderId
  me.decreaseMsgCount(tSenderId)
  if pItemList[#messages].count > 0 then
    pItemList[#messages].getaProp(tSenderId).deleteProp(tmessageId)
    if pItemList[#messages].getaProp(tSenderId).count = 0 then
      pItemList[#messages].deleteProp(tSenderId)
    end if
  end if
  me.getInterface().updateBuddyList()
  if tSenderId = "Campaign Msg" then
    getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_C_READ" && tmessageId)
  else
    getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_MARKREAD" && tmessageId)
  end if
end

on send_Message me, tReceivers, tMsg
  puppetSound(3, getmemnum("con_message_sent"))
  getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_SENDMSG" && tReceivers & RETURN & tMsg)
end

on send_EmailMessage me, tReceivers, tMsg
  puppetSound(3, getmemnum("con_message_sent"))
  getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_SENDEMAILMSG" && tReceivers & RETURN & tMsg)
end

on send_SmsMessage me, tReceivers, tMsg
  puppetSound(3, getmemnum("con_message_sent"))
  getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_SENDSMSMSG" && tReceivers & RETURN & tMsg)
end

on send_PersistentMsg me, tMsg
  tMsg = tMsg.line[1]
  if tMsg = pItemList[#persistenMsg] then
    return 0
  end if
  pItemList[#persistenMsg] = tMsg
  getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_ASSIGNPERSMSG" && tMsg)
end

on send_AcceptBuddy me, tBuddyName
  if pItemList[#newBuddyRequest].count > 0 then
    if voidp(tBuddyName) then
      tBuddyName = pItemList[#newBuddyRequest][1]
      pItemList[#newBuddyRequest].deleteAt(1)
    end if
    me.tellRequestCount()
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_ACCEPTBUDDY" && tBuddyName)
    end if
  end if
end

on send_DeclineBuddy me, tBuddyName
  if pItemList[#newBuddyRequest].count > 0 then
    if voidp(tBuddyName) then
      tBuddyName = pItemList[#newBuddyRequest][1]
      pItemList[#newBuddyRequest].deleteAt(1)
    end if
    me.tellRequestCount()
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_DECLINEBUDDY" && tBuddyName)
    end if
  end if
end

on send_RequestBuddy me, tBuddyName
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_REQUESTBUDDY" && tBuddyName & RETURN & "x")
  end if
end

on send_RemoveBuddy me, tBuddyName
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_REMOVEBUDDY" && tBuddyName)
  end if
end

on send_FindUser me, tName
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "FINDUSER" && tName & TAB & "MESSENGER")
  end if
end

on send_GetProfile me
  if pProfileData.count = 0 then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send(#info, "UINFO_GETPROFILE")
    end if
  else
  end if
end

on send_ProfileValue me, tid, tValue
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "UINFO_SETPROFILEVALUE /" & tid & "/" & tValue)
  end if
end

on send_BuddylistUpdate me
  if not pPaused then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send(#info, "MESSENGER_SENDUPDATE")
    end if
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

on getsmsAccount me
  return pItemList[#smsAccount]
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

on getProfileData me
  return pProfileData
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
