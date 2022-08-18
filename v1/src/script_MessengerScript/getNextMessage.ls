global gMessageManager

on mouseDown me
  msg = getNextMessage(gMessageManager)
  if not voidp(msg) then
    goContext("readmsg")
    display(msg)
  else
    goContext("buddies")
  end if
end
