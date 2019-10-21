property pColorList, pAvailable, pID, pAnimFrame, pMaxFrame, pTargetImg, pLastPoint, pPointList, pDrawProps, pTargetPoint

on construct me 
  pID = void()
  pAvailable = 1
  pDrawProps = [#shapeType:#oval, #color:rgb("009C9C")]
  pColorList = [rgb("008C94"), rgb("008080"), rgb("00637B"), rgb("00737B"), rgb("007B84"), rgb("00848C"), rgb("008C94")]
  pPointList = [point(34, 17), point(42, 21), point(50, 25), point(58, 29), point(66, 33), point(74, 37), point(82, 41)]
  pAnimFrame = 999
  pMaxFrame = pColorList.count
  pTargetPoint = point(0, 0)
  pLastPoint = point(0, 0)
  pTargetImg = void()
  return TRUE
end

on define me, tProps 
  pID = tProps.getAt(#id)
  pTargetImg = tProps.getAt(#buffer)
  return TRUE
end

on getAvailableRipple me 
  if pAvailable then
    return(pID)
  end if
end

on setTargetPoint me, tTargetPoint 
  pAvailable = 0
  pAnimFrame = 1
  pTargetPoint = tTargetPoint
end

on update me 
  if pAnimFrame < pMaxFrame then
    pTargetImg.draw(pLastPoint, (pLastPoint + pPointList.getAt(pAnimFrame)), pDrawProps)
    pAnimFrame = (pAnimFrame + 1)
    pTargetImg.draw(pTargetPoint, (pTargetPoint + pPointList.getAt(pAnimFrame)), [#shapeType:#oval, #color:pColorList.getAt(pAnimFrame)])
    pLastPoint = pTargetPoint
  else
    if (pAnimFrame = pMaxFrame) then
      pTargetImg.draw(pLastPoint, (pLastPoint + pPointList.getAt(pAnimFrame)), pDrawProps)
      pAvailable = 1
    end if
  end if
end
