on construct(me)
  pWindowList = []
  pCreatorID = "room.object.displayer.window.creator"
  createObject(pCreatorID, "Room Object Window Creator Class")
  pBadgeObjID = "room.obj.disp.badge.mngr"
  createObject(pBadgeObjID, "Badge Manager Class")
  registerMessage(#groupLogoDownloaded, me.getID(), #groupLogoDownloaded)
  registerMessage(#hideInfoStand, me.getID(), #clearWindowDisplayList)
  pWindowCreator = getObject(pCreatorID)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#hideInfoStand, me.getID())
  unregisterMessage(#groupLogoDownloaded, me.getID())
  removeObject(pBadgeObjID)
  removeObject(pCreatorID)
  return(1)
  exit
end

on showObjectInfo(me, tObjType)
  if pWindowCreator = 0 then
    return(0)
  end if
  me.clearWindowDisplayList()
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tWindowTypes = []
  if me = "user" then
    tObj = tRoomComponent.getUserObject(tSelectedObj)
    tWindowTypes = getVariableValue("object.display.windows.human")
  else
    if me = "bot" then
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.bot")
    else
      if me = "active" then
        tObj = tRoomComponent.getActiveObject(tSelectedObj)
        tWindowTypes = getVariableValue("object.display.windows.furni")
      else
        if me = "item" then
          tObj = tRoomComponent.getItemObject(tSelectedObj)
          tWindowTypes = getVariableValue("object.display.windows.furni")
        else
          if me = "pet" then
            tObj = tRoomComponent.getUserObject(tSelectedObj)
            tWindowTypes = getVariableValue("object.display.windows.pet")
          else
            error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
            tObj = 0
          end if
        end if
      end if
    end if
  end if
  if tObj = 0 then
    return(0)
  else
    tProps = tObj.getInfo()
  end if
  tPos = 1
  repeat while tPos <= tWindowTypes.count
    tWindowType = tWindowTypes.getAt(tPos)
    if me = "human" then
      tID = pWindowCreator.createHumanWindow(tProps.getAt(#class), tProps.getAt(#name), tProps.getAt(#custom), tProps.getAt(#image), tProps.getAt(#badge), tSelectedObj, pBadgeObjID)
      me.updateInfoStandGroup(tProps.getAt(#groupid))
      me.pushWindowToDisplayList(tID)
    else
      if me = "furni" then
        tID = pWindowCreator.createFurnitureWindow(tProps.getAt(#class), tProps.getAt(#name), tProps.getAt(#custom), tProps.getAt(#smallmember))
        me.pushWindowToDisplayList(tID)
      else
        if me = "pet" then
          tID = pWindowCreator.createPetWindow(tProps.getAt(#class), tProps.getAt(#name), tProps.getAt(#custom), tProps.getAt(#image))
          me.pushWindowToDisplayList(tID)
        else
          if me = "links_human" then
            if tProps.getAt(#name) = getObject(#session).GET("user_name") then
              tID = pWindowCreator.createLinksWindow(#own)
            else
              tID = pWindowCreator.createLinksWindow(#peer)
            end if
            me.pushWindowToDisplayList(tID)
          else
            if me = "links_furni" then
              tID = pWindowCreator.createLinksWindow(#furni)
              me.pushWindowToDisplayList(tID)
            else
              if me = "actions_human" then
                tID = pWindowCreator.createActionsHumanWindow(tProps.getAt(#name))
                me.pushWindowToDisplayList(tID)
              else
                if me = "actions_furni" then
                  tID = pWindowCreator.createActionsFurniWindow(tObjType)
                  me.pushWindowToDisplayList(tID)
                else
                  if me = "bottom" then
                    tID = pWindowCreator.createBottomWindow()
                    me.pushWindowToDisplayList(tID)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    if windowExists(tID) then
      tWndObj = getWindow(tID)
      tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    end if
    tPos = 1 + tPos
  end repeat
  createTimeout("object.displayer.align", 40, #alignWindows, me.getID(), void(), 1)
  exit
end

on clearWindowDisplayList(me)
  repeat while me <= undefined
    tWindowID = getAt(undefined, undefined)
    removeWindow(tWindowID)
  end repeat
  pWindowList = []
  exit
end

on pushWindowToDisplayList(me, tWindowID)
  pWindowList.add(tWindowID)
  exit
end

on alignWindows(me)
  if pWindowList.count = 0 then
    return(0)
  end if
  tIndex = pWindowList.count
  repeat while tIndex >= 1
    tWindowID = pWindowList.getAt(tIndex)
    tWindowObj = getWindow(tWindowID)
    if tIndex = pWindowList.count then
      tDefLeftPos = getVariable("object.display.pos.left")
      tDefTopPos = getVariable("object.display.pos.bottom")
      tWindowObj.moveTo(tDefLeftPos, tDefTopPos)
    else
      tPrevWindowID = pWindowList.getAt(tIndex + 1)
      tPrevWindow = getWindow(tPrevWindowID)
      tTopPos = tPrevWindow.getProperty(#locY) - tWindowObj.getProperty(#height)
      tWindowObj.moveTo(tDefLeftPos, tTopPos)
    end if
    tIndex = 255 + tIndex
  end repeat
  exit
end

on updateInfoStandGroup(me, tGroupId)
  tHumanWindowID = pWindowCreator.getHumanWindowID()
  if windowExists(tHumanWindowID) then
    tWindowObj = getWindow(tHumanWindowID)
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

on eventProc(me, tEvent, tSprID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  tComponent = getThread(#room).getComponent()
  tOwnUser = tComponent.getOwnUser()
  tInterface = getThread(#room).getInterface()
  tSelectedObj = tInterface.pSelectedObj
  tSelectedType = tInterface.pSelectedType
  if me = "dance.button" then
    tCurrentDance = tOwnUser.getProperty(#dancing)
    if tCurrentDance > 0 then
      tComponent.getRoomConnection().send("STOP", "Dance")
    else
      tComponent.getRoomConnection().send("DANCE")
    end if
    return(1)
  else
    if me = "hcdance.button" then
      tCurrentDance = tOwnUser.getProperty(#dancing)
      if tParam.count(#char) = 6 then
        tInteger = integer(tParam.getProp(#char, 6))
        tComponent.getRoomConnection().send("DANCE", [#integer:tInteger])
      else
        if tCurrentDance > 0 then
          tComponent.getRoomConnection().send("STOP", "Dance")
        end if
      end if
      return(1)
    else
      if me = "wave.button" then
        if tOwnUser.getProperty(#dancing) then
          tComponent.getRoomConnection().send("STOP", "Dance")
          tInterface.dancingStoppedExternally()
        end if
        return(tComponent.getRoomConnection().send("WAVE"))
      else
        if me = "move.button" then
          return(tInterface.startObjectMover(tSelectedObj))
        else
          if me = "rotate.button" then
            return(tComponent.getActiveObject(tSelectedObj).rotate())
          else
            if me = "pick.button" then
              if me = "active" then
                ttype = "stuff"
              else
                if me = "item" then
                  ttype = "item"
                else
                  return(me.clearWindowDisplayList())
                end if
              end if
              return(tComponent.getRoomConnection().send("ADDSTRIPITEM", "new" && ttype && tSelectedObj))
            else
              if me = "delete.button" then
                pDeleteObjID = tSelectedObj
                pDeleteType = tSelectedType
                return(tInterface.showConfirmDelete())
              else
                if me = "kick.button" then
                  if tComponent.userObjectExists(tSelectedObj) then
                    tUserName = tComponent.getUserObject(tSelectedObj).getName()
                  else
                    tUserName = ""
                  end if
                  tComponent.getRoomConnection().send("KICKUSER", tUserName)
                  return(me.clearWindowDisplayList())
                else
                  if me = "give_rights.button" then
                    if tComponent.userObjectExists(tSelectedObj) then
                      tUserName = tComponent.getUserObject(tSelectedObj).getName()
                    else
                      tUserName = ""
                    end if
                    tComponent.getRoomConnection().send("ASSIGNRIGHTS", tUserName)
                    tSelectedObj = ""
                    me.clearWindowDisplayList()
                    tInterface.hideArrowHiliter()
                    return(1)
                  else
                    if me = "take_rights.button" then
                      if tComponent.userObjectExists(tSelectedObj) then
                        tUserName = tComponent.getUserObject(tSelectedObj).getName()
                      else
                        tUserName = ""
                      end if
                      tComponent.getRoomConnection().send("REMOVERIGHTS", tUserName)
                      tSelectedObj = ""
                      me.clearWindowDisplayList()
                      tInterface.hideArrowHiliter()
                      return(1)
                    else
                      if me = "friend.button" then
                        if tComponent.userObjectExists(tSelectedObj) then
                          tUserName = tComponent.getUserObject(tSelectedObj).getName()
                        else
                          tUserName = ""
                        end if
                        executeMessage(#externalBuddyRequest, tUserName)
                        return(1)
                      else
                        if me = "trade.button" then
                          tList = []
                          tList.setAt("showDialog", 1)
                          executeMessage(#getHotelClosingStatus, tList)
                          if tList.getAt("retval") = 1 then
                            return(1)
                          end if
                          if tComponent.userObjectExists(tSelectedObj) then
                            tUserName = tComponent.getUserObject(tSelectedObj).getName()
                          else
                            tUserName = ""
                          end if
                          tInterface.startTrading(tSelectedObj)
                          tInterface.getContainer().open()
                          return(1)
                        else
                          if me = "ignore.button" then
                            tIgnoreListObj = tInterface.pIgnoreListObj
                            if tComponent.userObjectExists(tSelectedObj) then
                              tUserName = tComponent.getUserObject(tSelectedObj).getName()
                              tIgnoreListObj.setIgnoreStatus(tUserName, 1)
                            end if
                            me.clearWindowDisplayList()
                            tSelectedObj = ""
                          else
                            if me = "unignore.button" then
                              tIgnoreListObj = tInterface.pIgnoreListObj
                              if tComponent.userObjectExists(tSelectedObj) then
                                tUserName = tComponent.getUserObject(tSelectedObj).getName()
                                tIgnoreListObj.setIgnoreStatus(tUserName, 0)
                              end if
                              me.clearWindowDisplayList()
                              tSelectedObj = ""
                            else
                              if me = "badge.button" then
                                if objectExists(pBadgeObjID) then
                                  getObject(pBadgeObjID).openBadgeWindow()
                                end if
                              else
                                if me = "userpage.button" then
                                  if variableExists("link.format.userpage") then
                                    tWebID = tComponent.getUserObject(tSelectedObj).getWebID()
                                    if not voidp(tWebID) then
                                      tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
                                      openNetPage(tDestURL)
                                    end if
                                  end if
                                else
                                  if me = "info_badge" then
                                    tSession = getObject(#session)
                                    tSelectedObj = tInterface.getSelectedObject()
                                    if tSelectedObj = tSession.GET("user_index") then
                                      tBadgeObj = getObject(pBadgeObjID)
                                      tBadgeObj.toggleOwnBadgeVisibility()
                                    end if
                                  else
                                    if me = "info_group_badge" then
                                      tSelectedObj = tInterface.getSelectedObject()
                                      if not voidp(tSelectedObj) and tSelectedObj <> "" then
                                        tUserObj = tComponent.getUserObject(tSelectedObj)
                                        tInfoObj = tComponent.getGroupInfoObject()
                                        if tUserObj <> 0 and tUserObj <> void() then
                                          tUserInfo = tUserObj.getInfo()
                                          tInfoObj.showUsersInfoByName(tUserInfo.getAt(#name))
                                        end if
                                      end if
                                    else
                                      if me = "room_obj_disp_close" then
                                        me.clearWindowDisplayList()
                                      else
                                        return(error(me, "Unknown object interface command:" && tSprID, #eventProcInterface, #minor))
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end