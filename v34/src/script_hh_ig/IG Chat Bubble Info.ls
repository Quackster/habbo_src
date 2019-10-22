on defineBalloon me, tMode, tColor, tMessage, tItemID, tSourceLoc 
  me.pBalloonImg = [:]
  me.pBalloonImg.addProp(#left, member(getmemnum("ig_chat_bubble_left")).image.duplicate())
  me.pBalloonImg.addProp(#middle, member(getmemnum("ig_chat_bubble_mid")).image.duplicate())
  me.pBalloonImg.addProp(#right, member(getmemnum("ig_chat_bubble_right")).image.duplicate())
  tNewBgMemName = "chat_item_background_" & tItemID
  me.pBgMemName = tNewBgMemName
  if not memberExists(me.pBgMemName) then
    createMember(me.pBgMemName, #bitmap)
  end if
  me.pItemId = tItemID
  tTextImg = me.renderWithWriter(tMessage, tColor)
  if (tTextImg = 0) then
    return(error(me, "Could not render text", #defineBalloon))
  end if
  tTextWidth = tTextImg.width
  me.setProp(#pMargins, #left, 8)
  me.setProp(#pMargins, #right, 8)
  tBalloonWidth = ((me.getProp(#pMargins, #left) + tTextWidth) + me.getProp(#pMargins, #right))
  tBackgroundImg = me.renderBackground(tBalloonWidth, tColor)
  tTextOffH = (me.getProp(#pMargins, #left) + 2)
  tTextOffV = (((me.getPropRef(#pBalloonImg, #middle).height - tTextImg.height) / 2) + 1)
  tTextDestRect = rect(tTextOffH, tTextOffV, (tTextOffH + tTextWidth), (tTextOffV + tTextImg.height))
  tBackgroundImg.copyPixels(tTextImg, tTextDestRect, tTextImg.rect)
  tBgMem = getMember(me.pBgMemName)
  tBgMem.image = tBackgroundImg
  tBgMem.regPoint = point(0, 0)
  me.pBgSprite.member = tBgMem
  me.pBgSprite.ink = 8
  return TRUE
end

on renderBackground me, tWidth, tBalloonColor 
  tNewImg = image(((me.pBalloonImg.getProp(#left).width + tWidth) + me.pBalloonImg.getProp(#left).width), me.getPropRef(#pBalloonImg, #left).height, 32)
  tStartPointY = 0
  tEndPointY = me.getPropRef(#pBalloonImg, #left).height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #middle, #right] <= tBalloonColor
    i = getAt(tBalloonColor, tWidth)
    tStartPointX = tEndPointX
    if ([#left, #middle, #right] = #left) then
      tEndPointX = (tEndPointX + me.pBalloonImg.getProp(i).width)
      tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
      tNewImg.copyPixels(me.pBalloonImg.getProp(i), tdestrect, me.pBalloonImg.getProp(i).rect, [#bgColor:tBalloonColor, #maskImage:me.pBalloonImg.getProp(i).createMatte()])
    else
      if ([#left, #middle, #right] = #middle) then
        tEndPointX = (((tEndPointX + tWidth) - me.pBalloonImg.getProp(#left).width) - me.pBalloonImg.getProp(#right).width)
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
        tNewImg.copyPixels(me.pBalloonImg.getProp(i), tdestrect, me.pBalloonImg.getProp(i).rect, [#bgColor:tBalloonColor, #maskImage:me.pBalloonImg.getProp(i).createMatte()])
      else
        if ([#left, #middle, #right] = #right) then
          tEndPointX = (tEndPointX + me.pBalloonImg.getProp(i).width)
          tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
          tNewImg.copyPixels(me.pBalloonImg.getProp(i), tdestrect, me.pBalloonImg.getProp(i).rect, [#bgColor:tBalloonColor, #maskImage:me.pBalloonImg.getProp(i).createMatte()])
        end if
      end if
    end if
  end repeat
  return(tNewImg)
end

on renderWithWriter me, tText, tBgColor 
  tWriterId = "bubbly_writer_" & getUniqueID()
  if writerExists(tWriterId) then
    removeWriter(tWriterId)
  end if
  tBoldStruct = getStructVariable("struct.font.bold")
  tBoldStruct.setaProp(#color, rgb(255, 255, 255))
  tBoldStruct.setaProp(#bgColor, tBgColor)
  createWriter(tWriterId, tBoldStruct)
  tWriter = getWriter(tWriterId)
  if (tWriter = 0) then
    return FALSE
  end if
  tImage = tWriter.render(tText)
  if (tImage.ilk = #image) then
    tImage = tImage.duplicate()
  end if
  removeWriter(tWriterId)
  return(tImage)
end
