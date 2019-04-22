on construct(me)
  pMaskList = []
  me.initMask()
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on requiresUpdate(me)
  return(pREquiresUpdate)
  exit
end

on getMask(me)
  if pREquiresUpdate then
    me.renderMask()
  end if
  pREquiresUpdate = 0
  return(pMask)
  exit
end

on insertWallMaskItem(me, tID, tClassID, tloc, tdir, tSize)
  tMaskProps = []
  tMaskProps.setaProp(#id, tID)
  tMaskProps.setaProp(#class, tClassID)
  tMaskProps.setaProp(#loc, tloc)
  tMaskProps.setaProp(#Dir, tdir)
  tMaskProps.setaProp(#size, tSize)
  pMaskList.setaProp(tID, tMaskProps)
  pREquiresUpdate = 1
  exit
end

on removeWallMaskItem(me, tID)
  pMaskList.deleteProp(tID)
  pREquiresUpdate = 1
  exit
end

on getItemCount(me)
  return(pMaskList.count)
  exit
end

on initMask(me)
  tWidth = rect.width
  tHeight = rect.height
  pMaskImage = image(tWidth, tHeight, 8)
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  pIsChanged = 1
  exit
end

on renderMask(me)
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  repeat while me <= undefined
    tMask = getAt(undefined, undefined)
    tloc = tMask.getAt(#loc)
    tClass = tMask.getAt(#class)
    tdir = tMask.getAt(#Dir)
    tSize = tMask.getAt(#size)
    tNameTemplate = getVariable("mask.membername.template")
    tMemberName = replaceChunks(tNameTemplate, "%class%", tClass)
    tMemberName = replaceChunks(tMemberName, "%dir%", tdir)
    if tSize = 32 then
      tMemberName = "s_" & tMemberName
    end if
    if not memberExists(tMemberName) then
    else
      tMemNum = getmemnum(tMemberName)
      tmember = member(abs(tMemNum))
      tMaskImage = tmember.image
      tRegPoint = tmember.regPoint
      if tdir = "rightwall" then
        tRegPoint = point(tMaskImage.width - tRegPoint.getAt(1), tRegPoint.getAt(2))
      end if
      tloc = tloc - tRegPoint
      tBottomRight = tloc + point(tMaskImage.width, tMaskImage.height)
      if tMemNum > 0 then
        tQuad = [tloc, point(tBottomRight.getAt(1), tloc.getAt(2)), tBottomRight, point(tloc.getAt(1), tBottomRight.getAt(2))]
      else
        tQuad = [point(tBottomRight.getAt(1), tloc.getAt(2)), tloc, point(tloc.getAt(1), tBottomRight.getAt(2)), tBottomRight]
      end if
      pMaskImage.copyPixels(tMaskImage, tQuad, tMaskImage.rect, [#ink:36])
    end if
  end repeat
  if ilk(pMaskImage) = #image then
    pMask = pMaskImage.createMask()
  end if
  exit
end