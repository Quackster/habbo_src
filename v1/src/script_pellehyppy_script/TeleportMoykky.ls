on mouseDown me 
  tMyPuppet = sprite(gpObjects.getAt(gMyName)).getProp(#scriptInstanceList, 1)
  if tMyPuppet.locY > 3 then
    sendFuseMsg("Move 2 6")
  else
    sendFuseMsg("Move 7 0")
  end if
  dontPassEvent()
end
