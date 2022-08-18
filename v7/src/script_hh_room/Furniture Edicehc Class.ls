property pActive, pValue, pAnimStart, pChanges

on prepare me, tdata
  pChanges = 1
  pAnimStart = 0
  if not voidp(tdata["VALUE"]) then
    pValue = tdata["VALUE"]
  else
    pValue = 0
  end if
  pActive = (integer(pValue) > 0)
  me.update()
  return 1
end

on select me
  if (me.pSprList.count < 2) then
    return 0
  end if
  if rollover(me.pSprList[2]) then
    if the doubleClick then
      tUserObj = getThread(#room).getComponent().getOwnUser()
      if not tUserObj then
        return 1
      end if
      if ((abs((tUserObj.pLocX - me.pLocX)) > 1) or (abs((tUserObj.pLocY - me.pLocY)) > 1)) then
        repeat with tX = (me.pLocX - 1) to (me.pLocX + 1)
          repeat with tY = (me.pLocY - 1) to (me.pLocY + 1)
            if ((tY = me.pLocY) or (tX = me.pLocX)) then
              if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
                getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: tX, #short: tY])
                return 1
              end if
            end if
          end repeat
        end repeat
      else
        getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", me.getID())
      end if
    end if
  else
    if (rollover(me.pSprList[1]) and the doubleClick) then
      getThread(#room).getComponent().getRoomConnection().send("DICE_OFF", me.getID())
      return 1
    end if
  end if
  return 1
end

on diceThrown me, tValue
  pChanges = 1
  pValue = tValue
  if (pValue > 0) then
    pActive = 1
    pAnimStart = the milliSeconds
  else
    pActive = 0
  end if
end

on update me
  if (me.pSprList.count < 3) then
    return 
  end if
  if (pChanges = 0) then
    return 
  end if
  if pActive then
    tSprite1 = me.pSprList[2]
    tSprite2 = me.pSprList[3]
    tMember1 = member(getmemnum("edicehc_c_0_1_1_0_1"))
    tMember2 = tSprite2.member
    if (((the milliSeconds - pAnimStart) < 2000) or ((random(100) = 2) and (pValue <> 0))) then
      if (tSprite1.castNum = getmemnum("edicehc_b_0_1_1_0_7")) then
        tMember1 = member(getmemnum("edicehc_b_0_1_1_0_0"))
      else
        tMember1 = member(getmemnum("edicehc_b_0_1_1_0_7"))
      end if
    else
      tMember1 = member(getmemnum(("edicehc_b_0_1_1_0_" & pValue)))
      pActive = 0
      pChanges = 1
    end if
  else
    tSprite1 = me.pSprList[2]
    tSprite2 = me.pSprList[3]
    tMember1 = tSprite1.member
    if (integer(pValue) = 0) then
      tMember2 = member(getmemnum("edicehc_c_0_1_1_0_0"))
    else
      tMember1 = member(getmemnum(("edicehc_b_0_1_1_0_" & pValue)))
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
