on construct me 
  getThread(#room).getComponent().getClassContainer().set("hububar", ["Passive Object Class", "Hububar Class"])
  initThread("hubu.index")
  return(1)
end

on deconstruct me 
  closeThread(#hubu)
  return(1)
end

on prepare me 
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  repeat while ["goawaybus"] <= undefined
    tID = getAt(undefined, undefined)
    tsprite = tRoomVis.getSprById(tID)
    registerProcedure(tsprite, #busTeleport, me.getID(), #mouseDown)
  end repeat
end

on showprogram me, tMsg 
  if voidp(tMsg) then
    return(0)
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPar = tMsg.getAt(#show_params)
end

on busTeleport me, tEvent, tSprID, tParm 
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return(0)
  end if
  if tSprID = "goawaybus" then
    tConnection.send("CHANGEWORLD", "0")
  end if
end
