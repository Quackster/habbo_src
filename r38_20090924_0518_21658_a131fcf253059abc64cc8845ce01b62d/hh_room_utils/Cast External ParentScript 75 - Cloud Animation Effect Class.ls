property pTotalAnimTime, pAnimStartTime, pScreenStartLoc, pSpriteData, pItemTravelDist, pMemberPrefix, pTimePerPhase, pFrameAmount, pPhaseAmount, pCurrentPhase, pCurrentFrame, pRunAnimation, pHostSpriteData

on construct me
  pTotalAnimTime = 700
  pPhaseAmount = 3
  pFrameAmount = 2
  pCurrentPhase = 1
  pCurrentFrame = random(pFrameAmount)
  pTimePerPhase = pTotalAnimTime / pPhaseAmount
  pMemberPrefix = "effect_cloud_"
  pSpriteData = []
  pRunAnimation = 0
  pHostSpriteData = [:]
end

on deconstruct me
  removeUpdate(me.getID())
  repeat with tSpriteData in pSpriteData
    releaseSprite(tSpriteData[#sprite].spriteNum)
  end repeat
  if pHostSpriteData[#sprite] <> VOID then
    pHostSpriteData[#sprite].color = pHostSpriteData[#previousfcolor]
    pHostSpriteData[#sprite].ink = pHostSpriteData[#previousink]
  end if
  pSpriteData = []
  pHostSpriteData = [:]
end

on removeFromObjectManager me
  if objectExists(me.getID()) then
    removeObject(me.getID())
  end if
end

on defineWithSprite me, tsprite, tSize, tLocOffset, tLocZOffset
  if ilk(tsprite) <> #sprite then
    return 0
  end if
  if voidp(tSize) then
    tSize = #large
  end if
  if voidp(tLocOffset) then
    tLocOffset = point(0, 0)
  end if
  if voidp(tLocZOffset) then
    tLocZOffset = 0
  end if
  tWidth = tsprite.width
  tHeight = tsprite.height
  tloc = point(tsprite.locH + (tWidth / 2), tsprite.locV - (tHeight / 2)) + tLocOffset
  tlocz = tsprite.locZ + tLocZOffset
  tRect = tsprite.rect
  pHostSpriteData[#sprite] = tsprite
  pHostSpriteData[#previousink] = tsprite.ink
  pHostSpriteData[#previousfcolor] = color(#rgb, 0, 0, 0)
  tsprite.color = color(#rgb, 150, 150, 150)
  tsprite.ink = 41
  me.define(tloc, tlocz, tSize)
end

on define me, tloc, tlocz, tSize
  if voidp(tloc) then
    return 0
  end if
  if ilk(tloc) <> #point then
    return 0
  end if
  if voidp(tlocz) then
    return 0
  end if
  if voidp(tSize) then
    tSize = #large
  end if
  pScreenStartLoc = tloc
  tSpriteCount = 3
  tAngleSectorSize = 2 * PI / tSpriteCount
  tMaxItemTravelDist = 25
  tLocZVariance = 200
  if tSize = #small then
    tMaxItemTravelDist = tMaxItemTravelDist / 2
    pMemberPrefix = pMemberPrefix & "small_"
  end if
  repeat with i = 1 to tSpriteCount
    tsprite = sprite(reserveSprite(me.getID()))
    tDirAngle = ((i - 1) * tAngleSectorSize) + random(tAngleSectorSize)
    tMaxTravelX = cos(tDirAngle) * tMaxItemTravelDist
    tMaxTravelY = sin(tDirAngle) * tMaxItemTravelDist
    tPixelsPerMillisecX = float(tMaxTravelX) / pTotalAnimTime
    tPixelsPerMillisecY = float(tMaxTravelY) / pTotalAnimTime
    tsprite.flipH = random(1)
    tsprite.flipV = random(1)
    tdata = [:]
    tdata[#IncrementX] = tPixelsPerMillisecX
    tdata[#IncrementY] = tPixelsPerMillisecY
    tdata[#sprite] = tsprite
    pSpriteData.add(tdata)
    tsprite.member = member(getmemnum(pMemberPrefix & pCurrentPhase & "_" & pCurrentFrame))
    tsprite.locZ = tlocz + random(tLocZVariance) - (tLocZVariance / 2)
    tsprite.ink = 8
  end repeat
  pAnimStartTime = the milliSeconds
  pRunAnimation = 1
  receiveUpdate(me.getID())
end

on update me
  if not pRunAnimation then
    return 0
  end if
  tMoveTime = the milliSeconds - pAnimStartTime
  if tMoveTime > pTotalAnimTime then
    pRunAnimation = 0
    me.removeFromObjectManager()
    return 0
  end if
  tUpdatePhase = 0
  tCurrentPhase = integer(tMoveTime / pTimePerPhase) + 1
  if tCurrentPhase <> pCurrentPhase then
    tUpdatePhase = 1
    pCurrentPhase = tCurrentPhase
  end if
  repeat with tSpriteData in pSpriteData
    tRandomUpdateTrigger = 3
    if (random(tRandomUpdateTrigger) > (tRandomUpdateTrigger - 1)) or tUpdatePhase then
      tNewFrame = random(pFrameAmount)
      tSpriteData[#sprite].flipH = random(1)
      tSpriteData[#sprite].flipV = random(1)
      tSpriteData[#sprite].member = member(getmemnum(pMemberPrefix & pCurrentPhase & "_" & tNewFrame))
      tSpriteData[#IncrementX] = tSpriteData[#IncrementX] * 1.05000000000000004
      tSpriteData[#IncrementY] = tSpriteData[#IncrementY] * 1.05000000000000004
    end if
    tLocX = integer((tMoveTime * tSpriteData[#IncrementX]) + pScreenStartLoc.locH)
    tLocY = integer((tMoveTime * tSpriteData[#IncrementY]) + pScreenStartLoc.locV)
    tSpriteData[#sprite].loc = point(tLocX, tLocY)
  end repeat
  if tMoveTime > (3.0 / 4 * pTotalAnimTime) then
    me.removeFromObjectManager()
  else
    if (tMoveTime > (2.0 / 4 * pTotalAnimTime)) and (pHostSpriteData[#sprite] <> VOID) then
      pHostSpriteData[#sprite].color = color(#rgb, 50, 50, 50)
    else
      if (tMoveTime > (1.0 / 4 * pTotalAnimTime)) and (pHostSpriteData[#sprite] <> VOID) then
        pHostSpriteData[#sprite].color = color(#rgb, 150, 150, 150)
      else
        pHostSpriteData[#sprite].color = color(#rgb, 255, 255, 255)
      end if
    end if
  end if
end
