property pProcessorObjList, pUpdateBrokerList, pBaseProcClassList

on construct me
  pProcessorObjList = [:]
  pUpdateBrokerList = [:]
  if not variableExists("gamesystem.processor.superclass") then
    return error(me, "gamesystem.processor.superclass not found.", #defineProcessors)
  end if
  pBaseProcClassList = getClassVariable("gamesystem.processor.superclass")
  return 1
end

on deconstruct me
  me.removeAllProcessors()
  return 1
end

on defineClient me, tID
  return me.defineProcessors()
end

on distributeEvent me, tTopic, tdata
  tBaseLogic = me.getBaseLogic()
  tStoreMethod = symbol("store_" & tTopic)
  if tBaseLogic.handler(tStoreMethod) then
    call(tStoreMethod, tBaseLogic, tdata)
  end if
  if not pUpdateBrokerList.findPos(tTopic) then
    return 0
  end if
  tList = pUpdateBrokerList.getProp(tTopic)
  repeat with tListenerId in tList
    tListener = pProcessorObjList.getaProp(tListenerId)
    if tListener <> VOID then
      call(#handleUpdate, tListener, tTopic, tdata)
      next repeat
    end if
    pProcessorObjList.deleteProp(tListenerId)
    tList.deleteOne(tListenerId)
  end repeat
  return 1
end

on defineProcessors me
  me.removeAllProcessors()
  tID = me.getSystemId()
  if variableExists(tID & ".processors") then
    tProcIdList = getVariableValue(tID & ".processors")
  end if
  if not listp(tProcIdList) then
    return error(me, "Processor list not found:" && tID, #defineProcessors)
  end if
  repeat with tProcId in tProcIdList
    me.defineSingleProcessor(tProcId)
  end repeat
  return 1
end

on defineSingleProcessor me, tProcId
  tID = me.getSystemId()
  tProcObjId = symbol(tID & "_proc_" & tProcId)
  tScriptList = getClassVariable(tID & "." & tProcId & ".processor.class")
  if not listp(tScriptList) then
    return error(me, "Script list not found:" && tID & "." & tProcId, #defineProcessors)
  end if
  tScriptList.addAt(1, pBaseProcClassList)
  tProcObject = createObject(tProcObjId, tScriptList)
  if not objectp(tProcObject) then
    return error(me, "Unable to create processor object:" && tProcObjId && tScriptList && tScriptList.ilk, #defineProcessors)
  end if
  tProcObject.setaProp(#pFacadeId, tID)
  tProcObject.setaProp(#pID, tProcId)
  tProcObject.setID(tProcId, tID)
  pProcessorObjList.addProp(tProcId, tProcObject)
  tProcessorRegList = getVariableValue(tID & "." & tProcId & ".processor.updates")
  if listp(tProcessorRegList) then
    repeat with tMsg in tProcessorRegList
      if tMsg = VOID then
        return error(me, "Invalid format in processor message:" && tProcObjId && tMsg, #defineProcessors)
      end if
      if voidp(pUpdateBrokerList[tMsg]) then
        pUpdateBrokerList.addProp(tMsg, [])
      end if
      if pUpdateBrokerList[tMsg].getPos(tProcId) = 0 then
        pUpdateBrokerList[tMsg].add(tProcId)
      end if
    end repeat
  end if
  return 1
end

on removeSingleProcessor me, tProcId
  tProcObject = pProcessorObjList.getaProp(tProcId)
  if not objectp(tProcObject) then
    return error(me, "Processor not found:" && tProcId, #removeSingleProcessor)
  end if
  repeat with tMsg in pUpdateBrokerList
    tMsg.deleteOne(tProcId)
  end repeat
  tProcObjectId = tProcObject.getID()
  pProcessorObjList.deleteProp(tProcId)
  removeObject(tProcObjectId)
  return 1
end

on getProcessor me, tProcId
  return pProcessorObjList.getaProp(tProcId)
end

on removeAllProcessors me
  repeat with tProc in pProcessorObjList
    removeObject(tProc.getID())
  end repeat
  pProcessorObjList = [:]
  pUpdateBrokerList = [:]
  return 1
end
