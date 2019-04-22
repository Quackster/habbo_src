on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_ok me, tMsg 
  return(tMsg.send("MESSENGERINIT"))
end

on handle_messenger_init me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tPersistentMsg = tConn.GetStrFrom()
  me.getComponent().receive_PersistentMsg(tPersistentMsg)
  tUserLimit = tConn.GetIntFrom()
  tNormalLimit = tConn.GetIntFrom()
  tExtendedLimit = tConn.GetIntFrom()
  me.getInterface().setBuddyListLimits(tUserLimit, tNormalLimit, tExtendedLimit)
  tConsoleInfo = me.get_console_info(tMsg)
  me.getComponent().receive_BuddyList(#new, tConsoleInfo.getAt(#buddies))
  repeat while tConsoleInfo.getAt(#campaign_messages) <= undefined
    tItem = getAt(undefined, tMsg)
    me.getComponent().receive_CampaignMsg(tItem)
  end repeat
  tComponent = me.getComponent()
  tComponent.send_AskForMessages()
  tComponent.send_AskForFriendRequests()
  return(tComponent.receive_MessengerReady("MESSENGERREADY"))
end

on handle_buddylist me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tBuddyData = [:]
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_user_info(tMsg)
    if tdata <> 0 then
      tBuddyData.addProp(string(tdata.getAt(#id)), tdata)
    end if
    i = 1 + i
  end repeat
  tBuddyList = me.get_sorted_buddy_list(tBuddyData)
  tBuddyList.setAt(#buddies, tBuddyData)
  me.getComponent().receive_BuddyList(#new, tBuddyList)
  return(1)
end

on handle_console_update me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tBuddyList = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_buddy_info(tMsg)
    if tdata <> 0 then
      tBuddyList.add(tdata)
    end if
    i = 1 + i
  end repeat
  me.getComponent().receive_BuddyList(#update, [#buddies:tBuddyList])
  return(1)
end

on handle_console_info me, tMsg 
  tConsoleInfo = me.get_console_info(tMsg)
  me.getComponent().receive_BuddyList(#new, tConsoleInfo.getAt(#buddies))
  repeat while tConsoleInfo.getAt(#console_messages) <= undefined
    tItem = getAt(undefined, tMsg)
    me.getComponent().receive_Message(tItem)
  end repeat
  repeat while tConsoleInfo.getAt(#console_messages) <= undefined
    tItem = getAt(undefined, tMsg)
    me.getComponent().receive_CampaignMsg(tItem)
  end repeat
  repeat while tConsoleInfo.getAt(#console_messages) <= undefined
    tItem = getAt(undefined, tMsg)
    me.getComponent().receive_BuddyRequest(tItem)
  end repeat
  return(1)
end

on handle_memberinfo me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tSearchId = tConn.GetStrFrom()
  if tSearchId <> "MESSENGER" then
    return(0)
  end if
  tdata = me.get_user_info(tMsg)
  if tdata = 0 then
    return(me.getComponent().receive_UserNotFound())
  end if
  tdata.setAt(#searchId, tSearchId)
  if objectExists("Figure_System") then
    tdata.setAt(#FigureData, getObject("Figure_System").parseFigure(tdata.getAt(#FigureData), tdata.getAt(#sex), "user"))
  end if
  return(me.getComponent().receive_UserFound(tdata))
end

on handle_buddy_request me, tMsg 
  tdata = me.get_buddy_request(tMsg)
  return(me.getComponent().receive_BuddyRequest([tdata]))
end

on handle_buddy_request_list me, tMsg 
  tConn = tMsg.connection
  tTotalFriendRequests = tConn.GetIntFrom()
  tFriendRequestCount = tConn.GetIntFrom()
  tRequests = []
  tRequestNo = 1
  repeat while tRequestNo <= tFriendRequestCount
    tRequests.add(me.get_buddy_request(tMsg))
    tRequestNo = 1 + tRequestNo
  end repeat
  if tTotalFriendRequests > tFriendRequestCount then
    me.getComponent().setFriendRequestUpdateRequired(1)
  else
    me.getComponent().setFriendRequestUpdateRequired(0)
  end if
  me.getComponent().receive_BuddyRequest(tRequests)
end

on handle_buddy_request_result me, tMsg 
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
  if tFailureCount < 1 then
    return(1)
  end if
  tNamesPerAlert = 10
  tNames = "\r"
  tNameNum = 1
  repeat while tNameNum <= tErrorList.count
    tNames = tNames & "\r" & tErrorList.getPropAt(tNameNum)
    if tErrorList.getAt(tNameNum) = 1 then
      tReason = getText("console_fr_limit_exceeded_error")
    else
      if tErrorList.getAt(tNameNum) = 2 then
        tReason = getText("console_target_friend_list_full")
      else
        if tErrorList.getAt(tNameNum) = 3 then
          tReason = getText("console_target_does_not_accept")
        else
          if tErrorList.getAt(tNameNum) = 4 then
            tReason = getText("console_friend_request_not_found")
          else
            if tErrorList.getAt(tNameNum) = 42 then
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
  return(1)
end

on handle_campaign_message me, tMsg 
  tdata = me.get_campaign_message(tMsg)
  return(me.getComponent().receive_CampaignMsg(tdata))
end

on handle_messenger_message me, tMsg 
  tdata = me.get_console_message(tMsg)
  if tdata <> 0 then
    me.getComponent().receive_Message(tdata)
  end if
  playSound("con_new_message", #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
  return(1)
end

on handle_messenger_messages me, tMsg 
  tTotalMessages = tMsg.GetIntFrom()
  tMessageCount = tMsg.GetIntFrom()
  if tTotalMessages > tMessageCount then
    me.getComponent().setMessageUpdateRequired(1)
  end if
  i = 1
  repeat while i <= tMessageCount
    tdata = me.get_console_message(tMsg)
    if tdata <> 0 then
      me.getComponent().receive_Message(tdata)
    end if
    i = 1 + i
  end repeat
  if tMessageCount > 1 then
    playSound("con_new_message", #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
  end if
  return(1)
end

on handle_add_buddy me, tMsg 
  tBuddyData = me.get_user_info(tMsg)
  tPendAcc = me.getComponent().getProp(#pItemList, #pendingBuddyAccept)
  if ilk(tPendAcc) = #propList then
    if tPendAcc.getAt(#name) = tBuddyData.getAt(#name) then
      me.getComponent().setProp(#pItemList, #pendingBuddyAccept, "")
    end if
  end if
  return(me.getComponent().receive_AppendBuddy([#buddies:tBuddyData]))
end

on handle_remove_buddy me, tMsg 
  tdata = me.get_user_list(tMsg)
  return(me.getComponent().receive_RemoveBuddies(tdata))
end

on handle_mypersistentmessage me, tMsg 
  tConnection = tMsg.connection
  tText = tConnection.GetStrFrom()
  return(me.getComponent().receive_PersistentMsg(tText))
end

on handle_messenger_error me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tClientMessageId = tConn.GetIntFrom()
  tErrorCode = tConn.GetIntFrom()
  if tErrorCode = 0 then
    return(error(me, "Undefined messenger error!", #handle_messenger_error, #major))
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
            if tReason = 1 then
              tItems = me.getComponent().pItemList
              tItems.getAt(#newBuddyRequest).addAt(1, tItems.getAt(#pendingBuddyAccept))
              tItems.setAt(#pendingBuddyAccept, "")
              me.getComponent().tellRequestCount()
              me.getInterface().updateFrontPage()
              return(me.getInterface().openBuddyMassremoveWindow())
            else
              if tReason = 2 then
                executeMessage(#alert, [#Msg:"console_buddylimit_requester", #modal:1])
              else
                if tReason = 42 then
                  return(me.getComponent().handleFriendlistConcurrency())
                end if
              end if
            end if
          else
            if tErrorCode = 39 then
              return(me.getInterface().openBuddyMassremoveWindow())
            else
              if tErrorCode = 42 then
                return(executeMessage(#alert, [#Msg:getText("console_concurrency_error")]))
              else
                return(error(me, "Messenger error, failed c->s message:" && tErrorCode && "Triggered by message:" && tClientMessageId, #handle_messenger_error, #major))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on get_console_info me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tResult = [:]
  tBuddyData = [:]
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_user_info(tMsg)
    if tdata <> 0 then
      tBuddyData.addProp(string(tdata.getAt(#id)), tdata)
    end if
    i = 1 + i
  end repeat
  tBuddyList = me.get_sorted_buddy_list(tBuddyData)
  tBuddyList.setAt(#buddies, tBuddyData)
  tResult.addProp(#buddies, tBuddyList)
  tResult.setAt(#request_limit, tConn.GetIntFrom())
  tResult.setAt(#request_count, tConn.GetIntFrom())
  tResult.setAt(#message_limit, tConn.GetIntFrom())
  tResult.setAt(#message_count, tConn.GetIntFrom())
  tResult.setAt(#campaign_message_count, tConn.GetIntFrom())
  tList = []
  tLoopCount = tResult.getAt(#campaign_message_count)
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_campaign_message(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
    i = 1 + i
  end repeat
  tResult.addProp(#campaign_messages, tList)
  return(tResult)
end

on get_sorted_buddy_list me, tBuddyData 
  tSortedList = [#online:[], #offline:[], #render:[]]
  i = 1
  repeat while i <= tBuddyData.count
    if tBuddyData.getAt(i).getAt(#online) then
      tSortedList.getAt(#online).add(tBuddyData.getAt(i).getAt(#name))
    else
      tSortedList.getAt(#offline).add(tBuddyData.getAt(i).getAt(#name))
    end if
    i = 1 + i
  end repeat
  tSortedList.getAt(#online).sort()
  tSortedList.getAt(#offline).sort()
  i = 1
  repeat while i <= tSortedList.getAt(#online).count
    tSortedList.getAt(#render).add(tSortedList.getAt(#online).getAt(i))
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tSortedList.getAt(#offline).count
    tSortedList.getAt(#render).add(tSortedList.getAt(#offline).getAt(i))
    i = 1 + i
  end repeat
  return(tSortedList)
end

on get_buddy_info me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#customText, tConn.GetStrFrom())
  tdata.setAt(#online, tConn.GetIntFrom())
  if tdata.getAt(#online) then
    tdata.setAt(#location, tConn.GetStrFrom())
    tdata.setAt(#lastAccess, "")
  else
    tdata.setAt(#location, "")
    tdata.setAt(#lastAccess, tConn.GetStrFrom())
  end if
  return(tdata)
end

on get_user_info me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  if tdata.getAt(#id) = "0" then
    return(0)
  end if
  tdata.setAt(#name, tConn.GetStrFrom())
  if tConn.GetIntFrom() = 0 then
    tdata.setAt(#sex, "F")
  else
    tdata.setAt(#sex, "M")
  end if
  tdata.setAt(#customText, tConn.GetStrFrom())
  tdata.setAt(#online, tConn.GetIntFrom())
  tdata.setAt(#location, tConn.GetStrFrom())
  tdata.setAt(#lastAccess, tConn.GetStrFrom())
  tdata.setAt(#FigureData, tConn.GetStrFrom())
  tdata.setAt(#msgs, 0)
  tdata.setAt(#update, 1)
  return(tdata)
end

on get_console_message me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#senderID, string(tConn.GetIntFrom()))
  tdata.setAt(#time, tConn.GetStrFrom())
  tdata.setAt(#message, tConn.GetStrFrom())
  return(tdata)
end

on get_campaign_message me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [#campaign:1]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#url, tConn.GetStrFrom())
  tdata.setAt(#link, tConn.GetStrFrom())
  tdata.setAt(#message, tConn.GetStrFrom())
  return(tdata)
end

on get_buddy_request me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#name, tConn.GetStrFrom())
  tdata.setAt(#webID, tConn.GetStrFrom())
  return(tdata)
end

on get_user_list me, tMsg 
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tdata = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata.add(string(tConn.GetIntFrom()))
    i = 1 + i
  end repeat
  return(tdata)
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(3, #handle_ok)
  tMsgs.setaProp(12, #handle_messenger_init)
  tMsgs.setaProp(13, #handle_console_update)
  tMsgs.setaProp(128, #handle_memberinfo)
  tMsgs.setaProp(132, #handle_buddy_request)
  tMsgs.setaProp(133, #handle_campaign_message)
  tMsgs.setaProp(134, #handle_messenger_message)
  tMsgs.setaProp(137, #handle_add_buddy)
  tMsgs.setaProp(138, #handle_remove_buddy)
  tMsgs.setaProp(147, #handle_mypersistentmessage)
  tMsgs.setaProp(260, #handle_messenger_error)
  tMsgs.setaProp(263, #handle_buddylist)
  tMsgs.setaProp(313, #handle_messenger_messages)
  tMsgs.setaProp(314, #handle_buddy_request_list)
  tMsgs.setaProp(315, #handle_buddy_request_result)
  tCmds = [:]
  tCmds.setaProp("MESSENGERINIT", 12)
  tCmds.setaProp("MESSENGER_UPDATE", 15)
  tCmds.setaProp("MESSENGER_C_CLICK", 30)
  tCmds.setaProp("MESSENGER_C_READ", 31)
  tCmds.setaProp("MESSENGER_MARKREAD", 32)
  tCmds.setaProp("MESSENGER_SENDMSG", 33)
  tCmds.setaProp("MESSENGER_ASSIGNPERSMSG", 36)
  tCmds.setaProp("MESSENGER_ACCEPTBUDDY", 37)
  tCmds.setaProp("MESSENGER_DECLINEBUDDY", 38)
  tCmds.setaProp("MESSENGER_REQUESTBUDDY", 39)
  tCmds.setaProp("MESSENGER_REMOVEBUDDY", 40)
  tCmds.setaProp("FINDUSER", 41)
  tCmds.setaProp("MESSENGER_GETMESSAGES", 191)
  tCmds.setaProp("MESSENGER_REPORTMESSAGE", 201)
  tCmds.setaProp("GET_BUDDY_REQUESTS", 233)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
end
