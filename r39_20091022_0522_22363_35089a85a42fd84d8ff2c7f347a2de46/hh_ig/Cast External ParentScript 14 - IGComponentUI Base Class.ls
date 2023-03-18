property pMasterIGComponentId, pMainThreadId, pFlagManagerId, pWindowSetId, pViewMode, pViewModeComponents, pSubComponentList, pModalSpr

on construct me
  pViewMode = #Info
  pViewModeComponents = [:]
  pSubComponentList = [:]
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  tObject = getObject(me.getID())
  tObject.removeWindows()
  return 1
end

on define me, tMasterIGComponentId, tMainThreadId
  pMasterIGComponentId = tMasterIGComponentId
  pMainThreadId = tMainThreadId
  pWindowSetId = me.getID()
  return 1
end

on displayEvent me, ttype, tParam
  return 0
end

on removeWindows me
  removeUpdate(me.getID())
  me.removeComponents()
  me.removeFlagManager()
  me.removeModalWindow()
  return 1
end

on renderUI me, tComponentSpec
  if voidp(tComponentSpec) then
    return me.renderSubComponents(1)
  end if
  tTopLevelRef = getObject(me.getID())
  if stringp(tComponentSpec) then
    tComponent = pSubComponentList.getaProp(tComponentSpec)
    if tComponent <> 0 then
      return tComponent.render()
    end if
  else
    if listp(tComponentSpec) then
      repeat with tID in tComponentSpec
        tComponent = pSubComponentList.getaProp(tID)
        if tComponent <> 0 then
          tComponent.render()
        end if
      end repeat
    end if
  end if
  return 1
end

on Remove me
  me.getMasterIGComponent().Remove()
end

