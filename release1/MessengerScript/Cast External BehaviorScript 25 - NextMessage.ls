global gBuddyList, gMessageManager, gChosenBuddyId

on mouseDown me
  global gChosenBuddyId, gMessageManager
  if voidp(gMessageManager) then
    return 
  end if
  msg = getNextMessage(gMessageManager, gChosenBuddyId)
  if msg = VOID then
    goContext("buddies")
  else
    display(msg)
  end if
end

on beginSprite me
  exitFrame(me)
end

on exitFrame me
  if getMessageCount(gMessageManager, gChosenBuddyId) = 0 then
    sprite(me.spriteNum).visible = 0
  else
    sprite(me.spriteNum).visible = 1
  end if
end

on endSprite me
  sprite(me.spriteNum).visible = 1
end
