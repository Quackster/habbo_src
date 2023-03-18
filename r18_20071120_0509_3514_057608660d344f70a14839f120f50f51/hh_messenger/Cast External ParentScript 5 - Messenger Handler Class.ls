on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_ok me, tMsg
  return tMsg.connection.send("MESSENGERINIT")
end

on handle_messenger_init me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tPersistentMsg = tConn.GetStrFrom()
  me.getComponent().receive_PersistentMsg(tPersistentMsg)
  tUserLimit = tConn.GetIntFrom()
  tNormalLimit = tConn.GetIntFrom()
  tExtendedLimit = tConn.GetIntFrom()
  me.getInterface().setBuddyListLimits(tUserLimit, tNormalLimit, tExtendedLimit)
  tConsoleInfo = me.get_console_info(tMsg)
  me.getComponent().receive_BuddyList(#new, tConsoleInfo[#buddies])
  repeat with tItem in tConsoleInfo[#console_messages]
    me.getComponent().receive_Message(tItem)
  end repeat
  repeat with tItem in tConsoleInfo[#campaign_messages]
    me.getComponent().receive_CampaignMsg(tItem)
  end repeat
  repeat with tItem in tConsoleInfo[#buddy_requests]
    me.getComponent().receive_BuddyRequest(tItem)
  end repeat
  return me.getComponent().receive_MessengerReady("MESSENGERREADY")
end

on handle_buddylist me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tBuddyData = [:]
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_user_info(tMsg)
    if tdata <> 0 then
      tBuddyData.addProp(string(tdata[#id]), tdata)
    end if
  end repeat
  tBuddyList = me.get_sorted_buddy_list(tBuddyData)
  tBuddyList[#buddies] = tBuddyData
  me.getComponent().receive_BuddyList(#new, tBuddyList)
  return 1
end

on handle_console_update me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tBuddyList = []
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_buddy_info(tMsg)
    if tdata <> 0 then
      tBuddyList.add(tdata)
    end if
  end repeat
  me.getComponent().receive_BuddyList(#update, [#buddies: tBuddyList])
  return 1
end

on handle_console_info me, tMsg
  tConsoleInfo = me.get_console_info(tMsg)
  me.getComponent().receive_BuddyList(#new, tConsoleInfo[#buddies])
  repeat with tItem in tConsoleInfo[#console_messages]
    me.getComponent().receive_Message(tItem)
  end repeat
  repeat with tItem in tConsoleInfo[#campaign_messages]
    me.getComponent().receive_CampaignMsg(tItem)
  end repeat
  repeat with tItem in tConsoleInfo[#buddy_requests]
    me.getComponent().receive_BuddyRequest(tItem)
  end repeat
  return 1
end

on handle_memberinfo me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tSearchId = tConn.GetStrFrom()
  if tSearchId <> "MESSENGER" then
    return 0
  end if
  tdata = me.get_user_info(tMsg)
  if tdata = 0 then
    return me.getComponent().receive_UserNotFound()
  end if
  tdata[#searchId] = tSearchId
  if objectExists("Figure_System") then
    tdata[#FigureData] = getObject("Figure_System").parseFigure(tdata[#FigureData], tdata[#sex], "user")
  end if
  return me.getComponent().receive_UserFound(tdata)
end

on handle_buddy_request me, tMsg
  tdata = me.get_buddy_request(tMsg)
  return me.getComponent().receive_BuddyRequest(tdata)
end

on handle_campaign_message me, tMsg
  tdata = me.get_campaign_message(tMsg)
  return me.getComponent().receive_CampaignMsg(tdata)
end

on handle_messenger_messages me, tMsg
  tLoopCount = tMsg.connection.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_console_message(tMsg)
    if tdata <> 0 then
      me.getComponent().receive_Message(tdata)
    end if
  end repeat
  return 1
end

on handle_add_buddy me, tMsg
  tBuddyData = me.get_user_info(tMsg)
  tPendAcc = me.getComponent().pItemList[#pendingBuddyAccept]
  if ilk(tPendAcc) = #propList then
    if tPendAcc[#name] = tBuddyData[#name] then
      me.getComponent().pItemList[#pendingBuddyAccept] = EMPTY
    end if
  end if
  return me.getComponent().receive_AppendBuddy([#buddies: tBuddyData])
end

on handle_remove_buddy me, tMsg
  tdata = me.get_user_list(tMsg)
  return me.getComponent().receive_RemoveBuddies(tdata)
end

on handle_mypersistentmessage me, tMsg
  tConnection = tMsg.connection
  tText = tConnection.GetStrFrom()
  return me.getComponent().receive_PersistentMsg(tText)
end

on handle_messenger_error me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tErrorCode = tConn.GetIntFrom()
  case tErrorCode of
    0:
      return error(me, "Undefined messenger error!", #handle_messenger_error)
    37:
      tReason = tConn.GetIntFrom()
      if tReason = 1 then
        tItems = me.getComponent().pItemList
        tItems[#newBuddyRequest].addAt(1, tItems[#pendingBuddyAccept])
        tItems[#pendingBuddyAccept] = EMPTY
        me.getComponent().tellRequestCount()
        me.getInterface().updateFrontPage()
        return me.getInterface().openBuddyMassremoveWindow()
      else
        if tReason = 2 then
          executeMessage(#alert, [#Msg: "console_buddylimit_requester", #modal: 1])
        else
          if tReason = 42 then
            return me.getComponent().handleFriendlistConcurrency()
          end if
        end if
      end if
    39:
      return me.getInterface().openBuddyMassremoveWindow()
    40:
      tReason = tConn.GetIntFrom()
      if tReason = 42 then
        return me.getComponent().handleFriendlistConcurrency()
      end if
    otherwise:
      return error(me, "Messenger error, failed c->s message:" && tErrorCode, #handle_messenger_error)
  end case
  return 1
end

on get_console_info me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tResult = [:]
  tBuddyData = [:]
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_user_info(tMsg)
    if tdata <> 0 then
      tBuddyData.addProp(string(tdata[#id]), tdata)
    end if
  end repeat
  tBuddyList = me.get_sorted_buddy_list(tBuddyData)
  tBuddyList[#buddies] = tBuddyData
  tResult.addProp(#buddies, tBuddyList)
  tList = []
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_console_message(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
  end repeat
  tResult.addProp(#console_messages, tList)
  tList = []
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_campaign_message(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
  end repeat
  tResult.addProp(#campaign_messages, tList)
  tList = []
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata = me.get_buddy_request(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
  end repeat
  tResult.addProp(#buddy_requests, tList)
  return tResult
end

on get_sorted_buddy_list me, tBuddyData
  tSortedList = [#online: [], #offline: [], #render: []]
  repeat with i = 1 to tBuddyData.count
    if tBuddyData[i][#online] then
      tSortedList[#online].add(tBuddyData[i][#name])
      next repeat
    end if
    tSortedList[#offline].add(tBuddyData[i][#name])
  end repeat
  tSortedList[#online].sort()
  tSortedList[#offline].sort()
  repeat with i = 1 to tSortedList[#online].count
    tSortedList[#render].add(tSortedList[#online][i])
  end repeat
  repeat with i = 1 to tSortedList[#offline].count
    tSortedList[#render].add(tSortedList[#offline][i])
  end repeat
  return tSortedList
end

on get_buddy_info me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tdata = [:]
  tdata[#id] = string(tConn.GetIntFrom())
  tdata[#customText] = tConn.GetStrFrom()
  tdata[#online] = tConn.GetIntFrom()
  if tdata[#online] then
    tdata[#location] = tConn.GetStrFrom()
    tdata[#lastAccess] = EMPTY
  else
    tdata[#location] = EMPTY
    tdata[#lastAccess] = tConn.GetStrFrom()
  end if
  return tdata
end

on get_user_info me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tdata = [:]
  tdata[#id] = string(tConn.GetIntFrom())
  if tdata[#id] = "0" then
    return 0
  end if
  tdata[#name] = tConn.GetStrFrom()
  if tConn.GetIntFrom() = 0 then
    tdata[#sex] = "F"
  else
    tdata[#sex] = "M"
  end if
  tdata[#customText] = tConn.GetStrFrom()
  tdata[#online] = tConn.GetIntFrom()
  tdata[#location] = tConn.GetStrFrom()
  tdata[#lastAccess] = tConn.GetStrFrom()
  tdata[#FigureData] = tConn.GetStrFrom()
  tdata[#msgs] = 0
  tdata[#update] = 1
  return tdata
end

on get_console_message me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tdata = [:]
  tdata[#id] = string(tConn.GetIntFrom())
  tdata[#senderID] = string(tConn.GetIntFrom())
  tdata[#time] = tConn.GetStrFrom()
  tdata[#message] = tConn.GetStrFrom()
  return tdata
end

on get_campaign_message me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tdata = [#campaign: 1]
  tdata[#id] = string(tConn.GetIntFrom())
  tdata[#url] = tConn.GetStrFrom()
  tdata[#link] = tConn.GetStrFrom()
  tdata[#message] = tConn.GetStrFrom()
  return tdata
end

on get_buddy_request me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tdata = [:]
  tdata[#id] = string(tConn.GetIntFrom())
  tdata[#name] = tConn.GetStrFrom()
  return tdata
end

on get_user_list me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tdata = []
  tLoopCount = tConn.GetIntFrom()
  repeat with i = 1 to tLoopCount
    tdata.add(string(tConn.GetIntFrom()))
  end repeat
  return tdata
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(3, #handle_ok)
  tMsgs.setaProp(12, #handle_messenger_init)
  tMsgs.setaProp(13, #handle_console_update)
  tMsgs.setaProp(128, #handle_memberinfo)
  tMsgs.setaProp(132, #handle_buddy_request)
  tMsgs.setaProp(133, #handle_campaign_message)
  tMsgs.setaProp(134, #handle_messenger_messages)
  tMsgs.setaProp(137, #handle_add_buddy)
  tMsgs.setaProp(138, #handle_remove_buddy)
  tMsgs.setaProp(147, #handle_mypersistentmessage)
  tMsgs.setaProp(260, #handle_messenger_error)
  tMsgs.setaProp(263, #handle_buddylist)
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
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
