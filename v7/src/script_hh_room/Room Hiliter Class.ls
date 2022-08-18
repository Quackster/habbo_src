property pLastLoc, pGeometry, pLastCrd, pSprite

on construct me 
  pGeometry = void()
  pSprite = void()
  pLastLoc = point(0, 0)
  pLastCrd = void()
  return TRUE
end

on deconstruct me 
  pGeometry = void()
  pSprite = void()
  pLastLoc = void()
  return TRUE
end

on define me, tdata 
  pGeometry = getObject(tdata.getAt(#geometry))
  pSprite = tdata.getAt(#sprite)
  return TRUE
end

on update me 
  if (the mouseLoc = pLastLoc) then
    return()
  end if
  pLastLoc = the mouseLoc
  tCrd = pGeometry.getWorldCoordinate(the mouseH, the mouseV)
  if the optionDown then
    if pLastCrd <> tCrd then
      put(tCrd)
    end if
  end if
  pLastCrd = tCrd
  if not tCrd then
    pSprite.locH = -10000
    pSprite.locV = -10000
  else
    tScreenCoord = pGeometry.getScreenCoordinate(tCrd.getAt(1), tCrd.getAt(2), tCrd.getAt(3))
    pSprite.locH = tScreenCoord.getAt(1)
    pSprite.locV = tScreenCoord.getAt(2)
  end if
end

on redirectEvent me, tEvent, tSprID, tParam 
  pSprite.visible = 0
  call(tEvent, [sprite(the rollover)])
  pSprite.visible = 1
end
