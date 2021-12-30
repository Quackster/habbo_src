on mouseDown me 
  if member("messenger.my_persistent_message").text <> AddTextToField("MyPersistentMessage") and gOldpersistentmessage <> member("messenger.my_persistent_message").text then
    sendEPFuseMsg("MESSENGER_ASSIGNPERSMSG" && member("messenger.my_persistent_message").text.line[1])
  end if
  closeMessenger()
end