on getWindowWrapper me
  return getObject(#ig_window_wrapper)
end

on getMasterIGComponentId me
  return pMasterIGComponentId
end

on getMasterIGComponent me
  return getObject(pMasterIGComponentId)
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
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return 0
  end if
  tInterface = tMainThreadRef.getInterface()
  if tInterface = 0 then
    return 0
  end if
  return tInterface.ChangeWindowView(tMode)
end

on getIGComponent me, tServiceId
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return 0
  end if
  return tMainThreadRef.getIGComponent(tServiceId)
end

on getSubComponent me, tID, tAddIfMissing
  tObject = me.pSubComponentList.getaProp(tID)
  if tObject <> 0 then
    return tObject
  end if
  if not tAddIfMissing then
    return 0
  end if
  tObject = me.initializeSubComponent(tID, me.getSubComponentClass(tID))
  if tObject = 0 then
    return 0
  end if
  return tObject
end

on initializeSubComponent me, tID, tClass
  if tID = #modal then
    tClass = []
  end if
  if tClass = 0 then
    return 0
  end if
  if listp(tClass) then
    tClass.addAt(1, "IGComponentUI Subcomponent Class")
  else
    if stringp(tClass) then
      tClass = ["IGComponentUI Subcomponent Class", tClass]
    else
      tClass = "IGComponentUI Subcomponent Class"
    end if
  end if
  tObject = createObject(#temp, tClass)
  if tObject = 0 then
    return error(me, "Cannot create subcomponent" && tID & ", class: " && tClass, #initializeSubComponent)
  end if
  tObject.setID(tID)
  tObject.pMainThreadId = me.pMainThreadId
  tObject.pWindowSetId = me.pWindowSetId & "_" & tID
  me.pSubComponentList.setaProp(tID, tObject)
  tFlagManager = me.getFlagManager(1)
  if tFlagManager = 0 then
    return 0
  end if
  tObject.pFlagManagerId = tFlagManager.getID()
  tObject.addWindows()
  return tObject
end

on setViewMode me, tMode
  me.pViewMode = tMode
  return me.renderSubComponents()
end

on getViewMode me
  return pViewMode
end

on resetSubComponent me, tID
  tPos = me.pSubComponentList.findPos(tID)
  if tPos = 0 then
    return 0
  end if
  tComponent = me.pSubComponentList.getaProp(tID)
  if objectp(tComponent) then
    tComponent.deconstruct()
  end if
  me.pSubComponentList.deleteProp(tID)
  tTopLevelRef = getObject(me.getID())
  tComponent = tTopLevelRef.getSubComponent(tID, 1)
  if tComponent = 0 then
    return error(me, "Error creating components:" && tID, #resetSubComponent)
  end if
  tNewList = [:]
  repeat with i = 1 to tPos - 1
    tNewList.setaProp(me.pSubComponentList.getPropAt(i), me.pSubComponentList[i])
  end repeat
  tNewList.setaProp(tID, tComponent)
  repeat with i = tPos to me.pSubComponentList.count - 1
    tNewList.setaProp(me.pSubComponentList.getPropAt(i), me.pSubComponentList[i])
  end repeat
  me.pSubComponentList = tNewList
  tComponent.render()
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.render()
  return 1
end

on renderSubComponents me, tComponentList
  tTopLevelRef = getObject(me.getID())
  if not listp(tComponentList) then
    tComponentList = pViewModeComponents.getaProp(pViewMode)
    if tComponentList = 0 then
      return 0
    end if
  end if
  if not me.verifyComponentList(tComponentList) then
    tNewSubComponentList = [:]
    tPurgeList = []
    repeat with i = 1 to tComponentList.count
      tID = tComponentList[i]
      tCreated = 0
      j = i
      repeat while j <= me.pSubComponentList.count
        if tID = me.pSubComponentList.getPropAt(j) then
          tCreated = 1
          exit repeat
          next repeat
        end if
        tObject = me.pSubComponentList[j]
        if objectp(tObject) then
          tObject.deconstruct()
        end if
        me.pSubComponentList.deleteAt(j)
        tRenderFlag = 1
      end repeat
      if not tCreated then
        tComponent = tTopLevelRef.getSubComponent(tID, 1)
        if tComponent <> 0 then
          tRenderFlag = 1
        end if
      end if
    end repeat
    if tRenderFlag = 1 then
      tWrapObjRef = me.getWindowWrapper()
      if tWrapObjRef = 0 then
        return 0
      end if
      tWrapObjRef.render()
    end if
  end if
  repeat with tID in tComponentList
    tComponent = tTopLevelRef.getSubComponent(tID)
    if tComponent <> 0 then
      tComponent.render()
    end if
  end repeat
  receiveUpdate(me.getID())
end

on removeComponents me
  repeat with tObject in pSubComponentList
    if objectp(tObject) then
      tObject.deconstruct()
    end if
  end repeat
  pSubComponentList = [:]
  return 1
end

on verifyComponentList me, tComponentList
  tCount = pSubComponentList.count
  if tCount <> tComponentList.count then
    return 0
  end if
  repeat with i = 1 to tCount
    if pSubComponentList.getPropAt(i) <> tComponentList[i] then
      return 0
    end if
  end repeat
  return 1
end

on getFlagManager me, tCreateIfMissing
  if objectExists(pFlagManagerId) then
    return getObject(pFlagManagerId)
  end if
  if not tCreateIfMissing then
    return 0
  end if
  return me.createFlagManager()
end

on createFlagManager me
  if pFlagManagerId = VOID then
    pFlagManagerId = me.getID() & "_flagmanager"
  end if
  if objectExists(pFlagManagerId) then
    return 1
  end if
  if not createObject(pFlagManagerId, "IG FlagManager Class") then
    return 0
  end if
  return getObject(pFlagManagerId)
end

on removeFlagManager me
  if not objectExists(pFlagManagerId) then
    return 1
  end if
  removeObject(pFlagManagerId)
  return 1
end

on createModalWindow me
  if pModalSpr > 0 then
    return 1
  end if
  pModalSpr = reserveSprite(me.getID())
  tsprite = sprite(pModalSpr)
  tsprite.member = member(getmemnum("null"))
  tsprite.blend = 70
  tsprite.rect = rect(0, 0, (the stage).rect.width, (the stage).rect.height)
  tVisualizer = getVisualizer("Room_visualizer")
  if tVisualizer <> 0 then
    tsprite.locZ = tVisualizer.getProperty(#locZ) + 10000000
  else
    tsprite.locZ = -10000000
  end if
  setEventBroker(tsprite.spriteNum, me.getID() & "_spr")
  return 1
end

on removeModalWindow me
  if pModalSpr > 0 then
    releaseSprite(pModalSpr)
    pModalSpr = VOID
  end if
  return 1
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  return 1
end
