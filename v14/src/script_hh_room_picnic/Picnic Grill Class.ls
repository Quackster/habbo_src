property pTokenList, pActiveSpots

on prepare me 
  pTokenList = value(getVariable("obj_" & me.pClass, "fireplace2"))
  if not listp(pTokenList) then
    pTokenList = [7]
  end if
  pActiveSpots = [[0, 1], [1, 0], [2, -1], [2, -2], [2, -3], [1, -4], [0, -4]]
  return TRUE
end

on select me 
  if not threadExists(#room) then
    return(error(me, "Room thread not found!!!", #select))
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return(error(me, "User object not found:" && getObject(#session).GET("user_name"), #select))
  end if
  repeat while pActiveSpots <= 1
    tSpot = getAt(1, count(pActiveSpots))
    if ((me.pLocX + tSpot.getAt(1)) = tUserObj.pLocX) and ((me.pLocY + tSpot.getAt(2)) = tUserObj.pLocY) then
      me.giveItem()
      return TRUE
    end if
  end repeat
end

on giveItem me 
  getThread(#room).getComponent().getRoomConnection().send("LOOKTO", me.pLocX && me.pLocY)
  getThread(#room).getComponent().getRoomConnection().send("CARRYDRINK", pTokenList.getAt(random(pTokenList.count)))
end
