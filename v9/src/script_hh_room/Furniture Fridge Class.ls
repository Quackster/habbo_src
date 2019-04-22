property pTokenList, pDoorTimer

on prepare me 
  pTokenList = value(getVariable("obj_" & me.pClass))
  if not listp(pTokenList) then
    pTokenList = [3]
  end if
  return(1)
end

on updateStuffdata me, tValue 
  if tValue = "TRUE" then
    pDoorTimer = 43
    me.openCloseDoor(#open)
  else
    pDoorTimer = 0
    me.openCloseDoor(#close)
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
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY - 1])
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
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"TRUE"])
  tConnection.send("LOOKTO", me.pLocX && me.pLocY)
  tConnection.send("CARRYDRINK", me.getDrinkname())
end

on getDrinkname me 
  return(pTokenList.getAt(random(pTokenList.count)))
end

on openCloseDoor me, tOpen 
  if tOpen = #open or tOpen = 1 then
    tFrame = 1
  else
    tFrame = 0
  end if
  repeat while me.pSprList <= undefined
    tsprite = getAt(undefined, tOpen)
    tCurName = tsprite.name
    tNewName = tCurName.getProp(#char, 1, length(tCurName) - 1) & tFrame
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
    if me.count(#pSprList) < 1 then
      return()
    end if
    pDoorTimer = pDoorTimer - 1
    if pDoorTimer = 0 then
      me.openCloseDoor(#close)
    end if
  end if
end
