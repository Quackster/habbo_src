property pGeometry, pSprite, pLastLoc, pLastCrd

on construct me
  pGeometry = VOID
  pSprite = VOID
  pLastLoc = point(0, 0)
  pLastCrd = VOID
  return 1
end

on deconstruct me
  pGeometry = VOID
  if ilk(pSprite) = #sprite then
    pSprite.visible = 0
  end if
  pSprite = VOID
  pLastLoc = VOID
  return 1
end

on define me, tdata
  pGeometry = getObject(tdata[#geometry])
  pSprite = tdata[#sprite]
  return 1
end

on update me
  if the mouseLoc = pLastLoc then
    return 
  end if
  pLastLoc = the mouseLoc
  tCrd = pGeometry.getWorldCoordinate(the mouseH, the mouseV)
  if the optionDown then
    if pLastCrd <> tCrd then
      put tCrd
    end if
  end if
  pLastCrd = tCrd
  if not tCrd then
    pSprite.locH = -10000
    pSprite.locV = -10000
  else
    tScreenCoord = pGeometry.getScreenCoordinate(tCrd[1], tCrd[2], tCrd[3])
    pSprite.locH = tScreenCoord[1]
    pSprite.locV = tScreenCoord[2]
  end if
end

on redirectEvent me, tEvent, tSprID, tParam
  pSprite.visible = 0
  call(tEvent, [sprite(the rollover)])
  pSprite.visible = 1
end
