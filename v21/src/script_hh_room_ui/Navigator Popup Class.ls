on construct(me)
  pPopupWindowID = getUniqueID()
  pHideTimeoutID = getUniqueID()
  pShowTimeOutID = getUniqueID()
  pVisible = 0
  pNodeInfo = []
  pBlend = 0
  registerMessage(#show_hide_navigator, me.getID(), #hide)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#show_hide_navigator, me.getID())
  return(1)
  exit
end

on Init(me, tTargetElementID)
  pTargetElementID = tTargetElementID
  tNavComponent = getObject(#navigator_component)
  if tNavComponent <> 0 then
    tNavComponent.updateRecomRooms()
  end if
  exit
end

on show(me)
  if pVisible then
    return(1)
  end if
  tNavInterface = getObject(#navigator_interface)
  if tNavInterface <> 0 then
    if tNavInterface.isOpen() then
      return(0)
    end if
  end if
  createWindow(pPopupWindowID, "nav_popup_bg.window")
  tWindow = getWindow(pPopupWindowID)
  tWindow.merge("navigator_popup.window")
  tRoomBar = getWindow("RoomBarID")
  tNavIcon = tRoomBar.getElement(pTargetElementID)
  tBarLocX = tRoomBar.getProperty(#locX)
  tBarLocY = tRoomBar.getProperty(#locY)
  tIconLocX = tNavIcon.getProperty(#locX)
  tIconLocY = tNavIcon.getProperty(#locY)
  tIconWidth = tNavIcon.getProperty(#width)
  tMargin = 2
  tLocX = tBarLocX + tIconLocX + tIconWidth / 2 - tWindow.getProperty(#width) / 2
  tLocY = tBarLocY + tIconLocY - tWindow.getProperty(#height)
  tOffset = the stage - rect.width - tMargin
  if tOffset > 0 then
    tLocX = tLocX - tOffset
    tPointerElem = tWindow.getElement("pointer")
    tPointerElem.moveBy(tOffset, 0)
  end if
  tWindow.moveTo(tLocX, tLocY)
  tWindow.registerProcedure(#popupEntered, me.getID(), #mouseEnter)
  tWindow.registerProcedure(#popupLeft, me.getID(), #mouseLeave)
  tWindow.registerProcedure(#eventProc, me.getID(), #mouseUp)
  me.fetchNodeInfo()
  i = 1
  repeat while i <= 3
    if i > pNodeInfo.count(#children) then
    else
      tRoom = pNodeInfo.getProp(#children, i)
      tElem = tWindow.getElement("nav_popup_link" & i)
      tRoomName = tRoom.getaProp(#name)
      tElem.setText(tRoomName)
      if tRoom.getAt(#usercount) and tRoom.getAt(#maxUsers) then
        tOccupancy = float(tRoom.getAt(#usercount)) / tRoom.getAt(#maxUsers)
      else
        tOccupancy = 0
      end if
      tElem = tWindow.getElement("nav_popup_occupancy" & i)
      if tOccupancy > 0.67 then
        tmember = "room.occupancy." & 3
      else
        if tOccupancy > 0.34 then
          tmember = "room.occupancy." & 2
        else
          if tOccupancy > 0 then
            tmember = "room.occupancy." & 1
          else
            tmember = "room.occupancy." & 0
          end if
        end if
      end if
      tImage = member(getmemnum(tmember)).image
      tElem = tWindow.getElement("nav_popup_link_occupancy" & i)
      tElem.feedImage(tImage)
      i = 1 + i
    end if
  end repeat
  tWindow.setBlend(0)
  pBlend = 0
  receiveUpdate(me.getID())
  pVisible = 1
  exit
end

on hide(me)
  if not pVisible then
    return(1)
  end if
  removeUpdate(me.getID())
  removeWindow(pPopupWindowID)
  executeMessage(#popupClosed, me.getID())
  pVisible = 0
  exit
end

on fetchNodeInfo(me)
  pNodeInfo = getObject(#navigator_component).getRecomNodeInfo()
  exit
end

on update(me)
  pBlend = pBlend + 25
  if pBlend >= 100 then
    pBlend = 100
    removeUpdate(me.getID())
  end if
  tWindow = getWindow(pPopupWindowID)
  tWindow.setBlend(pBlend)
  exit
end

on popupEntered(me)
  executeMessage(#popupEntered, pTargetElementID)
  exit
end

on popupLeft(me)
  executeMessage(#popupLeft, pTargetElementID)
  exit
end

on eventProc(me, tEvent, tSprID, tParam, tWndID)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if tSprID contains "nav_popup_link" then
    tLinkNum = value(tSprID.getProp(#char, tSprID.length))
    tRoom = pNodeInfo.getProp(#children, tLinkNum)
    if not voidp(tRoom) then
      tRoomID = tRoom.getAt(#id)
      executeMessage(#roomForward, tRoomID, #private)
    end if
  end if
  if tSprID = "nav_popup_nav_link" then
    me.hide()
    executeMessage(#show_navigator)
  end if
  exit
end