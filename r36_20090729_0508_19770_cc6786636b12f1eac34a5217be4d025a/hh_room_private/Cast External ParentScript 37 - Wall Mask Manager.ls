property pMask, pMaskImage, pMaskList, pREquiresUpdate

on construct me
  pMaskList = [:]
  me.initMask()
  return 1
end

on deconstruct me
  return 1
end

on requiresUpdate me
  return pREquiresUpdate
end

on getMask me
  if pREquiresUpdate then
    me.renderMask()
  end if
  pREquiresUpdate = 0
  return pMask
end

on insertWallMaskItem me, tID, tClassID, tloc, tdir, tSize
  tMaskProps = [:]
  tMaskProps.setaProp(#id, tID)
  tMaskProps.setaProp(#class, tClassID)
  tMaskProps.setaProp(#loc, tloc)
  tMaskProps.setaProp(#Dir, tdir)
  tMaskProps.setaProp(#size, tSize)
  pMaskList.setaProp(tID, tMaskProps)
  pREquiresUpdate = 1
end

on removeWallMaskItem me, tID
  pMaskList.deleteProp(tID)
  pREquiresUpdate = 1
end

on getItemCount me
  return pMaskList.count
end

on initMask me
  tWidth = (the stage).rect.width
  tHeight = (the stage).rect.height
  pMaskImage = image(tWidth, tHeight, 8)
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  pIsChanged = 1
end

on renderMask me
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  repeat with tMask in pMaskList
    tloc = tMask[#loc]
    tClass = tMask[#class]
    tdir = tMask[#Dir]
    tSize = tMask[#size]
    tNameTemplate = getVariable("mask.membername.template")
    tMemberName = replaceChunks(tNameTemplate, "%class%", tClass)
    tMemberName = replaceChunks(tMemberName, "%dir%", tdir)
    if tSize = 32 then
      tMemberName = "s_" & tMemberName
    end if
    if not memberExists(tMemberName) then
      next repeat
    end if
    tMemNum = getmemnum(tMemberName)
    tmember = member(abs(tMemNum))
    tMaskImage = tmember.image
    tRegPoint = tmember.regPoint
    if tdir = "rightwall" then
      tRegPoint = point(tMaskImage.width - tRegPoint[1], tRegPoint[2])
    end if
    tloc = tloc - tRegPoint
    tBottomRight = tloc + point(tMaskImage.width, tMaskImage.height)
    if tMemNum > 0 then
      tQuad = [tloc, point(tBottomRight[1], tloc[2]), tBottomRight, point(tloc[1], tBottomRight[2])]
    else
      tQuad = [point(tBottomRight[1], tloc[2]), tloc, point(tloc[1], tBottomRight[2]), tBottomRight]
    end if
    pMaskImage.copyPixels(tMaskImage, tQuad, tMaskImage.rect, [#ink: 36])
  end repeat
  if ilk(pMaskImage) = #image then
    pMask = pMaskImage.createMask()
  end if
end
