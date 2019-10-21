on handle_error me, tMsg, tConnection 
  error(me, tConnection & ":" && tMsg, #handle_error)
  if (tMsg = "Incorrect flat password") then
    if threadExists(#navigator) then
      getThread(#navigator).getComponent().flatAccessResult(tMsg)
    end if
  else
    if (tMsg = "Password required") then
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().flatAccessResult(tMsg)
      end if
    else
      if (tMsg = "weird error") then
        executeMessage(#leaveRoom)
      else
        if (tMsg = "Not owner") then
          getObject(#session).set("room_controller", 0)
          me.getInterface().hideInterface(#hide)
        else
          if tMsg contains "Version not correct." then
            executeMessage(#leaveRoom)
          end if
        end if
      end if
    end if
  end if
end

on handle_users me, tList 
  if (count(tList) = 0) then
    me.getComponent().validateUserObjects(0)
  else
    repeat while tList <= undefined
      tuser = getAt(undefined, tList)
      me.getComponent().validateUserObjects(tuser)
    end repeat
    tName = getObject(#session).get(#userName)
    if not voidp(tList.getAt(tName)) then
      me.getInterface().eventProcUserObj(#selection, tName)
    end if
  end if
end

on handle_OBJECTS me, tList 
  if count(tList) > 0 then
    repeat while tList <= undefined
      tObj = getAt(undefined, tList)
      me.getComponent().validatePassiveObjects(tObj)
    end repeat
  else
    me.getComponent().validatePassiveObjects(0)
  end if
end

on handle_active_objects me, tList 
  if count(tList) > 0 then
    repeat while tList <= undefined
      tObj = getAt(undefined, tList)
      me.getComponent().validateActiveObjects(tObj)
    end repeat
  else
    me.getComponent().validateActiveObjects(0)
  end if
end

on handle_activeobject_update me, tObj 
  if me.getComponent().activeObjectExists(tObj.getAt(#id)) then
    me.getComponent().getActiveObject(tObj.getAt(#id)).define(tObj)
  else
    return(error(me, "Active object not found:" && tObj.getAt(#id), #handle_activeobject_update))
  end if
end

on handle_items me, tList 
  if count(tList) > 0 then
    repeat while tList <= undefined
      tItem = getAt(undefined, tList)
      me.getComponent().validateItemObjects(tItem)
    end repeat
  else
    me.getComponent().validateItemObjects(0)
  end if
end

on handle_stuffdataupdate me, tMsg 
  if me.getComponent().activeObjectExists(tMsg.getAt(#target)) then
    call(#updateStuffdata, [me.getComponent().getActiveObject(tMsg.getAt(#target))], tMsg.getAt(#key), tMsg.getAt(#value))
  else
    return(error(me, "Active object not found:" && tMsg.getAt(#target), #handle_stuffdataupdate))
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
  tInventory.updateStripItems(tMsg.getAt(#objects))
  tInventory.setStripItemCount(tMsg.getAt(#count))
  tInventory.open(1)
  tInventory.refresh()
end

on handle_addstripitem me, tMsg 
  tInventory = me.getInterface().getContainer()
  tInventory.appendStripItem(tMsg.getAt(#objects).getAt(1))
  tInventory.open(1)
  tInventory.refresh()
end

on handle_door_in me, tMsg 
  tDoorObj = me.getComponent().getActiveObject(tMsg.getAt(#door))
  if tDoorObj <> 0 then
    tDoorObj.animate(18)
    if (getObject(#session).get("user_name") = tMsg.getAt(#user)) then
      tDoorObj.prepareToKick(tMsg.getAt(#user))
    end if
  else
    return FALSE
  end if
end

on handle_door_out me, tMsg 
  tDoorObj = me.getComponent().getActiveObject(tMsg.getAt(#door))
  if tDoorObj <> 0 then
    tDoorObj.animate()
  else
    return FALSE
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
