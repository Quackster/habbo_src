property pOrderNum, pUserCount, pVisible, pSubUnitOpen, pPropList, pCacheLinkImg, pCacheLineImg, pCacheNameImg, pWriterPlain, pWriterUnder

on construct me
  pUserCount = VOID
  pOrderNum = 0
  pSubUnitOpen = VOID
  pVisible = 0
  pPropList = [:]
  pWriterPlain = getWriter("nav_draw_unit_plain")
  pWriterUnder = getWriter("nav_draw_unit_under")
  if pWriterPlain = 0 then
    tStruct = getStructVariable("struct.font.plain")
    tMetrics = [:]
    tMetrics[#wordWrap] = 0
    tMetrics[#font] = tStruct.getaProp(#font)
    tMetrics[#fontStyle] = tStruct.getaProp(#fontStyle)
    tMetrics[#fontSize] = tStruct.getaProp(#fontSize)
    tMetrics[#fixedLineSpace] = tStruct.getaProp(#fontSize)
    tMetrics = tStruct
    createWriter("nav_draw_unit_plain", tMetrics)
    pWriterPlain = getWriter("nav_draw_unit_plain")
  end if
  if pWriterUnder = 0 then
    tStruct = getStructVariable("struct.font.link")
    tMetrics = [:]
    tMetrics[#wordWrap] = 0
    tMetrics[#font] = tStruct.getaProp(#font)
    tMetrics[#fontStyle] = tStruct.getaProp(#fontStyle)
    tMetrics[#fontSize] = tStruct.getaProp(#fontSize)
    tMetrics[#fixedLineSpace] = tStruct.getaProp(#fontSize)
    tMetrics = tStruct
    createWriter("nav_draw_unit_under", tMetrics)
    pWriterUnder = getWriter("nav_draw_unit_under")
  end if
  pCacheLinkImg = pWriterUnder.render(getText("nav_gobutton")).duplicate()
  return 1
end

on define me, tProps
  pPropList = tProps
end

on render me, tBuffer
  tUnitid = pPropList[#id]
  tUnitName = pPropList[#name]
  tImgHeight = pPropList[#height]
  tOrderNum = pPropList[#number]
  tDepth = tBuffer.depth
  tdata = getThread(#navigator).getInterface().getUnitData(tUnitid)
  if voidp(tdata) then
    return error(me, "Unit data not found!", #render)
  end if
  pVisible = tdata[#visible]
  if not pVisible then
    return 
  end if
  if not voidp(pCacheLineImg) and (pUserCount = tdata[#usercount]) and (pSubUnitOpen = tdata[#multiroomOpen]) then
    pOrderNum = tOrderNum
    tdestrect = pCacheLineImg.rect + rect(0, pOrderNum * tImgHeight, 0, pOrderNum * tImgHeight)
    tBuffer.copyPixels(pCacheLineImg, tdestrect, pCacheLineImg.rect)
    if tdata[#type] = #subUnit then
      me.drawSubLinesIcon(tdata, tdestrect, tBuffer)
    end if
  else
    pUserCount = tdata[#usercount]
    pOrderNum = tOrderNum
    pSubUnitOpen = tdata[#multiroomOpen]
    pCacheLineImg = image(tBuffer.width, tImgHeight, tDepth)
    case tdata[#type] of
      #mainUnit:
        tImage = member(getmemnum("colored_room_icon")).image
        tIcon = image(tImage.width, tImage.height, tDepth)
        tColor = string(getVariable("icon.color." & tUnitid))
        if tColor = 0 then
          tColor = "#FFFFFF"
        end if
        tIcon.copyPixels(tImage, tImage.rect, tImage.rect, [#maskImage: tImage.createMatte(), #ink: 41, #bgColor: rgb(tColor)])
        tLeft = 20
      #MultiUnit:
        me.drawTriangleIcon(tdata)
        tIcon = member(getmemnum("multi_room_icon")).image
        tLeft = 20
      #subUnit:
        tImage = member(getmemnum("colored_room_icon")).image
        tIcon = image(tImage.width, tImage.height, tDepth)
        tColor = string(getVariable("icon.color." & tUnitid))
        if tColor = 0 then
          tColor = "#FFFFFF"
        end if
        tIcon.copyPixels(tImage, tImage.rect, tImage.rect, [#maskImage: tImage.createMatte(), #ink: 41, #bgColor: rgb(tColor)])
        tLeft = 63
    end case
    tX1 = tLeft
    tX2 = tX1 + tIcon.width
    tY1 = 0
    tY2 = tY1 + tIcon.height
    tdestrect = rect(tX1, tY1, tX2, tY2)
    pCacheLineImg.copyPixels(tIcon, tdestrect, tIcon.rect)
    if not voidp(pCacheNameImg) then
      tNameImg = pCacheNameImg
    else
      tNameImg = pWriterUnder.render(tUnitName)
      pCacheNameImg = tNameImg.duplicate()
    end if
    tX1 = tX2 + 8
    tX2 = tX1 + tNameImg.width
    tY1 = 0
    tY2 = tNameImg.height
    tdestrect = rect(tX1, tY1, tX2, tY2)
    pCacheLineImg.copyPixels(tNameImg, tdestrect, tNameImg.rect)
    tUsersImg = pWriterPlain.render("(" & tdata[#usercount] & "/" & tdata[#maxUsers] & ")")
    tX1 = tX2 + 2
    tX2 = tX1 + tUsersImg.width
    tY1 = 1
    tY2 = tY1 + tUsersImg.height
    tdestrect = rect(tX1, tY1, tX2, tY2)
    pCacheLineImg.copyPixels(tUsersImg, tdestrect, tUsersImg.rect)
    if tdata[#type] <> #MultiUnit then
      tDotLineImg = pPropList[#dotline]
      tX1 = tX2
      tY1 = tNameImg.height - 1
      tX2 = pCacheLineImg.width - 5
      tY2 = tY1 + 1
      tDstRect = rect(tX1, tY1, tX2, tY2)
      tSrcRect = rect(0, 0, tX2 - tX1, 1)
      pCacheLineImg.copyPixels(tDotLineImg, tDstRect, tSrcRect)
      tX1 = pCacheLineImg.width - pCacheLinkImg.width + 2
      tY1 = 0
      tX2 = tX1 + pCacheLinkImg.width
      tY2 = tY1 + pCacheLinkImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pCacheLineImg.copyPixels(pCacheLinkImg, tDstRect, pCacheLinkImg.rect)
    end if
    tdestrect = pCacheLineImg.rect + rect(0, pOrderNum * tImgHeight, 0, pOrderNum * tImgHeight)
    tBuffer.copyPixels(pCacheLineImg, tdestrect, pCacheLineImg.rect)
    if tdata[#type] = #subUnit then
      me.drawSubLinesIcon(tdata, tdestrect, tBuffer)
    end if
  end if
end

on getClickedUnitName me, tLineNum
  if pVisible and (tLineNum = pOrderNum) then
    return pPropList[#id]
  end if
end

on drawTriangleIcon me, tdata
  if tdata[#multiroomOpen] = #open then
    tTriangle = member(getmemnum("triangle_open")).image
    tY1 = 2
  else
    tTriangle = member(getmemnum("triangle_closed")).image
    tY1 = 0
  end if
  tX1 = 6
  tX2 = tX1 + tTriangle.width
  tY2 = tTriangle.height + tY1
  tdestrect = rect(tX1, tY1, tX2, tY2)
  pCacheLineImg.copyPixels(tTriangle, tdestrect, tTriangle.rect)
end

on drawSubLinesIcon me, tdata, tdestrect, tBuffer
  if tdata[#visible] = 0 then
    return 
  end if
  if tdata[#subordernum] = 1 then
    tDotLine = member(getmemnum("subroom_line_first")).image
    tFixY = -3
  else
    tDotLine = member(getmemnum("subroom_line")).image
    tFixY = -7
  end if
  tX1 = 50
  tX2 = tX1 + tDotLine.width
  tY1 = 0
  tY2 = tY1 + tDotLine.height
  tdestrect = rect(tX1, tY1, tX2, tY2) + rect(0, tdestrect.top + tFixY, 0, tdestrect.top + tFixY)
  tBuffer.copyPixels(tDotLine, tdestrect, tDotLine.rect)
end
