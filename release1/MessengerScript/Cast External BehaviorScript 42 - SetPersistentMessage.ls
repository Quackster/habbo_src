on beginSprite me
  member("messenger.my_persistent_message").editable = 1
end

on mouseDown me
  member("messenger.my_persistent_message").editable = 0
  sendEPFuseMsg("MESSENGER_ASSIGNPERSMSG" && line 1 of field "messenger.my_persistent_message")
end
