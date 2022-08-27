on deconstruct me 


  callAncestor(#deconstruct, [me])


  if threadExists(#room) then


    tRoomComponent = getThread(#room).getComponent()


    tRoomComponent.removeWallMaskItem(me.getID())


  end if


  return TRUE


end





on define me, tProps 


  tReturnValue = callAncestor(#define, [me], tProps)


  if threadExists(#room) then


    tRoomComponent = getThread(#room).getComponent()


    tRoomComponent.insertWallMaskItem(me.getID(), me.getClass(), me.getPropRef(#pSprList, 1).loc, me.pDirection, me.pXFactor)


  end if


  return(tReturnValue)


end


