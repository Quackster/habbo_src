on construct(me)
  pGroupWindowID = getText("group_window_title")
  pGroupData = []
  pCurrentShownGroupId = void()
  pGroupsWithDownloadedLogo = []
  pLastPendingData = []
  pGroupLogoMemPrefix = "group_logo_"
  pGroupLogoTemplateMember = "logo_downloading_template"
  pGroupLogoUrlTemplate = getText("group_logo_url_template")
  registerMessage(#roomReady, me.getID(), #requestGroups)
  registerMessage(#leaveRoom, me.getID(), #clearGroups)
  registerMessage(#changeRoom, me.getID(), #clearGroups)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#userClicked, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  return(1)
  exit
end

on updateGroupInformation(me, tGroupsArr)
  if not listp(tGroupsArr) then
    return(0)
  end if
  repeat while me <= undefined
    tIncomingGroupData = getAt(undefined, tGroupsArr)
    tid = string(tIncomingGroupData.getAt(#id))
    tCombinedData = []
    if not voidp(pGroupData.getAt(tid)) then
      tCombinedData = pGroupData.getAt(tid)
    end if
    tKeyList = [#id, #name, #desc, #logo]
    repeat while me <= undefined
      tKey = getAt(undefined, tGroupsArr)
      if not voidp(tIncomingGroupData.getAt(tKey)) then
        tCombinedData.setAt(tKey, tIncomingGroupData.getAt(tKey))
        if tKey = #logo then
          tCombinedData.setAt(#download, #invalid)
        end if
      end if
    end repeat
    pGroupData.setAt(tid, tCombinedData)
    if pLastPendingData.getAt(#groupid) = tid then
      me.showUsersInfo(pLastPendingData.getAt(#userindex))
      pGroupData.getAt(tid).setAt(#download, #done)
      pLastPendingData = []
    end if
  end repeat
  exit
end

on getGroupInformation(me, tGroupId)
  tGroupInfo = []
  tGroupId = string(tGroupId)
  if not voidp(pGroupData.getAt(tGroupId)) then
    tGroupInfo = pGroupData.getAt(tGroupId)
  end if
  return(tGroupInfo)
  exit
end

on getGroupLogoMemberNum(me, tGroupId)
  tGroupData = pGroupData.getaProp(tGroupId)
  if voidp(tGroupData) then
    return(getmemnum(pGroupLogoTemplateMember))
  end if
  tGroupLogoMem = pGroupLogoMemPrefix & tGroupData.getAt(#logo)
  if memberExists(tGroupLogoMem) then
    return(getmemnum(tGroupLogoMem))
  else
    me.requestLogoDownload(tGroupId)
    return(getmemnum(pGroupLogoTemplateMember))
  end if
  exit
end

on closeView(me)
  removeWindow(pGroupWindowID)
  exit
end

on clearGroups(me)
  me.closeView()
  pGroupInformation = []
  pCurrentShownGroupId = void()
  exit
end

on requestGroups(me)
  getConnection(getVariable("connection.room.id")).send("GET_GROUP_BADGES")
  exit
end

on getLogoURL(me, tGroupId)
  if voidp(tGroupId) then
    return(0)
  end if
  tURL = ""
  tGroupData = pGroupData.getAt(tGroupId)
  if ilk(tGroupData) = #propList then
    tURL = pGroupLogoUrlTemplate
    tGroupLogoPath = tGroupData.getAt(#logo)
    tURL = replaceChunks(tURL, "%imagerdata%", tGroupLogoPath)
  end if
  return(tURL)
  exit
end

on requestLogoDownload(me, tGroupId)
  tGroupId = string(tGroupId)
  tGroupData = pGroupData.getaProp(tGroupId)
  if ilk(tGroupData) <> #propList then
    return(error(me, "No group found: " & tGroupId, me.getID(), #requestLogoDownload))
  end if
  tDownloadStatus = tGroupData.getAt(#download)
  if not voidp(tDownloadStatus) or tDownloadStatus = #invalid then
    return(0)
  else
    pGroupData.getAt(tGroupId).setAt(#download, #downloading)
  end if
  tMemberName = pGroupLogoMemPrefix & tGroupData.getAt(#logo)
  tLogoURL = me.getLogoURL(tGroupId)
  tMemNum = queueDownload(tLogoURL, tMemberName, #bitmap, 1)
  registerDownloadCallback(tMemNum, #logoDownloadedCallback, me.getID(), tGroupId)
  exit
end

on logoDownloadedCallback(me, tGroupId)
  executeMessage(#groupLogoDownloaded, tGroupId)
  me.updateGroupLogoToWindow(tGroupId)
  exit
end

on showUsersInfoByName(me, tUserName)
  tUserIndex = getThread(#room).getComponent().getUsersRoomId(tUserName)
  if tUserIndex <> -1 then
    me.showUsersInfo(tUserIndex)
  end if
  exit
end

on showUsersInfo(me, tUserIndex)
  tRoomComponent = getThread(#room).getComponent()
  tuser = tRoomComponent.getUserObject(tUserIndex)
  if voidp(tuser) then
    return(0)
  end if
  tGroupId = tuser.getProperty(#groupid)
  tGroupId = string(tGroupId)
  tGroupStatus = tuser.getProperty(#groupstatus)
  if tGroupId = "" then
    return(0)
  end if
  if integer(tGroupId) < 0 then
    return(0)
  end if
  if voidp(pGroupData.getAt(tGroupId)) then
    pLastPendingData = [#userindex:tUserIndex, #groupid:tGroupId]
    getConnection(getVariable("connection.info.id")).send("GET_GROUP_DETAILS", [#integer:integer(tGroupId)])
    return(0)
  end if
  if voidp(pGroupData.getAt(tGroupId).getAt(#name)) then
    pLastPendingData = [#userindex:tUserIndex, #groupid:tGroupId]
    getConnection(getVariable("connection.info.id")).send("GET_GROUP_DETAILS", [#integer:integer(tGroupId)])
    return(0)
  end if
  if not windowExists(pGroupWindowID) then
    createWindow(pGroupWindowID, "habbo_full.window")
    tWindowObj = getWindow(pGroupWindowID)
    tWindowObj.merge("group_info.window")
    tWindowObj.registerProcedure(#eventProcInfoWindow, me.getID(), #mouseUp)
  end if
  tWindowObj = getWindow(pGroupWindowID)
  tGroup = pGroupData.getAt(tGroupId)
  tUserStatusTxt = ""
  if me = 1 then
    tUserStatusTxt = getText("group_owner")
  else
    if me = 2 then
      tUserStatusTxt = getText("group_admin")
    else
      if me = 3 then
        tUserStatusTxt = getText("group_member")
      end if
    end if
  end if
  tPrivilegesTxt = getText("group_privileges")
  tPrivilegesTxt = tPrivilegesTxt && tUserStatusTxt
  tWindowObj.getElement("group_name").setText(tGroup.getAt(#name))
  tWindowObj.getElement("group_privileges").setText(tPrivilegesTxt)
  tWindowObj.getElement("group_description").setText(tGroup.getAt(#desc))
  pCurrentShownGroupId = tGroupId
  me.updateGroupLogoToWindow(tGroupId)
  exit
end

on updateGroupLogoToWindow(me, tGroupId)
  if voidp(tGroupId) then
    return(0)
  end if
  if not windowExists(pGroupWindowID) then
    return(0)
  end if
  if pCurrentShownGroupId <> tGroupId then
    return(0)
  end if
  tWindowObj = getWindow(pGroupWindowID)
  if not tWindowObj.elementExists("group_logo") then
    return(0)
  end if
  tGroupLogoMemNum = me.getGroupLogoMemberNum(tGroupId)
  tLogoImg = member(tGroupLogoMemNum).image
  tWindowObj.getElement("group_logo").clearImage()
  tWindowObj.getElement("group_logo").feedImage(tLogoImg)
  exit
end

on eventProcInfoWindow(me, tEvent, tSprID, tParams)
  if me = "group_homepage_link" then
    tGroupId = pGroupData.getAt(pCurrentShownGroupId).getAt(#id)
    tGroupURL = getText("group_homepage_url")
    tGroupURL = replaceChunks(tGroupURL, "%groupid%", tGroupId)
    openNetPage(tGroupURL)
  end if
  exit
end