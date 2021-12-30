on mouseDown me 
  receivers = field(0)
  if receivers.length < 2 then
    ShowAlert("ChooseWhoToSentMessage")
    return()
  end if
  message = field(0)
  if message.length < 1 then
    return()
  else
    sendEPFuseMsg("MESSENGER_SENDEMAILMSG" && receivers & "\r" & message)
  end if
  puppetSound(2, "messagesent")
end
