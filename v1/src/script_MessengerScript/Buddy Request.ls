property enabled

on beginSprite me 
  gBuddyRequestSprite = me.spriteNum
  disable(me)
end

on enable me 
  enabled = 1
  mname = sprite(me.spriteNum).member.name
  sprite(me.spriteNum).blend = 100
end

on disable me 
  enabled = 0
  mname = sprite(me.spriteNum).member.name
  sprite(me.spriteNum).blend = 50
end

on mouseUp me 
  if enabled then
    buddy = NULL
    sendEPFuseMsg("MESSENGER_REQUESTBUDDY" && buddy & "\r" & "request buddy.message")
    s = member(member("messenger.ask_to_buddy_confirmation")).text
    member(member("messenger.ask_to_buddy_confirmation")).text = s
    goContext("asktobuddy")
  end if
end
