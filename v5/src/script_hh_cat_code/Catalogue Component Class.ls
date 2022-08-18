property pCatalogProps, pProductOrderData

on construct me 
  pOrderInfoList = []
  pCatalogProps = [:]
  pProductOrderData = [:]
  if variableExists("ctlg.editmode") then
    pCatalogProps.setAt("editmode", getVariable("ctlg.editmode"))
  else
    pCatalogProps.setAt("editmode", "production")
  end if
  registerMessage(#edit_catalogue, me.getID(), #editModeOn)
  return TRUE
end

on deconstruct me 
  pOrderInfoList = []
  pCatalogProps = [:]
  unregisterMessage(#edit_catalogue, me.getID())
  return TRUE
end

on editModeOn me 
  setVariable("ctlg.editmode", "develop")
  pCatalogProps.setAt("editmode", getVariable("ctlg.editmode"))
end

on getLanguage me 
  if variableExists("language") then
    tLanguage = getVariable("language")
  else
    tLanguage = "en"
  end if
  return(tLanguage)
end

on checkProductOrder me, tProductProps 
  if tProductProps.ilk <> #propList then
    return(error(me, "Incorrect SelectedProduct proplist", #buySelectedProduct))
  end if
  if not voidp(tProductProps.getAt("purchaseCode")) then
    tProps = [:]
    tstate = "OK"
    if not voidp(tProductProps.getAt("name")) then
      tProps.setAt(#name, tProductProps.getAt("name"))
    else
      tProps.setAt(#name, "ERROR")
      tstate = "ERROR"
    end if
    if not voidp(tProductProps.getAt("purchaseCode")) then
      tProps.setAt(#code, tProductProps.getAt("purchaseCode"))
    else
      tProps.setAt(#code, "ERROR")
      tstate = "ERROR"
    end if
    if not voidp(tProductProps.getAt("price")) then
      tProps.setAt(#price, tProductProps.getAt("price"))
    else
      tProps.setAt(#price, "ERROR")
      tstate = "ERROR"
    end if
    pProductOrderData = tProductProps.duplicate()
    me.getInterface().showOrderInfo(tstate, tProps)
    return TRUE
  else
    pProductOrderData = [:]
    return FALSE
  end if
end

on purchaseProduct me, tGiftProps 
  if pProductOrderData.ilk <> #propList then
    return(error(me, "Incorrect Product data", #purchaseProduct))
  end if
  if tGiftProps.ilk <> #propList then
    return(error(me, "Incorrect Gift Props", #purchaseProduct))
  end if
  if voidp(pProductOrderData.getAt("name")) then
    return(error(me, "Product name not found", #purchaseProduct))
  end if
  if voidp(pProductOrderData.getAt("purchaseCode")) then
    return(error(me, "PurchaseCode name not found", #purchaseProduct))
  end if
  if voidp(pProductOrderData.getAt("extra_parm")) then
    pProductOrderData.setAt("extra_parm", "-")
  end if
  if voidp(pCatalogProps.getAt("editmode")) then
    return(error(me, "Catalogue mode not found", #purchaseProduct))
  end if
  if voidp(pCatalogProps.getAt("lastPageID")) then
    return(error(me, "Catalogue page id missing", #purchaseProduct))
  end if
  if not voidp(tGiftProps.getAt("gift")) then
    tGift = tGiftProps.getAt("gift") & "\r"
    if not voidp(tGiftProps.getAt("gift_receiver")) then
      tGift = tGift & tGiftProps.getAt("gift_receiver") & "\r"
    else
      tGift = ""
    end if
    if not voidp(tGiftProps.getAt("gift_msg")) then
      tGift = tGift & tGiftProps.getAt("gift_msg") & "\r"
    else
      tGift = ""
    end if
  else
    tGift = "0"
  end if
  tOrderStr = ""
  tOrderStr = "GPRC /" & "\r"
  tOrderStr = tOrderStr & pCatalogProps.getAt("editmode") & "\r"
  tOrderStr = tOrderStr & pCatalogProps.getAt("lastPageID") & "\r"
  tOrderStr = tOrderStr & me.getLanguage() & "\r"
  tOrderStr = tOrderStr & pProductOrderData.getAt("purchaseCode") & "\r"
  tOrderStr = tOrderStr & pProductOrderData.getAt("extra_parm") & "\r"
  tOrderStr = tOrderStr & tGift
  if not connectionExists(getVariable("connection.info.id")) then
    return FALSE
  end if
  return(getConnection(getVariable("connection.info.id")).send(#info, tOrderStr))
end

on retrieveCatalogueIndex me 
  if not voidp(pCatalogProps.getAt("editmode")) then
    tEditmode = pCatalogProps.getAt("editmode")
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  if not voidp(pCatalogProps.getAt("catalogueIndex")) and tEditmode <> "develop" then
    me.getInterface().saveCatalogueIndex(pCatalogProps.getAt("catalogueIndex"))
  else
    if connectionExists(getVariable("connection.info.id")) then
      return(getConnection(getVariable("connection.info.id")).send(#info, "GCIX /" & tEditmode & "/" & tLanguage))
    else
      return FALSE
    end if
  end if
end

on retrieveCataloguePage me, tPageID 
  if not voidp(pCatalogProps.getAt("editmode")) then
    tEditmode = pCatalogProps.getAt("editmode")
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  pProductOrderData = void()
  if not voidp(pCatalogProps.getAt(tPageID)) and tEditmode <> "develop" then
    pCatalogProps.setAt("lastPageID", tPageID)
    me.getInterface().cataloguePageData(pCatalogProps.getAt(tPageID))
  else
    if connectionExists(getVariable("connection.info.id")) then
      return(getConnection(getVariable("connection.info.id")).send(#info, "GCAP /" & tEditmode & "/" & tPageID & "/" & tLanguage))
    else
      return FALSE
    end if
  end if
  return FALSE
end

on purchaseReady me, tStatus, tMsg 
  if (tStatus = "OK") then
    me.getInterface().showPurchaseOk()
  else
    if (tStatus = "NOBALANCE") then
      error(me, "User out of cash!", #purchaseReady)
    else
      if (tStatus = "ERROR") then
        error(me, "Purchase error:" && tMsg, #purchaseReady)
      else
        error(me, "Unsupported purchase result:" && tStatus && tMsg, #purchaseReady)
      end if
    end if
  end if
  return TRUE
end

on saveCatalogueIndex me, tdata 
  if tdata.ilk <> #propList then
    return(error(me, "Incorrect Catalogue Format", #saveCatalogueIndex))
  end if
  if (tdata.count = 0) then
    return FALSE
  end if
  pCatalogProps.setAt("catalogueIndex", tdata)
  me.getInterface().saveCatalogueIndex(tdata)
end

on saveCataloguePage me, tdata 
  if tdata.ilk <> #propList then
    return(error(me, "Incorrect Catalogue Page Format", #saveCataloguePage))
  end if
  if (tdata.count = 0) then
    return FALSE
  end if
  if not voidp(tdata.getAt("id")) then
    tdata = me.solveCatalogueMembers(tdata)
    tPageID = tdata.getAt("id")
    pCatalogProps.setAt(tPageID, tdata)
    pCatalogProps.setAt("lastPageID", tPageID)
    me.getInterface().cataloguePageData(tdata)
  else
    return(error(me, "Catalogue Page ID missing", #saveCataloguePage))
  end if
end

on solveCatalogueMembers me, tdata 
  tLanguage = me.getLanguage()
  if not voidp(tdata.getAt("headerImage")) then
    if memberExists(tdata.getAt("headerImage") & "_" & tLanguage) then
      tdata.setAt("headerImage", getmemnum(tdata.getAt("headerImage") & "_" & tLanguage))
    else
      if memberExists(tdata.getAt("headerImage")) then
        tdata.setAt("headerImage", getmemnum(tdata.getAt("headerImage")))
      else
        tdata.setAt("headerImage", 0)
      end if
    end if
  end if
  if not voidp(tdata.getAt("teaserImgList")) then
    tImageNameList = tdata.getAt("teaserImgList")
    tMemList = []
    if tImageNameList.count > 0 then
      repeat while tImageNameList <= undefined
        tImg = getAt(undefined, tdata)
        if memberExists(tImg & "_" & tLanguage) then
          tMemList.add(getmemnum(tImg & "_" & tLanguage))
        else
          if memberExists(tImg) then
            tMemList.add(getmemnum(tImg))
          else
            tMemList.add(0)
          end if
        end if
      end repeat
    end if
    tdata.setAt("teaserImgList", tMemList)
  end if
  if not voidp(tdata.getAt("productList")) then
    f = 1
    repeat while f <= tdata.getAt("productList").count
      tProductData = tdata.getAt("productList").getAt(f)
      if not voidp(tProductData.getAt("purchaseCode")) then
        tPrewMember = "ctlg_pic_"
        tPurchaseCode = tProductData.getAt("purchaseCode")
        if memberExists(tPrewMember & tLanguage & "_" & tPurchaseCode) then
          tdata.getAt("productList").getAt(f).setAt("prewImage", getmemnum(tPrewMember & tLanguage & "_" & tPurchaseCode))
        else
          if memberExists(tPrewMember & tPurchaseCode) then
            tdata.getAt("productList").getAt(f).setAt("prewImage", getmemnum(tPrewMember & tPurchaseCode))
          else
            tdata.getAt("productList").getAt(f).setAt("prewImage", 0)
          end if
        end if
        if memberExists(tPrewMember & "small_" & tLanguage & tPurchaseCode) then
          tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum(tPrewMember & "small_" & tLanguage & "_" & tPurchaseCode))
        else
          if memberExists(tPrewMember & "small_" & tPurchaseCode) then
            tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum(tPrewMember & "small_" & tPurchaseCode))
          else
            tdata.getAt("productList").getAt(f).setAt("smallPrewImg", 0)
          end if
        end if
      end if
      if not voidp(tProductData.getAt("class")) then
        tClass = tProductData.getAt("class")
        if tClass contains "*" then
          tClass = tClass.getProp(#char, 1, (offset("*", tClass) - 1))
        end if
        if (tdata.getAt("productList").getAt(f).getAt("smallPrewImg") = 0) then
          if memberExists(tClass & "_small") then
            tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum(tClass & "_small"))
          else
            tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum("no_icon_small"))
          end if
        end if
      end if
      f = (1 + f)
    end repeat
  end if
  return(tdata)
end
