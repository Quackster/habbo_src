on defineBalloon me, tMode, tColor, tMessage, tItemID, tSourceLoc 
  me.pBalloonImg = [:]
  me.addProp(#left, undefined.duplicate())
  me.addProp(#middle, undefined.duplicate())
  me.addProp(#right, undefined.duplicate())
  tNewBgMemName = "chat_item_background_" & tItemID
  me.pBgMemName = tNewBgMemName
  if not memberExists(me.pBgMemName) then
    createMember(me.pBgMemName, #bitmap)
  end if
  me.pItemId = tItemID
  tTextImg = me.renderWithWriter(tMessage, tColor)
  if tTextImg = 0 then
    return(error(me, "Could not render text", #defineBalloon))
  end if
  tTextWidth = tTextImg.width
  me.setProp(#pMargins, #left, 8)
  me.setProp(#pMargins, #right, 8)
  tBalloonWidth = me.getProp(#pMargins, #left) + tTextWidth + me.getProp(#pMargins, #right)
  tBackgroundImg = me.renderBackground(tBalloonWidth, tColor)
  tTextOffH = me.getProp(#pMargins, #left) + 2
  tTextOffV = me.getPropRef(#pBalloonImg, #middle).height - tTextImg.height / 2 + 1
  tTextDestRect = rect(tTextOffH, tTextOffV, tTextOffH + tTextWidth, tTextOffV + tTextImg.height)
  tBackgroundImg.copyPixels(tTextImg, tTextDestRect, tTextImg.rect)
  tBgMem = getMember(me.pBgMemName)
  tBgMem.image = tBackgroundImg
  tBgMem.regPoint = point(0, 0)
  me.member = tBgMem
  me.ink = 8
  return(1)
end

on renderBackground me, tWidth, tBalloonColor 
  tNewImg = image(me.getProp(#left).width + tWidth + me.getProp(#left).width, me.getPropRef(#pBalloonImg, #left).height, 32)
  tStartPointY = 0
  tEndPointY = me.getPropRef(#pBalloonImg, #left).height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #middle, #right] <= tBalloonColor
    i = getAt(tBalloonColor, tWidth)
    tStartPointX = tEndPointX
    if [#left, #middle, #right] = #left then
      tEndPointX = tEndPointX + me.getProp(i).width
      tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
      tNewImg.copyPixels(me.getProp(i), tdestrect, me.getProp(i).rect, [#bgColor:tBalloonColor, #maskImage:me.getProp(i).createMatte()])
    else
      if [#left, #middle, #right] = #middle then
        tEndPointX = tEndPointX + tWidth - me.getProp(#left).width - me.getProp(#right).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
        tNewImg.copyPixels(me.getProp(i), tdestrect, me.getProp(i).rect, [#bgColor:tBalloonColor, #maskImage:me.getProp(i).createMatte()])
      else
        if [#left, #middle, #right] = #right then
          tEndPointX = tEndPointX + me.getProp(i).width
          tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
          tNewImg.copyPixels(me.getProp(i), tdestrect, me.getProp(i).rect, [#bgColor:tBalloonColor, #maskImage:me.getProp(i).createMatte()])
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
  if tWriter = 0 then
    return(0)
  end if
  tImage = tWriter.render(tText)
  if tImage.ilk = #image then
    tImage = tImage.duplicate()
  end if
  removeWriter(tWriterId)
  return(tImage)
end
