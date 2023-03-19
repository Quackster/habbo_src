property pImageWidth, pImageHeight, pCellWidth, pCellHeight, pwidth, pheight, pMarginLeft, pMarginRight, pMarginTop, pMarginBottom, pNumberPosX, pNumberPosY, pDealList, pCountWriterID, pAlign

on construct me
  pCellWidth = getVariable("catalogue.deal.cellwidth")
  pCellHeight = getVariable("catalogue.deal.cellheight")
  pwidth = getVariable("catalogue.deal.gridwidth")
  pheight = getVariable("catalogue.deal.gridheight")
  pNumberPosX = getVariable("catalogue.deal.numberpos.x")
  pNumberPosY = getVariable("catalogue.deal.numberpos.y")
  pMarginLeft = getVariable("catalogue.deal.margin.left")
  pMarginRight = getVariable("catalogue.deal.margin.right")
  pMarginTop = getVariable("catalogue.deal.margin.top")
  pMarginBottom = getVariable("catalogue.deal.margin.bottom")
  pAlign = 1
  tAlign = getVariable("catalogue.deal.number.align")
  if tAlign = "left" then
    pAlign = 0
  else
    if tAlign = "right" then
      pAlign = 2
    end if
  end if
  pDealList = [:]
  pCountWriterID = getUniqueID()
  tBold = getStructVariable("struct.font.bold")
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#FFFFCC")]
  createWriter(pCountWriterID, tMetrics)
  return 1
end

on deconstruct me
  pDealList = [:]
  removeWriter(pCountWriterID)
  return 1
end

on define me, tDealList, tCellWidth, tCellHeight, tWidth, tHeight, tNumberPosX, tNumberPosY
  pDealList = tDealList.duplicate()
  if integerp(tCellWidth) then
    pCellWidth = tCellWidth
  end if
  if integerp(tCellHeight) then
    pCellHeight = tCellHeight
  end if
  if integerp(tWidth) then
    pwidth = tWidth
  end if
  if integerp(tHeight) then
    pheight = tHeight
  end if
  if integerp(tNumberPosX) then
    pNumberPosX = tNumberPosX
  end if
  if integerp(tNumberPosY) then
    pNumberPosY = tNumberPosY
  end if
  if pwidth < 1 then
    pwidth = 1
  end if
  if pheight < 1 then
    pheight = 1
  end if
  pImageWidth = (pwidth * pCellWidth) + 1 + pMarginLeft + pMarginRight
  pImageHeight = (pheight * pCellHeight) + 1 + pMarginTop + pMarginBottom
  return 1
end

