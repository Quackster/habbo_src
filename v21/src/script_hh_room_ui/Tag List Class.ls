on construct(me)
  tID = getUniqueID()
  tLinkFont = getStructVariable("struct.font.link")
  tLinkFont.setaProp(#lineHeight, 15)
  tLinkFont.color = rgb(240, 240, 240)
  createWriter(tID, tLinkFont)
  pWriter = getWriter(tID)
  pTagList = []
  pRectList = []
  pwidth = 1
  pheight = 1
  pGapH = 5
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on createTagList(me, tTagList)
  if voidp(tTagList) then
    tTagList = []
  end if
  pRectList = []
  tImage = image(pwidth, pheight, 8)
  tImage.fill(tImage.rect, rgb("#FFFFFF"))
  tPosX = 0
  tPosY = 0
  repeat while me <= undefined
    tTag = getAt(undefined, tTagList)
    tTagImage = pWriter.render(tTag).duplicate()
    if tPosX + tTagImage.width > pwidth then
      tPosX = 0
      tPosY = tPosY + tTagImage.height + 1
    end if
    if tPosX + tTagImage.width >= pwidth then
    else
      if tPosY + tTagImage.height > pheight then
      else
        tTargetRect = rect(tPosX, tPosY, tPosX + tTagImage.width, tPosY + tTagImage.height)
        tImage.copyPixels(tTagImage, tTargetRect, tTagImage.rect)
        pRectList.setaProp(tTag, tTargetRect)
        tPosX = tPosX + tTagImage.width + pGapH
      end if
      return(tImage)
      exit
    end if
  end repeat
end

on getTagAt(me, tpoint)
  tRect = 1
  repeat while tRect <= pRectList.count
    if tpoint.inside(pRectList.getAt(tRect)) then
      return(pRectList.getPropAt(tRect))
    end if
    tRect = 1 + tRect
  end repeat
  return(0)
  exit
end

on setWidth(me, tWidth)
  if not integerp(tWidth) then
    return(0)
  end if
  pwidth = tWidth
  exit
end

on setHeight(me, tHeight)
  if not integerp(tHeight) then
    return(0)
  end if
  pheight = tHeight
  exit
end