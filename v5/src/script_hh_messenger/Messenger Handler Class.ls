on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_messengerready me, tMsg 
  me.getComponent().receive_MessengerReady("MESSENGERREADY")
end

on handle_buddylist me, tMsg 
  tMessage = [#buddies:[:], #online:[], #offline:[], #render:[]]
  tBuddies = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 2
  repeat while i <= tMsg.message.count(#line)
    tLine = tMsg.message.getProp(#line, i)
    if length(tLine) > 4 then
      the itemDelimiter = "/"
      tSupp = tLine.getProp(#item, tLine.count(#item))
      tLine = tLine.getProp(#item, 1, (tLine.count(#item) - 1))
      tProps = [:]
      tProps.setAt(#id, tLine.getProp(#word, 1))
      tProps.setAt(#name, tLine.getProp(#word, 2))
      tProps.setAt(#msg, tLine.getPropRef(#item, 1).getProp(#word, 3, tLine.getPropRef(#item, 1).count(#word)))
      tProps.setAt(#emailOk, tSupp contains "email_ok")
      tProps.setAt(#smsOk, tSupp contains "sms_ok")
      tProps.setAt(#msgs, 0)
      tProps.setAt(#update, 1)
      if tLine contains "sex=F" then
        tProps.setAt(#sex, "F")
      else
        tProps.setAt(#sex, "M")
      end if
      the itemDelimiter = "\t"
      tUnit = tMsg.message.getPropRef(#line, (i + 1)).getProp(#item, 1)
      if (tUnit = "ENTERPRISESERVER") then
        tProps.setAt(#unit, "Messenger")
      else
        tProps.setAt(#unit, tUnit)
      end if
      tProps.setAt(#last_access_time, tMsg.message.getPropRef(#line, (i + 1)).getProp(#item, 2))
      the itemDelimiter = ","
      if length(tUnit) > 2 then
        tMessage.online.add(tLine.getProp(#word, 2))
        tProps.setAt(#online, 1)
      else
        tMessage.offline.add(tLine.getProp(#word, 2))
        tProps.setAt(#online, 0)
      end if
      tBuddies.setAt(tProps.name, tProps)
    end if
    i = (i + 2)
  end repeat
  sort(tMessage.online)
  sort(tMessage.offline)
  repeat while tMessage.online <= undefined
    tName = getAt(undefined, tMsg)
    tBuddy = tBuddies.getaProp(tName)
    tMessage.buddies.setaProp(tBuddy.getAt(#id), tBuddy)
    tMessage.render.add(tName)
  end repeat
  repeat while tMessage.online <= undefined
    tName = getAt(undefined, tMsg)
    tBuddy = tBuddies.getaProp(tName)
    tMessage.buddies.setaProp(tBuddy.getAt(#id), tBuddy)
    tMessage.render.add(tName)
  end repeat
  the itemDelimiter = tDelim
  tMsg.setaProp(#content, tMessage)
  if (tMessage.online = "BLU") then
    if tMessage.count(#buddies) > 0 then
      me.getComponent().receive_BuddyList(#update, tMessage)
    end if
  else
    if (tMessage.online = "A_BD") then
      me.getComponent().receive_AppendBuddy(tMessage)
    else
      me.getComponent().receive_BuddyList(#new, tMessage)
    end if
  end if
end

on handle_remove_buddy me, tMsg 
  me.getComponent().receive_RemoveBuddy(tMsg.content)
end

on handle_messenger_msg me, tMsg 
  tProps = [:]
  tProps.setAt(#id, tMsg.message.getProp(#line, 2))
  tProps.setAt(#senderID, tMsg.message.getProp(#line, 3))
  tProps.setAt(#recipients, tMsg.message.getProp(#line, 4))
  tProps.setAt(#time, tMsg.message.getProp(#line, 5))
  tProps.setAt(#message, tMsg.message.getProp(#line, 6, (tMsg.message.count(#line) - 2)))
  tProps.setAt(#FigureData, tMsg.message.getProp(#line, (tMsg.message.count(#line) - 1)))
  me.getComponent().receive_Message(tProps)
end

on handle_nosuchuser me, tMsg 
  if (tMsg.content.getProp(#word, 1) = "REGNAME") then
  else
    if (tMsg.content.getProp(#word, 1) = "MESSENGER") then
      me.getComponent().receive_UserNotFound(["name":tMsg.content.getProp(#word, 2)])
    end if
  end if
end

on handle_messengersmsaccount me, tMsg 
  me.getComponent().receive_SmsAccount(tMsg.getaProp(#content))
end

on handle_buddyaddrequests me, tMsg 
  tProps = [:]
  tStr = tMsg.message.getProp(#line, 2, tMsg.message.count(#line))
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tProps.setAt(#name, tStr.getPropRef(#word, 1).getProp(#item, 2))
  the itemDelimiter = tDelim
  me.getComponent().receive_BuddyRequest(tProps)
end

on handle_mypersistentmsg me, tMsg 
  me.getComponent().receive_PersistentMsg(tMsg.getaProp(#content))
end

on handle_userprofile me, tMsg 
  tProfile = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  i = 2
  repeat while i <= tMsg.message.count(#line)
    tLine = tMsg.message.getProp(#line, i)
    if tLine.count(#item) > 3 then
      tDataID = integer(tLine.getProp(#item, 1))
      tGroupID = integer(tLine.getProp(#item, 2))
      tText = tLine.getProp(#item, 3)
      tValue = integer(tLine.getProp(#item, 4))
      if voidp(tProfile.getaProp(tGroupID)) then
        tProfile.setaProp(tGroupID, [#name:"", #open:0, #id:tGroupID, #group:tGroupID, #data:[:]])
      end if
      if (tGroupID = tDataID) then
        tProfile.getaProp(tGroupID).name = tText
      else
        tProfile.getaProp(tGroupID).data.setaProp(tDataID, [#name:tText, #value:tValue, #id:tDataID, #group:tGroupID])
      end if
    end if
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().receive_UserProfile(tProfile)
end

on handle_campaign_msg me, tMsg 
  tdata = [:]
  tdata.setAt(#id, tMsg.content.getProp(#line, 1))
  tdata.setAt(#url, tMsg.content.getProp(#line, 2))
  tdata.setAt(#link, tMsg.content.getProp(#line, 3))
  tdata.setAt(#message, tMsg.content.getProp(#line, 4, tMsg.content.count(#line)))
  tdata.setAt(#senderID, "Campaign Msg")
  tdata.setAt(#recipiens, "[]")
  tdata.setAt(#time, "---")
  tdata.setAt(#FigureData, "")
  tdata.setAt(#campaign, 1)
  me.getComponent().receive_CampaignMsg(tdata)
end

on handle_system_msg me, tMsg 
  put("TODO:" & tMsg.getaProp(#message))
end

on regMsgList me, tBool 
  tList = [:]
  tList.setAt("MESSENGERREADY", #handle_messengerready)
  tList.setAt("BUDDYLIST", #handle_buddylist)
  tList.setAt("BLU", #handle_buddylist)
  tList.setAt("A_BD", #handle_buddylist)
  tList.setAt("R_BD", #handle_remove_buddy)
  tList.setAt("MESSENGER_MSG", #handle_messenger_msg)
  tList.setAt("MYPERSISTENTMSG", #handle_mypersistentmsg)
  tList.setAt("MESSENGERSMSACCOUNT", #handle_messengersmsaccount)
  tList.setAt("BUDDYADDREQUESTS", #handle_buddyaddrequests)
  tList.setAt("NOSUCHUSER", #handle_nosuchuser)
  tList.setAt("USERPROFILE", #handle_userprofile)
  tList.setAt("CAMPAIGN_MSG", #handle_campaign_msg)
  tList.setAt("MESSENGER_SYSTEMMSG", #handle_system_msg)
  tList.setAt("SYSTEMMSG", #handle_system_msg)
  if tBool then
    return(registerListener(getVariable("connection.info.id"), me.getID(), tList))
  else
    return(unregisterListener(getVariable("connection.info.id"), me.getID(), tList))
  end if
end
