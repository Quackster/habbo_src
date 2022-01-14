property pTokenList, pDoorTimer

on prepare me 
  pTokenList = [getText("handitem2", "handitem2"), getText("handitem5", "handitem5"), getText("handitem7", "handitem7")]
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
  if the doubleClick then
    tUserObj = getThread(#room).getComponent().getOwnUser()
    if (tUserObj = 0) then
      return FALSE
    end if
    if (me.getProp(#pDirection, 1) = 4) then
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY + 1)])
      end if
    else
      if (me.getProp(#pDirection, 1) = 0) then
        if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
          me.giveDrink()
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY - 1)])
        end if
      else
        if (me.getProp(#pDirection, 1) = 2) then
          if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
            me.giveDrink()
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX + 1), #short:me.pLocY])
          end if
        else
          if (me.getProp(#pDirection, 1) = 6) then
            if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
              me.giveDrink()
            else
              getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX - 1), #short:me.pLocY])
            end if
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on giveDrink me 
  tConnection = getThread(#room).getComponent().getRoomConnection()
  tConnection.send("SETSTUFFDATA", me.getID() & "/" & "DOOROPEN" & "/" & "TRUE")
  tConnection.send("LOOKTO", me.pLocX && me.pLocY)
  tConnection.send("CARRYDRINK", me.getDrinkname())
end

on getDrinkname me 
  return(pTokenList.getAt(random(pTokenList.count)))
end

on update me 
  if (me.count(#pSprList) = 0) then
    return()
  end if
  if pDoorTimer <> 0 then
    tName = me.getPropRef(#pSprList, 1).member.name
    tNewName = tName.getProp(#char, 1, (tName.length - 1)) & 1
    me.getPropRef(#pSprList, 1).castNum = abs(getmemnum(tNewName))
    pDoorTimer = (pDoorTimer - 1)
    if (pDoorTimer = 0) then
      tName = me.getPropRef(#pSprList, 1).member.name
      tNewName = tName.getProp(#char, 1, (tName.length - 1)) & 0
      me.getPropRef(#pSprList, 1).castNum = getmemnum(tNewName)
    end if
  end if
end
