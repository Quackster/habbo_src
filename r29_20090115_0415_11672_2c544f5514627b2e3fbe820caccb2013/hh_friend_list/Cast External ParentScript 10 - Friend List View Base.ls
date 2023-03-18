property pFriendRenderQueue, pTasksPerUpdate, pNeedsRender

on construct me
  pFriendRenderQueue = []
  pTasksPerUpdate = 6
  pNeedsRender = 1
  return me.ancestor.construct()
end

on hasQueue me
  return pFriendRenderQueue.count > 0
end

on update me, tContentElem
  if pFriendRenderQueue.count = 0 then
    return 1
  end if
  me.renderFromQueue(tContentElem)
end

on renderListImage me
  nothing()
end

on needsRender me
  return pNeedsRender
end

on resetRenderFlag me
  pNeedsRender = 0
end

on getViewImage me
  if me.pContentList.count = 0 then
    tID = getUniqueID()
    createWriter(tID)
    tWriter = getWriter(tID)
    tFont = getStructVariable("struct.font.plain")
    tFont.setaProp(#wordWrap, 1)
    tOffsets = rect(5, 2, 5, 2)
    tWidth = getVariable("fr.list.panel.width") - (tOffsets[1] * 2)
    tFont.setaProp(#rect, rect(0, 0, tWidth, 0))
    tWriter.define(tFont)
    tEmptyListTextImg = tWriter.render(me.pEmptyListText)
    tEmptyListImg = image(tEmptyListTextImg.width + tOffsets[1], tEmptyListTextImg.height + tOffsets[2], 32)
    tEmptyListImg.copyPixels(tEmptyListTextImg, tEmptyListImg.rect + tOffsets, tEmptyListImg.rect)
    return tEmptyListImg
  end if
  tImage = me.renderBackgroundImage()
  tImage.copyPixels(me.pListImg, me.pListImg.rect, me.pListImg.rect, [#ink: 36])
  return tImage
end

on insertImageTo me, tSourceImg, tTargetImg, tPosV
  tNewImg = image(tTargetImg.width, tTargetImg.height + tSourceImg.height, 32)
  tTopRect = rect(0, 0, tTargetImg.width, tPosV)
  tNewImg.copyPixels(tTargetImg, tTopRect, tTopRect)
  tdestrect = rect(0, tTopRect.height, tSourceImg.width, tTopRect.height + tSourceImg.height)
  tNewImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect)
  tSourceRect = rect(0, tPosV, tTargetImg.width, tTargetImg.height)
  tdestrect = tSourceRect + rect(0, tSourceImg.height, 0, tSourceImg.height)
  tNewImg.copyPixels(tTargetImg, tdestrect, tSourceRect)
  return tNewImg
end

on updateImagePart me, tSourceImg, tTargetImg, tPosV
  tdestrect = rect(0, tPosV, tSourceImg.width, tPosV + tSourceImg.height)
  tTargetImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect)
  return tTargetImg
end

on removeImagePart me, tImage, tStartPosV, tEndPosV
  tNewImg = image(me.pItemWidth, tImage.height - (tEndPosV - tStartPosV), 32)
  tTopRect = rect(0, 0, tImage.width, tStartPosV)
  tNewImg.copyPixels(tImage, tTopRect, tTopRect)
  tSourceRect = rect(0, tEndPosV, tImage.width, tImage.height)
  tdestrect = rect(0, tStartPosV, tImage.width, tNewImg.height)
  tNewImg.copyPixels(tImage, tdestrect, tSourceRect)
  return tNewImg
end
