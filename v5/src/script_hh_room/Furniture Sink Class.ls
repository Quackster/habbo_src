on prepare(me)
  tTokenList = getText("obj_" & me.pClass, "water")
  pTokenList = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tTokenList.count(#item)
    pTokenList.add(tTokenList.getPropRef(#item, i).getProp(#word, 1, tTokenList.getPropRef(#item, i).count(#word)))
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "TRUE" then
    pDoorTimer = 80
  else
    pDoorTimer = 0
  end if
  exit
end

on select(me)
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  if tUserObj = 0 then
    return(1)
  end if
  if me = 4 then
    if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = -1 then
      if the doubleClick then
        me.giveDrink()
      end if
    else
      getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY + 1)
    end if
  else
    if me = 0 then
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = 1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.locX && me.pLocY - 1)
      end if
    else
      if me = 2 then
        if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = -1 then
          if the doubleClick then
            me.giveDrink()
          end if
        else
          getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX + 1 && me.pLocY)
        end if
      else
        if me = 6 then
          if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = 1 then
            if the doubleClick then
              me.giveDrink()
            end if
          else
            getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX - 1 && me.pLocY)
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
  tConnection.send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "DOOROPEN" & "/" & "TRUE")
  tConnection.send(#room, "LOOKTO" && me.pLocX && me.pLocY)
  tConnection.send(#room, "CarryDrink" && me.getDrinkname())
  exit
end

on getDrinkname(me)
  return(pTokenList.getAt(random(pTokenList.count)))
  exit
end

on update(me)
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
  exit
end