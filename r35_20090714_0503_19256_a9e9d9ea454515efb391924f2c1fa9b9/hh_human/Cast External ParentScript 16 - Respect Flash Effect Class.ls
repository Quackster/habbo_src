property pTotalAnimTime, pAnimStartTime, pScreenStartLoc, pSpriteData, pItemTravelDist, pMemberPrefix, pTimePerPhase, pFrameAmount, pPhaseAmount, pCurrentPhase, pCurrentFrame, pRunAnimation, pHostSpriteData

on construct me
  pTotalAnimTime = 700
  pPhaseAmount = 3
  pFrameAmount = 2
  pCurrentPhase = 1
  pCurrentFrame = random(pFrameAmount)
  pTimePerPhase = pTotalAnimTime / pPhaseAmount
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

on defineWithSprite me, tsprite, tSize
  if ilk(tsprite) <> #sprite then
    return 0
  end if
  if voidp(tSize) then
    tSize = #large
  end if
  tWidth = tsprite.width
  tHeight = tsprite.height
  tloc = point(tsprite.locH + (tWidth / 2), tsprite.locV - (tHeight / 2))
  tlocz = tsprite.locZ
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
  if tMoveTime > (3.0 / 4 * pTotalAnimTime) then
    me.removeFromObjectManager()
  else
    if (tMoveTime > (2.0 / 4 * pTotalAnimTime)) and (pHostSpriteData[#sprite] <> VOID) then
      pHostSpriteData[#sprite].color = color(#rgb, 62, 51, 15)
    else
      if (tMoveTime > (1.0 / 4 * pTotalAnimTime)) and (pHostSpriteData[#sprite] <> VOID) then
        pHostSpriteData[#sprite].color = color(#rgb, 124, 102, 29)
      else
        pHostSpriteData[#sprite].color = color(#rgb, 247, 204, 59)
      end if
    end if
  end if
end
