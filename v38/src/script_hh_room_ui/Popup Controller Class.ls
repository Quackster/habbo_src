on construct(me)
  pPopupList = []
  pShowTimeOutID = getUniqueID()
  pHideTimeoutID = getUniqueID()
  registerMessage(#popupEntered, me.getID(), #popupEntered)
  registerMessage(#popupLeft, me.getID(), #popupLeft)
  registerMessage(#leaveRoom, me.getID(), #removePopups)
  registerMessage(#changeRoom, me.getID(), #removePopups)
  registerMessage(#enterRoom, me.getID(), #removePopups)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#popupEntered, me.getID())
  unregisterMessage(#popupLeft, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  return(1)
  exit
end

on handleEvent(me, tEvent, tSprID, tParam)
  if me <> "int_nav_image" then
    if me = "int_controller_image" then
      nothing()
    else
      return(0)
    end if
    if me = #mouseEnter then
      me.timeoutShow(tSprID)
    else
      if me = #mouseLeave then
        me.timeoutHide(tSprID)
      end if
    end if
    exit
  end if
end

on timeoutShow(me, tPopupID)
  if voidp(tPopupID) then
    return(0)
  end if
  tObject = me.getPopup(tPopupID)
  if not objectp(tObject) then
    return(0)
  end if
  tObject.Init(tPopupID)
  if timeoutExists(pHideTimeoutID) then
    removeTimeout(pHideTimeoutID)
  end if
  if not timeoutExists(pShowTimeOutID) then
    createTimeout(pShowTimeOutID, 500, #showPopup, me.getID(), tPopupID, 1)
  end if
  exit
end

on timeoutHide(me, tPopupID)
  if voidp(tPopupID) then
    return(0)
  end if
  if timeoutExists(pShowTimeOutID) then
    removeTimeout(pShowTimeOutID)
  end if
  if not timeoutExists(pHideTimeoutID) then
    createTimeout(pHideTimeoutID, 200, #hidePopup, me.getID(), tPopupID, 1)
  end if
  exit
end

on showPopup(me, tPopupID)
  tPopup = me.getPopup(tPopupID)
  if not objectp(tPopup) then
    return(0)
  end if
  tPopup.show()
  exit
end

on hidePopup(me, tPopupID)
  tPopup = me.getPopup(tPopupID)
  if not objectp(tPopup) then
    return(0)
  end if
  tPopup.hide()
  exit
end

on getPopup(me, tPopupID)
  if voidp(pPopupList.getaProp(tPopupID)) then
    if me = "int_nav_image" then
      tPopupClass = "Navigator Popup Class"
    else
      if me = "int_controller_image" then
        tPopupClass = "IG Popup Class"
      else
        return(0)
      end if
    end if
    if not memberExists(tPopupClass) then
      return(0)
    end if
    tObject = createObject(#random, tPopupClass)
    if tObject = 0 then
      return(0)
    end if
    pPopupList.setaProp(tPopupID, tObject)
  end if
  return(pPopupList.getaProp(tPopupID))
  exit
end

on removePopups(me)
  repeat while me <= undefined
    tPopup = getAt(undefined, undefined)
    tPopup.hide()
  end repeat
  if timeoutExists(pShowTimeOutID) then
    removeTimeout(pShowTimeOutID)
  end if
  if timeoutExists(pHideTimeoutID) then
    removeTimeout(pHideTimeoutID)
  end if
  exit
end

on popupEntered(me, tTarget)
  me.timeoutShow(tTarget)
  exit
end

on popupLeft(me, tTarget)
  me.timeoutHide(tTarget)
  exit
end