property pDoorTimer

on prepare me
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    pDoorTimer = 0
    me.openCloseDoor(#close)
  else
    pDoorTimer = 43
    me.openCloseDoor(#open)
  end if
end

on select me
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return 1
  end if
  case me.pDirection[1] of
    4:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY + 1])
      end if
    0:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY - 1])
      end if
    2:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX + 1, #integer: me.pLocY])
      end if
    6:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX - 1, #integer: me.pLocY])
      end if
  end case
  return 1
end

on giveDrink me
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return 0
  end if
  tConnection.send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
end

on openCloseDoor me, tOpen
  if (tOpen = #open) or (tOpen = 1) then
    tFrame = 1
  else
    tFrame = 0
  end if
  repeat with tsprite in me.pSprList
    tCurName = tsprite.member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & tFrame
    if memberExists(tNewName) then
      tMem = member(getmemnum(tNewName))
      tsprite.member = tMem
      tsprite.width = tMem.width
      tsprite.height = tMem.height
    end if
  end repeat
end

on update me
  if pDoorTimer <> 0 then
    if me.pSprList.count < 1 then
      return 
    end if
    pDoorTimer = pDoorTimer - 1
    if pDoorTimer = 0 then
      me.openCloseDoor(#close)
    end if
  end if
end
