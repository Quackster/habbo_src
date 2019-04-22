property pAnimThisUpdate, pSin, pSpriteList, pOrigLocs, pTileSprites, pWallLightCount, pWallLightValues, pWallLightSprites

on construct me 
  pSin = 0
  pSpriteList = []
  pOrigLocs = []
  pAnimThisUpdate = 0
  pWallLightCount = 60
  pWallLightSprites = []
  pWallLightValues = []
  pTileSprites = []
  return(1)
end

on deconstruct me 
  me.removeWallLights()
  return(removeUpdate(me.getID()))
end

on prepare me 
  return(receiveUpdate(me.getID()))
end

on update me 
  pAnimThisUpdate = not pAnimThisUpdate
  if not pAnimThisUpdate then
    return(1)
  end if
  pSin = pSin + 0.07
  if pSpriteList = [] then
    return(me.getSpriteList())
  end if
  me.rotateWallLights()
  me.blinkFloorLights()
  me.fullRotation(15, 15, 15, 15, point(-10, -10), point(-10, -10))
  return(1)
end

on fullRotation me, tX1, tY1, tX2, tY2, tOffset1, tOffset2 
  if tOffset1 = void() then
    tOffset1 = point(0, 0)
  end if
  if tOffset2 = void() then
    tOffset2 = point(0, 0)
  end if
  pSpriteList.getAt(3).loc = pOrigLocs.getAt(1) + tOffset1 + point(sin(pSin) * tX1, cos(pSin) * tY1)
  pSpriteList.getAt(6).loc = pOrigLocs.getAt(2) + tOffset2 + point(cos(pSin) * tX2, sin(pSin) * tY2)
  tLocs = [pSpriteList.getAt(3).loc + point(pSpriteList.getAt(3).width / 2 - 15, 0), pSpriteList.getAt(6).loc - point(pSpriteList.getAt(6).width / 2 - 10, 0)]
  pSpriteList.getAt(2).rect = rect(pSpriteList.getAt(2).getProp(#rect, 1), pSpriteList.getAt(2).getProp(#rect, 2), tLocs.getAt(1).getAt(1), tLocs.getAt(1).getAt(2))
  pSpriteList.getAt(5).rect = rect(tLocs.getAt(2).getAt(1), pSpriteList.getAt(5).getProp(#rect, 2), pSpriteList.getAt(5).getProp(#rect, 3), tLocs.getAt(2).getAt(2))
  return(1)
end

on getSpriteList me 
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= 2
    tSp1 = tObj.getSprById("disco_bulb_" & i)
    tSp2 = tObj.getSprById("disco_light_" & i)
    tSp3 = tObj.getSprById("disco_spot_" & i)
    if tSp1 < 1 or tSp2 < 1 or tSp3 < 1 then
      return(0)
    end if
    pSpriteList.add(tSp1)
    pSpriteList.add(tSp2)
    pSpriteList.add(tSp3)
    i = 1 + i
  end repeat
  pOrigLocs = [pSpriteList.getAt(3).loc, pSpriteList.getAt(6).loc]
  i = 1
  repeat while i <= pSpriteList.count
    removeEventBroker(pSpriteList.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  tColors = [rgb(30, 30, 115), rgb(20, 20, 105), rgb(30, 13, 110), rgb(30, 30, 120)]
  i = 1
  repeat while i <= 20
    tSp = tObj.getSprById("valo" & i)
    if tSp < 1 then
      pSpriteList = []
      return(0)
    end if
    pTileSprites.add(tSp)
    pTileSprites.getAt(i).color = tColors.getAt(random(tColors.count))
    pTileSprites.getAt(i).blend = 0
    i = 1 + i
  end repeat
  me.createWallLights()
  return(1)
end

on createWallLights me 
  i = 1
  repeat while i <= pWallLightCount
    pWallLightValues.setAt(i, [])
    pWallLightValues.getAt(i).setAt(1, random(155))
    pWallLightValues.getAt(i).setAt(2, random(100))
    tSpriteChannel = reserveSprite(me.getID())
    if tSpriteChannel = 0 then
      me.removeWallLights()
      return(1)
    end if
    pWallLightSprites.setAt(i, sprite(tSpriteChannel))
    pWallLightSprites.getAt(i).ink = 32
    pWallLightSprites.getAt(i).blend = random(70)
    pWallLightSprites.getAt(i).locH = 64 + random(608 - 65)
    pWallLightSprites.getAt(i).member = getMember("lightspot_1")
    i = 1 + i
  end repeat
  return(1)
end

on rotateWallLights me 
  i = 1
  repeat while i <= pWallLightSprites.count
    tDimValue = pWallLightValues.getAt(i).getAt(2)
    tDimValue = tDimValue + 0.19
    if tDimValue > 100 then
      tDimValue = 1
    end if
    pWallLightValues.getAt(i).setAt(2, tDimValue)
    tLocH = pWallLightSprites.getAt(i).locH
    tLocH = tLocH + 2
    if tLocH > 608 then
      tLocH = 65
      pWallLightSprites.getAt(i).flipH = 0
      pWallLightValues.getAt(i).setAt(1, random(155))
    end if
    if tLocH > 353 then
      pWallLightSprites.getAt(i).flipH = 1
      tLocV = 38 + tLocH - 353 * 0.5 + pWallLightValues.getAt(i).getAt(1)
    else
      tLocV = 38 + 353 - tLocH * 0.5 + pWallLightValues.getAt(i).getAt(1)
    end if
    pWallLightSprites.getAt(i).loc = point(tLocH, tLocV)
    pWallLightSprites.getAt(i).blend = max(0, sin(tDimValue) * 60)
    i = 1 + i
  end repeat
  return(1)
end

on removeWallLights me 
  repeat while pWallLightSprites <= undefined
    tWallSprite = getAt(undefined, undefined)
    if tWallSprite.ilk = #sprite then
      releaseSprite(tWallSprite.spriteNum)
    end if
    pWallLightSprites = []
  end repeat
  return(1)
end

on blinkFloorLights me 
  i = 1
  repeat while i <= 20
    tMultiplier = sin(pSin * 1.5 + i * 0.3)
    pTileSprites.getAt(i).blend = abs(tMultiplier * 100)
    i = 1 + i
  end repeat
  return(1)
end
