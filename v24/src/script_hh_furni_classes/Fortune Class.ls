on define(me, tProps)
  pShowSymbol = 0
  pBlend = 100
  tReturnValue = callAncestor(#define, [me], tProps)
  pTargetBlend = me.getProp(#pBlendList, 6)
  return(tReturnValue)
  exit
end

on select(me)
  if not the doubleClick then
    return(0)
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return(1)
  end if
  if abs(tUserObj.pLocX - me.pLocX) > 1 or abs(tUserObj.pLocY - me.pLocY) > 1 then
    tX = me.pLocX - 1
    repeat while tX <= me.pLocX + 1
      tY = me.pLocY - 1
      repeat while tY <= me.pLocY + 1
        if getThread(#room).getInterface().getGeometry().emptyTile(tX, tY) then
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:tX, #short:tY])
          return(1)
        end if
        tY = 1 + tY
      end repeat
      tX = 1 + tX
    end repeat
    exit repeat
  end if
  tConn = getThread(#room).getComponent().getRoomConnection()
  tConn.send("SET_RANDOM_STATE", [#integer:integer(me.getID())])
  return(1)
  exit
end

on update(me)
  if pShowSymbol then
    tsprite = me.getProp(#pSprList, 6)
    tBlend = tsprite.blend
    if tBlend < pTargetBlend then
      tBlend = tBlend + 1
      if tBlend > pTargetBlend then
        tBlend = pTargetBlend
      end if
      tsprite.blend = tBlend
    end if
  end if
  return(callAncestor(#update, [me]))
  exit
end

on setState(me, tNewState)
  tNewState = value(tNewState)
  if tNewState.ilk <> #integer then
    tNewState = 2
    pShowSymbol = 0
  else
    tNewState = tNewState + 2
    tsprite = me.getProp(#pSprList, 6)
    tsprite.blend = 0
    pShowSymbol = 1
  end if
  callAncestor(#setState, [me], tNewState)
  exit
end