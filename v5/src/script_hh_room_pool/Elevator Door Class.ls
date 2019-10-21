on construct(me)
  pMode = #close
  return(1)
  exit
end

on setDoorMode(me, tMode)
  pMode = symbol(tMode)
  me.updateDoor()
  exit
end

on updateDoor(me)
  if pMode = #open then
    tMem = member(getmemnum("towerdoor_2"))
  else
    tMem = member(getmemnum("towerdoor_0"))
  end if
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if tRoomVis = 0 or tMem = 0 then
    return(0)
  end if
  tRoomVis.getSprById("lift_door").setMember(tMem)
  exit
end