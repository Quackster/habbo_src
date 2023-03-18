property pVectorX, pVectorY, pDirection

on defineLine me, tStartX, tStartY, tTargetX, tTargetY
  pVectorX = tTargetX - tStartX
  pVectorY = tTargetY - tStartY
  if pVectorX <> 0 then
    pVectorX = pVectorX / abs(pVectorX)
  end if
  if pVectorY <> 0 then
    pVectorY = pVectorY / abs(pVectorY)
  end if
  pDirection = me.getAngleFromComponents(pVectorX, pVectorY)
  return 1
end

on defineDirection me, tDirection
  pDirection = tDirection
  tVector = me.getComponentsFromAngle(tDirection)
  pVectorX = tVector[1]
  pVectorY = tVector[2]
  return 1
end

on getDirection me
  return pDirection
end

on getUnitVectorXComponent me
  return pVectorX
end

on getUnitVectorYComponent me
  return pVectorY
end

on rotateDirection45Degrees me, tClockwise
  if tClockwise then
    tDirection = pDirection + 1
    if tDirection = 8 then
      tDirection = 0
    end if
  else
    tDirection = pDirection - 1
    if tDirection = -1 then
      tDirection = 7
    end if
  end if
  return me.defineDirection(tDirection)
end

on getAngleFromComponents me, tVectorX, tVectorY
  case 1 of
    (tVectorX = -1):
      case 1 of
        (tVectorY = -1):
          return 7
        (tVectorY = 0):
          return 6
        (tVectorY = 1):
          return 5
      end case
    (tVectorX = 0):
      case 1 of
        (tVectorY = -1):
          return 0
        (tVectorY = 0):
          return -1
        (tVectorY = 1):
          return 4
      end case
    (tVectorX = 1):
      case 1 of
        (tVectorY = -1):
          return 1
        (tVectorY = 0):
          return 2
        (tVectorY = 1):
          return 3
      end case
  end case
end

on getComponentsFromAngle me, tAngle
  case tAngle of
    0:
      return [0, -1]
    1:
      return [1, -1]
    2:
      return [1, 0]
    3:
      return [1, 1]
    4:
      return [0, 1]
    5:
      return [-1, 1]
    6:
      return [-1, 0]
    7:
      return [-1, -1]
  end case
end
