global gpObjects, gMyName

on mouseDown me
  tMyPuppet = sprite(gpObjects[gMyName]).scriptInstanceList[1]
  if tMyPuppet.locY > 2 then
    sendFuseMsg("Move 3 2")
  else
    sendFuseMsg("Move 7 0")
  end if
  dontPassEvent()
end
