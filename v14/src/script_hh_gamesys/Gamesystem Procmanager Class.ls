on construct(me)
  pProcessorObjList = []
  pUpdateBrokerList = []
  return(1)
  exit
end

on deconstruct(me)
  me.removeProcessors()
  return(1)
  exit
end

on defineClient(me, tid)
  return(me.defineProcessors(tid))
  exit
end

on distributeEvent(me, tTopic, tdata)
  if me.getBaseLogic().handler(symbol("store_" & tTopic)) then
    call(symbol("store_" & tTopic), me.getBaseLogic(), tdata)
  end if
  tList = pUpdateBrokerList.getAt(tTopic)
  if not listp(tList) then
    return(0)
  end if
  repeat while me <= tdata
    tListenerId = getAt(tdata, tTopic)
    tListener = pProcessorObjList.getAt(tListenerId)
    if tListener <> void() then
      call(#handleUpdate, tListener, tTopic, tdata)
    else
      pProcessorObjList.deleteProp(tListenerId)
      pUpdateBrokerList.getAt(tTopic).deleteOne(tListenerId)
    end if
  end repeat
  return(1)
  exit
end

on defineProcessors(me, tid)
  me.removeProcessors()
  if variableExists(tid & ".processors") then
    tProcIdList = getVariableValue(tid & ".processors")
  end if
  if not listp(tProcIdList) then
    return(error(me, "Processor list not found:" && tid, #defineProcessors))
  end if
  if not variableExists("gamesystem.processor.superclass") then
    return(error(me, "gamesystem.processor.superclass not found.", #defineProcessors))
  end if
  tBaseProcClassList = getClassVariable("gamesystem.processor.superclass")
  repeat while me <= undefined
    tProcId = getAt(undefined, tid)
    tProcObjId = symbol(tid & "_proc_" & tProcId)
    tScriptList = getClassVariable(tid & "." & tProcId & ".processor.class")
    if not listp(tScriptList) then
      return(error(me, "Script list not found:" && tid & "." & tProcId, #defineProcessors))
    end if
    tScriptList.addAt(1, tBaseProcClassList)
    tProcObject = createObject(tProcObjId, tScriptList)
    if not objectp(tProcObject) then
      return(error(me, "Unable to create processor object:" && tProcObjId && tScriptList && tScriptList.ilk, #defineProcessors))
    end if
    tProcObject.setAt(#pFacadeId, tid)
    tProcObject.setAt(#pID, tProcId)
    tProcObject.setID(tProcId, tid)
    pProcessorObjList.addProp(tProcId, tProcObject)
    tProcessorRegList = getVariableValue(tid & "." & tProcId & ".processor.updates")
    if listp(tProcessorRegList) then
      repeat while me <= undefined
        tMsg = getAt(undefined, tid)
        if tMsg = void() then
          return(error(me, "Invalid format in processor message:" && tProcObjId && tMsg, #defineProcessors))
        end if
        if pUpdateBrokerList.getAt(tMsg) = void() then
          pUpdateBrokerList.addProp(tMsg, [])
        end if
        if pUpdateBrokerList.getAt(tMsg).getPos(tProcId) = 0 then
          pUpdateBrokerList.getAt(tMsg).add(tProcId)
        end if
      end repeat
    end if
  end repeat
  return(1)
  exit
end

on removeProcessors(me)
  repeat while me <= undefined
    pProc = getAt(undefined, undefined)
    removeObject(pProc.getID())
  end repeat
  pProcessorObjList = []
  pUpdateBrokerList = []
  return(1)
  exit
end