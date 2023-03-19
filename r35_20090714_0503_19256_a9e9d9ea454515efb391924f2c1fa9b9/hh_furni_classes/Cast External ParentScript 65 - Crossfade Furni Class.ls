property pActiveLayer, pActiveLayerNew, pCounter, pAnimLength, pCrossFadeLength, pBlendSpriteList

on define me, tProps
  pAnimLength = 20
  pCrossFadeLength = pAnimLength / 2
  tRetVal = callAncestor(#define, [me], tProps)
  pBlendSpriteList = []
  repeat with i = 1 to me.pLayerDataList.count
    if me.pLayerDataList[i].count > 1 then
      pBlendSpriteList.add(i)
    end if
  end repeat
  return tRetVal
end

on update me
  if not voidp(pActiveLayer) and not voidp(pActiveLayerNew) then
    if pCounter > (pAnimLength - pCrossFadeLength) then
      tDelta = pCounter - (pAnimLength - pCrossFadeLength)
      if me.pSprList.count >= pActiveLayer then
        me.pSprList[pActiveLayer].blend = (pCrossFadeLength - tDelta) * 100 / pCrossFadeLength
      end if
      if me.pSprList.count >= pActiveLayerNew then
        me.pSprList[pActiveLayerNew].blend = tDelta * 100 / pCrossFadeLength
      end if
    end if
    if pCounter = pAnimLength then
      pCounter = 1
      tList = pBlendSpriteList.duplicate()
      pActiveLayer = pActiveLayerNew
      tList.deleteOne(pActiveLayer)
      tAnimData = me.pLayerDataList[pActiveLayer][2]
      if not voidp(tAnimData[#delay]) then
        pAnimLength = tAnimData[#delay]
        pCrossFadeLength = pAnimLength / 2
      end if
      pActiveLayerNew = tList[random(tList.count)]
      me.initBlends()
    else
      pCounter = pCounter + 1
    end if
  end if
  return callAncestor(#update, [me])
end

on setState me, tNewState
  tNewState = integer(tNewState)
  if not integerp(tNewState) then
    tNewState = 0
  end if
  if tNewState = 1 then
    pCounter = 1
    if voidp(pBlendSpriteList) then
      pBlendSpriteList = []
      repeat with i = 1 to me.pLayerDataList.count
        if me.pLayerDataList[i].count > 1 then
          pBlendSpriteList.add(i)
        end if
      end repeat
    end if
    tList = pBlendSpriteList.duplicate()
    if tList.count >= 2 then
      pActiveLayer = tList[random(tList.count)]
      tList.deleteOne(pActiveLayer)
      tAnimData = me.pLayerDataList[pActiveLayer][2]
      if not voidp(tAnimData[#delay]) then
        pAnimLength = tAnimData[#delay]
        pCrossFadeLength = pAnimLength / 2
      end if
      pActiveLayerNew = tList[random(tList.count)]
    end if
  end if
  tRetVal = callAncestor(#setState, [me], tNewState)
  me.initBlends()
  return tRetVal
end

on initBlends me
  if voidp(pBlendSpriteList) then
    return 0
  end if
  repeat with i in pBlendSpriteList
    if me.pSprList.count >= i then
      if i = pActiveLayer then
        me.pSprList[i].blend = 100
        next repeat
      end if
      me.pSprList[i].blend = 0
    end if
  end repeat
  return 1
end
