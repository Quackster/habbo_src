on construct(me)
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
  return(1)
  exit
end

on deconstruct(me)
  me.hide()
  return(1)
  exit
end

on hide(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  me.removeDetailsBubble()
  exit
end

on Remove(me)
  removeObject(me.getID())
  exit
end

on editEvent(me, tEventData)
  pEditedEventData = tEventData
  me.ChangeWindowView(#edit)
  exit
end

on ChangeWindowView(me, tView)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  createWindow(pWindowID, "habbo_basic_red.window")
  tWnd = getWindow(pWindowID)
  pView = tView
  if me = #browse then
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
    if me = #create then
      tWnd.merge("roomevent_create.window")
      tWnd.registerProcedure(#eventProcCreate, me.getID(), #mouseUp)
      me.updateDropMenu()
      tWnd.getElement("roomevent.create.name").setText(getText("roomevent_default_name"))
      tWnd.getElement("roomevent.create.description").setText(getText("roomevent_default_desc"))
    else
      if me = #edit then
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
  activateWindowObj(pWindowID)
  exit
end

on askCreatePermission(me)
  tConn = getConnection(getVariable("connection.info.id", #info))
  tConn.send("CAN_CREATE_ROOMEVENT")
  exit
end

on enableCreateButton(me)
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.browser.create") then
    return(0)
  end if
  tWnd.getElement("roomevent.browser.create").Activate()
  return(1)
  exit
end

on updateDropMenu(me)
  pTypeCount = getThread(#room).getComponent().getRoomEventTypeCount()
  if pTypeCount = 0 then
    return(0)
  end if
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.type") then
    return(0)
  end if
  tTextList = []
  tTextKeys = []
  if pView = #browse then
    tStartIndex = 0
  else
    tStartIndex = 1
  end if
  tIndex = tStartIndex
  repeat while tIndex <= pTypeCount
    tKey = pTypeTextKeyBody & tIndex
    tTextKeys.add(tKey)
    tTextList.add(getText(tKey))
    tIndex = 1 + tIndex
  end repeat
  tWnd.getElement("roomevent.type").updateData(tTextList, tTextKeys, pSelectedType)
  return(1)
  exit
end

on updateEventList(me)
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.browser.list") then
    return(0)
  end if
  if not tWnd.elementExists("roomevent.type") then
    return(0)
  end if
  tEventList = getThread(#room).getComponent().getRoomEventList(pSelectedType)
  pEventListObj.setEvents(tEventList)
  tListImage = pEventListObj.renderListImage()
  if tListImage.ilk <> #image then
    return(0)
  end if
  tListElem = tWnd.getElement("roomevent.browser.list")
  tListElem.feedImage(tListImage)
  exit
end

on updateDetailsBubble(me, tpoint)
  if not windowExists(pWindowID) then
    return(0)
  end if
  tEventData = pEventListObj.getEventAt(tpoint)
  if not tEventData then
    me.removeDetailsBubble()
    return(1)
  end if
  tEventID = tEventData.getaProp(#flatId)
  if tEventID = pEventID then
    return(1)
  end if
  pEventID = tEventID
  tEventRect = tEventData.getaProp(#rect)
  tWnd = getWindow(pWindowID)
  tListElem = tWnd.getElement("roomevent.browser.list")
  if not objectp(tListElem) then
    return(0)
  end if
  tListRect = tListElem.getProperty(#rect)
  tScrollElem = tWnd.getElement("roomevent.browser.scroll")
  if not objectp(tScrollElem) then
    return(0)
  end if
  tScrollOffset = tScrollElem.getScrollOffset()
  tLocY = tListRect.getAt(2) - tScrollOffset
  tLocX = tListRect.getAt(1)
  tTargetRect = tEventRect + rect(tLocX, tLocY, tLocX, tLocY)
  if objectExists(pDetailsWindowID) then
    removeObject(pDetailsWindowID)
  end if
  tDetailsBubble = createObject(pDetailsWindowID, "Details Bubble Class")
  tDetailsBubble.createWithContent("roomevent_info.window", tTargetRect, #right)
  tDetailsWindow = tDetailsBubble.getWindowObj()
  if not objectp(tDetailsWindow) then
    return(error(me, "Failed to create event details bubble window", #updateDetailsBubble, #minor))
  end if
  tHost = getText("roomevent_host") && tEventData.getaProp(#hostName)
  tDetailsWindow.getElement("roomevent.info.host").setText(tHost)
  tText = "\"" & tEventData.getaProp(#desc) & "\""
  tDetailsWindow.getElement("roomevent.info.desc").setText(tText)
  tstart = getText("roomevent_starttime") && tEventData.getaProp(#time)
  tDetailsWindow.getElement("roomevent.info.time").setText(tstart)
  exit
end

on removeDetailsBubble(me)
  if objectExists(pDetailsWindowID) then
    removeObject(pDetailsWindowID)
  end if
  pEventID = void()
  exit
end

on selectEvent(me, tpoint)
  tEventData = pEventListObj.getEventAt(tpoint)
  if not tEventData then
    return(0)
  end if
  tFlatID = tEventData.getaProp(#flatId)
  executeMessage(#roomForward, tFlatID, #private)
  exit
end

on createEvent(me, tOperation)
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("roomevent.type") then
    return(0)
  end if
  ttype = tWnd.getElement("roomevent.type").getSelection(#key)
  tChunks = explode(ttype, "_")
  tTypeID = value(tChunks.getAt(tChunks.count))
  tName = tWnd.getElement("roomevent.create.name").getText()
  tDesc = tWnd.getElement("roomevent.create.description").getText()
  tValid = 1
  if tName = getText("roomevent_default_name") or tDesc = getText("roomevent_default_desc") then
    tValid = 0
  end if
  tMinLength = 3
  if tName.length < tMinLength or tDesc.length < tMinLength then
    tValid = 0
  end if
  if not tValid then
    executeMessage(#alert, "roomevent_invalid_input")
    return(0)
  end if
  tEvent = [#integer:tTypeID, #string:tName, #string:tDesc]
  tConn = getConnection(getVariable("connection.info.id", #info))
  if tOperation = #edit then
    tConn.send("EDIT_ROOMEVENT", tEvent)
  else
    tConn.send("CREATE_ROOMEVENT", tEvent)
  end if
  return(1)
  exit
end

on eventProcBrowse(me, tEvent, tElemID, tParam)
  if tElemID = "roomevent.browser.list" then
    if me = #mouseWithin then
      if tParam.ilk <> #point then
        return(0)
      end if
      me.updateDetailsBubble(tParam)
    else
      if me = #mouseLeave then
        me.removeDetailsBubble()
      else
        if me = #mouseUp then
          me.selectEvent(tParam)
        end if
      end if
    end if
  end if
  if tEvent <> #mouseUp then
    return(1)
  end if
  if me = "roomevent.browser.create" then
    me.ChangeWindowView(#create)
  else
    if me = "roomevent.close" then
      me.Remove()
    else
      if me = "roomevent.type" then
        tChunks = explode(tParam, "_")
        pSelectedType = value(tChunks.getAt(tChunks.count))
        me.updateEventList()
      end if
    end if
  end if
  exit
end

on eventProcCreate(me, tEvent, tElemID, tParam)
  if me = "roomevent.create.create" then
    if me.createEvent() then
      me.Remove()
    end if
  else
    if me <> "roomevent.cancel.icon" then
      if me = "roomevent.cancel.text" then
        me.ChangeWindowView(#browse)
      else
        if me = "roomevent.close" then
          me.Remove()
        else
          if me = "roomevent.create.name" then
            tWnd = getWindow(pWindowID)
            tElem = tWnd.getElement(tElemID)
            if tElem.getText() = getText("roomevent_default_name") then
              tElem.setText("")
            end if
          else
            if me = "roomevent.create.description" then
              tWnd = getWindow(pWindowID)
              tElem = tWnd.getElement(tElemID)
              if tElem.getText() = getText("roomevent_default_desc") then
                tElem.setText("")
              end if
            end if
          end if
        end if
      end if
      exit
    end if
  end if
end

on eventProcEdit(me, tEvent, tElemID, tParam)
  if me = "roomevent.create.create" then
    me.createEvent(#edit)
    me.Remove()
  else
    if me <> "roomevent.cancel.icon" then
      if me <> "roomevent.cancel.text" then
        if me = "roomevent.close" then
          me.Remove()
        end if
        exit
      end if
    end if
  end if
end