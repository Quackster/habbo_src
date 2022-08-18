property spriteNum
global dancing

on mouseUp me
  dancing = not dancing
  sendFuseMsg("STOP CarryDrink")
  if dancing then
    sendFuseMsg("Dance")
  else
    sendFuseMsg("STOP Dance")
  end if
end
