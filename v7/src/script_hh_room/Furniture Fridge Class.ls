property pTokenList, pDoorTimer

on prepare me 
  pTokenList = value(getVariable("obj_" & me.pClass))
  if not listp(pTokenList) then
    pTokenList = [3]
  end if
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if (tValue = "TRUE") then
    pDoorTimer = 43
  else
    pDoorTimer = 0
  end if
end

on select me 
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if (tUserObj = 0) then
    return TRUE
  end if
  if (me.getProp(#pDirection, 1) = 4) then
    if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
      if the doubleClick then
        me.giveDrink()
      end if
    else
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY + 1)])
    end if
  else
    if (me.getProp(#pDirection, 1) = 0) then
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY - 1)])
      end if
    else
      if (me.getProp(#pDirection, 1) = 2) then
        if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
          if the doubleClick then
            me.giveDrink()
          end if
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX + 1), #short:me.pLocY])
        end if
      else
        if (me.getProp(#pDirection, 1) = 6) then
          if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
            if the doubleClick then
              me.giveDrink()
            end if
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX - 1), #short:me.pLocY])
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on giveDrink me 
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if (tConnection = 0) then
    return FALSE
  end if
  tConnection.send("SETSTUFFDATA", me.getID() & "/" & "DOOROPEN" & "/" & "TRUE")
  tConnection.send("LOOKTO", me.pLocX && me.pLocY)
  tConnection.send("CARRYDRINK", me.getDrinkname())
end

on getDrinkname me 
  return(pTokenList.getAt(random(pTokenList.count)))
end

on update me 
  if pDoorTimer <> 0 then
    if me.count(#pSprList) < 1 then
      return()
    end if
    tCurName = me.getPropRef(#pSprList, 1).member.name
    tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & 1
    tmember = member(abs(getmemnum(tNewName)))
    pDoorTimer = (pDoorTimer - 1)
    if (pDoorTimer = 0) then
      tCurName = me.getPropRef(#pSprList, 1).member.name
      tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 1)) & 0
      tmember = member(getmemnum(tNewName))
    end if
    me.getPropRef(#pSprList, 1).castNum = tmember.number
    me.getPropRef(#pSprList, 1).width = tmember.width
    me.getPropRef(#pSprList, 1).height = tmember.height
  end if
end
