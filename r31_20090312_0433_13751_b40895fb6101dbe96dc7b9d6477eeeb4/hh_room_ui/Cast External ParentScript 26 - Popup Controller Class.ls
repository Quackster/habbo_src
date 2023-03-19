property pPopupList, pShowTimeOutID, pHideTimeoutID

on construct me
  pPopupList = [:]
  pShowTimeOutID = getUniqueID()
  pHideTimeoutID = getUniqueID()
  registerMessage(#popupEntered, me.getID(), #popupEntered)
  registerMessage(#popupLeft, me.getID(), #popupLeft)
  registerMessage(#leaveRoom, me.getID(), #removePopups)
  registerMessage(#changeRoom, me.getID(), #removePopups)
  registerMessage(#enterRoom, me.getID(), #removePopups)
  return 1
end

on deconstruct me
  unregisterMessage(#popupEntered, me.getID())
  unregisterMessage(#popupLeft, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  return 1
end

on handleEvent me, tEvent, tSprID, tParam
  case tSprID of
    "int_nav_image", "int_controller_image":
      nothing()
    otherwise:
      return 0
  end case
  case tEvent of
    #mouseEnter:
      me.timeoutShow(tSprID)
    #mouseLeave:
      me.timeoutHide(tSprID)
  end case
end

on timeoutShow me, tPopupID
  if voidp(tPopupID) then
    return 0
  end if
  tObject = me.getPopup(tPopupID)
  if not objectp(tObject) then
    return 0
  end if
  tObject.Init(tPopupID)
  if timeoutExists(pHideTimeoutID) then
    removeTimeout(pHideTimeoutID)
  end if
  if not timeoutExists(pShowTimeOutID) then
    createTimeout(pShowTimeOutID, 500, #showPopup, me.getID(), tPopupID, 1)
  end if
end

on timeoutHide me, tPopupID
  if voidp(tPopupID) then
    return 0
  end if
  if timeoutExists(pShowTimeOutID) then
    removeTimeout(pShowTimeOutID)
  end if
  if not timeoutExists(pHideTimeoutID) then
    createTimeout(pHideTimeoutID, 200, #hidePopup, me.getID(), tPopupID, 1)
  end if
end

on showPopup me, tPopupID
  tPopup = me.getPopup(tPopupID)
  if not objectp(tPopup) then
    return 0
  end if
  tPopup.show()
end

on hidePopup me, tPopupID
  tPopup = me.getPopup(tPopupID)
  if not objectp(tPopup) then
    return 0
  end if
  tPopup.hide()
end

on getPopup me, tPopupID
  if voidp(pPopupList.getaProp(tPopupID)) then
    case tPopupID of
      "int_nav_image":
        tPopupClass = "Navigator Popup Class"
      "int_controller_image":
        tPopupClass = "IG Popup Class"
      otherwise:
        return 0
    end case
    if not memberExists(tPopupClass) then
      return 0
    end if
    tObject = createObject(#random, tPopupClass)
    if tObject = 0 then
      return 0
    end if
    pPopupList.setaProp(tPopupID, tObject)
  end if
  return pPopupList.getaProp(tPopupID)
end

on removePopups me
  repeat with tPopup in pPopupList
    tPopup.hide()
  end repeat
  if timeoutExists(pShowTimeOutID) then
    removeTimeout(pShowTimeOutID)
  end if
  if timeoutExists(pHideTimeoutID) then
    removeTimeout(pHideTimeoutID)
  end if
end

on popupEntered me, tTarget
  me.timeoutShow(tTarget)
end

on popupLeft me, tTarget
  me.timeoutHide(tTarget)
end
