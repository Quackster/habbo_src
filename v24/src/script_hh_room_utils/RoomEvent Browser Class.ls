property pWindowID, pEditedEventData, pTypeCount, pView, pTypeTextKeyBody, pSelectedType, pEventListObj, pEventID, pDetailsWindowID

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
  return TRUE
end

on deconstruct me 
  me.hide()
  return TRUE
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
  if (tView = #browse) then
    tWnd.merge("roomevent_browser.window")
    tCreateButton = tWnd.getElement("roomevent.browser.create")
    tCreateButton.deactivate()
    me.askCreatePermission()
    tWnd.registerProcedure(#eventProcBrowse, me.getID(), #mouseWithin)
    tWnd.registerProcedure(#eventProcBrowse, me.getID(), #mouseUp)
    tWnd.registerProcedure(#eventProcBrowse, me.getID(), #mouseLeave)
    me.updateDropMenu()
    me.updateEventList()
  else
    if (tView = #create) then
      tWnd.merge("roomevent_create.window")
      tWnd.registerProcedure(#eventProcCreate, me.getID(), #mouseUp)
      me.updateDropMenu()
      tWnd.getElement("roomevent.create.name").setText(getText("roomevent_default_name"))
      tWnd.getElement("roomevent.create.description").setText(getText("roomevent_default_desc"))
    else
      if (tView = #edit) then
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
      end if
    end if
  end if
  activateWindow(pWindowID)
end

on askCreatePermission me 
  tConn = getConnection(getVariable("connection.info.id", #info))
  tConn.send("CAN_CREATE_ROOMEVENT")
end

on enableCreateButton me 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.browser.create") then
    return FALSE
  end if
  tWnd.getElement("roomevent.browser.create").Activate()
  return TRUE
end

on updateDropMenu me 
  pTypeCount = getThread(#room).getComponent().getRoomEventTypeCount()
  if (pTypeCount = 0) then
    return FALSE
  end if
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.type") then
    return FALSE
  end if
  tTextList = []
  tTextKeys = []
  if (pView = #browse) then
    tStartIndex = 0
  else
    tStartIndex = 1
  end if
  tIndex = tStartIndex
  repeat while tIndex <= pTypeCount
    tKey = pTypeTextKeyBody & tIndex
    tTextKeys.add(tKey)
    tTextList.add(getText(tKey))
    tIndex = (1 + tIndex)
  end repeat
  tWnd.getElement("roomevent.type").updateData(tTextList, tTextKeys, pSelectedType)
  return TRUE
end

on updateEventList me 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.browser.list") then
    return FALSE
  end if
  if not tWnd.elementExists("roomevent.type") then
    return FALSE
  end if
  tEventList = getThread(#room).getComponent().getRoomEventList(pSelectedType)
  pEventListObj.setEvents(tEventList)
  tListImage = pEventListObj.renderListImage()
  tListElem = tWnd.getElement("roomevent.browser.list")
  tListElem.feedImage(tListImage)
end

on updateDetailsBubble me, tpoint 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tEventData = pEventListObj.getEventAt(tpoint)
  if not tEventData then
    me.removeDetailsBubble()
    return TRUE
  end if
  tEventID = tEventData.getaProp(#flatId)
  if (tEventID = pEventID) then
    return TRUE
  end if
  pEventID = tEventID
  tEventRect = tEventData.getaProp(#rect)
  tWnd = getWindow(pWindowID)
  tListElem = tWnd.getElement("roomevent.browser.list")
  tListRect = tListElem.getProperty(#rect)
  tScrollElem = tWnd.getElement("roomevent.browser.scroll")
  tScrollOffset = tScrollElem.getScrollOffset()
  tLocY = (tListRect.getAt(2) - tScrollOffset)
  tLocX = tListRect.getAt(1)
  tTargetRect = (tEventRect + rect(tLocX, tLocY, tLocX, tLocY))
  if objectExists(pDetailsWindowID) then
    removeObject(pDetailsWindowID)
  end if
  tDetailsBubble = createObject(pDetailsWindowID, "Details Bubble Class")
  tDetailsBubble.createWithContent("roomevent_info.window", tTargetRect, #right)
  tDetailsWindow = tDetailsBubble.getWindowObj()
  tHost = getText("roomevent_host") && tEventData.getaProp(#hostName)
  tDetailsWindow.getElement("roomevent.info.host").setText(tHost)
  tText = "\"" & tEventData.getaProp(#desc) & "\""
  tDetailsWindow.getElement("roomevent.info.desc").setText(tText)
  tstart = getText("roomevent_starttime") && tEventData.getaProp(#time)
  tDetailsWindow.getElement("roomevent.info.time").setText(tstart)
end

on removeDetailsBubble me 
  if objectExists(pDetailsWindowID) then
    removeObject(pDetailsWindowID)
  end if
  pEventID = void()
end

on selectEvent me, tpoint 
  tEventData = pEventListObj.getEventAt(tpoint)
  if not tEventData then
    return FALSE
  end if
  tFlatID = tEventData.getaProp(#flatId)
  executeMessage(#roomForward, tFlatID, #private)
end

on createEvent me, tOperation 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.type") then
    return FALSE
  end if
  ttype = tWnd.getElement("roomevent.type").getSelection(#key)
  tChunks = explode(ttype, "_")
  tTypeID = value(tChunks.getAt(tChunks.count))
  tName = tWnd.getElement("roomevent.create.name").getText()
  tDesc = tWnd.getElement("roomevent.create.description").getText()
  tValid = 1
  if (tName = getText("roomevent_default_name")) or (tDesc = getText("roomevent_default_desc")) then
    tValid = 0
  end if
  tMinLength = 3
  if tName.length < tMinLength or tDesc.length < tMinLength then
    tValid = 0
  end if
  if not tValid then
    executeMessage(#alert, "roomevent_invalid_input")
    return FALSE
  end if
  tEvent = [#integer:tTypeID, #string:tName, #string:tDesc]
  tConn = getConnection(getVariable("connection.info.id", #info))
  if (tOperation = #edit) then
    tConn.send("EDIT_ROOMEVENT", tEvent)
  else
    tConn.send("CREATE_ROOMEVENT", tEvent)
  end if
  return TRUE
end

on eventProcBrowse me, tEvent, tElemID, tParam 
  if (tElemID = "roomevent.browser.list") then
    if (tEvent = #mouseWithin) then
      if tParam.ilk <> #point then
        return FALSE
      end if
      me.updateDetailsBubble(tParam)
    else
      if (tEvent = #mouseLeave) then
        me.removeDetailsBubble()
      else
        if (tEvent = #mouseUp) then
          me.selectEvent(tParam)
        end if
      end if
    end if
  end if
  if tEvent <> #mouseUp then
    return TRUE
  end if
  if (tEvent = "roomevent.browser.create") then
    me.ChangeWindowView(#create)
  else
    if (tEvent = "roomevent.close") then
      me.Remove()
    else
      if (tEvent = "roomevent.type") then
        tChunks = explode(tParam, "_")
        pSelectedType = value(tChunks.getAt(tChunks.count))
        me.updateEventList()
      end if
    end if
  end if
end

on eventProcCreate me, tEvent, tElemID, tParam 
  if (tElemID = "roomevent.create.create") then
    if me.createEvent() then
      me.Remove()
    end if
  else
    if tElemID <> "roomevent.cancel.icon" then
      if (tElemID = "roomevent.cancel.text") then
        me.ChangeWindowView(#browse)
      else
        if (tElemID = "roomevent.close") then
          me.Remove()
        else
          if (tElemID = "roomevent.create.name") then
            tWnd = getWindow(pWindowID)
            tElem = tWnd.getElement(tElemID)
            if (tElem.getText() = getText("roomevent_default_name")) then
              tElem.setText("")
            end if
          else
            if (tElemID = "roomevent.create.description") then
              tWnd = getWindow(pWindowID)
              tElem = tWnd.getElement(tElemID)
              if (tElem.getText() = getText("roomevent_default_desc")) then
                tElem.setText("")
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcEdit me, tEvent, tElemID, tParam 
  if (tElemID = "roomevent.create.create") then
    me.createEvent(#edit)
    me.Remove()
  else
    if tElemID <> "roomevent.cancel.icon" then
      if tElemID <> "roomevent.cancel.text" then
        if (tElemID = "roomevent.close") then
          me.Remove()
        end if
      end if
    end if
  end if
end
