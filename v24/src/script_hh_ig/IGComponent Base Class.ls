property pFeederList, pIGComponentId, pActiveFlag, pMainThreadId, pListenerList, pTimeoutUpdates, pHiddenUpdates, pUpdateInterval

on construct me 
  pActiveFlag = 0
  pTimeoutUpdates = 0
  pHiddenUpdates = 0
  pUpdateLastTimestamp = 0
  pUpdateInterval = 10000
  pFeederList = []
  pListenerList = []
  return TRUE
end

on deconstruct me 
  me.setContentUpdatePollingTimeout(0)
  me.setActiveFlag(0)
  pListenerList = []
  repeat while pFeederList <= undefined
    tServiceId = getAt(undefined, undefined)
    tService = me.getIGComponent(tServiceId)
    if tService <> 0 then
      tService.unregisterUpdates(pIGComponentId)
    end if
  end repeat
  pFeederList = []
  if objectExists(me.getRendererID()) then
    removeObject(me.getRendererID())
  end if
  return TRUE
end

on Initialize me 
  return TRUE
end

on setActiveFlag me, tstate, tHoldUpdates 
  pActiveFlag = tstate
  if not me.pHiddenUpdates then
    if not tHoldUpdates then
      me.setContentUpdatePollingTimeout(tstate)
    else
      me.setContentUpdatePollingTimeout(0)
    end if
  end if
  if (tstate = 1) then
    receiveUpdate(me.getID())
  else
    removeUpdate(me.getID())
    me.discardRenderer()
  end if
  return TRUE
end

on getActiveFlag me 
  return(pActiveFlag)
end

on update me 
  return TRUE
end

on displayEvent me, ttype, tParam 
  tRenderObj = me.getRenderer(1)
  if tRenderObj <> 0 then
    return(tRenderObj.displayEvent(ttype, tParam))
  end if
  return FALSE
end

on Remove me 
  me.getComponent().removeIGComponent(pIGComponentId)
end

on getMainThread me 
  return(getObject(pMainThreadId))
end

on getHandler me 
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return FALSE
  end if
  return(tMainThreadRef.getHandler())
end

on getComponent me 
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return FALSE
  end if
  return(tMainThreadRef.getComponent())
end

on getInterface me 
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return FALSE
  end if
  return(tMainThreadRef.getInterface())
end

on ChangeWindowView me, tMode 
  tInterface = me.getInterface()
  if (tInterface = 0) then
    return FALSE
  end if
  return(tInterface.ChangeWindowView(tMode))
end

on renderUI me, tComponentSpec 
  tRenderObj = getObject(me.getRendererID())
  if (tRenderObj = 0) then
    return TRUE
  end if
  return(tRenderObj.renderUI(tComponentSpec))
end

on resetSubComponent me, tID 
  tRenderObj = getObject(me.getRendererID())
  if (tRenderObj = 0) then
    return TRUE
  end if
  return(tRenderObj.resetSubComponent(tID))
end

on getIGComponent me, tServiceId 
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return FALSE
  end if
  return(tMainThreadRef.getIGComponent(tServiceId))
end

on registerForIGComponentUpdates me, tServiceId 
  tService = me.getIGComponent(tServiceId)
  if (tService = 0) then
    return FALSE
  end if
  if tService.registerUpdates(pIGComponentId) then
    if (pFeederList.findPos(tServiceId) = 0) then
      pFeederList.append(tServiceId)
    end if
  end if
  return TRUE
end

on unregisterFromIGComponentUpdates me, tServiceId 
  tService = me.getIGComponent(tServiceId)
  if (tService = 0) then
    return FALSE
  end if
  if tService.unregisterUpdates(pIGComponentId) then
    pFeederList.deleteOne(tServiceId)
  end if
  return TRUE
end

on registerUpdates me, tServiceId 
  if (tServiceId = void()) then
    return FALSE
  end if
  if pListenerList.findPos(tServiceId) then
    return TRUE
  end if
  pListenerList.append(tServiceId)
  return TRUE
end

on unregisterUpdates me, tServiceId 
  pListenerList.deleteOne(tServiceId)
  return TRUE
end

on announceUpdate me, tUpdateId 
  if me.getActiveFlag() then
    me.handleUpdate(tUpdateId, pIGComponentId)
    return TRUE
  end if
  repeat while pListenerList <= undefined
    tServiceId = getAt(undefined, tUpdateId)
    tService = me.getIGComponent(tServiceId)
    if tService <> 0 then
      if tService.getActiveFlag() then
        tService.handleUpdate(tUpdateId, pIGComponentId)
      end if
    end if
  end repeat
  return TRUE
end

on handleUpdate me, tUpdateId, tSenderId 
  if not me.getActiveFlag() then
    return TRUE
  end if
  tRenderObj = getObject(me.getRendererID())
  if (tRenderObj = 0) then
    return TRUE
  end if
  call(#handleUpdate, [tRenderObj], tUpdateId, tSenderId)
end

on getRenderer me, tCreateIfMissing 
  if not tCreateIfMissing and not me.getActiveFlag() then
    return FALSE
  end if
  tRenderObj = getObject(me.getRendererID())
  if objectp(tRenderObj) then
    return(tRenderObj)
  end if
  tRenderObj = createObject(me.getRendererID(), ["IGComponentUI Base Class", "IG" && me.pIGComponentId & "UI Class"])
  if (tRenderObj = 0) then
    return FALSE
  end if
  tRenderObj.define(me.getID(), pMainThreadId)
  return(tRenderObj)
end

on discardRenderer me 
  tID = me.getRendererID()
  tRenderObj = getObject(tID)
  if objectp(tRenderObj) then
    tRenderObj.removeWindows()
    removeObject(tID)
  end if
  return TRUE
end

on getRendererID me 
  return(me.getID() & "_UI")
end

on setContentUpdatePollingTimeout me, tstate 
  if not pTimeoutUpdates then
    return TRUE
  end if
  if (me.pIGComponentId = void()) then
    return(error(me, "IGComponent ID not defined before setting updates!", #setContentUpdatePollingTimeout))
  end if
  tUpdateTimeoutId = pIGComponentId & "_timer"
  if (tstate = 1) or pHiddenUpdates then
    getObject(me.getID()).pollContentUpdate()
    if not timeoutExists(tUpdateTimeoutId) then
      createTimeout(tUpdateTimeoutId, pUpdateInterval, #pollContentUpdate, me.getID(), void(), 0)
    end if
  else
    if timeoutExists(tUpdateTimeoutId) then
      removeTimeout(tUpdateTimeoutId)
    end if
  end if
  return TRUE
end

on pollContentUpdate me, tForced 
  return FALSE
end

on setUpdateTimestamp me 
  me.pUpdateLastTimestamp = the milliSeconds
  return TRUE
end

on isUpdateTimestampExpired me 
  tTolerance = 1.05
  return((tTolerance * (the milliSeconds - me.pUpdateLastTimestamp)) >= me.pUpdateInterval)
end

on getOwnPlayerName me 
  tSession = getObject(#session)
  if (tSession = 0) then
    return FALSE
  end if
  return(tSession.GET(#user_name))
end
