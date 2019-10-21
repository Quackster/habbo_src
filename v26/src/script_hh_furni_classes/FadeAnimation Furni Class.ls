on define(me, tProps)
  pAnimState = 0
  pActiveLayer = 0
  pAnimLength = 20
  pCrossFadeLength = pAnimLength / 2
  tRetVal = callAncestor(#define, [me], tProps)
  i = me.count(#pLayerDataList)
  repeat while i >= 1
    j = 1
    repeat while j <= me.getPropRef(#pLayerDataList, i).count
      if me.getPropRef(#pLayerDataList, i).getAt(j).getAt(#frames).count > 1 then
        pAnimState = j
      end if
      j = 1 + j
    end repeat
    if pAnimState > 0 then
    else
      i = 255 + i
    end if
  end repeat
  if pAnimState > 0 then
    i = 1
    repeat while i <= me.count(#pLayerDataList)
      if me.getPropRef(#pLayerDataList, i).count >= pAnimState then
        if me.getPropRef(#pLayerDataList, i).getAt(pAnimState).getAt(#frames).count > 1 then
          pActiveLayer = i
        end if
      end if
      i = 1 + i
    end repeat
  end if
  if pActiveLayer > 0 then
    tAnimData = me.getPropRef(#pLayerDataList, pActiveLayer).getAt(pAnimState)
    if not voidp(tAnimData.getAt(#delay)) then
      pAnimLength = tAnimData.getAt(#delay)
      pCrossFadeLength = pAnimLength / 2
    end if
  end if
  me.initBlends()
  return(tRetVal)
  exit
end

on update(me)
  if pActiveLayer > 0 and pActiveLayer <= me.count(#pSprList) and me.pState = pAnimState then
    if pCounter > pAnimLength / 2 - pCrossFadeLength and pCounter <= pAnimLength / 2 then
      tDelta = pCounter - pAnimLength / 2 - pCrossFadeLength
      me.getPropRef(#pSprList, pActiveLayer).blend = tDelta * 100 / pCrossFadeLength
    else
      if pCounter > pAnimLength - pCrossFadeLength then
        tDelta = pCounter - pAnimLength - pCrossFadeLength
        me.getPropRef(#pSprList, pActiveLayer).blend = pCrossFadeLength - tDelta * 100 / pCrossFadeLength
      end if
    end if
    if pCounter = pAnimLength then
      pCounter = 1
      me.initBlends()
    else
      pCounter = pCounter + 1
    end if
  end if
  return(callAncestor(#update, [me]))
  exit
end

on setState(me, tNewState)
  tNewState = value(tNewState)
  if tNewState = pAnimState then
    pCounter = 1
  end if
  tRetVal = callAncestor(#setState, [me], tNewState)
  me.initBlends()
  return(tRetVal)
  exit
end

on initBlends(me)
  if pActiveLayer > 0 then
    if me.pState = pAnimState then
      me.getPropRef(#pSprList, pActiveLayer).blend = 0
    else
      me.getPropRef(#pSprList, pActiveLayer).blend = 100
    end if
  end if
  return(1)
  exit
end