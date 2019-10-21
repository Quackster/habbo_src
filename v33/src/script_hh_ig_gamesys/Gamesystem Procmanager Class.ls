on construct(me)
  pProcessorObjList = []
  pUpdateBrokerList = []
  if not variableExists("gamesystem.processor.superclass") then
    return(error(me, "gamesystem.processor.superclass not found.", #defineProcessors))
  end if
  pBaseProcClassList = getClassVariable("gamesystem.processor.superclass")
  return(1)
  exit
end

on deconstruct(me)
  me.removeAllProcessors()
  return(1)
  exit
end

on defineClient(me, tID)
  return(me.defineProcessors())
  exit
end

on distributeEvent(me, tTopic, tdata)
  tBaseLogic = me.getBaseLogic()
  tStoreMethod = symbol("store_" & tTopic)
  if tBaseLogic.handler(tStoreMethod) then
    call(tStoreMethod, tBaseLogic, tdata)
  end if
  if not pUpdateBrokerList.findPos(tTopic) then
    return(0)
  end if
  tList = pUpdateBrokerList.getProp(tTopic)
  repeat while me <= tdata
    tListenerId = getAt(tdata, tTopic)
    tListener = pProcessorObjList.getaProp(tListenerId)
    if tListener <> void() then
      call(#handleUpdate, tListener, tTopic, tdata)
    else
      pProcessorObjList.deleteProp(tListenerId)
      tList.deleteOne(tListenerId)
    end if
  end repeat
  return(1)
  exit
end

on defineProcessors(me)
  me.removeAllProcessors()
  tID = me.getSystemId()
  if variableExists(tID & ".processors") then
    tProcIdList = getVariableValue(tID & ".processors")
  end if
  if not listp(tProcIdList) then
    return(error(me, "Processor list not found:" && tID, #defineProcessors))
  end if
  repeat while me <= undefined
    tProcId = getAt(undefined, undefined)
    me.defineSingleProcessor(tProcId)
  end repeat
  return(1)
  exit
end

on defineSingleProcessor(me, tProcId)
  tID = me.getSystemId()
  tProcObjId = symbol(tID & "_proc_" & tProcId)
  tScriptList = getClassVariable(tID & "." & tProcId & ".processor.class")
  if not listp(tScriptList) then
    return(error(me, "Script list not found:" && tID & "." & tProcId, #defineProcessors))
  end if
  tScriptList.addAt(1, pBaseProcClassList)
  tProcObject = createObject(tProcObjId, tScriptList)
  if not objectp(tProcObject) then
    return(error(me, "Unable to create processor object:" && tProcObjId && tScriptList && tScriptList.ilk, #defineProcessors))
  end if
  tProcObject.setaProp(#pFacadeId, tID)
  tProcObject.setaProp(#pID, tProcId)
  tProcObject.setID(tProcId, tID)
  pProcessorObjList.addProp(tProcId, tProcObject)
  tProcessorRegList = getVariableValue(tID & "." & tProcId & ".processor.updates")
  if listp(tProcessorRegList) then
    repeat while me <= undefined
      tMsg = getAt(undefined, tProcId)
      if tMsg = void() then
        return(error(me, "Invalid format in processor message:" && tProcObjId && tMsg, #defineProcessors))
      end if
      if voidp(pUpdateBrokerList.getAt(tMsg)) then
        pUpdateBrokerList.addProp(tMsg, [])
      end if
      if pUpdateBrokerList.getAt(tMsg).getPos(tProcId) = 0 then
        pUpdateBrokerList.getAt(tMsg).add(tProcId)
      end if
    end repeat
  end if
  return(1)
  exit
end

on removeSingleProcessor(me, tProcId)
  tProcObject = pProcessorObjList.getaProp(tProcId)
  if not objectp(tProcObject) then
    return(error(me, "Processor not found:" && tProcId, #removeSingleProcessor))
  end if
  repeat while me <= undefined
    tMsg = getAt(undefined, tProcId)
    tMsg.deleteOne(tProcId)
  end repeat
  tProcObjectId = tProcObject.getID()
  pProcessorObjList.deleteProp(tProcId)
  removeObject(tProcObjectId)
  return(1)
  exit
end

on getProcessor(me, tProcId)
  return(pProcessorObjList.getaProp(tProcId))
  exit
end

on removeAllProcessors(me)
  repeat while me <= undefined
    tProc = getAt(undefined, undefined)
    removeObject(tProc.getID())
  end repeat
  pProcessorObjList = []
  pUpdateBrokerList = []
  return(1)
  exit
end