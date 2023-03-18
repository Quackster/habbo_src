property pmode

on construct me
  pmode = #close
  return 1
end

on setDoorMode me, tMode
  pmode = symbol(tMode)
  me.updateDoor()
end

on updateDoor me
  if pmode = #open then
    tMem = member(getmemnum("towerdoor_2"))
  else
    tMem = member(getmemnum("towerdoor_0"))
  end if
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if (tRoomVis = 0) or (tMem = 0) then
    return 0
  end if
  tRoomVis.getSprById("lift_door").setMember(tMem)
end
