property pRoomBarID, pRoomInfoID, pObjectDispID, pBadgeObjID, pFxInvObjID

on construct me
  pRoomBarID = "RoomBarProgram"
  pRoomInfoID = "RoomInfoProgram"
  pObjectDispID = "ObjectDisplayerProgram"
  pBadgeObjID = "room.obj.disp.badge.mngr"
  pFxInvObjID = "room.obj.fx.inventory"
  createObject(pRoomInfoID, "Room Info Class")
  createObject(pRoomBarID, "Room Bar Class")
  createObject(pObjectDispID, "Room Object Displayer Class")
  createObject(pBadgeObjID, "Badge Manager Class")
  createObject(pFxInvObjID, "Effect Inventory Class")
  registerMessage(#takingPhoto, me.getID(), #hideInfoStand)
  return 1
end

on deconstruct me
  unregisterMessage(#takingPhoto, me.getID())
  removeObject(pRoomInfoID)
  removeObject(pRoomBarID)
  removeObject(pObjectDispID)
  removeObject(pBadgeObjID)
  removeObject(pFxInvObjID)
  return 1
end

on getBadgeObject me
  return getObject(pBadgeObjID)
end

on getFxInventory me
  return getObject(pFxInvObjID)
end

on showRoomBar me, tLayout
  tRoomInfoObj = getObject(pRoomInfoID)
  if not voidp(tRoomInfoObj) and (not tRoomInfoObj = 0) then
    tRoomInfoObj.showRoomInfo()
  end if
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and (not tRoomBarObj = 0) then
    tRoomBarObj.showRoomBar(tLayout)
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
  if not voidp(tRoomInfoObj) and (not tRoomInfoObj = 0) then
    tRoomInfoObj.hideRoomInfo()
  end if
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and (not tRoomBarObj = 0) then
    tRoomBarObj.hideRoomBar()
  end if
end

on setRollOverInfo me, tInfoText
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and (not tRoomBarObj = 0) then
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

on showVote me
  tRoomBarObj = getObject(pRoomBarID)
  if not voidp(tRoomBarObj) and (not tRoomBarObj = 0) then
    tRoomBarObj.showVote()
  end if
end
