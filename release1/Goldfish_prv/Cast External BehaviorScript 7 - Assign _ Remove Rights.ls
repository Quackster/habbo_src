global gChosenUser

on mouseDown me
  if sprite(me.spriteNum).member.name contains "enable" then
    if not voidp(gChosenUser) then
      sendFuseMsg("ASSIGNRIGHTS" && gChosenUser)
    end if
  else
    sendFuseMsg("REMOVERIGHTS" && gChosenUser)
  end if
end
