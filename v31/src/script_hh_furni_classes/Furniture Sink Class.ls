property pDoorTimer

on prepare me 
  return(1)
end

on updateStuffdata me, tValue 
  tValue = integer(tValue)
  if tValue = 0 then
    pDoorTimer = 1
  else
    pDoorTimer = 80
  end if
end

on select me 
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return(1)
  end if
  if me.getProp(#pDirection, 1) = 4 then
    if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = -1 then
      if the doubleClick then
        me.giveDrink()
      end if
    else
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY + 1])
    end if
  else
    if me.getProp(#pDirection, 1) = 0 then
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = 1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.locX, #short:me.pLocY - 1])
      end if
    else
      if me.getProp(#pDirection, 1) = 2 then
        if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = -1 then
          if the doubleClick then
            me.giveDrink()
          end if
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX + 1, #short:me.pLocY])
        end if
      else
        if me.getProp(#pDirection, 1) = 6 then
          if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = 1 then
            if the doubleClick then
              me.giveDrink()
            end if
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX - 1, #short:me.pLocY])
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on giveDrink me 
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return(0)
  end if
  tConnection.send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
end

on update me 
  if pDoorTimer <> 0 then
    if me.count(#pSprList) < 2 then
      return()
    end if
    tName = member.name
    tName = tName.getProp(#char, 1, length(tName) - 1) & 1
    tmember = member(abs(getmemnum(tName)))
    pDoorTimer = pDoorTimer - 1
    if pDoorTimer = 0 then
      tName = tName.getProp(#char, 1, length(tName) - 1) & 0
      tmember = member(getmemnum(tName))
    end if
    me.getPropRef(#pSprList, 2).castNum = tmember.number
    me.getPropRef(#pSprList, 2).width = tmember.width
    me.getPropRef(#pSprList, 2).height = tmember.height
  end if
end
