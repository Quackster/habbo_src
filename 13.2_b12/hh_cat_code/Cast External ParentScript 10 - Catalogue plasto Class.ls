property pPageData, pSmallImg, pSelectedOrderNum, pSelectedColorNum, pSelectedProduct, pLastProductNum, pNumOfColorBoxies

on construct me
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #construct)
  end if
  pPageData = [:]
  pSmallImg = image(32, 32, 24)
  pSelectedOrderNum = 1
  pSelectedColorNum = 1
  pLastProductNum = 0
  pNumOfColorBoxies = 0
  repeat with f = 1 to 50
    tid = "ctlg_selectcolor_bg_" & f
    if tCataloguePage.elementExists(tid) then
      pNumOfColorBoxies = pNumOfColorBoxies + 1
      next repeat
    end if
    exit repeat
  end repeat
  return 1
end

on define me, tPageProps
  if tPageProps.ilk <> #propList then
    return error(me, "Incorrect Catalogue page data", #define)
  end if
  pPageData = [:]
  pPageData.sort()
  if not voidp(tPageProps["productList"]) then
    tProducts = tPageProps["productList"]
    aa = the milliSeconds
    repeat with f = 1 to tProducts.count
      if not voidp(tProducts[f]["class"]) then
        tClass = tProducts[f]["class"]
        if tClass contains "*" then
          tClass = tClass.char[1..offset("*", tClass) - 1]
        end if
        if voidp(pPageData[tClass]) then
          pPageData[tClass] = [:]
          pPageData[tClass].sort()
        end if
        pPageData[tClass].addProp(tProducts[f]["class"], tProducts[f])
      end if
    end repeat
  end if
  if pPageData.count > 1 then
    pSelectedOrderNum = 1
    pSelectedColorNum = 1
    renderSmallIcons(me)
    selectProduct(me, 1)
    renderProductColors(me, 1)
  end if
end

on renderSmallIcons me, tstate, tPram
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #renderSmallIcons)
  end if
  tWndObj = tCataloguePage
  case tstate of
    VOID:
      tFirst = 1
      tLast = pPageData.count
      repeat with f = 1 to pPageData.count
        tid = "ctlg_small_img_" & f
        if tWndObj.elementExists(tid) then
          tWndObj.getElement(tid).clearImage()
          tWndObj.getElement(tid).setProperty(#ink, 36)
        end if
      end repeat
    #hilite, #unhilite:
      tFirst = tPram
      tLast = tPram
    otherwise:
      return error(me, "unsupported mode", #ShowSmallIcons)
  end case
  if voidp(tFirst) or voidp(tLast) then
    return 
  end if
  if (tFirst < 1) or (tLast < 1) then
    return 
  end if
  repeat with f = tFirst to tLast
    if not voidp(pPageData[f][1]["smallPrewImg"]) then
      tmember = pPageData[f][1]["smallPrewImg"]
      tid = "ctlg_small_img_" & f
      if tmember <> 0 then
        if tWndObj.elementExists(tid) then
          pSmallImg.fill(pSmallImg.rect, rgb(255, 255, 255))
          if not voidp(tstate) then
            if (tstate = #hilite) and memberExists("ctlg_small_active2_bg") then
              tBgImage = member("ctlg_small_active2_bg").image
              pSmallImg.copyPixels(tBgImage, tBgImage.rect, pSmallImg.rect)
            end if
          end if
          tTempSmallImg = member(tmember).image
          tdestrect = pSmallImg.rect - tTempSmallImg.rect
          tMargins = rect(0, 0, 0, 0)
          tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempSmallImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tTempSmallImg.height) + tMargins
          pSmallImg.copyPixels(tTempSmallImg, tdestrect, tTempSmallImg.rect, [#ink: 36])
          tWndObj.getElement(tid).clearImage()
          tWndObj.getElement(tid).feedImage(pSmallImg)
        end if
      end if
    end if
  end repeat
end

on renderProductColors me, tOrderNum
  if not integerp(tOrderNum) then
    return error(me, "Incorrect value", #renderProductColors)
  end if
  if pPageData.ilk <> #propList then
    return error(me, "page data not found", #renderProductColors)
  end if
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #construct)
  end if
  tWndObj = tCataloguePage
  repeat with f = 1 to pNumOfColorBoxies
    tid = "ctlg_selectcolor_bg_" & f
    if tCataloguePage.elementExists(tid) then
      tColor = paletteIndex(0)
      tWndObj.getElement(tid).setProperty(#bgColor, tColor)
      tWndObj.getElement(tid).setProperty(#blend, 30)
    end if
    tid = "ctlg_selectcolor_" & f
    if tCataloguePage.elementExists(tid) then
      tWndObj.getElement(tid).setProperty(#blend, 30)
    end if
  end repeat
  if tOrderNum <= pPageData.count then
    tProducts = pPageData[tOrderNum]
    repeat with f = 1 to tProducts.count
      if not voidp(tProducts[f]["partColors"]) then
        tItemDeLimiter = the itemDelimiter
        the itemDelimiter = ","
        tColor = tProducts[f]["partColors"].item[tProducts[f]["partColors"].item.count]
        the itemDelimiter = tItemDeLimiter
        if tColor.char[1] = "#" then
          tColor = rgb(tColor)
        else
          tColor = paletteIndex(integer(tColor))
        end if
        tid = "ctlg_selectcolor_bg_" & f
        if tWndObj.elementExists(tid) then
          tWndObj.getElement(tid).setProperty(#bgColor, tColor)
          tWndObj.getElement(tid).setProperty(#blend, 100)
        end if
        tid = "ctlg_selectcolor_" & f
        if tCataloguePage.elementExists(tid) then
          tWndObj.getElement(tid).setProperty(#blend, 100)
        end if
      end if
    end repeat
  end if
end

on selectProduct me, tOrderNum
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #selectProduct)
  end if
  tWndObj = tCataloguePage
  if not integerp(tOrderNum) then
    return error(me, "Incorrect value", #selectProduct)
  end if
  if voidp(pPageData) then
    return error(me, "product not found", #selectProduct)
  end if
  if tOrderNum > pPageData.count then
    return 
  end if
  if voidp(pPageData[tOrderNum][1]) then
    return 
  end if
  pSelectedProduct = pPageData[tOrderNum][1]
  pSelectedColorNum = 1
  pSelectedOrderNum = tOrderNum
  renderProductColors(me, tOrderNum)
  getThread(#catalogue).getInterface().showPreviewImage(pSelectedProduct)
  if not voidp(pSelectedProduct["name"]) then
    if tWndObj.elementExists("ctlg_product_name") then
      tWndObj.getElement("ctlg_product_name").setText(pSelectedProduct["name"])
    end if
  end if
  if not voidp(pSelectedProduct["description"]) then
    if tWndObj.elementExists("ctlg_description") then
      tWndObj.getElement("ctlg_description").setText(pSelectedProduct["description"])
    end if
  end if
  if not voidp(pSelectedProduct["price"]) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct["price"]) > 1 then
        tText = pSelectedProduct["price"] && getText("credits", "credits")
      else
        tText = pSelectedProduct["price"] && getText("credit", "credit")
      end if
      tWndObj.getElement("ctlg_price_1").setText(tText)
    end if
  end if
  if tWndObj.elementExists("ctlg_buy_button") then
    tWndObj.getElement("ctlg_buy_button").setProperty(#visible, 1)
  end if
  renderSmallIcons(me, #hilite, tOrderNum)
  renderSmallIcons(me, #unhilite, pLastProductNum)
  pLastProductNum = pSelectedOrderNum
end

on selectColor me, tOrderNum
  if voidp(pSelectedOrderNum) then
    return 
  end if
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #selectColor)
  end if
  tWndObj = tCataloguePage
  if not integerp(pSelectedOrderNum) then
    return error(me, "Incorrect SelectedOrderNum", #selectColor)
  end if
  if not integerp(tOrderNum) then
    return error(me, "Incorrect value", #selectColor)
  end if
  if voidp(pPageData) then
    return error(me, "product not found", #selectColor)
  end if
  if voidp(pPageData[pSelectedOrderNum]) then
    return 
  end if
  if tOrderNum > pPageData[pSelectedOrderNum].count then
    return 
  end if
  pSelectedColorNum = tOrderNum
  pSelectedProduct = pPageData[pSelectedOrderNum][pSelectedColorNum]
  getThread(#catalogue).getInterface().showPreviewImage(pSelectedProduct)
  if not voidp(pSelectedProduct["name"]) then
    if tWndObj.elementExists("ctlg_product_name") then
      tWndObj.getElement("ctlg_product_name").setText(pSelectedProduct["name"])
    end if
  end if
  if not voidp(pSelectedProduct["description"]) then
    if tWndObj.elementExists("ctlg_description") then
      tWndObj.getElement("ctlg_description").setText(pSelectedProduct["description"])
    end if
  end if
  if not voidp(pSelectedProduct["price"]) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct["price"]) > 1 then
        tText = pSelectedProduct["price"] && getText("credits", "credits")
      else
        tText = pSelectedProduct["price"] && getText("credit", "credit")
      end if
      tWndObj.getElement("ctlg_price_1").setText(tText)
    end if
  end if
end

on eventProc me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    if tSprID = "close" then
      return 0
    end if
  end if
  if tEvent = #mouseDown then
    if tSprID contains "ctlg_small_img_" then
      tItemDeLimiter = the itemDelimiter
      the itemDelimiter = "_"
      tProductOrderNum = integer(tSprID.item[tSprID.item.count])
      the itemDelimiter = tItemDeLimiter
      selectProduct(me, tProductOrderNum)
    else
      if (tSprID contains "ctlg_selectcolor_") or (tSprID contains "ctlg_selectcolor_bg_10") then
        tItemDeLimiter = the itemDelimiter
        the itemDelimiter = "_"
        tOrderNum = integer(tSprID.item[tSprID.item.count])
        the itemDelimiter = tItemDeLimiter
        selectColor(me, tOrderNum)
      else
        if tSprID = "ctlg_buy_button" then
          if pSelectedProduct.ilk <> #propList then
            return error(me, "incorrect Selected Product Data", #eventProc)
          end if
          getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
        else
          return 0
        end if
      end if
    end if
  end if
  return 1
end
