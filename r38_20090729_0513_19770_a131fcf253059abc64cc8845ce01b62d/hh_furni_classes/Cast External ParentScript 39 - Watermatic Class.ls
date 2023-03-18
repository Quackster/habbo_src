on prepare me
  return 1
end

on select me
  if not threadExists(#room) then
    return error(me, "Room thread not found!!!", #select, #major)
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return error(me, "User object not found:" && getObject(#session).GET("user_name"), #select, #major)
  end if
  case me.pDirection[1] of
    4:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY + 1])
      end if
    0:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.locX, #integer: me.pLocY - 1])
      end if
    2:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX + 1, #integer: me.pLocY])
      end if
    6:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
        me.giveDrink()
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
  tConnection.send("CARRYOBJECT", [#integer: 7])
end
