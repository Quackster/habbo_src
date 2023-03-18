property pTokenList

on prepare me
  pTokenList = value(getVariable("obj_" & me.pClass))
  if not listp(pTokenList) then
    pTokenList = [1]
  end if
  return 1
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
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY + 1])
      end if
    0:
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY - 1])
      end if
    2:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX + 1, #short: me.pLocY])
      end if
    6:
      if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX - 1, #short: me.pLocY])
      end if
  end case
  return 1
end

on giveDrink me
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return 0
  end if
  tConnection.send("LOOKTO", me.pLocX && me.pLocY)
  tConnection.send("CARRYDRINK", me.getDrinkname())
end

on getDrinkname me
  return pTokenList[random(pTokenList.count)]
end
