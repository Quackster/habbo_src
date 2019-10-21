on define(me, tProps)
  pAnimLength = 20
  pCrossFadeLength = pAnimLength / 2
  tRetVal = callAncestor(#define, [me], tProps)
  pBlendSpriteList = []
  i = 1
  repeat while i <= me.count(#pLayerDataList)
    if me.getPropRef(#pLayerDataList, i).count > 1 then
      pBlendSpriteList.add(i)
    end if
    i = 1 + i
  end repeat
  return(tRetVal)
  exit
end

on update(me)
  if not voidp(pActiveLayer) and not voidp(pActiveLayerNew) then
    if pCounter > pAnimLength - pCrossFadeLength then
      tDelta = pCounter - pAnimLength - pCrossFadeLength
      if me.count(#pSprList) >= pActiveLayer then
        me.getPropRef(#pSprList, pActiveLayer).blend = pCrossFadeLength - tDelta * 100 / pCrossFadeLength
      end if
      if me.count(#pSprList) >= pActiveLayerNew then
        me.getPropRef(#pSprList, pActiveLayerNew).blend = tDelta * 100 / pCrossFadeLength
      end if
    end if
    if pCounter = pAnimLength then
      pCounter = 1
      tList = pBlendSpriteList.duplicate()
      pActiveLayer = pActiveLayerNew
      tList.deleteOne(pActiveLayer)
      tAnimData = me.getPropRef(#pLayerDataList, pActiveLayer).getAt(2)
      if not voidp(tAnimData.getAt(#delay)) then
        pAnimLength = tAnimData.getAt(#delay)
        pCrossFadeLength = pAnimLength / 2
      end if
      pActiveLayerNew = tList.getAt(random(tList.count))
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
  if tNewState = 2 then
    pCounter = 1
    if voidp(pBlendSpriteList) then
      pBlendSpriteList = []
      i = 1
      repeat while i <= me.count(#pLayerDataList)
        if me.getPropRef(#pLayerDataList, i).count > 1 then
          pBlendSpriteList.add(i)
        end if
        i = 1 + i
      end repeat
    end if
    tList = pBlendSpriteList.duplicate()
    if tList.count >= 2 then
      pActiveLayer = tList.getAt(random(tList.count))
      tList.deleteOne(pActiveLayer)
      tAnimData = me.getPropRef(#pLayerDataList, pActiveLayer).getAt(2)
      if not voidp(tAnimData.getAt(#delay)) then
        pAnimLength = tAnimData.getAt(#delay)
        pCrossFadeLength = pAnimLength / 2
      end if
      pActiveLayerNew = tList.getAt(random(tList.count))
    end if
  end if
  tRetVal = callAncestor(#setState, [me], tNewState)
  me.initBlends()
  return(tRetVal)
  exit
end

on initBlends(me)
  if voidp(pBlendSpriteList) then
    return(0)
  end if
  repeat while me <= undefined
    i = getAt(undefined, undefined)
    if me.count(#pSprList) >= i then
      if i = pActiveLayer then
        me.getPropRef(#pSprList, i).blend = 100
      else
        me.getPropRef(#pSprList, i).blend = 0
      end if
    end if
  end repeat
  return(1)
  exit
end