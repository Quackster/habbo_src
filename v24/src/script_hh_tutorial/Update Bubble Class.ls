on construct(me)
  callAncestor(#construct, [me])
  pUpdate = 1
  receiveUpdate(me.getID())
  pSkipFrames = 1
  return(1)
  exit
end

on deconstruct(me)
  pUpdate = 0
  removeUpdate(me.getID())
  callAncestor(#deconstruct, [me])
  return(1)
  exit
end

on update(me)
  pSkipFrames = not pSkipFrames
  if pSkipFrames = 1 then
    return(0)
  end if
  tRoomComponent = getThread("room").getComponent()
  tOwnRoomId = tRoomComponent.getUsersRoomId(getObject(#session).GET("user_name"))
  tHumanObj = tRoomComponent.getUserObject(tOwnRoomId)
  if tHumanObj = 0 then
    return(0)
  end if
  tHumanLoc = tHumanObj.getPartLocation("hd")
  me.setProperty(#targetX, tHumanLoc.getAt(1))
  me.setProperty(#targetY, tHumanLoc.getAt(2))
  if tHumanLoc.getAt(1) < 200 then
    me.selectPointerAndPosition(7)
  else
    me.selectPointerAndPosition(4)
  end if
  exit
end