global gBuddyList, gMessageManager, gChosenBuddyId

on mouseDown me
  receivers = field("receivers")
  if receivers.length < 2 then
    ShowAlert("ChooseWhoToSentMessage")
    return 
  end if
  message = field("message")
  if message.length < 1 then
    return 
  else
    sendEPFuseMsg("MESSENGER_SENDEMAILMSG" && receivers & RETURN & message)
  end if
  put EMPTY into field "receivers"
  put EMPTY into field "message"
  puppetSound(2, "messagesent")
end
