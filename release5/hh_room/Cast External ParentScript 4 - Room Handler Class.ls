on handle_error me, tMsg, tConnection
  error(me, tConnection & ":" && tMsg, #handle_error)
  case tMsg of
    "Incorrect flat password":
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().flatAccessResult(tMsg)
      end if
    "Password required":
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().flatAccessResult(tMsg)
      end if
    "weird error":
      executeMessage(#leaveRoom)
    "Not owner":
      getObject(#session).set("room_controller", 0)
      me.getInterface().hideInterface(#hide)
    otherwise:
      if tMsg contains "Version not correct." then
        executeMessage(#leaveRoom)
      end if
  end case
end

on handle_users me, tList
  if count(tList) = 0 then
    me.getComponent().validateUserObjects(0)
  else
    repeat with tuser in tList
      me.getComponent().validateUserObjects(tuser)
    end repeat
    tName = getObject(#session).get(#userName)
    if not voidp(tList[tName]) then
      me.getInterface().eventProcUserObj(#selection, tName)
    end if
  end if
end

on handle_OBJECTS me, tList
  if count(tList) > 0 then
    repeat with tObj in tList
      me.getComponent().validatePassiveObjects(tObj)
    end repeat
  else
    me.getComponent().validatePassiveObjects(0)
  end if
end

on handle_active_objects me, tList
  if count(tList) > 0 then
    repeat with tObj in tList
      me.getComponent().validateActiveObjects(tObj)
    end repeat
  else
    me.getComponent().validateActiveObjects(0)
  end if
end

on handle_activeobject_update me, tObj
  if me.getComponent().activeObjectExists(tObj[#id]) then
    me.getComponent().getActiveObject(tObj[#id]).define(tObj)
  else
    return error(me, "Active object not found:" && tObj[#id], #handle_activeobject_update)
  end if
end

on handle_items me, tList
  if count(tList) > 0 then
    repeat with tItem in tList
      me.getComponent().validateItemObjects(tItem)
    end repeat
  else
    me.getComponent().validateItemObjects(0)
  end if
end

on handle_stuffdataupdate me, tMsg
  if me.getComponent().activeObjectExists(tMsg[#target]) then
    call(#updateStuffdata, [me.getComponent().getActiveObject(tMsg[#target])], tMsg[#key], tMsg[#value])
  else
    return error(me, "Active object not found:" && tMsg[#target], #handle_stuffdataupdate)
  end if
end

on handle_presentopen me, tMsg
  tCardObj = "PackageCardObj"
  if objectExists(tCardObj) then
    getObject(tCardObj).showContent(tMsg)
  else
    error(me, "Package card obj not found!", #handle_presentopen)
  end if
end

on handle_stripinfo me, tMsg
  tInventory = me.getInterface().getContainer()
  tInventory.updateStripItems(tMsg[#objects])
  tInventory.setStripItemCount(tMsg[#count])
  tInventory.open(1)
  tInventory.refresh()
end

on handle_addstripitem me, tMsg
  tInventory = me.getInterface().getContainer()
  tInventory.appendStripItem(tMsg[#objects][1])
  tInventory.open(1)
  tInventory.refresh()
end

on handle_door_in me, tMsg
  tDoorObj = me.getComponent().getActiveObject(tMsg[#door])
  if tDoorObj <> 0 then
    tDoorObj.animate(18)
    if getObject(#session).get("user_name") = tMsg[#user] then
      tDoorObj.prepareToKick(tMsg[#user])
    end if
  else
    return 0
  end if
end

on handle_door_out me, tMsg
  tDoorObj = me.getComponent().getActiveObject(tMsg[#door])
  if tDoorObj <> 0 then
    tDoorObj.animate()
  else
    return 0
  end if
end

on handle_doorflat me, tMsg
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).get("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if tDoorObj <> 0 then
      tDoorObj.startTeleport(tMsg)
    end if
  end if
end
