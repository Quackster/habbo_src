property pFloorPreviewIdList, pWallPreviewIdList, pLandscapePreviewIdList, pLandscapePatterns, pLandscapeGradients, pLandscapeBlockedCombos, pWallPatterns, pLandscapeProducts, pWallPattern, pWallModel, pFloorPattern, pFloorPatterns, pFloorModel, pFloorProps, pLandscapePattern, pLandscapeGradient, pLandscapeProps, pLandscapeElement, pWallProps

on construct me 
  pWallPatterns = [:]
  pWallPattern = 0
  pWallModel = 0
  pFloorPatterns = field(0)
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
  tLandscapePatterns = field(0)
  tLandscapeGradients = field(0)
  pLandscapePatterns = []
  pLandscapeGradients = []
  i = 1
  repeat while i <= tLandscapePatterns.count(#line)
    pLandscapePatterns.add(tLandscapePatterns.getProp(#line, i))
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= tLandscapeGradients.count(#line)
    pLandscapeGradients.add(tLandscapeGradients.getProp(#line, i))
    i = (1 + i)
  end repeat
  pLandscapeBlockedCombos = []
  if memberExists("catalog_landscape_blocked_combinations") then
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    tBlockList = field(0)
    i = 1
    repeat while i <= tBlockList.count(#line)
      pLandscapeBlockedCombos.add([tBlockList.getPropRef(#line, i).getProp(#item, 1), tBlockList.getPropRef(#line, i).getProp(#item, 2)])
      i = (1 + i)
    end repeat
    the itemDelimiter = tDelim
  end if
  return TRUE
end

on define me, tPageProps 
  if tPageProps.ilk <> #propList then
    return(error(me, "Incorrect Catalogue page data", #define, #major))
  end if
  tWallPatterns = field(0)
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return(error(me, "Couldn't access catalogue window!", #define, #major))
  end if
  tProdList = tPageProps.getAt("productList")
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
      return FALSE
    end if
    tItemNo = 1
    repeat while tItemNo <= tProdList.count
      tProp = tProdList.getAt(tItemNo)
      tClass = tProp.getAt("class")
      tClassPrefix = tClass.getProp(#word, 1)
      tClassPostfix = tClass.getProp(#word, 2)
      if (tClassPrefix = "wallpaper") and tClassPostfix <> "" then
        tPatternNo = tClassPostfix
        tPatternMemName = tWallPatterns.getProp(#line, integer(tPatternNo))
        tModelsRawData = member(tPatternMemName).text
        if ilk(pWallPatterns.getAt(tPatternNo)) <> #propList then
          pWallPatterns.setAt(tPatternNo, [:])
        end if
        tmodellist = pWallPatterns.getAt(tPatternNo).duplicate()
        tDelim = the itemDelimiter
        the itemDelimiter = ","
        tModelNo = 1
        repeat while tModelNo <= tModelsRawData.count(#line)
          tModelDataLn = tModelsRawData.getProp(#line, tModelNo)
          if tModelDataLn.count(#item) < 5 then
          else
            tPatternID = tModelDataLn.getProp(#item, 1)
            tPalette = tModelDataLn.getProp(#item, 2)
            tRed = integer(tModelDataLn.getProp(#item, 3))
            tGreen = integer(tModelDataLn.getProp(#item, 4))
            tBlue = integer(tModelDataLn.getProp(#item, 5))
            tRGB = rgb(tRed, tGreen, tBlue)
            tTempModelNo = tModelNo
            if tModelNo < 10 then
              tTempModelNo = "0" & tModelNo
            end if
            tPaperID = tPatternNo & "" & tTempModelNo
            tModelProps = tProp.duplicate()
            tModelProps.setAt("extra_parm", tPaperID)
            tModelProps.setAt(#patternID, tPatternID)
            tModelProps.setAt(#rgb, tRGB)
            tModelProps.setAt(#palette, tPalette)
            tmodellist.setAt(string(tModelNo), tModelProps)
            tModelNo = (1 + tModelNo)
          end if
        end repeat
        pWallPatterns.setAt(tPatternNo, tmodellist)
        the itemDelimiter = tDelim
      else
        if (tClass = "floor") then
          pFloorProps = tProp
        else
          if (tClassPrefix = "landscape") then
            tPatternNo = tClassPostfix
            if tPatternNo <= pLandscapePatterns.count then
              if (tPatternNo = 0) then
                tPatternMemName = ""
              else
                tPatternMemName = pLandscapePatterns.getAt(integer(tPatternNo))
              end if
              tLandscapeProps = tProp.duplicate()
              tLandscapeProps.setAt("extra_parm", "1." & tPatternNo)
              tLandscapeProps.setAt(#patternID, tPatternNo)
              pLandscapeProducts.setAt(string(tPatternNo), tLandscapeProps)
            end if
          end if
        end if
      end if
      tItemNo = (1 + tItemNo)
    end repeat
  end if
  me.setWallPaper("pattern", 6)
  me.setFloorPattern("pattern", 3)
  me.setLandscapePreview("pattern", 0)
end

on setWallPaper me, ttype, tChange 
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return(error(me, "Couldn't access catalogue window!", #setWallPaper, #major))
  end if
  if (ttype = "pattern") then
    pWallPattern = (pWallPattern + tChange)
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
    if pWallPatterns.getAt(pWallPattern).count < 2 then
      tElemPrev.deactivate()
      tElemNext.deactivate()
    else
      tElemPrev.Activate()
      tElemNext.Activate()
    end if
  else
    if (ttype = "model") then
      pWallModel = (pWallModel + tChange)
      if pWallModel > pWallPatterns.getAt(pWallPattern).count then
        pWallModel = 1
      else
        if pWallModel < 1 then
          pWallModel = pWallPatterns.getAt(pWallPattern).count
        end if
      end if
    end if
  end if
  tWallData = pWallPatterns.getAt(pWallPattern).getAt(string(pWallModel))
  ttype = tWallData.getAt(#patternID)
  tPalette = tWallData.getAt(#palette)
  tColor = tWallData.getAt(#rgb)
  tColors = ["left":(tColor - rgb(16, 16, 16)), "right":tColor, "a":(tColor - rgb(16, 16, 16)), "b":tColor, "pattern":tColor]
  pWallProps = tWallData
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat while pWallPreviewIdList <= tChange
    tID = getAt(tChange, ttype)
    tPiece = tID.getProp(#item, tID.count(#item))
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
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage:tMatte, #ink:41, #bgColor:tColors.getAt(tPiece)])
        tElem.feedImage(tDestImg)
      end if
    else
      error(me, "Wall member not found:" && "catalog_spaces_wall" & ttype & "_" & tPiece, #setWallPaper, #minor)
    end if
  end repeat
  the itemDelimiter = tDelim
  tPrice = tWallData.getAt("price")
  tElemName = "ctlg_wall_price"
  if not voidp(tPrice) then
    if tWndObj.elementExists(tElemName) then
      if value(tPrice) > 0 then
        tText = tPrice && getText("credits", "credits")
        tWndObj.getElement(tElemName).setText(tText)
      end if
    end if
  end if
  return TRUE
end

on setFloorPattern me, ttype, tChange 
  if (ttype = "pattern") then
    pFloorPattern = (pFloorPattern + tChange)
    if pFloorPattern > pFloorPatterns.count(#line) then
      pFloorPattern = 1
    else
      if pFloorPattern < 1 then
        pFloorPattern = pFloorPatterns.count(#line)
      end if
    end if
    pFloorModel = 1
  else
    if (ttype = "model") then
      pFloorModel = (pFloorModel + tChange)
      if pFloorPatterns.getProp(#line, pFloorPattern) > field(0).count(#line) then
        pFloorModel = 1
      else
        if pFloorModel < 1 then
          pFloorModel = field(0).count(#line)
        end if
      end if
    end if
  end if
  tmodel = field(0)
  tPattern = tmodel.getProp(#line, pFloorModel)
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.getPropRef(#item, 1).getProp(#char, 1)
  tPalette = tPattern.getProp(#item, 2)
  tR = integer(tPattern.getProp(#item, 3))
  tG = integer(tPattern.getProp(#item, 4))
  tB = integer(tPattern.getProp(#item, 5))
  tColor = rgb(tR, tG, tB)
  pFloorProps.setAt("extra_parm", tPattern.getProp(#item, 6))
  the itemDelimiter = "_"
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return(error(me, "Couldn't access catalogue window!", #setFloorPattern, #major))
  end if
  repeat while pFloorModel <= tChange
    tID = getAt(tChange, ttype)
    tPiece = tID.getProp(#item, tID.count(#item))
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
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage:tMatte, #ink:41, #bgColor:tColor])
        tElem.feedImage(tDestImg)
      end if
    else
      error(me, "Wall member not found:" && "catalog_spaces_floor" & ttype & "_" & tPiece, #setFloorPattern, #minor)
    end if
  end repeat
  the itemDelimiter = tDelim
  tPrice = pFloorProps.getAt("price")
  tElemName = "ctlg_floor_price"
  if not voidp(tPrice) then
    if tWndObj.elementExists(tElemName) then
      if value(tPrice) > 0 then
        tText = tPrice && getText("credits", "credits")
        tWndObj.getElement(tElemName).setText(tText)
      end if
    end if
  end if
  return TRUE
end

on GetLsProductOffset me, tNumber 
  i = 1
  repeat while i <= pLandscapeProducts.count
    if (string(tNumber) = pLandscapeProducts.getPropAt(i)) then
      return(i)
    end if
    i = (1 + i)
  end repeat
  return(void())
end

on ComboIsBlocked me, tLandscape, tGradient 
  repeat while pLandscapeBlockedCombos <= tGradient
    tCombo = getAt(tGradient, tLandscape)
    if (tLandscape = tCombo.getAt(1)) and (tGradient = tCombo.getAt(2)) then
      return TRUE
    end if
  end repeat
  return FALSE
end

on availableGradientsCount me, tLandscape 
  tGradientsCount = pLandscapeGradients.count
  repeat while pLandscapeBlockedCombos <= undefined
    tCombo = getAt(undefined, tLandscape)
    if (tLandscape = tCombo.getAt(1)) then
      tGradientsCount = (tGradientsCount - 1)
    end if
  end repeat
  return(tGradientsCount)
end

on setLandscapePreview me, ttype, tChange 
  tCurrent = me.GetLsProductOffset(pLandscapePattern)
  if voidp(tCurrent) then
    tCurrent = (1 - tChange)
  end if
  if pLandscapeProducts.count < 1 then
    return FALSE
  end if
  if (ttype = "pattern") then
    tNext = (tCurrent + tChange)
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
        tGradient = (tGradient + 1)
      end repeat
      pLandscapeGradient = tGradient
    end if
  else
    if (ttype = "gradient") then
      pLandscapeGradient = (pLandscapeGradient + tChange)
      repeat while me.ComboIsBlocked(pLandscapePattern, pLandscapeGradient)
        pLandscapeGradient = (pLandscapeGradient + tChange)
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
    return(error(me, "Couldn't access catalogue window!", #setLandscapePreview, #major))
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
  pLandscapeProps = pLandscapeProducts.getaProp(string(pLandscapePattern))
  if not voidp(pLandscapeProps) then
    pLandscapeProps = pLandscapeProps.duplicate()
    pLandscapeProps.setAt("extra_parm", string(pLandscapeGradient) & "." & string(pLandscapePattern))
    tPrice = pLandscapeProps.getAt("price")
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
  tBuffer.fill(tBuffer.rect, [#shapeType:#rect, #color:rgb("#FFFFFF")])
  tRenderCount = 8
  tRenderOffsetRect = rect(16, 4, 16, 4)
  tSrc = getMember(pLandscapeGradients.getAt(pLandscapeGradient)).image
  tClipAmount = 88
  tdestrect = rect(0, 0, tSrc.width, tSrc.height)
  i = 1
  repeat while i <= tRenderCount
    tSrcRect = rect(0, 0, tSrc.width, tSrc.height)
    tOldDest = tdestrect.duplicate()
    tdestrect.bottom = (tdestrect.bottom - tClipAmount)
    tdestrect.top = (tdestrect.top - tClipAmount)
    if tdestrect.top < 0 then
      tdestrect.top = 0
    end if
    tSrcRect.top = (tSrcRect.height - tdestrect.height)
    tBuffer.copyPixels(tSrc, tdestrect, tSrcRect, [#useFastQuads:1, #ink:#copy])
    tdestrect = tOldDest
    tdestrect = (tdestrect + tRenderOffsetRect)
    tClipAmount = (tClipAmount - tRenderOffsetRect.top)
    if tClipAmount < 0 then
      tClipAmount = 0
    end if
    i = (1 + i)
  end repeat
  if pLandscapePattern <= pLandscapePatterns.count and pLandscapePattern > 0 then
    tSrc = getMember(pLandscapePatterns.getAt(pLandscapePattern)).image
    tdestrect = rect(0, 0, tBuffer.width, tBuffer.height)
    tBuffer.copyPixels(tSrc, tdestrect, tdestrect, [#useFastQuads:1, #ink:36])
  end if
  tMask = createMask(getMember(pLandscapePreviewIdList.getAt(2)).image)
  tBuffer.copyPixels(getMember(pLandscapePreviewIdList.getAt(1)).image, tdestrect, tdestrect, [#useFastQuads:1, #ink:#copy, #maskImage:tMask])
  tBuffer.setAlpha(getMember(pLandscapePreviewIdList.getAt(3)).image)
  tBuffer.useAlpha = 1
  tElement.pSprite.member.image = tBuffer
  tElement.pSprite.member.useAlpha = 1
  tElement.pSprite.member.regPoint = point(0, 0)
end

on eventProc me, tEvent, tSprID, tProp 
  if (tEvent = #mouseUp) then
    if (tSprID = "close") then
      return FALSE
    end if
  end if
  if (tEvent = #mouseDown) then
    if (tSprID = "ctlg_wall_pattern_prev") then
      me.setWallPaper("pattern", -1)
    else
      if (tSprID = "ctlg_wall_pattern_next") then
        me.setWallPaper("pattern", 1)
      else
        if (tSprID = "ctlg_wall_color_prev") then
          me.setWallPaper("model", -1)
        else
          if (tSprID = "ctlg_wall_color_next") then
            me.setWallPaper("model", 1)
          else
            if (tSprID = "ctlg_floor_pattern_prev") then
              me.setFloorPattern("pattern", -1)
            else
              if (tSprID = "ctlg_floor_pattern_next") then
                me.setFloorPattern("pattern", 1)
              else
                if (tSprID = "ctlg_floor_color_prev") then
                  me.setFloorPattern("model", -1)
                else
                  if (tSprID = "ctlg_floor_color_next") then
                    me.setFloorPattern("model", 1)
                  else
                    if (tSprID = "ctlg_landscape_pattern_prev") then
                      me.setLandscapePreview("pattern", -1)
                    else
                      if (tSprID = "ctlg_landscape_pattern_next") then
                        me.setLandscapePreview("pattern", 1)
                      else
                        if (tSprID = "ctlg_landscape_color_prev") then
                          me.setLandscapePreview("gradient", -1)
                        else
                          if (tSprID = "ctlg_landscape_color_next") then
                            me.setLandscapePreview("gradient", 1)
                          else
                            if (tSprID = "ctlg_buy_wall") then
                              getThread(#catalogue).getComponent().checkProductOrder(pWallProps)
                            else
                              if (tSprID = "ctlg_buy_floor") then
                                getThread(#catalogue).getComponent().checkProductOrder(pFloorProps)
                              else
                                if (tSprID = "ctlg_buy_landscape") then
                                  getThread(#catalogue).getComponent().checkProductOrder(pLandscapeProps)
                                else
                                  return FALSE
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return TRUE
end
