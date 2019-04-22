on prepare(me, tdata)
  pChanges = 1
  pAnimStart = 0
  pValue = integer(tdata.getAt(#stuffdata))
  if not integerp(pValue) then
    pValue = 1
  end if
  if pValue > 6 or pValue < 0 then
    pValue = 0
  end if
  me.update()
  return(1)
  exit
end

on select(me)
  if me.count(#pSprList) < 2 then
    return(0)
  end if
  if rollover(me.getProp(#pSprList, 2)) then
    if the doubleClick then
      tUserObj = getThread(#room).getComponent().getOwnUser()
      if not tUserObj then
        return(1)
      end if
      if abs(tUserObj.pLocX - me.pLocX) > 1 or abs(tUserObj.pLocY - me.pLocY) > 1 then
        tX = me.pLocX - 1
        repeat while tX <= me.pLocX + 1
          tY = me.pLocY - 1
          repeat while tY <= me.pLocY + 1
            if tY = me.pLocY or tX = me.pLocX then
              if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
                getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer:tX, #integer:tY])
                return(1)
              end if
            end if
            tY = 1 + tY
          end repeat
          tX = 1 + tX
        end repeat
        exit repeat
      end if
      if pActive = 0 then
        getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", [#integer:integer(me.getID())])
      end if
    end if
  else
    if rollover(me.getProp(#pSprList, 1)) and the doubleClick and pActive = 0 then
      getThread(#room).getComponent().getRoomConnection().send("DICE_OFF", [#integer:integer(me.getID())])
      return(1)
    end if
  end if
  return(1)
  exit
end

on diceThrown(me, tValue)
  pChanges = 1
  pValue = tValue
  if pValue < 0 then
    pValue = 0
    pActive = 1
  end if
  if pValue > 6 then
    pValue = 0
    pActive = 0
  end if
  return(1)
  exit
end

on update(me)
  if me.count(#pSprList) < 3 then
    return()
  end if
  if pChanges = 0 then
    return()
  end if
  tName = member.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tClass = tName.getProp(#item, 1, tName.count(#item) - 6)
  the itemDelimiter = tDelim
  if pActive then
    tSprite1 = me.getProp(#pSprList, 2)
    tSprite2 = me.getProp(#pSprList, 3)
    tMember2 = member(getmemnum(tClass & "_c_0_1_1_0_1"))
    if pValue <= 0 then
      if tSprite1.castNum = getmemnum(tClass & "_b_0_1_1_0_7") then
        tMember1 = member(getmemnum(tClass & "_b_0_1_1_0_0"))
      else
        tMember1 = member(getmemnum(tClass & "_b_0_1_1_0_7"))
      end if
    else
      tMember1 = member(getmemnum(tClass & "_b_0_1_1_0_" & pValue))
      pActive = 0
      pChanges = 1
    end if
  else
    tSprite1 = me.getProp(#pSprList, 2)
    tSprite2 = me.getProp(#pSprList, 3)
    tMember1 = tSprite1.member
    if integer(pValue) = 0 then
      tMember2 = member(getmemnum(tClass & "_c_0_1_1_0_0"))
    else
      tMember1 = member(getmemnum(tClass & "_b_0_1_1_0_" & pValue))
      tMember2 = member(getmemnum(tClass & "_c_0_1_1_0_1"))
    end if
    pChanges = 0
  end if
  tSprite1.member = tMember1
  tSprite1.width = tMember1.width
  tSprite1.height = tMember1.height
  tSprite2.member = tMember2
  tSprite2.width = tMember2.width
  tSprite2.height = tMember2.height
  return(1)
  exit
end