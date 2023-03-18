property pWallPatterns, pWallPattern, pWallModel, pWallThumbSpr, pWallPreviewIdList, pFloorPatterns, pFloorPattern, pFloorModel, pFloorThumbSpr, pFloorPreviewIdList, pLandscapePatterns, pLandscapeGradients, pLandscapeProducts, pLandscapePattern, pLandscapeGradient, pLandscapePreviewIdList, pLandscapeElement, pLandscapeBlockedCombos, pWallProps, pFloorProps, pLandscapeProps

on construct me
  pWallPatterns = [:]
  pWallPattern = 0
  pWallModel = 0
  pFloorPatterns = field("catalog_floorpattern_patterns")
  pFloorPattern = 0
  pFloorModel = 0
  pLandscapePattern = 1
  pLandscapeGradient = 1
  pWallProps = [:]
  pFloorProps = [:]
  pLandscapeProps = [:]
  pLandscapeProducts = [:]
  pFloorPreviewIdList = []
  pFloorPreviewIdList.add("catalog_floor_preview_example")
  pWallPreviewIdList = []
  pWallPreviewIdList.add("catalog_wall_preview_a_left")
  pWallPreviewIdList.add("catalog_wall_preview_b_right")
  pLandscapeElement = "catalog_space_preview_window"
  pLandscapePreviewIdList = []
  pLandscapePreviewIdList.add("catalog_spaces_window")
  pLandscapePreviewIdList.add("catalog_spaces_window_mask")
  pLandscapePreviewIdList.add("catalog_landscape_preview_window_alpha")
  tLandscapePatterns = field("catalog_landscape_patterns")
  tLandscapeGradients = field("catalog_landscape_gradients")
  pLandscapePatterns = []
  pLandscapeGradients = []
  repeat with i = 1 to tLandscapePatterns.line.count
    pLandscapePatterns.add(tLandscapePatterns.line[i])
  end repeat
  repeat with i = 1 to tLandscapeGradients.line.count
    pLandscapeGradients.add(tLandscapeGradients.line[i])
  end repeat
  pLandscapeBlockedCombos = []
  if memberExists("catalog_landscape_blocked_combinations") then
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    tBlockList = field("catalog_landscape_blocked_combinations")
    repeat with i = 1 to tBlockList.line.count
      pLandscapeBlockedCombos.add([tBlockList.line[i].item[1], tBlockList.line[i].item[2]])
    end repeat
    the itemDelimiter = tDelim
  end if
  return 1
end

