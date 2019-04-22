on construct(me)
  getThread(#room).getComponent().getClassContainer().set("hububar", ["Passive Object Class", "Hububar Class"])
  initThread("hubu.index")
  return(1)
  exit
end

on deconstruct(me)
  closeThread(#hubu)
  return(1)
  exit
end

on prepare(me)
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  repeat while me <= undefined
    tid = getAt(undefined, undefined)
    tSprite = tRoomVis.getSprById(tid)
    registerProcedure(tSprite, #busTeleport, me.getID(), #mouseDown)
  end repeat
  exit
end

on showprogram(me, tMsg)
  if voidp(tMsg) then
    return(0)
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPar = tMsg.getAt(#show_params)
  exit
end

on busTeleport(me, tEvent, tSprID, tParm)
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return(0)
  end if
  if me = "goawaybus" then
    tConnection.send("CHANGEWORLD", "0")
  end if
  exit
end