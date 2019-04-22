property pTokenList, pActiveSpots

on prepare me 
  pTokenList = value(getVariable("obj_" & me.pClass, "sodagreen"))
  if not listp(pTokenList) then
    pTokenList = [7]
  end if
  pActiveSpots = [[0, 1]]
  return(1)
end

on select me 
  if not threadExists(#room) then
    return(error(me, "Room thread not found!!!", #select))
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return(error(me, "User object not found:" && getObject(#session).GET("user_name"), #select))
  end if
  repeat while pActiveSpots <= undefined
    tSpot = getAt(undefined, undefined)
    if me.pLocX + tSpot.getAt(1) = tUserObj.pLocX and me.pLocY + tSpot.getAt(2) = tUserObj.pLocY then
      me.giveItem()
    end if
  end repeat
  return(1)
end

on giveItem me 
  getThread(#room).getComponent().getRoomConnection().send("LOOKTO", me.pLocX && me.pLocY)
  getThread(#room).getComponent().getRoomConnection().send("CARRYOBJECT", [#integer:integer(pTokenList.getAt(random(pTokenList.count)))])
end
