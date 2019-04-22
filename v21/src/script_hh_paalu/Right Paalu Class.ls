on construct(me)
  pTrgLoc = getVariableValue("paalu.start.right", [21, 7])
  return(1)
  exit
end

on select(me)
  if threadExists(#room) then
    return(getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:pTrgLoc.getAt(1), #short:pTrgLoc.getAt(2)]))
  end if
  exit
end