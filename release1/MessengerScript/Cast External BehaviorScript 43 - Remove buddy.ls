property num
global gChosenbuddyName

on mouseUp me
  name = gChosenbuddyName
  if not voidp(name) then
    sendEPFuseMsg("MESSENGER_REMOVEBUDDY" && name)
    goContext("buddies")
  end if
end
