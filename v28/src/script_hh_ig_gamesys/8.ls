property pUpdateBrokerList, pProcessorObjList, pBaseProcClassList

on construct me 
  pProcessorObjList = [:]
  pUpdateBrokerList = [:]
  if not variableExists("gamesystem.processor.superclass") then
    return(error(me, "gamesystem.processor.superclass not found.", #defineProcessors))
  end if
  pBaseProcClassList = getClassVariable("gamesystem.processor.superclass")
  return TRUE
end

on deconstruct me 
  me.removeAllProcessors()
  return TRUE
end

on defineClient me, tID 
  return(me.defineProcessors())
end

on distributeEvent me, tTopic, tdata 
  tBaseLogic = me.getBaseLogic()
  tStoreMethod = symbol("store_" & tTopic)
  if tBaseLogic.handler(tStoreMethod) then
    call(tStoreMethod, tBaseLogic, tdata)
  end if
  if not pUpdateBrokerList.findPos(tTopic) then
    return FALSE
  end if
  tList = pUpdateBrokerList.getProp(tTopic)
  repeat while tList <= tdata
    tListenerId = getAt(tdata, tTopic)
    tListener = pProcessorObjList.getaProp(tListenerId)
    if tListener <> void() then
      call(#handleUpdate, tListener, tTopic, tdata)
    else
      pProcessorObjList.deleteProp(tListenerId)
      tList.deleteOne(tListenerId)
    end if
  end repeat
  return TRUE
end

on defineProcessors me 
  me.removeAllProcessors()
  tID = me.getSystemId()
  if variableExists(tID & ".processors") then
    tProcIdList = getVariableValue(tID & ".processors")
  end if
  if not listp(tProcIdList) then
    return(error(me, "Processor list not found:" && tID, #defineProcessors))
  end if
  repeat while tProcIdList <= undefined
    tProcId = getAt(undefined, undefined)
    me.defineSingleProcessor(tProcId)
  end repeat
  return TRUE
end

on defineSingleProcessor me, tProcId 
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
    repeat while tProcessorRegList <= undefined
      tMsg = getAt(undefined, tProcId)
      if (tMsg = void()) then
        return(error(me, "Invalid format in processor message:" && tProcObjId && tMsg, #defineProcessors))
      end if
      if voidp(pUpdateBrokerList.getAt(tMsg)) then
        pUpdateBrokerList.addProp(tMsg, [])
      end if
      if (pUpdateBrokerList.getAt(tMsg).getPos(tProcId) = 0) then
        pUpdateBrokerList.getAt(tMsg).add(tProcId)
      end if
    end repeat
  end if
  return TRUE
end

on removeSingleProcessor me, tProcId 
  tProcObject = pProcessorObjList.getaProp(tProcId)
  if not objectp(tProcObject) then
    return(error(me, "Processor not found:" && tProcId, #removeSingleProcessor))
  end if
  repeat while pUpdateBrokerList <= undefined
    tMsg = getAt(undefined, tProcId)
    tMsg.deleteOne(tProcId)
  end repeat
  tProcObjectId = tProcObject.getID()
  pProcessorObjList.deleteProp(tProcId)
  removeObject(tProcObjectId)
  return TRUE
end

on getProcessor me, tProcId 
  return(pProcessorObjList.getaProp(tProcId))
end

on removeAllProcessors me 
  repeat while pProcessorObjList <= undefined
    tProc = getAt(undefined, undefined)
    removeObject(tProc.getID())
  end repeat
  pProcessorObjList = [:]
  pUpdateBrokerList = [:]
  return TRUE
end
