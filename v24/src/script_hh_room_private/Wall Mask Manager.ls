property pREquiresUpdate, pMaskImage, pMaskList, pRenderNeeded, pMember

on construct me 
  tMemberName = "landscape_mask_test"
  if memberExists(tMemberName) then
    pMember = getMember(tMemberName)
  else
    createMember(tMemberName, #bitmap)
    pMember = getMember(tMemberName)
  end if
  pMaskList = [:]
  me.initMask()
  receiveUpdate(me.getID())
  return(1)
end

on deconstruct me 
  removeUpdate(me.getID())
  return(1)
end

on requiresUpdate me 
  return(pREquiresUpdate)
end

on getMask me 
  pREquiresUpdate = 0
  return(pMaskImage.createMask())
end

on insertWallMaskItem me, tID, tClassID, tloc, tdir, tSize 
  tMaskProps = [:]
  tMaskProps.setaProp(#id, tID)
  tMaskProps.setaProp(#class, tClassID)
  tMaskProps.setaProp(#loc, tloc)
  tMaskProps.setaProp(#Dir, tdir)
  tMaskProps.setaProp(#size, tSize)
  pMaskList.setaProp(tID, tMaskProps)
  pRenderNeeded = 1
end

on removeWallMaskItem me, tID 
  pMaskList.deleteProp(tID)
  pRenderNeeded = 1
end

on getItemCount me 
  return(pMaskList.count)
end

on initMask me 
  tWidth = rect.width
  tHeight = rect.height
  pMaskImage = image(tWidth, tHeight, 8)
  pMaskImage.fill(pMaskImage.rect, rgb("FFFFFF"))
  pIsChanged = 1
end

on update me 
  if not pRenderNeeded then
    return(1)
  end if
  me.renderMask()
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
  pMember.image = pMaskImage
  pREquiresUpdate = 1
  pRenderNeeded = 0
end
