property pSprite, pOffset, pMaxOffset, pPhase, pSpeed, pLocOrig, pCreases, pUseCreases, pBinMember, pPaletteMember

on define me, tsprite
  pMaxOffset = 165
  pSpeed = 10
  pUseCreases = 1
  pCreases = [1, 131, 209, 450, 720]
  pOffset = 0
  pPhase = 0
  tOrigMember = tsprite.member
  pSprite = tsprite
  pLocOrig = pSprite.loc
  tOrigWidth = tsprite.width
  tOrigHeight = tsprite.height
  tOrigLoc = tsprite.loc
  tLeft = tOrigLoc[1] - (tOrigWidth / 2)
  tRight = tOrigLoc[1] + (tOrigWidth / 2)
  tTop = tOrigLoc[2] - (tOrigHeight / 2)
  tBottom = tOrigLoc[2] + (tOrigHeight / 2)
  tOrigRect = rect(tLeft, tTop, tRight, tBottom)
  if memberExists("starlounge_gradient") then
    pBinMember = member(getmemnum("starlounge_gradient"))
  else
    pBinMember = member(createMember("starlounge_gradient", #bitmap))
  end if
  tImage = tOrigMember.image.duplicate()
  if ilk(tImage.paletteRef) <> #symbol then
    if memberExists("starlounge_gradient_palette") then
      pPaletteMember = member(getmemnum("starlounge_gradient_palette"))
    else
      pPaletteMember = member(createMember("starlounge_gradient_palette", #palette))
    end if
    pPaletteMember.media = tImage.paletteRef.media
  end if
  tRect = tOrigRect
  if pUseCreases then
    tImage = me.makeCreases(tRect, tImage, pCreases, tImage.paletteRef)
  end if
  if tImage.paletteRef.ilk <> #symbol then
    tImage.paletteRef = pPaletteMember
  end if
  pBinMember.image = tImage
  pBinMember.regPoint = point(0, 0)
  pSprite.member = pBinMember
  return 1
end

on update me
  pPhase = (pPhase + pSpeed) mod 3600
  pOffset = (pMaxOffset / 2 * sin(pPhase * PI / 1800)) + (pMaxOffset / 2)
  pSprite.locV = pLocOrig[2] - pOffset
  return 1
end

on makeCreases me, tRect, tSourceImage, tCreases, tPalette
  tImageNew = image(tRect.width, tRect.height, 8, tPalette)
  tImageNew.copyPixels(tSourceImage, tImageNew.rect, tSourceImage.rect)
  tImageCreased = image(tImageNew.width, tImageNew.height, 8, tPalette)
  tTop = 1
  tdir = 1
  repeat with i = 1 to tCreases.count - 1
    tPoint1 = point(tCreases[i], tTop)
    tTop = tTop - (tdir * (tCreases[i + 1] - tCreases[i]) / 2)
    tdir = -tdir
    tPoint2 = point(tCreases[i + 1], tTop)
    tPoint3 = tPoint2 + [0, tImageNew.height]
    tPoint4 = tPoint1 + [0, tImageNew.height]
    tQuad = [tPoint1, tPoint2, tPoint3, tPoint4]
    tRectSource = rect(tCreases[i], 1, tCreases[i + 1], tImageNew.height)
    tImageCreased.copyPixels(tImageNew, tQuad, tRectSource)
  end repeat
  return tImageCreased
end

on cleanUp me
  if not voidp(pBinMember) then
    removeMember(pBinMember.name)
  end if
  if not voidp(pPaletteMember) then
    removeMember(pPaletteMember.name)
  end if
end
