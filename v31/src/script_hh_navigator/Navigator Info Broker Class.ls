property pClientList

on construct me 
  pClientList = [:]
  registerMessage(#requestRoomData, me.getID(), #requestRoomData)
end

on deconstruct me 
  pClientList = void()
  unregisterMessage(#requestRoomData, me.getID())
end

on requestRoomData me, tRoomID, ttype, tCallback 
  tNavComponent = me.getNavComponent()
  if (tNavComponent = 0) then
    return FALSE
  end if
  if (tRoomID = void()) then
    return(error(me, "Must specify room ID.", #requestRoomData, #major))
  end if
  if not listp(tCallback) then
    return(error(me, "Callback list in format [obj, handler] expected.", #requestRoomData, #major))
  end if
  if voidp(tCallback.getAt(1)) or voidp(tCallback.getAt(2)) then
    return(error(me, "Callback list in format [obj, handler] expected.", #requestRoomData, #major))
  end if
  if (ttype = #private) and not tRoomID contains "f_" then
    tID = "f_" & tRoomID
  else
    tID = tRoomID
  end if
  if (pClientList.findPos(tID) = 0) then
    pClientList.addProp(tID, [])
  end if
  tList = pClientList.getAt(tID)
  tList.append(tCallback)
  if (ttype = #private) then
    return(tNavComponent.sendGetFlatInfo(tRoomID))
  else
    return(tNavComponent.sendNavigate(tRoomID, 1, 0))
  end if
end

on processNavigatorData me, tdata 
  if not listp(tdata) then
    return FALSE
  end if
  tList = pClientList.getAt(tdata.getAt(#id))
  pClientList.deleteProp(tdata.getAt(#id))
  if (tList = void()) then
    return TRUE
  end if
  repeat while tList <= undefined
    tCallback = getAt(undefined, tdata)
    tTargetObject = getObject(tCallback.getAt(1))
    tTargetMethod = tCallback.getAt(2)
    if tTargetObject <> 0 then
      call(tTargetMethod, tTargetObject, tdata)
    end if
  end repeat
  return TRUE
end

on getNavComponent me 
  tObject = getObject(#navigator_component)
  if (tObject = 0) then
    return(error(me, "Navigator component not found!", #getNavigator, #major))
  end if
  return(tObject)
end
