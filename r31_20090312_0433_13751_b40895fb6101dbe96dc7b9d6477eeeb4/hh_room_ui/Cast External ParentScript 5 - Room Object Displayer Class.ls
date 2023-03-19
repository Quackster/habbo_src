property pCreatorID, pWindowCreator, pWindowList, pBadgeObjID, pShowActions, pShowUserTags, pLastSelectedObjType, pLastSelectedObj, pBaseWindowIds, pBaseLocZ, pTagListObjID, pTagListObj, pTagLists, pClosed, pTagRequestTimeout, pBadgeDetailsWindowID

on construct me
  pWindowList = []
  if variableExists("displayer.tag.expiration.time") then
    pTagRequestTimeout = getVariable("displayer.tag.expiration.time")
  else
    pTagRequestTimeout = 120000
  end if
  pCreatorID = "room.object.displayer.window.creator"
  createObject(pCreatorID, "Room Object Window Creator Class")
  pBadgeObjID = "room.obj.disp.badge.mngr"
  pShowActions = 1
  pShowUserTags = 1
  pLastSelectedObjType = VOID
  pTagListObjID = "room.obj.disp.tags"
  createObject(pTagListObjID, "Tag List Class")
  pBadgeDetailsWindowID = #badgeDetailsWindowID
  pBaseLocZ = 0
  pBaseWindowIds = getVariableValue("object.displayer.window.ids")
  me.createBaseWindows()
  registerMessage(#groupLogoDownloaded, me.getID(), #groupLogoDownloaded)
  registerMessage(#hideInfoStand, me.getID(), #clearWindowDisplayList)
  registerMessage(#updateInfoStandButtons, me.getID(), #refreshView)
  registerMessage(#updateInfostandAvatar, me.getID(), #refreshView)
  registerMessage(#showObjectInfo, me.getID(), #showObjectInfo)
  registerMessage(#hideObjectInfo, me.getID(), #clearWindowDisplayList)
  registerMessage(#removeObjectInfo, me.getID(), #clearWindowDisplayList)
  registerMessage(#updateInfoStandBadge, me.getID(), #updateBadge)
  registerMessage(#leaveRoom, me.getID(), #clearWindowDisplayList)
  registerMessage(#updateUserTags, me.getID(), #updateTagList)
  registerMessage(#changeRoom, me.getID(), #clearWindowDisplayList)
  registerMessage(#itemObjectsUpdated, me.getID(), #refreshView)
  registerMessage(#activeObjectsUpdated, me.getID(), #refreshView)
  registerMessage(#updateClubStatus, me.getID(), #refreshView)
  registerMessage(#remove_user, me.getID(), #userRemoved)
  registerMessage(#activeObjectRemoved, me.getID(), #refreshView)
  registerMessage(#itemObjectRemoved, me.getID(), #refreshView)
  pWindowCreator = getObject(pCreatorID)
  pTagListObj = getObject(pTagListObjID)
  pTagLists = [:]
  return 1
end

on deconstruct me
  unregisterMessage(#updateInfoStandButtons, me.getID())
  unregisterMessage(#hideInfoStand, me.getID())
  unregisterMessage(#groupLogoDownloaded, me.getID())
  removeObject(pCreatorID)
  me.removeBadgeDetailsBubble()
  return 1
end

on updateBadge me, tBadgeName
  me.refreshView()
end

on createBaseWindows me
  repeat with tIndex = 1 to pBaseWindowIds.count
    tID = pBaseWindowIds[tIndex]
    if not windowExists(tID) then
      createWindow(tID, "obj_disp_base.window", 999, 999)
      tWndObj = getWindow(tID)
      if tIndex = 1 then
        pBaseLocZ = tWndObj.getProperty(#locZ) - 1000
      end if
    end if
    tWndObj.hide()
  end repeat
end

on userRemoved me, tObjectId
  tRoomInterface = getObject(#room_interface)
  if tRoomInterface = 0 then
    return 0
  end if
  tSelectedObj = tRoomInterface.getSelectedObject()
  if tSelectedObj = tObjectId then
    me.refreshView()
    me.removeBadgeDetailsBubble()
  end if
  return 1
end

on showObjectInfo me, tObjType, tRefresh
  if pClosed and tRefresh then
    return 1
  end if
  if voidp(tObjType) then
    return 0
  end if
  if pWindowCreator = 0 then
    return 0
  end if
  me.clearWindowDisplayList()
  pLastSelectedObjType = tObjType
  if not threadExists(#room) then
    return 0
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  if (tSelectedObj = 0) and not stringp(tSelectedObj) then
    return 0
  end if
  pLastSelectedObj = tSelectedObj
  tWindowTypes = []
  case tObjType of
    "user":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      if (tObj <> 0) and pShowUserTags then
        tUserID = integer(tObj.getWebID())
        me.updateUserTags(tUserID)
      else
        return 0
      end if
      if tObj <> 0 then
        tProps = tObj.getInfo()
        if ilk(tProps) <> #propList then
          return 0
        end if
      else
        return 0
      end if
      if tProps[#name] = getObject(#session).GET("user_name") then
        tWindowTypes = getVariableValue("object.display.windows.human.own")
      else
        tWindowTypes = getVariableValue("object.display.windows.human")
      end if
    "bot":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.bot")
    "active":
      tObj = tRoomComponent.getActiveObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.furni")
    "item":
      tObj = tRoomComponent.getItemObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.furni")
    "pet":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.pet")
    otherwise:
      error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
      return 0
  end case
  if tObj = 0 then
    return 0
  else
    tProps = tObj.getInfo()
    if ilk(tProps) <> #propList then
      return 0
    end if
  end if
  if not listp(tWindowTypes) then
    return 0
  end if
  if ilk(pBaseWindowIds) <> #propList then
    return 0
  end if
  repeat with tPos = 1 to tWindowTypes.count
    tWindowType = tWindowTypes[tPos]
    case tWindowType of
      "motto":
        tID = pBaseWindowIds[#motto]
        pWindowCreator.createMottoWindow(tID, tProps, tSelectedObj, pBadgeObjID, pShowUserTags)
        me.pushWindowToDisplayList(tID)
      "avatar":
        tID = pBaseWindowIds[#avatar]
        pWindowCreator.createHumanWindow(tID, tProps, tSelectedObj, pBadgeObjID, pShowUserTags)
        me.updateInfoStandGroup(tProps[#groupID])
        me.pushWindowToDisplayList(tID)
      "bot":
        tID = pBaseWindowIds[#avatar]
        pWindowCreator.createBotWindow(tID, tProps)
        me.pushWindowToDisplayList(tID)
      "furni":
        tID = pBaseWindowIds[#avatar]
        pWindowCreator.createFurnitureWindow(tID, tProps)
        me.pushWindowToDisplayList(tID)
      "pet":
        tID = pBaseWindowIds[#avatar]
        pWindowCreator.createPetWindow(tID, tProps)
        me.pushWindowToDisplayList(tID)
      "tags_user":
        if pShowUserTags then
          if ilk(pTagLists) <> #propList then
            pTagLists = [:]
          end if
          tOwnUserId = integer(getObject(#session).GET("user_user_id"))
          if voidp(pTagLists.getaProp(tOwnUserId)) then
            me.updateUserTags(tOwnUserId)
          else
            tOwnTags = pTagLists.getaProp(tOwnUserId)[#tags]
          end if
          tUserTagData = pTagLists.getaProp(tObj.getWebID())
          if ilk(tUserTagData) = #propList then
            tTagList = tUserTagData[#tags]
          else
            tTagList = []
          end if
          if ilk(tTagList) <> #list then
            tTagList = []
          end if
          if tTagList.count > 0 then
            tID = pBaseWindowIds[#tags]
            pWindowCreator.createUserTagsWindow(tID)
            me.pushWindowToDisplayList(tID)
            tTagsWindow = getWindow(tID)
            tTagsElem = tTagsWindow.getElement("room_obj_disp_tags")
            pTagListObj.setWidth(tTagsElem.getProperty(#width))
            pTagListObj.setHeight(tTagsElem.getProperty(#height))
            if objectp(pTagListObj) then
              if tOwnUserId = tObj.getWebID() then
                pTagListObj.setOwnTags([])
              else
                pTagListObj.setOwnTags(tOwnTags)
              end if
              tTagListImage = pTagListObj.createTagList(tTagList)
              tTagsElem.feedImage(tTagListImage)
              tOffset = tTagListImage.height - tTagsWindow.getProperty(#height)
              tTagsWindow.resizeBy(0, tOffset)
            end if
          end if
        end if
      "xp_user":
        tXP = tProps.getaProp(#xp)
        if not (voidp(tXP) or (tXP = 0)) then
          tID = pBaseWindowIds[#xp]
          pWindowCreator.createUserXpWindow(tID, tXP)
          me.pushWindowToDisplayList(tID)
        end if
      "fx_user":
        tFx = tProps.getaProp(#FX)
        if listp(tFx) then
          if tFx.count > 0 then
            tID = pBaseWindowIds[#FX]
            pWindowCreator.createUserFxWindow(tID, tFx)
            me.pushWindowToDisplayList(tID)
          end if
        end if
      "links_human":
        tID = pBaseWindowIds[#links]
        if tProps[#name] = getObject(#session).GET("user_name") then
          pWindowCreator.createLinksWindow(tID, #own)
        else
          pWindowCreator.createLinksWindow(tID, #peer)
        end if
        me.pushWindowToDisplayList(tID)
      "actions_human":
        tID = pBaseWindowIds[#actions]
        pWindowCreator.createActionsHumanWindow(tID, tProps[#name], pShowActions)
        me.pushWindowToDisplayList(tID)
      "actions_furni":
        if tRoomComponent.itemObjectExists(tSelectedObj) then
          tselectedobject = tRoomComponent.getItemObject(tSelectedObj)
          if objectp(tselectedobject) then
            tClass = tselectedobject.getClass()
            if tClass contains "post.it" then
              next repeat
            end if
          end if
        end if
        tID = pBaseWindowIds[#actions]
        pWindowCreator.createActionsFurniWindow(tID, tObjType, pShowActions)
        me.pushWindowToDisplayList(tID)
      "bottom":
        tID = pBaseWindowIds[#bottom]
        pWindowCreator.createBottomWindow(tID)
        me.pushWindowToDisplayList(tID)
    end case
    if windowExists(tID) then
      tWndObj = getWindow(tID)
      tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProc, me.getID(), #mouseEnter)
      tWndObj.registerProcedure(#eventProc, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProc, me.getID(), #mouseLeave)
    end if
  end repeat
  me.alignWindows()
  pClosed = 0
end

on clearWindowDisplayList me
  if pWindowCreator = 0 then
    return 0
  end if
  if listp(pWindowList) and objectp(pWindowCreator) then
    repeat with tWindowID in pWindowList
      pWindowCreator.clearWindow(tWindowID)
    end repeat
  end if
  pWindowList = []
  if objectExists(pBadgeObjID) then
    getObject(pBadgeObjID).removeBadgeEffect()
  end if
end

on pushWindowToDisplayList me, tWindowID
  pWindowList.add(tWindowID)
end

on refreshView me
  me.clearWindowDisplayList()
  me.showObjectInfo(pLastSelectedObjType, 1)
end

on showHideActions me
  pShowActions = not pShowActions
  me.refreshView()
end

on showHideTags me
  pShowUserTags = not pShowUserTags
  me.refreshView()
end

on updateUserTags me, tUserID
  tLastUpdateTime = 0
  tTimeNow = the milliSeconds
  if ilk(pTagLists) <> #propList then
    return 0
  end if
  tUserData = pTagLists.getaProp(tUserID)
  if listp(tUserData) then
    tLastUpdateTime = tUserData[#lastUpdate]
  else
    pTagLists[string(tUserID)] = [#tags: [], #lastUpdate: 0]
  end if
  if (tTimeNow - tLastUpdateTime) > pTagRequestTimeout then
    if ilk(pTagLists[string(tUserID)]) = #propList then
      pTagLists[string(tUserID)][#lastUpdate] = tTimeNow
      getConnection(#Info).send("GET_USER_TAGS", [#integer: tUserID])
    end if
  end if
end

on alignWindows me
  if ilk(pWindowList) <> #list then
    return 0
  end if
  if pWindowList.count = 0 then
    return 0
  end if
  tDefLeftPos = getVariable("object.display.pos.left")
  tDefBottomPos = getVariable("object.display.pos.bottom")
  tAlignments = getVariableValue("object.displayer.window.align", [:])
  tStageWidth = the stageRight - the stageLeft
  tDefLeftPos = tDefLeftPos + (tStageWidth - 720)
  repeat with tIndex = pWindowList.count down to 1
    tWindowID = pWindowList[tIndex]
    if not windowExists(tWindowID) then
      next repeat
    end if
    tWindowObj = getWindow(tWindowID)
    tWindowObj.moveZ(pBaseLocZ + ((tIndex - 1) * 100))
    tWindowType = pBaseWindowIds.getOne(tWindowID)
    tAlignment = tAlignments.getaProp(tWindowType)
    if voidp(tAlignment) then
      tAlignment = #left
    end if
    tLeft = tDefLeftPos
    if tIndex = pWindowList.count then
      tNextWindowID = pWindowList[tIndex - 1]
      if windowExists(tNextWindowID) then
        tNextWindow = getWindow(tNextWindowID)
        if tAlignment = #right then
          tLeft = tDefLeftPos + tNextWindow.getProperty(#width) - tWindowObj.getProperty(#width)
        end if
        tTop = tDefBottomPos - tWindowObj.getProperty(#height)
      end if
    else
      tPrevWindowID = pWindowList[tIndex + 1]
      if windowExists(tPrevWindowID) then
        tPrevWindow = getWindow(tPrevWindowID)
        if tAlignment = #right then
          tLeft = tDefLeftPos + tPrevWindow.getProperty(#width) - tWindowObj.getProperty(#width)
        end if
        tTop = tPrevWindow.getProperty(#locY) - tWindowObj.getProperty(#height)
      end if
    end if
    tWindowObj.moveTo(tLeft, tTop)
  end repeat
end

on updateInfoStandGroup me, tGroupId
  if ilk(pBaseWindowIds) <> #propList then
    return 0
  end if
  tHumanWindowID = pBaseWindowIds[#avatar]
  if windowExists(tHumanWindowID) then
    tWindowObj = getWindow(tHumanWindowID)
    if tWindowObj.elementExists("info_group_badge") then
      tElem = tWindowObj.getElement("info_group_badge")
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
  if not threadExists(#room) then
    return 0
  end if
  tRoomComponent = getThread(#room).getComponent()
  tGroupInfoObject = tRoomComponent.getGroupInfoObject()
  if not objectp(tGroupInfoObject) then
    return 0
  end if
  tLogoMemNum = tGroupInfoObject.getGroupLogoMemberNum(tGroupId)
  tGroupImageFound = 1
  if member(tLogoMemNum).type <> #bitmap then
    tGroupImageFound = 0
  end if
  if not voidp(tGroupId) and tGroupImageFound then
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

on updateTagList me, tUserID, tTagList
  tUserTagData = pTagLists.getaProp(tUserID)
  if voidp(tUserTagData) then
    tUserTagData = [#tags: [], #lastUpdate: 0]
  end if
  tOldList = tUserTagData[#tags]
  if tOldList <> tTagList then
    pTagLists.setaProp(tUserID, [#tags: tTagList, #lastUpdate: the milliSeconds])
    me.refreshView()
  end if
end

on updateBadgeDetailsBubble me, tElemID
  if not objectExists(#session) then
    return 0
  end if
  tRoomThread = getThread(#room)
  tSelectedObjID = tRoomThread.getInterface().getSelectedObject()
  tSelectedObj = tRoomThread.getComponent().getUserObject(tSelectedObjID)
  if not tSelectedObj then
    return 0
  end if
  tBadges = tSelectedObj.getProperty(#badges)
  if tBadges.ilk <> #propList then
    tBadges = [:]
  end if
  tBadgeIndex = value(tElemID.char[tElemID.length])
  if not integerp(tBadgeIndex) then
    return 0
  end if
  tBadgeID = tBadges.getaProp(tBadgeIndex)
  if voidp(tBadgeID) then
    return 0
  end if
  tWindowID = pBaseWindowIds.getaProp(#avatar)
  if not windowExists(tWindowID) then
    return 0
  end if
  tWindow = getWindow(tWindowID)
  if not tWindow.elementExists(tElemID) then
    return 0
  end if
  if objectExists(pBadgeDetailsWindowID) then
    removeObject(pBadgeDetailsWindowID)
  end if
  tElem = tWindow.getElement(tElemID)
  tTargetRect = tElem.getProperty(#rect)
  tBubble = createObject(pBadgeDetailsWindowID, "Details Bubble Class")
  tBubble.createWithContent("badge_info.window", tTargetRect, #left)
  tBubbleWindow = tBubble.getWindowObj()
  tBubbleWindow.getElement("badge.info.name").setText(getText("badge_name_" & tBadgeID))
  tBubbleWindow.getElement("badge.info.desc").setText(getText("badge_desc_" & tBadgeID))
  return 1
end

on removeBadgeDetailsBubble me
  if objectExists(pBadgeDetailsWindowID) then
    removeObject(pBadgeDetailsWindowID)
  end if
end

on eventProc me, tEvent, tSprID, tParam
  tComponent = getThread(#room).getComponent()
  tOwnUser = tComponent.getOwnUser()
  tInterface = getThread(#room).getInterface()
  tSelectedObj = tInterface.pSelectedObj
  tSelectedType = tInterface.pSelectedType
  tSession = getObject(#session)
  if tSprID contains "info_badge" then
    case tEvent of
      #mouseEnter:
        if not me.updateBadgeDetailsBubble(tSprID) then
          me.removeBadgeDetailsBubble()
        end if
      #mouseLeave:
        me.removeBadgeDetailsBubble()
      #mouseUp:
        tSelectedObj = tInterface.getSelectedObject()
        if tSelectedObj = tSession.GET("user_index") then
          if objectExists(pBadgeObjID) then
            getObject(pBadgeObjID).openBadgeWindow()
          end if
        end if
    end case
  end if
  if tEvent = #mouseUp then
    case tSprID of
      "badges.button":
        if objectExists(pBadgeObjID) then
          getObject(pBadgeObjID).openBadgeWindow()
        end if
      "dance.button":
        tCurrentDance = tOwnUser.getProperty(#dancing)
        if tCurrentDance > 0 then
          tComponent.getRoomConnection().send("DANCE", [#integer: 0])
        else
          tComponent.getRoomConnection().send("DANCE", [#integer: 1])
        end if
        return 1
      "hcdance.button":
        tCurrentDance = tOwnUser.getProperty(#dancing)
        if not (ilk(tParam) = #string) then
          return error(me, "tParam was not a string", #eventProc, #minor)
        end if
        if tParam.char.count = 6 then
          tInteger = integer(tParam.char[6])
          tComponent.getRoomConnection().send("DANCE", [#integer: tInteger])
        else
          if tCurrentDance > 0 then
            tComponent.getRoomConnection().send("DANCE", [#integer: 0])
          end if
        end if
        return 1
      "wave.button":
        if tOwnUser.getProperty(#dancing) then
          tComponent.getRoomConnection().send("DANCE", [#integer: 0])
          tInterface.dancingStoppedExternally()
        end if
        return tComponent.getRoomConnection().send("WAVE")
      "fx.button":
        if not (ilk(tParam) = #string) then
          return error(me, "tParam was not a string", #eventProc, #minor)
        end if
        if tParam.char.count < 3 then
          return 0
        end if
        tID = integer(tParam.char[3..tParam.length])
        if integerp(tID) then
          return executeMessage(#use_avatar_effect, tID)
        else
          case tParam of
            "fx_btn_stop":
              executeMessage(#use_avatar_effect, -1)
            "fx_btn_inventory", "fx_btn_choose":
              executeMessage(#openFxWindow)
          end case
          return 1
        end if
      "move.button":
        return tInterface.startObjectMover(tSelectedObj)
      "rotate.button":
        tActiveObj = tComponent.getActiveObject(tSelectedObj)
        if not tActiveObj then
          return 0
        end if
        return tActiveObj.rotate()
      "pick.button":
        case tSelectedType of
          "active":
            ttype = 2
          "item":
            ttype = 1
          otherwise:
            return me.clearWindowDisplayList()
        end case
        me.clearWindowDisplayList()
        return tComponent.getRoomConnection().send("ADDSTRIPITEM", [#integer: ttype, #integer: integer(tSelectedObj)])
      "delete.button":
        pDeleteObjID = tSelectedObj
        pDeleteType = tSelectedType
        return tInterface.showConfirmDelete()
      "kick.button":
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
        else
          tUserName = EMPTY
        end if
        tComponent.getRoomConnection().send("KICKUSER", tUserName)
        return me.clearWindowDisplayList()
      "ban.button":
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
        else
          tUserName = EMPTY
        end if
        tComponent.getRoomConnection().send("BANUSER", tUserName)
        return me.clearWindowDisplayList()
      "give_rights.button":
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
        else
          tUserName = EMPTY
        end if
        tComponent.getRoomConnection().send("ASSIGNRIGHTS", tUserName)
        tSelectedObj = EMPTY
        me.clearWindowDisplayList()
        tInterface.hideArrowHiliter()
        return 1
      "take_rights.button":
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
        else
          tUserName = EMPTY
        end if
        tComponent.getRoomConnection().send("REMOVERIGHTS", tUserName)
        tSelectedObj = EMPTY
        me.clearWindowDisplayList()
        tInterface.hideArrowHiliter()
        return 1
      "friend.button":
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
          executeMessage(#externalFriendRequest, tUserName)
        end if
        return 1
      "respect.button":
        if tComponent.userObjectExists(tSelectedObj) then
          tWebID = tComponent.getUserObject(tSelectedObj).getWebID()
          executeMessage(#externalGiveRespect, tWebID)
        end if
        return 1
      "trade.button":
        tList = [:]
        tList["showDialog"] = 1
        executeMessage(#getHotelClosingStatus, tList)
        if tList["retval"] = 1 then
          return 1
        end if
        if (pLastSelectedObjType <> "user") or not tComponent.userObjectExists(pLastSelectedObj) then
          me.clearWindowDisplayList()
          return 0
        end if
        tInterface.startTrading(pLastSelectedObj)
        return 1
      "ignore.button":
        tIgnoreListObj = tInterface.getIgnoreListObject()
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
          tIgnoreListObj.setIgnoreStatus(tUserName, 1)
        else
          tUserName = EMPTY
        end if
        me.clearWindowDisplayList()
        tSelectedObj = EMPTY
      "unignore.button":
        tIgnoreListObj = tInterface.getIgnoreListObject()
        if tComponent.userObjectExists(tSelectedObj) then
          tUserName = tComponent.getUserObject(tSelectedObj).getName()
          tIgnoreListObj.setIgnoreStatus(tUserName, 0)
        end if
        me.clearWindowDisplayList()
        tSelectedObj = EMPTY
      "room_obj_disp_badge_sel", "room_obj_disp_icon_badge":
        if objectExists(pBadgeObjID) then
          getObject(pBadgeObjID).openBadgeWindow()
        end if
      "room_obj_disp_home", "room_obj_disp_icon_home", "room_obj_disp_name":
        if tComponent.userObjectExists(tSelectedObj) then
          if variableExists("link.format.userpage") then
            tWebID = tComponent.getUserObject(tSelectedObj).getWebID()
            if not voidp(tWebID) then
              if tWebID > 0 then
                tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
                executeMessage(#externalLinkClick, the mouseLoc)
                openNetPage(tDestURL)
              end if
            end if
          end if
        end if
      "info_group_badge":
        tSelectedObj = tInterface.getSelectedObject()
        if not voidp(tSelectedObj) and (tSelectedObj <> EMPTY) then
          tUserObj = tComponent.getUserObject(tSelectedObj)
          tInfoObj = tComponent.getGroupInfoObject()
          if (tUserObj <> 0) and (tUserObj <> VOID) then
            tUserInfo = tUserObj.getInfo()
            tInfoObj.showUsersInfoByName(tUserInfo[#name])
          end if
        end if
      "object_displayer_toggle_actions":
        me.showHideActions()
      "object_displayer_toggle_actions_icon":
        me.showHideActions()
      "object_displayer_toggle_tags":
        me.showHideTags()
      "object_displayer_toggle_tags_icon":
        me.showHideTags()
      "room_obj_disp_close":
        pClosed = 1
        me.clearWindowDisplayList()
      "room_obj_disp_looks", "room_obj_disp_icon_avatar", "room_obj_disp_avatar", "outlook.button":
        if tSelectedObj = tSession.GET("user_index") then
          tAllowModify = 1
          if getObject(#session).exists("allow_profile_editing") then
            tAllowModify = getObject(#session).GET("allow_profile_editing")
          end if
          if tAllowModify then
            if threadExists(#registration) then
              getThread(#registration).getComponent().openFigureUpdate()
            end if
          else
            executeMessage(#externalLinkClick, the mouseLoc)
            openNetPage(getText("url_figure_editor"))
          end if
        end if
      "room_obj_disp_tags":
        if not (ilk(tParam) = #point) then
          return 0
        end if
        tTag = pTagListObj.getTagAt(tParam)
        if stringp(tTag) then
          tDestURL = replaceChunks(getVariable("link.format.tag.search"), "%tag%", tTag)
          executeMessage(#externalLinkClick, the mouseLoc)
          openNetPage(tDestURL)
        end if
      "room_obj_disp_bg":
        return 0
    end case
  else
    if tEvent = #mouseWithin then
      case tSprID of
        "room_obj_disp_tags":
          if not (ilk(tParam) = #point) then
            return 0
          end if
          tTagsWindow = getWindow(pBaseWindowIds[#tags])
          tElem = tTagsWindow.getElement(tSprID)
          if stringp(pTagListObj.getTagAt(tParam)) then
            tElem.setProperty(#cursor, "cursor.finger")
          else
            tElem.setProperty(#cursor, 0)
          end if
        otherwise:
          nothing()
      end case
    else
      if tEvent = #mouseLeave then
        case tSprID of
          "room_obj_disp_tags":
            tTagsWindow = getWindow(pBaseWindowIds[#tags])
            tElem = tTagsWindow.getElement(tSprID)
            tElem.setProperty(#cursor, 0)
          otherwise:
            nothing()
        end case
      end if
    end if
  end if
end
