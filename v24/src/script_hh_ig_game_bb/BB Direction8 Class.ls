property pVectorX, pVectorY, pDirection

on defineLine me, tStartX, tStartY, tTargetX, tTargetY 
  pVectorX = tTargetX - tStartX
  pVectorY = tTargetY - tStartY
  if pVectorX <> 0 then
    pVectorX = (pVectorX / abs(pVectorX))
  end if
  if pVectorY <> 0 then
    pVectorY = (pVectorY / abs(pVectorY))
  end if
  pDirection = me.getAngleFromComponents(pVectorX, pVectorY)
  return(1)
end

on defineDirection me, tDirection 
  pDirection = tDirection
  tVector = me.getComponentsFromAngle(tDirection)
  pVectorX = tVector.getAt(1)
  pVectorY = tVector.getAt(2)
  return(1)
end

on getDirection me 
  return(pDirection)
end

on getUnitVectorXComponent me 
  return(pVectorX)
end

on getUnitVectorYComponent me 
  return(pVectorY)
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
  return(me.defineDirection(tDirection))
end

on getAngleFromComponents me, tVectorX, tVectorY 
  if 1 = tVectorX = -1 then
    if 1 = tVectorY = -1 then
      return(7)
    else
      if 1 = tVectorY = 0 then
        return(6)
      else
        if 1 = tVectorY = 1 then
          return(5)
        end if
      end if
    end if
  else
    if 1 = tVectorX = 0 then
      if 1 = tVectorY = -1 then
        return(0)
      else
        if 1 = tVectorY = 0 then
          return(-1)
        else
          if 1 = tVectorY = 1 then
            return(4)
          end if
        end if
      end if
    else
      if 1 = tVectorX = 1 then
        if 1 = tVectorY = -1 then
          return(1)
        else
          if 1 = tVectorY = 0 then
            return(2)
          else
            if 1 = tVectorY = 1 then
              return(3)
            end if
          end if
        end if
      end if
    end if
  end if
end

on getComponentsFromAngle me, tAngle 
  if tAngle = 0 then
    return([0, -1])
  else
    if tAngle = 1 then
      return([1, -1])
    else
      if tAngle = 2 then
        return([1, 0])
      else
        if tAngle = 3 then
          return([1, 1])
        else
          if tAngle = 4 then
            return([0, 1])
          else
            if tAngle = 5 then
              return([-1, 1])
            else
              if tAngle = 6 then
                return([-1, 0])
              else
                if tAngle = 7 then
                  return([-1, -1])
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
