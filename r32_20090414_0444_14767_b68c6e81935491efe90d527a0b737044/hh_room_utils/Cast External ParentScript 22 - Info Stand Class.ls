property pInfoStandName, pInfoStandId, pCurrentlySelectedUserId

on construct me
  pInfoStandId = "Info_Stand_Window"
  pInfoStandName = VOID
  pCurrentlySelectedUserId = VOID
  registerMessage(#hideInfoStand, me.getID(), #hideInfoStand)
  registerMessage(#groupLogoDownloaded, me.getID(), #groupLogoDownloaded)
end

on deconstruct me
  unregisterMessage(#hideInfoStand, me.getID())
  unregisterMessage(#groupLogoDownloaded, me.getID())
end

on showInfostand me
  if not windowExists(pInfoStandId) then
    createWindow(pInfoStandId, "info_stand.window", 552, 300)
    tWndObj = getWindow(pInfoStandId)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcInfoStand, me.getID(), #mouseUp)
  end if
  return 1
end

on hideInfoStand me
  executeMessage(#hideObjectDEVELOPMENT)
  if windowExists(pInfoStandId) then
    return removeWindow(pInfoStandId)
  end if
end

on showObjectInfo me, tObjType
  executeMessage(#showObjectDEVELOPMENT, tObjType)
  tWndObj = getWindow(pInfoStandId)
  if not tWndObj then
    return 0
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  case tObjType of
    "user":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      pCurrentlySelectedUserIdId = tSelectedObj
    "active":
      tObj = tRoomComponent.getActiveObject(tSelectedObj)
      pCurrentlySelectedUserIdId = VOID
    "item":
      tObj = tRoomComponent.getItemObject(tSelectedObj)
      pCurrentlySelectedUserIdId = VOID
    "pet":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      pCurrentlySelectedUserIdId = VOID
    otherwise:
      error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
      pCurrentlySelectedUserIdId = VOID
      tObj = 0
  end case
  if tObj = 0 then
    tProps = 0
  else
    tProps = tObj.getInfo()
  end if
  if listp(tProps) then
    tElem = tWndObj.getElement("bg_darken")
    if tElem = 0 then
      return 0
    end if
    tElem.show()
    tElem = tWndObj.getElement("info_name")
    if tElem = 0 then
      return 0
    end if
    tElem.show()
    tWndObj.getElement("info_text").show()
    tWndObj.getElement("info_name").setText(tProps[#name])
    tWndObj.getElement("info_text").setText(tProps[#custom])
    tElem = tWndObj.getElement("info_image")
    if tElem = 0 then
      return 0
    end if
    if ilk(tProps[#image]) = #image then
      tElem.resizeTo(tProps[#image].width, tProps[#image].height)
      tElem.getProperty(#sprite).member.regPoint = point(tProps[#image].width / 2, tProps[#image].height)
      tElem.feedImage(tProps[#image])
    end if
    me.updateInfoStandBadge(tProps[#badge])
    me.updateInfoStandGroup(tProps[#groupID])
    if tObjType = "user" then
      pInfoStandName = tProps[#name]
    else
      pInfoStandName = VOID
    end if
    return 1
  else
    return me.hideObjectInfo()
  end if
end

on updateInfostandAvatar me, tUserObj
  if call(#getClass, [tUserObj]) <> "user" then
    return 1
  end if
  if tUserObj.getName() <> pInfoStandName then
    return 1
  end if
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tSaveSelectedObj = tSelectedObj
  tRoomInterface.setSelectedObject(tUserObj.getID())
  me.showObjectInfo("user")
  tRoomInterface.setSelectedObject(tSaveSelectedObj)
  return 1
end

on hideObjectInfo me
  executeMessage(#hideObjectDEVELOPMENT)
  if objectExists("BadgeEffect") then
    removeObject("BadgeEffect")
  end if
  if not windowExists(pInfoStandId) then
    return 0
  end if
  tWndObj = getWindow(pInfoStandId)
  tWndObj.getElement("info_image").clearImage()
  tWndObj.getElement("bg_darken").hide()
  tWndObj.getElement("info_name").hide()
  tWndObj.getElement("info_text").hide()
  tWndObj.getElement("info_badge_1").clearImage()
  tWndObj.getElement("info_group_badge").clearImage()
  pCurrentlySelectedUserId = VOID
  me.updateInfoStandGroup()
  return 1
end

on updateInfoStandBadge me, tBadgeID, tUserID
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  return tRoomInterface.getBadgeObject().updateInfoStandBadge(pInfoStandId, tSelectedObj, tBadgeID, tUserID)
end

on updateInfoStandGroup me, tGroupId
  if windowExists(pInfoStandId) then
    tWindowObj = getWindow(pInfoStandId)
    if tWindowObj.elementExists("info_group_badge") then
      tElem = tWindowObj.getElement("info_group_badge")
      if tElem = 0 then
        return 0
      end if
    else
      return 0
    end if
  else
    return 0
  end if
  if voidp(tGroupId) or (tGroupId < 0) then
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
    return 0
  end if
  tRoomComponent = getThread(#room).getComponent()
  tGroupInfoObject = tRoomComponent.getGroupInfoObject()
  if tGroupInfoObject = 0 then
    return 0
  end if
  tLogoMemNum = tGroupInfoObject.getGroupLogoMemberNum(tGroupId)
  if not voidp(tGroupId) and (tLogoMemNum > 0) then
    tElem.clearImage()
    tElem.setProperty(#image, member(tLogoMemNum).image)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
  end if
end

on groupLogoDownloaded me, tGroupId
  tRoomInterface = getThread(#room).getInterface()
  tRoomComponent = getThread(#room).getComponent()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tObj = tRoomComponent.getUserObject(tSelectedObj)
  if tObj = 0 then
    return 0
  end if
  tUsersGroup = tObj.getProperty(#groupID)
  if tUsersGroup = tGroupId then
    me.updateInfoStandGroup(tGroupId)
  end if
end

on eventProcInfoStand me, tEvent, tSprID, tParam
  case tSprID of
    "info_badge":
      tSession = getObject(#session)
      tRoomInterface = getThread(#room).getInterface()
      tSelectedObj = tRoomInterface.getSelectedObject()
      if tSelectedObj = tSession.GET("user_index") then
      end if
    "info_group_badge":
      tRoomInterface = getThread(#room).getInterface()
      tSelectedObj = tRoomInterface.getSelectedObject()
      if not voidp(tSelectedObj) and (tSelectedObj <> EMPTY) then
        tRoomComponent = getThread(#room).getComponent()
        tInfoObj = tRoomComponent.getGroupInfoObject()
        tInfoObj.showUsersInfoByName(pInfoStandName)
      end if
  end case
  return 1
end
