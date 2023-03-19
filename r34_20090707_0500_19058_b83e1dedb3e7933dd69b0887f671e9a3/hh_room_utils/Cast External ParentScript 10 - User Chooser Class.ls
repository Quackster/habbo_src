property pWndID, pObjList, pObjMode, pWriterObj, pListHeight

on construct me
  pWndID = "Chooser."
  pObjMode = #user
  pObjList = [:]
  tMetrics = getStructVariable("struct.font.plain")
  tMetrics.setaProp(#lineHeight, 14)
  createWriter(me.getID() && "Writer", tMetrics)
  pWriterObj = getWriter(me.getID() && "Writer")
  if not createWindow(pWndID, "habbo_system.window", 5, 345) then
    return 0
  end if
  tWndObj = getWindow(pWndID)
  if not tWndObj.merge("chooser.window") then
    return tWndObj.close()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcChooser, me.getID(), #mouseUp)
  registerMessage(#leaveRoom, me.getID(), #clear)
  registerMessage(#changeRoom, me.getID(), #clear)
  registerMessage(#enterRoom, me.getID(), #update)
  registerMessage(#create_user, me.getID(), #update)
  registerMessage(#remove_user, me.getID(), #update)
  return me.update()
end

on deconstruct me
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  pWriterObj = VOID
  removeWriter(me.getID() && "Writer")
  pObjList = [:]
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#remove_user, me.getID())
  return 1
end

on setMode me, tMode
  case tMode of
    #user:
      pObjMode = #user
    #Active:
      pObjMode = #Active
    #item:
      pObjMode = #item
    otherwise:
      return error(me, "Unsupported obj type:" && tMode, #setMode, #minor)
  end case
  return me.update()
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
  tObjList = getThread(#room).getComponent().getUserObject(#list)
  repeat with tObj in tObjList
    pObjList.setaProp(convertToLowerCase(tObj.getName()), [#id: tObj.getID(), #name: tObj.getName()])
  end repeat
  tObjStr = EMPTY
  repeat with i = 1 to pObjList.count
    tObjStr = tObjStr && pObjList[i].getaProp(#name) & RETURN
  end repeat
  delete char -30003 of tObjStr
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
      if tCount = 0 then
        return 0
      end if
      tLineNum = (tParam.locV / (pListHeight / tCount)) + 1
      if tLineNum < 1 then
        tLineNum = 1
      end if
      if tLineNum > tCount then
        tLineNum = tCount
      end if
      if not threadExists(#room) then
        return removeObject(me.getID())
      end if
      tObjID = pObjList[tLineNum].getaProp(#id)
      getThread(#room).getInterface().eventProcUserObj(#mouseUp, tObjID)
      getThread(#room).getInterface().getArrowHiliter().show(tObjID, 1)
  end case
end
