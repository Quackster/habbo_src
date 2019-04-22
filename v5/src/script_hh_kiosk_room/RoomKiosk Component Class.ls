property pState

on construct me 
  return(me.updateState("start"))
end

on deconstruct me 
  return(me.updateState("reset"))
end

on showHideRoomKiosk me 
  return(me.getInterface().showHideRoomKiosk())
end

on sendNewRoomData me, tFlatData 
  if connectionExists(getVariable("connection.info.id")) then
    return(getConnection(getVariable("connection.info.id")).send(#info, "CREATEFLAT" && tFlatData))
  else
    return(0)
  end if
end

on sendSetFlatInfo me, tFlatMsg 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send(#info, "SETFLATINFO" && tFlatMsg)
  else
    return(0)
  end if
end

on updateState me, tstate, tProps 
  if tstate = "reset" then
    pState = tstate
    return(unregisterMessage(#open_roomkiosk, me.getID()))
  else
    if tstate = "start" then
      pState = tstate
      return(registerMessage(#open_roomkiosk, me.getID(), #showHideRoomKiosk))
    else
      return(error(me, "Unknown state:" && tstate, #updateState))
    end if
  end if
end

on getState me 
  return(pState)
end
