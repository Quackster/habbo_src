property pNumOfColorBoxies, pPageData, pSmallImg, pSelectedProduct, pLastProductNum, pSelectedOrderNum, pSelectedColorNum

on construct me 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #construct, #major))
  end if
  pPageData = [:]
  pSmallImg = image(32, 32, 32)
  pSelectedOrderNum = 1
  pSelectedColorNum = 1
  pLastProductNum = 0
  pNumOfColorBoxies = 0
  f = 1
  repeat while f <= 50
    tID = "ctlg_selectcolor_bg_" & f
    if tCataloguePage.elementExists(tID) then
      pNumOfColorBoxies = (pNumOfColorBoxies + 1)
    else
    end if
    f = (1 + f)
  end repeat
  return TRUE
end

on define me, tPageProps 
  if tPageProps.ilk <> #propList then
    return(error(me, "Incorrect Catalogue page data", #define, #major))
  end if
  pPageData = [:]
  pPageData.sort()
  if not voidp(tPageProps.getAt("productList")) then
    tProducts = tPageProps.getAt("productList")
    aa = the milliSeconds
    f = 1
    repeat while f <= tProducts.count
      if not voidp(tProducts.getAt(f).getAt("class")) then
        tClass = tProducts.getAt(f).getAt("class")
        if tClass contains "*" then
          tClass = tClass.getProp(#char, 1, (offset("*", tClass) - 1))
        end if
        if voidp(pPageData.getAt(tClass)) then
          pPageData.setAt(tClass, [:])
          pPageData.getAt(tClass).sort()
        end if
        pPageData.getAt(tClass).addProp(tProducts.getAt(f).getAt("class"), tProducts.getAt(f))
      end if
      f = (1 + f)
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
    return(error(me, "Couldn't access catalogue window!", #renderSmallIcons, #major))
  end if
  tWndObj = tCataloguePage
  if (tstate = void()) then
    tFirst = 1
    tLast = pPageData.count
    f = 1
    repeat while f <= pPageData.count
      tID = "ctlg_small_img_" & f
      if tWndObj.elementExists(tID) then
        tWndObj.getElement(tID).clearImage()
        tWndObj.getElement(tID).setProperty(#ink, 36)
      end if
      f = (1 + f)
    end repeat
    exit repeat
  end if
  if tstate <> #hilite then
    if (tstate = #unhilite) then
      tFirst = tPram
      tLast = tPram
    else
      if (tstate = #furniLoaded) then
        if voidp(pPageData) then
          return()
        end if
        tFurniName = tPram
        tFirst = pPageData.count
        tLast = 1
        i = 1
        repeat while i <= pPageData.count
          if pPageData.getPropAt(i) contains tFurniName then
            if tFirst > i then
              tFirst = i
            end if
            if tLast < i then
              tLast = i
            end if
          end if
          i = (1 + i)
        end repeat
        exit repeat
      end if
      return(error(me, "unsupported mode", #ShowSmallIcons, #minor))
    end if
    if voidp(tFirst) or voidp(tLast) then
      return()
    end if
    if tFirst < 1 or tLast < 1 then
      return()
    end if
    f = tFirst
    repeat while f <= tLast
      if not voidp(pPageData.getAt(f).getAt(1).getAt("smallPrewImg")) then
        tmember = pPageData.getAt(f).getAt(1).getAt("smallPrewImg")
        tID = "ctlg_small_img_" & f
        if tmember <> 0 then
          if tWndObj.elementExists(tID) then
            pSmallImg.fill(pSmallImg.rect, rgb(255, 255, 255))
            if not voidp(tstate) then
              if (tstate = #hilite) and memberExists("ctlg_small_active2_bg") then
                tBgImage = member("ctlg_small_active2_bg").image
                pSmallImg.copyPixels(tBgImage, tBgImage.rect, pSmallImg.rect)
              end if
            end if
            tTempSmallImg = getObject("Preview_renderer").renderPreviewImage(void(), void(), "", pPageData.getPropAt(f))
            tdestrect = (pSmallImg.rect - tTempSmallImg.rect)
            tMargins = rect(0, 0, 0, 0)
            tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tTempSmallImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tTempSmallImg.height)) + tMargins)
            pSmallImg.copyPixels(tTempSmallImg, tdestrect, tTempSmallImg.rect, [#ink:36])
            tWndObj.getElement(tID).clearImage()
            tWndObj.getElement(tID).feedImage(pSmallImg)
          end if
        end if
      end if
      f = (1 + f)
    end repeat
  end if
end

on renderProductColors me, tOrderNum 
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #renderProductColors, #major))
  end if
  if pPageData.ilk <> #propList then
    return(error(me, "page data not found", #renderProductColors, #major))
  end if
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #renderProductColors, #major))
  end if
  tWndObj = tCataloguePage
  f = 1
  repeat while f <= pNumOfColorBoxies
    tID = "ctlg_selectcolor_bg_" & f
    if tCataloguePage.elementExists(tID) then
      tColor = paletteIndex(0)
      tWndObj.getElement(tID).setProperty(#bgColor, tColor)
      tWndObj.getElement(tID).setProperty(#blend, 30)
    end if
    tID = "ctlg_selectcolor_" & f
    if tCataloguePage.elementExists(tID) then
      tWndObj.getElement(tID).setProperty(#blend, 30)
    end if
    f = (1 + f)
  end repeat
  if tOrderNum <= pPageData.count then
    tProducts = pPageData.getAt(tOrderNum)
    f = 1
    repeat while f <= tProducts.count
      if not voidp(tProducts.getAt(f).getAt("partColors")) then
        tItemDeLimiter = the itemDelimiter
        the itemDelimiter = ","
        tColor = tProducts.getAt(f).getAt("partColors").getProp(#item, tProducts.getAt(f).getAt("partColors").count(#item))
        the itemDelimiter = tItemDeLimiter
        if (tColor.getProp(#char, 1) = "#") then
          tColor = rgb(tColor)
        else
          tColor = paletteIndex(integer(tColor))
        end if
        tID = "ctlg_selectcolor_bg_" & f
        if tWndObj.elementExists(tID) then
          tWndObj.getElement(tID).setProperty(#bgColor, tColor)
          tWndObj.getElement(tID).setProperty(#blend, 100)
        end if
        tID = "ctlg_selectcolor_" & f
        if tCataloguePage.elementExists(tID) then
          tWndObj.getElement(tID).setProperty(#blend, 100)
        end if
      end if
      f = (1 + f)
    end repeat
  end if
end

on selectProduct me, tOrderNum 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #selectProduct, #major))
  end if
  tWndObj = tCataloguePage
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectProduct, #major))
  end if
  if voidp(pPageData) then
    return(error(me, "product not found", #selectProduct, #major))
  end if
  if tOrderNum > pPageData.count then
    return()
  end if
  if voidp(pPageData.getAt(tOrderNum).getAt(1)) then
    return()
  end if
  pSelectedProduct = pPageData.getAt(tOrderNum).getAt(1)
  pSelectedColorNum = 1
  pSelectedOrderNum = tOrderNum
  renderProductColors(me, tOrderNum)
  getThread(#catalogue).getInterface().showPreviewImage(pSelectedProduct)
  if not voidp(pSelectedProduct.getAt("name")) then
    if tWndObj.elementExists("ctlg_product_name") then
      tWndObj.getElement("ctlg_product_name").setText(pSelectedProduct.getAt("name"))
    end if
  end if
  if not voidp(pSelectedProduct.getAt("description")) then
    if tWndObj.elementExists("ctlg_description") then
      tWndObj.getElement("ctlg_description").setText(pSelectedProduct.getAt("description"))
    end if
  end if
  if not voidp(pSelectedProduct.getAt("price")) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct.getAt("price")) > 1 then
        tText = pSelectedProduct.getAt("price") && getText("credits", "credits")
      else
        tText = pSelectedProduct.getAt("price") && getText("credit", "credit")
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
    return()
  end if
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #selectColor, #major))
  end if
  tWndObj = tCataloguePage
  if not integerp(pSelectedOrderNum) then
    return(error(me, "Incorrect SelectedOrderNum", #selectColor, #major))
  end if
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectColor, #major))
  end if
  if voidp(pPageData) then
    return(error(me, "product not found", #selectColor, #major))
  end if
  if voidp(pPageData.getAt(pSelectedOrderNum)) then
    return()
  end if
  if tOrderNum > pPageData.getAt(pSelectedOrderNum).count then
    return()
  end if
  pSelectedColorNum = tOrderNum
  pSelectedProduct = pPageData.getAt(pSelectedOrderNum).getAt(pSelectedColorNum)
  getThread(#catalogue).getInterface().showPreviewImage(pSelectedProduct)
  if not voidp(pSelectedProduct.getAt("name")) then
    if tWndObj.elementExists("ctlg_product_name") then
      tWndObj.getElement("ctlg_product_name").setText(pSelectedProduct.getAt("name"))
    end if
  end if
  if not voidp(pSelectedProduct.getAt("description")) then
    if tWndObj.elementExists("ctlg_description") then
      tWndObj.getElement("ctlg_description").setText(pSelectedProduct.getAt("description"))
    end if
  end if
  if not voidp(pSelectedProduct.getAt("price")) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct.getAt("price")) > 1 then
        tText = pSelectedProduct.getAt("price") && getText("credits", "credits")
      else
        tText = pSelectedProduct.getAt("price") && getText("credit", "credit")
      end if
      tWndObj.getElement("ctlg_price_1").setText(tText)
    end if
  end if
end

on eventProc me, tEvent, tSprID, tProp 
  if (tEvent = #mouseUp) then
    if (tSprID = "close") then
      return FALSE
    end if
  end if
  if (tEvent = #mouseDown) then
    if tSprID contains "ctlg_small_img_" then
      tItemDeLimiter = the itemDelimiter
      the itemDelimiter = "_"
      tProductOrderNum = integer(tSprID.getProp(#item, tSprID.count(#item)))
      the itemDelimiter = tItemDeLimiter
      selectProduct(me, tProductOrderNum)
    else
      if tSprID contains "ctlg_selectcolor_" or tSprID contains "ctlg_selectcolor_bg_10" then
        tItemDeLimiter = the itemDelimiter
        the itemDelimiter = "_"
        tOrderNum = integer(tSprID.getProp(#item, tSprID.count(#item)))
        the itemDelimiter = tItemDeLimiter
        selectColor(me, tOrderNum)
      else
        if (tSprID = "ctlg_buy_button") then
          if pSelectedProduct.ilk <> #propList then
            return(error(me, "incorrect Selected Product Data", #eventProc, #major))
          end if
          getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
        else
          return FALSE
        end if
      end if
    end if
  end if
  return TRUE
end
