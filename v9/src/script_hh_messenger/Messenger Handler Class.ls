on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_ok me, tMsg 
  return(tMsg.connection.send("MESSENGERINIT"))
end

on handle_messenger_init me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tPersistentMsg = tConn.GetStrFrom()
  me.getComponent().receive_PersistentMsg(tPersistentMsg)
  tUserLimit = tConn.GetIntFrom()
  tNormalLimit = tConn.GetIntFrom()
  tExtendedLimit = tConn.GetIntFrom()
  me.getInterface().setBuddyListLimits(tUserLimit, tNormalLimit, tExtendedLimit)
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
  return(me.getComponent().receive_MessengerReady("MESSENGERREADY"))
end

on handle_buddylist me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tBuddyData = [:]
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_user_info(tMsg)
    if tdata <> 0 then
      tBuddyData.addProp(string(tdata.getAt(#id)), tdata)
    end if
    i = (1 + i)
  end repeat
  tBuddyList = me.get_sorted_buddy_list(tBuddyData)
  tBuddyList.setAt(#buddies, tBuddyData)
  me.getComponent().receive_BuddyList(#new, tBuddyList)
  return TRUE
end

on handle_console_update me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tBuddyList = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_buddy_info(tMsg)
    if tdata <> 0 then
      tBuddyList.add(tdata)
    end if
    i = (1 + i)
  end repeat
  me.getComponent().receive_BuddyList(#update, [#buddies:tBuddyList])
  return TRUE
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
  return TRUE
end

on handle_memberinfo me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tSearchId = tConn.GetStrFrom()
  if tSearchId <> "MESSENGER" then
    return FALSE
  end if
  tdata = me.get_user_info(tMsg)
  if (tdata = 0) then
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
  return(me.getComponent().receive_BuddyRequest(tdata))
end

on handle_campaign_message me, tMsg 
  tdata = me.get_campaign_message(tMsg)
  return(me.getComponent().receive_CampaignMsg(tdata))
end

on handle_messenger_messages me, tMsg 
  tLoopCount = tMsg.connection.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_console_message(tMsg)
    if tdata <> 0 then
      me.getComponent().receive_Message(tdata)
    end if
    i = (1 + i)
  end repeat
  return TRUE
end

on handle_add_buddy me, tMsg 
  tBuddyData = me.get_user_info(tMsg)
  tPendAcc = me.getComponent().getProp(#pItemList, #pendingBuddyAccept)
  if (ilk(tPendAcc) = #propList) then
    if (tPendAcc.getAt(#name) = tBuddyData.getAt(#name)) then
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
  if (tConn = 0) then
    return FALSE
  end if
  tErrorCode = tConn.GetIntFrom()
  if (tErrorCode = 0) then
    return(error(me, "Undefined messenger error!", #handle_messenger_error))
  else
    if (tErrorCode = 37) then
      tItems = me.getComponent().pItemList
      tItems.getAt(#newBuddyRequest).addAt(1, tItems.getAt(#pendingBuddyAccept))
      tItems.setAt(#pendingBuddyAccept, "")
      me.getComponent().tellRequestCount()
      me.getInterface().updateFrontPage()
      return(me.getInterface().openBuddyMassremoveWindow())
    else
      if (tErrorCode = 39) then
        return(me.getInterface().openBuddyMassremoveWindow())
      else
        return(error(me, "Messenger error, failed c->s message:" && tErrorCode, #handle_messenger_error))
      end if
    end if
  end if
  return TRUE
end

on get_console_info me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
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
    i = (1 + i)
  end repeat
  tBuddyList = me.get_sorted_buddy_list(tBuddyData)
  tBuddyList.setAt(#buddies, tBuddyData)
  tResult.addProp(#buddies, tBuddyList)
  tList = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_console_message(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
    i = (1 + i)
  end repeat
  tResult.addProp(#console_messages, tList)
  tList = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_campaign_message(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
    i = (1 + i)
  end repeat
  tResult.addProp(#campaign_messages, tList)
  tList = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata = me.get_buddy_request(tMsg)
    if tdata <> 0 then
      tList.add(tdata)
    end if
    i = (1 + i)
  end repeat
  tResult.addProp(#buddy_requests, tList)
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
    i = (1 + i)
  end repeat
  tSortedList.getAt(#online).sort()
  tSortedList.getAt(#offline).sort()
  i = 1
  repeat while i <= tSortedList.getAt(#online).count
    tSortedList.getAt(#render).add(tSortedList.getAt(#online).getAt(i))
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= tSortedList.getAt(#offline).count
    tSortedList.getAt(#render).add(tSortedList.getAt(#offline).getAt(i))
    i = (1 + i)
  end repeat
  return(tSortedList)
end

on get_buddy_info me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#name, string(tConn.GetStrFrom()))
  tdata.setAt(#customText, tConn.GetStrFrom())
  tdata.setAt(#online, tConn.GetIntFrom())
  tdata.setAt(#location, tConn.GetStrFrom())
  tdata.setAt(#lastAccess, tConn.GetStrFrom())
  return(tdata)
end

on get_user_info me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  if (tdata.getAt(#id) = "0") then
    return FALSE
  end if
  tdata.setAt(#name, tConn.GetStrFrom())
  if (tConn.GetIntFrom() = 0) then
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
  if (tConn = 0) then
    return FALSE
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#senderID, string(tConn.GetIntFrom()))
  if (tConn.GetIntFrom() = 0) then
    tdata.setAt(#sex, "F")
  else
    tdata.setAt(#sex, "M")
  end if
  tdata.setAt(#FigureData, tConn.GetStrFrom())
  tdata.setAt(#time, tConn.GetStrFrom())
  tdata.setAt(#message, tConn.GetStrFrom())
  return(tdata)
end

on get_campaign_message me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
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
  if (tConn = 0) then
    return FALSE
  end if
  tdata = [:]
  tdata.setAt(#id, string(tConn.GetIntFrom()))
  tdata.setAt(#name, tConn.GetStrFrom())
  return(tdata)
end

on get_user_list me, tMsg 
  tConn = tMsg.connection
  if (tConn = 0) then
    return FALSE
  end if
  tdata = []
  tLoopCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tLoopCount
    tdata.add(string(tConn.GetIntFrom()))
    i = (1 + i)
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
  return TRUE
end
