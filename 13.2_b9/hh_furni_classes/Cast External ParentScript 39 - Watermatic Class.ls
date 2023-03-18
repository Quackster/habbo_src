property pTokenList

on prepare me
  pTokenList = value(getVariable("obj_" & me.pClass, "water"))
  if not listp(pTokenList) then
    pTokenList = [7]
  end if
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
  case me.pDirection[1] of
    4:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY + 1])
      end if
    0:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.locX, #short: me.pLocY - 1])
      end if
    2:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX + 1, #short: me.pLocY])
      end if
    6:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX - 1, #short: me.pLocY])
      end if
  end case
  return 1
end

on giveDrink me
  getThread(#room).getComponent().getRoomConnection().send("LOOKTO", me.pLocX && me.pLocY)
  getThread(#room).getComponent().getRoomConnection().send("CARRYDRINK", pTokenList[random(pTokenList.count)])
end
