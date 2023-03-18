on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_messengerready me, tMsg
  me.getComponent().receive_MessengerReady("MESSENGERREADY")
end

on handle_buddylist me, tMsg
  tMessage = [#buddies: [:], #online: [], #offline: [], #render: []]
  tBuddies = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 2
  repeat while i <= tMsg.message.line.count
    tLine = tMsg.message.line[i]
    if length(tLine) > 4 then
      the itemDelimiter = "/"
      tSupp = tLine.item[tLine.item.count]
      tLine = tLine.item[1..tLine.item.count - 1]
      tProps = [:]
      tProps[#id] = tLine.word[1]
      tProps[#name] = tLine.word[2]
      tProps[#msg] = tLine.item[1].word[3..tLine.item[1].word.count]
      tProps[#emailOk] = tSupp contains "email_ok"
      tProps[#smsOk] = tSupp contains "sms_ok"
      tProps[#msgs] = 0
      tProps[#update] = 1
      if tLine contains "sex=F" then
        tProps[#sex] = "F"
      else
        tProps[#sex] = "M"
      end if
      the itemDelimiter = TAB
      tUnit = tMsg.message.line[i + 1].item[1]
      if tUnit = "ENTERPRISESERVER" then
        tProps[#unit] = "Messenger"
      else
        tProps[#unit] = tUnit
      end if
      tProps[#last_access_time] = tMsg.message.line[i + 1].item[2]
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
    "BLU":
      if tMessage.buddies.count > 0 then
        me.getComponent().receive_BuddyList(#update, tMessage)
      end if
    "A_BD":
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
  tProps[#id] = tMsg.message.line[2]
  tProps[#senderID] = tMsg.message.line[3]
  tProps[#recipients] = tMsg.message.line[4]
  tProps[#time] = tMsg.message.line[5]
  tProps[#message] = tMsg.message.line[6..tMsg.message.line.count - 2]
  tProps[#FigureData] = tMsg.message.line[tMsg.message.line.count - 1]
  me.getComponent().receive_Message(tProps)
end

on handle_nosuchuser me, tMsg
  case tMsg.content.word[1] of
    "REGNAME":
    "MESSENGER":
      me.getComponent().receive_UserNotFound(["name": tMsg.content.word[2]])
  end case
end

on handle_messengersmsaccount me, tMsg
  me.getComponent().receive_SmsAccount(tMsg.getaProp(#content))
end

on handle_buddyaddrequests me, tMsg
  tProps = [:]
  tStr = tMsg.message.line[2..tMsg.message.line.count]
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tProps[#name] = tStr.word[1].item[2]
  the itemDelimiter = tDelim
  me.getComponent().receive_BuddyRequest(tProps)
end

on handle_mypersistentmsg me, tMsg
  me.getComponent().receive_PersistentMsg(tMsg.getaProp(#content))
end

on handle_userprofile me, tMsg
  tProfile = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  repeat with i = 2 to tMsg.message.line.count
    tLine = tMsg.message.line[i]
    if tLine.item.count > 3 then
      tDataID = integer(tLine.item[1])
      tGroupID = integer(tLine.item[2])
      tText = tLine.item[3]
      tValue = integer(tLine.item[4])
      if voidp(tProfile.getaProp(tGroupID)) then
        tProfile.setaProp(tGroupID, [#name: EMPTY, #open: 0, #id: tGroupID, #group: tGroupID, #data: [:]])
      end if
      if tGroupID = tDataID then
        tProfile.getaProp(tGroupID).name = tText
        next repeat
      end if
      tProfile.getaProp(tGroupID).data.setaProp(tDataID, [#name: tText, #value: tValue, #id: tDataID, #group: tGroupID])
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().receive_UserProfile(tProfile)
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

on handle_system_msg me, tMsg
  put "TODO:" & tMsg.getaProp(#message)
end

on regMsgList me, tBool
  tList = [:]
  tList["MESSENGERREADY"] = #handle_messengerready
  tList["BUDDYLIST"] = #handle_buddylist
  tList["BLU"] = #handle_buddylist
  tList["A_BD"] = #handle_buddylist
  tList["R_BD"] = #handle_remove_buddy
  tList["MESSENGER_MSG"] = #handle_messenger_msg
  tList["MYPERSISTENTMSG"] = #handle_mypersistentmsg
  tList["MESSENGERSMSACCOUNT"] = #handle_messengersmsaccount
  tList["BUDDYADDREQUESTS"] = #handle_buddyaddrequests
  tList["NOSUCHUSER"] = #handle_nosuchuser
  tList["USERPROFILE"] = #handle_userprofile
  tList["CAMPAIGN_MSG"] = #handle_campaign_msg
  tList["MESSENGER_SYSTEMMSG"] = #handle_system_msg
  tList["SYSTEMMSG"] = #handle_system_msg
  if tBool then
    return registerListener(getVariable("connection.info.id"), me.getID(), tList)
  else
    return unregisterListener(getVariable("connection.info.id"), me.getID(), tList)
  end if
end
