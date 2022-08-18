property pSprite, pOffset, pMaxOffset, pPhase, pSpeed, pLocOrig, pCreases, pUseCreases, pBinMember, pPaletteMember

on define me, tsprite
  pMaxOffset = 300
  pSpeed = 10
  pUseCreases = 1
  pCreases = [1, 131, 209, 450, 720]
  pOffset = 0
  pPhase = 0
  tOrigMember = tsprite.member
  pSprite = tsprite
  if memberExists("starlounge_gradient") then
    pBinMember = member(getmemnum("starlounge_gradient"))
  else
    pBinMember = member(createMember("starlounge_gradient", #bitmap))
  end if
  tImage = tOrigMember.image.duplicate()
  if (ilk(tImage.paletteRef) <> #symbol) then
    if memberExists("starlounge_gradient_palette") then
      pPaletteMember = member(getmemnum("starlounge_gradient_palette"))
    else
      pPaletteMember = member(createMember("starlounge_gradient_palette", #palette))
    end if
    pPaletteMember.media = tImage.paletteRef.media
  end if
  if pUseCreases then
    tImage = me.makeCreases(tImage, pCreases, tImage.paletteRef)
  end if
  if (tImage.paletteRef.ilk <> #symbol) then
    tImage.paletteRef = pPaletteMember
  end if
  pBinMember.image = tImage
  pSprite.member = pBinMember
  tWidth = the stage.rect.width
  tHeight = the stage.rect.height
  pSprite.rect = rect(0, 0, tWidth, tHeight)
  pLocOrig = pSprite.loc
  return 1
end

on update me
  pPhase = ((pPhase + pSpeed) mod 3600)
  pOffset = (((pMaxOffset / 2) * sin(((pPhase * PI) / 1800))) + (pMaxOffset / 2))
  pSprite.loc = (pLocOrig - [0, pOffset])
  return 1
end

on makeCreases me, tSourceImage, tCreases, tPalette
  tImageStage = image(the stage.rect.width, the stage.rect.height, 8, tPalette)
  tImageStage.copyPixels(tSourceImage, tImageStage.rect, tSourceImage.rect)
  tImageCreased = image(tImageStage.width, tImageStage.height, 8, tPalette)
  tTop = 1
  tdir = 1
  repeat with i = 1 to (tCreases.count - 1)
    tPoint1 = point(tCreases[i], tTop)
    tTop = (tTop - ((tdir * (tCreases[(i + 1)] - tCreases[i])) / 2))
    tdir = -tdir
    tPoint2 = point(tCreases[(i + 1)], tTop)
    tPoint3 = (tPoint2 + [0, tImageStage.height])
    tPoint4 = (tPoint1 + [0, tImageStage.height])
    tQuad = [tPoint1, tPoint2, tPoint3, tPoint4]
    tRectSource = rect(tCreases[i], 1, tCreases[(i + 1)], tImageStage.height)
    tImageCreased.copyPixels(tImageStage, tQuad, tRectSource)
  end repeat
  return tImageCreased
end

on cleanup me
  if not voidp(pBinMember) then
    removeMember(pBinMember.name)
  end if
  if not voidp(pPaletteMember) then
    removeMember(pPaletteMember.name)
  end if
end
