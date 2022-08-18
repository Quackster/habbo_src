property pTrgLoc

on construct me 
  pTrgLoc = getVariableValue("paalu.start.left", [21, 19])
  return TRUE
end

on select me 
  if threadExists(#room) then
    return(getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && pTrgLoc.getAt(1) && pTrgLoc.getAt(2)))
  end if
end
