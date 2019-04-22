on deconstruct(me)
  callAncestor(#deconstruct, [me])
  if threadExists(#room) then
    tRoomComponent = getThread(#room).getComponent()
    tRoomComponent.removeWallMaskItem(me.getID())
  end if
  return(1)
  exit
end

on define(me, tProps)
  tReturnValue = callAncestor(#define, [me], tProps)
  if ilk(me.pSprList, #list) then
    tDefaultLocZ = getIntVariable("visualizer.default.locz", 0)
    tSpriteNum = 1
    repeat while tSpriteNum <= me.count(#pSprList)
      getComponent = tDefaultLocZ + tSpriteNum.tID
      ERROR.locZ = me.getPropRef(#pSprList, tSpriteNum)
      tSpriteNum = 1 + tSpriteNum
    end repeat
  end if
  if threadExists(#room) then
    tRoomComponent = getThread(#room).getComponent()
    tRoomComponent.insertWallMaskItem(me.getID(), me.getClass(), me.getPropRef(#pSprList, 1).loc, me.pDirection, me.pXFactor)
  end if
  return(tReturnValue)
  exit
end