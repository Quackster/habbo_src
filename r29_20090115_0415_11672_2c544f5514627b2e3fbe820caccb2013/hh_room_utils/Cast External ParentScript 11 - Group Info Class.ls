property pGroupWindowID, pGroupData, pCurrentShownGroupId, pGroupsWithDownloadedLogo, pGroupLogoMemPrefix, pGroupLogoTemplateMember, pGroupLogoUrlTemplate, pLastPendingData

on construct me
  pGroupWindowID = getText("group_window_title")
  pGroupData = [:]
  pCurrentShownGroupId = VOID
  pGroupsWithDownloadedLogo = []
  pLastPendingData = [:]
  pGroupLogoMemPrefix = "group_logo_"
  pGroupLogoTemplateMember = "logo_downloading_template"
  pGroupLogoUrlTemplate = getText("group_logo_url_template")
  registerMessage(#roomReady, me.getID(), #requestGroups)
  registerMessage(#leaveRoom, me.getID(), #clearGroups)
  registerMessage(#changeRoom, me.getID(), #clearGroups)
  return 1
end

on deconstruct me
  unregisterMessage(#userClicked, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  return 1
end

on updateGroupInformation me, tGroupsArr
  if not listp(tGroupsArr) then
    return 0
  end if
  repeat with tIncomingGroupData in tGroupsArr
    tID = string(tIncomingGroupData[#id])
    tCombinedData = [:]
    if not voidp(pGroupData[tID]) then
      tCombinedData = pGroupData[tID]
    end if
    tKeyList = [#id, #name, #desc, #logo, #roomid, #roomname]
    repeat with tKey in tKeyList
      if not voidp(tIncomingGroupData[tKey]) then
        tCombinedData[tKey] = tIncomingGroupData[tKey]
        if tKey = #logo then
          tCombinedData[#download] = #invalid
        end if
      end if
    end repeat
    pGroupData[tID] = tCombinedData
    if pLastPendingData[#groupID] = tID then
      me.showUsersInfo(pLastPendingData[#userindex])
      pGroupData[tID][#download] = #done
      pLastPendingData = [:]
    end if
  end repeat
end

on getGroupInformation me, tGroupId
  tGroupInfo = [:]
  tGroupId = string(tGroupId)
  if not voidp(pGroupData[tGroupId]) then
    tGroupInfo = pGroupData[tGroupId]
  end if
  return tGroupInfo
end

on getGroupLogoMemberNum me, tGroupId
  tGroupData = pGroupData.getaProp(tGroupId)
  if voidp(tGroupData) then
    return getmemnum(pGroupLogoTemplateMember)
  end if
  tGroupLogoMem = pGroupLogoMemPrefix & tGroupData[#logo]
  if memberExists(tGroupLogoMem) then
    return getmemnum(tGroupLogoMem)
  else
    me.requestLogoDownload(tGroupId)
    return getmemnum(pGroupLogoTemplateMember)
  end if
end

on closeView me
  removeWindow(pGroupWindowID)
end

on clearGroups me
  me.closeView()
  pGroupInformation = [:]
  pCurrentShownGroupId = VOID
end

on requestGroups me
  getConnection(getVariable("connection.room.id")).send("GET_GROUP_BADGES")
end

on getLogoURL me, tGroupId
  if voidp(tGroupId) then
    return 0
  end if
  tURL = EMPTY
  tGroupData = pGroupData[tGroupId]
  if ilk(tGroupData) = #propList then
    tURL = pGroupLogoUrlTemplate
    tGroupLogoPath = tGroupData[#logo]
    tURL = replaceChunks(tURL, "%imagerdata%", tGroupLogoPath)
  end if
  return tURL
end

on requestLogoDownload me, tGroupId
  tGroupId = string(tGroupId)
  tGroupData = pGroupData.getaProp(tGroupId)
  if ilk(tGroupData) <> #propList then
    return error(me, "No group found: " & tGroupId, me.getID(), #requestLogoDownload, #minor)
  end if
  tDownloadStatus = tGroupData[#download]
  if not (voidp(tDownloadStatus) or (tDownloadStatus = #invalid)) then
    return 0
  else
    pGroupData[tGroupId][#download] = #downloading
  end if
  tMemberName = pGroupLogoMemPrefix & tGroupData[#logo]
  tLogoURL = me.getLogoURL(tGroupId)
  tMemNum = queueDownload(tLogoURL, tMemberName, #bitmap, 1)
  registerDownloadCallback(tMemNum, #logoDownloadedCallback, me.getID(), tGroupId)
end

on logoDownloadedCallback me, tGroupId
  executeMessage(#groupLogoDownloaded, tGroupId)
  me.updateGroupLogoToWindow(tGroupId)
end

on showUsersInfoByName me, tUserName
  tUserIndex = getThread(#room).getComponent().getUsersRoomId(tUserName)
  if tUserIndex <> -1 then
    me.showUsersInfo(tUserIndex)
  end if
end

on showUsersInfo me, tUserIndex
  tRoomComponent = getThread(#room).getComponent()
  tuser = tRoomComponent.getUserObject(tUserIndex)
  if voidp(tuser) then
    return 0
  end if
  tGroupId = tuser.getProperty(#groupID)
  tGroupId = string(tGroupId)
  tGroupStatus = tuser.getProperty(#groupstatus)
  if tGroupId = EMPTY then
    return 0
  end if
  if integer(tGroupId) < 0 then
    return 0
  end if
  if voidp(pGroupData[tGroupId]) then
    pLastPendingData = [#userindex: tUserIndex, #groupID: tGroupId]
    getConnection(getVariable("connection.info.id")).send("GET_GROUP_DETAILS", [#integer: integer(tGroupId)])
    return 0
  end if
  if voidp(pGroupData[tGroupId][#name]) then
    pLastPendingData = [#userindex: tUserIndex, #groupID: tGroupId]
    getConnection(getVariable("connection.info.id")).send("GET_GROUP_DETAILS", [#integer: integer(tGroupId)])
    return 0
  end if
  if not windowExists(pGroupWindowID) then
    createWindow(pGroupWindowID, "habbo_full.window")
    tWindowObj = getWindow(pGroupWindowID)
    tWindowObj.merge("group_info.window")
    tWindowObj.registerProcedure(#eventProcInfoWindow, me.getID(), #mouseUp)
  end if
  tWindowObj = getWindow(pGroupWindowID)
  tGroup = pGroupData[tGroupId]
  tUserStatusTxt = EMPTY
  case tGroupStatus of
    1:
      tUserStatusTxt = getText("group_owner")
    2:
      tUserStatusTxt = getText("group_admin")
    3:
      tUserStatusTxt = getText("group_member")
  end case
  tPrivilegesTxt = getText("group_privileges")
  tPrivilegesTxt = tPrivilegesTxt && tUserStatusTxt
  tWindowObj.getElement("group_name").setText(tGroup[#name])
  tWindowObj.getElement("group_privileges").setText(tPrivilegesTxt)
  tWindowObj.getElement("group_description").setText(tGroup[#desc])
  pCurrentShownGroupId = tGroupId
  tRoomLinkElem = tWindowObj.getElement("group_room_link")
  if tGroup[#roomid] < 0 then
    tRoomLinkElem.hide()
  else
    tRoomNameTemplate = getText("group_room_link")
    tRoomLinkText = replaceChunks(tRoomNameTemplate, "%room_name%", tGroup[#roomname])
    tRoomLinkElem.setText(tRoomLinkText)
    tRoomLinkElem.show()
  end if
  me.updateGroupLogoToWindow(tGroupId)
end

on updateGroupLogoToWindow me, tGroupId
  if voidp(tGroupId) then
    return 0
  end if
  if not windowExists(pGroupWindowID) then
    return 0
  end if
  if pCurrentShownGroupId <> tGroupId then
    return 0
  end if
  tWindowObj = getWindow(pGroupWindowID)
  if not tWindowObj.elementExists("group_logo") then
    return 0
  end if
  tGroupLogoMemNum = me.getGroupLogoMemberNum(tGroupId)
  tLogoImg = member(tGroupLogoMemNum).image
  tWindowObj.getElement("group_logo").clearImage()
  tWindowObj.getElement("group_logo").feedImage(tLogoImg)
end

on eventProcInfoWindow me, tEvent, tSprID, tParams
  case tSprID of
    "group_homepage_link":
      tGroupId = pGroupData[pCurrentShownGroupId][#id]
      tGroupURL = getText("group_homepage_url")
      tGroupURL = replaceChunks(tGroupURL, "%groupid%", tGroupId)
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tGroupURL)
    "group_room_link":
      tForwardId = string(pGroupData[pCurrentShownGroupId][#roomid])
      tForwardType = #private
      executeMessage(#roomForward, tForwardId, tForwardType)
  end case
end
