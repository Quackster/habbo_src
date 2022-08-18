property pBuddyList, pTimeOutID, pReadyFlag, pItemList, pPaused

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
  pItemList = [#messages:[:], #msgCount:[:], #newBuddyRequest:[], #persistenMsg:""]
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

on receive_MessengerReady me, tMsg 
  pReadyFlag = 1
  createTimeout(pTimeOutID, getIntVariable("messenger.updatetime.buddylist", 120000), #send_BuddylistUpdate, me.getID(), void(), 0)
  executeMessage(#messenger_ready)
end

on receive_BuddyList me, ttype, tList 
  if (ttype = #new) then
    pBuddyList.setaProp(#value, tList)
    me.getInterface().createBuddyList(pBuddyList)
  else
    if (ttype = #update) then
      if (tList.count(#buddies) = 0) then
        return FALSE
      end if
      tTheBuddyList = pBuddyList.getaProp(#value)
      i = 1
      repeat while i <= tList.count(#buddies)
        tBuddy = tList.getProp(#buddies, i)
        tCurrData = tTheBuddyList.buddies.getaProp(tBuddy.id)
        if voidp(tCurrData) then
          error(me, "Buddy not found:" & tBuddy.getAt(#name) & "Creating new struct.", #receive_BLUpdate)
          me.receive_AppendBuddy([#buddies:[tBuddy]])
        else
          j = 1
          repeat while j <= tCurrData.count
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
            if tTheBuddyList.offline.getOne(tBuddy.name) then
              tTheBuddyList.offline.deleteOne(tBuddy.name)
            end if
            if (tTheBuddyList.online.getOne(tBuddy.name) = 0) then
              tTheBuddyList.online.add(tBuddy.name)
            end if
          else
            if tTheBuddyList.online.getOne(tBuddy.name) then
              tTheBuddyList.online.deleteOne(tBuddy.name)
            end if
            if (tTheBuddyList.offline.getOne(tBuddy.name) = 0) then
              tTheBuddyList.offline.add(tBuddy.name)
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
  tdata = tdata.getProp(#buddies, 1)
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

on receive_RemoveBuddy me, tid 
  me.getInterface().removeBuddy(tid)
  tTheBuddyList = pBuddyList.getaProp(#value)
  tBuddy = tTheBuddyList.buddies.getaProp(tid)
  if voidp(tBuddy) then
    return(error(me, "Buddy not found:" && tid, #receive_RemoveBuddy))
  end if
  tTheBuddyList.buddies.deleteProp(tid)
  tTheBuddyList.online.deleteOne(tBuddy.name)
  tTheBuddyList.offline.deleteOne(tBuddy.name)
  tTheBuddyList.render.deleteOne(tBuddy.name)
  me.eraseMessagesBySenderID(tid)
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

on receive_BuddyRequest me, tMsg 
  pItemList.getAt(#newBuddyRequest).add(tMsg.getAt(#name))
  me.tellRequestCount()
  me.getInterface().updateFrontPage()
end

on receive_UserFound me, tMsg 
  me.getInterface().updateUserFind(tMsg, 1)
end

on receive_UserNotFound me, tMsg 
  me.getInterface().updateUserFind(tMsg, 0)
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

on send_MessageMarkRead me, tmessageId, tSenderId 
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
  if (tSenderId = "Campaign Msg") then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_C_READ", tmessageId)
  else
    getConnection(getVariable("connection.info.id")).send("MESSENGER_MARKREAD", tmessageId)
  end if
end

on send_Message me, tReceivers, tMsg 
  puppetSound(3, getmemnum("con_message_sent"))
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDMSG", tReceivers & "\r" & tMsg)
end

on send_EmailMessage me, tReceivers, tMsg 
  puppetSound(3, getmemnum("con_message_sent"))
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDEMAILMSG", tReceivers & "\r" & tMsg)
end

on send_PersistentMsg me, tMsg 
  tMsg = tMsg.getProp(#line, 1)
  if (tMsg = pItemList.getAt(#persistenMsg)) then
    return FALSE
  end if
  pItemList.setAt(#persistenMsg, tMsg)
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ASSIGNPERSMSG", tMsg)
end

on send_AcceptBuddy me, tBuddyName 
  if pItemList.getAt(#newBuddyRequest).count > 0 then
    if voidp(tBuddyName) then
      tBuddyName = pItemList.getAt(#newBuddyRequest).getAt(1)
      pItemList.getAt(#newBuddyRequest).deleteAt(1)
    end if
    me.tellRequestCount()
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", tBuddyName)
    end if
  end if
end

on send_DeclineBuddy me, tBuddyName 
  if pItemList.getAt(#newBuddyRequest).count > 0 then
    if voidp(tBuddyName) then
      tBuddyName = pItemList.getAt(#newBuddyRequest).getAt(1)
      pItemList.getAt(#newBuddyRequest).deleteAt(1)
    end if
    me.tellRequestCount()
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", tBuddyName)
    end if
  end if
end

on send_RequestBuddy me, tBuddyName 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REQUESTBUDDY", tBuddyName)
  end if
end

on send_RemoveBuddy me, tBuddyName 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_REMOVEBUDDY", tBuddyName)
  end if
end

on send_FindUser me, tName 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("FINDUSER", tName & "\t" & "MESSENGER")
  end if
end

on send_BuddylistUpdate me 
  if not pPaused then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDUPDATE")
    end if
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
