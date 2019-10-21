on construct(me)
  pPriorityList = ["fx", "wave", "dance", "mv", "sit", "lay"]
  pEndList = ["std":["mv", "sit", "lay"], "wave":["dance"], "mv":["sit", "lay"], "sit":["lay"]]
  pTerminationList = ["dance":"std"]
  pCurrentActions = []
  pHostObject = void()
  exit
end

on isPriorityTo(me, tIs, tThan)
  if pPriorityList.getPos(tIs) = 0 then
    return(0)
  else
    if pPriorityList.getPos(tThan) = 0 then
      return(1)
    else
      if pPriorityList.getPos(tIs) < pPriorityList.getPos(tThan) then
        return(1)
      else
        return(0)
      end if
    end if
  end if
  exit
end

on setHumanObject(me, tHumanObj)
  pHostObject = tHumanObj
  exit
end

on processAction(me, tAction)
  if voidp(pHostObject) then
    return(error(me, "Host object not set", #processAction, #major))
  end if
  tParams = tAction.getProp(#word, 2, tAction.count(#word))
  tActRoot = tAction.getProp(#word, 1)
  if pPriorityList.getPos(tActRoot) <> 0 then
    call(symbol("action_" & tActRoot), [pHostObject], tAction)
    return(1)
  end if
  me.endActions(tActRoot)
  me.addToCurrentActions(tAction)
  put(pCurrentActions)
  tActionIndex = me.getActionIndex(pCurrentActions)
  tAllowFX = call(#validateFxForActionList, [pHostObject], pCurrentActions, tActionIndex)
  tActionList = []
  tUserActions = pCurrentActions.duplicate()
  i = tUserActions.count
  repeat while i >= 1
    tAction = tUserActions.getAt(i)
    tName = tAction.getProp(#word, 1)
    if pPriorityList.findPos(tName) then
      tActionList.add(tAction)
      tUserActions.deleteAt(i)
    end if
    if tName = "fx" and not tAllowFX then
      tUserActions.deleteAt(i)
    end if
    i = 255 + i
  end repeat
  tEffect = void()
  repeat while me <= undefined
    tAction = getAt(undefined, tAction)
    if tAction.getProp(#word, 1) = "fx" then
      tEffect = tAction.duplicate()
    else
      tActionList.add(tAction)
    end if
  end repeat
  if tEffect <> void() then
    tActionList.add(tEffect)
  end if
  repeat while me <= undefined
    tAction = getAt(undefined, tAction)
    call(symbol("action_" & tAction.getProp(#word, 1)), [pHostObject], tAction)
  end repeat
  return(1)
  exit
end

on addToCurrentActions(me, tAction)
  exit
end

on terminateAction(me, tAction)
  if voidp(pHostObject) then
    return(error(me, "Host object not set", #processAction, #major))
  end if
  tActRoot = tAction.getProp(#word, 1)
  if not voidp(pTerminationList.getaProp(tActRoot)) then
    tTermination = pTerminationList.getaProp(tActRoot)
    call("action_" & tTermination, [pHostObject], tTermination)
    pCurrentActions.deleteOne(tActRoot)
  end if
  return(1)
  exit
end

on endActions(me, tCause)
  if voidp(pHostObject) then
    return(error(me, "Host object not set", #processAction, #major))
  end if
  tActRoot = tCause.getProp(#word, 1)
  if not voidp(pEndList.getaProp(tActRoot)) then
    repeat while me <= undefined
      tAct = getAt(undefined, tCause)
      me.terminateAction(tAct)
    end repeat
  end if
  return(1)
  exit
end

on getActionIndex(me, tActionList)
  tOut = []
  repeat while me <= undefined
    tAction = getAt(undefined, tActionList)
    tOut.add(tAction.getProp(#word, 1))
  end repeat
  return(tOut)
  exit
end