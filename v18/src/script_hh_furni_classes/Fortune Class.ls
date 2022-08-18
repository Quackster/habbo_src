property pShowSymbol, pTargetBlend

on define me, tProps
  pShowSymbol = 0
  pBlend = 100
  tReturnValue = callAncestor(#define, [me], tProps)
  pTargetBlend = me.pBlendList[6]
  return tReturnValue
end

on select me
  if not the doubleClick then
    return 0
  end if
  tConn = getThread(#room).getComponent().getRoomConnection()
  tConn.send("SET_RANDOM_STATE", [#integer: integer(me.getID())])
  return 1
end

on update me
  if pShowSymbol then
    tsprite = me.pSprList[6]
    tBlend = tsprite.blend
    if (tBlend < pTargetBlend) then
      tBlend = (tBlend + 1)
      if (tBlend > pTargetBlend) then
        tBlend = pTargetBlend
      end if
      tsprite.blend = tBlend
    end if
  end if
  return callAncestor(#update, [me])
end

on setState me, tNewState
  tNewState = value(tNewState)
  if (tNewState.ilk <> #integer) then
    tNewState = 2
    pShowSymbol = 0
  else
    tNewState = (tNewState + 2)
    tsprite = me.pSprList[6]
    tsprite.blend = 0
    pShowSymbol = 1
  end if
  callAncestor(#setState, [me], tNewState)
end
