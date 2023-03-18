global gpObjects, gMyName

on mouseDown me
  tMyPuppet = sprite(gpObjects[gMyName]).scriptInstanceList[1]
  if tMyPuppet.locY > 3 then
    sendFuseMsg("Move 2 6")
  else
    sendFuseMsg("Move 7 0")
  end if
  dontPassEvent()
end
