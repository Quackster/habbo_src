property pREquiresUpdate, pMask, pMaskList, pMaskImage

on construct me 
  pMaskList = [:]
  me.initMask()
  return TRUE
end

on deconstruct me 
  return TRUE
end

on requiresUpdate me 
  return(pREquiresUpdate)
end

on getMask me 
  if pREquiresUpdate then
    me.renderMask()
  end if
  pREquiresUpdate = 0
  return(pMask)
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
  return(pMaskList.count)
end

on initMask me 
  tWidth = the stage.rect.width
  tHeight = the stage.rect.height
  pMaskImage = image(tWidth, tHeight, 8)
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  pIsChanged = 1
end

on renderMask me 
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  repeat while pMaskList <= undefined
    tMask = getAt(undefined, undefined)
    tloc = tMask.getAt(#loc)
    tClass = tMask.getAt(#class)
    tdir = tMask.getAt(#Dir)
    tSize = tMask.getAt(#size)
    tNameTemplate = getVariable("mask.membername.template")
    tMemberName = replaceChunks(tNameTemplate, "%class%", tClass)
    tMemberName = replaceChunks(tMemberName, "%dir%", tdir)
    if (tSize = 32) then
      tMemberName = "s_" & tMemberName
    end if
    if not memberExists(tMemberName) then
    else
      tMemNum = getmemnum(tMemberName)
      tmember = member(abs(tMemNum))
      tMaskImage = tmember.image
      tRegPoint = tmember.regPoint
      if (tdir = "rightwall") then
        tRegPoint = point((tMaskImage.width - tRegPoint.getAt(1)), tRegPoint.getAt(2))
      end if
      tloc = (tloc - tRegPoint)
      tBottomRight = (tloc + point(tMaskImage.width, tMaskImage.height))
      if tMemNum > 0 then
        tQuad = [tloc, point(tBottomRight.getAt(1), tloc.getAt(2)), tBottomRight, point(tloc.getAt(1), tBottomRight.getAt(2))]
      else
        tQuad = [point(tBottomRight.getAt(1), tloc.getAt(2)), tloc, point(tloc.getAt(1), tBottomRight.getAt(2)), tBottomRight]
      end if
      pMaskImage.copyPixels(tMaskImage, tQuad, tMaskImage.rect, [#ink:36])
    end if
  end repeat
  if (ilk(pMaskImage) = #image) then
    pMask = pMaskImage.createMask()
  end if
end