on define me, tPageProps
  if tPageProps.ilk <> #propList then
    return error(me, "Incorrect Catalogue page data", #define, #major)
  end if
  tWallPatterns = field("catalog_wallpattern_patterns")
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return error(me, "Couldn't access catalogue window!", #define, #major)
  end if
  tProdList = tPageProps["productList"]
  if not voidp(tProdList) then
    if tProdList.count < 2 then
      if tWndObj.elementExists("ctlg_buy_wall") then
        tWndObj.getElement("ctlg_buy_wall").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_buy_floor") then
        tWndObj.getElement("ctlg_buy_floor").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_buy_landscape") then
        tWndObj.getElement("ctlg_buy_landscape").setProperty(#visible, 0)
      end if
      return 0
    end if
    repeat with tItemNo = 1 to tProdList.count
      tProp = tProdList[tItemNo]
      tClass = tProp["class"]
      if tClass = VOID then
        next repeat
      end if
      tClassPrefix = tClass.word[1]
      tClassPostfix = tClass.word[2]
      if (tClassPrefix = "wallpaper") and (tClassPostfix <> EMPTY) then
        tPatternNo = tClassPostfix
        tPatternMemName = tWallPatterns.line[integer(tPatternNo)]
        tModelsRawData = member(tPatternMemName).text
        if ilk(pWallPatterns[tPatternNo]) <> #propList then
          pWallPatterns[tPatternNo] = [:]
        end if
        tmodellist = pWallPatterns[tPatternNo].duplicate()
        tDelim = the itemDelimiter
        the itemDelimiter = ","
        repeat with tModelNo = 1 to tModelsRawData.line.count
          tModelDataLn = tModelsRawData.line[tModelNo]
          if tModelDataLn.item.count < 5 then
            exit repeat
          end if
          tPatternID = tModelDataLn.item[1]
          tPalette = tModelDataLn.item[2]
          tRed = integer(tModelDataLn.item[3])
          tGreen = integer(tModelDataLn.item[4])
          tBlue = integer(tModelDataLn.item[5])
          tRGB = rgb(tRed, tGreen, tBlue)
          tTempModelNo = tModelNo
          if tModelNo < 10 then
            tTempModelNo = "0" & tModelNo
          end if
          tPaperID = tPatternNo & EMPTY & tTempModelNo
          tModelProps = tProp.duplicate()
          tModelProps["extra_parm"] = tPaperID
          tModelProps[#patternID] = tPatternID
          tModelProps[#rgb] = tRGB
          tModelProps[#palette] = tPalette
          tmodellist[string(tModelNo)] = tModelProps
        end repeat
        pWallPatterns[tPatternNo] = tmodellist
        the itemDelimiter = tDelim
        next repeat
      end if
      if tClass = "floor" then
        pFloorProps = tProp.duplicate()
        next repeat
      end if
      if tClassPrefix = "landscape" then
        tPatternNo = tClassPostfix
        if tPatternNo <= pLandscapePatterns.count then
          if tPatternNo = 0 then
            tPatternMemName = EMPTY
          else
            tPatternMemName = pLandscapePatterns[integer(tPatternNo)]
          end if
          tLandscapeProps = tProp.duplicate()
          tLandscapeProps["extra_parm"] = "1." & tPatternNo
          tLandscapeProps[#patternID] = tPatternNo
          pLandscapeProducts[string(tPatternNo)] = tLandscapeProps
        end if
      end if
    end repeat
  end if
  me.setWallPaper("pattern", 6)
  me.setFloorPattern("pattern", 3)
  me.setLandscapePreview("pattern", 0)
end

on setWallPaper me, ttype, tChange
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return error(me, "Couldn't access catalogue window!", #setWallPaper, #major)
  end if
  if ttype = "pattern" then
    pWallPattern = pWallPattern + tChange
    if pWallPattern > pWallPatterns.count then
      pWallPattern = 1
    else
      if pWallPattern < 1 then
        pWallPattern = pWallPatterns.count
      end if
    end if
    pWallModel = 1
    tElemPrev = tWndObj.getElement("ctlg_wall_color_prev")
    tElemNext = tWndObj.getElement("ctlg_wall_color_next")
    if ilk(pWallPatterns.getaProp(pWallPattern)) <> #propList then
      return 0
    end if
    if pWallPatterns[pWallPattern].count < 2 then
      tElemPrev.deactivate()
      tElemNext.deactivate()
    else
      tElemPrev.Activate()
      tElemNext.Activate()
    end if
  else
    if ttype = "model" then
      pWallModel = pWallModel + tChange
      if pWallModel > pWallPatterns[pWallPattern].count then
        pWallModel = 1
      else
        if pWallModel < 1 then
          pWallModel = pWallPatterns[pWallPattern].count
        end if
      end if
    end if
  end if
  tWallData = pWallPatterns[pWallPattern][string(pWallModel)]
  ttype = tWallData[#patternID]
  tPalette = tWallData[#palette]
  tColor = tWallData[#rgb]
  tColors = ["left": tColor - rgb(16, 16, 16), "right": tColor, "a": tColor - rgb(16, 16, 16), "b": tColor, "pattern": tColor]
  pWallProps = tWallData.duplicate()
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat with tID in pWallPreviewIdList
    tPiece = tID.item[tID.item.count]
    tMem = "catalog_spaces_wall" & ttype & "_" & tPiece
    if memberExists(tMem) then
      if tWndObj.elementExists(tID) then
        tmember = member(getmemnum(tMem))
        tmember.paletteRef = member(getmemnum(tPalette))
        tImg = tmember.image
        tElem = tWndObj.getElement(tID)
        tDestImg = tElem.getProperty(#image)
        tRect = tDestImg.rect
        tMatte = tImg.createMatte()
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage: tMatte, #ink: 41, #bgColor: tColors[tPiece]])
        tElem.feedImage(tDestImg)
      end if
      next repeat
    end if
    error(me, "Wall member not found:" && "catalog_spaces_wall" & ttype & "_" & tPiece, #setWallPaper, #minor)
  end repeat
  the itemDelimiter = tDelim
  tPrice = tWallData["price"]
  tElemName = "ctlg_wall_price"
  if not voidp(tPrice) then
    if tWndObj.elementExists(tElemName) then
      if value(tPrice) > 0 then
        tText = tPrice && getText("credits", "credits")
        tWndObj.getElement(tElemName).setText(tText)
      end if
    end if
  end if
  return 1
end

on setFloorPattern me, ttype, tChange
  if ttype = "pattern" then
    pFloorPattern = pFloorPattern + tChange
    if pFloorPattern > pFloorPatterns.line.count then
      pFloorPattern = 1
    else
      if pFloorPattern < 1 then
        pFloorPattern = pFloorPatterns.line.count
      end if
    end if
    pFloorModel = 1
  else
    if ttype = "model" then
      pFloorModel = pFloorModel + tChange
      if pFloorModel > field(pFloorPatterns.line[pFloorPattern]).line.count then
        pFloorModel = 1
      else
        if pFloorModel < 1 then
          pFloorModel = field(pFloorPatterns.line[pFloorPattern]).line.count
        end if
      end if
    end if
  end if
  tmodel = field(pFloorPatterns.line[pFloorPattern])
  tPattern = tmodel.line[pFloorModel]
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.item[1].char[1]
  tPalette = tPattern.item[2]
  tR = integer(tPattern.item[3])
  tG = integer(tPattern.item[4])
  tB = integer(tPattern.item[5])
  tColor = rgb(tR, tG, tB)
  pFloorProps["extra_parm"] = tPattern.item[6]
  the itemDelimiter = "_"
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return error(me, "Couldn't access catalogue window!", #setFloorPattern, #major)
  end if
  repeat with tID in pFloorPreviewIdList
    tPiece = tID.item[tID.item.count]
    tMem = "catalog_spaces_floor" & ttype & "_" & tPiece
    if memberExists(tMem) then
      if tWndObj.elementExists(tID) then
        tmember = member(getmemnum(tMem))
        tmember.paletteRef = member(getmemnum(tPalette))
        tImg = tmember.image
        tElem = tWndObj.getElement(tID)
        tDestImg = tElem.getProperty(#image)
        tRect = tDestImg.rect
        tMatte = tImg.createMatte()
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage: tMatte, #ink: 41, #bgColor: tColor])
        tElem.feedImage(tDestImg)
      end if
      next repeat
    end if
    error(me, "Wall member not found:" && "catalog_spaces_floor" & ttype & "_" & tPiece, #setFloorPattern, #minor)
  end repeat
  the itemDelimiter = tDelim
  tPrice = pFloorProps["price"]
  tElemName = "ctlg_floor_price"
  if not voidp(tPrice) then
    if tWndObj.elementExists(tElemName) then
      if value(tPrice) > 0 then
        tText = tPrice && getText("credits", "credits")
        tWndObj.getElement(tElemName).setText(tText)
      end if
    end if
  end if
  return 1
end

on GetLsProductOffset me, tNumber
  repeat with i = 1 to pLandscapeProducts.count
    if string(tNumber) = pLandscapeProducts.getPropAt(i) then
      return i
    end if
  end repeat
  return VOID
end

on ComboIsBlocked me, tLandscape, tGradient
  repeat with tCombo in pLandscapeBlockedCombos
    if (tLandscape = tCombo[1]) and (tGradient = tCombo[2]) then
      return 1
    end if
  end repeat
  return 0
end

on availableGradientsCount me, tLandscape
  tGradientsCount = pLandscapeGradients.count
  repeat with tCombo in pLandscapeBlockedCombos
    if tLandscape = tCombo[1] then
      tGradientsCount = tGradientsCount - 1
    end if
  end repeat
  return tGradientsCount
end

on setLandscapePreview me, ttype, tChange
  tCurrent = me.GetLsProductOffset(pLandscapePattern)
  if voidp(tCurrent) then
    tCurrent = 1 - tChange
  end if
  if pLandscapeProducts.count < 1 then
    return 0
  end if
  if ttype = "pattern" then
    tNext = tCurrent + tChange
    if tNext > pLandscapeProducts.count then
      tNext = 1
    else
      if tNext < 1 then
        tNext = pLandscapeProducts.count
      end if
    end if
    pLandscapePattern = integer(pLandscapeProducts.getPropAt(tNext))
    if me.ComboIsBlocked(pLandscapePattern, pLandscapeGradient) then
      tGradient = 1
      repeat while me.ComboIsBlocked(pLandscapePattern, tGradient)
        tGradient = tGradient + 1
      end repeat
      pLandscapeGradient = tGradient
    end if
  else
    if ttype = "gradient" then
      pLandscapeGradient = pLandscapeGradient + tChange
      repeat while me.ComboIsBlocked(pLandscapePattern, pLandscapeGradient)
        pLandscapeGradient = pLandscapeGradient + tChange
        if pLandscapeGradient > pLandscapeGradients.count then
          pLandscapeGradient = 1
          next repeat
        end if
        if pLandscapeGradient < 1 then
          pLandscapeGradient = pLandscapeGradients.count
        end if
      end repeat
      if pLandscapeGradient > pLandscapeGradients.count then
        pLandscapeGradient = 1
      else
        if pLandscapeGradient < 1 then
          pLandscapeGradient = pLandscapeGradients.count
        end if
      end if
    end if
  end if
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return error(me, "Couldn't access catalogue window!", #setLandscapePreview, #major)
  end if
  tElemPrev = tWndObj.getElement("ctlg_landscape_color_prev")
  tElemNext = tWndObj.getElement("ctlg_landscape_color_next")
  if me.availableGradientsCount(pLandscapePattern) < 2 then
    tElemPrev.deactivate()
    tElemNext.deactivate()
  else
    tElemPrev.Activate()
    tElemNext.Activate()
  end if
  tLandscapeProps = pLandscapeProducts.getaProp(string(pLandscapePattern))
  if not voidp(tLandscapeProps) then
    pLandscapeProps = tLandscapeProps.duplicate()
    pLandscapeProps["extra_parm"] = string(pLandscapeGradient) & "." & string(pLandscapePattern)
    tPrice = pLandscapeProps["price"]
  else
    tPrice = 0
  end if
  tElemName = "ctlg_landscape_price"
  if not voidp(tPrice) then
    if tWndObj.elementExists(tElemName) then
      if value(tPrice) > 0 then
        tText = tPrice && getText("credits", "credits")
        tWndObj.getElement(tElemName).setText(tText)
      else
        tText = "N/A"
        tWndObj.getElement(tElemName).setText(tText)
      end if
    end if
  end if
  tElement = tWndObj.getElement(pLandscapeElement)
  tBuffer = image(tElement.getProperty(#width), tElement.getProperty(#height), 32)
  tBuffer.fill(tBuffer.rect, [#shapeType: #rect, #color: rgb("#FFFFFF")])
  tRenderCount = 8
  tRenderOffsetRect = rect(16, 4, 16, 4)
  tSrc = getMember(pLandscapeGradients[pLandscapeGradient]).image
  tClipAmount = 88
  tdestrect = rect(0, 0, tSrc.width, tSrc.height)
  repeat with i = 1 to tRenderCount
    tSrcRect = rect(0, 0, tSrc.width, tSrc.height)
    tOldDest = tdestrect.duplicate()
    tdestrect.bottom = tdestrect.bottom - tClipAmount
    tdestrect.top = tdestrect.top - tClipAmount
    if tdestrect.top < 0 then
      tdestrect.top = 0
    end if
    tSrcRect.top = tSrcRect.height - tdestrect.height
    tBuffer.copyPixels(tSrc, tdestrect, tSrcRect, [#useFastQuads: 1, #ink: #copy])
    tdestrect = tOldDest
    tdestrect = tdestrect + tRenderOffsetRect
    tClipAmount = tClipAmount - tRenderOffsetRect.top
    if tClipAmount < 0 then
      tClipAmount = 0
    end if
  end repeat
  if (pLandscapePattern <= pLandscapePatterns.count) and (pLandscapePattern > 0) then
    tSrc = getMember(pLandscapePatterns[pLandscapePattern]).image
    tdestrect = rect(0, 0, tBuffer.width, tBuffer.height)
    tBuffer.copyPixels(tSrc, tdestrect, tdestrect, [#useFastQuads: 1, #ink: 36])
  end if
  tMask = createMask(getMember(pLandscapePreviewIdList[2]).image)
  tBuffer.copyPixels(getMember(pLandscapePreviewIdList[1]).image, tdestrect, tdestrect, [#useFastQuads: 1, #ink: #copy, #maskImage: tMask])
  tBuffer.setAlpha(getMember(pLandscapePreviewIdList[3]).image)
  tBuffer.useAlpha = 1
  tElement.pSprite.member.image = tBuffer
  tElement.pSprite.member.useAlpha = 1
  tElement.pSprite.member.regPoint = point(0, 0)
end

on eventProc me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    if tSprID = "close" then
      return 0
    end if
  end if
  if tEvent = #mouseDown then
    case tSprID of
      "ctlg_wall_pattern_prev":
        me.setWallPaper("pattern", -1)
      "ctlg_wall_pattern_next":
        me.setWallPaper("pattern", 1)
      "ctlg_wall_color_prev":
        me.setWallPaper("model", -1)
      "ctlg_wall_color_next":
        me.setWallPaper("model", 1)
      "ctlg_floor_pattern_prev":
        me.setFloorPattern("pattern", -1)
      "ctlg_floor_pattern_next":
        me.setFloorPattern("pattern", 1)
      "ctlg_floor_color_prev":
        me.setFloorPattern("model", -1)
      "ctlg_floor_color_next":
        me.setFloorPattern("model", 1)
      "ctlg_landscape_pattern_prev":
        me.setLandscapePreview("pattern", -1)
      "ctlg_landscape_pattern_next":
        me.setLandscapePreview("pattern", 1)
      "ctlg_landscape_color_prev":
        me.setLandscapePreview("gradient", -1)
      "ctlg_landscape_color_next":
        me.setLandscapePreview("gradient", 1)
      "ctlg_buy_wall":
        getThread(#catalogue).getComponent().checkProductOrder(pWallProps)
      "ctlg_buy_floor":
        getThread(#catalogue).getComponent().checkProductOrder(pFloorProps)
      "ctlg_buy_landscape":
        getThread(#catalogue).getComponent().checkProductOrder(pLandscapeProps)
      otherwise:
        return 0
    end case
  end if
  return 1
end
