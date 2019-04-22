on construct(me)
  pID = void()
  pAvailable = 1
  pDrawProps = [#shapeType:#oval, #color:rgb("6DBBE2")]
  pColorList = [rgb("008C94"), rgb("008080"), rgb("00637B"), rgb("00737B"), rgb("007B84"), rgb("00848C"), rgb("6DBBE2")]
  pPointList = [point(34, 17), point(42, 21), point(50, 25), point(58, 29), point(66, 33), point(74, 37), point(82, 41)]
  pAnimFrame = 999
  pMaxFrame = pColorList.count
  pTargetPoint = point(0, 0)
  pLastPoint = point(0, 0)
  pTargetImg = void()
  return(1)
  exit
end

on define(me, tProps)
  pID = tProps.getAt(#id)
  pTargetImg = tProps.getAt(#buffer)
  return(1)
  exit
end

on getAvailableRipple(me)
  if pAvailable then
    return(pID)
  end if
  exit
end

on setTargetPoint(me, tTargetPoint)
  pAvailable = 0
  pAnimFrame = 1
  pTargetPoint = tTargetPoint
  exit
end

on update(me)
  if pAnimFrame < pMaxFrame then
    pTargetImg.draw(pLastPoint, pLastPoint + pPointList.getAt(pAnimFrame), pDrawProps)
    pAnimFrame = pAnimFrame + 1
    pTargetImg.draw(pTargetPoint, pTargetPoint + pPointList.getAt(pAnimFrame), [#shapeType:#oval, #color:pColorList.getAt(pAnimFrame)])
    pLastPoint = pTargetPoint
  else
    if pAnimFrame = pMaxFrame then
      pTargetImg.draw(pLastPoint, pLastPoint + pPointList.getAt(pAnimFrame), pDrawProps)
      pAvailable = 1
    end if
  end if
  exit
end