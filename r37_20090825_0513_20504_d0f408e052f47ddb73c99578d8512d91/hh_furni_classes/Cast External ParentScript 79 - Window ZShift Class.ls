on deconstruct me
  callAncestor(#deconstruct, [me])
  if threadExists(#room) then
    tRoomComponent = getThread(#room).getComponent()
    tRoomComponent.removeWallMaskItem(me.getID())
  end if
  return 1
end

on define me, tProps
  tReturnValue = callAncestor(#define, [me], tProps)
  if threadExists(#room) then
    tRoomComponent = getThread(#room).getComponent()
    tRoomComponent.insertWallMaskItem(me.getID(), me.getClass(), me.pSprList[1].loc, me.pDirection, me.pXFactor)
  end if
  return tReturnValue
end
