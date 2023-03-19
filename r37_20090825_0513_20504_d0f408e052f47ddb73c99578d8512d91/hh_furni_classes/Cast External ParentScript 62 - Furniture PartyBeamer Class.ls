property pUpdateInterval, pUpdateCounter, pAnimItemList, pAreaDiameter, pMiddlePoint

on define me, tdata
  pUpdateInterval = 2
  pAnimItemList = []
  if me.pXFactor = 32 then
    pAreaDiameter = 15
    pAnimItemList.add([#phase: random(pAreaDiameter * 1.5) - pAreaDiameter, #direction: 1, #speed: 2, #factor: me.getRandomAmplitudeFactor()])
    pAnimItemList.add([#phase: random(pAreaDiameter * 1.5) - pAreaDiameter, #direction: -1, #speed: 1, #factor: me.getRandomAmplitudeFactor()])
  else
    pAreaDiameter = 31
    pAnimItemList.add([#phase: random(pAreaDiameter * 1.5) - pAreaDiameter, #direction: 1, #speed: 2, #factor: me.getRandomAmplitudeFactor()])
    pAnimItemList.add([#phase: random(pAreaDiameter * 1.5) - pAreaDiameter, #direction: -1, #speed: 1, #factor: me.getRandomAmplitudeFactor()])
  end if
  pMiddlePoint = VOID
  return me.ancestor.define(tdata)
end

on update me
  me.ancestor.update()
  if me.pState > 1 then
    pUpdateCounter = pUpdateCounter + 1
    if pUpdateCounter < pUpdateInterval then
      return 1
    end if
    pUpdateCounter = 0
    if pMiddlePoint = VOID then
      pMiddlePoint = me.pSprList[2].loc + point(0, 0)
    end if
    tSpr = me.pSprList[3]
    tSpr.loc = me.getNewPoint(pAnimItemList[1]) + pMiddlePoint
    tSpr = me.pSprList[4]
    tSpr.loc = me.getNewPoint(pAnimItemList[2]) + pMiddlePoint
  end if
end

on getNewPoint me, tItem
  tPhase = tItem.getaProp(#phase)
  tDirection = tItem.getaProp(#direction)
  tSpeed = tItem.getaProp(#speed)
  tFactor = tItem.getaProp(#factor)
  if abs(tPhase + (tDirection * tSpeed)) >= pAreaDiameter then
    tItem.setaProp(#direction, -tDirection)
  end if
  tAmplitude = (pAreaDiameter - abs(tPhase)) * tFactor
  tLocY = tDirection * sin(abs(tPhase / 4.0)) * tAmplitude
  if tDirection > 0 then
    tLocY = tLocY - tAmplitude
  else
    tLocY = tLocY + tAmplitude
  end if
  tItem.setaProp(#phase, tPhase + (tDirection * tSpeed))
  if integer(tLocY) = 0 then
    tItem.setaProp(#factor, me.getRandomAmplitudeFactor())
  end if
  return point(tPhase, tLocY)
end

on getRandomAmplitudeFactor me
  return (random(30) / 100.0) + 0.14999999999999999
end
