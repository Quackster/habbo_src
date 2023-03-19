on select me
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return 0
  end if
  tLocUser = [tUserObj.pLocX, tUserObj.pLocY]
  tLocDoor = [me.pLocX, me.pLocY]
  case me.pDirection[1] of
    0:
      tLocWanted = tLocDoor + [0, -1]
    2:
      tLocWanted = tLocDoor + [1, 0]
    4:
      tLocWanted = tLocDoor + [0, 1]
    6:
      tLocWanted = tLocDoor + [-1, 0]
    otherwise:
      return 0
  end case
  tConnection = getConnection(getVariable("connection.info.id", #Info))
  if voidp(tConnection) then
    error(me, "No connection available.", me.getID(), #select, #major)
    return 0
  end if
  if tLocUser = tLocWanted then
    if the doubleClick then
      tConnection.send("ENTER_ONEWAY_DOOR", [#integer: integer(me.getID())])
    end if
  else
    tConnection.send("MOVE", [#integer: tLocWanted[1], #integer: tLocWanted[2]])
  end if
  return 1
end

on setDoor me, tStatus
  if not ((tStatus = 1) or (tStatus = 0)) then
    error(me, "Invalid door status:" && tStatus, #setDoor, #minor)
    return 0
  end if
  repeat with tsprite in me.pSprList
    tCurName = tsprite.member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & tStatus
    if memberExists(tNewName) then
      tMem = member(getmemnum(tNewName))
      tsprite.member = tMem
      tsprite.width = tMem.width
      tsprite.height = tMem.height
    end if
  end repeat
end
