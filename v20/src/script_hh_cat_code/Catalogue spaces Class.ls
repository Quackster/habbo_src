on construct(me)
  pWallPatterns = []
  pWallPattern = 0
  pWallModel = 0
  pFloorPatterns = field(0)
  pFloorPattern = 0
  pFloorModel = 0
  pWallProps = []
  pFloorProps = []
  pFloorPreviewIdList = []
  pFloorPreviewIdList.add("catalog_thumb_floor_pattern")
  pFloorPreviewIdList.add("catalog_floor_preview_example")
  pWallPreviewIdList = []
  pWallPreviewIdList.add("catalog_thumb_wall_pattern")
  pWallPreviewIdList.add("catalog_wall_preview_a_left")
  pWallPreviewIdList.add("catalog_wall_preview_b_right")
  return(1)
  exit
end

on define(me, tPageProps)
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
      return(0)
    end if
    tItemNo = 1
    repeat while tItemNo <= tProdList.count
      tProp = tProdList.getAt(tItemNo)
      tClass = tProp.getAt("class")
      tClassPrefix = tClass.getProp(#word, 1)
      tClassPostfix = tClass.getProp(#word, 2)
      if tClassPrefix = "wallpaper" and tClassPostfix <> "" then
        tPatternNo = tClassPostfix
        tPatternMemName = tWallPatterns.getProp(#line, integer(tPatternNo))
        tModelsRawData = member(tPatternMemName).text
        if ilk(pWallPatterns.getAt(tPatternNo)) <> #propList then
          pWallPatterns.setAt(tPatternNo, [])
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
            tModelNo = 1 + tModelNo
          end if
        end repeat
        pWallPatterns.setAt(tPatternNo, tmodellist)
        the itemDelimiter = tDelim
      else
        if tClass = "floor" then
          pFloorProps = tProp
        end if
      end if
      tItemNo = 1 + tItemNo
    end repeat
  end if
  me.setWallPaper("pattern", 6)
  me.setFloorPattern("pattern", 3)
  exit
end

on setWallPaper(me, ttype, tChange)
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return(error(me, "Couldn't access catalogue window!", #setWallPaper, #major))
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
    if pWallPatterns.getAt(pWallPattern).count < 2 then
      tElemPrev.deactivate()
      tElemNext.deactivate()
    else
      tElemPrev.Activate()
      tElemNext.Activate()
    end if
  else
    if ttype = "model" then
      pWallModel = pWallModel + tChange
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
  tColors = ["left":tColor - rgb(16, 16, 16), "right":tColor, "a":tColor - rgb(16, 16, 16), "b":tColor, "pattern":tColor]
  pWallProps = tWallData
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat while me <= tChange
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
  return(1)
  exit
end

on setFloorPattern(me, ttype, tChange)
  if ttype = "pattern" then
    pFloorPattern = pFloorPattern + tChange
    if pFloorPattern > pFloorPatterns.count(#line) then
      pFloorPattern = 1
    else
      if pFloorPattern < 1 then
        pFloorPattern = pFloorPatterns.count(#line)
      end if
    end if
    pFloorModel = 1
  else
    if ttype = "model" then
      pFloorModel = pFloorModel + tChange
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
  repeat while me <= tChange
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
  return(1)
  exit
end

on eventProc(me, tEvent, tSprID, tProp)
  if tEvent = #mouseUp then
    if tSprID = "close" then
      return(0)
    end if
  end if
  if tEvent = #mouseDown then
    if me = "ctlg_wall_pattern_prev" then
      me.setWallPaper("pattern", -1)
    else
      if me = "ctlg_wall_pattern_next" then
        me.setWallPaper("pattern", 1)
      else
        if me = "ctlg_wall_color_prev" then
          me.setWallPaper("model", -1)
        else
          if me = "ctlg_wall_color_next" then
            me.setWallPaper("model", 1)
          else
            if me = "ctlg_floor_pattern_prev" then
              me.setFloorPattern("pattern", -1)
            else
              if me = "ctlg_floor_pattern_next" then
                me.setFloorPattern("pattern", 1)
              else
                if me = "ctlg_floor_color_prev" then
                  me.setFloorPattern("model", -1)
                else
                  if me = "ctlg_floor_color_next" then
                    me.setFloorPattern("model", 1)
                  else
                    if me = "ctlg_buy_wall" then
                      getThread(#catalogue).getComponent().checkProductOrder(pWallProps)
                    else
                      if me = "ctlg_buy_floor" then
                        getThread(#catalogue).getComponent().checkProductOrder(pFloorProps)
                      else
                        return(0)
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
  return(1)
  exit
end