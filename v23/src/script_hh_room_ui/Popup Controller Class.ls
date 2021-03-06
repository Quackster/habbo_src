property pHideTimeoutID, pShowTimeOutID, pPopupList

on construct me 
  pPopupList = [:]
  pShowTimeOutID = getUniqueID()
  pHideTimeoutID = getUniqueID()
  registerMessage(#popupEntered, me.getID(), #popupEntered)
  registerMessage(#popupLeft, me.getID(), #popupLeft)
  registerMessage(#leaveRoom, me.getID(), #removePopups)
  registerMessage(#changeRoom, me.getID(), #removePopups)
  registerMessage(#enterRoom, me.getID(), #removePopups)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#popupEntered, me.getID())
  unregisterMessage(#popupLeft, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  return TRUE
end

on handleEvent me, tEvent, tSprID, tParam 
  if tSprID <> "int_nav_image" then
    return FALSE
  end if
  if (tEvent = #mouseEnter) then
    me.timeoutShow(tSprID)
  else
    if (tEvent = #mouseLeave) then
      me.timeoutHide(tSprID)
    end if
  end if
end

on timeoutShow me, tPopupID 
  if voidp(tPopupID) then
    return FALSE
  end if
  me.getPopup(tPopupID).Init(tPopupID)
  if timeoutExists(pHideTimeoutID) then
    removeTimeout(pHideTimeoutID)
  end if
  if not timeoutExists(pShowTimeOutID) then
    createTimeout(pShowTimeOutID, 500, #showPopup, me.getID(), tPopupID, 1)
  end if
end

on timeoutHide me, tPopupID 
  if voidp(tPopupID) then
    return FALSE
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
  tPopup.show()
end

on hidePopup me, tPopupID 
  tPopup = me.getPopup(tPopupID)
  tPopup.hide()
end

on getPopup me, tPopupID 
  if voidp(pPopupList.getaProp(tPopupID)) then
    tPopupClass = "Navigator Popup Class"
    pPopupList.setaProp(tPopupID, createObject(#random, tPopupClass))
  end if
  return(pPopupList.getaProp(tPopupID))
end

on removePopups me 
  repeat while pPopupList <= undefined
    tPopup = getAt(undefined, undefined)
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
