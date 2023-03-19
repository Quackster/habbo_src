property pTokenList, pActiveSpots

on prepare me
  pTokenList = value(getVariable("obj_" & me.pClass, "fireplace2"))
  if not listp(pTokenList) then
    pTokenList = [7]
  end if
  pActiveSpots = [[0, 1], [1, 0], [2, -1], [2, -2], [2, -3], [1, -4], [0, -4]]
  return 1
end

on select me
  if not threadExists(#room) then
    return error(me, "Room thread not found!!!", #select)
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return error(me, "User object not found:" && getObject(#session).GET("user_name"), #select)
  end if
  repeat with tSpot in pActiveSpots
    if ((me.pLocX + tSpot[1]) = tUserObj.pLocX) and ((me.pLocY + tSpot[2]) = tUserObj.pLocY) then
      me.giveItem()
      return 1
    end if
  end repeat
end

on giveItem me
  getThread(#room).getComponent().getRoomConnection().send("LOOKTO", [#integer: integer(me.pLocX), #integer: integer(me.pLocY)])
  getThread(#room).getComponent().getRoomConnection().send("CARRYOBJECT", [#integer: integer(pTokenList[random(pTokenList.count)])])
end
