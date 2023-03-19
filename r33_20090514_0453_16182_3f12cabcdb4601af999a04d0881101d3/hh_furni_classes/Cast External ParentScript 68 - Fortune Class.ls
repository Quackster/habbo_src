property pShowSymbol, pTargetBlend

on define me, tProps
  pShowSymbol = 0
  pBlend = 100
  tReturnValue = callAncestor(#define, [me], tProps)
  pTargetBlend = me.pBlendList[6]
  return tReturnValue
end

on select me
  if not (the doubleClick) then
    return 0
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return 1
  end if
  if (abs(tUserObj.pLocX - me.pLocX) > 1) or (abs(tUserObj.pLocY - me.pLocY) > 1) then
    repeat with tX = me.pLocX - 1 to me.pLocX + 1
      repeat with tY = me.pLocY - 1 to me.pLocY + 1
        if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: tX, #integer: tY])
          return 1
        end if
      end repeat
    end repeat
  else
    tConn = getThread(#room).getComponent().getRoomConnection()
    tConn.send("SET_RANDOM_STATE", [#integer: integer(me.getID())])
  end if
  return 1
end

on update me
  if pShowSymbol then
    tsprite = me.pSprList[6]
    tBlend = tsprite.blend
    if tBlend < pTargetBlend then
      tBlend = tBlend + 1
      if tBlend > pTargetBlend then
        tBlend = pTargetBlend
      end if
      tsprite.blend = tBlend
    end if
  end if
  return callAncestor(#update, [me])
end

on setState me, tNewState
  if integerp(integer(tNewState)) then
    tNewState = integer(tNewState)
  else
    tNewState = string(tNewState)
  end if
  if tNewState.ilk <> #integer then
    tNewState = 2
    pShowSymbol = 0
  else
    tNewState = tNewState + 2
    if me.pSprList.count >= 6 then
      tsprite = me.pSprList[6]
      tsprite.blend = 0
    end if
    pShowSymbol = 1
  end if
  callAncestor(#setState, [me], tNewState)
end
