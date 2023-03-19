property pPriorityList, pEndList, pTerminationList, pCurrentActions, pHostObject

on construct me
  pPriorityList = ["fx", "wave", "dance", "mv", "sit", "lay"]
  pEndList = ["std": ["mv", "sit", "lay"], "wave": ["dance"], "mv": ["sit", "lay"], "sit": ["lay"]]
  pTerminationList = ["dance": "std"]
  pCurrentActions = []
  pHostObject = VOID
end

on isPriorityTo me, tIs, tThan
  if pPriorityList.getPos(tIs) = 0 then
    return 0
  else
    if pPriorityList.getPos(tThan) = 0 then
      return 1
    else
      if pPriorityList.getPos(tIs) < pPriorityList.getPos(tThan) then
        return 1
      else
        return 0
      end if
    end if
  end if
end

on setHumanObject me, tHumanObj
  pHostObject = tHumanObj
end

on processAction me, tAction
  if voidp(pHostObject) then
    return error(me, "Host object not set", #processAction, #major)
  end if
  tParams = tAction.word[2..tAction.word.count]
  tActRoot = tAction.word[1]
  if pPriorityList.getPos(tActRoot) <> 0 then
    call(symbol("action_" & tActRoot), [pHostObject], tAction)
    return 1
  end if
  me.endActions(tActRoot)
  me.addToCurrentActions(tAction)
  put pCurrentActions
  tActionIndex = me.getActionIndex(pCurrentActions)
  tAllowFX = call(#validateFxForActionList, [pHostObject], pCurrentActions, tActionIndex)
  tActionList = []
  tUserActions = pCurrentActions.duplicate()
  repeat with i = tUserActions.count down to 1
    tAction = tUserActions[i]
    tName = tAction.word[1]
    if pPriorityList.findPos(tName) then
      tActionList.add(tAction)
      tUserActions.deleteAt(i)
    end if
    if (tName = "fx") and not tAllowFX then
      tUserActions.deleteAt(i)
    end if
  end repeat
  tEffect = VOID
  repeat with tAction in tUserActions
    if tAction.word[1] = "fx" then
      tEffect = tAction.duplicate()
      next repeat
    end if
    tActionList.add(tAction)
  end repeat
  if tEffect <> VOID then
    tActionList.add(tEffect)
  end if
  repeat with tAction in tActionList
    call(symbol("action_" & tAction.word[1]), [pHostObject], tAction)
  end repeat
  return 1
end

on addToCurrentActions me, tAction
end

on terminateAction me, tAction
  if voidp(pHostObject) then
    return error(me, "Host object not set", #processAction, #major)
  end if
  tActRoot = tAction.word[1]
  if not voidp(pTerminationList.getaProp(tActRoot)) then
    tTermination = pTerminationList.getaProp(tActRoot)
    call("action_" & tTermination, [pHostObject], tTermination)
    pCurrentActions.deleteOne(tActRoot)
  end if
  return 1
end

on endActions me, tCause
  if voidp(pHostObject) then
    return error(me, "Host object not set", #processAction, #major)
  end if
  tActRoot = tCause.word[1]
  if not voidp(pEndList.getaProp(tActRoot)) then
    repeat with tAct in pEndList.getaProp(tActRoot)
      me.terminateAction(tAct)
    end repeat
  end if
  return 1
end

on getActionIndex me, tActionList
  tOut = []
  repeat with tAction in tActionList
    tOut.add(tAction.word[1])
  end repeat
  return tOut
end
