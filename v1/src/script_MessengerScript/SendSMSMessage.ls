on mouseDown me 
  receivers = field(0)
  if receivers.length < 1 then
    ShowAlert("ChooseWhoToSentMessage")
    return()
  end if
  message = member("messenger.message.new").text
  if message.length < 1 then
    return()
  else
    sendEPFuseMsg("MESSENGER_SENDSMSMSG" && receivers & "\r" & message)
    goContext("buddies")
  end if
  member("messenger.message.new").text = ""
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  puppetSound(2, "messagesent")
end
