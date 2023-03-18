global gBuddyList, gMessageManager, gChosenBuddyId, gMModeChosenMode

on mouseDown me
  receivers = field("receivers")
  if receivers.length < 1 then
    ShowAlert("ChooseWhoToSentMessage")
    return 
  end if
  message = member("messenger.message.new").text
  if message.length < 1 then
    return 
  else
    sendEPFuseMsg("MESSENGER_SENDSMSMSG" && receivers & RETURN & message)
    goContext("buddies")
  end if
  put EMPTY into field "receivers"
  member("messenger.message.new").text = EMPTY
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  puppetSound(2, "messagesent")
end
