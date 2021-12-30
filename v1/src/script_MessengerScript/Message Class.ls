property senderID, recipients, recipientNames, recipientIds, message, id, time

on new me, fusepMsg 
  id = integer(fusepMsg.line[1])
  senderID = integer(fusepMsg.line[2])
  recipients = value(fusepMsg.line[3])
  time = fusepMsg.line[4]
  FigureData = fusepMsg.line[6]
  if voidp(gBuddyFigures) then
    gBuddyFigures = [:]
  end if
  if voidp(gBuddyFigures.findPos(senderID)) then
    addProp(gBuddyFigures, senderID, FigureData)
  end if
  message = fusepMsg.line[5..(the number of line in fusepMsg - 2)]
  recipientNames = ""
  recipientIds = ""
  repeat while recipients <= 1
    buddyId = getAt(1, count(recipients))
    recipientNames = recipientNames & getBuddyName(gBuddyList, buddyId) & " "
    recipientIds = recipientIds && buddyId
  end repeat
  return(me)
end

on getMessage me 
  return(message)
end

on markAsRead me 
  sendEPFuseMsg("MESSENGER_MARKREAD " & id)
end

on display me 
  s = "From:" && getBuddyName(gBuddyList, senderID)
  s = s & "\r" & time & "\r"
  member("messenger.message_info").text = s
  member("messenger.message").text = message
  gActiveMsg = me
end

on reply me 
  member("receivers.show").text = AddTextToField("receivers") & "\r" & getBuddyName(gBuddyList, senderID)
end
