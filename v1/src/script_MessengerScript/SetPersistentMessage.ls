on beginSprite me 
  member("messenger.my_persistent_message").editable = 1
end

on mouseDown me 
  member("messenger.my_persistent_message").editable = 0
  sendEPFuseMsg(0 && null)
end
