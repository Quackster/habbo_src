property scrollOn
global gBuddyList

on mouseWithin me
  if the mouseDown and scrollOn then
    scrollUp(gBuddyList)
  else
    scrollOn = 0
  end if
end

on mouseDown me
  scrollOn = 1
  scrollUp(gBuddyList)
end
