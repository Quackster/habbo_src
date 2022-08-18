property pObjectList, pUpdateList, pPrepareList, pManagerList, pInstanceList, pEraseLock, pTimeout, pUpdatePause, pBaseClsMem, pDontProfile

on construct me
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  pManagerList = []
  pInstanceList = []
  pEraseLock = 0
  pTimeout = VOID
  pUpdatePause = 0
  pBaseClsMem = script("Object Base Class")
  pDontProfile = 1
  pObjectList.sort()
  pUpdateList.sort()
  return 1
end

on deconstruct me
  pEraseLock = 1
  if objectp(pTimeout) then
    pTimeout.forget()
    pTimeout = VOID
  end if
  repeat with i = pInstanceList.count down to 1
    me.Remove(pInstanceList[i])
  end repeat
  repeat with i = pManagerList.count down to 1
    me.Remove(pManagerList[i])
  end repeat
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  return 1
end

on create me, tID, tClassList
  if (not symbolp(tID) and not stringp(tID)) then
    return error(me, ("Symbol or string expected:" && tID), #create, #major)
  end if
  if objectp(pObjectList.getaProp(tID)) then
    return error(me, ("Object already exists:" && tID), #create, #major)
  end if
  if (tID = #random) then
    tID = getUniqueID()
  end if
  if voidp(tClassList) then
    return error(me, "Class member name expected!", #create, #major)
  end if
  if not listp(tClassList) then
    tClassList = [tClassList]
  end if
  tClassList = tClassList.duplicate()
  tObject = VOID
  tTemp = VOID
  tBase = pBaseClsMem.new()
  tBase.construct()
  if (tID <> #temp) then
    tBase.id = tID
    pObjectList[tID] = tBase
  end if
  tClassList.addAt(1, tBase)
  repeat with tClass in tClassList
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      if me.managerExists(#resource_manager) then
        tMemNum = me.getManager(#resource_manager).getmemnum(tClass)
      else
        tMemNum = member(tClass).number
      end if
      if (tMemNum < 1) then
        if (tID <> #temp) then
          pObjectList.deleteProp(tID)
        end if
        return error(me, ("Script not found:" && tMemNum), #create, #major)
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    if ilk(tObject, #instance) then
      tObject[#ancestor] = tTemp
      tTemp = tObject
    end if
    if ((tID <> #temp) and (tClassList.getLast() = tClass)) then
      pObjectList[tID] = tObject
      pInstanceList.append(tID)
    end if
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return tObject
end

on GET me, tID
  tObj = pObjectList.getaProp(tID)
  if voidp(tObj) then
    return 0
  else
    return tObj
  end if
end

on Remove me, tID
  tObj = pObjectList.getaProp(tID)
  if voidp(tObj) then
    return 0
  end if
  if ilk(tObj, #instance) then
    if not tObj.valid then
      return 0
    end if
    repeat with i = 1 to tObj.delays.count
      tDelayID = tObj.delays.getPropAt(i)
      tObj.Cancel(tDelayID)
    end repeat
    tObj.deconstruct()
    tObj.valid = 0
  end if
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  tObj = VOID
  if not pEraseLock then
    pObjectList.deleteProp(tID)
    pInstanceList.deleteOne(tID)
    pManagerList.deleteOne(tID)
  end if
  return 1
end

on exists me, tID
  if voidp(tID) then
    return 0
  end if
  return objectp(pObjectList.getaProp(tID))
end

on print me
  repeat with i = 1 to pObjectList.count
    tProp = pObjectList.getPropAt(i)
    if symbolp(tProp) then
      tProp = ("#" & tProp)
    end if
    put ((tProp && ":") && pObjectList[i])
  end repeat
  return 1
end

on registerObject me, tID, tObject
  if not objectp(tObject) then
    return error(me, ("Invalid object:" && tObject), #register, #major)
  end if
  if not voidp(pObjectList.getaProp(tID)) then
    return error(me, ("Object already exists:" && tID), #register, #minor)
  end if
  setaProp(pObjectList, tID, tObject)
  pInstanceList.append(tID)
  return 1
end

on unregisterObject me, tID
  if voidp(pObjectList.getaProp(tID)) then
    return error(me, ("Referred object not found:" && tID), #unregister, #minor)
  end if
  tObj = pObjectList.getaProp(tID)
  pObjectList.deleteProp(tID)
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  pInstanceList.deleteOne(tID)
  tObj = VOID
  return 1
end

on registerManager me, tID
  if not me.exists(tID) then
    return error(me, ("Referred object not found:" && tID), #registerManager, #major)
  end if
  if (pManagerList.getOne(tID) <> 0) then
    return error(me, ("Manager already registered:" && tID), #registerManager, #minor)
  end if
  pInstanceList.deleteOne(tID)
  pManagerList.append(tID)
  return 1
end

on unregisterManager me, tID
  if not me.exists(tID) then
    return error(me, ("Referred object not found:" && tID), #unregisterManager, #minor)
  end if
  if (pInstanceList.getOne(tID) <> 0) then
    return error(me, ("Manager already unregistered:" && tID), #unregisterManager, #minor)
  end if
  pManagerList.deleteOne(tID)
  pInstanceList.append(tID)
  return 1
end

on getManager me, tID
  if not pManagerList.getOne(tID) then
    return error(me, ("Manager not found:" && tID), #getManager, #major)
  end if
  return pObjectList.getaProp(tID)
end

on managerExists me, tID
  return (pManagerList.getOne(tID) <> 0)
end

on receivePrepare me, tID
  if voidp(pObjectList.getaProp(tID)) then
    return 0
  end if
  if (pPrepareList.getPos(pObjectList.getaProp(tID)) > 0) then
    return 0
  end if
  pPrepareList.add(pObjectList.getaProp(tID))
  if not pUpdatePause then
    if voidp(pTimeout) then
      pTimeout = timeout(("objectmanager" & the milliSeconds)).new(((60 * 1000) * 60), #null, me)
    end if
  end if
  return 1
end

on removePrepare me, tID
  if voidp(pObjectList.getaProp(tID)) then
    return 0
  end if
  if (pPrepareList.getOne(pObjectList.getaProp(tID)) < 1) then
    return 0
  end if
  pPrepareList.deleteOne(pObjectList.getaProp(tID))
  if ((pPrepareList.count = 0) and (pUpdateList.count = 0)) then
    if objectp(pTimeout) then
      pTimeout.forget()
      pTimeout = VOID
    end if
  end if
  return 1
end

on receiveUpdate me, tID
  if voidp(pObjectList.getaProp(tID)) then
    return 0
  end if
  if (pUpdateList.getPos(pObjectList.getaProp(tID)) > 0) then
    return 0
  end if
  pUpdateList.add(pObjectList.getaProp(tID))
  if not pUpdatePause then
    if voidp(pTimeout) then
      pTimeout = timeout(("objectmanager" & the milliSeconds)).new(((60 * 1000) * 60), #null, me)
    end if
  end if
  return 1
end

on removeUpdate me, tID
  if voidp(pObjectList.getaProp(tID)) then
    return 0
  end if
  if (pUpdateList.getOne(pObjectList.getaProp(tID)) < 1) then
    return 0
  end if
  pUpdateList.deleteOne(pObjectList.getaProp(tID))
  if ((pPrepareList.count = 0) and (pUpdateList.count = 0)) then
    if objectp(pTimeout) then
      pTimeout.forget()
      pTimeout = VOID
    end if
  end if
  return 1
end

on pauseUpdate me
  if objectp(pTimeout) then
    pTimeout.forget()
    pTimeout = VOID
  end if
  pUpdatePause = 1
  return 1
end

on resumeUpdate me
  if ((pUpdateList.count > 0) and voidp(pTimeout)) then
    pTimeout = timeout(("objectmanager" & the milliSeconds)).new(((60 * 1000) * 60), #null, me)
  end if
  pUpdatePause = 0
  return 1
end

on prepareFrame me
  if (pDontProfile and getObjectManager().managerExists(#variable_manager)) then
    if variableExists("profile.core.enabled") then
      pDontProfile = 0
    end if
  end if
  if not pDontProfile then
    startProfilingTask("Object Manager::prepareFrame")
  end if
  the traceScript = 0
  if (the activeWindow.name <> "stage") then
    return stopMovie()
  end if
  if pDontProfile then
    call(#prepare, pPrepareList)
    call(#update, pUpdateList)
  else
    repeat with i = 1 to pPrepareList.count
      tTask = pPrepareList[i]
      tTaskName = ("Prepare " & string(tTask))
      startProfilingTask(tTaskName)
      call(#prepare, [tTask])
      finishProfilingTask(tTaskName)
    end repeat
    repeat with i = 1 to pUpdateList.count
      tTask = pUpdateList[i]
      tTaskName = ("Update " & string(tTask))
      startProfilingTask(tTaskName)
      call(#update, [tTask])
      finishProfilingTask(tTaskName)
    end repeat
  end if
  if not pDontProfile then
    finishProfilingTask("Object Manager::prepareFrame")
  end if
end

on null me
end

on handlers
  return []
end
