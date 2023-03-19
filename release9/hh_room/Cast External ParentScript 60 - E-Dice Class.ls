property pActive, pValue

on prepare me, tdata
  pActive = 1
  pValue = integer(tdata[#stuffdata])
  if not integerp(pValue) then
    pValue = 1
  end if
  if pValue > 6 then
    pValue = 6
  end if
  if pValue < 0 then
    pValue = 0
  end if
  return 1
end

on select me
  if me.pSprList.count < 2 then
    return 0
  end if
  if rollover(me.pSprList[2]) then
    if the doubleClick then
      tUserObj = getThread(#room).getComponent().getOwnUser()
      if not tUserObj then
        return 1
      end if
      if (abs(tUserObj.pLocX - me.pLocX) > 1) or (abs(tUserObj.pLocY - me.pLocY) > 1) then
        repeat with tX = me.pLocX - 1 to me.pLocX + 1
          repeat with tY = me.pLocY - 1 to me.pLocY + 1
            if (tY = me.pLocY) or (tX = me.pLocX) then
              if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
                getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: tX, #short: tY])
                return 1
              end if
            end if
          end repeat
        end repeat
      else
        if pActive = 0 then
          getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", me.getID())
        end if
      end if
    end if
  else
    if rollover(me.pSprList[1]) and the doubleClick and (pActive = 0) then
      getThread(#room).getComponent().getRoomConnection().send("DICE_OFF", me.getID())
      return 1
    end if
  end if
  return 1
end

on diceThrown me, tValue
  pActive = 1
  if tValue > 0 then
    pValue = tValue
  else
    pValue = tValue
  end if
end

on update me
  if pActive then
    the itemDelimiter = "_"
    tMemName = me.pSprList[2].member.name
    tClass = tMemName.item[1..tMemName.item.count - 6]
    if me.pSprList.count < 2 then
      return 
    end if
    tsprite = me.pSprList[2]
    if pValue < 0 then
      if tsprite.castNum = getmemnum(tClass & "_b_0_1_1_0_7") then
        tmember = member(getmemnum(tClass & "_b_0_1_1_0_0"))
      else
        tmember = member(getmemnum(tClass & "_b_0_1_1_0_7"))
      end if
    else
      tmember = member(getmemnum(tClass & "_b_0_1_1_0_" & pValue))
      pActive = 0
    end if
    tsprite.castNum = tmember.number
    tsprite.width = tmember.width
    tsprite.height = tmember.height
  end if
end
