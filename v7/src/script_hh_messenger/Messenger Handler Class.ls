on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_ok(me, tMsg)
  tMsg.send("MESSENGER_INIT")
  exit
end

on handle_messengerready(me, tMsg)
  me.getComponent().receive_MessengerReady("MESSENGERREADY")
  exit
end

on handle_buddylist(me, tMsg)
  tMessage = [#buddies:[], #online:[], #offline:[], #render:[]]
  tBuddies = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, i)
    if length(tLine) > 4 then
      the itemDelimiter = "/"
      tSupp = tLine.getProp(#item, tLine.count(#item))
      tLine = tLine.getProp(#item, 1, tLine.count(#item) - 1)
      tProps = []
      tProps.setAt(#id, tLine.getProp(#word, 1))
      tProps.setAt(#name, tLine.getProp(#word, 2))
      tProps.setAt(#msg, tLine.getPropRef(#item, 1).getProp(#word, 3, tLine.getPropRef(#item, 1).count(#word)))
      tProps.setAt(#emailOk, tSupp contains "email_ok")
      tProps.setAt(#msgs, 0)
      tProps.setAt(#update, 1)
      if tSupp contains "sex=F" or tSupp contains "sex=f" then
        tProps.setAt(#sex, "F")
      else
        tProps.setAt(#sex, "M")
      end if
      the itemDelimiter = "\t"
      tUnit = tMsg.getPropRef(#line, i + 1).getProp(#item, 1)
      if tUnit = "ENTERPRISESERVER" then
        tProps.setAt(#unit, "Messenger")
      else
        tProps.setAt(#unit, tUnit)
      end if
      tProps.setAt(#last_access_time, tMsg.getPropRef(#line, i + 1).getProp(#item, 2))
      the itemDelimiter = ","
      if length(tUnit) > 2 then
        online.add(tLine.getProp(#word, 2))
        tProps.setAt(#online, 1)
      else
        offline.add(tLine.getProp(#word, 2))
        tProps.setAt(#online, 0)
      end if
      tBuddies.setAt(tProps.name, tProps)
    end if
    i = i + 2
  end repeat
  sort(tMessage.online)
  sort(tMessage.offline)
  repeat while me <= undefined
    tName = getAt(undefined, tMsg)
    tBuddy = tBuddies.getaProp(tName)
    buddies.setaProp(tBuddy.getAt(#id), tBuddy)
    render.add(tName)
  end repeat
  repeat while me <= undefined
    tName = getAt(undefined, tMsg)
    tBuddy = tBuddies.getaProp(tName)
    buddies.setaProp(tBuddy.getAt(#id), tBuddy)
    render.add(tName)
  end repeat
  the itemDelimiter = tDelim
  tMsg.setaProp(#content, tMessage)
  if me = 17 then
    if tMessage.count(#buddies) > 0 then
      me.getComponent().receive_BuddyList(#update, tMessage)
    end if
  else
    if me = 137 then
      me.getComponent().receive_AppendBuddy(tMessage)
    else
      me.getComponent().receive_BuddyList(#new, tMessage)
    end if
  end if
  exit
end

on handle_remove_buddy(me, tMsg)
  me.getComponent().receive_RemoveBuddy(tMsg.content)
  exit
end

on handle_messenger_msg(me, tMsg)
  tProps = []
  tProps.setAt(#id, tMsg.getProp(#line, 1))
  tProps.setAt(#senderID, tMsg.getProp(#line, 2))
  tProps.setAt(#recipients, tMsg.getProp(#line, 3))
  tProps.setAt(#time, tMsg.getProp(#line, 4))
  tProps.setAt(#message, tMsg.getProp(#line, 5, tMsg.count(#line) - 1))
  tProps.setAt(#FigureData, tMsg.getProp(#line, tMsg.count(#line)))
  me.getComponent().receive_Message(tProps)
  exit
end

on handle_nosuchuser(me, tMsg)
  if me = "REGNAME" then
  else
    if me = "MESSENGER" then
      me.getComponent().receive_UserNotFound(["name":tMsg.getProp(#word, 2)])
    end if
  end if
  exit
end

on handle_memberinfo(me, tMsg)
  if me = "MESSENGER" then
    tProps = []
    tStr = tMsg.getaProp(#content)
    tStr = tStr.getProp(#line, 2, tStr.count(#line))
    tProps.setAt(#name, tStr.getProp(#line, 1))
    tProps.setAt(#customText, "\"" & tStr.getProp(#line, 2) & "\"")
    tProps.setAt(#lastAccess, tStr.getProp(#line, 3))
    tProps.setAt(#location, tStr.getProp(#line, 4))
    tProps.setAt(#FigureData, tStr.getProp(#line, 5))
    tProps.setAt(#sex, tStr.getProp(#line, 6))
    if tProps.getAt(#sex) contains "f" or tProps.getAt(#sex) contains "F" then
      tProps.setAt(#sex, "F")
    else
      tProps.setAt(#sex, "M")
    end if
    if tProps.getAt(#location) = "ENTERPRISESERVER" then
      tProps.setAt(#location, "messenger")
    end if
    if objectExists("Figure_System") then
      tProps.setAt(#FigureData, getObject("Figure_System").parseFigure(tProps.getAt(#FigureData), tProps.getAt(#sex), "user"))
    end if
    me.getComponent().receive_UserFound(tProps)
  end if
  exit
end

on handle_buddyaddrequests(me, tMsg)
  tProps = []
  tStr = tMsg.getProp(#line, 1, tMsg.count(#line))
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tProps.setAt(#name, tStr.getPropRef(#word, 1).getProp(#item, 2))
  the itemDelimiter = tDelim
  me.getComponent().receive_BuddyRequest(tProps)
  exit
end

on handle_mypersistentmsg(me, tMsg)
  me.getComponent().receive_PersistentMsg(tMsg.getaProp(#content))
  exit
end

on handle_campaign_msg(me, tMsg)
  tdata = []
  tdata.setAt(#id, tMsg.getProp(#line, 1))
  tdata.setAt(#url, tMsg.getProp(#line, 2))
  tdata.setAt(#link, tMsg.getProp(#line, 3))
  tdata.setAt(#message, tMsg.getProp(#line, 4, tMsg.count(#line)))
  tdata.setAt(#senderID, "Campaign Msg")
  tdata.setAt(#recipiens, "[]")
  tdata.setAt(#time, "---")
  tdata.setAt(#FigureData, "")
  tdata.setAt(#campaign, 1)
  me.getComponent().receive_CampaignMsg(tdata)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
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
  tCmds = []
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
  return(1)
  exit
end