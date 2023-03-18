property scrollOn
global gBuddyList

on mouseWithin me
  if the mouseDown and scrollOn then
    sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "hi")
    scrollByLine(member("messenger.message"), -1)
  else
    sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me))
    scrollOn = 0
  end if
end

on mouseUp me
  scrollOn = 0
end

on mouseDown me
  scrollOn = 1
  sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "hi")
  scrollByLine(member("messenger.message"), -1)
end
