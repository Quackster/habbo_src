property pExtraStateCount, pFlippedLayerDataList, pStateCount, pRollStartMillis, pOriginalLayerDataList, pTargetState, pRunning

on define me, tProps 
  pRunning = 0
  pTargetState = 0
  pExtraStateCount = 3
  pRollStartMillis = 0
  tRetVal = callAncestor(#define, [me], tProps)
  pStateCount = ((me.count(#pStateSequenceList) - pExtraStateCount) / 2)
  pFlippedLayerDataList = me.pLayerDataList.duplicate()
  pOriginalLayerDataList = me.pLayerDataList.duplicate()
  tLayerCount = pFlippedLayerDataList.count
  j = 1
  repeat while j <= 2
    i = 1
    repeat while i <= (pStateCount / 2)
      tTmp = pFlippedLayerDataList.getAt(((tLayerCount - (pStateCount * j)) + i)).duplicate()
      tTmp2 = pFlippedLayerDataList.getAt(((((tLayerCount - (pStateCount * j)) + pStateCount) + 1) - i)).duplicate()
      pFlippedLayerDataList.setAt(((tLayerCount - (pStateCount * j)) + i), tTmp2)
      pFlippedLayerDataList.setAt(((((tLayerCount - (pStateCount * j)) + pStateCount) + 1) - i), tTmp)
      i = (1 + i)
    end repeat
    j = (1 + j)
  end repeat
  return(tRetVal)
end

on select me 
  if the doubleClick then
    if (me.pState = 1) or (me.pState = pExtraStateCount) and (the milliSeconds - pRollStartMillis) > (15 * 1000) then
      getThread(#room).getComponent().getRoomConnection().send("SET_RANDOM_STATE", [#integer:value(me.getID())])
      pRunning = 1
    end if
  else
    return FALSE
  end if
  return TRUE
end

on update me 
  if (me.getProp(#pDirection, 1) = 4) then
    me.pLayerDataList = pOriginalLayerDataList
  else
    me.pLayerDataList = pFlippedLayerDataList
  end if
  if (me.pIsAnimatingList.findPos(1) = 0) then
    if (me.pState = (pExtraStateCount - 1)) then
      me.setStateInternal(pExtraStateCount)
    else
      if (me.pState = pExtraStateCount) then
        if pTargetState then
          me.setStateInternal((pExtraStateCount + pTargetState))
        else
          me.setStateInternal(pExtraStateCount)
        end if
      else
        if (me.pState = (pExtraStateCount + pTargetState)) then
          me.setStateInternal(((pExtraStateCount + pStateCount) + pTargetState))
          pTargetState = 0
        else
          if me.pState > (pExtraStateCount + pStateCount) then
            me.setStateInternal(1)
          end if
        end if
      end if
    end if
  end if
  return(callAncestor(#update, [me]))
end

on setState me, tNewState 
  tNewState = value(tNewState)
  if tNewState > 1000 then
    tNewState = 0
    pRunning = 1
  end if
  if pRunning then
    tNewState = -tNewState
  end if
  me.setStateInternal(tNewState)
end

on setStateInternal me, tNewState 
  tNewState = value(tNewState)
  if not pRunning then
    if tNewState > 0 then
      tNewState = 1
    end if
  end if
  if tNewState <= 0 then
    tNewState = -tNewState
    if (tNewState = 0) then
      pRollStartMillis = the milliSeconds
      if pRunning then
        callAncestor(#setState, [me], (pExtraStateCount - 1))
      else
        callAncestor(#setState, [me], pExtraStateCount)
      end if
    else
      if tNewState >= 1 and tNewState <= pStateCount then
        pTargetState = tNewState
      end if
    end if
  else
    tRetVal = callAncestor(#setState, [me], tNewState)
  end if
  return(tRetVal)
end
