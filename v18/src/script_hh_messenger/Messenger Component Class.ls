property pBuddyList, pTimeOutID, pReadyFlag, pItemList, pUpdateBuddiesInterval, pPaused, pLastBuddiesUpdateTime

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
  pState = void()
  pPaused = 0
  pTimeOutID = #messenger_msg_poller
  pReadyFlag = 0
  pBuddyList = getStructVariable("struct.pointer")
  pItemList = [#messages:[:], #msgCount:[:], #newBuddyRequest:[], #pendingBuddyAccept:"", #persistenMsg:""]
  pUpdateBuddiesInterval = getIntVariable("messenger.updatetime.buddylist", 120000)
  pLastBuddiesUpdateTime = 0
  pBuddyList.setProp(#value, [#buddies:[:], #online:[], #offline:[], #render:[]])
  me.getInterface().createBuddyList(pBuddyList)
  executeMessage(#messenger_ready, #messenger)
  return TRUE
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
  return TRUE
end

on showMessenger me 
  if not pReadyFlag then
    return(error(me, "Messenger not ready yet..", #showMessenger))
  end if
  return(me.getInterface().showMessenger())
end

on hideMessenger me 
  if not pReadyFlag then
    return(error(me, "Messenger not ready yet..", #hideMessenger))
  end if
  return(me.getInterface().hideMessenger())
end

on showhidemessenger me 
  if not pReadyFlag then
    return(error(me, "Messenger not ready yet..", #showhidemessenger))
  end if
  return(me.getInterface().showhidemessenger())
end

on deleteAllMessages me 
  pItemList.messages = [:]
  pItemList.msgCount = [:]
  me.tellMessageCount()
  return TRUE
end

on receive_MessengerReady me, tMsg 
  pReadyFlag = 1
  createTimeout(pTimeOutID, pUpdateBuddiesInterval, #send_BuddylistUpdate, me.getID(), void(), 0)
  return(executeMessage(#messenger_ready))
end

on receive_BuddyList me, ttype, tList 
  me.getInterface().setMessengerActive()
  if (ttype = #new) then
    pBuddyList.setaProp(#value, tList)
    me.getInterface().createBuddyList(pBuddyList)
  else
    if (ttype = #update) then
      if (tList.buddies = void()) then
        return FALSE
      end if
      if (tList.count(#buddies) = 0) then
        return FALSE
      end if
      tTheBuddyList = pBuddyList.getaProp(#value)
      i = 1
      repeat while i <= tList.count(#buddies)
        tBuddy = tList.getProp(#buddies, i)
        tCurrData = tTheBuddyList.buddies.getaProp(tBuddy.id)
        if voidp(tCurrData) then
          error(me, "Buddy not found:" & tBuddy.getAt(#id) & " - Rejecting update.", #receive_BuddyList)
        else
          j = 1
          repeat while j <= tBuddy.count
            tKey = tBuddy.getPropAt(j)
            tValue = tBuddy.getAt(j)
            tCurrData.setAt(tKey, tValue)
            j = (1 + j)
          end repeat
          tMsgList = pItemList.messages.getaProp(tBuddy.getAt(#id))
          if listp(tMsgList) then
            tCurrData.setAt(#msgs, tMsgList.count)
          end if
          if tBuddy.online then
            if tTheBuddyList.offline.getOne(tCurrData.getAt(#name)) then
              tTheBuddyList.offline.deleteOne(tCurrData.getAt(#name))
            end if
            if (tTheBuddyList.online.getOne(tCurrData.getAt(#name)) = 0) then
              tTheBuddyList.online.add(tCurrData.getAt(#name))
            end if
          else
            if tTheBuddyList.online.getOne(tCurrData.getAt(#name)) then
              tTheBuddyList.online.deleteOne(tCurrData.getAt(#name))
            end if
            if (tTheBuddyList.offline.getOne(tCurrData.getAt(#name)) = 0) then
              tTheBuddyList.offline.add(tCurrData.getAt(#name))
            end if
          end if
        end if
        i = (1 + i)
      end repeat
      tTheBuddyList.render = []
      repeat while ttype <= tList
        tName = getAt(tList, ttype)
        tTheBuddyList.render.add(tName)
      end repeat
      repeat while ttype <= tList
        tName = getAt(tList, ttype)
        tTheBuddyList.render.add(tName)
      end repeat
      me.getInterface().updateBuddyList()
    end if
  end if
end

on receive_AppendBuddy me, tdata 
  if not listp(tdata) then
    return FALSE
  end if
  if tdata.count < 1 then
    return FALSE
  end if
  tdata = tdata.buddies
  tTheBuddyList = pBuddyList.getaProp(#value)
  tTheBuddyList.buddies.setaProp(tdata.getAt(#id), tdata)
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
  repeat while tTheBuddyList.online <= undefined
    tName = getAt(undefined, tdata)
    tTheBuddyList.render.add(tName)
  end repeat
  repeat while tTheBuddyList.online <= undefined
    tName = getAt(undefined, tdata)
    tTheBuddyList.render.add(tName)
  end repeat
  me.getInterface().appendBuddy(tdata)
end

on receive_RemoveBuddies me, tList 
  if not me.getInterface().isMessengerActive() then
    if objectExists("buddy_massremove") then
      getObject("buddy_massremove").confirmationReceived()
    end if
    return TRUE
  end if
  repeat while tList <= undefined
    tID = getAt(undefined, tList)
    me.getInterface().removeBuddy(tID)
    tTheBuddyList = pBuddyList.getaProp(#value)
    tTheBuddyList.sort()
    tBuddy = tTheBuddyList.buddies.getaProp(tID)
    if voidp(tBuddy) then
      return(error(me, "Buddy not found:" && tID, #receive_RemoveBuddies))
    end if
    tBuddyName = tBuddy.name
    tTheBuddyList.buddies.deleteProp(tID)
    tTheBuddyList.online.deleteOne(tBuddyName)
    tTheBuddyList.offline.deleteOne(tBuddyName)
    tTheBuddyList.render.deleteOne(tBuddyName)
    me.eraseMessagesBySenderID(tID)
  end repeat
  return TRUE
end

on receive_PersistentMsg me, tMsg 
  pItemList.setAt(#persistenMsg, tMsg)
end

on receive_Message me, tMsg 
  if voidp(pItemList.getAt(#messages).getaProp(tMsg.getAt(#senderID))) then
    pItemList.getAt(#messages).setaProp(tMsg.getAt(#senderID), [:])
  end if
  pItemList.getAt(#messages).getaProp(tMsg.getAt(#senderID)).setaProp(tMsg.getAt(#id), tMsg)
  if voidp(pItemList.getAt(#msgCount).getAt(#allmsg)) then
    pItemList.getAt(#msgCount).setAt(#allmsg, 1)
  else
    pItemList.getAt(#msgCount).setAt(#allmsg, (pItemList.getAt(#msgCount).getAt(#allmsg) + 1))
  end if
  tSender = pBuddyList.getaProp(#value).buddies.getaProp(tMsg.getAt(#senderID))
  if not voidp(tSender) then
    tSender.setaProp(#msgs, (tSender.getaProp(#msgs) + 1))
    tSender.setaProp(#update, 1)
  end if
  if voidp(pItemList.getAt(#msgCount).getaProp(tMsg.getAt(#senderID))) then
    pItemList.getAt(#msgCount).setaProp(tMsg.getAt(#senderID), 1)
  else
    pItemList.getAt(#msgCount).setaProp(tMsg.getAt(#senderID), (pItemList.getAt(#msgCount).getaProp(tMsg.getAt(#senderID)) + 1))
  end if
  me.getInterface().updateBuddyList()
  me.tellMessageCount()
  puppetSound(3, getmemnum("con_new_message"))
  me.getInterface().updateFrontPage()
end

on receive_BuddyRequest me, tdata 
  pItemList.getAt(#newBuddyRequest).add(tdata)
  me.tellRequestCount()
  return(me.getInterface().updateFrontPage())
end

on receive_UserFound me, tMsg 
  me.getInterface().updateUserFind(tMsg, 1)
end

on receive_UserNotFound me, tMsg 
  me.getInterface().updateUserFind(void(), 0)
end

on receive_CampaignMsg me, tMsg 
  if (tMsg.getAt(#message).getProp(#char, 1, 12) = "[dialog_msg]") then
    if memberExists(tMsg.getAt(#link) && "Class") then
      tObjID = getUniqueID()
      if not createObject(tObjID, tMsg.getAt(#link) && "Class") then
        return(error(me, "Failed to initialize class:" && tMsg.getAt(#link), #receive_CampaignMsg))
      end if
      call(#assignCampaignID, [getObject(tObjID)], tMsg.getAt(#id))
      return TRUE
    end if
  end if
  me.receive_Message(tMsg)
end

on send_MessageMarkRead me, tmessageId, tSenderId, tCampaignFlag 
  me.decreaseMsgCount(tSenderId)
  if pItemList.getAt(#messages).count > 0 then
    if not voidp(pItemList.getAt(#messages).getaProp(tSenderId)) then
      pItemList.getAt(#messages).getaProp(tSenderId).deleteProp(tmessageId)
      if (pItemList.getAt(#messages).getaProp(tSenderId).count = 0) then
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
end

on send_Message me, tReceivers, tMsg 
  if not listp(tReceivers) then
    return FALSE
  end if
  puppetSound(3, getmemnum("con_message_sent"))
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  tdata = [#integer:tReceivers.count]
  repeat while tReceivers <= tMsg
    tReceiver = getAt(tMsg, tReceivers)
    tdata.addProp(#integer, integer(tReceiver.getAt(#id)))
  end repeat
  tdata.addProp(#string, tMsg)
  return(getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDMSG", tdata))
end

on send_PersistentMsg me, tMsg 
  tMsg = tMsg.getProp(#line, 1)
  if (tMsg = pItemList.getAt(#persistenMsg)) then
    return FALSE
  end if
  pItemList.setAt(#persistenMsg, tMsg)
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ASSIGNPERSMSG", [#string:tMsg])
end

on send_AcceptBuddy me 
  if pItemList.getAt(#newBuddyRequest).count > 0 then
    tBuddyID = pItemList.getAt(#newBuddyRequest).getAt(1).getAt(#id)
    pItemList.setAt(#pendingBuddyAccept, pItemList.getAt(#newBuddyRequest).getAt(1))
    pItemList.getAt(#newBuddyRequest).deleteAt(1)
    me.tellRequestCount()
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", [#integer:integer(tBuddyID)])
    end if
  end if
end

on send_DeclineBuddy me, ttype 
  if not connectionExists(getVariable("connection.info.id")) then
    return FALSE
  end if
  if (ttype = #all) then
    pItemList.setAt(#newBuddyRequest, [])
    me.tellRequestCount()
    me.getInterface().updateFrontPage()
    return(getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", [#integer:0]))
  else
    if (ttype = #one) and pItemList.getAt(#newBuddyRequest).count > 0 then
      tBuddyID = pItemList.getAt(#newBuddyRequest).getAt(1).getAt(#id)
      pItemList.getAt(#newBuddyRequest).deleteAt(1)
      me.tellRequestCount()
      return(getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", [#integer:1, #integer:integer(tBuddyID)]))
    end if
  end if
end

on send_RequestBuddy me, tBuddyName 
  if (tBuddyName = void()) or (tBuddyName = "") then
    return TRUE
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REQUESTBUDDY", [#string:tBuddyName])
  end if
end

on send_RemoveBuddy me, tBuddyID 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REMOVEBUDDY", [#integer:1, #integer:integer(tBuddyID)])
  end if
end

on send_reportMessage me, tMsgId 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REPORTMESSAGE", [#integer:integer(tMsgId)])
  end if
end

on send_FindUser me, tName 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FINDUSER", [#string:tName, #string:"MESSENGER"])
  end if
end

on send_BuddylistUpdate me 
  if not pPaused then
    tWindow = me.getInterface().pOpenWindow
    if (tWindow = "") then
      return FALSE
    end if
    if (pLastBuddiesUpdateTime + pUpdateBuddiesInterval) > the milliSeconds then
      return FALSE
    end if
    pLastBuddiesUpdateTime = the milliSeconds
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE")
    end if
  end if
end

on send_AskForMessages me 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_GETMESSAGES", [#integer:1])
  end if
end

on getBuddyData me 
  return(pBuddyList.getaProp(#value))
end

on getNumOfMessages me 
  if voidp(pItemList.getAt(#msgCount).getAt(#allmsg)) then
    return FALSE
  else
    return(pItemList.getAt(#msgCount).getAt(#allmsg))
  end if
end

on getNumOfBuddyRequest me 
  return(pItemList.getAt(#newBuddyRequest).count)
end

on getMyPersistenMsg me 
  return(pItemList.getAt(#persistenMsg))
end

on getNextBuddyRequest me 
  if pItemList.getAt(#newBuddyRequest).count < 1 then
    return("")
  else
    return(pItemList.getAt(#newBuddyRequest).getAt(1))
  end if
end

on getNextMessage me 
  if pItemList.getAt(#messages).count > 0 then
    tSenderId = pItemList.getAt(#messages).getAt(1).getAt(1).getAt(#senderID)
    return(pItemList.getAt(#messages).getAt(1).getAt(1))
  end if
end

on getMessageBySenderId me, tSenderId 
  if pItemList.getAt(#messages).count > 0 then
    if not stringp(tSenderId) then
      tSenderId = string(tSenderId)
    end if
    if not voidp(pItemList.getAt(#messages).getAt(tSenderId)) then
      return(pItemList.getAt(#messages).getAt(tSenderId).getAt(1))
    end if
  end if
end

on eraseMessagesBySenderID me, tSenderId 
  tMsgCount = 0
  if pItemList.getAt(#messages).count > 0 then
    if not voidp(pItemList.getAt(#messages).getaProp(tSenderId)) then
      tMsgCount = pItemList.getAt(#messages).getAt(tSenderId).count
      pItemList.getAt(#messages).deleteProp(tSenderId)
    end if
  end if
  pItemList.getAt(#msgCount).setAt(tSenderId, 0)
  pItemList.getAt(#msgCount).setAt(#allmsg, (pItemList.getAt(#msgCount).getAt(#allmsg) - tMsgCount))
  me.tellMessageCount()
  me.getInterface().updateFrontPage()
end

on decreaseMsgCount me, tSenderId 
  pItemList.getAt(#msgCount).setaProp(tSenderId, (pItemList.getAt(#msgCount).getaProp(tSenderId) - 1))
  if pItemList.getAt(#msgCount).getaProp(tSenderId) < 0 then
    pItemList.getAt(#msgCount).setaProp(tSenderId, 0)
  end if
  pItemList.getAt(#msgCount).setAt(#allmsg, (pItemList.getAt(#msgCount).getAt(#allmsg) - 1))
  if pItemList.getAt(#msgCount).getAt(#allmsg) < 0 then
    pItemList.getAt(#msgCount).setAt(#allmsg, 0)
  end if
  tBuddy = pBuddyList.getaProp(#value).buddies.getaProp(tSenderId)
  if not voidp(tBuddy) then
    tMsgCount = tBuddy.getaProp(#msgs)
    if tMsgCount > 0 then
      tBuddy.setaProp(#msgs, (tMsgCount - 1))
      tBuddy.setaProp(#update, 1)
    end if
  end if
  me.tellMessageCount()
end

on tellMessageCount me 
  return(executeMessage(#updateMessageCount, me.getNumOfMessages()))
end

on tellRequestCount me 
  return(executeMessage(#updateBuddyrequestCount, me.getNumOfBuddyRequest()))
end

on externalBuddyRequest me, tTargetUser 
  me.send_RequestBuddy(tTargetUser)
  me.getInterface().showMessenger()
  me.getInterface().setProp(#pLastSearch, #name, tTargetUser)
  me.getInterface().ChangeWindowView("console_sentrequest.window")
end

on pause me 
  pPaused = 1
  return TRUE
end

on resume me 
  pPaused = 0
  return TRUE
end

on handleFriendlistConcurrency me 
  executeMessage(#alert, [#Msg:"console_buddylist_concurrency", #modal:1])
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE", [#integer:0])
  end if
end
