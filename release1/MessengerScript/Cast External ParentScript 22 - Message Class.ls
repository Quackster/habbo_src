property id, message, senderID, recipients, recipientNames, recipientIds, time
global gBuddyList, gActiveMsg, gBuddyFigures

on new me, fusepMsg
  id = integer(line 1 of fusepMsg)
  senderID = integer(line 2 of fusepMsg)
  recipients = value(line 3 of fusepMsg)
  time = line 4 of fusepMsg
  FigureData = line 6 of fusepMsg
  if voidp(gBuddyFigures) then
    gBuddyFigures = [:]
  end if
  if voidp(gBuddyFigures.findPos(senderID)) then
    addProp(gBuddyFigures, senderID, FigureData)
  end if
  message = line 5 to the number of lines in fusepMsg - 2 of fusepMsg
  recipientNames = EMPTY
  recipientIds = EMPTY
  repeat with buddyId in recipients
    recipientNames = recipientNames & getBuddyName(gBuddyList, buddyId) & " "
    recipientIds = recipientIds && buddyId
  end repeat
  return me
end

on getMessage me
  return message
end

on markAsRead me
  sendEPFuseMsg("MESSENGER_MARKREAD " & id)
end

on display me
  s = "From:" && getBuddyName(gBuddyList, senderID)
  s = s & RETURN & time & RETURN
  member("messenger.message_info").text = s
  member("messenger.message").text = message
  gActiveMsg = me
end

on reply me
  member("receivers.show").text = AddTextToField("receivers") & RETURN & getBuddyName(gBuddyList, senderID)
  put senderID into field "receivers"
end
