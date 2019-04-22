on getViewImage(me)
  if me.count(#pContentList) = 0 then
    tID = getUniqueID()
    createWriter(tID)
    tWriter = getWriter(tID)
    tFont = getStructVariable("struct.font.plain")
    tFont.setaProp(#wordWrap, 1)
    tOffsets = rect(5, 2, 5, 2)
    tWidth = getVariable("fr.list.panel.width") - tOffsets.getAt(1) * 2
    tFont.setaProp(#rect, rect(0, 0, tWidth, 0))
    tWriter.define(tFont)
    tEmptyListTextImg = tWriter.render(me.pEmptyListText)
    tEmptyListImg = image(tEmptyListTextImg.width + tOffsets.getAt(1), tEmptyListTextImg.height + tOffsets.getAt(2), 32)
    tEmptyListImg.copyPixels(tEmptyListTextImg, tEmptyListImg.rect + tOffsets, tEmptyListImg.rect)
    return(tEmptyListImg)
  end if
  tImage = me.renderBackgroundImage()
  tImage.copyPixels(me.pListImg, me.rect, me.rect, [#ink:36])
  return(tImage)
  exit
end

on insertImageTo(me, tSourceImg, tTargetImg, tPosV)
  tNewImg = image(tTargetImg.width, tTargetImg.height + tSourceImg.height, 32)
  tTopRect = rect(0, 0, tTargetImg.width, tPosV)
  tNewImg.copyPixels(tTargetImg, tTopRect, tTopRect)
  tdestrect = rect(0, tTopRect.height, tSourceImg.width, tTopRect.height + tSourceImg.height)
  tNewImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect)
  tSourceRect = rect(0, tPosV, tTargetImg.width, tTargetImg.height)
  tdestrect = tSourceRect + rect(0, tSourceImg.height, 0, tSourceImg.height)
  tNewImg.copyPixels(tTargetImg, tdestrect, tSourceRect)
  return(tNewImg)
  exit
end

on updateImagePart(me, tSourceImg, tTargetImg, tPosV)
  tdestrect = rect(0, tPosV, tSourceImg.width, tPosV + tSourceImg.height)
  tTargetImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect)
  return(tTargetImg)
  exit
end

on removeImagePart(me, tImage, tStartPosV, tEndPosV)
  tNewImg = image(me.pItemWidth, tImage.height - tEndPosV - tStartPosV, 32)
  tTopRect = rect(0, 0, tImage.width, tStartPosV)
  tNewImg.copyPixels(tImage, tTopRect, tTopRect)
  tSourceRect = rect(0, tEndPosV, tImage.width, tImage.height)
  tdestrect = rect(0, tStartPosV, tImage.width, tNewImg.height)
  tNewImg.copyPixels(tImage, tdestrect, tSourceRect)
  return(tNewImg)
  exit
end