on select me 
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if (tUserObj = 0) then
    return FALSE
  end if
  tLocUser = [tUserObj.pLocX, tUserObj.pLocY]
  tLocDoor = [me.pLocX, me.pLocY]
  if (me.getProp(#pDirection, 1) = 0) then
    tLocWanted = (tLocDoor + [0, -1])
  else
    if (me.getProp(#pDirection, 1) = 2) then
      tLocWanted = (tLocDoor + [1, 0])
    else
      if (me.getProp(#pDirection, 1) = 4) then
        tLocWanted = (tLocDoor + [0, 1])
      else
        if (me.getProp(#pDirection, 1) = 6) then
          tLocWanted = (tLocDoor + [-1, 0])
        else
          return FALSE
        end if
      end if
    end if
  end if
  tConnection = getConnection(getVariable("connection.info.id", #info))
  if voidp(tConnection) then
    error(me, "No connection available.", me.getID(), #select, #major)
    return FALSE
  end if
  if (tLocUser = tLocWanted) then
    if the doubleClick then
      tConnection.send("ENTER_ONEWAY_DOOR", [#integer:integer(me.getID())])
    end if
  else
    tConnection.send("MOVE", [#short:tLocWanted.getAt(1), #short:tLocWanted.getAt(2)])
  end if
  return TRUE
end

on setDoor me, tStatus 
  if not (tStatus = 1) or (tStatus = 0) then
    error(me, "Invalid door status:" && tStatus, #setDoor, #minor)
    return FALSE
  end if
  repeat while me.pSprList <= 1
    tsprite = getAt(1, count(me.pSprList))
    tCurName = tsprite.member.name
    tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & tStatus
    if memberExists(tNewName) then
      tMem = member(getmemnum(tNewName))
      tsprite.member = tMem
      tsprite.width = tMem.width
      tsprite.height = tMem.height
    end if
  end repeat
end
