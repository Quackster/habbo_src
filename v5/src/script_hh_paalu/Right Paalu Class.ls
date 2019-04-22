property pTrgLoc

on construct me 
  pTrgLoc = getVariableValue("paalu.start.right", [21, 7])
  return(1)
end

on select me 
  if threadExists(#room) then
    return(getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && pTrgLoc.getAt(1) && pTrgLoc.getAt(2)))
  end if
end
