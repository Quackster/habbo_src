property scrollOn
global gBuddyList

on mouseWithin me
  if the mouseDown and scrollOn then
    scrollDown(gBuddyList)
  else
    scrollOn = 0
  end if
end

on mouseDown me
  scrollDown(gBuddyList)
  scrollOn = 1
end
