on construct(me)
  pAnimCounter = 0
  pCurrentFrm = 1
  pAnimList = [2, 3, 4, 5, 6, 7, 8, 9, 10]
  receiveUpdate(me.getID())
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("teleport")
  registerProcedure(tSpr, #eventProc, me.getID(), #mouseUp)
  return(1)
  exit
end

on deconstruct(me)
  return(removeUpdate(me.getID()))
  exit
end

on eventProc(me)
  if connectionExists(getVariable("connection.room.id")) then
    tName = getObject(#session).get("user_name")
    tloc = getThread(#room).getComponent().getUserObject(tName).getLocation()
    tLocY = tloc.getAt(2)
    if tLocY > 2 then
      getConnection(getVariable("connection.room.id")).send(#room, "Move 3 2")
    else
      getConnection(getVariable("connection.room.id")).send(#room, "Move 7 0")
    end if
  end if
  exit
end

on update(me)
  if pAnimCounter > 2 then
    tNextFrm = pAnimList.getAt(random(pAnimList.count))
    pAnimList.deleteOne(tNextFrm)
    pAnimList.add(pCurrentFrm)
    pCurrentFrm = tNextFrm
    tmember = member(getmemnum("fount" & pCurrentFrm))
    tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
    if not tRoomVis then
      return(0)
    end if
    tRoomVis.getSprById("fountain").setMember(tmember)
    pAnimCounter = 0
  end if
  pAnimCounter = pAnimCounter + 1
  exit
end