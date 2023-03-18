property pActiveLayer, pCounter, pAnimLength, pCrossFadeLength, pAnimState

on define me, tProps
  pAnimState = 0
  pActiveLayer = 0
  pAnimLength = 20
  pCrossFadeLength = pAnimLength / 2
  tRetVal = callAncestor(#define, [me], tProps)
  repeat with i = me.pLayerDataList.count down to 1
    repeat with j = 1 to me.pLayerDataList[i].count
      if me.pLayerDataList[i][j][#frames].count > 1 then
        pAnimState = j
      end if
    end repeat
    if pAnimState > 0 then
      exit repeat
    end if
  end repeat
  if pAnimState > 0 then
    repeat with i = 1 to me.pLayerDataList.count
      if me.pLayerDataList[i].count >= pAnimState then
        if me.pLayerDataList[i][pAnimState][#frames].count > 1 then
          pActiveLayer = i
        end if
      end if
    end repeat
  end if
  if pActiveLayer > 0 then
    tAnimData = me.pLayerDataList[pActiveLayer][pAnimState]
    if not voidp(tAnimData[#delay]) then
      pAnimLength = tAnimData[#delay]
      pCrossFadeLength = pAnimLength / 2
    end if
  end if
  me.initBlends()
  return tRetVal
end

on update me
  if (pActiveLayer > 0) and (pActiveLayer <= me.pSprList.count) and (me.pState = pAnimState) then
    if (pCounter > ((pAnimLength / 2) - pCrossFadeLength)) and (pCounter <= (pAnimLength / 2)) then
      tDelta = pCounter - ((pAnimLength / 2) - pCrossFadeLength)
      me.pSprList[pActiveLayer].blend = tDelta * 100 / pCrossFadeLength
    else
      if pCounter > (pAnimLength - pCrossFadeLength) then
        tDelta = pCounter - (pAnimLength - pCrossFadeLength)
        me.pSprList[pActiveLayer].blend = (pCrossFadeLength - tDelta) * 100 / pCrossFadeLength
      end if
    end if
    if pCounter = pAnimLength then
      pCounter = 1
      me.initBlends()
    else
      pCounter = pCounter + 1
    end if
  end if
  return callAncestor(#update, [me])
end

on setState me, tNewState
  tNewState = integer(tNewState)
  if tNewState = pAnimState then
    pCounter = 1
  end if
  tRetVal = callAncestor(#setState, [me], tNewState)
  me.initBlends()
  return tRetVal
end

on initBlends me
  if pActiveLayer > 0 then
    if me.pState = pAnimState then
      me.pSprList[pActiveLayer].blend = 0
    else
      me.pSprList[pActiveLayer].blend = 100
    end if
  end if
  return 1
end
