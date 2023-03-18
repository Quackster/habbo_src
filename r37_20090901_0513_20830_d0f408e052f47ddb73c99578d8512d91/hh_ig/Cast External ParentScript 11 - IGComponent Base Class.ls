property pIGComponentId, pActiveFlag, pTimeoutUpdates, pHiddenUpdates, pMainThreadId, pUpdateLastTimestamp, pUpdateInterval, pFeederList, pListenerList

on construct me
  pActiveFlag = 0
  pTimeoutUpdates = 0
  pHiddenUpdates = 0
  pUpdateLastTimestamp = 0
  if variableExists("ig.update.interval") then
    pUpdateInterval = getIntVariable("ig.update.interval")
  else
    pUpdateInterval = 5000
  end if
  pFeederList = []
  pListenerList = []
  return 1
end

on deconstruct me
  me.setContentUpdatePollingTimeout(0)
  me.setActiveFlag(0)
  pListenerList = []
  repeat with tServiceId in pFeederList
    tService = me.getIGComponent(tServiceId)
    if tService <> 0 then
      tService.unregisterUpdates(pIGComponentId)
    end if
  end repeat
  pFeederList = []
  if objectExists(me.getRendererID()) then
    removeObject(me.getRendererID())
  end if
  return 1
end

on Initialize me
  return 1
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
  if tstate = 1 then
    receiveUpdate(me.getID())
  else
    removeUpdate(me.getID())
    me.discardRenderer()
  end if
  return 1
end

on getActiveFlag me
  return pActiveFlag
end

on update me
  return 1
end

on displayEvent me, ttype, tParam
  tRenderObj = me.getRenderer(1)
  if tRenderObj <> 0 then
    return tRenderObj.displayEvent(ttype, tParam)
  end if
  return 0
end

on Remove me
  me.getComponent().removeIGComponent(pIGComponentId)
end

on getMainThread me
  return getObject(pMainThreadId)
end

on getHandler me
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return 0
  end if
  return tMainThreadRef.getHandler()
end

on getComponent me
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return 0
  end if
  return tMainThreadRef.getComponent()
end

on getInterface me
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return 0
  end if
  return tMainThreadRef.getInterface()
end

on ChangeWindowView me, tMode
  tInterface = me.getInterface()
  if tInterface = 0 then
    return 0
  end if
  return tInterface.ChangeWindowView(tMode)
end

on renderUI me, tComponentSpec
  tRenderObj = getObject(me.getRendererID())
  if tRenderObj = 0 then
    return 1
  end if
  return tRenderObj.renderUI(tComponentSpec)
end

on resetSubComponent me, tID
  tRenderObj = getObject(me.getRendererID())
  if tRenderObj = 0 then
    return 1
  end if
  return tRenderObj.resetSubComponent(tID)
end

on getIGComponent me, tServiceId
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return 0
  end if
  return tMainThreadRef.getIGComponent(tServiceId)
end

on registerForIGComponentUpdates me, tServiceId
  tService = me.getIGComponent(tServiceId)
  if tService = 0 then
    return 0
  end if
  if tService.registerUpdates(pIGComponentId) then
    if pFeederList.findPos(tServiceId) = 0 then
      pFeederList.append(tServiceId)
    end if
  end if
  return 1
end

on unregisterFromIGComponentUpdates me, tServiceId
  tService = me.getIGComponent(tServiceId)
  if tService = 0 then
    return 0
  end if
  if tService.unregisterUpdates(pIGComponentId) then
    pFeederList.deleteOne(tServiceId)
  end if
  return 1
end

on registerUpdates me, tServiceId
  if tServiceId = VOID then
    return 0
  end if
  if pListenerList.findPos(tServiceId) then
    return 1
  end if
  pListenerList.append(tServiceId)
  return 1
end

on unregisterUpdates me, tServiceId
  pListenerList.deleteOne(tServiceId)
  return 1
end

on announceUpdate me, tUpdateId
  if me.getActiveFlag() then
    me.handleUpdate(tUpdateId, pIGComponentId)
    return 1
  end if
  repeat with tServiceId in pListenerList
    tService = me.getIGComponent(tServiceId)
    if tService <> 0 then
      if tService.getActiveFlag() then
        tService.handleUpdate(tUpdateId, pIGComponentId)
      end if
    end if
  end repeat
  return 1
end

on handleUpdate me, tUpdateId, tSenderId
  if not me.getActiveFlag() then
    return 1
  end if
  tRenderObj = getObject(me.getRendererID())
  if tRenderObj = 0 then
    return 1
  end if
  call(#handleUpdate, [tRenderObj], tUpdateId, tSenderId)
end

on getRenderer me, tCreateIfMissing
  if not tCreateIfMissing and not me.getActiveFlag() then
    return 0
  end if
  tRenderObj = getObject(me.getRendererID())
  if objectp(tRenderObj) then
    return tRenderObj
  end if
  tRenderObj = createObject(me.getRendererID(), ["IGComponentUI Base Class", "IG" && me.pIGComponentId & "UI Class"])
  if tRenderObj = 0 then
    return 0
  end if
  tRenderObj.define(me.getID(), pMainThreadId)
  return tRenderObj
end

on discardRenderer me
  tID = me.getRendererID()
  tRenderObj = getObject(tID)
  if objectp(tRenderObj) then
    tRenderObj.removeWindows()
    removeObject(tID)
  end if
  return 1
end

on getRendererID me
  return me.getID() & "_UI"
end

on setContentUpdatePollingTimeout me, tstate
  if not pTimeoutUpdates then
    return 1
  end if
  if me.pIGComponentId = VOID then
    return error(me, "IGComponent ID not defined before setting updates!", #setContentUpdatePollingTimeout)
  end if
  tUpdateTimeoutId = pIGComponentId & "_timer"
  if (tstate = 1) or pHiddenUpdates then
    if variableExists("ig." & pIGComponentId & ".update.interval") then
      pUpdateInterval = getIntVariable("ig." & pIGComponentId & ".update.interval")
    end if
    getObject(me.getID()).pollContentUpdate()
    if not timeoutExists(tUpdateTimeoutId) then
      createTimeout(tUpdateTimeoutId, pUpdateInterval, #pollContentUpdate, me.getID(), VOID, 0)
    end if
  else
    if timeoutExists(tUpdateTimeoutId) then
      removeTimeout(tUpdateTimeoutId)
    end if
  end if
  return 1
end

on pollContentUpdate me, tForced
  return 0
end

on setUpdateTimestamp me
  me.pUpdateLastTimestamp = the milliSeconds
  return 1
end

on isUpdateTimestampExpired me
  tTolerance = 1.05000000000000004
  return (tTolerance * (the milliSeconds - me.pUpdateLastTimestamp)) >= me.pUpdateInterval
end

on getOwnPlayerName me
  tSession = getObject(#session)
  if tSession = 0 then
    return 0
  end if
  return tSession.GET(#user_name)
end
