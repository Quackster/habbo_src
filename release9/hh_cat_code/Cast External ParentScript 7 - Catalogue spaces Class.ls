property pWallPatterns, pWallPattern, pWallModel, pWallThumbSpr, pWallPreviewIdList, pFloorPatterns, pFloorPattern, pFloorModel, pFloorThumbSpr, pFloorPreviewIdList, pWallProps, pFloorProps

on construct me
  pWallPatterns = field("catalog_wallpattern_patterns")
  pWallPattern = 0
  pWallModel = 0
  pFloorPatterns = field("catalog_floorpattern_patterns")
  pFloorPattern = 0
  pFloorModel = 0
  pWallProps = [:]
  pFloorProps = [:]
  pFloorPreviewIdList = []
  pFloorPreviewIdList.add("catalog_thumb_floor_pattern")
  pFloorPreviewIdList.add("catalog_floor_preview_example")
  pWallPreviewIdList = []
  pWallPreviewIdList.add("catalog_thumb_wall_pattern")
  pWallPreviewIdList.add("catalog_wall_preview_a_left")
  pWallPreviewIdList.add("catalog_wall_preview_b_right")
  return 1
end

on define me, tPageProps
  if tPageProps.ilk <> #propList then
    return error(me, "Incorrect Catalogue page data", #define)
  end if
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return error(me, "Couldn't access catalogue window!", #define)
  end if
  if not voidp(tPageProps["productList"]) then
    if tPageProps["productList"].count < 2 then
      if tWndObj.elementExists("ctlg_buy_wall") then
        tWndObj.getElement("ctlg_buy_wall").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_buy_floor") then
        tWndObj.getElement("ctlg_buy_floor").setProperty(#visible, 0)
      end if
      return 0
    end if
    pWallProps = tPageProps["productList"][1]
    pFloorProps = tPageProps["productList"][2]
    tProductPrice = tPageProps["productList"][1]["price"]
    if not voidp(tProductPrice) then
      if tWndObj.elementExists("ctlg_price_1") then
        if value(tProductPrice) > 1 then
          tText = tProductPrice && getText("credits", "credits")
        else
          tText = tPageProps["price"] && getText("credit", "credit")
        end if
        tWndObj.getElement("ctlg_price_1").setText(tText)
      end if
    end if
  end if
  me.setWallPaper("pattern", 6)
  me.setFloorPattern("pattern", 3)
end

on setWallPaper me, ttype, tChange
  if ttype = "pattern" then
    pWallPattern = pWallPattern + tChange
    if pWallPattern > pWallPatterns.line.count then
      pWallPattern = 1
    else
      if pWallPattern < 1 then
        pWallPattern = pWallPatterns.line.count
      end if
    end if
    pWallModel = 1
  else
    if ttype = "model" then
      pWallModel = pWallModel + tChange
      if pWallModel > field(pWallPatterns.line[pWallPattern]).line.count then
        pWallModel = 1
      else
        if pWallModel < 1 then
          pWallModel = field(pWallPatterns.line[pWallPattern]).line.count
        end if
      end if
    end if
  end if
  tmodel = field(pWallPatterns.line[pWallPattern])
  tPattern = tmodel.line[pWallModel]
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.item[1].char[1]
  tPalette = tPattern.item[2]
  tR = integer(tPattern.item[3])
  tG = integer(tPattern.item[4])
  tB = integer(tPattern.item[5])
  tColor = rgb(tR, tG, tB)
  tColors = ["left": tColor - rgb(16, 16, 16), "right": tColor, "a": tColor - rgb(16, 16, 16), "b": tColor, "pattern": tColor]
  pWallProps["extra_parm"] = tPattern.item[6]
  the itemDelimiter = "_"
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return error(me, "Couldn't access catalogue window!", #setWallPaper)
  end if
  repeat with tid in pWallPreviewIdList
    tPiece = tid.item[tid.item.count]
    tMem = "catalog_spaces_wall" & ttype & "_" & tPiece
    if memberExists(tMem) then
      if tWndObj.elementExists(tid) then
        tmember = member(getmemnum(tMem))
        tmember.paletteRef = member(getmemnum(tPalette))
        tImg = tmember.image
        tElem = tWndObj.getElement(tid)
        tDestImg = tElem.getProperty(#image)
        tRect = tDestImg.rect
        tMatte = tImg.createMatte()
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage: tMatte, #ink: 41, #bgColor: tColors[tPiece]])
        tElem.feedImage(tDestImg)
      end if
      next repeat
    end if
    error(me, "Wall member not found:" && "catalog_spaces_wall" & ttype & "_" & tPiece)
  end repeat
  the itemDelimiter = tDelim
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
    return error(me, "Couldn't access catalogue window!", #setFloorPattern)
  end if
  repeat with tid in pFloorPreviewIdList
    tPiece = tid.item[tid.item.count]
    tMem = "catalog_spaces_floor" & ttype & "_" & tPiece
    if memberExists(tMem) then
      if tWndObj.elementExists(tid) then
        tmember = member(getmemnum(tMem))
        tmember.paletteRef = member(getmemnum(tPalette))
        tImg = tmember.image
        tElem = tWndObj.getElement(tid)
        tDestImg = tElem.getProperty(#image)
        tRect = tDestImg.rect
        tMatte = tImg.createMatte()
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage: tMatte, #ink: 41, #bgColor: tColor])
        tElem.feedImage(tDestImg)
      end if
      next repeat
    end if
    error(me, "Wall member not found:" && "catalog_spaces_floor" & ttype & "_" & tPiece)
  end repeat
  the itemDelimiter = tDelim
  return 1
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
      "ctlg_buy_wall":
        getThread(#catalogue).getComponent().checkProductOrder(pWallProps)
      "ctlg_buy_floor":
        getThread(#catalogue).getComponent().checkProductOrder(pFloorProps)
      otherwise:
        return 0
    end case
  end if
  return 1
end
