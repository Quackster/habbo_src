on construct(me)
  pInfoStandId = "Info_Stand_Window"
  pInfoStandName = void()
  pCurrentlySelectedUserId = void()
  registerMessage(#hideInfoStand, me.getID(), #hideInfoStand)
  registerMessage(#groupLogoDownloaded, me.getID(), #groupLogoDownloaded)
  exit
end

on deconstruct(me)
  unregisterMessage(#hideInfoStand, me.getID())
  unregisterMessage(#groupLogoDownloaded, me.getID())
  exit
end

on showInfostand(me)
  if not windowExists(pInfoStandId) then
    createWindow(pInfoStandId, "info_stand.window", 552, 300)
    tWndObj = getWindow(pInfoStandId)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInfoStand, me.getID(), #mouseUp)
  end if
  return(1)
  exit
end

on hideInfoStand(me)
  executeMessage(#hideObjectDEVELOPMENT)
  if windowExists(pInfoStandId) then
    return(removeWindow(pInfoStandId))
  end if
  exit
end

on showObjectInfo(me, tObjType)
  executeMessage(#showObjectDEVELOPMENT, tObjType)
  tWndObj = getWindow(pInfoStandId)
  if not tWndObj then
    return(0)
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  if me = "user" then
    tObj = tRoomComponent.getUserObject(tSelectedObj)
    pCurrentlySelectedUserIdId = tSelectedObj
  else
    if me = "active" then
      tObj = tRoomComponent.getActiveObject(tSelectedObj)
      pCurrentlySelectedUserIdId = void()
    else
      if me = "item" then
        tObj = tRoomComponent.getItemObject(tSelectedObj)
        pCurrentlySelectedUserIdId = void()
      else
        if me = "pet" then
          tObj = tRoomComponent.getUserObject(tSelectedObj)
          pCurrentlySelectedUserIdId = void()
        else
          error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
          pCurrentlySelectedUserIdId = void()
          tObj = 0
        end if
      end if
    end if
  end if
  if tObj = 0 then
    tProps = 0
  else
    tProps = tObj.getInfo()
  end if
  if listp(tProps) then
    tWndObj.getElement("bg_darken").show()
    tWndObj.getElement("info_name").show()
    tWndObj.getElement("info_text").show()
    tWndObj.getElement("info_name").setText(tProps.getAt(#name))
    tWndObj.getElement("info_text").setText(tProps.getAt(#custom))
    tElem = tWndObj.getElement("info_image")
    if ilk(tProps.getAt(#image)) = #image then
      tElem.resizeTo(tProps.getAt(#image).width, tProps.getAt(#image).height)
      member.regPoint = point(tProps.getAt(#image).width / 2, tProps.getAt(#image).height)
      tElem.feedImage(tProps.getAt(#image))
    end if
    me.updateInfoStandBadge(tProps.getAt(#badge))
    me.updateInfoStandGroup(tProps.getAt(#groupid))
    if tObjType = "user" then
      pInfoStandName = tProps.getAt(#name)
    else
      pInfoStandName = void()
    end if
    return(1)
  else
    return(me.hideObjectInfo())
  end if
  exit
end

on updateInfostandAvatar(me, tUserObj)
  if call(#getClass, [tUserObj]) <> "user" then
    return(1)
  end if
  if tUserObj.getName() <> pInfoStandName then
    return(1)
  end if
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tSaveSelectedObj = tSelectedObj
  tRoomInterface.setSelectedObject(tUserObj.getID())
  me.showObjectInfo("user")
  tRoomInterface.setSelectedObject(tSaveSelectedObj)
  return(1)
  exit
end

on hideObjectInfo(me)
  executeMessage(#hideObjectDEVELOPMENT)
  if objectExists("BadgeEffect") then
    removeObject("BadgeEffect")
  end if
  if not windowExists(pInfoStandId) then
    return(0)
  end if
  tWndObj = getWindow(pInfoStandId)
  tWndObj.getElement("info_image").clearImage()
  tWndObj.getElement("bg_darken").hide()
  tWndObj.getElement("info_name").hide()
  tWndObj.getElement("info_text").hide()
  tWndObj.getElement("info_badge").clearImage()
  tWndObj.getElement("info_group_badge").clearImage()
  pCurrentlySelectedUserId = void()
  me.updateInfoStandGroup()
  return(1)
  exit
end

on updateInfoStandBadge(me, tBadgeID, tUserID)
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  return(tRoomInterface.getBadgeObject().updateInfoStandBadge(pInfoStandId, tSelectedObj, tBadgeID, tUserID))
  exit
end

on updateInfoStandGroup(me, tGroupId)
  if windowExists(pInfoStandId) then
    tWindowObj = getWindow(pInfoStandId)
    if tWindowObj.elementExists("info_group_badge") then
      tElem = tWindowObj.getElement("info_group_badge")
    else
      return(0)
    end if
  else
    return(0)
  end if
  if voidp(tGroupId) or tGroupId < 0 then
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
    return(0)
  end if
  tRoomComponent = getThread(#room).getComponent()
  tGroupInfoObject = tRoomComponent.getGroupInfoObject()
  tLogoMemNum = tGroupInfoObject.getGroupLogoMemberNum(tGroupId)
  if not voidp(tGroupId) then
    tElem.clearImage()
    tElem.setProperty(#image, member(tLogoMemNum).image)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
  end if
  exit
end

on groupLogoDownloaded(me, tGroupId)
  tRoomInterface = getThread(#room).getInterface()
  tRoomComponent = getThread(#room).getComponent()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tObj = tRoomComponent.getUserObject(tSelectedObj)
  if tObj = 0 then
    return(0)
  end if
  tUsersGroup = tObj.getProperty(#groupid)
  if tUsersGroup = tGroupId then
    me.updateInfoStandGroup(tGroupId)
  end if
  exit
end

on eventProcInfoStand(me, tEvent, tSprID, tParam)
  if me = "info_badge" then
    tSession = getObject(#session)
    tRoomInterface = getThread(#room).getInterface()
    tSelectedObj = tRoomInterface.getSelectedObject()
    if tSelectedObj = tSession.GET("user_index") then
      tRoomInterface.getBadgeObject().toggleOwnBadgeVisibility()
    end if
  else
    if me = "info_group_badge" then
      tRoomInterface = getThread(#room).getInterface()
      tSelectedObj = tRoomInterface.getSelectedObject()
      if not voidp(tSelectedObj) and tSelectedObj <> "" then
        tRoomComponent = getThread(#room).getComponent()
        tInfoObj = tRoomComponent.getGroupInfoObject()
        tInfoObj.showUsersInfoByName(pInfoStandName)
      end if
    end if
  end if
  return(1)
  exit
end