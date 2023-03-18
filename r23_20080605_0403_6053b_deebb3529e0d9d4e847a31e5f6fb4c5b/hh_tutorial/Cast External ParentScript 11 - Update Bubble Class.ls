property pUpdate, pSkipFrames

on construct me
  callAncestor(#construct, [me])
  pUpdate = 1
  receiveUpdate(me.getID())
  pSkipFrames = 1
  return 1
end

on deconstruct me
  pUpdate = 0
  removeUpdate(me.getID())
  callAncestor(#deconstruct, [me])
  return 1
end

on update me
  pSkipFrames = not pSkipFrames
  if pSkipFrames = 1 then
    return 0
  end if
  tRoomComponent = getThread("room").getComponent()
  tOwnRoomId = tRoomComponent.getUsersRoomId(getObject(#session).GET("user_name"))
  tHumanObj = tRoomComponent.getUserObject(tOwnRoomId)
  if tHumanObj = 0 then
    return 0
  end if
  tHumanLoc = tHumanObj.getPartLocation("hd")
  me.setProperty(#targetX, tHumanLoc[1])
  me.setProperty(#targetY, tHumanLoc[2])
  if tHumanLoc[1] < 200 then
    me.selectPointerAndPosition(7)
  else
    me.selectPointerAndPosition(4)
  end if
end
