property pTrgLoc

on construct me
  pTrgLoc = getVariableValue("paalu.start.left", [21, 19])
  return 1
end

on select me
  if threadExists(#room) then
    return getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && pTrgLoc[1] && pTrgLoc[2])
  end if
end
