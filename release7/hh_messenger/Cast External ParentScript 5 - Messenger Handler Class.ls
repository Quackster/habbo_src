on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_ok me, tMsg
  tMsg.connection.send("MESSENGER_INIT")
end

on handle_messengerready me, tMsg
  me.getComponent().receive_MessengerReady("MESSENGERREADY")
end

on handle_buddylist me, tMsg
  tMessage = [#buddies: [:], #online: [], #offline: [], #render: []]
  tBuddies = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tMsg.content.line.count
    tLine = tMsg.content.line[i]
    if length(tLine) > 4 then
      the itemDelimiter = "/"
      tSupp = tLine.item[tLine.item.count]
      tLine = tLine.item[1..tLine.item.count - 1]
      tProps = [:]
      tProps[#id] = tLine.word[1]
      tProps[#name] = tLine.word[2]
      tProps[#msg] = tLine.item[1].word[3..tLine.item[1].word.count]
      tProps[#emailOk] = tSupp contains "email_ok"
      tProps[#msgs] = 0
      tProps[#update] = 1
      if (tSupp contains "sex=F") or (tSupp contains "sex=f") then
        tProps[#sex] = "F"
      else
        tProps[#sex] = "M"
      end if
      the itemDelimiter = TAB
      tUnit = tMsg.content.line[i + 1].item[1]
      if tUnit = "ENTERPRISESERVER" then
        tProps[#unit] = "Messenger"
      else
        tProps[#unit] = tUnit
      end if
      tProps[#last_access_time] = tMsg.content.line[i + 1].item[2]
      the itemDelimiter = ","
      if length(tUnit) > 2 then
        tMessage.online.add(tLine.word[2])
        tProps[#online] = 1
      else
        tMessage.offline.add(tLine.word[2])
        tProps[#online] = 0
      end if
      tBuddies[tProps.name] = tProps
    end if
    i = i + 2
  end repeat
  sort(tMessage.online)
  sort(tMessage.offline)
  repeat with tName in tMessage.online
    tBuddy = tBuddies.getaProp(tName)
    tMessage.buddies.setaProp(tBuddy[#id], tBuddy)
    tMessage.render.add(tName)
  end repeat
  repeat with tName in tMessage.offline
    tBuddy = tBuddies.getaProp(tName)
    tMessage.buddies.setaProp(tBuddy[#id], tBuddy)
    tMessage.render.add(tName)
  end repeat
  the itemDelimiter = tDelim
  tMsg.setaProp(#content, tMessage)
  case tMsg.getaProp(#subject) of
    17:
      if tMessage.buddies.count > 0 then
        me.getComponent().receive_BuddyList(#update, tMessage)
      end if
    137:
      me.getComponent().receive_AppendBuddy(tMessage)
    otherwise:
      me.getComponent().receive_BuddyList(#new, tMessage)
  end case
end

on handle_remove_buddy me, tMsg
  me.getComponent().receive_RemoveBuddy(tMsg.content)
end

on handle_messenger_msg me, tMsg
  tProps = [:]
  tProps[#id] = tMsg.content.line[1]
  tProps[#senderID] = tMsg.content.line[2]
  tProps[#recipients] = tMsg.content.line[3]
  tProps[#time] = tMsg.content.line[4]
  tProps[#message] = tMsg.content.line[5..tMsg.content.line.count - 1]
  tProps[#FigureData] = tMsg.content.line[tMsg.content.line.count]
  me.getComponent().receive_Message(tProps)
end

on handle_nosuchuser me, tMsg
  case tMsg.content.word[1] of
    "REGNAME":
    "MESSENGER":
      me.getComponent().receive_UserNotFound(["name": tMsg.content.word[2]])
  end case
end

on handle_memberinfo me, tMsg
  case tMsg.content.line[1].word[1] of
    "MESSENGER":
      tProps = [:]
      tStr = tMsg.getaProp(#content)
      tStr = tStr.line[2..tStr.line.count]
      tProps[#name] = tStr.line[1]
      tProps[#customText] = QUOTE & tStr.line[2] & QUOTE
      tProps[#lastAccess] = tStr.line[3]
      tProps[#location] = tStr.line[4]
      tProps[#FigureData] = tStr.line[5]
      tProps[#sex] = tStr.line[6]
      if (tProps[#sex] contains "f") or (tProps[#sex] contains "F") then
        tProps[#sex] = "F"
      else
        tProps[#sex] = "M"
      end if
      if tProps[#location] = "ENTERPRISESERVER" then
        tProps[#location] = "messenger"
      end if
      if objectExists("Figure_System") then
        tProps[#FigureData] = getObject("Figure_System").parseFigure(tProps[#FigureData], tProps[#sex], "user")
      end if
      me.getComponent().receive_UserFound(tProps)
  end case
end

on handle_buddyaddrequests me, tMsg
  tProps = [:]
  tStr = tMsg.content.line[1..tMsg.content.line.count]
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tProps[#name] = tStr.word[1].item[2]
  the itemDelimiter = tDelim
  me.getComponent().receive_BuddyRequest(tProps)
end

on handle_mypersistentmsg me, tMsg
  me.getComponent().receive_PersistentMsg(tMsg.getaProp(#content))
end

on handle_campaign_msg me, tMsg
  tdata = [:]
  tdata[#id] = tMsg.content.line[1]
  tdata[#url] = tMsg.content.line[2]
  tdata[#link] = tMsg.content.line[3]
  tdata[#message] = tMsg.content.line[4..tMsg.content.line.count]
  tdata[#senderID] = "Campaign Msg"
  tdata[#recipiens] = "[]"
  tdata[#time] = "---"
  tdata[#FigureData] = EMPTY
  tdata[#campaign] = 1
  me.getComponent().receive_CampaignMsg(tdata)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(3, #handle_ok)
  tMsgs.setaProp(12, #handle_buddylist)
  tMsgs.setaProp(13, #handle_mypersistentmsg)
  tMsgs.setaProp(15, #handle_messengerready)
  tMsgs.setaProp(17, #handle_buddylist)
  tMsgs.setaProp(128, #handle_memberinfo)
  tMsgs.setaProp(132, #handle_buddyaddrequests)
  tMsgs.setaProp(133, #handle_campaign_msg)
  tMsgs.setaProp(134, #handle_messenger_msg)
  tMsgs.setaProp(137, #handle_buddylist)
  tMsgs.setaProp(138, #handle_remove_buddy)
  tMsgs.setaProp(147, #handle_nosuchuser)
  tCmds = [:]
  tCmds.setaProp("MESSENGER_INIT", 12)
  tCmds.setaProp("MESSENGER_SENDUPDATE", 15)
  tCmds.setaProp("MESSENGER_C_CLICK", 30)
  tCmds.setaProp("MESSENGER_C_READ", 31)
  tCmds.setaProp("MESSENGER_MARKREAD", 32)
  tCmds.setaProp("MESSENGER_SENDMSG", 33)
  tCmds.setaProp("MESSENGER_SENDEMAILMSG", 34)
  tCmds.setaProp("MESSENGER_ASSIGNPERSMSG", 36)
  tCmds.setaProp("MESSENGER_ACCEPTBUDDY", 37)
  tCmds.setaProp("MESSENGER_DECLINEBUDDY", 38)
  tCmds.setaProp("MESSENGER_REQUESTBUDDY", 39)
  tCmds.setaProp("MESSENGER_REMOVEBUDDY", 40)
  tCmds.setaProp("FINDUSER", 41)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
