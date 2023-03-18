property pVelocityTable, pComponentToAngle

on direction360to8 me, tValue
  return me.validateDirection8Value((me.validateDirection360Value(tValue - 22) / 45) + 1)
end

on validateDirection360Value me, tValue
  if tValue > 359 then
    tValue = tValue mod 360
  else
    if tValue < 0 then
      tValue = 360 + (tValue mod 360)
    end if
  end if
  return integer(tValue)
end

on validateDirection8Value me, tValue
  if tValue > 7 then
    tValue = tValue mod 8
  else
    if tValue < 0 then
      tValue = (8 + (tValue mod 8)) mod 8
    end if
  end if
  return integer(tValue)
end

on rotateDirection45DegreesCW me, tValue
  return me.validateDirection360Value(tValue + 45)
end

on rotateDirection45DegreesCCW me, tValue
  return me.validateDirection360Value(tValue - 45)
end

on getAngleFromComponents me, tX, tY
  if pComponentToAngle = VOID then
    pComponentToAngle = createObject(#temp, getClassVariable("gamesystem.componenttoangle.class"))
    if not objectp(pComponentToAngle) then
      return error(me, "Cannot create pComponentToAngle")
    end if
  end if
  return me.validateDirection360Value(pComponentToAngle.getAngleFromComponents(tX, tY))
end

on GetVelocityTable me
  if pVelocityTable = VOID then
    pVelocityTable = createObject(#temp, getClassVariable("gamesystem.velocitytable.class"))
    if not objectp(pVelocityTable) then
      return error(me, "Cannot create pVelocityTable")
    end if
  end if
  return pVelocityTable
end
