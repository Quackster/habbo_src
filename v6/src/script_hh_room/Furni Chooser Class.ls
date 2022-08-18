property pWndID, pObjList, pWriterObj, pListHeight

on construct me
  pWndID = "Furniture Chooser."
  pObjMode = #user
  pObjList = [:]
  tMetrics = getStructVariable("struct.font.plain")
  tMetrics.setaProp(#lineHeight, 14)
  createWriter((me.getID() && "Writer"), tMetrics)
  pWriterObj = getWriter((me.getID() && "Writer"))
  createWindow(pWndID, "habbo_system.window", 5, 315)
  tWndObj = getWindow(pWndID)
  tWndObj.merge("chooser.window")
  tWndObj.resizeTo(250, 170)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcChooser, me.getID(), #mouseUp)
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  registerMessage(#enterRoom, me.getID(), #update)
  registerMessage(#activeObjectRemoved, me.getID(), #update)
  return me.update()
end

on deconstruct me
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  pWriterObj = VOID
  removeWriter((me.getID() && "Writer"))
  pObjList = [:]
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#activeObjectRemoved, me.getID())
  return 1
end

on close me
  return removeObject(me.getID())
end

on update me
  if not threadExists(#room) then
    return removeObject(me.getID())
  end if
  if not windowExists(pWndID) then
    return removeObject(me.getID())
  end if
  pObjList = [:]
  pObjList.sort()
  tRoomComponent = getThread(#room).getComponent()
  if not objectp(tRoomComponent) then
    return [:]
  end if
  tActiveObjList = tRoomComponent.getActiveObject(#list)
  tItemObjList = tRoomComponent.getItemObject(#list)
  repeat with tObj in tActiveObjList
    pObjList.setaProp((tObj.getLocation() && tObj.getInfo().name), tObj.getID())
  end repeat
  repeat with tObj in tItemObjList
    pObjList.setaProp((tObj.getLocation() && tObj.getInfo().name), tObj.getID())
  end repeat
  tObjStr = EMPTY
  repeat with i = 1 to pObjList.count
    tObjStr = ((tObjStr && pObjList.getPropAt(i)) & RETURN)
  end repeat
  tObjStr = tObjStr.line[1]
  tImg = pWriterObj.render(tObjStr)
  tElem = getWindow(pWndID).getElement("list")
  tElem.feedImage(tImg)
  pListHeight = tImg.height
  return 1
end

on clear me
  pObjList = [:]
  pListHeight = 0
  getWindow(pWndID).getElement("list").feedImage(image(1, 1, 8))
  return 1
end

on eventProcChooser me, tEvent, tSprID, tParam
  case tSprID of
    "close":
      return removeObject(me.getID())
    "list":
      tCount = count(pObjList)
      if (tCount = 0) then
        return 0
      end if
      tLineNum = ((tParam.locV / (pListHeight / tCount)) + 1)
      if (tLineNum < 1) then
        tLineNum = 1
      end if
      if (tLineNum > tCount) then
        tLineNum = tCount
      end if
      if not threadExists(#room) then
        return removeObject(me.getID())
      end if
      tObjID = pObjList[tLineNum]
      tRoomInt = getThread(#room).getInterface()
      if not tRoomInt then
        return 0
      end if
      tRoomComponent = getThread(#room).getComponent()
      if not tRoomComponent then
        return 0
      end if
      if not tRoomComponent.activeObjectExists(tObjID) then
        if not tRoomComponent.itemObjectExists(tObjID) then
          return 0
        else
          ttype = "item"
        end if
      else
        ttype = "active"
      end if
      tRoomInt.pSelectedObj = tObjID
      tRoomInt.pSelectedType = ttype
      tRoomInt.showObjectInfo(ttype)
      tRoomInt.showInterface(ttype)
      tRoomInt.hideArrowHiliter()
  end case
end
