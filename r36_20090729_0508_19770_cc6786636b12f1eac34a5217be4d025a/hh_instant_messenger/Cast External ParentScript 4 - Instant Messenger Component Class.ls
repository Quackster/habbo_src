property pChats, pFriends, pUserId, pShowModNotification, pInvitees

on construct me
  tStamp = EMPTY
  repeat with tNo = 1 to 100
    tChar = numToChar(random(48) + 74)
    tStamp = tStamp & tChar
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  repeat with tCharNo = 1 to tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = (tChar * tCharNo) + 309203
    tReceipt[tCharNo] = tChar
  end repeat
  if tReceipt <> tFuseReceipt then
    error(me, "Invalid build structure", #checkDataLoaded, #critical)
    return 0
  end if
  pChats = [:]
  pFriends = [:]
  pInvitees = []
  registerMessage(#userlogin, me.getID(), #setUserID)
  registerMessage(#startIMChat, me.getID(), #startIMChat)
  registerMessage(#friendDataUpdated, me.getID(), #updateChat)
  pShowModNotification = 1
  return 1
end

on deconstruct me
  unregisterMessage(#startIMChat, me.getID())
  return 1
end

on setUserID me
  pUserId = getObject(#session).GET("user_user_id")
end

on startIMChat me, tReceiverName, tText
  if not threadExists(#friend_list) then
    return 0
  end if
  tFriend = getThread(#friend_list).getComponent().getFriendByName(tReceiverName)
  if not tFriend then
    return 0
  end if
  tReceiverID = tFriend.getaProp(#id)
  if tReceiverID = 0 then
    return 0
  end if
  me.addChat(tReceiverID, 1)
  if tText <> EMPTY then
    me.sendMessage(tReceiverID, tText)
  end if
  me.getInterface().activateChat(tReceiverID)
  me.getInterface().openIMWindow()
  me.updateChat(tReceiverID)
end

on inviteFriends me, tIDList
  if not listp(tIDList) then
    return 0
  end if
  pInvitees = tIDList
  me.getInterface().showInvitationWindow(pInvitees.count)
end

on sendInvitation me, tInvitationText
  if pInvitees.count = 0 then
    return 0
  end if
  tMsg = [:]
  tMsg.addProp(#integer, pInvitees.count)
  repeat with tID in pInvitees
    tMsg.addProp(#integer, integer(tID))
  end repeat
  tMsg.addProp(#string, tInvitationText)
  return getConnection(getVariable("connection.info.id")).send("FRIEND_INVITE", tMsg)
end

on addChat me, tChatID, tDontPlaySound
  if not voidp(pChats.getaProp(tChatID)) then
    return 0
  end if
  tFriend = me.updateFriend(tChatID)
  if not tFriend then
    return 0
  end if
  tFriendID = tFriend.getaProp(#id)
  pFriends.setaProp(tFriendID, tFriend)
  tChat = []
  pChats.setaProp(tChatID, tChat)
  me.getInterface().addChat(tChatID, tFriend, tDontPlaySound)
  if pShowModNotification then
    me.receiveNotification(tChatID, #moderation)
    pShowModNotification = 0
  end if
  return 1
end

on updateChat me, tChatID
  if voidp(tChatID) then
    return 0
  end if
  if voidp(pChats.findPos(tChatID)) then
    return 0
  end if
  tFriend = pFriends.getaProp(tChatID)
  if ilk(tFriend) <> #propList then
    return 0
  end if
  tOnline = tFriend.getaProp(#online)
  tFriendUpdated = me.updateFriend(tChatID)
  if ilk(tFriendUpdated) <> #propList then
    return 0
  end if
  tOnlineUpdated = tFriendUpdated.getaProp(#online)
  if tOnlineUpdated <> tOnline then
    if tOnlineUpdated then
      me.receiveNotification(tChatID, #online)
    else
      me.receiveNotification(tChatID, #offline)
    end if
  end if
  pFriends.setaProp(tChatID, tFriendUpdated)
  me.getInterface().updateInterface()
end

on removeChat me, tChatID
  if pChats.findPos(tChatID) = 0 then
    return 0
  end if
  me.getInterface().removeChat(tChatID)
  return 1
end

on removeAllChats me
  pChats = [:]
  me.getInterface().removeAllChats()
end

on getChat me, tChatID
  tChat = pChats.getaProp(tChatID)
  if voidp(tChat) then
    if not me.addChat(tChatID) then
      return 0
    end if
    tChat = pChats.getaProp(tChatID)
  end if
  return tChat
end

on receiveMessage me, tSenderId, tText
  tEntry = [:]
  tEntry.setaProp(#type, #message)
  tEntry.setaProp(#userID, tSenderId)
  tEntry.setaProp(#Msg, tText)
  tEntry.setaProp(#time, the time)
  me.addMessage(tSenderId, tEntry)
end

on receiveError me, tChatID, ttype
  case ttype of
    3:
      tTextKey = "im_error_receiver_muted"
    4:
      tTextKey = "im_error_sender_muted"
    5:
      tTextKey = "im_error_offline"
    6:
      tTextKey = "im_error_not_friend"
    7:
      tTextKey = "im_error_busy"
    otherwise:
      tTextKey = "im_error_undefined"
  end case
  tEntry = [:]
  tEntry.setaProp(#type, #error)
  tEntry.setaProp(#Msg, getText(tTextKey))
  tEntry.setaProp(#time, the time)
  me.addMessage(tChatID, tEntry)
end

on receiveNotification me, tChatID, ttype
  tTextKey = "im_notification_" & string(ttype)
  tEntry = [:]
  tEntry.setaProp(#type, #notification)
  tEntry.setaProp(#Msg, getText(tTextKey))
  tEntry.setaProp(#time, the time)
  me.addMessage(tChatID, tEntry)
end

on receiveInvitation me, tChatID, tText
  tText = getText("im_invitation") & RETURN & RETURN & tText
  tEntry = [:]
  tEntry.setaProp(#type, #invitation)
  tEntry.setaProp(#userID, tChatID)
  tEntry.setaProp(#Msg, tText)
  tEntry.setaProp(#time, the time)
  me.addMessage(tChatID, tEntry)
end

on sendMessage me, tReceiverID, tText
  if voidp(tReceiverID) then
    return 0
  end if
  tEntry = [:]
  tEntry.setaProp(#type, #message)
  tEntry.setaProp(#userID, pUserId)
  tEntry.setaProp(#Msg, tText)
  tEntry.setaProp(#time, the time)
  me.addMessage(tReceiverID, tEntry)
  tText = getStringServices().convertSpecialChars(tText, 1)
  tdata = [:]
  tdata.addProp(#integer, integer(tReceiverID))
  tdata.addProp(#string, tText)
  return getConnection(getVariable("connection.info.id")).send("MESSENGER_SENDMSG", tdata)
end

on addMessage me, tChatID, tEntry
  tChat = me.getChat(tChatID)
  if not tChat then
    return 0
  end if
  tChat.add(tEntry)
  me.getInterface().addMessage(tChatID, tEntry)
end

on updateFriend me, tUserID
  if not objectExists(#friend_list_component) then
    return error(me, "Can't find friend list component", #getFriend, #major)
  end if
  tFriend = getObject(#friend_list_component).getFriendByID(tUserID)
  return tFriend
end

on getFriend me, tUserID
  return pFriends.getaProp(tUserID)
end
