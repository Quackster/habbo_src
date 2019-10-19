property pFrameAmount, pTotalAnimTime, pPhaseAmount, pSpriteData, pHostSpriteData, pMemberPrefix, pCurrentPhase, pCurrentFrame, pRunAnimation, pAnimStartTime, pTimePerPhase, pScreenStartLoc

on construct me 
  pTotalAnimTime = 700
  pPhaseAmount = 3
  pFrameAmount = 2
  pCurrentPhase = 1
  pCurrentFrame = random(pFrameAmount)
  pTimePerPhase = (pTotalAnimTime / pPhaseAmount)
  pMemberPrefix = "effect_cloud_"
  pSpriteData = []
  pRunAnimation = 0
  pHostSpriteData = [:]
end

on deconstruct me 
  removeUpdate(me.getID())
  repeat while pSpriteData <= undefined
    tSpriteData = getAt(undefined, undefined)
    releaseSprite(tSpriteData.getAt(#sprite).spriteNum)
  end repeat
  if pHostSpriteData.getAt(#sprite) <> void() then
    pHostSpriteData.getAt(#sprite).color = pHostSpriteData.getAt(#previousfcolor)
    pHostSpriteData.getAt(#sprite).ink = pHostSpriteData.getAt(#previousink)
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
    return(0)
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
  pHostSpriteData.setAt(#sprite, tsprite)
  pHostSpriteData.setAt(#previousink, tsprite.ink)
  pHostSpriteData.setAt(#previousfcolor, color(#rgb, 0, 0, 0))
  tsprite.color = color(#rgb, 150, 150, 150)
  tsprite.ink = 41
  me.define(tloc, tlocz, tSize)
end

on define me, tloc, tlocz, tSize 
  if voidp(tloc) then
    return(0)
  end if
  if ilk(tloc) <> #point then
    return(0)
  end if
  if voidp(tlocz) then
    return(0)
  end if
  if voidp(tSize) then
    tSize = #large
  end if
  pScreenStartLoc = tloc
  tSpriteCount = 3
  tAngleSectorSize = ((2 * pi()) / tSpriteCount)
  tMaxItemTravelDist = 25
  tLocZVariance = 200
  if tSize = #small then
    tMaxItemTravelDist = (tMaxItemTravelDist / 2)
    pMemberPrefix = pMemberPrefix & "small_"
  end if
  i = 1
  repeat while i <= tSpriteCount
    tsprite = sprite(reserveSprite(me.getID()))
    tDirAngle = (i - 1 * tAngleSectorSize) + random(tAngleSectorSize)
    tMaxTravelX = (cos(tDirAngle) * tMaxItemTravelDist)
    tMaxTravelY = (sin(tDirAngle) * tMaxItemTravelDist)
    tPixelsPerMillisecX = (float(tMaxTravelX) / pTotalAnimTime)
    tPixelsPerMillisecY = (float(tMaxTravelY) / pTotalAnimTime)
    tsprite.flipH = random(1)
    tsprite.flipV = random(1)
    tdata = [:]
    tdata.setAt(#IncrementX, tPixelsPerMillisecX)
    tdata.setAt(#IncrementY, tPixelsPerMillisecY)
    tdata.setAt(#sprite, tsprite)
    pSpriteData.add(tdata)
    tsprite.member = member(getmemnum(pMemberPrefix & pCurrentPhase & "_" & pCurrentFrame))
    tsprite.locZ = tlocz + random(tLocZVariance) - (tLocZVariance / 2)
    tsprite.ink = 8
    i = 1 + i
  end repeat
  pAnimStartTime = the milliSeconds
  pRunAnimation = 1
  receiveUpdate(me.getID())
end

on update me 
  if not pRunAnimation then
    return(0)
  end if
  tMoveTime = the milliSeconds - pAnimStartTime
  if tMoveTime > pTotalAnimTime then
    pRunAnimation = 0
    me.removeFromObjectManager()
    return(0)
  end if
  tUpdatePhase = 0
  tCurrentPhase = integer((tMoveTime / pTimePerPhase)) + 1
  if tCurrentPhase <> pCurrentPhase then
    tUpdatePhase = 1
    pCurrentPhase = tCurrentPhase
  end if
  repeat while pSpriteData <= undefined
    tSpriteData = getAt(undefined, undefined)
    tRandomUpdateTrigger = 3
    if random(tRandomUpdateTrigger) > tRandomUpdateTrigger - 1 or tUpdatePhase then
      tNewFrame = random(pFrameAmount)
      tSpriteData.getAt(#sprite).flipH = random(1)
      tSpriteData.getAt(#sprite).flipV = random(1)
      tSpriteData.getAt(#sprite).member = member(getmemnum(pMemberPrefix & pCurrentPhase & "_" & tNewFrame))
      tSpriteData.setAt(#IncrementX, (tSpriteData.getAt(#IncrementX) * 1.05))
      tSpriteData.setAt(#IncrementY, (tSpriteData.getAt(#IncrementY) * 1.05))
    end if
    tLocX = integer((tMoveTime * tSpriteData.getAt(#IncrementX)) + pScreenStartLoc.locH)
    tLocY = integer((tMoveTime * tSpriteData.getAt(#IncrementY)) + pScreenStartLoc.locV)
    tSpriteData.getAt(#sprite).loc = point(tLocX, tLocY)
  end repeat
  if tMoveTime > ((3 / 4) * pTotalAnimTime) then
    me.removeFromObjectManager()
  else
    if tMoveTime > ((2 / 4) * pTotalAnimTime) and pHostSpriteData.getAt(#sprite) <> void() then
      pHostSpriteData.getAt(#sprite).color = color(#rgb, 50, 50, 50)
    else
      if tMoveTime > ((1 / 4) * pTotalAnimTime) and pHostSpriteData.getAt(#sprite) <> void() then
        pHostSpriteData.getAt(#sprite).color = color(#rgb, 150, 150, 150)
      else
        pHostSpriteData.getAt(#sprite).color = color(#rgb, 255, 255, 255)
      end if
    end if
  end if
end
