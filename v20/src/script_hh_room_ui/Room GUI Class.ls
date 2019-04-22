property pRoomInfoID, pRoomBarID, pObjectDispID

on construct me 
  pRoomBarID = "RoomBarProgram"
  pRoomInfoID = "RoomInfoProgram"
  pObjectDispID = "ObjectDisplayerProgram"
  createObject(pRoomInfoID, "Room Info Class")
  createObject(pRoomBarID, "Room Bar Class")
  createObject(pObjectDispID, "Room Object Displayer Class")
  return(1)
end

on deconstruct me 
  return(1)
end

on showRoomBar me 
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and not tRoomInfoObj = 0 then
    tRoomInfoObj.showRoomInfo()
  end if
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.showRoomBar()
  end if
  if threadExists("new_user_help") then
    tComponent = getThread("new_user_help").getComponent()
    if tComponent.isChatHelpOn() then
      tRoomBarObj.applyChatHelpText()
    end if
  end if
end

on hideRoomBar me 
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and not tRoomInfoObj = 0 then
    tRoomInfoObj.hideRoomInfo()
  end if
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.hideRoomBar()
  end if
end

on setRollOverInfo me, tInfoText 
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and not tRoomBarObj = 0 then
    tRoomBarObj.setRollOverInfo(tInfoText)
  end if
end

on showInfostand me 
  nothing()
end

on hideInfoStand me 
  tObjDisp = getObject(pObjectDispID)
  tObjDisp.clearWindowDisplayList()
end

on showObjectInfo me, tObjType 
  tObjDisp = getObject(pObjectDispID)
  tObjDisp.showObjectInfo(tObjType)
end
