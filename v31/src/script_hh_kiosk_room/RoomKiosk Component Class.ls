on construct(me)
  registerMessage(#userlogin, me.getID(), #checkWebShortcuts)
  return(me.updateState("start"))
  exit
end

on deconstruct(me)
  unregisterMessage(#userlogin, me.getID())
  return(me.updateState("reset"))
  exit
end

on showHideRoomKiosk(me)
  return(me.getInterface().showHideRoomKiosk())
  exit
end

on sendNewRoomData(me, tName, tMarker, tDoorinfo, tShowOwnerName)
  if connectionExists(getVariable("connection.info.id")) then
    if not integerp(integer(tShowOwnerName)) then
      return(error(me, #sendNewRoomData, "Illegal type for showOwnerName, must be number", #major))
    end if
    return(getConnection(getVariable("connection.info.id")).send("CREATEFLAT", [#string:tName, #string:tMarker, #string:tDoorinfo, #integer:integer(tShowOwnerName)]))
  else
    return(0)
  end if
  exit
end

on sendSetFlatInfo(me, tFlatID, tDesc, tPassword, tAbleToMoveFurniture, tMaxVisitors)
  if connectionExists(getVariable("connection.info.id")) then
    if voidp(tPassword) then
      tPassword = ""
    end if
    tMsg = []
    tMsg.addProp(#integer, integer(tFlatID))
    tMsg.addProp(#string, tDesc)
    tMsg.addProp(#string, tPassword)
    tMsg.addProp(#integer, integer(tAbleToMoveFurniture))
    if not voidp(tMaxVisitors) then
      tMsg.addProp(#integer, integer(tMaxVisitors))
    end if
    getConnection(getVariable("connection.info.id")).send("SETFLATINFO", tMsg)
  else
    return(0)
  end if
  exit
end

on sendFlatCategory(me, tNodeId, tCategoryID)
  if voidp(tNodeId) then
    return(error(me, "Node ID expected!", #sendFlatCategory, #major))
  end if
  if voidp(tCategoryID) then
    return(error(me, "Category ID expected!", #sendFlatCategory, #major))
  end if
  if connectionExists(getVariable("connection.info.id")) then
    return(getConnection(getVariable("connection.info.id")).send("SETFLATCAT", [#integer:integer(tNodeId), #integer:integer(tCategoryID)]))
  else
    return(0)
  end if
  exit
end

on updateState(me, tstate, tProps)
  if me = "reset" then
    pState = tstate
    return(unregisterMessage(#open_roomkiosk, me.getID()))
  else
    if me = "start" then
      pState = tstate
      return(registerMessage(#open_roomkiosk, me.getID(), #showHideRoomKiosk))
    else
      return(error(me, "Unknown state:" && tstate, #updateState, #minor))
    end if
  end if
  exit
end

on getState(me)
  return(pState)
  exit
end

on checkWebShortcuts(me, tChecked)
  if tChecked = 1 then
    executeMessage(#open_roomkiosk)
    return(1)
  end if
  if variableExists("shortcut.id") then
    tShortcutID = getIntVariable("shortcut.id")
    if tShortcutID = 1 then
      tTimeoutID = #roommatic_opening_timeout
      if not timeoutExists(tTimeoutID) then
        createTimeout(#tTimeoutID, 2500, #checkWebShortcuts, me.getID(), 1, 1)
      end if
    end if
  end if
  return(1)
  exit
end