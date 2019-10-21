property pValue, pChanges, pActive, pAnimStart

on prepare me, tdata 
  pChanges = 1
  pAnimStart = 0
  if not voidp(tdata.getAt("VALUE")) then
    pValue = tdata.getAt("VALUE")
  else
    pValue = 0
  end if
  pActive = integer(pValue) > 0
  me.update()
  return TRUE
end

on select me 
  if rollover(me.getProp(#pSprList, 2)) then
    if the doubleClick then
      tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
      if not tUserObj then
        return TRUE
      end if
      if abs((tUserObj.pLocX - me.pLocX)) > 1 or abs((tUserObj.pLocY - me.pLocY)) > 1 then
        tX = (me.pLocX - 1)
        repeat while tX <= (me.pLocX + 1)
          tY = (me.pLocY - 1)
          repeat while tY <= (me.pLocY + 1)
            if (tY = me.pLocY) or (tX = me.pLocX) then
              if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
                getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && tX && tY)
                return TRUE
              end if
            end if
            tY = (1 + tY)
          end repeat
          tX = (1 + tX)
        end repeat
        exit repeat
      end if
      getThread(#room).getComponent().getRoomConnection().send(#room, "THROW_DICE /" & me.getID())
    end if
  else
    if rollover(me.getProp(#pSprList, 1)) and the doubleClick then
      getThread(#room).getComponent().getRoomConnection().send(#room, "DICE_OFF /" & me.getID())
      return TRUE
    end if
  end if
  return TRUE
end

on diceThrown me, tValue 
  pChanges = 1
  pValue = tValue
  if pValue > 0 then
    pActive = 1
    pAnimStart = the milliSeconds
  else
    pActive = 0
  end if
end

on update me 
  if me.count(#pSprList) < 3 then
    return()
  end if
  if (pChanges = 0) then
    return()
  end if
  if pActive then
    tSprite1 = me.getProp(#pSprList, 2)
    tSprite2 = me.getProp(#pSprList, 3)
    tMember1 = member(getmemnum("edicehc_c_0_1_1_0_1"))
    tMember2 = tSprite2.member
    if (the milliSeconds - pAnimStart) < 2000 or (random(100) = 2) and pValue <> 0 then
      if (tSprite1.castNum = getmemnum("edicehc_b_0_1_1_0_7")) then
        tMember1 = member(getmemnum("edicehc_b_0_1_1_0_0"))
      else
        tMember1 = member(getmemnum("edicehc_b_0_1_1_0_7"))
      end if
    else
      tMember1 = member(getmemnum("edicehc_b_0_1_1_0_" & pValue))
      pActive = 0
      pChanges = 1
    end if
  else
    tSprite1 = me.getProp(#pSprList, 2)
    tSprite2 = me.getProp(#pSprList, 3)
    tMember1 = tSprite1.member
    if (integer(pValue) = 0) then
      tMember2 = member(getmemnum("edicehc_c_0_1_1_0_0"))
    else
      tMember1 = member(getmemnum("edicehc_b_0_1_1_0_" & pValue))
      tMember2 = member(getmemnum("edicehc_c_0_1_1_0_1"))
    end if
    pChanges = 0
  end if
  tSprite1.member = tMember1
  tSprite1.width = tMember1.width
  tSprite1.height = tMember1.height
  tSprite2.member = tMember2
  tSprite2.width = tMember2.width
  tSprite2.height = tMember2.height
end
