global gChosenUser

on mouseDown me
  if not voidp(gChosenUser) then
    sendFuseMsg("KILLUSER" && gChosenUser)
  end if
end
