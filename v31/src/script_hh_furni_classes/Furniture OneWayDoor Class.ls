on select(me)
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return(0)
  end if
  tLocUser = [tUserObj.pLocX, tUserObj.pLocY]
  tLocDoor = [me.pLocX, me.pLocY]
  if me = 0 then
    tLocWanted = tLocDoor + [0, -1]
  else
    if me = 2 then
      tLocWanted = tLocDoor + [1, 0]
    else
      if me = 4 then
        tLocWanted = tLocDoor + [0, 1]
      else
        if me = 6 then
          tLocWanted = tLocDoor + [-1, 0]
        else
          return(0)
        end if
      end if
    end if
  end if
  tConnection = getConnection(getVariable("connection.info.id", #info))
  if voidp(tConnection) then
    error(me, "No connection available.", me.getID(), #select, #major)
    return(0)
  end if
  if tLocUser = tLocWanted then
    if the doubleClick then
      tConnection.send("ENTER_ONEWAY_DOOR", [#integer:integer(me.getID())])
    end if
  else
    tConnection.send("MOVE", [#short:tLocWanted.getAt(1), #short:tLocWanted.getAt(2)])
  end if
  return(1)
  exit
end

on setDoor(me, tStatus)
  if not tStatus = 1 or tStatus = 0 then
    error(me, "Invalid door status:" && tStatus, #setDoor, #minor)
    return(0)
  end if
  repeat while me <= undefined
    tsprite = getAt(undefined, tStatus)
    tCurName = member.name
    tNewName = tCurName.getProp(#char, 1, length(tCurName) - 1) & tStatus
    if memberExists(tNewName) then
      tMem = member(getmemnum(tNewName))
      tsprite.member = tMem
      tsprite.width = tMem.width
      tsprite.height = tMem.height
    end if
  end repeat
  exit
end