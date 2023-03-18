property pActive, pValue, pAnimStart

on prepare me, tdata
  pActive = 1
  pAnimStart = 0
  if not voidp(tdata["VALUE"]) then
    pValue = tdata["VALUE"]
  else
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
                getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: tX, #move: tY])
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
    if rollover(me.pSprList[1]) and the doubleClick then
      getThread(#room).getComponent().getRoomConnection().send("DICE_OFF", me.getID())
      return 1
    end if
  end if
  return 1
end

on diceThrown me, tValue
  pActive = 1
  pValue = tValue
  if pValue > 0 then
    pAnimStart = the milliSeconds
  end if
end

on update me
  if pActive then
    if me.pSprList.count < 2 then
      return 
    end if
    tSprite = me.pSprList[2]
    if ((the milliSeconds - pAnimStart) < 2000) or ((random(100) = 2) and (pValue <> 0)) then
      if tSprite.castNum = getmemnum("edice_b_0_1_1_0_7") then
        tmember = member(getmemnum("edice_b_0_1_1_0_0"))
      else
        tmember = member(getmemnum("edice_b_0_1_1_0_7"))
      end if
    else
      tmember = member(getmemnum("edice_b_0_1_1_0_" & pValue))
      pActive = 0
    end if
    tSprite.castNum = tmember.number
    tSprite.width = tmember.width
    tSprite.height = tmember.height
  end if
end
