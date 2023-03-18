on construct me
  getThread(#room).getComponent().getClassContainer().set("hububar", ["Passive Object Class", "Hububar Class"])
  initThread("hubu.index")
  return 1
end

on deconstruct me
  closeThread(#hubu)
  return 1
end

on prepare me
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  repeat with tID in ["goawaybus"]
    tsprite = tRoomVis.getSprById(tID)
    registerProcedure(tsprite, #busTeleport, me.getID(), #mouseDown)
  end repeat
end

on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tDst = tMsg[#show_dest]
  tCmd = tMsg[#show_command]
  tPar = tMsg[#show_params]
end

on busTeleport me, tEvent, tSprID, tParm
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return 0
  end if
  case tSprID of
    "goawaybus":
      tConnection.send("CHANGEWORLD", "0")
  end case
end
