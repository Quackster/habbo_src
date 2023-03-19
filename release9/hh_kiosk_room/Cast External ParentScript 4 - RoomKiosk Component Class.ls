property pState, pValidPartProps, pValidPartGroups

on construct me
  return me.updateState("start")
end

on deconstruct me
  return me.updateState("reset")
end

on showHideRoomKiosk me
  return me.getInterface().showHideRoomKiosk()
end

on sendNewRoomData me, tFlatData
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("CREATEFLAT", tFlatData)
  else
    return 0
  end if
end

on sendSetFlatInfo me, tFlatMsg
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("SETFLATINFO", tFlatMsg)
  else
    return 0
  end if
end

on sendFlatCategory me, tNodeId, tCategoryId
  if voidp(tNodeId) then
    return error(me, "Node ID expected!", #sendFlatCategory)
  end if
  if voidp(tCategoryId) then
    return error(me, "Category ID expected!", #sendFlatCategory)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("SETFLATCAT", [#integer: integer(tNodeId), #integer: integer(tCategoryId)])
  else
    return 0
  end if
end

on updateState me, tstate, tProps
  case tstate of
    "reset":
      pState = tstate
      return unregisterMessage(#open_roomkiosk, me.getID())
    "start":
      pState = tstate
      return registerMessage(#open_roomkiosk, me.getID(), #showHideRoomKiosk)
    otherwise:
      return error(me, "Unknown state:" && tstate, #updateState)
  end case
end

on getState me
  return pState
end
