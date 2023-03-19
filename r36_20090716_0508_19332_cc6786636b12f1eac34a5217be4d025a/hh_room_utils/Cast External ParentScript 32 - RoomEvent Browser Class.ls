property pWindowID, pDetailsWindowID, pEventListObj, pLineHeight, pEventID, pTypeCount, pTypeTextKeyBody, pSelectedType, pEditedEventData, pView

on construct me
  pWindowID = #eventBrowserWindow
  pDetailsWindowID = #eventBrowserDetailsWindow
  pEventListObj = createObject(#temp, "RoomEvent List Class")
  pTypeTextKeyBody = "roomevent_type_"
  pSelectedType = 0
  me.ChangeWindowView(#browse)
  registerMessage(#allowRoomeventCreation, me.getID(), #enableCreateButton)
  registerMessage(#roomEventTypeCountUpdated, me.getID(), #updateDropMenu)
  registerMessage(#roomEventsUpdated, me.getID(), #updateEventList)
  registerMessage(#enterRoom, me.getID(), #Remove)
  registerMessage(#leaveRoom, me.getID(), #Remove)
  registerMessage(#changeRoom, me.getID(), #Remove)
  pTypeCount = getThread(#room).getComponent().getRoomEventTypeCount()
  return 1
end

on deconstruct me
  me.hide()
  return 1
end

on hide me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  me.removeDetailsBubble()
end

on Remove me
  removeObject(me.getID())
end

on editEvent me, tEventData
  pEditedEventData = tEventData
  me.ChangeWindowView(#edit)
end

on ChangeWindowView me, tView
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  createWindow(pWindowID, "habbo_basic_red.window")
  tWnd = getWindow(pWindowID)
  pView = tView
  case tView of
    #browse:
      tWnd.merge("roomevent_browser.window")
      tCreateButton = tWnd.getElement("roomevent.browser.create")
      tCreateButton.deactivate()
      me.askCreatePermission()
      tWnd.registerProcedure(#eventProcBrowse, me.getID(), #mouseWithin)
      tWnd.registerProcedure(#eventProcBrowse, me.getID(), #mouseUp)
      tWnd.registerProcedure(#eventProcBrowse, me.getID(), #mouseLeave)
      me.updateDropMenu()
      me.updateEventList()
    #create:
      tWnd.merge("roomevent_create.window")
      tWnd.registerProcedure(#eventProcCreate, me.getID(), #mouseUp)
      me.updateDropMenu()
      tWnd.getElement("roomevent.create.name").setText(getText("roomevent_default_name"))
      tWnd.getElement("roomevent.create.description").setText(getText("roomevent_default_desc"))
    #edit:
      tWnd.merge("roomevent_create.window")
      tWnd.registerProcedure(#eventProcEdit, me.getID(), #mouseUp)
      tName = pEditedEventData.getaProp(#name)
      tDesc = pEditedEventData.getaProp(#desc)
      tWnd.getElement("roomevent.create.name").setText(tName)
      tWnd.getElement("roomevent.create.description").setText(tDesc)
      tWnd.getElement("roomevent.create.create").setText(getText("roomevent_edit"))
      pSelectedType = pEditedEventData.getaProp(#typeID)
      me.updateDropMenu()
      tWnd.getElement("roomevent.type").deactivate()
  end case
  activateWindowObj(pWindowID)
end

on askCreatePermission me
  tConn = getConnection(getVariable("connection.info.id", #Info))
  tConn.send("CAN_CREATE_ROOMEVENT")
end

on enableCreateButton me
  if not windowExists(pWindowID) then
    return 0
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.browser.create") then
    return 0
  end if
  tWnd.getElement("roomevent.browser.create").Activate()
  return 1
end

on updateDropMenu me
  pTypeCount = getThread(#room).getComponent().getRoomEventTypeCount()
  if pTypeCount = 0 then
    return 0
  end if
  if not windowExists(pWindowID) then
    return 0
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.type") then
    return 0
  end if
  tTextList = []
  tTextKeys = []
  if pView = #browse then
    tStartIndex = 0
  else
    tStartIndex = 1
  end if
  repeat with tIndex = tStartIndex to pTypeCount
    tKey = pTypeTextKeyBody & tIndex
    tTextKeys.add(tKey)
    tTextList.add(getText(tKey))
  end repeat
  tWnd.getElement("roomevent.type").updateData(tTextList, tTextKeys, pSelectedType)
  return 1
end

on updateEventList me
  if not windowExists(pWindowID) then
    return 0
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.browser.list") then
    return 0
  end if
  if not tWnd.elementExists("roomevent.type") then
    return 0
  end if
  tEventList = getThread(#room).getComponent().getRoomEventList(pSelectedType)
  pEventListObj.setEvents(tEventList)
  tListImage = pEventListObj.renderListImage()
  if tListImage.ilk <> #image then
    return 0
  end if
  tListElem = tWnd.getElement("roomevent.browser.list")
  tListElem.feedImage(tListImage)
end

on updateDetailsBubble me, tpoint
  if not windowExists(pWindowID) then
    return 0
  end if
  tEventData = pEventListObj.getEventAt(tpoint)
  if not tEventData then
    me.removeDetailsBubble()
    return 1
  end if
  tEventID = tEventData.getaProp(#flatId)
  if tEventID = pEventID then
    return 1
  end if
  pEventID = tEventID
  tEventRect = tEventData.getaProp(#rect)
  tWnd = getWindow(pWindowID)
  tListElem = tWnd.getElement("roomevent.browser.list")
  if not objectp(tListElem) then
    return 0
  end if
  tListRect = tListElem.getProperty(#rect)
  tScrollElem = tWnd.getElement("roomevent.browser.scroll")
  if not objectp(tScrollElem) then
    return 0
  end if
  tScrollOffset = tScrollElem.getScrollOffset()
  tLocY = tListRect[2] - tScrollOffset
  tLocX = tListRect[1]
  tTargetRect = tEventRect + rect(tLocX, tLocY, tLocX, tLocY)
  if objectExists(pDetailsWindowID) then
    removeObject(pDetailsWindowID)
  end if
  tDetailsBubble = createObject(pDetailsWindowID, "Details Bubble Class")
  tDetailsBubble.createWithContent("roomevent_info.window", tTargetRect, #right)
  tDetailsWindow = tDetailsBubble.getWindowObj()
  if not objectp(tDetailsWindow) then
    return error(me, "Failed to create event details bubble window", #updateDetailsBubble, #minor)
  end if
  tHost = getText("roomevent_host") && tEventData.getaProp(#hostName)
  tDetailsWindow.getElement("roomevent.info.host").setText(tHost)
  tText = QUOTE & tEventData.getaProp(#desc) & QUOTE
  tDetailsWindow.getElement("roomevent.info.desc").setText(tText)
  tstart = getText("roomevent_starttime") && tEventData.getaProp(#time)
  tDetailsWindow.getElement("roomevent.info.time").setText(tstart)
end

on removeDetailsBubble me
  if objectExists(pDetailsWindowID) then
    removeObject(pDetailsWindowID)
  end if
  pEventID = VOID
end

on selectEvent me, tpoint
  tEventData = pEventListObj.getEventAt(tpoint)
  if not tEventData then
    return 0
  end if
  tFlatID = tEventData.getaProp(#flatId)
  executeMessage(#roomForward, tFlatID, #private)
end

on createEvent me, tOperation
  if not windowExists(pWindowID) then
    return 0
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.type") then
    return 0
  end if
  ttype = tWnd.getElement("roomevent.type").getSelection(#key)
  tChunks = explode(ttype, "_")
  tTypeID = value(tChunks[tChunks.count])
  tName = tWnd.getElement("roomevent.create.name").getText()
  tDesc = tWnd.getElement("roomevent.create.description").getText()
  tValid = 1
  if (tName = getText("roomevent_default_name")) or (tDesc = getText("roomevent_default_desc")) then
    tValid = 0
  end if
  tMinLength = 3
  if (tName.length < tMinLength) or (tDesc.length < tMinLength) then
    tValid = 0
  end if
  if not tValid then
    executeMessage(#alert, "roomevent_invalid_input")
    return 0
  end if
  tEvent = [#integer: tTypeID, #string: tName, #string: tDesc]
  tConn = getConnection(getVariable("connection.info.id", #Info))
  if tOperation = #edit then
    tConn.send("EDIT_ROOMEVENT", tEvent)
  else
    tConn.send("CREATE_ROOMEVENT", tEvent)
  end if
  return 1
end

on eventProcBrowse me, tEvent, tElemID, tParam
  if tElemID = "roomevent.browser.list" then
    case tEvent of
      #mouseWithin:
        if tParam.ilk <> #point then
          return 0
        end if
        me.updateDetailsBubble(tParam)
      #mouseLeave:
        me.removeDetailsBubble()
      #mouseUp:
        me.selectEvent(tParam)
    end case
  end if
  if tEvent <> #mouseUp then
    return 1
  end if
  case tElemID of
    "roomevent.browser.create":
      me.ChangeWindowView(#create)
    "roomevent.close":
      me.Remove()
    "roomevent.type":
      tChunks = explode(tParam, "_")
      pSelectedType = value(tChunks[tChunks.count])
      me.updateEventList()
  end case
end

on eventProcCreate me, tEvent, tElemID, tParam
  case tElemID of
    "roomevent.create.create":
      if me.createEvent() then
        me.Remove()
      end if
    "roomevent.cancel.icon", "roomevent.cancel.text":
      me.ChangeWindowView(#browse)
    "roomevent.close":
      me.Remove()
    "roomevent.create.name":
      tWnd = getWindow(pWindowID)
      tElem = tWnd.getElement(tElemID)
      if tElem.getText() = getText("roomevent_default_name") then
        tElem.setText(EMPTY)
      end if
    "roomevent.create.description":
      tWnd = getWindow(pWindowID)
      tElem = tWnd.getElement(tElemID)
      if tElem.getText() = getText("roomevent_default_desc") then
        tElem.setText(EMPTY)
      end if
  end case
end

on eventProcEdit me, tEvent, tElemID, tParam
  case tElemID of
    "roomevent.create.create":
      me.createEvent(#edit)
      me.Remove()
    "roomevent.cancel.icon", "roomevent.cancel.text", "roomevent.close":
      me.Remove()
  end case
end
