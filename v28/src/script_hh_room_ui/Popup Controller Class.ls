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
    if (tSprID = "int_controller_image") then
      nothing()
    else
      return FALSE
    end if
    if (tSprID = #mouseEnter) then
      me.timeoutShow(tSprID)
    else
      if (tSprID = #mouseLeave) then
        me.timeoutHide(tSprID)
      end if
    end if
  end if
end

on timeoutShow me, tPopupID 
  if voidp(tPopupID) then
    return FALSE
  end if
  tObject = me.getPopup(tPopupID)
  if not objectp(tObject) then
    return FALSE
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
  if not objectp(tPopup) then
    return FALSE
  end if
  tPopup.show()
end

on hidePopup me, tPopupID 
  tPopup = me.getPopup(tPopupID)
  if not objectp(tPopup) then
    return FALSE
  end if
  tPopup.hide()
end

on getPopup me, tPopupID 
  if voidp(pPopupList.getaProp(tPopupID)) then
    if (tPopupID = "int_nav_image") then
      tPopupClass = "Navigator Popup Class"
    else
      if (tPopupID = "int_controller_image") then
        tPopupClass = "IG Popup Class"
      else
        return FALSE
      end if
    end if
    if not memberExists(tPopupClass) then
      return FALSE
    end if
    tObject = createObject(#random, tPopupClass)
    if (tObject = 0) then
      return FALSE
    end if
    pPopupList.setaProp(tPopupID, tObject)
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
