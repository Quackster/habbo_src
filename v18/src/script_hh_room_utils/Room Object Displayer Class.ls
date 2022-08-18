property pCreatorID, pWindowCreator, pWindowList, pBadgeObjID

on construct me
  pWindowList = []
  pCreatorID = "room.object.displayer.window.creator"
  createObject(pCreatorID, "Room Object Window Creator Class")
  pBadgeObjID = "room.obj.disp.badge.mngr"
  createObject(pBadgeObjID, "Badge Manager Class")
  registerMessage(#groupLogoDownloaded, me.getID(), #groupLogoDownloaded)
  registerMessage(#hideInfoStand, me.getID(), #clearWindowDisplayList)
  pWindowCreator = getObject(pCreatorID)
  return 1
end

on deconstruct me
  unregisterMessage(#hideInfoStand, me.getID())
  unregisterMessage(#groupLogoDownloaded, me.getID())
  removeObject(pBadgeObjID)
  removeObject(pCreatorID)
  return 1
end

on showObjectInfo me, tObjType
  if (pWindowCreator = 0) then
    return 0
  end if
  me.clearWindowDisplayList()
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tWindowTypes = []
  case tObjType of
    "user":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.human")
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
      error(me, ("Unsupported object type:" && tObjType), #showObjectInfo, #minor)
      tObj = 0
  end case
  if (tObj = 0) then
    return 0
  else
    tProps = tObj.getInfo()
  end if
  repeat with tPos = 1 to tWindowTypes.count
    tWindowType = tWindowTypes[tPos]
    case tWindowType of
      "human":
        tID = pWindowCreator.createHumanWindow(tProps[#class], tProps[#name], tProps[#custom], tProps[#image], tProps[#badge], tSelectedObj, pBadgeObjID)
        me.updateInfoStandGroup(tProps[#groupid])
        me.pushWindowToDisplayList(tID)
      "furni":
        tID = pWindowCreator.createFurnitureWindow(tProps[#class], tProps[#name], tProps[#custom], tProps[#smallmember])
        me.pushWindowToDisplayList(tID)
      "pet":
        tID = pWindowCreator.createPetWindow(tProps[#class], tProps[#name], tProps[#custom], tProps[#image])
        me.pushWindowToDisplayList(tID)
      "links_human":
        if (tProps[#name] = getObject(#session).GET("user_name")) then
          tID = pWindowCreator.createLinksWindow(#own)
        else
          tID = pWindowCreator.createLinksWindow(#peer)
        end if
        me.pushWindowToDisplayList(tID)
      "links_furni":
        tID = pWindowCreator.createLinksWindow(#furni)
        me.pushWindowToDisplayList(tID)
      "actions_human":
        tID = pWindowCreator.createActionsHumanWindow(tProps[#name])
        me.pushWindowToDisplayList(tID)
      "actions_furni":
        tID = pWindowCreator.createActionsFurniWindow(tObjType)
        me.pushWindowToDisplayList(tID)
      "bottom":
        tID = pWindowCreator.createBottomWindow()
        me.pushWindowToDisplayList(tID)
    end case
    if windowExists(tID) then
      tWndObj = getWindow(tID)
      tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    end if
  end repeat
  createTimeout("object.displayer.align", 40, #alignWindows, me.getID(), VOID, 1)
end

on clearWindowDisplayList me
  repeat with tWindowID in pWindowList
    removeWindow(tWindowID)
  end repeat
  pWindowList = []
end

on pushWindowToDisplayList me, tWindowID
  pWindowList.add(tWindowID)
end

on alignWindows me
  if (pWindowList.count = 0) then
    return 0
  end if
  repeat with tIndex = pWindowList.count down to 1
    tWindowID = pWindowList[tIndex]
    tWindowObj = getWindow(tWindowID)
    if (tIndex = pWindowList.count) then
      tDefLeftPos = getVariable("object.display.pos.left")
      tDefTopPos = getVariable("object.display.pos.bottom")
      tWindowObj.moveTo(tDefLeftPos, tDefTopPos)
      next repeat
    end if
    tPrevWindowID = pWindowList[(tIndex + 1)]
    tPrevWindow = getWindow(tPrevWindowID)
    tTopPos = (tPrevWindow.getProperty(#locY) - tWindowObj.getProperty(#height))
    tWindowObj.moveTo(tDefLeftPos, tTopPos)
  end repeat
end

on updateInfoStandGroup me, tGroupId
  tHumanWindowID = pWindowCreator.getHumanWindowID()
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
  if (voidp(tGroupId) or (tGroupId < 0)) then
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
    return 0
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
end

on groupLogoDownloaded me, tGroupId
  tRoomInterface = getThread(#room).getInterface()
  tRoomComponent = getThread(#room).getComponent()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tObj = tRoomComponent.getUserObject(tSelectedObj)
  if (tObj = 0) then
    return 0
  end if
  tUsersGroup = tObj.getProperty(#groupid)
  if (tUsersGroup = tGroupId) then
    me.updateInfoStandGroup(tGroupId)
  end if
end

on eventProc me, tEvent, tSprID, tParam
  if (tEvent <> #mouseUp) then
    return 0
  end if
  tComponent = getThread(#room).getComponent()
  tOwnUser = tComponent.getOwnUser()
  tInterface = getThread(#room).getInterface()
  tSelectedObj = tInterface.pSelectedObj
  tSelectedType = tInterface.pSelectedType
  case tSprID of
    "dance.button":
      tCurrentDance = tOwnUser.getProperty(#dancing)
      if (tCurrentDance > 0) then
        tComponent.getRoomConnection().send("STOP", "Dance")
      else
        tComponent.getRoomConnection().send("DANCE")
      end if
      return 1
    "hcdance.button":
      tCurrentDance = tOwnUser.getProperty(#dancing)
      if (tParam.char.count = 6) then
        tInteger = integer(tParam.char[6])
        tComponent.getRoomConnection().send("DANCE", [#integer: tInteger])
      else
        if (tCurrentDance > 0) then
          tComponent.getRoomConnection().send("STOP", "Dance")
        end if
      end if
      return 1
    "wave.button":
      if tOwnUser.getProperty(#dancing) then
        tComponent.getRoomConnection().send("STOP", "Dance")
        tInterface.dancingStoppedExternally()
      end if
      return tComponent.getRoomConnection().send("WAVE")
    "move.button":
      return tInterface.startObjectMover(tSelectedObj)
    "rotate.button":
      return tComponent.getActiveObject(tSelectedObj).rotate()
    "pick.button":
      case tSelectedType of
        "active":
          ttype = "stuff"
        "item":
          ttype = "item"
      end case
      return me.clearWindowDisplayList()
      return tComponent.getRoomConnection().send("ADDSTRIPITEM", (("new" && ttype) && tSelectedObj))
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
      else
        tUserName = EMPTY
      end if
      executeMessage(#externalBuddyRequest, tUserName)
      return 1
    "trade.button":
      tList = [:]
      tList["showDialog"] = 1
      executeMessage(#getHotelClosingStatus, tList)
      if (tList["retval"] = 1) then
        return 1
      end if
      if tComponent.userObjectExists(tSelectedObj) then
        tUserName = tComponent.getUserObject(tSelectedObj).getName()
      else
        tUserName = EMPTY
      end if
      tInterface.startTrading(tSelectedObj)
      tInterface.getContainer().open()
      return 1
    "ignore.button":
      tIgnoreListObj = tInterface.pIgnoreListObj
      if tComponent.userObjectExists(tSelectedObj) then
        tUserName = tComponent.getUserObject(tSelectedObj).getName()
        tIgnoreListObj.setIgnoreStatus(tUserName, 1)
      end if
      me.clearWindowDisplayList()
      tSelectedObj = EMPTY
    "unignore.button":
      tIgnoreListObj = tInterface.pIgnoreListObj
      if tComponent.userObjectExists(tSelectedObj) then
        tUserName = tComponent.getUserObject(tSelectedObj).getName()
        tIgnoreListObj.setIgnoreStatus(tUserName, 0)
      end if
      me.clearWindowDisplayList()
      tSelectedObj = EMPTY
    "badge.button":
      if objectExists(pBadgeObjID) then
        getObject(pBadgeObjID).openBadgeWindow()
      end if
    "userpage.button":
      if variableExists("link.format.userpage") then
        tWebID = tComponent.getUserObject(tSelectedObj).getWebID()
        if not voidp(tWebID) then
          tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
          openNetPage(tDestURL)
        end if
      end if
    "info_badge":
      tSession = getObject(#session)
      tSelectedObj = tInterface.getSelectedObject()
      if (tSelectedObj = tSession.GET("user_index")) then
        tBadgeObj = getObject(pBadgeObjID)
        tBadgeObj.toggleOwnBadgeVisibility()
      end if
    "info_group_badge":
      tSelectedObj = tInterface.getSelectedObject()
      if (not voidp(tSelectedObj) and (tSelectedObj <> EMPTY)) then
        tUserObj = tComponent.getUserObject(tSelectedObj)
        tInfoObj = tComponent.getGroupInfoObject()
        if ((tUserObj <> 0) and (tUserObj <> VOID)) then
          tUserInfo = tUserObj.getInfo()
          tInfoObj.showUsersInfoByName(tUserInfo[#name])
        end if
      end if
    "room_obj_disp_close":
      me.clearWindowDisplayList()
  end case
  return error(me, ("Unknown object interface command:" && tSprID), #eventProcInterface, #minor)
end
