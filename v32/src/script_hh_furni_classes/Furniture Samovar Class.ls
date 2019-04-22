on prepare(me)
  return(1)
  exit
end

on select(me)
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return(1)
  end if
  if me = 4 then
    if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = -1 then
      if the doubleClick then
        me.giveDrink()
      end if
    else
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer:me.pLocX, #integer:me.pLocY + 1])
    end if
  else
    if me = 0 then
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = 1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer:me.pLocX, #integer:me.pLocY - 1])
      end if
    else
      if me = 2 then
        if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = -1 then
          if the doubleClick then
            me.giveDrink()
          end if
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer:me.pLocX + 1, #integer:me.pLocY])
        end if
      else
        if me = 6 then
          if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = 1 then
            if the doubleClick then
              me.giveDrink()
            end if
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer:me.pLocX - 1, #integer:me.pLocY])
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on giveDrink(me)
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return(0)
  end if
  tConnection.send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  exit
end