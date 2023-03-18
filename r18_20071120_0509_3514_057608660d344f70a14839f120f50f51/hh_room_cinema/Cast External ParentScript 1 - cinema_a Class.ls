property pAnimCounter, pAnimList, pCurrentFrm

on construct me
  pAnimCounter = 0
  pCurrentFrm = 1
  pAnimList = [2, 3, 4, 5, 6, 7, 8, 9, 10]
  receiveUpdate(me.getID())
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("teleport")
  registerProcedure(tSpr, #eventProc, me.getID(), #mouseUp)
  return 1
end

on deconstruct me
  return removeUpdate(me.getID())
end

on eventProc me
  if connectionExists(getVariable("connection.room.id")) then
    tloc = getThread(#room).getComponent().getOwnUser().getLocation()
    tLocY = tloc[2]
    if tLocY > 2 then
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 3, #short: 2])
    else
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short: 7, #short: 0])
    end if
  end if
end

on update me
  if pAnimCounter > 2 then
    tNextFrm = pAnimList[random(pAnimList.count)]
    pAnimList.deleteOne(tNextFrm)
    pAnimList.add(pCurrentFrm)
    pCurrentFrm = tNextFrm
    tmember = member(getmemnum("fount" & pCurrentFrm))
    tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
    if not tRoomVis then
      return 0
    end if
    tRoomVis.getSprById("fountain").setMember(tmember)
    pAnimCounter = 0
  end if
  pAnimCounter = pAnimCounter + 1
end
