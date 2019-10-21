property pNumOfColorBoxies, pPageData, pSmallImg, pSelectedProduct, pLastProductNum, pSelectedOrderNum, pSelectedColorNum

on construct me 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #construct))
  end if
  pPageData = [:]
  pSmallImg = image(32, 32, 24)
  pSelectedOrderNum = 1
  pSelectedColorNum = 1
  pLastProductNum = 0
  pNumOfColorBoxies = 0
  f = 1
  repeat while f <= 50
    tid = "ctlg_selectcolor_bg_" & f
    if tCataloguePage.elementExists(tid) then
      pNumOfColorBoxies = (pNumOfColorBoxies + 1)
    else
    end if
    f = (1 + f)
  end repeat
  if tCataloguePage.elementExists("trophies_habbo_name") then
    tUserName = getObject(#session).get(#userName)
    tCataloguePage.getElement("trophies_habbo_name").setText(tUserName)
  end if
  registerMessage(#serverDate, me.getID(), #setDate)
  if objectExists(#getServerDate) then
    getObject(#getServerDate).getDate()
  end if
  return TRUE
end

on define me, tPageProps 
  if tPageProps.ilk <> #propList then
    return(error(me, "Incorrect Catalogue page data", #define))
  end if
  pPageData = [:]
  pPageData.sort()
  if not voidp(tPageProps.getAt("productList")) then
    tProducts = tPageProps.getAt("productList")
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

on setDate me, tDate 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #construct))
  end if
  if stringp(tDate) then
    if tCataloguePage.elementExists("trophies_date") then
      tCataloguePage.getElement("trophies_date").setText(tDate)
    end if
  end if
end

on renderSmallIcons me, tstate, tPram 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #renderSmallIcons))
  end if
  tWndObj = tCataloguePage
  if (tstate = void()) then
    tFirst = 1
    tLast = pPageData.count
    f = 1
    repeat while f <= pPageData.count
      tid = "ctlg_small_img_" & f
      if tWndObj.elementExists(tid) then
        tWndObj.getElement(tid).clearImage()
        tWndObj.getElement(tid).setProperty(#ink, 36)
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
      return(error(me, "unsupported mode", #ShowSmallIcons))
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
            tdestrect = (pSmallImg.rect - tTempSmallImg.rect)
            tMargins = rect(0, 0, 0, 0)
            tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tTempSmallImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tTempSmallImg.height)) + tMargins)
            pSmallImg.copyPixels(tTempSmallImg, tdestrect, tTempSmallImg.rect, [#ink:36])
            tWndObj.getElement(tid).clearImage()
            tWndObj.getElement(tid).feedImage(pSmallImg)
          end if
        end if
      end if
      f = (1 + f)
    end repeat
  end if
end

on renderProductColors me, tOrderNum 
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #renderProductColors))
  end if
  if pPageData.ilk <> #propList then
    return(error(me, "page data not found", #renderProductColors))
  end if
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #construct))
  end if
  tWndObj = tCataloguePage
  f = 1
  repeat while f <= pNumOfColorBoxies
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
      f = (1 + f)
    end repeat
  end if
end

on selectProduct me, tOrderNum 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #selectProduct))
  end if
  tWndObj = tCataloguePage
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectProduct))
  end if
  if voidp(pPageData) then
    return(error(me, "product not found", #selectProduct))
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

on nextProduct me 
  if pPageData.ilk <> #propList then
    return(error(me, "Incorrect data", #nextProduct))
  end if
  tNext = (pLastProductNum + 1)
  if tNext > pPageData.count then
    tNext = pPageData.count
  end if
  pSelectedOrderNum = tNext
  pSelectedColorNum = 1
  selectProduct(me, tNext)
  renderProductColors(me, tNext)
end

on prevProduct me 
  if pPageData.ilk <> #propList then
    return(error(me, "Incorrect data", #prewProduct))
  end if
  tPrev = (pLastProductNum - 1)
  if tPrev < 1 then
    tPrev = 1
  end if
  pSelectedOrderNum = tPrev
  pSelectedColorNum = 1
  selectProduct(me, tPrev)
  renderProductColors(me, tPrev)
end

on selectColor me, tOrderNum 
  if voidp(pSelectedOrderNum) then
    return()
  end if
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #selectColor))
  end if
  tWndObj = tCataloguePage
  if not integerp(pSelectedOrderNum) then
    return(error(me, "Incorrect SelectedOrderNum", #selectColor))
  end if
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectColor))
  end if
  if voidp(pPageData) then
    return(error(me, "product not found", #selectColor))
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
      if (tSprID = "ctlg_nextmodel_button") then
        me.nextProduct()
      else
        if (tSprID = "ctlg_prevmodel_button") then
          me.prevProduct()
        else
          if tSprID contains "ctlg_selectcolor_" or tSprID contains "ctlg_selectcolor_bg_10" then
            tItemDeLimiter = the itemDelimiter
            the itemDelimiter = "_"
            tOrderNum = integer(tSprID.getProp(#item, tSprID.count(#item)))
            the itemDelimiter = tItemDeLimiter
            selectColor(me, tOrderNum)
          else
            if (tSprID = "ctlg_buy_button") then
              tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
              tText = ""
              if tWndObj.elementExists("dedication_text") then
                tText = tWndObj.getElement("dedication_text").getText()
                tText = replaceChunks(tText, "\r", "\\r")
              end if
              if tText.length < 1 then
                return(executeMessage(#alert, [#msg:"catalog_give_trophymsg", #id:"ctlg_trophymsg"]))
              else
                if tText.length > 150 then
                  return(executeMessage(#alert, [#msg:"catalog_length_trophymsg", #id:"ctlg_trophymsg"]))
                end if
              end if
              if pSelectedProduct.ilk <> #propList then
                return(error(me, "incorrect Selected Product Data", #eventProc))
              end if
              pSelectedProduct.setAt("extra_parm", tText)
              getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
            else
              return FALSE
            end if
          end if
        end if
      end if
    end if
  end if
  return TRUE
end
