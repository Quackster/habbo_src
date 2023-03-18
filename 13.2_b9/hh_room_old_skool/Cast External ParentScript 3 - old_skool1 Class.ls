property pAnimThisUpdate, pSin, pSpriteList, pOrigLocs, pWallLightSprites, pWallLightValues, pWallLightCount, pTileSprites

on construct me
  pSin = 0.0
  pSpriteList = []
  pOrigLocs = []
  pAnimThisUpdate = 0
  pWallLightCount = 60
  pWallLightSprites = []
  pWallLightValues = []
  pTileSprites = []
  return 1
end

on deconstruct me
  me.removeWallLights()
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on update me
  pAnimThisUpdate = not pAnimThisUpdate
  if not pAnimThisUpdate then
    return 1
  end if
  pSin = pSin + 0.07000000000000001
  if pSpriteList = [] then
    return me.getSpriteList()
  end if
  me.rotateWallLights()
  me.blinkFloorLights()
  me.fullRotation(15, 15, 15, 15, point(-10, -10), point(-10, -10))
  return 1
end

on fullRotation me, tX1, tY1, tX2, tY2, tOffset1, tOffset2
  if tOffset1 = VOID then
    tOffset1 = point(0, 0)
  end if
  if tOffset2 = VOID then
    tOffset2 = point(0, 0)
  end if
  pSpriteList[3].loc = pOrigLocs[1] + tOffset1 + point(sin(pSin) * tX1, cos(pSin) * tY1)
  pSpriteList[6].loc = pOrigLocs[2] + tOffset2 + point(cos(pSin) * tX2, sin(pSin) * tY2)
  tLocs = [pSpriteList[3].loc + point((pSpriteList[3].width / 2.0) - 15, 0), pSpriteList[6].loc - point((pSpriteList[6].width / 2.0) - 10, 0)]
  pSpriteList[2].rect = rect(pSpriteList[2].rect[1], pSpriteList[2].rect[2], tLocs[1][1], tLocs[1][2])
  pSpriteList[5].rect = rect(tLocs[2][1], pSpriteList[5].rect[2], pSpriteList[5].rect[3], tLocs[2][2])
  return 1
end

on getSpriteList me
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return 0
  end if
  repeat with i = 1 to 2
    tSp1 = tObj.getSprById("disco_bulb_" & i)
    tSp2 = tObj.getSprById("disco_light_" & i)
    tSp3 = tObj.getSprById("disco_spot_" & i)
    if (tSp1 < 1) or (tSp2 < 1) or (tSp3 < 1) then
      return 0
    end if
    pSpriteList.add(tSp1)
    pSpriteList.add(tSp2)
    pSpriteList.add(tSp3)
  end repeat
  pOrigLocs = [pSpriteList[3].loc, pSpriteList[6].loc]
  repeat with i = 1 to pSpriteList.count
    removeEventBroker(pSpriteList[i].spriteNum)
  end repeat
  tColors = [rgb(30, 30, 115), rgb(20, 20, 105), rgb(30, 13, 110), rgb(30, 30, 120)]
  repeat with i = 1 to 20
    tSp = tObj.getSprById("valo" & i)
    if tSp < 1 then
      pSpriteList = []
      return 0
    end if
    pTileSprites.add(tSp)
    pTileSprites[i].color = tColors[random(tColors.count)]
    pTileSprites[i].blend = 0
  end repeat
  me.createWallLights()
  return 1
end

on createWallLights me
  repeat with i = 1 to pWallLightCount
    pWallLightValues[i] = []
    pWallLightValues[i][1] = random(155)
    pWallLightValues[i][2] = random(100)
    tSpriteChannel = reserveSprite(me.getID())
    if tSpriteChannel = 0 then
      me.removeWallLights()
      return 1
    end if
    pWallLightSprites[i] = sprite(tSpriteChannel)
    pWallLightSprites[i].ink = 32
    pWallLightSprites[i].blend = random(70)
    pWallLightSprites[i].locH = 64 + random(608 - 65)
    pWallLightSprites[i].member = getMember("lightspot_1")
  end repeat
  return 1
end

on rotateWallLights me
  repeat with i = 1 to pWallLightSprites.count
    tDimValue = pWallLightValues[i][2]
    tDimValue = tDimValue + 0.19
    if tDimValue > 100 then
      tDimValue = 1
    end if
    pWallLightValues[i][2] = tDimValue
    tLocH = pWallLightSprites[i].locH
    tLocH = tLocH + 2
    if tLocH > 608 then
      tLocH = 65
      pWallLightSprites[i].flipH = 0
      pWallLightValues[i][1] = random(155)
    end if
    if tLocH > 353 then
      pWallLightSprites[i].flipH = 1
      tLocV = 38 + ((tLocH - 353) * 0.5) + pWallLightValues[i][1]
    else
      tLocV = 38 + ((353 - tLocH) * 0.5) + pWallLightValues[i][1]
    end if
    pWallLightSprites[i].loc = point(tLocH, tLocV)
    pWallLightSprites[i].blend = max(0, sin(tDimValue) * 60)
  end repeat
  return 1
end

on removeWallLights me
  repeat with tWallSprite in pWallLightSprites
    if tWallSprite.ilk = #sprite then
      releaseSprite(tWallSprite.spriteNum)
    end if
    pWallLightSprites = []
  end repeat
  return 1
end

on blinkFloorLights me
  repeat with i = 1 to 20
    tMultiplier = sin((pSin * 1.5) + (i * 0.29999999999999999))
    pTileSprites[i].blend = abs(tMultiplier * 100)
  end repeat
  return 1
end
