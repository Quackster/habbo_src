property pFloorPreviewIdList, pWallPreviewIdList, pWallPattern, pWallPatterns, pWallModel, pWallProps, pFloorPattern, pFloorPatterns, pFloorModel, pFloorProps

on construct me 
  pWallPatterns = field(0)
  pWallPattern = 0
  pWallModel = 0
  pFloorPatterns = field(0)
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
  me.setWallPaper("pattern", 1)
  me.setFloorPattern("pattern", 1)
  return(1)
end

on define me, tPageProps 
  if tPageProps.ilk <> #propList then
    return(error(me, "Incorrect Catalogue page data", #define))
  end if
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return(error(me, "Couldn't access catalogue window!", #define))
  end if
  if not voidp(tPageProps.getAt("productList")) then
    if tPageProps.getAt("productList").count < 2 then
      if tWndObj.elementExists("ctlg_buy_wall") then
        tWndObj.getElement("ctlg_buy_wall").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_buy_floor") then
        tWndObj.getElement("ctlg_buy_floor").setProperty(#visible, 0)
      end if
      return(0)
    end if
    pWallProps = tPageProps.getAt("productList").getAt(1)
    pFloorProps = tPageProps.getAt("productList").getAt(2)
    tProductPrice = tPageProps.getAt("productList").getAt(1).getAt("price")
    if not voidp(tProductPrice) then
      if tWndObj.elementExists("ctlg_price_1") then
        if value(tProductPrice) > 1 then
          tText = tProductPrice && getText("credits", "credits")
        else
          tText = tPageProps.getAt("price") && getText("credit", "credit")
        end if
        tWndObj.getElement("ctlg_price_1").setText(tText)
      end if
    end if
  end if
end

on setWallPaper me, ttype, tChange 
  if ttype = "pattern" then
    pWallPattern = pWallPattern + tChange
    if pWallPattern > pWallPatterns.count(#line) then
      pWallPattern = 1
    else
      if pWallPattern < 1 then
        pWallPattern = pWallPatterns.count(#line)
      end if
    end if
    pWallModel = 1
  else
    if ttype = "model" then
      pWallModel = pWallModel + tChange
      if pWallPatterns.getProp(#line, pWallPattern) > field(0).count(#line) then
        pWallModel = 1
      else
        if pWallModel < 1 then
          pWallModel = field(0).count(#line)
        end if
      end if
    end if
  end if
  tmodel = field(0)
  tPattern = tmodel.getProp(#line, pWallModel)
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.getPropRef(#item, 1).getProp(#char, 1)
  tPalette = tPattern.getProp(#item, 2)
  tR = integer(tPattern.getProp(#item, 3))
  tG = integer(tPattern.getProp(#item, 4))
  tB = integer(tPattern.getProp(#item, 5))
  tColor = rgb(tR, tG, tB)
  tColors = ["left":tColor - rgb(16, 16, 16), "right":tColor, "a":tColor - rgb(16, 16, 16), "b":tColor, "pattern":tColor]
  pWallProps.setAt("extra_parm", tPattern.getProp(#item, 6))
  the itemDelimiter = "_"
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWndObj then
    return(error(me, "Couldn't access catalogue window!", #setWallPaper))
  end if
  repeat while pWallModel <= tChange
    tid = getAt(tChange, ttype)
    tPiece = tid.getProp(#item, tid.count(#item))
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
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage:tMatte, #ink:41, #bgColor:tColors.getAt(tPiece)])
        tElem.feedImage(tDestImg)
      end if
    else
      error(me, "Wall member not found:" && "catalog_spaces_wall" & ttype & "_" & tPiece)
    end if
  end repeat
  the itemDelimiter = tDelim
  return(1)
end

on setFloorPattern me, ttype, tChange 
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
    return(error(me, "Couldn't access catalogue window!", #setFloorPattern))
  end if
  repeat while pFloorModel <= tChange
    tid = getAt(tChange, ttype)
    tPiece = tid.getProp(#item, tid.count(#item))
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
        tDestImg.copyPixels(tImg, tRect, tImg.rect, [#maskImage:tMatte, #ink:41, #bgColor:tColor])
        tElem.feedImage(tDestImg)
      end if
    else
      error(me, "Wall member not found:" && "catalog_spaces_floor" & ttype & "_" & tPiece)
    end if
  end repeat
  the itemDelimiter = tDelim
  return(1)
end

on eventProc me, tEvent, tSprID, tProp 
  if tEvent = #mouseDown then
    if tSprID = "ctlg_wall_pattern_prev" then
      me.setWallPaper("pattern", -1)
    else
      if tSprID = "ctlg_wall_pattern_next" then
        me.setWallPaper("pattern", 1)
      else
        if tSprID = "ctlg_wall_color_prev" then
          me.setWallPaper("model", -1)
        else
          if tSprID = "ctlg_wall_color_next" then
            me.setWallPaper("model", 1)
          else
            if tSprID = "ctlg_floor_pattern_prev" then
              me.setFloorPattern("pattern", -1)
            else
              if tSprID = "ctlg_floor_pattern_next" then
                me.setFloorPattern("pattern", 1)
              else
                if tSprID = "ctlg_floor_color_prev" then
                  me.setFloorPattern("model", -1)
                else
                  if tSprID = "ctlg_floor_color_next" then
                    me.setFloorPattern("model", 1)
                  else
                    if tSprID = "ctlg_buy_wall" then
                      getThread(#catalogue).getComponent().checkProductOrder(pWallProps)
                    else
                      if tSprID = "ctlg_buy_floor" then
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
end
