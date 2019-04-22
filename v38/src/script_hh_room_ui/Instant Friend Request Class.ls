property pWindowID, pData, pParentWindowID, pParentElementID, pParentObjId

on construct me 
  pWindowID = "Instant Friend Request Window"
  return(1)
end

on deconstruct me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return(1)
end

on define me, tParentWindowID, tParentElementID, tdata, tParentObjId 
  pParentWindowID = tParentWindowID
  pParentElementID = tParentElementID
  pData = tdata
  pParentObjId = tParentObjId
end

on show me 
  if pData.ilk <> #propList then
    return(0)
  end if
  if voidp(pData.findPos(#name)) then
    return(0)
  end if
  if not windowExists(pParentWindowID) then
    return(0)
  end if
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "instant_friend_request.window")
    tWindow = getWindow(pWindowID)
    tWindow.registerProcedure(#eventProcRequest, me.getID(), #mouseUp)
  else
    tWindow = getWindow(pWindowID)
  end if
  tRoomComp = getThread(#room).getComponent()
  tUsersRoomId = tRoomComp.getUsersRoomId(pData.getAt(#name))
  tUserObj = tRoomComp.getUserObject(tUsersRoomId)
  if not voidp(tUserObj) then
    if objectExists("Figure_Preview") then
      tPartList = tUserObj.getProp(#pPartListSubSet, #head)
      tFigure = tUserObj.getRawFigure()
      tUserImg = getObject("Figure_Preview").getHumanPartImg(tPartList, tFigure, 2, "sh")
    end if
    tFaceElem = tWindow.getElement("user_head")
    tFaceElem.feedImage(tUserImg)
  end if
  tWindow.getElement("user_name").setText(pData.getAt(#name))
  if not me.align() then
    return(0)
  end if
end

on align me 
  if not windowExists(pParentWindowID) then
    return(0)
  end if
  if not windowExists(pWindowID) then
    return(0)
  end if
  tTargetWindow = getWindow(pParentWindowID)
  tRequestWindow = getWindow(pWindowID)
  if not tTargetWindow.elementExists(pParentElementID) then
    return(0)
  end if
  tElem = tTargetWindow.getElement(pParentElementID)
  if not tElem.getProperty(#visible) then
    return(0)
  end if
  tWinLocX = tTargetWindow.getProperty(#locX)
  tWinLocY = tTargetWindow.getProperty(#locY)
  tElemLocX = tElem.getProperty(#locX)
  tElemLocY = tElem.getProperty(#locY)
  tElemWidth = tElem.getProperty(#width)
  tOwnWidth = tRequestWindow.getProperty(#width)
  tOwnHeight = tRequestWindow.getProperty(#height)
  tLocX = tWinLocX + tElemLocX + tElemWidth / 2 - tOwnWidth / 2
  tLocY = tWinLocY + tElemLocY - tOwnHeight
  tOffset = the stage - rect.width
  if tOffset > 0 then
    tLocX = tLocX - tOffset
    tPointerElem = tRequestWindow.getElement("pointer")
    tPointerElem.moveBy(tOffset, 0)
  end if
  tRequestWindow.moveTo(tLocX, tLocY)
  return(1)
end

on eventProcRequest me, tEvent, tSprID 
  if tSprID = "button_accept" then
    if objectExists(pParentObjId) then
      tParent = getObject(pParentObjId)
      tParent.confirmFriendRequest(1, pData.getAt(#id))
      createTimeout(#room_bar_extension_next_update, 1000, #viewNextItemInStack, pParentObjId, void(), 1)
    end if
  else
    if tSprID = "button_deny" then
      if objectExists(pParentObjId) then
        tParent = getObject(pParentObjId)
        tParent.confirmFriendRequest(0, pData.getAt(#id))
        createTimeout(#room_bar_extension_next_update, 1000, #viewNextItemInStack, pParentObjId, void(), 1)
      end if
    else
      if tSprID = "user_head" then
        if listp(pData) then
          tRoomComp = getThread(#room).getComponent()
          tRoomInterface = getThread(#room).getInterface()
          tUsersRoomId = tRoomComp.getUsersRoomId(pData.getAt(#name))
          if tUsersRoomId > -1 then
            tRoomInterface.eventProcUserObj(#mouseDown, tUsersRoomId)
          end if
        end if
      else
        if tSprID = "popup_button_close" then
          if objectExists(pParentObjId) then
            tParent = getObject(pParentObjId)
            tParent.ignoreInstantFriendRequests()
            tParent.viewNextItemInStack()
          end if
        end if
      end if
    end if
  end if
end
