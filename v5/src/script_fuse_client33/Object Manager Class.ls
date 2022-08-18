property pObjectList, pUpdateList, pTimeOut, pInstanceList, pManagerList, pBaseClsMem, pPrepareList, pEraseLock, pUpdatePause

on construct me 
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  pManagerList = []
  pInstanceList = []
  pEraseLock = 0
  pTimeOut = void()
  pUpdatePause = 0
  pBaseClsMem = script("Object Base Class")
  pObjectList.sort()
  pUpdateList.sort()
  return TRUE
end

on deconstruct me 
  pEraseLock = 1
  if objectp(pTimeOut) then
    pTimeOut.forget()
    pTimeOut = void()
  end if
  i = pInstanceList.count
  repeat while i >= 1
    me.remove(pInstanceList.getAt(i))
    i = (255 + i)
  end repeat
  i = pManagerList.count
  repeat while i >= 1
    me.remove(pManagerList.getAt(i))
    i = (255 + i)
  end repeat
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  return TRUE
end

on create me, tid, tClassList 
  if not symbolp(tid) and not stringp(tid) then
    return(error(me, "Symbol or string expected:" && tid, #create))
  end if
  if objectp(pObjectList.getAt(tid)) then
    return(error(me, "Object already exists:" && tid, #create))
  end if
  if (tid = #random) then
    tid = getUniqueID()
  end if
  if voidp(tClassList) then
    return(error(me, "Class member name expected!", #create))
  end if
  if not listp(tClassList) then
    tClassList = [tClassList]
  end if
  tClassList = tClassList.duplicate()
  tObject = void()
  tTemp = void()
  tBase = pBaseClsMem.new()
  tBase.construct()
  if tid <> #temp then
    tBase.id = tid
    pObjectList.setAt(tid, tBase)
  end if
  tClassList.addAt(1, tBase)
  repeat while tClassList <= tClassList
    tClass = getAt(tClassList, tid)
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      if me.managerExists(#resource_manager) then
        tMemNum = me.getManager(#resource_manager).getmemnum(tClass)
      else
        tMemNum = member(tClass).number
      end if
      if tMemNum < 1 then
        if tid <> #temp then
          pObjectList.deleteProp(tid)
        end if
        return(error(me, "Script not found:" && tMemNum, #create))
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    if ilk(tObject, #instance) then
      tObject.setAt(#ancestor, tTemp)
      tTemp = tObject
    end if
    if tid <> #temp and (tClassList.getLast() = tClass) then
      pObjectList.setAt(tid, tObject)
      pInstanceList.append(tid)
    end if
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return(tObject)
end

on get me, tid 
  tObj = pObjectList.getAt(tid)
  if voidp(tObj) then
    return FALSE
  else
    return(tObj)
  end if
end

on remove me, tid 
  tObj = pObjectList.getAt(tid)
  if voidp(tObj) then
    return FALSE
  end if
  if ilk(tObj, #instance) then
    if not tObj.valid then
      return FALSE
    end if
    i = 1
    repeat while i <= tObj.count(#delays)
      tDelayID = tObj.delays.getPropAt(i)
      tObj.cancel(tDelayID)
      i = (1 + i)
    end repeat
    tObj.deconstruct()
    tObj.valid = 0
  end if
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  tObj = void()
  if not pEraseLock then
    pObjectList.deleteProp(tid)
    pInstanceList.deleteOne(tid)
    pManagerList.deleteOne(tid)
  end if
  return TRUE
end

on exists me, tid 
  if voidp(tid) then
    return FALSE
  end if
  return(objectp(pObjectList.getAt(tid)))
end

on print me 
  i = 1
  repeat while i <= pObjectList.count
    tProp = pObjectList.getPropAt(i)
    if symbolp(tProp) then
      tProp = "#" & tProp
    end if
    put(tProp && ":" && pObjectList.getAt(i))
    i = (1 + i)
  end repeat
  return TRUE
end

on registerObject me, tid, tObject 
  if not objectp(tObject) then
    return(error(me, "Invalid object:" && tObject, #register))
  end if
  if not voidp(pObjectList.getAt(tid)) then
    return(error(me, "Object already exists:" && tid, #register))
  end if
  pObjectList.setAt(tid, tObject)
  pInstanceList.append(tid)
  return TRUE
end

on unregisterObject me, tid 
  if voidp(pObjectList.getAt(tid)) then
    return(error(me, "Referred object not found:" && tid, #unregister))
  end if
  tObj = pObjectList.getAt(tid)
  pObjectList.deleteProp(tid)
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  pInstanceList.deleteOne(tid)
  tObj = void()
  return TRUE
end

on registerManager me, tid 
  if not me.exists(tid) then
    return(error(me, "Referred object not found:" && tid, #registerManager))
  end if
  if pManagerList.getOne(tid) <> 0 then
    return(error(me, "Manager alreay registered:" && tid, #registerManager))
  end if
  pInstanceList.deleteOne(tid)
  pManagerList.append(tid)
  return TRUE
end

on unregisterManager me, tid 
  if not me.exists(tid) then
    return(error(me, "Referred object not found:" && tid, #unregisterManager))
  end if
  if pInstanceList.getOne(tid) <> 0 then
    return(error(me, "Manager already unregistered:" && tid, #unregisterManager))
  end if
  pManagerList.deleteOne(tid)
  pInstanceList.append(tid)
  return TRUE
end

on getManager me, tid 
  if not pManagerList.getOne(tid) then
    return(error(me, "Manager not found:" && tid, #getManager))
  end if
  return(pObjectList.getAt(tid))
end

on managerExists me, tid 
  return(pManagerList.getOne(tid) <> 0)
end

on receivePrepare me, tid 
  if voidp(pObjectList.getAt(tid)) then
    return FALSE
  end if
  if pPrepareList.getPos(pObjectList.getAt(tid)) > 0 then
    return FALSE
  end if
  pPrepareList.add(pObjectList.getAt(tid))
  if not pUpdatePause then
    if voidp(pTimeOut) then
      pTimeOut = timeout("objectmanager" & the milliSeconds).new(((60 * 1000) * 60), #null, me)
    end if
  end if
  return TRUE
end

on removePrepare me, tid 
  if voidp(pObjectList.getAt(tid)) then
    return FALSE
  end if
  if pPrepareList.getOne(pObjectList.getAt(tid)) < 1 then
    return FALSE
  end if
  pPrepareList.deleteOne(pObjectList.getAt(tid))
  if (pPrepareList.count = 0) and (pUpdateList.count = 0) then
    if objectp(pTimeOut) then
      pTimeOut.forget()
      pTimeOut = void()
    end if
  end if
  return TRUE
end

on receiveUpdate me, tid 
  if voidp(pObjectList.getAt(tid)) then
    return FALSE
  end if
  if pUpdateList.getPos(pObjectList.getAt(tid)) > 0 then
    return FALSE
  end if
  pUpdateList.add(pObjectList.getAt(tid))
  if not pUpdatePause then
    if voidp(pTimeOut) then
      pTimeOut = timeout("objectmanager" & the milliSeconds).new(((60 * 1000) * 60), #null, me)
    end if
  end if
  return TRUE
end

on removeUpdate me, tid 
  if voidp(pObjectList.getAt(tid)) then
    return FALSE
  end if
  if pUpdateList.getOne(pObjectList.getAt(tid)) < 1 then
    return FALSE
  end if
  pUpdateList.deleteOne(pObjectList.getAt(tid))
  if (pPrepareList.count = 0) and (pUpdateList.count = 0) then
    if objectp(pTimeOut) then
      pTimeOut.forget()
      pTimeOut = void()
    end if
  end if
  return TRUE
end

on pauseUpdate me 
  if objectp(pTimeOut) then
    pTimeOut.forget()
    pTimeOut = void()
  end if
  pUpdatePause = 1
  return TRUE
end

on resumeUpdate me 
  if pUpdateList.count > 0 and voidp(pTimeOut) then
    pTimeOut = timeout("objectmanager" & the milliSeconds).new(((60 * 1000) * 60), #null, me)
  end if
  pUpdatePause = 0
  return TRUE
end

on prepareFrame me 
  call(#prepare, pPrepareList)
  call(#update, pUpdateList)
end

on null me 
end
