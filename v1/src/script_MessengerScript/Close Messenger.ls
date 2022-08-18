on mouseDown me
  global gOldpersistentmessage
  if ((member("messenger.my_persistent_message").text <> AddTextToField("MyPersistentMessage")) and (gOldpersistentmessage <> member("messenger.my_persistent_message").text)) then
    sendEPFuseMsg(("MESSENGER_ASSIGNPERSMSG" && line 1 of the text of member("messenger.my_persistent_message")))
  end if
  closeMessenger()
end
