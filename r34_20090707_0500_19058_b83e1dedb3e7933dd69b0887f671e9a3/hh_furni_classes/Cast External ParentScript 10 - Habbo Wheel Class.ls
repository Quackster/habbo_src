property pRunning, pStateCount, pTargetState

on define me, tProps
  pRunning = 0
  pTargetState = 0
  tRetVal = callAncestor(#define, [me], tProps)
  pStateCount = (me.pStateSequenceList.count - 2) / 3
  pRunning = 1
  return tRetVal
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SPIN_WHEEL_OF_FORTUNE", [#integer: integer(me.getID())])
  end if
  return 1
end

on update me
  if me.pIsAnimatingList.findPos(1) = 0 then
    if me.pState = ((pStateCount * 3) + 1) then
      me.setState((pStateCount * 3) + 2)
    else
      if me.pState = ((pStateCount * 3) + 2) then
        if pTargetState then
          me.setState(pStateCount + pTargetState)
        else
          me.setState((pStateCount * 3) + 2)
        end if
      else
        if (me.pState = (pStateCount + pTargetState)) and (pTargetState <> 0) then
          me.setState((pStateCount * 2) + pTargetState)
          pTargetState = 0
        end if
      end if
    end if
  end if
  return callAncestor(#update, [me])
end

on setState me, tNewState
  tNewState = integer(tNewState)
  if tNewState = -1 then
    if pRunning then
      tNewState = (pStateCount * 3) + 1
    else
      tNewState = (pStateCount * 3) + 2
    end if
  end if
  if (tNewState >= 1) and (tNewState <= pStateCount) then
    if pRunning then
      if (pTargetState = 0) and ((me.pState = ((pStateCount * 3) + 1)) or (me.pState = ((pStateCount * 3) + 2))) then
        pTargetState = tNewState
      end if
    else
      tRetVal = callAncestor(#setState, [me], tNewState - 1)
    end if
  else
    tRetVal = callAncestor(#setState, [me], tNewState - 1)
  end if
  return tRetVal
end
