property canSpam

on beginSprite me
  if the frameLabel = "regist" then
    set the member of sprite the spriteNum of me to "checkbox on"
    canSpam = 1
    put canSpam into field "can_spam_field"
  end if
  if member("can_spam_field").text = "1" then
    set the member of sprite the spriteNum of me to "checkbox on"
    canSpam = 1
  else
    set the member of sprite the spriteNum of me to "checkbox off"
    canSpam = 0
  end if
  put canSpam into field "can_spam_field"
end

on mouseDown me
  doSwitch(me)
end

on doSwitch me
  if canSpam then
    set the member of sprite the spriteNum of me to "checkbox off"
    canSpam = 0
  else
    set the member of sprite the spriteNum of me to "checkbox on"
    canSpam = 1
  end if
  put canSpam into field "can_spam_field"
end
