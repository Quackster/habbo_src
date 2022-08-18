property pWndID, pObjList, pWriterObj, pListHeight

on construct me 
  pWndID = "Furniture Chooser."
  pObjMode = #user
  pObjList = [:]
  tMetrics = getStructVariable("struct.font.plain")
  tMetrics.setaProp(#lineHeight, 14)
  createWriter(me.getID() && "Writer", tMetrics)
  pWriterObj = getWriter(me.getID() && "Writer")
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
  return(me.update())
end

on deconstruct me 
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  pWriterObj = void()
  removeWriter(me.getID() && "Writer")
  pObjList = [:]
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#activeObjectRemoved, me.getID())
  return TRUE
end

on close me 
  return(removeObject(me.getID()))
end

on update me 
  if not threadExists(#room) then
    return(removeObject(me.getID()))
  end if
  if not windowExists(pWndID) then
    return(removeObject(me.getID()))
  end if
  pObjList = [:]
  pObjList.sort()
  tRoomComponent = getThread(#room).getComponent()
  if not objectp(tRoomComponent) then
    return([:])
  end if
  tActiveObjList = tRoomComponent.getActiveObject(#list)
  tItemObjList = tRoomComponent.getItemObject(#list)
  repeat while tActiveObjList <= 1
    tObj = getAt(1, count(tActiveObjList))
    pObjList.setaProp(tObj.getLocation() && tObj.getInfo().name, tObj.getID())
  end repeat
  repeat while tItemObjList <= 1
    tObj = getAt(1, count(tItemObjList))
    pObjList.setaProp(tObj.getLocation() && tObj.getInfo().name, tObj.getID())
  end repeat
  tObjStr = ""
  i = 1
  repeat while i <= pObjList.count
    tObjStr = tObjStr && pObjList.getPropAt(i) & "\r"
    i = (1 + i)
  end repeat
  tObjStr = tObjStr.getProp(#line, 1, (tObjStr.count(#line) - 1))
  tImg = pWriterObj.render(tObjStr)
  tElem = getWindow(pWndID).getElement("list")
  tElem.feedImage(tImg)
  pListHeight = tImg.height
  return TRUE
end

on clear me 
  pObjList = [:]
  pListHeight = 0
  getWindow(pWndID).getElement("list").feedImage(image(1, 1, 8))
  return TRUE
end

on eventProcChooser me, tEvent, tSprID, tParam 
  if (tSprID = "close") then
    return(removeObject(me.getID()))
  else
    if (tSprID = "list") then
      tCount = count(pObjList)
      if (tCount = 0) then
        return FALSE
      end if
      tLineNum = ((tParam.locV / (pListHeight / tCount)) + 1)
      if tLineNum < 1 then
        tLineNum = 1
      end if
      if tLineNum > tCount then
        tLineNum = tCount
      end if
      if not threadExists(#room) then
        return(removeObject(me.getID()))
      end if
      tObjID = pObjList.getAt(tLineNum)
      tRoomInt = getThread(#room).getInterface()
      if not tRoomInt then
        return FALSE
      end if
      tRoomComponent = getThread(#room).getComponent()
      if not tRoomComponent then
        return FALSE
      end if
      if not tRoomComponent.activeObjectExists(tObjID) then
        if not tRoomComponent.itemObjectExists(tObjID) then
          return FALSE
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
    end if
  end if
end
