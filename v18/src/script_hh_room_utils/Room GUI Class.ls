on construct(me)
  pRoomBarID = "RoomBarProgram"
  pRoomInfoID = "RoomInfoProgram"
  pObjectDispID = "ObjectDisplayerProgram"
  createObject(pRoomBarID, "Room Bar Class")
  createObject(pRoomInfoID, "Room Info Class")
  createObject(pObjectDispID, "Room Object Displayer Class")
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on showRoomBar(me)
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.showRoomBar()
  end if
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and not tRoomInfoObj = 0 then
    tRoomInfoObj.showRoomInfo()
  end if
  exit
end

on hideRoomBar(me)
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.hideRoomBar()
  end if
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and not tRoomInfoObj = 0 then
    tRoomInfoObj.hideRoomInfo()
  end if
  exit
end

on setRollOverInfo(me, tInfoText)
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.setRollOverInfo(tInfoText)
  end if
  exit
end