on getPicture me, tImg
  tCanvas = me.drawBackground()
  tLimit = pDealList.count()
  if (pheight * pwidth) < tLimit then
    tLimit = pheight * pwidth
  end if
  tDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  repeat with i = tLimit down to 1
    if voidp(pDealList[i]["class"]) then
      return error(me, "class property missing", #showPreviewImage, #minor)
      next repeat
    end if
    tClass = pDealList[i]["class"]
    tpartColors = pDealList[i]["partColors"]
    tCount = pDealList[i]["count"]
    tmember = getImage(tClass)
    if tmember <> 0 then
      tAssetId = me.getClassAsset(tClass)
      if not tDownloader.isAssetDownloading(tAssetId) then
        if not voidp(tClass) and not voidp(tpartColors) then
          tRenderedImage = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, tpartColors, tClass).duplicate()
        else
          tRenderedImage = member(tmember).image
        end if
      else
        tRenderedImage = getMember("ctlg_loading_icon2").image
      end if
      me.drawItem(tCanvas, tRenderedImage, i, tCount)
    end if
  end repeat
  if voidp(tImg) then
    tImg = tCanvas
  else
    tdestrect = tImg.rect - tCanvas.rect
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tCanvas.width + (tdestrect.width / 2), (tdestrect.height / 2) + tCanvas.height)
    tImg.copyPixels(tCanvas, tdestrect, tCanvas.rect, [#ink: 36])
  end if
  return tImg.trimWhiteSpace()
end

on renderDealPreviewImage me, tDealNumber, tDealList, tWidth, tHeight
  if tDealList.count = 0 then
    return VOID
  end if
  if tDealList.count > 1 then
    tmember = "ctlg_pic_deal_icon_narrow"
    if memberExists(tmember) then
      tMem = member(getmemnum(tmember))
      tRenderedImage = image(tMem.width, tMem.height, 32)
      tRenderedImage.copyPixels(tMem.image, tMem.rect, tMem.rect)
      tWriteObj = getWriter(pCountWriterID)
      tCountImg = tWriteObj.render(string(tDealNumber))
      tCountImgTrimmed = image(tCountImg.width, tCountImg.height, 32)
      tCountImgTrimmed.copyPixels(tCountImg, tCountImg.rect, tCountImg.rect, [#ink: 36])
      tCountImgTrimmed = tCountImgTrimmed.trimWhiteSpace()
      tNumberWd = tCountImgTrimmed.rect[3] - tCountImgTrimmed.rect[1]
      tNumberHt = tCountImgTrimmed.rect[4] - tCountImgTrimmed.rect[2]
      tOffsetRect = rect(20 - ((tNumberWd + 1) / 2), 20 - ((tNumberHt + 1) / 2), 20 - ((tNumberWd + 1) / 2), 20 - ((tNumberHt + 1) / 2))
      tRenderedImage.copyPixels(tCountImg, tCountImg.rect + tOffsetRect, tCountImg.rect, [#ink: 36])
    else
      tRenderedImage = image(1, 1, 32)
    end if
  else
    tpartColors = tDealList[1][#partColors]
    tClass = tDealList[1][#class]
    tCount = tDealList[1][#count]
    tBackgroundImage = image(tWidth, tHeight, 32)
    tRenderedImage = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, tpartColors, tClass)
    tRenderWd = tRenderedImage.rect[3] - tRenderedImage.rect[1]
    tRenderHt = tRenderedImage.rect[4] - tRenderedImage.rect[2]
    tOffsetRect = rect((tWidth - tRenderWd) / 2, min(8, tHeight - tRenderHt), (tWidth - tRenderWd) / 2, min(8, tHeight - tRenderHt))
    tBackgroundImage.copyPixels(tRenderedImage, tRenderedImage.rect + tOffsetRect, tRenderedImage.rect, [#ink: 36])
    tCountImg = me.getNumberImage(tCount)
    tOffsetRect = rect(2, 0, 2, 0)
    tBackgroundImage.copyPixels(tCountImg, tCountImg.rect + tOffsetRect, tCountImg.rect, [#ink: 36])
    tRenderedImage = tBackgroundImage.trimWhiteSpace()
  end if
  return tRenderedImage
end

on drawBackground me
  tCanvas = image(pImageWidth, pImageHeight, 32)
  tFlipFlag = 0
  if memberExists("ctlg_dyndeal_background") then
    tImage = member(getmemnum("ctlg_dyndeal_background")).image
    tCanvas.copyPixels(tImage, tImage.rect, tImage.rect)
  end if
  return tCanvas
end

on drawItem me, tCanvas, tImage, tIndex, tCount
  tX = ((tIndex - 1) mod pwidth * pCellWidth) + pMarginLeft
  tY = ((tIndex - 1) / pwidth * pCellHeight) + pMarginTop
  tCenteredX = tX + ((pCellWidth - (tImage.rect[3] - tImage.rect[1])) / 2)
  tCenteredY = tY + ((pCellHeight - (tImage.rect[4] - tImage.rect[2])) / 2)
  tCanvas.copyPixels(tImage, tImage.rect + rect(tCenteredX, tCenteredY, tCenteredX, tCenteredY), tImage.rect, [#ink: 36])
  if tCount > 1 then
    tCountImg = me.getNumberImage(tCount)
    tCenteredX = tX + pNumberPosX - ((tCountImg.rect[3] - tCountImg.rect[1]) / 2)
    tCenteredY = tY + pNumberPosY - ((tCountImg.rect[4] - tCountImg.rect[2]) / 2)
    if pAlign = 0 then
      tCenteredX = tX + pNumberPosX
    else
      if pAlign = 2 then
        tCenteredX = tX + pNumberPosX - (tCountImg.rect[3] - tCountImg.rect[1])
      end if
    end if
    tCanvas.copyPixels(tCountImg, tCountImg.rect + rect(tCenteredX, tCenteredY, tCenteredX, tCenteredY), tCountImg.rect, [#ink: 36])
  end if
end

on getImage me, tClass
  if not voidp(tClass) then
    if tClass contains "*" then
      tSmallMem = tClass & "_small"
      tClass = tClass.char[1..offset("*", tClass) - 1]
      if not memberExists(tSmallMem) then
        tSmallMem = tClass & "_small"
      end if
    else
      tSmallMem = tClass & "_small"
    end if
    if memberExists(tSmallMem) then
      return getmemnum(tSmallMem)
    end if
  end if
  return getmemnum("no_icon_small")
end

on getNumberImage me, tNumber
  tCountImg = image(80, 20, 32)
  tTemp = integer(tNumber)
  tDigit = []
  repeat with i = 1 to 2
    tDigit[i] = tTemp mod 10
    tTemp = (tTemp - tDigit[i]) / 10
  end repeat
  tstart = 0
  tWidth = 0
  repeat with i = 2 down to 1
    if tDigit[i] = 0 then
      tDigit[i] = -1
      next repeat
    end if
    tWidth = tWidth + (i - 1)
    exit repeat
  end repeat
  tDigitImg = []
  repeat with i = 1 to 2
    if memberExists("ctlg_dyndeal_" & string(tDigit[i])) then
      tDigitImg[i] = member(getmemnum("ctlg_dyndeal_" & string(tDigit[i]))).image
      tWidth = tWidth + (tDigitImg[i].rect[3] - tDigitImg[i].rect[1])
      next repeat
    end if
    tDigitImg[i] = VOID
  end repeat
  if memberExists("ctlg_dyndeal_button_left") then
    tImage = member(getmemnum("ctlg_dyndeal_button_left")).image
    tCountImg.copyPixels(tImage, tImage.rect, tImage.rect)
    tstart = tImage.rect[3] - tImage.rect[1]
  end if
  if memberExists("ctlg_dyndeal_button_center") then
    tImage = member(getmemnum("ctlg_dyndeal_button_center")).image
    repeat with i = tstart to tstart + tWidth
      tCountImg.copyPixels(tImage, tImage.rect + rect(i, 0, i, 0), tImage.rect)
    end repeat
  end if
  if memberExists("ctlg_dyndeal_button_right") then
    tImage = member(getmemnum("ctlg_dyndeal_button_right")).image
    tCountImg.copyPixels(tImage, tImage.rect + rect(tstart + tWidth + 1, 0, tstart + tWidth + 1, 0), tImage.rect)
  end if
  repeat with i = 2 down to 1
    if not voidp(tDigitImg[i]) then
      tCountImg.copyPixels(tDigitImg[i], tDigitImg[i].rect + rect(tstart + 2, 3, tstart + 2, 3), tDigitImg[i].rect, [#ink: 36])
      tstart = tstart + (tDigitImg[i].rect[3] - tDigitImg[i].rect[1]) + 1
    end if
  end repeat
  return tCountImg.trimWhiteSpace()
end

on getClassAsset me, tClassName
  if ilk(tClassName) <> #string then
    return EMPTY
  end if
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.char[1..offset("*", tClass) - 1]
  end if
  return tClass
end
