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
  if ilk(me.pSprList) = #list then
    tDefaultLocZ = getIntVariable("visualizer.default.locz", 0)
    repeat with tSpriteNum = 1 to me.pSprList.count
      me.pSprList[tSpriteNum].locZ = tDefaultLocZ + tSpriteNum - 50000
    end repeat
  end if
  if threadExists(#room) then
    tRoomComponent = getThread(#room).getComponent()
    tRoomComponent.insertWallMaskItem(me.getID(), me.getClass(), me.pSprList[1].loc, me.pDirection, me.pXFactor)
  end if
  return tReturnValue
end
