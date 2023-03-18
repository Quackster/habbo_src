property pTokenList

on prepare me
  tTokenList = getText("obj_" & me.pClass, "water")
  pTokenList = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  repeat with i = 1 to tTokenList.item.count
    pTokenList.add(tTokenList.item[i].word[1..tTokenList.item[i].word.count])
  end repeat
  the itemDelimiter = tDelim
  return 1
end

on select me
  if not threadExists(#room) then
    return error(me, "Room thread not found!!!", #select)
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  if not tUserObj then
    return error(me, "User object not found:" && getObject(#session).get("user_name"), #select)
  end if
  case me.pDirection[1] of
    4:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY + 1)
      end if
    0:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.locX && me.pLocY - 1)
      end if
    2:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX + 1 && me.pLocY)
      end if
    6:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX - 1 && me.pLocY)
      end if
  end case
  return 1
end

on giveDrink me
  getThread(#room).getComponent().getRoomConnection().send(#room, "LOOKTO" && me.pLocX && me.pLocY)
  getThread(#room).getComponent().getRoomConnection().send(#room, "CarryDrink" && pTokenList[random(pTokenList.count)])
end
