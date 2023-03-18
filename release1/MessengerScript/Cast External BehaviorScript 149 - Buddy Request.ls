property enabled
global gBuddyRequestSprite

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
    buddy = line 1 of field "messenger.member_info"
    sendEPFuseMsg("MESSENGER_REQUESTBUDDY" && buddy & RETURN & "request buddy.message")
    s = member(member("messenger.ask_to_buddy_confirmation")).text
    put buddy into line 1 of s
    member(member("messenger.ask_to_buddy_confirmation")).text = s
    goContext("asktobuddy")
  end if
end
