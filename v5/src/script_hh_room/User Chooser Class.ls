property pWndID, pObjList, pWriterObj, pListHeight

on construct me 
  pWndID = "Chooser."
  pObjMode = #user
  pObjList = []
  tMetrics = getStructVariable("struct.font.plain")
  tMetrics.setaProp(#lineHeight, 14)
  createWriter(me.getID() && "Writer", tMetrics)
  pWriterObj = getWriter(me.getID() && "Writer")
  createWindow(pWndID, "habbo_system.window", 5, 345)
  tWndObj = getWindow(pWndID)
  tWndObj.merge("chooser.window")
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcChooser, me.getID(), #mouseUp)
  registerMessage(#leaveRoom, me.getID(), #clear)
  registerMessage(#changeRoom, me.getID(), #clear)
  registerMessage(#enterRoom, me.getID(), #update)
  registerMessage(#create_user, me.getID(), #update)
  registerMessage(#remove_user, me.getID(), #update)
  return(me.update())
end

on deconstruct me 
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  pWriterObj = void()
  removeWriter(me.getID() && "Writer")
  pObjList = []
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#remove_user, me.getID())
  return TRUE
end

on setMode me, tMode 
  if (tMode = #user) then
    pObjMode = #user
  else
    if (tMode = #Active) then
      pObjMode = #Active
    else
      if (tMode = #item) then
        pObjMode = #item
      else
        return(error(me, "Unsupported obj type:" && tMode, #setMode))
      end if
    end if
  end if
  return(me.update())
end

on update me 
  if not threadExists(#room) then
    return(removeObject(me.getID()))
  end if
  if not windowExists(pWndID) then
    return(removeObject(me.getID()))
  end if
  pObjList = []
  pObjList.sort()
  tObjList = getThread(#room).getComponent().getUserObject(#list)
  repeat while tObjList <= undefined
    tObj = getAt(undefined, undefined)
    pObjList.add(tObj.getID())
  end repeat
  tObjStr = ""
  repeat while tObjList <= undefined
    tName = getAt(undefined, undefined)
    tObjStr = tObjStr && tName & "\r"
  end repeat
  tObjStr = tObjStr.getProp(#line, 1, (tObjStr.count(#line) - 1))
  tImg = pWriterObj.render(tObjStr)
  tElem = getWindow(pWndID).getElement("list")
  tElem.feedImage(tImg)
  pListHeight = tImg.height
  return TRUE
end

on clear me 
  pObjList = []
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
      getThread(#room).getInterface().eventProcUserObj(#mouseUp, tObjID)
      getThread(#room).getInterface().getArrowHiliter().show(tObjID, 1)
    end if
  end if
end
