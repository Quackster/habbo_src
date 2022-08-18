property pTrgLoc

on construct me
  pTrgLoc = getVariableValue("paalu.start.left", [21, 19])
  return 1
end

on select me
  if threadExists(#room) then
    return getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: pTrgLoc[1], #short: pTrgLoc[2]])
  end if
end
